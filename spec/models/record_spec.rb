require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:valid_attributes) { { status: 'pending', internal_notes: 'Test notes' } }

  describe 'validations' do
    it 'is valid with valid attributes' do
      customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
      vehicle = Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id)
      record = Record.new(valid_attributes)
      record.vehicle = vehicle
      expect(record).to be_valid
    end

    it 'requires vehicle_id' do
      record = Record.new(valid_attributes)
      expect(record).not_to be_valid
      expect(record.errors[:vehicle_id]).to include("can't be blank")
    end

    it 'subtitute pending if status is nil' do
      customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
      vehicle = Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id)
      record = Record.new(valid_attributes.merge(status: nil))
      record.vehicle = vehicle
      expect(record).to be_valid
      expect(record.status).to include('pending')
    end

    it 'requires internal_notes' do
      record = Record.new(valid_attributes.merge(internal_notes: nil))
      expect(record).not_to be_valid
      expect(record.errors[:internal_notes]).to include("can't be blank")
    end
  end

  describe 'enum :status' do
    let(:record) { Record.new(valid_attributes.merge(vehicle_id: 1)) }

    it 'has pending scope' do
      record.status = 'pending'
      expect(record.pending?).to be true
    end

    it 'has in_progress scope' do
      record.status = 'in_progress'
      expect(record.in_progress?).to be true
    end

    it 'has completed scope' do
      record.status = 'completed'
      expect(record.completed?).to be true
    end
  end

  describe '#ensure_status_values' do
    let(:record) { Record.new(valid_attributes.merge(vehicle_id: 1, status: nil)) }

    it 'defaults status to pending before validation' do
      expect(record.status).to be_nil
      record.valid?
      expect(record.status).to eq 'pending'
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:vehicle) }
    it { is_expected.to have_one(:customer).through(:vehicle) }
    it { is_expected.to have_one(:summary) }
    it { is_expected.to belong_to(:mechanic).optional(true) }
    it { is_expected.to have_many(:service_parts).dependent(:destroy) }
    it { is_expected.to have_many(:parts).through(:service_parts) }
    it { is_expected.to have_and_belong_to_many(:tags) }
  end

  describe '#customer_notes' do
    it 'is accessible via attr_accessor' do
      record = Record.new(valid_attributes)
      record.customer_notes = 'customer note'
      expect(record.customer_notes).to eq 'customer note'
    end
  end

  describe '#sumarize_record' do
    let(:customer) { Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678") }
    let(:vehicle) { Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id) }
    let(:record) { Record.create!(valid_attributes.merge(vehicle_id: vehicle.id)) }

    context 'when summary does not exist' do
      it 'creates a new summary' do
        record.customer_notes = 'test notes'
        expect { record.send :sumarize_record }.to change(Summary, :count).by(1)
        summary = Summary.last
        expect(summary.record_id).to eq(record.id)
        expect(summary.summary_text).to eq(record.internal_notes)
        expect(summary.customer_notes).to eq('test notes')
      end
    end

    context 'when summary exists' do
      it 'updates existing summary' do
        summary = Summary.create!(record_id: record.id, summary_text: 'old text')
        record.customer_notes = 'updated notes'
        record.send :sumarize_record
        summary.reload
        expect(summary.summary_text).to eq(record.internal_notes)
        expect(summary.customer_notes).to eq('updated notes')
      end
    end
  end

  describe '.ransackable_associations' do
    it 'returns correct associations' do
      expect(Record.ransackable_associations(nil)).to match_array(
        %w[customer mechanic parts tags vehicle reviews summary service_parts]
      )
    end
  end

  describe '.ransackable_attributes' do
    it 'returns correct attributes' do
      expect(Record.ransackable_attributes(nil)).to match_array(
        %w[id internal_notes mechanic_id status total_cost vehicle_id created_at updated_at]
      )
    end
  end
end
