require 'rails_helper'

require 'rails_helper'

RSpec.describe Tag, type: :model do
  it "Should validate tag" do
    tag = Tag.create!(tag: "test")
    expect(tag).not_to be_nil
  end

  describe 'ransackable_associations' do
    it 'returns correct associations' do
      expected = %w[records]
      expect(Tag.ransackable_associations(nil)).to match_array(expected)
    end
  end

  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[id tag]
      expect(Tag.ransackable_attributes(nil)).to match_array(expected)
    end
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:records) }
  end
end
