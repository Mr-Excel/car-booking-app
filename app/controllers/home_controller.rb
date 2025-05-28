class HomeController < ApplicationController
  skip_before_action :authenticate_user
  
  def index
    if current_tenant
      @tenant = current_tenant
    else
      redirect_to new_tenant_path
    end
  end
end
