require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Vehicles", type: :request do
  let!(:customer) do
    Customer.create!(
      name: "test",
      email: "test@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let!(:mechanic) do
    Mechanic.create!(
      name: "Mechanic Test",
      email: "mechanic@test.com",
      experience: "5",
      password: "12345678"
    )
  end

  let!(:vehicle) do
    Vehicle.create!(
      model: "Honda Civic",
      number_plate: "ABC123",
      customer_id: customer.id
    )
  end

  describe "GET /vehicles" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/vehicles'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/vehicles'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/vehicles'
      expect(response).to be_redirect
    end
  end

  describe "GET /vehicles/:id" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/vehicles/#{vehicle.id}", params: { format: vehicle.id }

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get "/vehicles/#{vehicle.id}", params: { format: vehicle.id }

      expect(response).to have_http_status(:ok)
    end
  end



  describe "GET /vehicles/new" do
    it "redirects for mechanic" do
      sign_in mechanic
      get '/vehicles/new'
      expect(response).to be_redirect
    end

    it "get status ok for customer" do
      sign_in customer
      get '/vehicles/new'

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /vehicles" do
    it "redirects for mechanic" do
      sign_in mechanic
      post '/vehicles', params: {
        vehicle: {
          model: "Toyota Corolla",
          number_plate: "XYZ789"
        }
      }
      expect(response).to be_redirect
    end

    it "creates vehicle for customer" do
      sign_in customer
      post '/vehicles', params: {
        vehicle: {
          model: "Toyota Corolla",
          number_plate: "XYZ789"
        }
      }
      expect(response).to redirect_to(profile_show_path)
    end


    it "handles duplicate number plate" do
      sign_in customer
      post '/vehicles', params: {
        vehicle: {
          model: "Toyota Corolla",
          number_plate: "ABC123"
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /vehicles/:id" do
    it "redirects for mechanic" do
      sign_in mechanic
      delete "/vehicles/#{vehicle.id}"
      expect(response).to be_redirect
    end

    it "deletes vehicle for customer" do
      sign_in customer
      delete "/vehicles/#{vehicle.id}"
      expect(response).to redirect_to(profile_show_path)
    end

  end
end
