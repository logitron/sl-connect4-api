class BoardsController < ApplicationController
  def create
    current_player = params[:is_opponent_ai] ? @current_user : nil
    board = Board.create!(
      primary_player: @current_user,
      is_opponent_ai: params[:is_opponent_ai],
      current_player: current_player)

    ActionCable.server.broadcast 'joinable_games',
      game: board,
      is_joinable: true unless board.is_opponent_ai

    render json: board, status: :created
  end

  def index
    board_params = nil

    case params[:type]
      when 'joinable'
        board_params = joinable_board_params
      when 'created'
        board_params = created_board_params
    end

    joinable_boards = Board.where(board_params)
    render json: joinable_boards, status: :ok, include: :primary_player
  end

  def update
    board = Board.find(params[:id])

    if board.primary_player == @current_user || board.is_opponent_ai
      render status: :bad_request
    elsif board.secondary_player
      render status: :conflict
    else
      board.update(join_board_params)
      ActionCable.server.broadcast 'joinable_games', game: board, is_joinable: false
    end
  end

  private

  def join_board_params
    board = Board.find(params[:id])
    secondary_player = User.find(params[:secondary_player_id])

    {
      secondary_player: secondary_player,
      current_player: board.primary_player
    }
  end

  def joinable_board_params
    [
      'primary_player_id != ? AND secondary_player_id IS ? AND is_opponent_ai = ?',
      @current_user.id, nil, false
    ]
  end

  def created_board_params
    { primary_player_id: @current_user.id }
  end
end
