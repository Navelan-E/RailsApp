require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Profile", type: :request do
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

  describe "GET /profile/show" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/profile/show'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/profile/show'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/profile/show'
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /profile/edit" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/profile/edit'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/profile/edit'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/profile/edit'
      expect(response).to redirect_to(root_path)
    end
  end
end
