require 'rails_helper'

RSpec.describe User, type: :model do
  context "email validations" do
    it "accepts a tamu.edu email" do
      user = User.new(email: "test@tamu.edu")
      expect(user.valid?).to be(true)
    end

    it "rejects a non-tamu email" do
      user = User.new(email: "hacker@gmail.com")
      expect(user.valid?).to be(false)
    end
  end


  context "anonymous display name" do
    it "auto-generates a display name on create" do
      user = User.create(email: "abc@tamu.edu")
      expect(user.display_name.blank?).to be(false)
    end
  end

  context "google image removal" do
    it "does not store the google-oauth2 profile image" do
      user = User.create(
        email: "abc@tamu.edu",
        image_url: "https://lh3.googleusercontent.com/some_image.jpg"
      )
      expect(user.image_url).to be_nil
    end
  end

  # context "location validations" do
  #   it "validates latitude numericality" do
  #     user = User.new(email: "x@tamu.edu", latitude: "not-a-number")
  #     expect(user.valid?).to be(false)
  #   end

  #   it "validates longitude numericality" do
  #     user = User.new(email: "x@tamu.edu", longitude: nil)
  #     expect(user.valid?).to be(false)
  #   end
  # end
end
