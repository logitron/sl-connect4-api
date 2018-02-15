require 'rails_helper'

RSpec.describe AiService, type: :service do
  let!(:board) { FactoryBot.create(:board, move_count: 0) }
  let(:board_service) { BoardService.new board }

  subject { described_class.new board_service }

  describe '#get_best_move' do
    context 'when opponent can win next move' do
      before do
        board.move_count = 5
        board.column_heights[0] = 2
        board.column_heights[1] = 1
        board.column_heights[3] = 1
        board.column_heights[5] = 1
        board.board = [
          [1, 2, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0]
        ]
      end

      it 'returns column index of best move' do
        column_index = subject.get_best_move
        expect(column_index).to eq(2)
      end
    end

    context 'when AI can win next move' do
      before do
        board.move_count = 8
        board.column_heights[0] = 2
        board.column_heights[1] = 2
        board.column_heights[2] = 3
        board.column_heights[5] = 1
        board.board = [
          [2, 1, 0, 0, 0, 0],
          [2, 1, 0, 0, 0, 0],
          [2, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0]
        ]
      end

      it 'returns column index of best move' do
        column_index = subject.get_best_move
        expect(column_index).to eq(3)
      end
    end
  end

  describe '#get_weak_move' do
    context 'when opponent can win next move' do
      before do
        board.move_count = 5
        board.column_heights[0] = 2
        board.column_heights[1] = 1
        board.column_heights[3] = 1
        board.column_heights[5] = 1
        board.board = [
          [1, 2, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0]
        ]
      end

      it 'returns column index of weak move' do
        column_index = subject.get_weak_move
        expect(column_index).to eq(2)
      end
    end

    context 'when AI can win next move' do
      before do
        board.move_count = 8
        board.column_heights[0] = 2
        board.column_heights[1] = 2
        board.column_heights[2] = 3
        board.column_heights[5] = 1
        board.board = [
          [2, 1, 0, 0, 0, 0],
          [2, 1, 0, 0, 0, 0],
          [2, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0]
        ]
      end

      it 'returns column index of weak move' do
        column_index = subject.get_weak_move
        expect(column_index).to eq(3)
      end
    end
  end
end
