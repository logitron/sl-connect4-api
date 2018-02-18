class GamePlayChannel < ApplicationCable::Channel
  def subscribed
    reject unless is_user_allowed_access? params['board_id']

    stream_from "board_#{params['board_id']}"
  end

  def receive(data)
    if data['board_id'] && data['column_index']
      board = Board.find(data['board_id'])

      if board.current_player == current_user
        PlayGameColumn.call(board, data['column_index'])

        if board.is_opponent_ai
          board.reload
          board_service = BoardService.new board
          ai_service = AiService.new board_service
          
          column_index = data['ai_intelligence'] != 'weak' ?
            ai_service.get_best_move : ai_service.get_weak_move

          PlayGameColumn.call(board, column_index)
        end
      end
    end
  end

  private

  def is_user_allowed_access? board_id
    board = Board.find(board_id)

    return (board.primary_player == current_user || board.secondary_player == current_user)
  end
end