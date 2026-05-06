FactoryBot.define do
  factory :customer do
    name {"test"}
    sequence (:email) { |n| "customer#{n}.@gmail.com"}
    phone { "1234567890" }
    password { "12345678" }
  end
end
