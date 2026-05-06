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

    it 'returns all records' do
      get '/api/v1/records', headers: { 'Authorization' => "Bearer #{c_token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it 'filters records by vehicle number plate' do
      get '/api/v1/records', params: { q: 'ABC' }, headers: { 'Authorization' => "Bearer #{c_token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it 'returns empty for non-matching search' do
      get '/api/v1/records', params: { q: 'NONEXIST' }, headers: { 'Authorization' => "Bearer #{c_token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(0)
    end
  end

  describe 'GET /api/v1/records/:id' do
    let!(:record) { Record.create!(vehicle: vehicle, internal_notes: 'Show rec', status: 'pending') }

    it 'returns record' do
      get "/api/v1/records/#{record.id}", headers: { 'Authorization' => "Bearer #{c_token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(record.id)
      expect(json['internal_notes']).to eq('Show rec')
      expect(json['status']).to eq('pending')
    end

    it 'returns 404 not found' do
      get '/api/v1/records/999', headers: { 'Authorization' => "Bearer #{c_token}" }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Record Not found')
    end
  end

  describe 'POST /api/v1/records' do
    it 'creates record, customer/vehicle/tags if new' do
      expect {
        post '/api/v1/records',
          params: {
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
          },
          headers: { 'Authorization' => "Bearer #{c_token}" }
      }.to change(Record, :count).by(1).and change(Tag, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Succesfully created')
      expect(json['record']['internal_notes']).to eq('Test notes')
      expect(json['record']['status']).to eq('pending')
      expect(Record.last.vehicle_id).to eq(vehicle.id)
      expect(Record.last.tags.exists?(tag: 'New Tag')).to be true
    end

    it 'reuses existing customer/vehicle' do
      post '/api/v1/records',
        params: {
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
        },
        headers: { 'Authorization' => "Bearer #{c_token}" }

      expect(Customer.count).to eq(1)
      expect(Vehicle.count).to eq(1)
    end

    it 'fails validation' do
      post '/api/v1/records',
        params: {
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
        },
        headers: { 'Authorization' => "Bearer #{c_token}" }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to include('Internal notes')
    end
  end

  describe 'PATCH /api/v1/records/:id' do
    let!(:record) { Record.create!(vehicle: vehicle, internal_notes: 'Old', status: 'pending') }

    it 'updates record and adds service_part' do
      expect {
        patch "/api/v1/records/#{record.id}",
          params: {
            record: {
              internal_notes: 'Updated notes',
              status: 'completed',
              mechanic_id: mechanic.id,
              total_cost: 100.0,
              customer_notes: 'Customer happy',
              part_id: part.id,
              part_quantity: 2
            }
          },
          headers: { 'Authorization' => "Bearer #{c_token}" }
      }.to change(ServicePart, :count).by(1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Record updated successfully')
      record.reload
      expect(record.internal_notes).to eq('Updated notes')
      expect(record.status).to eq('completed')
      expect(record.total_cost).to eq(100.0)
      expect(record.summary.customer_notes).to eq('Customer happy')
      expect(record.service_parts.first.part).to eq(part)
      expect(record.service_parts.first.quantity).to eq(2)
    end

    it 'skips service_part if no part_id/quantity' do
      expect {
        patch "/api/v1/records/#{record.id}",
          params: {
            record: {
              internal_notes: 'No parts'
            }
          },
          headers: { 'Authorization' => "Bearer #{c_token}" }
      }.not_to change(ServicePart, :count)

      expect(response).to have_http_status(:ok)
    end

    it '404 not found' do
      patch '/api/v1/records/999',
        params: {
          record: {
            internal_notes: 'Update'
          }
        },
        headers: { 'Authorization' => "Bearer #{c_token}" }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Record Not found')
    end
  end
end
