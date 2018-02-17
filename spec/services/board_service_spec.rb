require 'rails_helper'

RSpec.describe BoardService, type: :service do
  let(:board) { FactoryBot.create(:board, move_count: 0) }

  subject { described_class.new board }

  describe '#is_playable?' do
    let(:board) do
      FactoryBot.create(:board,
        column_heights: [0, 0, 0, 6, 0, 0, 0])
    end

    context 'when column height is at max' do
      it 'returns false' do
        is_playable = subject.is_playable? 3
        expect(is_playable).to be false
      end
    end

    context 'when column height is not at max' do
      it 'returns true' do
        is_playable = subject.is_playable? 2
        expect(is_playable).to be true
      end
    end
  end

  describe '#is_winning_move?' do
    context 'when move is a winning move' do
      context 'when horizontal win' do
        let(:board) do
          FactoryBot.create(:board,
            move_count: 6,
            column_heights: [2, 1, 1, 0, 0, 1, 1],
            board: [
              [1, 2, 0, 0, 0, 0],
              [1, 0, 0, 0, 0, 0],
              [1, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [2, 0, 0, 0, 0, 0],
              [2, 0, 0, 0, 0, 0]
            ])
        end

        it 'returns true' do
          expect(subject.is_winning_move? 3).to be true
        end
      end

      context 'when vertical win' do
        let(:board) do
          FactoryBot.create(:board,
            move_count: 6,
            column_heights: [3, 0, 0, 0, 1, 1, 1],
            board: [
              [1, 1, 1, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [2, 0, 0, 0, 0, 0],
              [2, 0, 0, 0, 0, 0],
              [2, 0, 0, 0, 0, 0]
            ])
        end

        it 'returns true' do
          expect(subject.is_winning_move? 0).to be true
        end
      end

      context 'when back-diagonal win' do
        let(:board) do
          FactoryBot.create(:board,
            move_count: 12,
            column_heights: [3, 3, 2, 2, 2, 0, 0],
            board: [
              [2, 2, 2, 0, 0, 0],
              [2, 2, 1, 0, 0, 0],
              [2, 1, 0, 0, 0, 0],
              [1, 1, 0, 0, 0, 0],
              [1, 1, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0]
            ])
        end

        it 'returns true' do
          expect(subject.is_winning_move? 0).to be true
        end
      end

      context 'when forward-diagonal win' do
        let(:board) do
          FactoryBot.create(:board,
            move_count: 12,
            column_heights: [2, 2, 2, 3, 3, 0, 0],
            board: [
              [1, 1, 0, 0, 0, 0],
              [1, 1, 0, 0, 0, 0],
              [2, 1, 0, 0, 0, 0],
              [2, 2, 1, 0, 0, 0],
              [2, 2, 2, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0]
            ])
        end

        it 'returns true' do
          expect(subject.is_winning_move? 4).to be true
        end
      end
    end

    context 'when move is not a winning move' do
      let(:board) do
        FactoryBot.create(:board,
          move_count: 6,
          column_heights: [2, 1, 1, 0, 0, 1, 1],
          board: [
            [1, 2, 0, 0, 0, 0],
            [1, 0, 0, 0, 0, 0],
            [1, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0],
            [2, 0, 0, 0, 0, 0],
            [2, 0, 0, 0, 0, 0]
          ])
      end

      it 'returns false' do
        expect(subject.is_winning_move? 0).to be false
      end
    end
  end

  describe '#is_tie_move?' do
    context 'when move results in a tie' do
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
  
      it 'returns true' do
        expect(subject.is_tie_move? 5).to eq true
      end
    end
    
    context 'when move does not result in tie' do
      let(:board) do
        FactoryBot::create(:board,
          move_count: 40,
          column_heights: [6, 6, 6, 5, 6, 5, 6],
          board: [
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 2],
            [2, 1, 2, 1, 2, 0],
            [1, 2, 1, 2, 1, 2],
            [1, 2, 1, 2, 1, 0],
            [1, 2, 1, 2, 1, 2]
          ])
      end
  
      it 'returns false' do
        expect(subject.is_tie_move? 3).to eq false
      end
    end
  end

  describe '#reset' do
    let(:original_board) do
      [
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]
      ]
    end
    let(:board) { FactoryBot.create(:board, move_count: 0, board: original_board) }

    before do
      subject.play 0
      subject.reset
    end

    it 'resets the board' do
      expect(board.board).to eq(original_board)
    end

    it 'resets the move count' do
      expect(board.move_count).to eq(0)
    end
  end

  describe '#move_count' do
    it 'returns the number of moves played' do
      moves = subject.move_count

      expect(moves).to eq(board.move_count)
    end
  end

  describe '#play' do
    context 'when column is playable' do
      context 'when current player is primary' do
        before do
          board.current_player = board.primary_player
          subject.play 0
        end

        it 'updates current player to secondary' do
          expect(board.current_player).to eq(board.secondary_player)
        end

        it 'updates column on board' do
          expect(board.board[0][0]).to eq(1)
        end
  
        it 'updates height of column' do
          expect(board.column_heights[0]).to eq(1)
        end
  
        it 'updates move count' do
          expect(board.move_count).to eq(1)
        end
      end

      context 'when current player is secondary' do
        before do
          board.current_player = board.secondary_player
          subject.play 0
        end

        it 'updates current player to primary' do
          expect(board.current_player).to eq(board.primary_player)
        end
      end
    end

    context 'when column is not playable' do
      before do
        board.column_heights = [0, 0, 0, 6, 0, 0, 0]
        board.current_player = board.primary_player

        subject.play 3
      end

      it 'updates nothing' do
        expect(Board.find(board.id).current_player).to eq(board.primary_player)
        expect(Board.find(board.id).board[0][0]).to eq(0)
        expect(Board.find(board.id).column_heights[0]).to eq(0)
        expect(Board.find(board.id).move_count).to eq(0)
      end
    end
  end
end
