class SummariesController < ApplicationController
  before_action :any_signed_in?
  def index
    @summary = Summary.all
  end

  def show
    @summary = Summary.find(params[:id])
  end
end
