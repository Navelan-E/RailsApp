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

    it "get status 404 for mechanic" do
      get "/api/v1/customers/#{120}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end
    it "get status ok for customer" do
      get "/api/v1/customers/#{120}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
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

    it "get status 404 for mechanic" do
      get "/api/v1/customers/#{120}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end
    it "get status ok for customer" do
      get "/api/v1/customers/#{120}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end
  end

  describe "Patch /api/v1/customers/#id" do
    it "get status forbideen for mechanic" do
      patch "/api/v1/customers/#{customer.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        customer: {
          name: "Demo"
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
    it "get status unprocessable_entity for mechanic" do
      patch "/api/v1/customers/#{customer.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        customer: {
          name: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "get status ok for customer" do
      patch "/api/v1/customers/#{customer.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        customer: {
          name: "Demo"
        }
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Updated successfully")
    end
    it "patch status ok for customer if no param" do
      patch "/api/v1/customers/#{120}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found.")
    end
  end

  describe "Patch /api/v1/customers/#id/disable" do
    it "patch status forbidden for mechanic" do
      patch "/api/v1/customers/#{customer.id}/disable", headers: {
        "Authorization" => "Bearer #{m_token}"
      }
      expect(response).to have_http_status(:forbidden)
    end
    it "patch status ok for customer" do
      patch "/api/v1/customers/#{customer.id}/disable", headers: {
        "Authorization" => "Bearer #{c_token}"
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Disabled successfully")
    end
    it "patch status not found if invalid id" do
      patch "/api/v1/customers/#{120}/disable", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found.")
    end
  end

  describe "Patch /api/v1/customers/#id/unlock" do
    it "patch status ok for customer" do
      customer.lock_access!
      patch "/api/v1/customers/#{customer.id}/unlock", headers: {
        "Authorization" => "Bearer #{c_token}"
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Unlocked successfully")
    end
    it "patch status not found if invalid id" do
      patch "/api/v1/customers/#{120}/unlock", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found.")
    end
  end
end