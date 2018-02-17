require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render :text => Faker::RickAndMorty.quote
    end
  end

  describe 'Authorization' do
    context 'when request has authorization header' do
      let(:validator) { double(:validator) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when authorization header is valid' do
        google_id = Faker::Hipster.word

        payload = {
          'sub' => google_id,
          'name' => Faker::Hipster.word,
          'email' => Faker::Internet.email
        }

        before do
          allow(validator).to receive(:check).and_return(payload)

          request.headers['Authorization'] = 'Engineering Champion'
          get :index
        end

        it 'sets current user' do
          user = User.find_by google_id: google_id

          expect(assigns(:current_user)).to eq(user)
        end

        it 'responds with status ok' do
          expect(response.status).to eq(200)
        end
      end

      context 'when authorization header is invalid' do
        let(:validation_error) { GoogleIDToken::ValidationError.new }

        before do
          allow(validator).to receive(:check).and_raise(validation_error)

          request.headers['Authorization'] = 'Engineering Loser'
          get :index
        end

        it 'responds with status unauthorized' do
          expect(response.status).to eq(401)
        end
  
        it 'responds with error text' do
          json_response_body = JSON.parse(response.body)
  
          expect(json_response_body['error']).to eq('Not Authorized')
        end
      end
    end

    context 'when request has no authorization header' do
      before do
        request.headers['Authorization'] = ''
        get :index
      end
  
      it 'responds with status not found' do
        expect(response.status).to eq(401)
      end

      it 'responds with error text' do
        json_response_body = JSON.parse(response.body)

        expect(json_response_body['error']).to eq('Not Authorized')
      end
    end
  end
end
