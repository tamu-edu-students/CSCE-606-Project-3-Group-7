require "rails_helper"

RSpec.describe "OAuth Failure", type: :request do
  it "redirects to root" do
    get "/auth/failure"
    expect(response).to redirect_to(root_path)
  end
end
