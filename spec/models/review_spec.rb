require 'rails_helper'

require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:valid_attributes) { { status: 'pending', internal_notes: 'Test notes' } }
  it "Should validate content and customer" do
    customer = Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678")
    vehicle = Vehicle.create!(number_plate: "TN12AC1234", model: "Electric", customer_id: customer.id)
    record = Record.new(valid_attributes.merge(status: nil))
    record.vehicle = vehicle
    record.save
    review = Review.create!(content: "test", customer_id: customer.id, reviewable_id: record.id, reviewable_type: 'Record')
    expect(review).not_to be_nil
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[customer reviewable]
      expect(Review.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[content customer_id id reviewable_id reviewable_type]
      expect(Review.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_scopes' do
    it 'returns mechanic_name_search scope' do
      expected = [ :mechanic_name_search ]
      expect(Review.ransackable_scopes(nil)).to match_array(expected)
    end
  end

  describe '.mechanic_name_search' do
    let(:mechanic) { Mechanic.create!(name: "john", email: "john@test.com", experience: "5", password: "12345678") }
    let(:customer) { Customer.create!(name: "test", email: "test@test.com", phone: "1234567890", password: "12345678") }

    it 'returns all reviews when name is blank' do
      review = Review.create!(content: "great", customer_id: customer.id, reviewable_id: mechanic.id, reviewable_type: 'Mechanic')
      expect(Review.mechanic_name_search("")).to include(review)
    end

    it 'filters reviews by mechanic name' do
      mechanic2 = Mechanic.create!(name: "jane", email: "jane@test.com", experience: "3", password: "12345678")
      review1 = Review.create!(content: "great", customer_id: customer.id, reviewable_id: mechanic.id, reviewable_type: 'Mechanic')
      review2 = Review.create!(content: "good", customer_id: customer.id, reviewable_id: mechanic2.id, reviewable_type: 'Mechanic')

      result = Review.mechanic_name_search("john")
      expect(result).to include(review1)
      expect(result).not_to include(review2)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:reviewable) }
  end
end
