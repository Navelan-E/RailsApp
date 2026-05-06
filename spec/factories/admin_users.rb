FactoryBot.define do
  factory :admin_user do
      sequence (:email) { |n| "admin#{n}.@gmail.com"}
      password { "12345678" }
  end
end
