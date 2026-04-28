class Api::V1::SummariesController < ApplicationController
def index
    summary = Summary.all
    render json: summary
  end

  def show
    summary = Summary.find(params[:id])
    render json: summary
  end
end
