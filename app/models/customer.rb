class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable
    validates :name, :phone, :email, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    has_many :vehicles
  def self.ransackable_attributes(_auth_object = nil)
    [ "email", "id", "name", "phone" ]
  end
end
