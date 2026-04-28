class Api::V1::MechanicsController < Api::V1::BaseController
      def index
        if params[:q].present?
            mechanics = Mechanic.where("name ILIKE ?", "%#{params[:q]}%")
        else
            mechanics = Mechanic.all
        end
        render json: mechanics
    end

    def new
        mechanic = Mechanic.new
    end

    def create
        mechanic = Mechanic.new(mechanic_params)

        if mechanic.save
            if params[:return_to].present?
                redirect_to params[:return_to]
            else
                redirect_back(fallback_location: :records_path)
            end
            render json: { message: "Created successfully",
              mechanic: mechanic
            }, status: :ok
        else
            render json:{
              error: mechanic.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    def show
        mechanic = Mechanic.find(params[:id])
        render json: mechanic
    end

    def update
        mechanic = Mechanic.find(params[:id])

        if mechanic.update(params[:mechanic].permit(:name, :email, :experience))
            redirect_to profile_show_path(mechanic), notice: "Mechanic updated successfully"
        else
            flash.now[:alert] = mechanic.errors.full_messages.join(", ")
            render :edit, status: :unprocessable_entity
        end
    end

    def mechanic_params
        params.require(:mechanic).permit(:name, :experience)
    end

    def destroy
        mechanic = Mechanic.find(params[:id])
        mechanic.destroy
        redirect_to mechanics_path, notice: 'Mechanic was successfully deleted.'
    end

    def disable
        mechanic = Mechanic.find_by(id: params[:id])
        if mechanic
        mechanic.lock_access!
        redirect_to root_path, notice: "Mechanic disabled successfully."
        else
        redirect_to profile_show_path(mechanic), alert: "Mechanic not found."
        end
    end

    def new
        mechanic = Mechanic.new
    end

    def create
        temp = mechanic_params
        temp[:password] = '123456'
        mechanic = Mechanic.new(temp)
        if mechanic.save
            render json:{
              message: "Created Successfully",
              mechanic: mechanic
            }, status: :ok
        else
            render json:{
              error: mechanic.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
        end
    end

    def show
        mechanic = Mechanic.find(params[:id])
        render json: mechanic
    end

    def update
        mechanic = Mechanic.find(params[:id])

        if mechanic.update(params[:mechanic].permit(:name, :experience))
          render json: {
            message: "Updated successfully",
            mechanic: mechanic
          }, status: :ok
        else
            render json: {
              error: mechanic.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
        end
    end

    def mechanic_params
        params.require(:mechanic).permit(:name, :experience, :email)
    end

    def destroy
      mechanic = Mechanic.find(params[:id])

      if mechanic.destroy
        render json: { message: "Mechanic deleted successfully" }, status: :ok
      else
        render json: { errors: mechanic.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def disable
      mechanic = Mechanic.find_by(id: params[:id])
      if mechanic
        mechanic.lock_access!
        render json: { message: "Disabled successfully",
      }, status: :ok
      else
        render json: { error: "Mechanic not found.",
        }, status: :not_found
      end
    end
end
