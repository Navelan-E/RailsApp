class Tag < ApplicationRecord
  validates :tag, presence: true, uniqueness: true
  has_and_belongs_to_many :records, join_table: :service_tags

  def self.ransackable_associations(_auth_object = nil)
    ["records"]
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["id", "tag"]
  end
end
