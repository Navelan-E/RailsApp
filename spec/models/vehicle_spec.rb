require 'rails_helper'

require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  it "Should validate all parameters" do
    customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
    vehicle = Vehicle.create!(number_plate: "test", model: "test", customer_id: customer.id)
    expect(vehicle).not_to be_nil
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[customer records reviews]
      expect(Vehicle.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[customer_id id model number_plate]
      expect(Vehicle.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:records) }
    it { is_expected.to have_many(:reviews) }
  end
end
