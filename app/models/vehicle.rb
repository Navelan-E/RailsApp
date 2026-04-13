class Vehicle < ApplicationRecord
  belongs_to :customer
  has_many :records
  has_many :comments, as: :commentable
end
