class GamePlayChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def receive(data)
    if data['board_id'] && data['column_index']
      board = Board.find(data['board_id'])

      PlayGameColumn.call(board, data['column_index']) if
        board.current_player == current_user
    end
  end
end