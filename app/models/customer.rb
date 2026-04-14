class Customer < ApplicationRecord
    def self.select_or_create(name, phone, email)
        customer = Customer.find_by(phone: phone)
        unless customer
            customer = Customer.create(name: name, phone: phone, email: email)
        end
        customer
    end
end
