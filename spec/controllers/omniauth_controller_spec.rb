require 'rails_helper'

RSpec.describe OmniauthController, type: :controller do
  describe 'GET #passthru' do
    it 'returns 404 not found' do
      get :passthru, params: { provider: 'google_oauth2' }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders plain text message' do
      get :passthru, params: { provider: 'google_oauth2' }
      expect(response.body).to eq('Not implemented')
    end
  end
end
