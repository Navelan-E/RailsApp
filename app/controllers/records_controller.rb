class RecordsController < ApplicationController

  before_action :set_record, only: [:edit, :update, :show]
  before_action :create_vehicle_customer_and_tags, only: [:create]
  before_action :set_parts, only: [:update]
  after_action :create_service_tags, only: [:create]
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
  end

  def new
    @record = Record.new
  end

  def create
    rp = record_params
    @record = Record.new(
      internal_notes: rp[:internal_notes],
      vehicle_id: @vehicle.id,
      status: "pending",
    )

    if @record.save
      redirect_to records_path, notice: "Record created successfully"
    else
      flash.now[:alert] = @record.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @mechanics = Mechanic.all
    @parts = Part.all
  end

  def update
    param = params[:record].permit(:internal_notes, :status, :mechanic_id, :total_cost)
    puts "Update Params: #{param}"
    if @record.update(param) &&param[:status] == "completed"
      @record.summary.update(customer_notes: params[:record][:summary])
      redirect_to records_path, notice: "Record updated successfully"
    else
      @mechanics = Mechanic.all
      render :edit, status: :unprocessable_entity
    end
  end

  def record_params
    puts("Raw Params: #{params[:record]}" )
    params.require(:record).permit(
      :internal_notes,
      :vehicle_no,
      :model,
      :customer_name,
      :customer_phone,
      :customer_email,
      :custom_tags,
      :tag_ids => []
    )
  end

  def set_record
    @record = Record.find(params[:id])
    @mechanics = Mechanic.all
  end

  def create_vehicle_customer_and_tags
    rp = record_params
    puts "Record Params: #{rp}"
    @customer = Customer.find_or_create_by(phone: rp[:customer_phone]) do |c|
      c.name = rp[:customer_name]
      c.email = rp[:customer_email]
    end

    @vehicle = Vehicle.find_or_create_by(number_plate: rp[:vehicle_no]) do |v|
      v.model = rp[:model]
      v.customer_id = @customer.id
    end
  end
  def set_parts
    @service_part = ServicePart.find_or_initialize_by(record_id: @record.id, part_id: params[:record][:part_id])
    @service_part.quantity = params[:record][:part_quantity]
    if @service_part.save
      @part = Part.find(params[:record][:part_id])
      @part.update(stock: @part.stock - @service_part.quantity)
    else
      flash.now[:alert] = "Failed to update part stock."
      render :edit, status: :unprocessable_entity
    end
  end
  def create_service_tags
    rp = record_params
    @tags = Tag.where(id: rp[:tag_ids]).to_a
    puts("Selected Tag IDs: #{@tags}")
    if rp[:custom_tags].present?
      custom_tags = rp[:custom_tags].split(",").map(&:strip).reject(&:empty?)
      puts( "Custom Tags: #{custom_tags}" )
      custom_tags.each do |tag_name|
        tag = Tag.find_or_create_by!(tag: tag_name)
        @tags << tag unless @tags.include?(tag)
      end
    end
    @tags.each do |tg|
      ServiceTag.find_or_create_by(record_id: @record.id, tag_id: tg.id)
    end
  end
end
