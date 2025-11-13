require "rails_helper"

RSpec.describe "Homepage", type: :request do
  it "returns success" do
    get root_path
    expect(response).to have_http_status(:ok)
  end
end
