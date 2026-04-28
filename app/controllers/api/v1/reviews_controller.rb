class Api::V1::ReviewsController < ApplicationController
  def index
    all_reviews = Review.all
    render json: all_reviews
  end

  def edit
    review = Review.find(params[:id])
  end

  def update
    review = Review.find(params[:id])
    if review.update(review_params)
      render json:{
        message: "Review updated successfully.",
        review: review
    },status: :ok
    else
      flash.now[:alert] = "Failed to update review."
      render json: {
        error: "Failed to update review."
      }, status: unprocessable_entity
    end
  end

  def show
    review = Review.find(params[:id])
    render json: review
  end

  def new
    puts("hlo.. #{params[:record_id]}")
    @record = Record.find_by(id: params[:record_id])
    puts(@record.inspect)
    @review = @record.reviews.build
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
    review = Review.new(reviewable: reviewable, **review_params, customer_id: current_customer.id)
    if review.save
      render json:{ message: "Review added successfully.",
        review: review
      }, status: :ok
    else
      render json: {
        error: "Failed to add review."
      }, status: :unprocessable_entity
    end
  end
  
  def destroy
    puts "Destroying review with ID: #{params[:id]}"
    review = Review.find(params[:id])
    review.destroy
    render json:{
      message: "Deleted Successfully"
    },status: :ok
  end

  private

  def review_params
    params.require(:review).permit(:content)
  end
end
