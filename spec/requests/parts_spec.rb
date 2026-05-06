require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Parts", type: :request do
  let!(:mechanic) do
    Mechanic.create!(
      name: "test",
      email: "test@test.com",
      experience: "1",
      password: "12345678"
    )
  end

  let!(:admin) do
    AdminUser.create!(
      email: "admin@test.com",
      password: "12345678"
    )
  end

  let!(:customer) do
    Customer.create!(
      name: "test",
      email: "customer@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let!(:part) do
    Part.create!(
      name: "Brake Pad",
      price: 25.50,
      stock: 100
    )
  end

  describe "GET /parts" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/parts'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for customer" do
      sign_in customer
      get '/parts'
      expect(response).to be_redirect
    end
  end

  describe "GET /parts/new" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/parts/new'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for customer" do
      sign_in customer
      get '/parts/new'
      expect(response).to be_redirect
    end
  end

  describe "POST /parts" do
    it "creates part for mechanic" do
      sign_in mechanic
      post '/parts', params: {
        part: {
          name: "Oil Filter",
          price: 15.00,
          stock: 50
        }
      }
      expect(response).to redirect_to(parts_path)
      expect(flash[:notice]).to eq("Part added successfully.")
    end

    it "redirects for customer" do
      sign_in customer
      post '/parts', params: {
        part: {
          name: "Oil Filter",
          price: 15.00,
          stock: 50
        }
      }
      expect(response).to be_redirect
    end
  end

  describe "GET /parts/:id/edit" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/parts/#{part.id}/edit"

      expect(response).to have_http_status(:ok)
    end

    it "redirects for customer" do
      sign_in customer
      get "/parts/#{part.id}/edit"
      expect(response).to be_redirect
    end
  end

  describe "PATCH /parts/:id" do
    it "updates part for mechanic" do
      sign_in mechanic
      patch "/parts/#{part.id}", params: {
        part: {
          stock: 80
        }
      }
      expect(response).to redirect_to(parts_path)
      expect(flash[:notice]).to eq("Part updated successfully.")
    end

    it "redirects for customer" do
      sign_in customer
      patch "/parts/#{part.id}", params: {
        part: {
          stock: 80
        }
      }
      expect(response).to be_redirect
    end
  end
end
