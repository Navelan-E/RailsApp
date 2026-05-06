require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Reviews", type: :request do
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
      email: "customer@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let!(:vehicle) do
    Vehicle.create!(
      model: "Honda Civic",
      number_plate: "ABC123",
      customer_id: customer.id
    )
  end

  let!(:record) do
    Record.create!(
      vehicle_id: vehicle.id,
      status: "completed",
      internal_notes: "Test notes",
      mechanic_id: mechanic.id
    )
  end

  let!(:review) do
    Review.create!(
      reviewable: mechanic,
      customer_id: customer.id,
      content: "Great service"
    )
  end


  describe "GET /reviews" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/reviews'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/reviews'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/reviews'
      expect(response).to be_redirect
    end
  end

  describe "GET /reviews/#id/edit" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/reviews/#{review.id}/edit"

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer/#id" do
      sign_in customer
      get "/reviews/#{review.id}/edit"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "Patch /reviews/#id" do
    it "Update for mechanic" do
      sign_in mechanic
      patch "/reviews/#{review.id}", params: {
        review:{
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
    end

    it "get status ok for customer/#id" do
      sign_in customer
      patch "/reviews/#{review.id}", params: {
        review:{
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Review updated successfully.")
    end

    it "get status ok for customer/#id" do
      sign_in customer
      allow(Review).to receive(:find).and_return(review)
      allow(review).to receive(:update).and_return(false)
      allow(review).to receive(:errors)
      patch "/reviews/#{review.id}", params: {
        review:{
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
      expect(flash[:alert]).to eq("Failed to update review.")
    end
  end

  describe "GET /reviews/new" do
    it "get status ok for customer" do
      sign_in customer
      get "/reviews/new", params: {
        record_id: record.id
      }

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for mechanic" do
      sign_in mechanic
      get "/reviews/new"

      expect(response).to be_redirect
    end
  end

  describe "Post /reviews/" do
    it "get status ok to Mechanic" do
      sign_in customer
      post "/reviews", params: {
        record_id: record.id,
        review: {
          review_type: 'Mechanic',
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Review added successfully.")
    end

    it "get status ok to Vehicle" do
      sign_in customer
      post "/reviews", params: {
        record_id: record.id,
        review: {
          review_type: 'Vehicle',
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Review added successfully.")
    end

    it "get status ok to default" do
      sign_in customer
      post "/reviews", params: {
        record_id: record.id,
        review: {
          content: "Service is ok"
        }
      }

      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Review added successfully.")
    end


    

    it "get status ok for mechanic" do
      sign_in mechanic
      post "/reviews"

      expect(response).to be_redirect
    end
  end

  describe "Delete /reviews/#id" do
    it "Delete review for mechanic" do
      sign_in customer
      review_to_delete = Review.create!(
        reviewable: mechanic,
        customer_id: customer.id,
        content: "Great service"
      )
      delete "/reviews/#{review_to_delete.id}"
      expect(response).to be_redirect
      expect(flash[:notice]).to eq("Review deleted successfully.")
    end
  end
end
