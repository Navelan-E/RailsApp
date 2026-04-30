class Api::V1::ReviewsController < Api::V1::BaseController
  before_action -> { doorkeeper_authorize! :"review:read" }
  before_action -> { doorkeeper_authorize! :"review:write" }, only: [:create, :destroy]
  def index
    all_reviews = Review.all
    render json: all_reviews
  end

  def update
    unless review = Review.find_by(id: params[:id])
      render json: {
        error: "Review not found"
      }, status: :not_found
      return
    end
    if review.update(review_params)
      render json:{
        message: "Review updated successfully.",
        review: review
    },status: :ok
    else
      render json: {
        error: "Failed to update review."
      }, status: :unprocessable_entity
    end
  end

  def show
    unless review = Review.find_by(id: params[:id])
      render json: {
        error: "Review no found"
      }, status: :not_found
      return
    end
    render json: review
  end

  def create
    record = Record.find(params[:record_id])
    reviewable = case params.dig(:review, :review_type)
      when "Mechanic"
        record.mechanic
      when "Vehicle"
        record.vehicle
      else
        record
    end
    review = Review.new(reviewable: reviewable, **review_params, customer_id: doorkeeper_token&.resource_owner_id)
    if review.save
      render json:{ message: "Review added successfully.",
        review: review
      }, status: :created
    else
      render json: {
        error: "Failed to add review."
      }, status: :unprocessable_entity
    end
  end
  
  def destroy
    puts "Destroying review with ID: #{params[:id]}"
    unless review = Review.find_by(id: params[:id])
      render json: {
        error: "Review not found"
      }, status: :not_found
      return
    end
    review.destroy
    head :no_content
  end

  private

  def review_params
    params.require(:review).permit(:content)
  end
end
