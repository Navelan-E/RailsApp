class Summary < ApplicationRecord
  validates :record_id, :summary_text, presence: true
  belongs_to :record

  def self.ransackable_associations(_auth_object = nil)
    ["record"]
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["completed_at", "customer_notes", "id", "record_id", "summary_text"]
  end
end
