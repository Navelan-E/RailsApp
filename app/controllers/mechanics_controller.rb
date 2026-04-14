class MechanicsController < ApplicationController

    def index
        if params[:q].present?
            @mechanics = Mechanic.where("name LIKE ?", "%#{params[:q].downcase}%")
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
            redirect_to mechanics_path, notice: 'Mechanic was successfully created.'
        else
            render :new
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
