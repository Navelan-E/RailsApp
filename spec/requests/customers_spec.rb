require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

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
  describe "GET /customers" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/customers'

      expect(response).to have_http_status(:ok)
    end
    it "redirects for customer" do
      sign_in customer
      get '/customers'
      # Customer is redirected because authenticate_pros? only allows mechanics
      expect(response).to be_redirect
    end
  end

  describe "GET /customers/:id" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/customers/#{customer.id}"

      expect(response).to have_http_status(:ok)
    end
    it "redirects for customer" do
      sign_in customer
      get "/customers/#{customer.id}"
      # Customer is redirected because authenticate_pros? only allows mechanics
      expect(response).to be_redirect
    end

    it "redirects with alert for mechanic when not found" do
      sign_in mechanic
      get "/customers/#{120}"

      expect(response).to redirect_to(customers_path)
      expect(flash[:alert]).to eq("Customer not found.")
    end
  end

  describe "PATCH /customers/:id" do
    it "redirects for mechanic" do
      sign_in mechanic
      patch "/customers/#{customer.id}", params: {
        customer: {
          name: "Demo"
        }
      }
      # Devise redirects to root or previous page for unauthorized users
      expect(response).to be_redirect
    end
    it "returns success for valid update" do
      sign_in customer
      patch "/customers/#{customer.id}", params: {
        customer: {
          name: "Demo"
        }
      }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Customer updated successfully.")
    end
    it "redirects with alert when customer not found" do
      sign_in customer
      patch "/customers/#{120}"

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /customers/:id/disable" do
    it "redirects for mechanic" do
      sign_in mechanic
      patch "/customers/#{customer.id}/disable"
      # Devise redirects to root or previous page for unauthorized users
      expect(response).to be_redirect
    end
    it "redirects successfully for customer" do
      sign_in customer
      patch "/customers/#{customer.id}/disable"
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Customer disabled successfully.")
    end
    it "redirects with alert if invalid id" do
      sign_in customer
      patch "/customers/#{120}/disable"

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /customers/:id/unlock" do
    it "redirects successfully for customer" do
      sign_in customer
      customer.lock_access!
      patch "/customers/#{customer.id}/unlock"
      expect(response).to redirect_to(new_customer_session_path)
    end
    it "redirects with alert if invalid id" do
      sign_in customer
      patch "/customers/#{120}/unlock"

      expect(response).to redirect_to(root_path)
    end
  end
end