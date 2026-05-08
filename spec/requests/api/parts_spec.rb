require 'rails_helper'

RSpec.describe "Parts", type: :request do
  let!(:part) do
    Part.create!(
      name: "Oil Filter",
      price: 10.0,
      stock: 50
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

  describe "GET /api/v1/parts" do
    before do
      get '/api/v1/parts', headers: {
        "Authorization" => "Bearer #{token}"
      }
    end
    it "returns all parts with valid token", :aggregate_failures do
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
      expect(json[0]["name"]).to eq("Oil Filter")
      expect(json[0]["price"].to_f).to eq(10.0)
      expect(json[0]["stock"]).to eq(50)
    end
  end

  describe "POST /api/v1/parts" do
    before do
      post '/api/v1/parts', headers: {
        "Authorization" => "Bearer #{token}"
      }, params: params
    end
    context "Authendicate as Mechanic" do
      let(:params) {{
        part: {
        name: "Air Filter",
        price: 15.0,
        stock: 30
        }
      }}
      it "creates a new part successfully", :aggregate_failures do
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Created Successfully")
        expect(json["part"]["name"]).to eq("Air Filter")
        expect(json["part"]["price"].to_f).to eq(15.0)
        expect(json["part"]["stock"]).to eq(30)
      end
    end
    context "Authendicate as Mechanic" do
      let(:params) {{
        part: {
        name: "",
        price: "invalid",
        stock: -5
        }
      }}
      it "fails to create part with invalid params", :aggregate_failures do
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Failed to create part")
      end
    end
  end

  describe "PATCH /api/v1/parts/:id" do
    before do
      patch "/api/v1/parts/#{id}", headers: {
        "Authorization" => "Bearer #{token}"
      }, params: params
    end
    context "Authendicate as mechanic" do
      let(:id) { part.id }
      let(:params) {{
        part: {
          stock: 100
        }
      }}
      it "updates part stock successfully" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Updated Successfully")
        expect(json["part"]["stock"]).to eq(100)
      end
    end
    context "Authendicate as mechanic" do
      let(:id) { 120 }
      let(:params) {{
        part: {
          stock: 100
        }
      }}
      it "returns 404 for non-existent part" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Part Not found")
      end
    end
    context "Authendicate as mechanic" do
      let(:id) { part.id }
      let(:params) {{
        part: {
          stock: "one"
        }
      }}
      it "fails to update part with invalid stock" do
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Failed to update part.")
      end
    end
  end
end