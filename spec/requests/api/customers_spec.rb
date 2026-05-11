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
    before do
      get '/api/v1/customers', headers: {
          "Authorization" => "Bearer #{token}"
        }
    end
    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      it "get status ok" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      it "get status ok" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/customers/#id" do
    before do
      get "/api/v1/customers/#{id}", headers: {
          "Authorization" => "Bearer #{token}"
        }
    end

    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      let(:id) { customer.id }
      it "get status ok for mechanic", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          "id" => customer.id,
          "name" => customer.name,
          "email" => customer.email,
          "phone" => customer.phone
        )
      end
    end
    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:id) { customer.id }
      it "get status ok for customer", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          "id" => customer.id,
          "name" => customer.name,
          "email" => customer.email,
          "phone" => customer.phone
        )
      end
    end

    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      let(:id) { 120 }
      it "get status 404" do
        get "/api/v1/customers/#{120}", headers: {
          "Authorization" => "Bearer #{m_token}"
        }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found")
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:id) { 120 }
      it "get status 404" do
        get "/api/v1/customers/#{120}", headers: {
          "Authorization" => "Bearer #{c_token}"
        }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found")
      end
    end
  end

  describe "GET /api/v1/customers/#id" do
    before do
      get "/api/v1/customers/#{id}", headers: {
          "Authorization" => "Bearer #{token}"
        }
    end
    context "Authendicate as mechanic" do
      let(:token) { m_token }
      let(:id) { customer.id }
      it "get status ok", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          "id" => customer.id,
          "name" => customer.name,
          "email" => customer.email,
          "phone" => customer.phone
        )
      end
    end

    context "Authendicate as customer" do
      let(:token) { c_token }
      let(:id) { customer.id }
      it "get status ok", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          "id" => customer.id,
          "name" => customer.name,
          "email" => customer.email,
          "phone" => customer.phone
        )
      end
    end

    context "Authendicate as mechanic", :aggregate_failures do
      let(:token) { m_token }
      let(:id) { 120 }
      it "get status 404" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found")
      end
    end

    context "Authendicate as customer" do
      let(:token) { c_token }
      let(:id) { 120 }
      it "get status 404", :aggregate_failures do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found")
      end
    end
  end

  describe "Patch /api/v1/customers/#id" do
    before do
      patch "/api/v1/customers/#{id}", headers: {
        "Authorization" => "Bearer #{token}"
      }, params: params
    end

    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      let(:params) {{
          customer: {
            name: "Demo"
          }
        }}
      let(:id) { customer.id }
      it "get status forbideen" do
        patch "/api/v1/customers/#{customer.id}", headers: {
          "Authorization" => "Bearer #{m_token}"
        }, params: {
          customer: {
            name: "Demo"
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:params) {{
          customer: {
            name: ""
          }
        }}
      let(:id) { customer.id }
      it "get status unprocessable_entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:params) {{
          customer: {
            name: "Demo"
          }
        }}
      let(:id) { customer.id }
      it "get status ok", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Updated successfully")
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:params) {{
          customer: {
            name: "Demo"
          }
        }}
      let(:id) { 120 }
      it "patch status ok for customer if no param", :aggregate_failures do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found.")
      end
    end
  end

  describe "Patch /api/v1/customers/#id/disable" do
    before do
      patch "/api/v1/customers/#{id}/disable", headers: {
          "Authorization" => "Bearer #{token}"
        }
    end
    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      let(:id) { customer.id }
      it "patch status forbidden for mechanic" do
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:id) { customer.id }
      it "patch status ok" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Disabled successfully")
      end
    end

    context "when authenticated as a customer" do
      let(:token) { c_token }
      let(:id) { 120}
      it "patch status not found if invalid id" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found.")
      end
    end
  end

  describe "Patch /api/v1/customers/#id/unlock" do
    before do
      customer.lock_access!
        patch "/api/v1/customers/#{id}/unlock", headers: {
          "Authorization" => "Bearer #{c_token}"
        }
    end
    context "Authendicate as a customer" do
      let(:id) {customer.id}
      it "patch status ok for customer" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Unlocked successfully")
      end
    end
    context "Authendicate as a customer" do
      let(:id) { 120 }
      it "patch status not found if invalid id" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Customer not found.")
      end
    end
  end
end
