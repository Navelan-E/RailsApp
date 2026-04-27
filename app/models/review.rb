class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
  belongs_to :customer
  validates :content, presence: true
  validates :customer_id, presence: true
  validates :reviewable_type, presence: true, inclusion: { in: %w(Record Mechanic Vehicle), message: "%{value} is not a valid reviewable type" }
  validates :reviewable_id, presence: true

  def self.ransackable_associations(_auth_object = nil)
    ["customer", "reviewable"]
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["content", "customer_id", "id", "reviewable_id", "reviewable_type"]
  end
end
