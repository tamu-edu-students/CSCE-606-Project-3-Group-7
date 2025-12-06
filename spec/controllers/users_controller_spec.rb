require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'controller existence' do
    it 'exists as an empty controller' do
      expect(controller).to be_a(UsersController)
    end
  end
end
