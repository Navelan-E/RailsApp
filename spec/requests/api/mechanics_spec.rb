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
    it "get status ok for customer" do
      get '/api/v1/mechanics', headers: {
        "Authorization" => "Bearer #{c_token}"
      }

      expect(response).to have_http_status(:ok)
    end
    it "get status ok for mechanic" do
      get '/api/v1/mechanics', headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
    end
    it "get status ok for mechanic with input" do
      get '/api/v1/mechanics',params:{ q: 'test'}, headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json[0]['name']).to eq('test')
    end

    it "get status ok for mechanic with invalid input and zero output" do
      get '/api/v1/mechanics',params:{ q: 'Invalid'}, headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
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
      get "/api/v1/mechanics/#{1200}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found.")
    end
  end

  describe "Patch /api/v1/mechanics/#id" do
    it "get status forbideen for customer" do
      patch "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        customer: {
          name: "Demo"
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
    it "get status ok for mechanic" do
      patch "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        mechanic: {
          name: "Demo"
        }
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Updated successfully")
    end
  end

  describe "Post /api/v1/mechanics/" do
    it "get status forbideen for customer" do
      post "/api/v1/mechanics/", headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "Demo@gmail.com"
        }
      }
      expect(response).to have_http_status(:forbidden)
    end

    it "get status ok for mechanic" do
      post "/api/v1/mechanics/", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "Demo@gmail.com",
          password: "123456"
        }
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Created Successfully")
    end
    it "get status ok for mechanic if no password" do
      post "/api/v1/mechanics", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "Demo@gmail.com"
        }
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Created Successfully")
    end

    it "get status unprocessable_entity for mechanic if invalid params" do
      post "/api/v1/mechanics", headers: {
        "Authorization" => "Bearer #{m_token}"
      }, params: {
        mechanic: {
          name: "Demo",
          experience: "2",
          email: "invalid"
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Patch /api/v1/mechanics/#id/disable" do
    it "patch status ok for mechanic" do
      patch "/api/v1/mechanics/#{mechanic.id}/disable", headers: {
        "Authorization" => "Bearer #{m_token}"
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Disabled successfully")
    end
    it "patch status forbidden for customer" do
      patch "/api/v1/mechanics/#{mechanic.id}/disable", headers: {
        "Authorization" => "Bearer #{c_token}"
      }
      expect(response).to have_http_status(:forbidden)
    end
    it "patch status not found if invalid id" do
      patch "/api/v1/mechanics/#{120}/disable", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found.")
    end

    it "get status unprocessable_entity for mechanic if invalid params" do
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
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "get status 404 for mechanic" do
      patch "/api/v1/mechanics/#{1200}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found")
    end
  end

  describe "Patch /api/v1/mechanics/#id/unlock" do
    it "patch status ok for mechanic" do
      mechanic.lock_access!
      patch "/api/v1/mechanics/#{mechanic.id}/unlock", headers: {
        "Authorization" => "Bearer #{m_token}"
      }
      expect(response).to have_http_status(:ok)
    end
    it "patch status not found if invalid id" do
      patch "/api/v1/mechanics/#{120}/unlock", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found.")
    end
  end

  describe "Delete /api/v1/mechanics/#id/" do
    it "delete status none for mechanic" do
      mechanic.lock_access!
      id = mechanic.id
      delete "/api/v1/mechanics/#{id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }
      expect(Mechanic.find_by(id: id)).to eq(nil)
    end

    it "returns 422 when destroy fails" do
      allow(Mechanic).to receive(:find_by).and_return(mechanic)

      allow(mechanic).to receive(:destroy).and_return(false)
      allow(mechanic).to receive(:errors)
        .and_return(double(full_messages: ["Cannot delete mechanic"]))

      delete "/api/v1/mechanics/#{mechanic.id}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Cannot delete mechanic")
    end

    it "patch status not found if invalid id" do
      delete "/api/v1/mechanics/#{120}", headers: {
        "Authorization" => "Bearer #{m_token}"
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Mechanic not found.")
    end
  end
end
