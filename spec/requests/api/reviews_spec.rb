require 'rails_helper'

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
      email: "test@test.com",
      phone: "1234567890",
      password: "12345678"
    )
  end

  let!(:vehicle) do
    Vehicle.create!(
      customer: customer,
      number_plate: "ABC123",
      model: "Test Model"
    )
  end

  let!(:record) do
    Record.create!(
      vehicle: vehicle,
      internal_notes: "Test Record",
      status: "completed",
      mechanic: mechanic
    )
  end

  let!(:review) do
    Review.create!(
      reviewable: mechanic,
      customer: customer,
      content: "Great service!"
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

  describe "GET /api/v1/reviews" do
    before do
      get '/api/v1/reviews', headers: {
        "Authorization" => "Bearer #{c_token}"
      }
    end
    context "Auhendiaction as customer"
    it "returns all reviews", :aggregate_failures do
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 1
      expect(json[0]["content"]).to eq("Great service!")
    end
  end

  describe "GET /api/v1/reviews/:id" do
    before do
      get "/api/v1/reviews/#{id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }
    end
    context "Auhendiaction as customer" do
      let(:id) { review.id }
      it "returns a specific review" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(review.id)
        expect(json["content"]).to eq("Great service!")
      end
    end
    context "Auhendiaction as customer" do
      let(:id) { 120 }
      it "returns 404 for non-existent review" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Review no found")
      end
    end
  end

  describe "POST /api/v1/reviews" do
    before do
      post '/api/v1/reviews', headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: params
    end
    context "Auhendiaction as customer" do
      let(:params) { {
        review: {
          content: "Excellent work!"
        },
        record_id: record.id
      } }
      it "creates a new review successfully" do

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review added successfully.")
        expect(json["review"]["content"]).to eq("Excellent work!")
      end
    end
    context "Auhendiaction as customer" do
      let(:params) { {
        review: {
          content: "Excellent work!",
          review_type: "Mechanic"
        },
        record_id: record.id
      } }
      it "creates a new review successfully with type Mechanic" do

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review added successfully.")
        expect(json["review"]["content"]).to eq("Excellent work!")
      end
    end
    context "Auhendiaction as customer" do
      let(:params) { {
        review: {
          content: "Excellent work!",
          review_type: "Vehicle"
        },
        record_id: record.id
      } }
      it "creates a new review successfully with type Vehicle" do

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review added successfully.")
        expect(json["review"]["content"]).to eq("Excellent work!")
      end
    end
    context "Authendicated as customer" do
      let(:params) {{
        review: {
          content: "",
          review_type: "Mechanic"
        },
        record_id: record.id
      }}

      it "fails to create review without required fields" do

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Failed to add review.")
      end
    end
  end

  describe "PATCH /api/v1/reviews/:id" do
    before do
      patch "/api/v1/reviews/#{id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }, params: params
    end

    context "Authendicate as customer" do
      let(:id) { review.id }
      let(:params) { {
        review: {
          content: "Updated review content"
        }
      } }
      it "updates a review successfully" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Review updated successfully.")
        expect(json["review"]["content"]).to eq("Updated review content")
      end
    end

    context "Authendicate as customer" do
      let(:id) { 120 }
      let(:params) { {
        review: {
          content: "Updated review content"
        }
      } }
      it "returns 404 for non-existent review" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Review not found")
      end
    end
    context "Authendicate as customer" do
      let(:id) { review.id }
      let(:params) { {
        review: {
          content: ""
        }
      } }
      it "fails to update review with invalid params" do
        allow_any_instance_of(Review).to receive(:update).and_return(false)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Failed to update review.")
      end
    end
  end

  describe "DELETE /api/v1/reviews/:id" do
    before do
      delete "/api/v1/reviews/#{id}", headers: {
        "Authorization" => "Bearer #{c_token}"
      }
    end
    context "Authendicate as customer" do
      let(:id) { review.id }
      it "deletes a review successfully" do
        expect(response).to have_http_status(:no_content)
      end
    end
    context "Authendicate as customer" do
      let(:id) { 120 }
      it "returns 404 for non-existent review" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Review not found")
      end
    end
  end
end
