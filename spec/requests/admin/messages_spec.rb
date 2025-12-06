require 'rails_helper'

RSpec.describe 'Admin Messages', type: :request do
  let(:admin_user) { User.create!(email: 'admin@tamu.edu', role: 'admin', display_name: 'Admin User', provider: 'google_oauth2', uid: 'admin123') }
  let(:regular_user) { User.create!(email: 'user@tamu.edu', role: 'user', display_name: 'Regular User', provider: 'google_oauth2', uid: 'user123') }

  def login_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.display_name, image: nil }
    )
    get '/auth/google_oauth2/callback'
  end

  describe 'GET /admin/messages' do
    context 'when user is admin' do
      before { login_as(admin_user) }

      it 'returns success status' do
        get admin_messages_path
        expect(response).to have_http_status(:success)
      end

      it 'displays admin messages page' do
        get admin_messages_path
        expect(response.body).to include('All Messages (Admin)')
      end
    end

    context 'when user is not admin' do
      before { login_as(regular_user) }

      it 'redirects to chat path' do
        get admin_messages_path
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to chat path' do
        get admin_messages_path
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'with messages' do
      let!(:message) { Message.create!(user: admin_user, body: 'Test message', ecef_x: 4000000.0, ecef_y: 3000000.0, ecef_z: 2000000.0) }

      before { login_as(admin_user) }

      it 'displays messages in the response' do
        get admin_messages_path
        expect(response.body).to include('Test message')
      end

      it 'displays message author information' do
        get admin_messages_path
        expect(response.body).to include(admin_user.display_name)
        expect(response.body).to include(admin_user.email)
      end

      it 'displays message timestamps' do
        get admin_messages_path
        expect(response.body).to include(message.created_at.strftime('%Y-%m-%d'))
      end
    end
  end
end
