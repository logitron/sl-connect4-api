class Board < ApplicationRecord
  validates :column_heights, length: { minimum: 7, maximum: 7 }

  belongs_to :primary_player, :class_name => 'User'
  belongs_to :secondary_player, :class_name => 'User', optional: true
  belongs_to :current_player, :class_name => 'User', optional: true
  belongs_to :winner, :class_name => 'User', optional: true
  belongs_to :loser, :class_name => 'User', optional: true
end
