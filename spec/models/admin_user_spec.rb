require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe 'ransackable_attributes' do
    it 'returns correct attributes' do
      expected = %w[email id]
      expect(AdminUser.ransackable_attributes(nil)).to match_array(expected)
    end
  end
end
