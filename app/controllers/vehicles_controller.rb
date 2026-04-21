class VehiclesController < ApplicationController
  before_action :any_signed_in?
  before_action :authenticate_customer!, only: [:new, :create, :destroy]
  before_action :fetch_records, only: %i[show]
  def index
    if params[:search]
      @vehicles = Vehicle.where("name LIKE ?", "%#{params[:search]}%")
    else
      @vehicles = Vehicle.all
    end
  end

  def show
    @vehicle = Vehicle.find(params[:format])
  end

  def fetch_records
    @vehicle = Vehicle.find_by(id: params[:vehicle_id])
    @records = []
    if @vehicle
      @records = @vehicle.records
    end
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    if Vehicle.exists?(number_plate: vehicle_params[:number_plate])
      flash.now[:alert] = "Vehicle with this number plate already exists."
      render :new, status: :unprocessable_entity
      return
    end
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.customer_id = current_customer.id
    if @vehicle.save
      redirect_to profile_show_path, notice: 'Vehicle added successfully.'
    else
      flash.now[:alert] = 'Failed to add vehicle.'
      render :new
    end
  end

  def destroy
    puts "Destroying vehicle with ID: #{params}"
    @vehicle = Vehicle.find_by(id:params[:id])
    if @vehicle.destroy
      redirect_to profile_show_path, notice: 'Vehicle deleted successfully.'
    else
      redirect_to profile_show_path, alert: 'Failed to delete vehicle.'
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:model, :number_plate)
  end
end
