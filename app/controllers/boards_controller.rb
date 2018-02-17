class BoardsController < ApplicationController
  def create
    board = Board.create!(primary_player: @current_user)

    render json: board, status: :created
  end
end
