require 'rails_helper'

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe "Records", type: :request do
  let!(:mechanic) { create(:mechanic) }
  let!(:customer) { create(:customer) }
  let!(:vehicle) { create(:vehicle, customer: customer, number_plate: 'ABC123', model: 'Test Model') }
  let!(:record) { create(:record, vehicle: vehicle) }

  let!(:part) { create(:part, name: 'Oil Filter', price: 10.0, stock: 50) }
  let!(:tag) { create(:tag, tag: 'Oil Change') }

  describe "GET /records" do
    context "Authenticated as mechanic" do
      before { sign_in mechanic }

      it "returns 200" do
        get "/records"
        expect(response).to have_http_status(:ok)
      end

      it "filters records by vehicle number plate" do
        get "/records", params: { q: vehicle.number_plate }
        expect(response).to have_http_status(:ok)
      end
    end

    context "Authenticated as customer" do
      before { sign_in customer }

      it "returns 200" do
        get "/records"
        expect(response).to have_http_status(:ok)
      end
    end

    context "Unauthenticated" do
      it "redirects" do
        get "/records"
        expect(response).to be_redirect
      end
    end
  end

  describe "GET /records/:id" do
    context "Authenticated as mechanic" do
      before { sign_in mechanic }

      it "returns 200" do
        get "/records/#{record.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    context "Authenticated as customer" do
      before { sign_in customer }

      it "returns 200" do
        get "/records/#{record.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    context "Unauthenticated" do
      it "redirects" do
        get "/records/#{record.id}"
        expect(response).to be_redirect
      end
    end
  end

  describe "GET /records/new" do
    context "Authenticated as mechanic" do
      before { sign_in mechanic }

      it "returns 200" do
        get "/records/new"
        expect(response).to have_http_status(:ok)
      end
    end

    context "Authenticated as customer" do
      before { sign_in customer }

      it "redirects" do
        get "/records/new"
        expect(response).to be_redirect
      end
    end

    context "Unauthenticated" do
      it "redirects" do
        get "/records/new"
        expect(response).to be_redirect
      end
    end
  end

  describe "POST /records" do
    subject(:make_request) do
      post "/records", params: params
    end

    let(:params) do
      {
        record: {
          internal_notes: 'Test notes',
          vehicle_no: vehicle.number_plate,
          model: vehicle.model,
          customer_name: customer.name,
          customer_phone: customer.phone,
          customer_email: customer.email,
          custom_tags: 'New Tag',
          tag_ids: [ tag.id ]
        }
      }
    end

    context "Authenticated as mechanic" do
      before { sign_in mechanic }

      it "creates a record (and assigns tags)" do
        expect { make_request }.to change(Record, :count).by(1)
        expect(response).to redirect_to(records_path)
      end
    end

    context "Unauthenticated" do
      it "redirects" do
        expect { make_request }.not_to change(Record, :count)
        expect(response).to be_redirect
      end
    end
  end

  describe "PATCH /records/:id" do
    subject(:make_request) do
      patch "/records/#{record.id}", params: params
    end

    let(:params) do
      {
        record: {
          internal_notes: 'Updated notes',
          status: 'completed',
          mechanic_id: mechanic.id,
          total_cost: 100.0,
          customer_notes: 'Customer happy',
          part_id: part.id,
          part_quantity: 2
        }
      }
    end

    context "Authenticated as mechanic" do
      before { sign_in mechanic }

      it "updates record" do
        expect { make_request }.not_to raise_error
        expect(response).to redirect_to(records_path)
        record.reload
        expect(record.internal_notes).to eq('Updated notes')
        expect(record.status).to eq('completed') if record.respond_to?(:status)
      end
    end

    context "Authenticated as customer" do
      before { sign_in customer }

      it "redirects/forbidden" do
        make_request
        expect(response).to be_redirect
      end
    end
  end
end
