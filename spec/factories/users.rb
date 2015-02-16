FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "username#{n}" }
    password "password"
    factory :admin do
      after(:create) {|user| user.add_role(:admin)}
    end
  end
end
