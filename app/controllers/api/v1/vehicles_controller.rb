class Api::V1::VehiclesController < ApplicationController
  before_action :fetch_records, only: %i[show]
  def index
    if params[:search]
      vehicles = Vehicle.where("name LIKE ?", "%#{params[:search]}%")
    else
      vehicles = Vehicle.all
    end
    render json: vehicles
  end

  def show
    vehicle = Vehicle.find(params[:format])
    render json:{
      vehicle: vehicle,
      record: records
    }, status: :ok
  end

  def fetch_records
    vehicle = Vehicle.find_by(id: params[:vehicle_id])
    records = []
    if vehicle
      records = vehicle.records
    end
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    if Vehicle.exists?(number_plate: vehicle_params[:number_plate])
      render json: {
         message: "Vehicle already exists"
      }, status: :unprocessable_entity
      return
    end
    vehicle = Vehicle.new(vehicle_params)
    vehicle.customer_id = current_customer.id
    if @vehicle.save
      render json: {
        message: 'Vehicle added successfully.',
        vehicle: vehicle
    }
    else
      
      render json:{
        error: 'Failed to add vehicle.'
      }, status: :unprocessable_entity
    end
  end

  def destroy
    puts "Destroying vehicle with ID: #{params}"
    vehicle = Vehicle.find_by(id:params[:id])
    if vehicle.destroy
      render json: { message: "Vehicle deleted successfully" }, status: :ok
      else
        render json: { errors: vehicle.errors.full_messages }, status: :unprocessable_entity
      end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:model, :number_plate)
  end
end
