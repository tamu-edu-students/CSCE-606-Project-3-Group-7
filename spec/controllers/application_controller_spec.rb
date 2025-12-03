require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "GET #oauth_failure" do
    it "redirects to root with an alert" do
      get :oauth_failure
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST #logout" do
    it "clears the session and redirects to root" do
      session[:user_id] = 123
      post :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
