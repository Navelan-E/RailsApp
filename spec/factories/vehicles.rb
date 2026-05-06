FactoryBot.define do
  factory :vehicle do
    model { "Honda" }
    number_plate { "TN22AB1234" }
    association :customer
  end
end
