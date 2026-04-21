class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true, optional: true
  belongs_to :customer
  validates :content, presence: true
end
