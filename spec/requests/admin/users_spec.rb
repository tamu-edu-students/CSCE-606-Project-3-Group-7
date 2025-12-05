require 'rails_helper'

RSpec.describe 'Admin Users', type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  let(:admin_user) { User.create!(email: 'admin@tamu.edu', role: 'admin', display_name: 'Admin User', provider: 'google_oauth2', uid: 'admin123') }
  let(:regular_user) { User.create!(email: 'user@tamu.edu', role: 'user', display_name: 'Regular User', provider: 'google_oauth2', uid: 'user123') }

  def mock_oauth_and_login(user)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: {
        email: user.email,
        name: user.display_name,
        image: nil
      }
    )
    get '/auth/google_oauth2/callback'
  end

  describe 'GET /admin/users' do
    context 'when user is admin' do
      before do
        mock_oauth_and_login(admin_user)
      end

      it 'returns success status' do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it 'displays users in the response' do
        get admin_users_path
        expect(response.body).to include('All Users (Admin)')
        expect(response.body).to include(admin_user.email)
      end
    end

    context 'when user is not admin' do
      before do
        mock_oauth_and_login(regular_user)
      end

      it 'redirects to chat path' do
        get admin_users_path
        expect(response).to redirect_to(chat_path)
      end

      it 'sets alert message' do
        get admin_users_path
        follow_redirect!
        expect(flash[:alert]).to eq('Admin access only')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to chat path' do
        get admin_users_path
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'with multiple users' do
      let!(:user1) { User.create!(email: 'user1@tamu.edu', role: 'user', display_name: 'User 1', provider: 'google_oauth2', uid: 'uid1') }
      let!(:user2) { User.create!(email: 'user2@tamu.edu', role: 'user', display_name: 'User 2', provider: 'google_oauth2', uid: 'uid2') }

      before do
        mock_oauth_and_login(admin_user)
      end

      it 'displays all users' do
        get admin_users_path
        expect(response.body).to include(user1.email)
        expect(response.body).to include(user2.email)
      end

      it 'displays user message counts' do
        Message.create!(user: user1, body: 'Test', ecef_x: 4000000.0, ecef_y: 3000000.0, ecef_z: 2000000.0)
        get admin_users_path
        expect(response.body).to include('1')
      end
    end
  end
end
