require 'rails_helper'

RSpec.describe 'Message Destruction', type: :request do
  let(:user_email) { "user#{SecureRandom.hex(4)}@tamu.edu" }
  let(:user_uid) { SecureRandom.hex(4) }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: user_uid,
      info: { email: user_email, name: 'Test User', image: nil }
    )
    get '/auth/google_oauth2/callback'
  end

  let(:user) { User.find_by(email: user_email) }
  let!(:message) { Message.create!(user: user, body: 'Test message', ecef_x: 4000000.0, ecef_y: 3000000.0, ecef_z: 2000000.0) }

  describe 'DELETE /messages/:id' do
    it 'deletes the message' do
      expect {
        delete message_path(message)
      }.to change(Message, :count).by(-1)
    end

    it 'redirects to chat path with notice' do
      delete message_path(message)
      expect(response).to redirect_to(chat_path)
      follow_redirect!
      expect(flash[:notice]).to eq('Message deleted')
    end
  end
end
