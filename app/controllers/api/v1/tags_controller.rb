class Api::V1::TagsController < Api::V1::BaseController
before_action :doorkeeper_authorize!
  def index
    tags = Tag.all
    render json: tags
  end
end
