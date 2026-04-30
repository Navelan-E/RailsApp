class Api::V1::RecordsController < Api::V1::BaseController
  before_action -> { doorkeeper_authorize! :"record:read" }
  before_action -> { doorkeeper_authorize! :"record:write" }, except: [:index, :show]
  before_action :set_record, only: [:edit, :update, :show]
  before_action :create_vehicle_customer_and_tags, only: [:create]
  before_action :set_parts, only: [:update]
  after_action :create_service_tags, only: [:create]
  def index
    if params[:q].present?
      vehicles = Vehicle.where("number_plate ILIKE ?", "%#{params[:q]}%")

      if vehicles.exists?
        record = Record.where(vehicle_id: vehicles.select(:id))
      else
        record = Record.none
      end
    else
      record = Record.all
    end
    render json: record
  end

  def show
    record = Record.find_by(id: params[:id])
    if record
      render json: record
    else
      render json:{
        error: "Record Not found"
      }, status: :not_found
    end
  end

  def new
    record = Record.new
  end

  def create
    rp = record_params
    @record = Record.new(
      internal_notes: rp[:internal_notes],
      vehicle_id: @vehicle.id,
      status: "pending",
    )

    if @record.save
      render json: {
        message: "Succesfully created",
        record: @record
      }, status: :created
    else
      render json:{
        error: @record.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  def edit
    @mechanics = Mechanic.all
    @parts = Part.all
  end

  def update
    record = Record.find_by(id: params[:id])
    unless record
      render json:{
        error: "Record Not found"
      }, status: :not_found
      return
    end
    @parts = Part.all
    param = params[:record].permit(:internal_notes, :status, :mechanic_id, :total_cost)
    puts "Update Params: #{param}"
    record.customer_notes = params.dig(:record, :customer_notes)
    if record.update(param)
      puts "Record updated: #{record.inspect}"
      render json: {
        message: "Record updated successfully",
        record: record
    },status: :ok
    else
      @mechanics = Mechanic.all
      render json:{
        error: record.errors.full_messages
      }, status: :unprocessable_entity
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
    @mechanics = Mechanic.all
  end

  def create_vehicle_customer_and_tags
    rp = record_params
    puts "Record Params: #{rp}"

    @customer = Customer.find_by(phone: rp[:customer_phone])
    unless @customer
      temp_password = "123456"
      @customer = Customer.new(
        name: rp[:customer_name],
        email: rp[:customer_email],
        phone: rp[:customer_phone],
        password: temp_password,
        password_confirmation: temp_password
      )
      unless @customer.save
        render json: {
          error: @customer.errors.full_messages.join(', ')
        },status: :unprocessable_entity
      end
    end

    @vehicle = Vehicle.find_by(number_plate: rp[:vehicle_no])
    unless @vehicle
      @vehicle = Vehicle.new(
        number_plate: rp[:vehicle_no],
        model: rp[:model],
        customer_id: @customer.id
      )
      unless @vehicle.save
        render json: {
          error: @vehicle.errors.full_messages.join(', ')
        },status: :unprocessable_entity
      end
    end
  end

  def set_parts
    part_id = params.dig(:record, :part_id)
    quantity = params.dig(:record, :part_quantity)
    puts("Exitting")
    return if part_id.blank? || quantity.to_i <= 0
    @service_part = ServicePart.find_or_initialize_by(record_id: record.id, part_id: params[:record][:part_id])
    @service_part.quantity = params[:record][:part_quantity]
    if @service_part.save
      @part = Part.find(params[:record][:part_id])
    else
      render json: {
          error: "Failed to update path"
        },status: :unprocessable_entity
    end
  end

  def create_service_tags
    rp = record_params
    valid_tag_ids = rp[:tag_ids].reject(&:blank?)
    @tags = valid_tag_ids.present? ? Tag.where(id: valid_tag_ids).to_a : []
    puts("Selected Tag IDs: #{@tags}")
    if rp[:custom_tags].present?
      custom_tags = rp[:custom_tags].split(",").map(&:strip).reject(&:empty?)
      puts( "Custom Tags: #{custom_tags}" )
      custom_tags.each do |tag_name|
        tag = Tag.find_or_create_by!(tag: tag_name)
        @tags << tag unless @tags.include?(tag)
      end
    end
    @record.tags = @tags
  end
end
