require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Mechanics", type: :request do

  let!(:mechanic) { create(:mechanic) }
  let!(:customer) { create(:customer) }
  let!(:admin)  { create(:admin_user) }


  describe "GET /mechanics for mechanic" do
    before do
      sign_in mechanic
      allow(::InternalApi::OauthTokenService).to receive(:token).and_return("test_token")
      allow(::InternalApi::MechanicsService).to receive(:index).and_return([
        { "id" => mechanic.id, "name" => mechanic.name, "email" => mechanic.email }
      ])
      sign_in mechanic

    end
    it "get status ok" do
      get '/mechanics'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok with param" do      
      get '/mechanics', params: {
        q: 'test'
      }

      expect(response).to have_http_status(:ok)
    end
  end
  describe "GET /mechanics for customer" do
    before do
      sign_in customer
      allow(::InternalApi::OauthTokenService).to receive(:token).and_return("test_token")
      allow(::InternalApi::MechanicsService).to receive(:index).and_return([
        { "id" => mechanic.id, "name" => mechanic.name, "email" => mechanic.email }
      ])
      get '/mechanics'
    end
    it "get status ok" do
      expect(response).to have_http_status(:ok)
    end
  end
  describe "GET /mechanics for unautherticated" do
    before do
      allow(::InternalApi::OauthTokenService).to receive(:token).and_return("test_token")
      allow(::InternalApi::MechanicsService).to receive(:index).and_return([
        { "id" => mechanic.id, "name" => mechanic.name, "email" => mechanic.email }
      ])
      get '/mechanics'
    end
    it "redirects" do
      expect(response).to be_redirect
    end
  end

  describe "GET /mechanics/:id for mechanic" do
    before do
      sign_in mechanic
      get "/mechanics/#{mechanic.id}"
    end
    it "get status ok for mechanic" do

      expect(response).to have_http_status(:ok)
    end
  end
  describe "GET /mechanics/:id for mechanic" do
    before do
      sign_in customer
      get "/mechanics/#{mechanic.id}"
    end
    it "get status ok for customer" do

      expect(response).to be_redirect
    end

  end

  describe "PATCH /mechanics/:id for mechanic" do
    before do
      sign_in mechanic
      patch "/mechanics/#{mechanic.id}", params: {
        mechanic: {
          name: "demo"
        }
      }
    end
    it " Update for mechanic", :aggregate_failures do
      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Mechanic updated successfully")
    end
  end
  describe "PATCH /mechanics/:id for mechanic" do
    before do
      sign_in mechanic
      patch "/mechanics/#{mechanic.id}", params: {
        mechanic: {
          experience: "two"
        }
      }
    end
    it "Update with invalid param", :aggregate_failures do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Experience is not a number")
    end

  end

  describe "GET /mechanics/:id for mechanic" do
    before do
       sign_in mechanic
      get "/mechanics/#{mechanic.id}"
    end
    it "get status ok for mechanic" do
      expect(response).to have_http_status(:ok)
    end
  end
  describe "GET /mechanics/:id for mechanic" do
    before do
       sign_in customer
      get "/mechanics/#{mechanic.id}"
    end
    it "get status ok for customer" do
      expect(response).to be_redirect
    end

  end

  describe "Delete /mechanics/:id for admin" do
    before do
      sign_in admin
      mechanic_to_destroy = Mechanic.create!(
        name: "delete",
        email: "delete@test.com",
        experience: "1",
        password: "12345678"
      )
      delete "/mechanics/#{mechanic_to_destroy.id}"

    end
    it "Deletes mechanic", :aggregate_failures do
      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Mechanic was successfully deleted.")
    end
  end
   describe "Delete /mechanics/:id for no admin" do
    before do
      sign_in customer
      mechanic_to_destroy = Mechanic.create!(
        name: "delete",
        email: "delete@test.com",
        experience: "1",
        password: "12345678"
      )
      delete "/mechanics/#{mechanic_to_destroy.id}"

    end
    it "Redirects" do
      expect(response).to be_redirect
    end

  end
end
