class ServicePart < ApplicationRecord
  validates :record_id, :part_id, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :record_id, uniqueness: { scope: :part_id, message: "Part already added to this record" }
  belongs_to :record
  belongs_to :part

  def self.ransackable_attributes(_auth_object = nil)
    ["id", "part_id", "quantity", "record_id"]
  end
end
