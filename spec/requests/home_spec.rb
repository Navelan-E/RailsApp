require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "get status ok without authentication" do
      get '/'

      expect(response).to have_http_status(:ok)
    end
  end
end
