class Record < ApplicationRecord

  scope :latest_completed, -> {
    where(status: "completed").order(updated_at: :desc)
  }
  validates :vehicle_id, :status, :internal_notes, presence: true
  before_validation :ensure_status_values
  attr_accessor :customer_notes
  before_update :sumarize_record, if: :completed?
  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed' }
  belongs_to :vehicle
  has_one :customer, through: :vehicle
  has_one :summary
  belongs_to :mechanic, optional: true
  has_many :service_parts, inverse_of: :record, dependent: :destroy
  accepts_nested_attributes_for :service_parts, allow_destroy: true
  has_many :parts, through: :service_parts
  has_and_belongs_to_many :tags, join_table: :service_tags
  has_many :reviews, as: :reviewable

  def ensure_status_values
    self.status ||= 'pending'
  end

  def sumarize_record
    puts "Summarizing record with status: #{self.customer_notes}"
    if self.summary.present?
      self.summary.update(summary_text: self.internal_notes, customer_notes: self.customer_notes, completed_at: Time.current)
    else
      Summary.create(record_id: self.id, summary_text: self.internal_notes, customer_notes: self.customer_notes, completed_at: Time.current)
    end
  end
  def self.ransackable_associations(_auth_object = nil)
    ["customer", "mechanic", "parts", "tags", "vehicle", "reviews", "summary", "service_parts"]
  end
  def self.ransackable_attributes(_auth_object = nil)
    ["id", "internal_notes", "mechanic_id", "status", "total_cost", "vehicle_id", "created_at", "updated_at"]
  end
  def self.ransackable_scopes(_auth_object = nil)
    [:latest_completed]
  end
end
