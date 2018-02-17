class BoardsController < ApplicationController
  def create
    board = Board.create!(primary_player: @current_user)

    render json: board, status: :created
  end

  def update
    board = Board.find(params[:id])

    if board.secondary_player
      render status: :conflict
    else
      board.update(join_board_params)
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
end
