class Customer < ApplicationRecord
    validates :name, :phone, :email, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
