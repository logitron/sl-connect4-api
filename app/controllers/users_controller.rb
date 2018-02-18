class UsersController < ApplicationController
  def show
    if (params[:id] == 'current')
      render json: @current_user, status: :ok
    else
      render json: User.find(params[:id]), status: :ok
    end
  end
end
