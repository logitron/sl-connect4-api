require 'rails_helper'

RSpec.describe PlayGameColumn, type: :command do
  describe '#call' do
    let(:board) do
      FactoryBot::create(:board,
        move_count: 10,
        column_heights: [6, 1, 1, 0, 0, 1, 1],
        board: [
          [1, 2, 1, 2, 1, 2],
          [1, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0]
        ])
    end

    context 'when move is invalid' do
      let(:column_index) { 0 }
      let(:result) { PlayGameColumn.call(board, column_index) }

      it 'is a failure' do
        expect(result).to be_failure
      end

      it 'broadcasts failure to current player' do
        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.current_player,
            status: :invalid_move,
            column_index: column_index)

        result
      end
    end

    context 'when move is valid' do
      let(:column_index) { 1 }
      let(:result) { PlayGameColumn.call(board, column_index) }

      it 'is successful' do
        expect(result).to be_success
      end

      it 'plays the move' do
        expect_any_instance_of(BoardService).to receive(:play)
          .with(column_index)

        result
      end

      it 'broadcasts move to all players' do
        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.primary_player,
            status: :valid_move,
            column_index: column_index)

        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.secondary_player,
            status: :valid_move,
            column_index: column_index)

        result
      end

      it 'saves the board' do
        actual_board = Board.find(board.id)

        expect(actual_board.move_count).to eq(board.move_count)
        expect(actual_board.column_heights).to eq(board.column_heights)
        expect(actual_board.board).to eq(board.board)
      end
    end

    context 'when move is a winning move' do
      let(:column_index) { 3 }
      let(:result) { PlayGameColumn.call(board, column_index) }

      it 'is successful' do
        expect(result).to be_success
      end

      it 'broadcasts winning move to all players' do
        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.primary_player,
            status: :winning_move,
            is_winner: true,
            column_index: column_index)

        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.secondary_player,
            status: :winning_move,
            is_winner: false,
            column_index: column_index)

        result
      end

      it 'plays move' do
        expect_any_instance_of(BoardService).to receive(:play)
          .with(column_index)

        result
      end

      it 'sets winner on board' do
        result
        expect(board.winner).to eq(board.primary_player)
      end

      it 'sets loser on board' do
        result
        expect(board.loser).to eq(board.secondary_player)
      end

      it 'sets game over on board' do
        result
        expect(board.is_game_over).to be true
      end

      it 'saves the board' do
        actual_board = Board.find(board.id)

        expect(actual_board.winner).to eq(board.winner)
        expect(actual_board.loser).to eq(board.loser)
        expect(actual_board.is_game_over).to eq(board.is_game_over)

        expect(actual_board.move_count).to eq(board.move_count)
        expect(actual_board.column_heights).to eq(board.column_heights)
        expect(actual_board.board).to eq(board.board)
      end
    end

    context 'when move results in tie' do
      let(:board) do
        FactoryBot::create(:board,
          move_count: 41,
          column_heights: [6, 6, 6, 6, 6, 5, 6],
          board: [
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 2],
            [2, 1, 2, 1, 2, 1],
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 0],
            [1, 2, 1, 2, 1, 2]
          ])
      end
      let(:column_index) { 5 }
      let(:result) { PlayGameColumn.call(board, column_index) }

      it 'is successful' do
        expect(result).to be_success
      end

      it 'broadcasts tie to all players' do
        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.primary_player,
            status: :tie_move,
            column_index: column_index)

        expect(GamePlayChannel).to receive(:broadcast_to)
          .with(
            board.secondary_player,
            status: :tie_move,
            column_index: column_index)

        result
      end

      it 'sets game over on board' do
        result
        expect(board.is_game_over).to be true
      end

      it 'saves the board' do
        actual_board = Board.find(board.id)

        expect(actual_board.is_game_over).to eq(board.is_game_over)

        expect(actual_board.move_count).to eq(board.move_count)
        expect(actual_board.column_heights).to eq(board.column_heights)
        expect(actual_board.board).to eq(board.board)
      end
    end
  end
end
