require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Summaries", type: :request do
  let!(:mechanic) do
    Mechanic.create!(
      name: "test",
      email: "test@test.com",
      experience: "1",
      password: "12345678"
    )
  end

  let!(:customer) do
    Customer.create!(
      name: "test",
      email: "customer@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  describe "GET /summaries" do
    it "redirects for customer" do
      sign_in customer
      get '/summaries'
      expect(response).to have_http_status(:ok)
    end

    it "get status ok for mechanic" do
      sign_in mechanic
      get '/summaries'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/summaries'
      expect(response).to be_redirect
    end
  end
end
