require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Mechanics", type: :request do

  let!(:mechanic) { create(:mechanic) }
  let!(:customer) { create(:customer) }
  let!(:admin)  { create(:admin_user) }


  describe "GET /mechanics" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/mechanics'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for mechanic with param" do
      sign_in mechanic
      get '/mechanics', params: {
        q: 'test'
      }

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/mechanics'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/mechanics'
      expect(response).to be_redirect
    end
  end

  describe "GET /mechanics/:id" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/mechanics/#{mechanic.id}"

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get "/mechanics/#{mechanic.id}"

      expect(response).to be_redirect
    end

  end

  describe "PATCH /mechanics/:id" do
    it " Update for mechanic" do
      sign_in mechanic
      patch "/mechanics/#{mechanic.id}", params: {
        mechanic: {
          name: "demo"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Mechanic updated successfully")
    end

    it "Update with invalid param" do
      sign_in mechanic
      patch "/mechanics/#{mechanic.id}", params: {
        mechanic: {
          experience: "two"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Experience is not a number")
    end

  end

  describe "GET /mechanics/:id" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/mechanics/#{mechanic.id}"

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get "/mechanics/#{mechanic.id}"

      expect(response).to be_redirect
    end

  end

  describe "Delete /mechanics/:id" do
    it "Delete for mechanic" do
      sign_in admin
      mechanic_to_destroy = Mechanic.create!(
        name: "delete",
        email: "delete@test.com",
        experience: "1",
        password: "12345678"
      )
      delete "/mechanics/#{mechanic_to_destroy.id}"
      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Mechanic was successfully deleted.")
    end

    it "Delete for customer" do
      sign_in customer
      mechanic_to_destroy = Mechanic.create!(
        name: "delete",
        email: "delete@test.com",
        experience: "1",
        password: "12345678"
      )
      patch "/mechanics/#{mechanic_to_destroy.id}"

      expect(response).to be_redirect
    end

  end
end
