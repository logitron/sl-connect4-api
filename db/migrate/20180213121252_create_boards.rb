class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.integer :primary_player_id, null: false
      t.integer :secondary_player_id, null: true
      t.integer :current_player_id, null: true
      t.integer :winner_id, null: true
      t.integer :loser_id, null: true
      t.boolean :is_opponent_ai, null: false, default: false
      t.boolean :is_game_over, null: false, default: false
      t.json :board, default: [
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]
      t.integer :column_heights, array: true, default: [0, 0, 0, 0, 0, 0, 0]
      t.integer :move_count, default: 0

      t.timestamps
    end
  end
end
