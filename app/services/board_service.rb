class BoardService
  MAX_WIDTH = 7.freeze
  MAX_HEIGHT = 6.freeze

  def initialize(board)
    @board = board
  end

  def is_playable? column_index
    @board.column_heights[column_index] < MAX_HEIGHT
  end

  def is_winning_move? column_index
    row_index = @board.column_heights[column_index]

    return true if @board.column_heights[column_index] >= 3 &&
       @board.board[column_index][row_index - 1] == current_player_token &&
       @board.board[column_index][row_index - 2] == current_player_token &&
       @board.board[column_index][row_index - 3] == current_player_token

    for diagonal_y in -1..1 do
      surrounding_stone_count = 0

      for diagonal_x in [-1, 1] do
        x = column_index + diagonal_x
        y = row_index + (diagonal_x * diagonal_y)

        while x >= 0 && x < MAX_WIDTH &&
              y >= 0 && y < MAX_HEIGHT &&
              @board.board[x][y] == current_player_token do
          x += diagonal_x
          y += (diagonal_x * diagonal_y)
          surrounding_stone_count += 1
        end
      end

      return true if surrounding_stone_count >= 3
    end

    false
  end

  def move_count
    @board.move_count
  end

  def play column_index
    return unless is_playable? column_index

    row_index = @board.column_heights[column_index]

    @board.board[column_index][row_index] = current_player_token
    @board.column_heights[column_index] += 1
    @board.move_count += 1

    @board.current_player = (@board.current_player == @board.primary_player) ?
      @board.secondary_player : @board.primary_player
  end

  def reset
    @board.restore_attributes
  end

  private

  def current_player_token
    1 + (move_count % 2)
  end
end
