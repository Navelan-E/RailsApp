class Mechanic < ApplicationRecord
    validates :name, :experience, presence: true
    before_validation :ensure__values
    
    has_many :records
    has_many :comments, as: :commentable

    def ensure__values
        self.experience ||= 0
        if self.name.present?
            self.name = self.name.strip.downcase
        end
    end
end
