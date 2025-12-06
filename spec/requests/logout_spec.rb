require 'rails_helper'

RSpec.describe 'Logout', type: :request do
  let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User') }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345',
      info: { email: 'user@tamu.edu', name: 'Test User', image: nil }
    )
    get '/auth/google_oauth2/callback'
  end

  describe 'POST /logout' do
    it 'clears the session' do
      post logout_path
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root path' do
      post logout_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /logout' do
    it 'clears the session' do
      get logout_path
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root path' do
      get logout_path
      expect(response).to redirect_to(root_path)
    end
  end
end
