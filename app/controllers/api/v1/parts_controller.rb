class Api::V1::PartsController < ApplicationController
before_action :set_part, only: [:edit, :update]
  def index
    parts = Part.all
    render json: parts
  end

  def new
    part = Part.new
  end

  def create
    part = Part.new(part_params)
    if part.save
      render json: {
        message: "Created Successfully",
        part: part
      },status: :ok
    else
      render json: {
        error: "Failed to create part"
      },status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @part.update(stock: params[:part][:stock])
      render json: {
        message: "Updated Successfully",
        part: part
      },status: :ok
    else
      render json: {
        error:"Failed to update part."
      }, status: :unprocessable_entity
    end
  end
  private

  def part_params
    params.require(:part).permit(:name, :price, :stock)
  end

  def set_part
    part = Part.find(params[:id])
  end
end
