class Part < ApplicationRecord
  has_many :service_parts
  has_many :records, through: :service_parts
end
