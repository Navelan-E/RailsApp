require 'rails_helper'

RSpec.describe "Summaries", type: :request do
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

  let!(:record) do
    Record.create!(
      vehicle: vehicle,
      internal_notes: "Test Record",
      status: "pending"
    )
  end

  let!(:summary1) do
    Summary.create!(
      record: record,
      summary_text: "Summary 1"
    )
  end

  let!(:summary2) do
    Summary.create!(
      record: record,
      summary_text: "Summary 2"
    )
  end

  let(:token) do
    mechanic = Mechanic.create!(
      name: "test",
      email: "test@test.com",
      experience: "1",
      password: "12345678"
    )
    post '/oauth/token', params: {
      "grant_type": "password",
      "username": "test@test.com",
      "password": "12345678",
      "role": "mechanic"
    }
    JSON.parse(response.body)["access_token"]
  end

  describe "GET /api/v1/summaries" do
    it "returns all summaries with valid token" do
      get '/api/v1/summaries', headers: {
        "Authorization" => "Bearer #{token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[0]["summary_text"]).to eq("Summary 1")
      expect(json[1]["summary_text"]).to eq("Summary 2")
    end
  end

  describe "GET /api/v1/summaries/:id" do
    it "returns a specific summary" do
      get "/api/v1/summaries/#{summary1.id}", headers: {
        "Authorization" => "Bearer #{token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(summary1.id)
      expect(json["summary_text"]).to eq("Summary 1")
    end

    it "returns 404 for non-existent summary" do
      get "/api/v1/summaries/9999", headers: {
        "Authorization" => "Bearer #{token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Summary not found")
    end
  end
end
