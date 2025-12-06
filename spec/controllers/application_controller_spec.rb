require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#current_user" do
    let(:user) { User.create!(email: 'user@tamu.edu', display_name: 'Test User') }

    it "returns user when session has user_id" do
      session[:user_id] = user.id
      expect(controller.current_user).to eq(user)
    end

    it "returns nil when session has no user_id" do
      expect(controller.current_user).to be_nil
    end

    it "returns nil when session user_id doesn't exist" do
      session[:user_id] = 99999
      expect(controller.current_user).to be_nil
    end
  end

  describe "GET #oauth_failure" do
    it "redirects to root with an alert" do
      get :oauth_failure, params: { message: "Access denied" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Authentication failed")
    end
  end

  describe "POST #logout" do
    it "clears the session and redirects to root" do
      session[:user_id] = 123
      post :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end

    it "sets flash notice" do
      post :logout
      expect(flash[:notice]).to eq('Signed out')
    end
  end

  describe "GET #logout" do
    it "clears the session and redirects to root" do
      session[:user_id] = 123
      get :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
