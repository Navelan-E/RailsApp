class Vehicle < ApplicationRecord
  validates :number_plate, :model, :customer_id, presence: true
  belongs_to :customer
  has_many :records, dependent: :destroy
  has_many :reviews, as: :reviewable, dependent: :destroy

  def self.ransackable_associations(_auth_object = nil)
    ["customer", "records", "reviews"]
  end
  def self.ransackable_attributes(_auth_object = nil)
    ["customer_id", "id", "model", "number_plate"]
  end
end
