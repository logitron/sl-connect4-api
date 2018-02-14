FactoryBot.define do
  factory :user do
    google_id { Faker::Number.number(10) }
    email { Faker::Internet.email }
    name { Faker::RickAndMorty.character }
  end
end