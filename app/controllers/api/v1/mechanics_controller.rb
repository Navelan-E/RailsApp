class Api::V1::MechanicsController < Api::V1::BaseController
    before_action -> { doorkeeper_authorize! :"mechanic:read" }
    before_action -> { doorkeeper_authorize! :"mechanic:write" }, except: [:index]
    def index
        if params[:q].present?
            mechanics = Mechanic.where("name ILIKE ?", "%#{params[:q]}%")
        else
            mechanics = Mechanic.all
        end
        render json: mechanics
    end

    def update
        mechanic = Mechanic.find_by(id: params[:id])
        if mechanic
            if mechanic&.update(params[:mechanic].permit(:name, :email, :experience))
                render json: {
                    message: "Updated successfully",
                    mechanic: mechanic
                }, status: :ok
            else
                render json:{
                    error: Array(mechanic.errors&.full_messages).join(", ")
                }, status: :unprocessable_entity
            end
        else
            render json: {
                    error: "Mechanic not found"
                }, status: :not_found
        end
    end

    def create
        temp = mechanic_params
        temp[:password] = '123456'
        mechanic = Mechanic.new(temp)
        if mechanic.save
            render json:{
              message: "Created Successfully",
              mechanic: mechanic
            }, status: :created
        else
            render json:{
              error: mechanic.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
        end
    end

    def show
        mechanic = Mechanic.find_by(id: params[:id])
        unless mechanic
            render json: { error: "Mechanic not found."
               }, status: :not_found
            return
        end
        render json: mechanic
    end

    def mechanic_params
        params.require(:mechanic).permit(:name, :experience, :email)
    end

    def destroy
      mechanic = Mechanic.find_by(id: params[:id])
        if mechanic
            if mechanic.destroy
                head :no_content
            else
                render json: { errors: mechanic.errors.full_messages }, status: :unprocessable_entity
            end
        else
            render json: { error: "Mechanic not found."
        }, status: :not_found
        end
    end

    def disable
      mechanic = Mechanic.find_by(id: params[:id])
      if mechanic
        mechanic.lock_access!
        render json: { message: "Disabled successfully"
      }, status: :ok
      else
        render json: { error: "Mechanic not found."
        }, status: :not_found
      end
    end

    def unlock
    mechanic = Mechanic.find_by(id: params[:id])
    puts mechanic
        if mechanic
            if mechanic.access_locked?
                mechanic.unlock_access!
            end
            render json: { message: "Unlocked successfully"
            }, status: :ok
        else
            render json: { error: "Mechanic not found."
            }, status: :not_found
        end
    end
end
