class VehiclesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def select_or_create
    vehicle = Vehicle.find_by(vehicle_no: params[:vehicle_no])
    unless vehicle
      puts "New Vechicle Created"
      vehicle = Vehicle.create(vehicle_no: params[:vehicle_no], model: params[:model], customer_id: params[:customer_id])
    end
    vehicle
  end
end
