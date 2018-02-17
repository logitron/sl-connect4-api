class PlayGameColumn
  prepend SimpleCommand

  def initialize(board, column_index)
    @board = board
    @column_index = column_index
  end

  def call
    board_service = BoardService.new @board

    unless board_service.is_playable? @column_index
      broadcast_invalid_move
      return errors.add(:invalid_move, 'Invalid Move')
    end

    if board_service.is_winning_move? @column_index
      @board.winner = @board.current_player
      @board.loser = not_current_player
      @board.is_game_over = true

      broadcast_winning_move @board.current_player, true
      broadcast_winning_move not_current_player, false
    elsif board_service.is_tie_move? @column_index
      @board.is_game_over = true

      broadcast_tie_move @board.primary_player
      broadcast_tie_move @board.secondary_player
    else
      broadcast_valid_move @board.primary_player
      broadcast_valid_move @board.secondary_player
    end

    board_service.play @column_index
    @board.save
  end

  private

  def not_current_player
    @board.current_player == @board.primary_player ?
        @board.secondary_player : @board.primary_player
  end

  def broadcast_invalid_move
    GamePlayChannel.broadcast_to(
        @board.current_player,
        status: :invalid_move,
        column_index: @column_index)
  end

  def broadcast_valid_move player
    GamePlayChannel.broadcast_to(
      player,
      status: :valid_move,
      column_index: @column_index)
  end

  def broadcast_winning_move player, is_winner
    GamePlayChannel.broadcast_to(
      player,
      status: :winning_move,
      is_winner: is_winner,
      column_index: @column_index)
  end

  def broadcast_tie_move player
    GamePlayChannel.broadcast_to(
      player,
      status: :tie_move,
      column_index: @column_index)
  end
end