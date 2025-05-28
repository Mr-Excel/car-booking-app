class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  
  def new
    puts "current_tenant: #{current_tenant}"
    @user = User.new
  end

  def create
    
    @user = User.new(user_params)
    @user.tenant = current_tenant
    
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    
    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :password, :password_confirmation)
  end
end
