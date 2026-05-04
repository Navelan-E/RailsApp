require 'rails_helper'

RSpec.describe Customer, type: :model do
  it "Find the Customer using number plate" do
    customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
    vehicle = Vehicle.new(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id)
    vehicle.save!
    result = Customer.vehicle_plate("TN12AC1234")
    expect(result).to include(customer)
  end

  it "Should validate if all of the correct parameters" do
    customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
    expect(customer).not_to be_nil
  end

  it "Should not validate if null parameters" do
    customer = Customer.create(
      name: nil,
      email: nil,
      phone: nil,
      password: nil
    )

    expect(customer).not_to be_valid
  end

  it "Should not validate if invalid email" do
    customer = Customer.create(
      name: "test",
      email: "nil",
      phone: "1234567890",
      password: "12345678"
    )

    expect(customer).not_to be_valid
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[vehicles]
      expect(Customer.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[email id name phone]
      expect(Customer.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_scopes' do
    it 'returns vehicle_plate scope' do
      expected = [ :vehicle_plate ]
      expect(Customer.ransackable_scopes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:vehicles) }
  end
end
