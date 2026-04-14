class Record < ApplicationRecord
  validates :vehicle_id, :mechanic_id, :status, :internal_notes, presence: true
  before_validation :ensure_status_values
  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed' }
  has_one :customer, through: :vehicle
  has_one :summary
  has_many :parts, through: :service_parts
  has_and_belongs_to_many :tags, through: :service_tags
  has_many :comments, as: :commentable
  
  def ensure_status_values
    self.status ||= 'pending'
  end
end
