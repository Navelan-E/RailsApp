class VehiclesController < ApplicationController
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
end
