class BookingsController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create]
  before_action :set_booking, only: [:show, :cancel]
  
  def index
    @bookings = current_user.bookings.order(created_at: :desc)
  end
  
  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.tenant = current_tenant
    
    if logged_in?
      @booking.user = current_user
    end
    
    if @booking.save
      if logged_in?
        redirect_to new_payment_path(booking_id: @booking.id)
      else
        redirect_to new_guest_user_path(booking_id: @booking.id)
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @booking
  end
  
  def cancel
    authorize @booking
    
    if @booking.can_cancel?
      @booking.update(status: 'cancelled')
      redirect_to bookings_path, notice: "Booking cancelled successfully"
    else
      redirect_to @booking, alert: "This booking cannot be cancelled"
    end
  end
  
  private
  
  def set_booking
    @booking = Booking.find(params[:id])
  end
  
  def booking_params
    params.require(:booking).permit(
      :pickup_location, :dropoff_location, 
      :pickup_lat, :pickup_lng, :dropoff_lat, :dropoff_lng,
      :distance, :duration, :passengers, :pickup_note,
      :payment_method
    )
  end
end
