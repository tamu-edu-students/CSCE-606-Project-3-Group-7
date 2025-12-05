require 'rails_helper'

RSpec.describe "Messages", type: :request do
  describe "POST /create" do
    before do
      User.create!(
      id: 0,
      email: "test@tamu.edu",
      password_digest: "password",
      display_name: "Test User",
      avatar_url: nil,
      is_admin: false,
      deleted_at: nil
      )
    end

    let(:valid_attributes) do
      {
        message: {
          body: "Hello from Huntsville, AL!",
          user_id: 0,
          lat: 34.729847,
          lon: -86.5859011
        }
      }
    end

    let(:valid_address_attributes) do
      {
        message: {
          body: "Hello from Zachry Engineering Education Complex!",
          user_id: 0,
          address: "125 Spence St, College Station, TX 77843"
        }
      }
    end

    let(:invalid_attributes) do
      {
        message: {
          body: "",
          user_id: nil
        }
      }
    end

    it "creates a message with valid lat/lon parameters" do
      post "/messages", params: valid_attributes
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Message created successfully")
      expect(json["message"]["body"]).to eq("Hello from Huntsville, AL!")
      expect(json["message"]["ecef_x"]).to be_within(1.0).of(312503)
      expect(json["message"]["ecef_y"]).to be_within(1.0).of(-5238246)
      expect(json["message"]["ecef_z"]).to be_within(1.0).of(3613276)
    end

    it "creates a message with valid address parameters" do
      post "/messages", params: valid_address_attributes
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Message created successfully")
      expect(json["message"]["body"]).to eq("Hello from Zachry Engineering Education Complex!")
      # the building has a radius of about 100m, so allow some leeway
      expect(json["message"]["ecef_x"]).to be_within(100.0).of(-606693)
      expect(json["message"]["ecef_y"]).to be_within(100.0).of(-5459887)
      expect(json["message"]["ecef_z"]).to be_within(100.0).of(3229843)
    end

    it "does not create a message with invalid parameters" do
      post "/messages", params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Error")
      expect(json["errors"]).to include("Body can't be blank")
    end
  end

  describe "GET /index" do
    before do
      User.create!(
      id: 1,
      email: "test2@tamu.edu",
      password_digest: "password",
      display_name: "Test User 2",
      avatar_url: nil,
      is_admin: false,
      deleted_at: nil
      )
      Message.create!(
        body: "Hello from Huntsville, AL!",
        user_id: 1,
        ecef_x: 312503,
        ecef_y: -5238246,
        ecef_z: 3613276
      )
      Message.create!(
        body: "Hello from Zachry Engineering Education Complex!",
        user_id: 1,
        ecef_x: -606693,
        ecef_y: -5459887,
        ecef_z: 3229843
      )
    end

    it "retrieves messages within 500m radius" do
      get "/messages", params: {
        message: {
          address: "Zachry Engineering Education Complex, College Station, TX"
        }
      }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("Success")
      expect(json["messages"].length).to eq(1)
      expect(json["messages"][0]["body"]).to eq("Hello from Zachry Engineering Education Complex!")
    end
  end
end
