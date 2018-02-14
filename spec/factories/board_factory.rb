FactoryBot.define do
  factory :board do
    association :primary_player, factory: :user
    association :secondary_player, factory: :user
    current_player { primary_player }
    move_count { Faker::Number.between(0, 42) }
  end
end