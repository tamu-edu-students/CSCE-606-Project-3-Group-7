# spec/requests/oauth_tamu_spec.rb
require 'rails_helper'

RSpec.describe 'TAMU Google OAuth', type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  def mock_google_oauth(email:)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '12345',
      info: {
        email: email,
        name: 'Fake Name',
        image: 'http://example.com/img.jpg'
      }
    )
  end

  context 'with @tamu.edu email' do
    before do
      mock_google_oauth(email: 'test@tamu.edu')
      get '/auth/google_oauth2/callback'
      @user = User.last
    end

    it 'creates a user with a tamu email' do
      expect(@user.email).to eq('test@tamu.edu')
    end

    it 'stores the provider correctly' do
      expect(@user.provider).to eq('google_oauth2')
    end

    it 'stores the uid correctly' do
      expect(@user.uid).to eq('12345')
    end

    it 'logs the user in' do
      expect(session[:user_id]).to eq(@user.id)
    end
  end

  context 'with a non-tamu email' do
    before do
      # Clean up any existing users first
      User.destroy_all
      mock_google_oauth(email: 'someone@gmail.com')
      get '/auth/google_oauth2/callback'
    end

    it 'does not create a user' do
      expect(User.count).to eq(0)
    end

    it 'does not log in a session' do
      expect(session[:user_id]).to be_nil
    end
  end
end
