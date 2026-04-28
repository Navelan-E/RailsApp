class Api::V1::CustomersController < Api::V1::BaseController

  def index
    customers = Customer.all
    render json: customers
  end

  def show
    customer = Customer.find_by(id: params[:id])

    if customer
      render json: customer.as_json(include: :vehicles)
    else
      render json: { error: "Customer not found" }, status: :not_found
    end
  end
  
  def update
    puts("Customer Update Params: #{params}")
    customer = Customer.find_by(id: params[:id])
    if customer&.update(customer_params)
      render json: { message: "Created successfully",
        customer: customer
      }, status: :ok                                                                                                                                                                                                                    
    else
      if customer
        render json: {
          error: customer.errors.full_messages
        }, status: :unprocessable_entity
      else
        render json: { error: "Customer not found.",
        }, status: :not_found
      end
    end
  end
  
  def disable
    puts("Disable Customer Params: #{params}")
    @customer = Customer.find_by(id: params[:id])
    if @customer
      @customer.lock_access!
      render json: { message: "Disabled successfully",
      }, status: :ok
    else
      render json: { error: "Customer not found.",
      }, status: :not_found
    end
  end

  def unlock
    @customer = Customer.find_by(id: params[:id])
    if @customer
      if @customer.access_locked?
        @customer.unlock_access!
      end
      render json: { message: "Unloacked successfully",
      }, status: :ok
    else
      render json: { error: "Customer not found.",
      }, status: :not_found
    end
  end

  def customer_params
    params.require(:customer).permit(:name, :phone, :email)
  end

end
