require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User', provider: 'google_oauth2', uid: '12345') }

  def login_user
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345',
      info: { email: 'user@tamu.edu', name: 'Test User', image: nil }
    )
    get '/auth/google_oauth2/callback'
  end

  describe 'POST /messages' do
    context 'when user is logged in' do
      before { login_user }

      it 'creates a message' do
        expect {
          post messages_path, params: { message: { body: 'Test message',
          lat: 34.729847,
          lon: -86.5859011 } }
        }.to change(Message, :count).by(1)
      end

      it 'redirects to chat path on success' do
        post messages_path, params: { message: { body: 'Test message',
          lat: 34.729847,
          lon: -86.5859011 } }
        expect(response).to redirect_to(chat_path)
      end

      it 'sets correct ECEF coordinates on message with lat/lon' do
        post messages_path, params: { message: { body: 'Hello from Huntsville, AL!',
          lat: 34.729847,
          lon: -86.5859011 } }
        message = Message.last
        expect(message.ecef_x).to be_within(1.0).of(312503)
        expect(message.ecef_y).to be_within(1.0).of(-5238246)
        expect(message.ecef_z).to be_within(1.0).of(3613276)
      end

      it 'sets correct ECEF coordinates on message with address' do
        post messages_path, params: { message: { body: 'Hello from Zachry Engineering Education Complex!',
          address: 'Zachry Engineering Education Complex, College Station, TX' } }
        message = Message.last
        # the building has a radius of about 100m, so allow some leeway
        expect(message.ecef_x).to be_within(100.0).of(-606693)
        expect(message.ecef_y).to be_within(100.0).of(-5459887)
        expect(message.ecef_z).to be_within(100.0).of(3229843)
      end

      context 'with invalid message' do
        it 'redirects with error when body is blank' do
          post messages_path, params: { message: { body: '' } }
          expect(response).to redirect_to(chat_path)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        post messages_path, params: { message: { body: 'Test message' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /messages/:id' do
    let!(:message) { Message.create!(user: user, body: 'Test message', ecef_x: 4000000.0, ecef_y: 3000000.0, ecef_z: 2000000.0) }

    context 'when user is logged in' do
      before { login_user }

      it 'deletes the message' do
        expect {
          delete message_path(message)
        }.to change(Message, :count).by(-1)
      end

      it 'redirects to chat path' do
        delete message_path(message)
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        delete message_path(message)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
