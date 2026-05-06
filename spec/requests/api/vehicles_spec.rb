require 'rails_helper'

RSpec.describe "Vehicles", type: :request do
  let!(:customer) do
    Customer.create!(
      name: "test",
      email: "test@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let!(:vehicle) do
    Vehicle.create!(
      customer: customer,
      number_plate: "ABC123",
      model: "Test Model"
    )
  end

  let(:c_token) do
    post '/oauth/token', params: {
      "grant_type": "password",
      "username": "test@test.com",
      "password": "12345678",
      "role": "customer"
    }
    JSON.parse(response.body)["access_token"]
  end

  let(:m_token) do
    mechanic = Mechanic.create!(
      name: "test",
      email: "mechanic@test.com",
      experience: "1",
      password: "12345678"
    )
    post '/oauth/token', params: {
      "grant_type": "password",
      "username": "mechanic@test.com",
      "password": "12345678",
      "role": "mechanic"
    }
    JSON.parse(response.body)["access_token"]
  end

  describe "GET /api/v1/vehicles" do
    it "returns all vehicles for customer" do
      get '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
      expect(json[0]["number_plate"]).to eq("ABC123")
      expect(json[0]["model"]).to eq("Test Model")
    end

    it "returns vehicles for customer with param" do
      get '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: { search: 'A'}

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
      expect(json[0]["number_plate"]).to eq("ABC123")
      expect(json[0]["model"]).to eq("Test Model")
    end

    it "returns all vehicles for mechanic" do
      get '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
    end
  end

  describe "GET /api/v1/vehicles/:id" do
    it "returns a specific vehicle with records" do
      Record.create!(
        vehicle: vehicle,
        internal_notes: "Test Record",
        status: "completed"
      )
      get "/api/v1/vehicles/#{vehicle.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["vehicle"]["id"]).to eq(vehicle.id)
      expect(json["vehicle"]["number_plate"]).to eq("ABC123")
      expect(json["record"]).to be_an(Array)
    end

    it "returns 404 for non-existent vehicle" do
      get "/api/v1/vehicles/9999", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Vehicle not found")
    end
  end

  describe "POST /api/v1/vehicles" do
    it "creates a new vehicle successfully" do
      post '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        vehicle: {
          model: "New Model",
          number_plate: "XYZ789"
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Vehicle added successfully.")
      expect(json["vehicle"]["model"]).to eq("New Model")
      expect(json["vehicle"]["number_plate"]).to eq("XYZ789")
    end

    it "fails to create duplicate vehicle with same number plate" do
      post '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        vehicle: {
          model: "Another Model",
          number_plate: "ABC123"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Vehicle already exists")
    end

    it "fails to create vehicle with invalid params" do
      post '/api/v1/vehicles', headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        vehicle: {
          model: "",
          number_plate: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Failed to add vehicle.")
    end
  end

  describe "DELETE /api/v1/vehicles/:id" do
    it "deletes a vehicle successfully" do
      vehicle_to_delete = Vehicle.create!(
        customer: customer,
        number_plate: "DEL123",
        model: "To Delete"
      )

      delete "/api/v1/vehicles/#{vehicle_to_delete.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:no_content)
    end

    it "422 if delete fails" do
      allow(Vehicle).to receive(:find_by).and_return(vehicle)

      allow(vehicle).to receive(:destroy).and_return(false)
      allow(vehicle).to receive(:errors)
        .and_return(double(full_messages: ["Cannot delete vehicle"]))
      vehicle_to_delete = Vehicle.create!(
        customer: customer,
        number_plate: "DEL123",
        model: "To Delete"
      )

      delete "/api/v1/vehicles/#{vehicle_to_delete.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for non-existent vehicle" do
      delete "/api/v1/vehicles/9999", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Vehicle not found")
    end
  end
end
