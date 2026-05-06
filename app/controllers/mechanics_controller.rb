class MechanicsController < ApplicationController
    before_action :any_signed_in?
    before_action :authenticate_pros?, except: [:index]
    before_action :authenticate_admin_user!, only: [:destroy]

    def index
        if params[:q].present?
            @mechanics = Mechanic.where("name ILIKE ?", "%#{params[:q]}%")
        else
            @mechanics = Mechanic.all
        end
    end

    def show
        @mechanic = Mechanic.find(params[:id])
    end

    def update
        @mechanic = Mechanic.find(params[:id])

        if @mechanic.update(params[:mechanic].permit(:name, :experience))
            redirect_to profile_show_path(@mechanic), notice: "Mechanic updated successfully"
        else
            flash.now[:alert] = @mechanic.errors.full_messages.join(", ")
            redirect_to profile_edit_path(@mechanic), status: :unprocessable_entity
        end
    end

    def destroy
        @mechanic = Mechanic.find(params[:id])
        @mechanic.destroy
        redirect_to mechanics_path, notice: 'Mechanic was successfully deleted.'
    end

    def disable
        @mechanic = Mechanic.find_by(id: params[:id])
        if @mechanic
        @mechanic.lock_access!
        redirect_to root_path, notice: "Mechanic disabled successfully."
        else
        redirect_to profile_show_path(@mechanic), alert: "Mechanic not found."
        end
    end
end
