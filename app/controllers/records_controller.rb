class RecordsController < ApplicationController
  def index
    if params[:q].present?
      vehicles = Vehicle.where("number_plate ILIKE ?", "%#{params[:q]}%")

      if vehicles.exists?
        @records = Record.where(vehicle_id: vehicles.select(:id))
      else
        @records = Record.none
      end
    else
      @records = Record.all
    end
  end

  def show
    @record = Record.find(params[:id])
  end

  def new
    @record = Record.new
  end

  def create
    rp = record_params

    @customer = Customer.find_or_create_by(phone: rp[:customer_phone]) do |c|
      c.name = rp[:customer_name]
      c.email = rp[:customer_email]
    end

    @vehicle = Vehicle.find_or_create_by(number_plate: rp[:vehicle_no]) do |v|
      v.model = rp[:model]
      v.customer_id = @customer.id
    end
    Rails.logger.info("RP: #{record_params.inspect}")
    Rails.logger.info("Vehicle No: #{record_params[:vehicle_no]}")
    Rails.logger.info("Vehicle: #{@vehicle.inspect}")
    @record = Record.new(
      internal_notes: rp[:internal_notes],
      vehicle_id: @vehicle.id,
      status: "pending",
    )

    if @record.save
      redirect_to records_path, notice: "Record created successfully"
    else
      Rails.logger.error(@record.errors.full_messages)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @record = Record.find(params[:id])
    @mechanics = Mechanic.all
  end

  def update
    @record = Record.find(params[:id])
    param = params[:record].permit(:internal_notes, :status, :mechanic_id, :total_cost)
    puts "Update Params: #{param}"
    if @record.update(param)
      redirect_to records_path, notice: "Record updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def record_params
    params.require(:record).permit(
      :internal_notes,
      :vehicle_no,
      :model,
      :customer_name,
      :customer_phone,
      :customer_email
    )
  end
end
