require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Records", type: :request do

  let!(:mechanic) { create(:mechanic) }
  let!(:customer) { create(:customer) }
  let!(:vehicle)  { create(:vehicle, customer: customer) }
  let!(:record)   { create(:record, vehicle: vehicle) }

  describe "GET /records" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get '/records'

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get '/records'

      expect(response).to have_http_status(:ok)
    end

    it "redirects for unauthenticated user" do
      get '/records'
      expect(response).to be_redirect
    end

    it 'filters records by vehicle number plate' do
      sign_in mechanic
      get '/records', params: { q: 'ABC' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ABC")
    end
  end

  describe "GET /records/:id" do
    it "get status ok for mechanic" do
      sign_in mechanic
      get "/records/#{record.id}"

      expect(response).to have_http_status(:ok)
    end

    it "get status ok for customer" do
      sign_in customer
      get "/records/#{record.id}"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /records/new" do
    it "redirects for customer" do
      sign_in customer
      get '/records/new'
      expect(response).to be_redirect
    end

    it "get status ok for mechanic" do
      sign_in mechanic
      get '/records/new'

      expect(response).to have_http_status(:ok)
    end
  end
end
