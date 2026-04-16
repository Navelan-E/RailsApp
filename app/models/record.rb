class Record < ApplicationRecord
  validates :vehicle_id, :status, :internal_notes, presence: true
  before_validation :ensure_status_values
  before_update :sumarize_record, if: :completed?
  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed' }
  belongs_to :vehicle
  has_one :customer, through: :vehicle
  has_one :summary
  belongs_to :mechanic, optional: true
  has_many :service_parts
  has_many :parts, through: :service_parts
  has_and_belongs_to_many :tags, join_table: :service_tags
  has_many :reviews, as: :reviewable

  def ensure_status_values
    self.status ||= 'pending'
  end

  def sumarize_record
    if self.summary.present?
      self.summary.update(summary_text: self.internal_notes, customer_notes: '', completed_at: Time.current)
    else
      Summary.create(record_id: self.id, summary_text: self.internal_notes, customer_notes: '', completed_at: Time.current)
    end
  end
end
