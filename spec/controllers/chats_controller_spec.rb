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
          body: 'Hello from Zachry Engineering Education Education Complex!',
          ecef_x: -606693,
          ecef_y: -5459887,
          ecef_z: 3229843
        )
      end

      before do
        session[:user_id] = user.id
      end

      it 'returns success status with messages' do
        get :index, params: {
          address: 'Zachry Engineering Education Complex, College Station, TX'
        }
        expect(response).to have_http_status(:success)
        expect(assigns(:messages)).to include(message)
      end
    end

    context 'when no location parameters are provided' do
      before do
        session[:user_id] = user.id
      end

      it 'returns empty messages array' do
        get :index
        expect(assigns(:messages)).to eq([])
      end

      it 'sets new_message to nil' do
        get :index
        expect(assigns(:new_message)).to be_nil
      end
    end

    context 'with lat and lon parameters' do
      before do
        session[:user_id] = user.id
      end

      it 'uses lat/lon to find messages' do
        message = Message.create!(
          user: user,
          body: 'Test message',
          ecef_x: -606693,
          ecef_y: -5459887,
          ecef_z: 3229843
        )

        get :index, params: { lat: 30.615, lon: -96.341 }
        expect(response).to have_http_status(:success)
        expect(assigns(:new_message)).to be_a(Message)
      end
    end

    context 'when geocoding fails (returns nil)' do
      before do
        session[:user_id] = user.id
      end

      it 'handles nil coordinates gracefully when geocoding fails' do
        # Mock address_to_cartesian to return nil (geocoding failure)
        allow(MessageHelper).to receive(:address_to_cartesian).and_return([ nil, nil, nil ])

        # Should handle nil coordinates gracefully without raising an error
        get :index, params: { address: 'Invalid Address That Cannot Be Geocoded' }

        expect(response).to have_http_status(:success)
        expect(assigns(:messages)).to eq([])
        expect(assigns(:new_message)).to be_nil
      end
    end
  end
end
