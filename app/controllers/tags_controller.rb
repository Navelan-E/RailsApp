class TagsController < ApplicationController
  before_action :any_signed_in?
  def index
    @tags = Tag.all
  end
end
