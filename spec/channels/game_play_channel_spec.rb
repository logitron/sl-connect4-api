require 'rails_helper'

class TestConnection
  attr_reader :identifiers, :logger

  def initialize(identifiers_hash = {})
    @identifiers = identifiers_hash.keys
    @logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(StringIO.new))

    # This is an equivalent of providing `identified_by :identifier_key` in ActionCable::Connection::Base subclass
    identifiers_hash.each do |identifier, value|
      define_singleton_method(identifier) do
        value
      end
    end
  end
end

RSpec.describe GamePlayChannel, type: :channel do
  subject { described_class.new(connection, {}) }

  let(:current_user) { FactoryBot.create(:user) }
  let(:connection) { TestConnection.new(current_user: current_user) }

  describe '#receive' do
    context 'when called with no board_id and column_index' do
      let(:data) { {} }

      it 'does not make a play' do
        expect(PlayGameColumn).not_to receive(:call)

        subject.receive data
      end
    end

    context 'when called with board_id and column_indx' do
      context 'when current user is not current player' do
        let(:board) { FactoryBot.create(:board, move_count: 0) }
        let(:data) do
          {
            'board_id' => board.id,
            'column_index' => 2
          }
        end

        it 'makes a play' do
          expect(PlayGameColumn).not_to receive(:call)

          subject.receive data
        end
      end

      context 'when current user is current player' do
        context 'when opponent is ai' do
          context 'when ai is weak' do
            let(:board) do
              FactoryBot.create(:board,
                current_player: current_user,
                is_opponent_ai: true,
                move_count: 0)
            end
    
            let(:data) do
              {
                'board_id' => board.id,
                'column_index' => 2,
                'ai_intelligence' => 'weak'
              }
            end

            let(:weak_column_index) { 6 }

            before do
              allow_any_instance_of(AiService).to receive(:get_weak_move)
                .and_return(weak_column_index)
            end

            it 'makes move followed by weak move by ai' do
              expect(PlayGameColumn).to receive(:call)
                .with(board, data['column_index'])

              expect(PlayGameColumn).to receive(:call)
                .with(board, weak_column_index)

              subject.receive data
            end
          end

          context 'when ai is strong' do
            let(:board) do
              FactoryBot.create(:board,
                current_player: current_user,
                is_opponent_ai: true,
                move_count: 0)
            end
    
            let(:data) do
              {
                'board_id' => board.id,
                'column_index' => 2
              }
            end

            let(:best_column_index) { 5 }

            before do
              allow_any_instance_of(AiService).to receive(:get_best_move)
                .and_return(best_column_index)
            end

            it 'makes move followed by best move by ai' do
              expect(PlayGameColumn).to receive(:call)
                .with(board, data['column_index'])

              expect(PlayGameColumn).to receive(:call)
                .with(board, best_column_index)

              subject.receive data
            end
          end
        end

        context 'when opponent is not ai' do
          let(:board) do
            FactoryBot.create(:board,
              current_player: current_user,
              is_opponent_ai: false,
              move_count: 0)
          end
  
          let(:data) do
            {
              'board_id' => board.id,
              'column_index' => 2
            }
          end

          it 'makes a play' do
            expect(PlayGameColumn).to receive(:call)
              .with(board, data['column_index'])
  
            subject.receive data
          end

          it 'does not make any other plays' do
            expect(PlayGameColumn).to receive(:call).once

            subject.receive data
          end
        end
      end
    end
  end
end