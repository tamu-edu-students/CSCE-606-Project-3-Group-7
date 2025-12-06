require 'rails_helper'

RSpec.describe 'Health Check', type: :request do
  describe 'GET /up' do
    it 'returns success status' do
      get rails_health_check_path
      expect(response).to have_http_status(:success)
    end
  end
end
