class Mechanic < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable
    validates :name, :experience, presence: true
    before_validation :ensure__values
    has_many :records, dependent: :nullify
    has_many :reviews, as: :reviewable, dependent: :destroy

    def ensure__values
        if self.name.present?
            self.name = self.name.strip.downcase
        end
    end

    def self.ransackable_attributes(_auth_object = nil)
    [ "email", "experience", "id", "name" ]
    end
end
