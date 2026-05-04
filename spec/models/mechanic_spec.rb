require 'rails_helper'

RSpec.describe Mechanic, type: :model do
  it "Should validate if all of the correct parameters" do
    mechanic = Mechanic.create!(name: "test", email: "test@test.com", experience: "1", password: "12345678")
    expect(mechanic).not_to be_nil
  end

  it "Should not validate if null parameters" do
    mechanic = Mechanic.create(
      name: nil,
      email: nil,
      experience: nil,
      password: nil
    )

    expect(mechanic).not_to be_valid
  end

  it "Should strip the invalid space" do
    mechanic = Mechanic.create!(name: "   test    ", email: "test@test.com", experience: "1", password: "12345678")
    expect(mechanic.name).to eq("test")
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[email experience id name]
      expect(Mechanic.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:records) }
  end
end
