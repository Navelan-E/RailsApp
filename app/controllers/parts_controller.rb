class PartsController < ApplicationController

  before_action :set_part, only: [:edit, :update]
  def index
    @parts = Part.all
  end

  def new
    @part = Part.new
  end

  def create
    @part = Part.new(part_params)
    if @part.save
      if params[:return_to].present?
        redirect_to params[:return_to], notice: "Part added successfully"
      else
        redirect_to parts_path, notice: "Part added successfully."
      end
    else
      flash.now[:alert] = "Failed to add part."
      render :new
    end
  end

  def edit
  end

  def update
    if @part.update(stock: params[:part][:stock])
      redirect_to parts_path, notice: "Part updated successfully."
    else
      flash.now[:alert] = "Failed to update part."
      render :edit
    end
  end
  private

  def part_params
    params.require(:part).permit(:name, :price, :stock)
  end

  def set_part
    @part = Part.find(params[:id])
  end
end
