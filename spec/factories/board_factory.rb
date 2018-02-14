FactoryBot.define do
  factory :board do
    association :primary_player, factory: :user
    association :secondary_player, factory: :user
    current_player { primary_player }
  end
end