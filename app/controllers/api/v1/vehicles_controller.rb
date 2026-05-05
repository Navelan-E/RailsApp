class Api::V1::VehiclesController < Api::V1::BaseController
  before_action -> { doorkeeper_authorize! :"vehicle:read" }
    before_action -> { doorkeeper_authorize! :"vehicle:write" }, only: [:new, :create, :destroy]
  before_action :fetch_records, only: %i[show]
  def index
    if params[:search]
      vehicles = Vehicle.where("number_plate LIKE ?", "%#{params[:search]}%")
    else
      vehicles = Vehicle.all
    end
    render json: vehicles
  end

  def new
  end

  def show
    vehicle = Vehicle.find_by(id: params[:id])
    unless vehicle
      render json:{
        error: "Vehicle not found"
      }, status: :not_found
      return
    end
    render json:{
      vehicle: vehicle,
      record: @records
    }, status: :ok
  end

  def fetch_records
    vehicle = Vehicle.find_by(id: params[:vehicle_id])
    @records = (vehicle&.records).to_a()
  end

  def create
    if Vehicle.exists?(number_plate: vehicle_params[:number_plate])
      render json: {
         message: "Vehicle already exists"
      }, status: :unprocessable_entity
      return
    end
    vehicle = Vehicle.new(vehicle_params)
    vehicle.customer_id = doorkeeper_token&.resource_owner_id
    if vehicle.save
      render json: {
        message: 'Vehicle added successfully.',
        vehicle: vehicle
    }, status: :created
    else
      render json: {
        error: 'Failed to add vehicle.'
      }, status: :unprocessable_entity
    end
  end

  def destroy
    puts "Destroying vehicle with ID: #{params}"
    vehicle = Vehicle.find_by(id:params[:id])
    unless vehicle
      render json:{
        error: "Vehicle not found"
      }, status: :not_found
      return
    end
    if vehicle.destroy
      head :no_content
    else
      render json: { errors: vehicle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:model, :number_plate)
  end
end
