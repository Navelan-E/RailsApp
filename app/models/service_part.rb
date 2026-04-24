class ServicePart < ApplicationRecord
  validates :record_id, :part_id, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :record_id, uniqueness: { scope: :part_id, message: "Part already added to this record" }
  belongs_to :record
  belongs_to :part

  def self.ransackable_attributes(_auth_object = nil)
    ["id", "part_id", "quantity", "record_id"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["part", "record"]
  end
 
  def self.ransackable_scopes(_auth_object = nil)
    %w[exclude_completed used_parts parts_in_use]
  end

  scope :exclude_completed, -> {
    joins(:record).where.not(records: { status: "completed" })
  }

  scope :used_parts, -> {
    joins(:record).where(records: { status: "completed" })
  }

  scope :parts_in_use, -> {
    joins(:record).where(records: { status: "in_progress" })
  }
end
