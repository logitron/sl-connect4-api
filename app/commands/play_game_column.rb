class PlayGameColumn
  prepend SimpleCommand

  def initialize(board, column_index)
    @board = board
    @column_index = column_index
  end

  def call
    board_service = BoardService.new @board

    unless board_service.is_playable? @column_index
      broadcast_move :invalid_move
      return errors.add(:invalid_move, 'Invalid Move')
    end

    if board_service.is_winning_move? @column_index
      @board.winner = @board.current_player
      @board.loser = not_current_player
      @board.is_game_over = true

      broadcast_move :winning_move
    elsif board_service.is_tie_move? @column_index
      @board.is_game_over = true

      broadcast_move :tie_move
    else
      broadcast_move :valid_move
    end

    board_service.play @column_index
    @board.save
  end

  private

  def not_current_player
    @board.current_player == @board.primary_player ?
        @board.secondary_player : @board.primary_player
  end

  def broadcast_move move_type
    GamePlayChannel.broadcast_to(
        "board_#{@board.id}",
        move_type: move_type,
        played_by: @board.current_player,
        column_index: @column_index)
  end
end