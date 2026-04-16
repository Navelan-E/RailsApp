class MechanicsController < ApplicationController

    def index
        if params[:q].present?
            @mechanics = Mechanic.where("name ILIKE ?", "%#{params[:q]}%")
        else
            @mechanics = Mechanic.all
        end
    end

    def new
        @mechanic = Mechanic.new
    end

    def create
        @mechanic = Mechanic.new(mechanic_params)

        if @mechanic.save
            if params[:return_to].present?
                redirect_to params[:return_to], notice: "Mechanic created successfully"
            else
                redirect_back(fallback_location: :records_path, notice: "Mechanic created successfully")
            end
        else
            flash.now[:alert] = @mechanic.errors.full_messages.join(", ")
            render :new, status: :unprocessable_entity
        end
    end

    def mechanic_params
        params.require(:mechanic).permit(:name, :experience)
    end

    def destroy
        @mechanic = Mechanic.find(params[:id])
        @mechanic.destroy
        redirect_to mechanics_path, notice: 'Mechanic was successfully deleted.'
    end
end
