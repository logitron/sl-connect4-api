require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:auth_command) { double(:auth_command) }
  let(:current_user) { FactoryBot.create(:user) }

  before do
    allow(AuthorizeApiRequest).to receive(:call)
      .and_return(auth_command)

    allow(auth_command).to receive(:result)
      .and_return(current_user)
  end

  describe '#show' do
    context 'when user provides an id' do
      let(:user) { FactoryBot.create(:user) }

      before do
        get "/users/#{user.id}"
      end

      it 'returns status ok' do
        expect(response.status).to eq(200)
      end

      it 'returns the user' do
        response_body = JSON.parse(response.body)

        expect(response_body['id']).to eq(user.id)
        expect(response_body['name']).to eq(user.name)
        expect(response_body['email']).to eq(user.email)
        expect(response_body['google_id']).to eq(user.google_id)
      end
    end

    context 'when user requests current' do
      before do
        get "/users/current"
      end

      it 'returns status ok' do
        expect(response.status).to eq(200)
      end

      it 'returns current user' do
        response_body = JSON.parse(response.body)

        expect(response_body['id']).to eq(current_user.id)
        expect(response_body['name']).to eq(current_user.name)
        expect(response_body['email']).to eq(current_user.email)
        expect(response_body['google_id']).to eq(current_user.google_id)
      end
    end
  end
end
