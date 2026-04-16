class Mechanic < ApplicationRecord
    validates :name, :experience, presence: true
    before_validation :ensure__values
    has_many :records
    has_many :reviews, as: :reviewable

    def ensure__values
        if self.name.present?
            self.name = self.name.strip.downcase
        end
    end
end
