require 'rails_helper'

RSpec.describe "mechanics", type: :request do
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
  describe "GET /api/v1/mechanics" do
     before do
      get '/api/v1/mechanics', headers: {
        "Authorization" => "Bearer #{token}"
      },params: params
    end
    context "Authendicate as Customer" do
      let(:token){ c_token }
      let(:params){ {} }
      it "get status ok" do
        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicate as Customer" do
      let(:token){ c_token }
      let(:params){ {} }
      it "get status ok for mechanic" do
        get '/api/v1/mechanics', headers: {
          "Authorization" => "Bearer #{m_token}"
        }

        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicate as Mechanic" do
      let(:token){ m_token }
      let(:params){ { q: 'test'} }
      it "get status ok with input" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json[0]['name']).to eq('test')
      end
    end
    context "Authendicate as Customer" do
      let(:token){ c_token }
      let(:params){ {q: 'Invalid'} }
      it "get status ok for invalid input and zero output" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(0)
      end
    end
  end

  describe "GET /api/v1/mechanics/#id" do
    it "get status ok for mechanic" do
      get "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(mechanic.id)
      expect(json["name"]).to eq(mechanic.name)
      expect(json["email"]).to eq(mechanic.email)
      expect(json["experience"]).to eq(mechanic.experience)
    end
    it "get status forbidden for customer" do
      get "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:forbidden)
    end

    it "get status 404 for mechanic" do
      get "/api/v1/mechanics/#{120}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found.")
    end
  end

  describe "GET /api/v1/mechanics/#id" do
    before do
      get "/api/v1/mechanics/#{id}", headers: {
        "Authorization" => "Bearer #{token}"
      }
    end
    context "Authendiacte as mechanic" do
      let(:token) { m_token }
      let(:id) { mechanic.id }
      it "get status ok for mechanic", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(mechanic.id)
        expect(json["name"]).to eq(mechanic.name)
        expect(json["email"]).to eq(mechanic.email)
        expect(json["experience"]).to eq(mechanic.experience)
      end
    end
    context "Authendiacte as mechanic" do
      let(:token) { c_token }
      let(:id) { mechanic.id }
      it "get status forbidden for customer" do
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "Authendiacte as mechanic" do
      let(:token) { m_token }
      let(:id) { 120 }
      it "get status 404 for mechanic" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Mechanic not found.")
      end
    end
  end

  describe "Patch /api/v1/mechanics/#id" do
    before do
      patch "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{token}"
      }, params: {
        mechanic: {
          name: "Demo"
        }
      }
    end
    context "Authendicated as customer" do
      let(:token) { c_token }
      it "get status forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "Authendicated as mechanic" do
      let(:token) { m_token }
      it "get status ok", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Updated successfully")
      end
    end
  end

  describe "Post /api/v1/mechanics/" do
    before do
      post "/api/v1/mechanics/", headers: {
        "Authorization" => "Bearer #{token}"
      }, params: params
    end
    context "Authendicated as customer" do
      let(:token){ c_token }
      let(:params){
        {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "Demo@gmail.com"
        }
      }
      }
      it "get status forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "Authendicated as mechanic" do
      let(:token) { m_token }
      let(:params) {
        {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "Demo@gmail.com",
          password: "12345678"
        }
      }
      }
        it "get status ok" do
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq("Invited Successfully")
        end
      end

      context "Authendicated as mechanic" do
        let(:token) { m_token }
        let(:params) {
          {
          mechanic: {
            name: "Demo",
            experience: "2",
            email: "Demo@gmail.com"
          }
        }
        }
    end
    context "Authendicated as mechanic" do
        let(:token) { m_token }
        let(:params) {
          {
          mechanic: {
            name: "Demo",
            experience: "2",
            email: "invalid"
          }
        }
        }
      it "get status unprocessable_entity for mechanic if invalid params" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "Patch /api/v1/mechanics/#id/disable" do
    subject(:make_request) do
      patch "/api/v1/mechanics/#{id}/disable", headers: {
        "Authorization" => "Bearer #{token}"
      }
    end
    context "Authendicated for mechanic" do
      let(:token){ m_token }
      let(:id){ mechanic.id }
      it "patch status ok" do
        make_request
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Disabled successfully")
      end
    end
    context "Authendicated for customer" do
      let(:token){ c_token }
      let(:id){ mechanic.id }
      it "patch status forbidden for customer" do
        make_request
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "Authendicated for mechanic" do
      let(:token){ m_token }
      let(:id){ 120 }
      it "get status 404" do
        make_request
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Mechanic not found.")
      end
    end
  end
  describe "Patch /api/v1/mechanics/#id/disable" do
    before do
      allow(Mechanic).to receive(:find_by).and_return(mechanic)

      allow(mechanic).to receive(:update).and_return(false)
      allow(mechanic).to receive(:errors)
      patch "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        mechanic: {
          name: "Demo"
        }
      }
    end
    context "Authendicated for mechanic" do
      it "get status unprocessable_entity if invalid params" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "Patch /api/v1/mechanics/#id/unlock" do
    before do
      mechanic.lock_access!
      patch "/api/v1/mechanics/#{id}/unlock", headers: {
          "Authorization" => "Bearer #{m_token}"
        }
    end
    context "Authendicate as Mechanic" do
      let(:id) { mechanic.id }
      it "patch status ok" do
        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicate as Mechanic" do
      let(:id) { 120 }
      it "patch status not found if invalid id", :aggregate_failures do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Mechanic not found.")
      end
    end
  end

  describe "Delete /api/v1/mechanics/#id/" do
    before do
     delete "/api/v1/mechanics/#{id}", headers: {
          "Authorization" => "Bearer #{m_token}"
        }
    end
    context "Authendicate as Mechanic" do
      let(:id) { mechanic.id }
      it "delete status none for mechanic" do
        expect(Mechanic.find_by(id: id)).to eq(nil)
      end
    end
    context "Authendicate as Mechanic" do
      let(:id){ 120 }
      it "patch status not found if invalid id", :aggregate_failures do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Mechanic not found.")
      end
    end
  end
  describe "Delete /api/v1/mechanics/#id/" do
    before do
      allow(Mechanic).to receive(:find_by).and_return(mechanic)

        allow(mechanic).to receive(:destroy).and_return(false)
        allow(mechanic).to receive(:errors)
          .and_return(double(full_messages: ["Cannot delete mechanic"]))

        delete "/api/v1/mechanics/#{mechanic.id}", headers: {
          "Authorization" => "Bearer #{m_token}"
        }
    end
    context "Authendicate as Mechanic", :aggrrgate_failure do
      it "returns 422 when destroy fails" do
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Cannot delete mechanic")
      end
    end
  end
    describe "Post /api/v1/mechanics/" do
    before do
      get "/api/v1/mechanics/available", headers: {
        "Authorization" => "Bearer #{token}"
      }
    end
    context "Authendicated as customer" do
      let(:token){ c_token }
      it "get status forbidden" do
        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicated as mechanic" do
      let(:token) { m_token }
      it "get status ok" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
