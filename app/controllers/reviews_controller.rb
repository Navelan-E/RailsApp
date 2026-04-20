class ReviewsController < ApplicationController
  before_action :any_signed_in?
  before_action :authenticate_customer!, only: [:new, :create, :destroy]
  def index
    @all_reviews = Review.all
  end

  def new
    puts("hlo.. #{params[:record_id]}")
    @record = Record.find_by(id: params[:record_id])
    puts(@record.inspect)
    @review = @record.reviews.build
  end

  def create
    @record = Record.find(params[:record_id])
    @review = Review.new(reviewable: @record, **review_params)
    if @review.save
      redirect_to summaries_path, notice: "Review added successfully."
    else
      flash.now[:alert] = "Failed to add review."
      render :new
    end
  end
  
  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to reviews_path, notice: "Review deleted successfully."
  end

  private

  def review_params
    params.require(:review).permit(:content)
  end
end
