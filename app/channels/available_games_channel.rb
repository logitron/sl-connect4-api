class AvailableGamesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'joinable_games'
  end
end