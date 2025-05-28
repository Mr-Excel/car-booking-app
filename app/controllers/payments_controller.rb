class PaymentsController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create, :webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook]
  before_action :set_booking, only: [:new, :create]
  
  def new
    @payment = Payment.new
    @amount = @booking.estimated_price
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.booking = @booking
    @payment.tenant = current_tenant
    @payment.amount = @booking.estimated_price
    
    if params[:payment_method] == 'cash'
      @payment.status = 'pending'
      
      if @payment.save
        redirect_to booking_path(@booking), notice: "Booking confirmed! Pay with cash on pickup."
      else
        render :new, status: :unprocessable_entity
      end
    else
      # Handle Stripe payment
      begin
        customer = Stripe::Customer.create({
          name: current_user&.full_name || session[:guest_user_id] && GuestUser.find(session[:guest_user_id])&.full_name,
          email: current_user&.email || session[:guest_user_id] && GuestUser.find(session[:guest_user_id])&.email
        })
        
        intent = Stripe::PaymentIntent.create({
          amount: (@payment.amount * 100).to_i, # Stripe expects amount in cents
          currency: 'usd',
          customer: customer.id,
          payment_method: params[:payment_method_id],
          confirmation_method: 'manual',
          confirm: true,
          description: "Booking ##{@booking.id} - #{@booking.pickup_location} to #{@booking.dropoff_location}"
        })
        
        @payment.transaction_id = intent.id
        @payment.status = 'paid'
        
        if @payment.save
          render json: { success: true }
        else
          render json: { success: false, errors: @payment.errors.full_messages }, status: :unprocessable_entity
        end
      rescue Stripe::CardError => e
        render json: { success: false, errors: [e.message] }, status: :payment_required
      end
    end
  end

  def show
    @payment = Payment.find(params[:id])
    authorize @payment
  end
  
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.stripe[:webhook_secret]
      )
    rescue JSON::ParserError => e
      render json: { status: 400, error: 'Invalid payload' }
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { status: 400, error: 'Invalid signature' }
      return
    end
    
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      payment = Payment.find_by(transaction_id: payment_intent.id)
      payment&.update(status: 'paid')
    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      payment = Payment.find_by(transaction_id: payment_intent.id)
      payment&.update(status: 'failed')
    end
    
    render json: { status: 200 }
  end
  
  private
  
  def set_booking
    @booking = Booking.find(params[:booking_id])
  end
  
  def payment_params
    params.require(:payment).permit(:payment_method)
  end
end
