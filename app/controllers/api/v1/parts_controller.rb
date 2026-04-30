class Api::V1::PartsController < Api::V1::BaseController
before_action -> { doorkeeper_authorize! :"part:write" }
  def index
    parts = Part.all
    render json: parts
  end

  def create
    part = Part.new(part_params)
    if part.save
      render json: {
        message: "Created Successfully",
        part: part
      }, status: :created
    else
      render json: {
        error: "Failed to create part"
      }, status: :unprocessable_entity
    end
  end

  def update
    part = Part.find_by(id: params[:id])
    unless part
      render json: {
        error: "Part Not found"
      }, status: :not_found
      return
    end
    if part.update(stock: params[:part][:stock])
      render json: {
        message: "Updated Successfully",
        part: part
      }, status: :ok
    else
      render json: {
        error: "Failed to update part."
      }, status: :unprocessable_entity
    end
  end
  private

  def part_params
    params.require(:part).permit(:name, :price, :stock)
  end
end
