class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable
    validates :name, :phone, :email, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    has_many :vehicles
  scope :vehicle_plate, ->(plate) {
    joins(:vehicles)
      .where("vehicles.number_plate ILIKE ?", "%#{plate}%")
  }

  def self.ransackable_attributes(_auth_object = nil)
    [ "email", "id", "name", "phone" ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["vehicles"]
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:vehicle_plate]
  end
end
