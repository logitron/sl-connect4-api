require 'rails_helper'

RSpec.describe BoardsController, type: :request do
  let(:auth_command) { double(:auth_command) }
  let(:current_user) { FactoryBot.create(:user) }

  before do
    allow(AuthorizeApiRequest).to receive(:call)
      .and_return(auth_command)

    allow(auth_command).to receive(:result)
      .and_return(current_user)
  end

  describe '#create' do
    before do
      expect(ActionCable.server).to receive(:broadcast)
        .with('joinable_games',
          game: an_instance_of(Board),
          is_joinable: true)

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

  describe '#update' do
    context 'when user joins a joinable game' do
      let(:board) do
        FactoryBot.create(:board,
          secondary_player: nil,
          current_player: nil)
      end
      let(:board_id) { board.id }
      let(:secondary_player) { FactoryBot.create(:user) }
      let(:params) { { secondary_player_id: secondary_player.id } }

      before do
        expect(ActionCable.server).to receive(:broadcast)
          .with('joinable_games',
            game: board,
            is_joinable: false)

        put "/boards/#{board_id}", params: params
      end

      it 'responds with status no content' do
        expect(response.status).to eq(204)
      end

      it 'associates user to the board' do
        board = Board.find(board_id)

        expect(board.secondary_player).to eq(secondary_player)
        expect(board.current_player).to eq(board.primary_player)
      end
    end

    context 'when user joins a non-joinable game' do
      let(:board) do
        FactoryBot.create(:board)
      end
      let(:board_id) { board.id }
      let(:third_player) { FactoryBot.create(:user) }
      let(:params) { { secondary_player_id: third_player.id } }

      before { put "/boards/#{board_id}", params: params }

      it 'responds with status conflict' do
        expect(response.status).to eq(409)
      end

      it 'does not associate user to the board' do
        board = Board.find(board_id)

        expect(board.secondary_player).not_to eq(third_player)
      end
    end

    context 'when user tries to join her own game' do
      let(:board) do
        FactoryBot.create(:board,
          primary_player: current_user,
          secondary_player: nil,
          current_player: nil)
      end
      let(:board_id) { board.id }
      let(:secondary_player) { board.primary_player }
      let(:params) { { secondary_player_id: secondary_player.id } }

      before { put "/boards/#{board_id}", params: params }

      it 'responds with status bad request' do
        expect(response.status).to eq(400)
      end
    end
  end
end
