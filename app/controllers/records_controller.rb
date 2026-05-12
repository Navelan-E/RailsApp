class RecordsController < ApplicationController
  before_action :any_signed_in?
  before_action :authenticate_pros?, except: [:index, :show]
  before_action :set_record, only: [:edit, :update, :show]
  before_action :set_parts, only: [:update]
  def index
    if params[:q].present?  && params[:q]!= ''
      @records = Record.joins(:vehicle).where("vehicles.number_plate ILIKE ?", "%#{params[:q]}%")
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
    service = RecordService.new(record: nil, params: params)
    result = service.create_vehicle_customer_and_tags
    rp = record_params
    @record = Record.new(
      internal_notes: rp[:internal_notes],
      vehicle_id: result[:vehicle].id,
      status: "pending",
    )

    if @record.save
      RecordService.new(record: @record, params: params).create_service_tags
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
    RecordService.new(record: @record, params: params).set_parts
    @parts = Part.all
    param = params[:record].permit(:internal_notes, :status, :mechanic_id, :total_cost)
    puts "Update Params: #{param}"
    @record.customer_notes = params.dig(:record, :customer_notes)
    if @record.update(param)
      puts "Record updated: #{@record.inspect}"
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

  def set_parts
    part_id = params.dig(:record, :part_id)
    quantity = params.dig(:record, :part_quantity)
    puts("Exitting")
    return if part_id.blank? || quantity.to_i <= 0
    puts("Cheated not exits")
    @service_part = ServicePart.find_or_initialize_by(record_id: @record.id, part_id: params[:record][:part_id])
    @service_part.quantity = params[:record][:part_quantity]
    if @service_part.save
      @part = Part.find(params[:record][:part_id])
    else
      flash.now[:alert] = "Failed to update part stock."
    end
  end
end
