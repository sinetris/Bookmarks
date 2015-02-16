FactoryGirl.define do
  factory :bookmark do
    sequence(:url) { |n| "http://example.com/url#{n}" }
    description "a description"
    user
  end
end
