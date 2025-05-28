class GuestUsersController < ApplicationController
  skip_before_action :authenticate_user
  
  def new
    @guest_user = GuestUser.new
  end

  def create
    @guest_user = GuestUser.new(guest_user_params)
    @guest_user.tenant = current_tenant
    
    if @guest_user.save
      session[:guest_user_id] = @guest_user.id
      redirect_to new_payment_path(booking_id: params[:booking_id]), notice: "Please proceed with payment"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def guest_user_params
    params.require(:guest_user).permit(:first_name, :last_name, :email, :phone)
  end
end
