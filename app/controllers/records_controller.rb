class RecordsController < ApplicationController
  def index
    @records = Record.all
  end

  def show
  end

  def new
    @record = Record.new
  end

  def create
    puts params.inspect
    @Customer = Customer.select_or_create(params[:customer_name], params[:customer_phone], params[:customer_email])
    @Vehicle = Vehicle.select_or_create(params[:vehicle_no], params[:model],@Customer.id)
    @record = Record.new(internal_notes: params[:internal_notes], vehicle_id: @Vehicle.id, status: params[:status])
    if @record.save
     redirect_to @record
    else
     render :new
    end
  end
  
  def edit
  end
end
