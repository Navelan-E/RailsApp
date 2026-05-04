require 'rails_helper'

RSpec.describe Part, type: :model do
  it "Should validate if all of the correct parameters" do
    part = Part.create!(name: "test", price: 200, stock: 10)
    expect(part).not_to be_nil
  end

  it "Should not validate if null parameters" do
    part = Part.create(name: nil, price: nil, stock: nil)
    expect(part).not_to be_valid
  end

  it "Should not validate if invalid email" do
    part = Part.create(name: "test", price: "two", stock: "ten")

    expect(part).not_to be_valid
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[records service_parts tags]
      expect(Part.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[id name price stock created_at updated_at tag]
      expect(Part.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:service_parts) }
    it { is_expected.to have_many(:records).through(:service_parts) }
  end
end
