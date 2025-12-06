require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    it 'returns success status' do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it 'displays welcome message' do
      get root_path
      expect(response.body).to include('Welcome')
    end
  end

  describe 'GET /pages/home' do
    it 'returns success status' do
      get '/pages/home'
      expect(response).to have_http_status(:success)
    end
  end
end
