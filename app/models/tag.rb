class Tag < ApplicationRecord
  has_and_belongs_to_many :records, join_table: :service_tags
end
