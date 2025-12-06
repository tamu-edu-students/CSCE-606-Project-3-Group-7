require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User') }

  describe 'POST #create' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'creates a message' do
        expect {
          post :create, params: { message: { body: 'Test message', lat: 34.729847, lon: -86.5859011 } }
        }.to change(Message, :count).by(1)
      end

      it 'redirects to chat path on success' do
        post :create, params: { message: { body: 'Test message', lat: 34.729847, lon: -86.5859011 } }
        expect(response).to redirect_to(chat_path)
      end

      context 'with invalid message' do
        it 'redirects with error when body is blank' do
          post :create, params: { message: { body: '' } }
          expect(response).to redirect_to(chat_path)
        end

        it 'sets flash alert with error message' do
          post :create, params: { message: { body: '' } }
          expect(flash[:alert]).to be_present
        end

        it 'does not create a message when body is blank' do
          expect {
            post :create, params: { message: { body: '' } }
          }.not_to change(Message, :count)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        post :create, params: { message: { body: 'Test message' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:message) { Message.create!(user: user, body: 'Test message', ecef_x: 4000000.0, ecef_y: 3000000.0, ecef_z: 2000000.0) }

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'deletes the message' do
        expect {
          delete :destroy, params: { id: message.id }
        }.to change(Message, :count).by(-1)
      end

      it 'redirects to chat path' do
        delete :destroy, params: { id: message.id }
        expect(response).to redirect_to(chat_path)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        delete :destroy, params: { id: message.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when message does not exist' do
      before do
        session[:user_id] = user.id
      end

      it 'raises an error' do
        expect {
          delete :destroy, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'sets flash notice on successful deletion' do
      session[:user_id] = user.id
      delete :destroy, params: { id: message.id }
      expect(flash[:notice]).to eq('Message deleted')
    end
  end
end
