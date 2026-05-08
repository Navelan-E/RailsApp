require 'rails_helper'

RSpec.describe "Tags", type: :request do
  let!(:tag1) do
    Tag.create!(tag: "Oil Change")
  end

  let!(:tag2) do
    Tag.create!(tag: "Maintenance")
  end

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

  describe "GET /api/v1/tags" do
    before do
      get '/api/v1/tags', headers: {
          "Authorization" => "Bearer #{token}"
        }
    end
    context "when authenticated as a mechanic" do
      let(:token) { m_token }
      it "returns all tags" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
      end
    end
    context "when authenticated as a mechanic" do
      let(:token) { c_token }
      it "returns all tags" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
      end
    end
  end
end
