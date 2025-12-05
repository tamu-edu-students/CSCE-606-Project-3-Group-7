require 'rails_helper'

RSpec.describe 'Chats', type: :request do
  let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User', provider: 'google_oauth2', uid: '12345') }

  describe 'GET /chat' do
    context 'when user is logged in' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '12345',
          info: { email: 'user@tamu.edu', name: 'Test User', image: nil }
        )
        get '/auth/google_oauth2/callback'
      end

      it 'returns success status' do
        get chat_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        get chat_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
