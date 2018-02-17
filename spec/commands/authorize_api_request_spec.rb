require 'rails_helper'

RSpec.describe AuthorizeApiRequest, type: :command do
  describe '#call' do
    let(:validator) { double(:validator) }

    token            = Faker::Hipster.word
    authorization    = "#{Faker::Hipster.word} #{token}"
    email            = Faker::Internet.email
    google_client_id = Faker::Hipster.word
    google_id        = Faker::Hipster.word
    name             = Faker::Hipster.word

    before do
      allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_ID').and_return(google_client_id)
    end

    context 'when token is present' do
      headers = { 'Authorization' => authorization }

      context 'when token is valid' do
        payload = { 'sub' => google_id, 'name' => name, 'email' => email }

        before do
          allow(validator).to receive(:check).with(token, google_client_id).and_return(payload)
        end

        context 'when user exists in database' do
          let!(:user) { FactoryBot.create(:user, google_id: google_id) }
          result = nil

          before do
            result = described_class.call(headers)
          end

          it 'succeeds' do
            expect(result).to be_success
          end

          it 'returns user' do
            expect(result.result).to eq(user)
          end
        end
    
        context 'when user does not exist in database' do
          result = nil
          user = nil

          before do
            result = described_class.call(headers)
            user = User.find_by google_id: google_id
          end

          it 'creates user in database' do
            expect(user).not_to be_nil
          end

          it 'returns user with expected properties' do
            expectedUser = result.result

            expect(expectedUser).to eq(user)
            expect(expectedUser.email).to eq(email)
            expect(expectedUser.name).to eq(name)
          end
        end
      end

      context 'when token is invalid' do
        result = nil
        let(:validation_error) { GoogleIDToken::ValidationError.new }

        before do
          allow(validator).to receive(:check).and_raise(validation_error)

          result = described_class.call(headers)
        end

        it 'fails' do
          expect(result).to be_failure
        end

        it 'has invalid token error' do
          errors = result.errors
          
          expect(errors[:token].first).to eq(validation_error)
          expect(errors[:token].last).to eq('Invalid Token')
        end
      end
    end

    context 'when token is not present' do
      result = nil

      before do
        headers = {}
        allow(validator).to receive(:check)

        result = described_class.call(headers)
      end

      it 'fails' do
        expect(result).to be_failure
      end

      it 'has missing token error' do
        errors = result.errors
        
        expect(errors[:token].first).to eq('Missing Token')
      end
    end
  end
end
