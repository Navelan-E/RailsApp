class Vehicle < ApplicationRecord
  validates :number_plate, :model, :customer_id, presence: true
  belongs_to :customer
  has_many :records
  has_many :comments, as: :commentable

end
