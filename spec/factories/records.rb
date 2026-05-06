FactoryBot.define do
  factory :record do
    status { "pending" }
    internal_notes { "Test notes" }
    association :vehicle
  end
end
