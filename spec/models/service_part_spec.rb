require 'rails_helper'

require 'rails_helper'

RSpec.describe ServicePart, type: :model do
    let(:valid_attributes) { { status: 'pending', internal_notes: 'Test notes' } }

  it "Should validate record_id part_id quantity" do
    customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
    vehicle = Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id)
    record = Record.new(valid_attributes.merge(status: nil))
    record.vehicle = vehicle
    record.save
    part = Part.create!(name: "test", price: 200, stock: 10)
    service_part = ServicePart.create!(record_id: record.id, part_id: part.id, quantity: 1)
    expect(service_part).not_to be_nil
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[part record]
      expect(ServicePart.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[id part_id quantity record_id]
      expect(ServicePart.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_scopes' do
    it 'returns scopes' do
      expected = %w[exclude_completed used_parts parts_in_use]
      expect(ServicePart.ransackable_scopes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:record) }
    it { is_expected.to belong_to(:part) }
  end

  describe 'scopes' do
    let(:customer) { Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678") }
    let(:vehicle) { Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id) }
    let(:pending_record) { Record.create!(vehicle_id: vehicle.id, status: 'pending', internal_notes: 'pending') }
    let(:in_progress_record) { Record.create!(vehicle_id: vehicle.id, status: 'in_progress', internal_notes: 'in_progress') }
    let(:completed_record) { Record.create!(vehicle_id: vehicle.id, status: 'completed', internal_notes: 'completed') }
    let(:part) { Part.create!(name: "test", price: 200, stock: 10) }

    describe '.exclude_completed' do
      it 'returns service parts that are not completed' do
        pending_sp = ServicePart.create!(record_id: pending_record.id, part_id: part.id, quantity: 1)
        in_progress_sp = ServicePart.create!(record_id: in_progress_record.id, part_id: part.id, quantity: 2)
        completed_sp = ServicePart.create!(record_id: completed_record.id, part_id: part.id, quantity: 3)

        result = ServicePart.exclude_completed
        expect(result).to include(pending_sp, in_progress_sp)
        expect(result).not_to include(completed_sp)
      end
    end

    describe '.used_parts' do
      it 'returns service parts in completed records' do
        pending_sp = ServicePart.create!(record_id: pending_record.id, part_id: part.id, quantity: 1)
        completed_sp = ServicePart.create!(record_id: completed_record.id, part_id: part.id, quantity: 3)

        result = ServicePart.used_parts
        expect(result).to include(completed_sp)
        expect(result).not_to include(pending_sp)
      end
    end

    describe '.parts_in_use' do
      it 'returns service parts in in_progress records' do
        pending_sp = ServicePart.create!(record_id: pending_record.id, part_id: part.id, quantity: 1)
        in_progress_sp = ServicePart.create!(record_id: in_progress_record.id, part_id: part.id, quantity: 2)

        result = ServicePart.parts_in_use
        expect(result).to include(in_progress_sp)
        expect(result).not_to include(pending_sp)
      end
    end
  end
end
