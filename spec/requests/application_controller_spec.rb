require 'rails_helper'

RSpec.describe 'ApplicationController OAuth', type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  def mock_google_oauth(email:, name: 'Test User', uid: '12345')
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: uid,
      info: {
        email: email,
        name: name,
        image: nil
      }
    )
  end

  describe 'GET /auth/google_oauth2/callback' do
    context 'with TAMU email' do
      before do
        mock_google_oauth(email: 'test@tamu.edu')
        get '/auth/google_oauth2/callback'
      end

      it 'creates a user' do
        expect(User.where(email: 'test@tamu.edu').exists?).to be(true)
      end

      it 'logs the user in' do
        expect(session[:user_id]).not_to be_nil
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with admin email' do
      before do
        mock_google_oauth(email: 'harsh.wadhawe@tamu.edu')
        get '/auth/google_oauth2/callback'
      end

      it 'creates a user with default role' do
        user = User.find_by(email: 'harsh.wadhawe@tamu.edu')
        expect(user).to be_present
        expect(user.role).to eq('user')
      end
    end

    context 'with non-TAMU email' do
      before do
        mock_google_oauth(email: 'test@gmail.com')
        get '/auth/google_oauth2/callback'
      end

      it 'does not create a user' do
        expect(User.where(email: 'test@gmail.com').exists?).to be(false)
      end

      it 'redirects with alert' do
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(flash[:alert]).to include('@tamu.edu')
      end
    end

    context 'with nil user name' do
      before do
        mock_google_oauth(email: 'test@tamu.edu', name: nil)
        get '/auth/google_oauth2/callback'
      end

      it 'creates a user successfully' do
        expect(User.where(email: 'test@tamu.edu').exists?).to be(true)
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'POST /auth/google_oauth2/callback' do
      before do
        mock_google_oauth(email: 'test@tamu.edu')
        post '/auth/google_oauth2/callback'
      end

      it 'creates a user' do
        expect(User.where(email: 'test@tamu.edu').exists?).to be(true)
      end

      it 'logs the user in' do
        expect(session[:user_id]).not_to be_nil
      end
    end
  end
end
