require 'rails_helper'

RSpec.describe Summary, type: :model do
  let(:customer) { Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678") }
  let(:vehicle) { Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id) }
  let(:record) { Record.create!(vehicle_id: vehicle.id, status: 'pending', internal_notes: 'Test notes') }
  let(:valid_attributes) { { record_id: record.id, summary_text: 'Test summary' } }

  describe 'validations' do
    it 'is valid with valid attributes' do
      summary = Summary.new(valid_attributes)
      expect(summary).to be_valid
    end

    it 'requires record_id' do
      summary = Summary.new(valid_attributes.merge(record_id: nil))
      expect(summary).not_to be_valid
      expect(summary.errors[:record_id]).to include("can't be blank")
    end

    it 'requires summary_text' do
      summary = Summary.new(valid_attributes.merge(summary_text: nil))
      expect(summary).not_to be_valid
      expect(summary.errors[:summary_text]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:record) }
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[record]
      expect(Summary.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[completed_at customer_notes id record_id summary_text]
      expect(Summary.ransackable_attributes(nil)).to match_array(expected)
    end
  end
end
