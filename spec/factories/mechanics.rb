FactoryBot.define do
  factory :mechanic do
      name {"test"}
      sequence (:email) { |n| "mechanic#{n}.@gmail.com"}
      experience { 1 }
      password { "12345678" }
  end
end
