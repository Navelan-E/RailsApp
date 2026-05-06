FactoryBot.define do
  factory :review do
    content { "Great service" }
    association :customer

    trait :for_mechanic do
      association :reviewable, factory: :mechanic
    end

    trait :for_vehicle do
      association :reviewable, factory: :vehicle
    end

    trait :for_record do
      association :reviewable, factory: :record
    end
  end
end
