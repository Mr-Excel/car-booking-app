class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :authenticate_user
  
  helper_method :current_user, :logged_in?
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  private
  
  def set_tenant
    current_tenant = Tenant.find_by(subdomain: request.subdomain)
    set_current_tenant(current_tenant)
  end
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def authenticate_user
    redirect_to login_path, alert: "You must be logged in to access this page" unless logged_in?
  end
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
