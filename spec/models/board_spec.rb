require 'rails_helper'

RSpec.describe Board, type: :model do
  subject { described_class.new }

  let!(:primary_user) { FactoryBot.create(:user) }
  let!(:secondary_user) { FactoryBot.create(:user) }

  before do
    subject.primary_player = primary_user
    subject.current_player = primary_user
    subject.column_heights = [0, 0, 0, 0, 0, 0, 0]
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid column height' do
    subject.column_heights = [0, 0, 0, 0, 0, 0, 0, 0]
    expect(subject).not_to be_valid
  end

  it 'is invalid column height' do
    subject.column_heights = [0, 0, 0, 0, 0, 0]
    expect(subject).not_to be_valid
  end

  it 'is invalid primary player' do
    subject.primary_player = nil
    expect(subject).not_to be_valid
  end
end
