class ServiceTag < ApplicationRecord
  validates :record_id, :tag_id, presence: true
  validates :record_id, uniqueness: { scope: :tag_id, message: "Tag already added to this record" }
  belongs_to :record
  belongs_to :tag


end
