class Mechanic < ApplicationRecord
    has_many :records
    has_many :comments, as: :commentable
end
