require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User') }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns success status' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'redirects with alert in flash' do
        get :index
        expect(flash[:alert]).to include('log in')
      end
    end

    context 'with messages in radius' do
      let!(:message) do
        Message.create!(
          user: user,
          body: 'Test message',
          ecef_x: 4000100.0,
          ecef_y: 3000000.0,
          ecef_z: 2000000.0
        )
      end

      before do
        session[:user_id] = user.id
      end

      it 'returns success status with messages' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
