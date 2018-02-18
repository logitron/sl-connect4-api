class GamePlayChannel < ApplicationCable::Channel
  def subscribed
    reject unless is_user_allowed_access? params['board_id']

    stream_from "board_#{params['board_id']}"
  end

  def receive(data)
    if data['board_id'] && data['column_index']
      board = Board.find(data['board_id'])

      PlayGameColumn.call(board, data['column_index']) if
        board.current_player == current_user
    end
  end

  private

  def is_user_allowed_access? board_id
    board = Board.find(board_id)

    return (board.primary_player == current_user || board.secondary_player == current_user)
  end
end