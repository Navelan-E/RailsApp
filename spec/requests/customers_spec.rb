require 'rails_helper'

RSpec.describe "Customers", type: :request do
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
      email: "test@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let(:m_token) do
    post '/oauth/token', params: {
    "grant_type": "password",
    "username": "test@test.com",
    "password": "12345678",
    "role": "mechanic"
  }
    JSON.parse(response.body)["access_token"]
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
  describe "GET /api/v1/customers" do
    it "get status ok for mechanic" do
      get '/api/v1/customers', headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
    end
    it "get status ok for customer" do
      get '/api/v1/customers', headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/customers/#id" do
    it "get status ok for mechanic" do
      get "/api/v1/customers/#{customer.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(customer.id)
      expect(json["name"]).to eq(customer.name)
      expect(json["email"]).to eq(customer.email)
      expect(json["phone"]).to eq(customer.phone)
    end
    it "get status ok for customer" do
      get "/api/v1/customers/#{customer.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(customer.id)
      expect(json["name"]).to eq(customer.name)
      expect(json["email"]).to eq(customer.email)
      expect(json["phone"]).to eq(customer.phone)
    end
  end
end