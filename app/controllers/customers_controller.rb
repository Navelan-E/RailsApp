class CustomersController < ApplicationController
  before_action :authenticate_pros?, except: [:update,:disable,:unlock]
  before_action :any_signed_in?, except: [:update,:disable,:unlock]
  before_action :authenticate_customer!, only: [:unlock]
  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find_by(id: params[:id])
    if @customer
      @vehicles = @customer.vehicles
    else
      redirect_to customers_path, alert: "Customer not found."
    end
  end

  def update
    puts("Customer Update Params: #{params}")
    @customer = Customer.find_by(id: params[:id])
    unless @customer
      redirect_to root_path, alert: "Customer not found."
      return
    end
    
    if @customer.update(customer_params)
      redirect_to root_path, notice: "Customer updated successfully."
    else
      flash.now[:alert] = @customer.errors.full_messages.join(", ")
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :email)
  end

  def disable
    puts("Disable Customer Params: #{params}")
    @customer = Customer.find_by(id: params[:id])
    unless @customer
      redirect_to root_path, alert: "Customer not found."
      return
    end
    
    @customer.lock_access!
    redirect_to root_path, notice: "Customer disabled successfully."
  end

  def unlock
    @customer = Customer.find_by(id: params[:id])
    unless @customer
      redirect_to root_path, alert: "Customer not found."
      return
    end
    
    if @customer.access_locked?
      @customer.unlock_access!
    end
    redirect_to root_path, notice: "Customer unlocked successfully."
  end
end
