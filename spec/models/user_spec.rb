require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:primary_board) { FactoryBot.create(:board) }

  subject { described_class.new }

  it { is_expected.to have_many(:primary_boards).class_name('Board') }
  it { is_expected.to have_many(:secondary_boards).class_name('Board') }
end
