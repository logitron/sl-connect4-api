class User < ApplicationRecord
  has_many :primary_boards, :class_name => 'Board', :foreign_key => 'primary_player_id'
  has_many :secondary_boards, :class_name => 'Board', :foreign_key => 'secondary_player_id'
end
