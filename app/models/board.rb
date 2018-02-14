class Board < ApplicationRecord
  validates :column_heights, length: { minimum: 6, maximum: 6 }

  belongs_to :primary_player, :class_name => 'User'
  belongs_to :secondary_player, :class_name => 'User'
  belongs_to :current_player, :class_name => 'User'
end
