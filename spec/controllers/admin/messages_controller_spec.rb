require 'rails_helper'

RSpec.describe Admin::MessagesController, type: :controller do
  let(:admin_user) { User.create!(email: 'admin@tamu.edu', role: 'admin', display_name: 'Admin User') }
  let(:regular_user) { User.create!(email: 'user@tamu.edu', role: 'user', display_name: 'Regular User') }

  describe 'GET #index' do
    context 'when user is admin' do
      before do
        session[:user_id] = admin_user.id
      end

      it 'returns success status' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not admin' do
      before do
        session[:user_id] = regular_user.id
      end

      it 'redirects to chat path' do
        get :index
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to chat path' do
        get :index
        expect(response).to redirect_to(chat_path)
      end
    end
  end
end
