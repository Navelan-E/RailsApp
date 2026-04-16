class SummariesController < ApplicationController
  def index
    @summary = Summary.all
  end

  def show
    @summary = Summary.find(params[:id])
  end
end
