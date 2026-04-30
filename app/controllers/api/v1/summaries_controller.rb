class Api::V1::SummariesController < Api::V1::BaseController
before_action :doorkeeper_authorize!
def index
  unless summary = Summary.all
    render json: {
        error: "Summary not found"
      }, status: :not_found
      return
  end
  render json: summary
end

  def show
    unless summary = Summary.find_by(id: params[:id])
      render json: {
        error: "Summary not found"
      }, status: :not_found
      return
    end
    render json: summary
  end
end
