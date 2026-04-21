class ReviewsController < ApplicationController
  before_action :any_signed_in?
  before_action :authenticate_customer!, only: [:new, :create, :destroy]
  def index
    @all_reviews = Review.all
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to reviews_path, notice: "Review updated successfully."
    else
      flash.now[:alert] = "Failed to update review."
      render :edit
    end
  end

  def show
    @review = Review.find(params[:id])
  end

  def new
    puts("hlo.. #{params[:record_id]}")
    @record = Record.find_by(id: params[:record_id])
    puts(@record.inspect)
    @review = @record.reviews.build
  end

  def create
    @record = Record.find(params[:record_id])
    reviewable = case params.dig(:review, :review_type)
      when "Mechanic"
        @record.mechanic
      when "Vehicle"
        @record.vehicle
      else
        @record
    end
    @review = Review.new(reviewable: reviewable, **review_params, customer_id: current_customer.id)
    if @review.save
      redirect_to summaries_path, notice: "Review added successfully."
    else
      flash.now[:alert] = "Failed to add review."
      render :new
    end
  end
  
  def destroy
    puts "Destroying review with ID: #{params[:id]}"
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to reviews_path, notice: "Review deleted successfully."
  end

  private

  def review_params
    params.require(:review).permit(:content)
  end
end
