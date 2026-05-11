require 'rails_helper'

RSpec.describe 'Api::V1::Records', type: :request do
  def skip_doorkeeper_authorization
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!).and_return(true)
  end

  before { skip_doorkeeper_authorization }
  let!(:customer) do
    Customer.create!(
      email: 'cust@test.com',
      phone: '1234567890',
      password: 'password123',
      name: 'Test Customer'
    )
  end

  let!(:vehicle) do
    Vehicle.create!(
      customer: customer,
      number_plate: 'ABC123',
      model: 'Test Model'
    )
  end

  let!(:mechanic) do
    Mechanic.create!(
      email: 'mech@test.com',
      password: 'password123',
      name: 'Test Mechanic',
      experience: '5'
    )
  end

  let!(:part) { Part.create!(name: 'Oil Filter', price: 10.0, stock: 50) }
  let!(:tag) { Tag.create!(tag: 'Oil Change') }

  let(:c_token) { 'test_token' }

  describe 'GET /api/v1/records' do
    let!(:record1) { Record.create!(vehicle: vehicle, internal_notes: 'Rec1', status: 'pending') }
    let!(:record2) { Record.create!(vehicle: vehicle, internal_notes: 'Rec2', status: 'in_progress') }
    before do
      get '/api/v1/records', params: params, headers: { 'Authorization' => "Bearer #{c_token}" }
    end
    context "Authendicated" do
      let(:params) { }
      it 'returns all records' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
      end
    end
    context "Authendicated" do
      let(:params) { { q: 'ABC' } }
      it 'filters records by vehicle number plate' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json[0]["vehicle_id"]).to eq(vehicle.id)
      end
    end
    context "Authendicated" do
      let(:params) { { q: 'NONEXIST' } }
      it 'returns empty for non-matching search' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(0)
      end
    end
  end
  describe 'GET /api/v1/records/:id' do
    let!(:record) { Record.create!(vehicle: vehicle, internal_notes: 'Show rec', status: 'pending') }
    before do
      get "/api/v1/records/#{id}", headers: { 'Authorization' => "Bearer #{c_token}" }
    end

    context "Authendicated" do
      let(:id) { record.id }
      it 'returns record' do
        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicated" do
      let(:id) { 120 }
      it 'returns 404 not found' do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Record Not found')
      end
    end
  end

  describe 'POST /api/v1/records' do
    subject(:make_request) do
      post '/api/v1/records', params: params
    end
    context "Authendicated" do
      let(:params) { {
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
            } }
      it 'creates record, customer/vehicle/tags if new', :aggregate_failures do
        expect {
          make_request
        }.to change(Record, :count).by(1)
        .and change(Tag, :count).by(1)
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Succesfully created')
      end
    end
    context "Authendicated" do
      let(:params) { {
              record: {
                internal_notes: 'Test notes',
                vehicle_no: vehicle.number_plate,
                model: vehicle.model,
                customer_name: customer.name,
                customer_phone: customer.phone,
                customer_email: customer.email,
                custom_tags: '',
                tag_ids: []
              }
            } }
      it 'reuses existing customer/vehicle', :aggregate_failures do
        make_request
        expect(Customer.count).to eq(1)
        expect(Vehicle.count).to eq(1)
      end
    end
    context "Authendicated" do
      let(:params) { {
              record: {
                internal_notes: '',
                vehicle_no: vehicle.number_plate,
                model: vehicle.model,
                customer_name: customer.name,
                customer_phone: customer.phone,
                customer_email: customer.email,
                custom_tags: '',
                tag_ids: []
              }
            } }
      it 'fails validation', :aggregate_failures do
        make_request
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Internal notes')
      end
    end
  end

  describe 'PATCH /api/v1/records/:id' do
    let!(:record) { Record.create!(vehicle: vehicle, internal_notes: 'Old', status: 'pending') }
    subject(:make_request) do
      patch "/api/v1/records/#{id}", params: params,
          headers: { 'Authorization' => "Bearer #{c_token}" }
    end
    context "Authendicated" do
      let(:params) { {
              record: {
                internal_notes: 'Updated notes',
                status: 'completed',
                mechanic_id: mechanic.id,
                total_cost: 100.0,
                customer_notes: 'Customer happy',
                part_id: part.id,
                part_quantity: 2
              }
            } }
      let(:id) { record.id }
    it 'updates record and adds service_part', :aggregate_failures do
      expect{ make_request }.to change(ServicePart, :count).by(1)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Record updated successfully')
    end
    end
    context "Authendicated" do
        let(:params) { {
                record: {
                  internal_notes: 'No parts'
                }
              } }
        let(:id) { record.id }
      it 'skips service_part if no part_id/quantity' do
        expect{ make_request }.not_to change(ServicePart, :count)

        expect(response).to have_http_status(:ok)
      end
    end
    context "Authendicated" do
        let(:params) { {
                record: {
                  internal_notes: 'Update'
                }
              } }
        let(:id) { 120 }
      it '404 not found' do
        make_request
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Record Not found')
      end
    end
  end
end
