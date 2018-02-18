class BoardsController < ApplicationController
  def create
    board = Board.create!(primary_player: @current_user)
    ActionCable.server.broadcast 'joinable_games', game: board, is_joinable: true

    render json: board, status: :created
  end

  def index
    joinable_boards = Board.where(index_board_params)
    render json: joinable_boards, status: :ok
  end

  def update
    board = Board.find(params[:id])

    if board.primary_player == @current_user
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

  def index_board_params
    params.permit(:secondary_player)
  end
end
