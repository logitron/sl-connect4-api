require 'rails_helper'

RSpec.describe BoardsController, type: :request do
  before do
    allow(AuthorizeApiRequest).to receive(:call)
      .and_return(auth_command)

    allow(auth_command).to receive(:result)
      .and_return(current_user)
  end

  describe '#create' do
    let(:auth_command) { double(:auth_command) }
    let(:current_user) { FactoryBot.create(:user) }

    before do
      post '/boards'
    end

    it 'responds with status created' do
      expect(response.status).to eq(201)
    end

    it 'creates new board' do
      expect(Board.count).to eq(1)
    end

    it 'responds with created board' do
      board = Board.first
      response_body = JSON.parse(response.body)

      expect(response_body['primary_player_id']).to eq(board.primary_player.id)
      expect(response_body['secondary_player_id']).to be_nil
      expect(response_body['current_player_id']).to be_nil
      expect(response_body['winner_id']).to be_nil
      expect(response_body['loser_id']).to be_nil
      expect(response_body['is_game_over']).to be false
      expect(response_body['column_heights']).to eq([0, 0, 0, 0, 0, 0, 0])
      expect(response_body['move_count']).to eq(0)
      expect(response_body['board']).to eq([
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]])
    end
  end
end
