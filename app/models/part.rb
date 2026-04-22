class Part < ApplicationRecord
  validates :name, :price, :stock, presence: true
  validates :price, :stock, numericality: { only_integer: false }
  has_many :service_parts
  has_many :records, through: :service_parts

  def self.ransackable_associations(_auth_object = nil)
    ["records", "service_parts" ,"tags"]
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["id", "tag", "price", "stock", "name", "created_at", "updated_at"]
  end
end
