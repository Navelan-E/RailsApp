require 'rails_helper'

RSpec.describe "Tags", type: :request do
  let!(:tag1) do
    Tag.create!(tag: "Oil Change")
  end

  let!(:tag2) do
    Tag.create!(tag: "Maintenance")
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

  describe "GET /api/v1/tags" do
    it "returns all tags with valid token" do
      get '/api/v1/tags', headers: {
        "Authorization" => "Bearer #{token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.map { |t| t["tag"] }).to include("Oil Change", "Maintenance")
    end

    it "returns all tags with any valid authorization" do
      customer = Customer.create!(
        name: "test",
        email: "customer@test.com",
        phone: "1234567890",
        password: "12345678"
      )
      post '/oauth/token', params: {
        "grant_type": "password",
        "username": "customer@test.com",
        "password": "12345678",
        "role": "customer"
      }
      c_token = JSON.parse(response.body)["access_token"]

      get '/api/v1/tags', headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end
end
