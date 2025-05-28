class TenantsController < ApplicationController
  skip_before_action :authenticate_user
  skip_before_action :set_tenant
  
  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)
    
    if @tenant.save
      redirect_to root_url(subdomain: @tenant.subdomain), notice: "Tenant was successfully created.", allow_other_host: true
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def tenant_params
    params.require(:tenant).permit(:name, :subdomain)
  end
end
