class Record < ApplicationRecord

  has_one :customer, through: :vehicle
  has_one :summary
  has_many :parts, through: :service_parts
  has_and_belongs_to_many :tags, through: :service_tags
  has_many :comments, as: :commentable
  
end
