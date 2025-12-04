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

    it "stores non-google images" do
      user = User.create(
        email: "abc@tamu.edu",
        image_url: "https://example.com/image.jpg"
      )
      expect(user.image_url).to eq("https://example.com/image.jpg")
    end

    it "handles nil image_url" do
      user = User.create(
        email: "abc@tamu.edu",
        image_url: nil
      )
      expect(user.image_url).to be_nil
    end
  end

  describe "associations" do
    it "has many messages" do
      user = User.create!(email: "test@tamu.edu")
      message = Message.create!(
        user: user,
        body: "Test",
        ecef_x: 4000000.0,
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
      )
      expect(user.messages).to include(message)
    end

    it "destroys messages when user is destroyed" do
      user = User.create!(email: "test@tamu.edu")
      message = Message.create!(
        user: user,
        body: "Test",
        ecef_x: 4000000.0,
        ecef_y: 3000000.0,
        ecef_z: 2000000.0
      )
      user.destroy
      expect(Message.exists?(message.id)).to be(false)
    end
  end

  describe "#image_url" do
    it "returns avatar_url" do
      user = User.create!(email: "test@tamu.edu", avatar_url: "https://example.com/img.jpg")
      expect(user.image_url).to eq("https://example.com/img.jpg")
    end
  end

  describe ".find_or_create_from_oauth" do
    let(:oauth_auth_tamu) do
      double(
        provider: "google_oauth2",
        uid: "12345",
        info: double(email: "test@tamu.edu", name: "Test User", image: nil)
      )
    end

    let(:oauth_auth_non_tamu) do
      double(
        provider: "google_oauth2",
        uid: "67890",
        info: double(email: "test@gmail.com", name: "Test User", image: nil)
      )
    end

    context "with TAMU email" do
      it "creates a new user" do
        expect {
          User.find_or_create_from_oauth(oauth_auth_tamu)
        }.to change(User, :count).by(1)
      end

      it "returns a user with correct attributes" do
        user = User.find_or_create_from_oauth(oauth_auth_tamu)
        expect(user.email).to eq("test@tamu.edu")
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("12345")
      end

      it "finds existing user by provider and uid" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345"
        )
        found_user = User.find_or_create_from_oauth(oauth_auth_tamu)
        expect(found_user.id).to eq(existing_user.id)
      end

      it "finds existing user by email when provider/uid don't match" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "99999"
        )
        found_user = User.find_or_create_from_oauth(oauth_auth_tamu)
        expect(found_user.id).to eq(existing_user.id)
      end

      it "updates OAuth fields when merging by email" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: nil,
          uid: nil
        )
        found_user = User.find_or_create_from_oauth(oauth_auth_tamu)
        found_user.reload
        expect(found_user.provider).to eq("google_oauth2")
        expect(found_user.uid).to eq("12345")
      end

      it "preserves role when updating existing user" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          role: "admin"
        )
        found_user = User.find_or_create_from_oauth(oauth_auth_tamu)
        found_user.reload
        expect(found_user.role).to eq("admin")
      end

      it "updates name when merging existing user" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          name: "Old Name"
        )
        oauth_with_new_name = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: "New Name", image: nil)
        )
        found_user = User.find_or_create_from_oauth(oauth_with_new_name)
        found_user.reload
        expect(found_user.name).to eq("New Name")
      end
    end

    context "with non-TAMU email" do
      it "returns nil" do
        result = User.find_or_create_from_oauth(oauth_auth_non_tamu)
        expect(result).to be_nil
      end

      it "does not create a user" do
        expect {
          User.find_or_create_from_oauth(oauth_auth_non_tamu)
        }.not_to change(User, :count)
      end
    end

    context "with nil email" do
      let(:oauth_auth_nil_email) do
        double(
          provider: "google_oauth2",
          uid: "99999",
          info: double(email: nil, name: "Test User", image: nil)
        )
      end

      it "returns nil" do
        result = User.find_or_create_from_oauth(oauth_auth_nil_email)
        expect(result).to be_nil
      end
    end
  end

  describe "#admin?" do
    it "returns true for admin users" do
      user = User.create!(email: "admin@tamu.edu", role: 'admin')
      expect(user.admin?).to be(true)
    end

    it "returns false for non-admin users" do
      user = User.create!(email: "user@tamu.edu", role: 'user')
      expect(user.admin?).to be(false)
    end
  end

  describe "#is_admin?" do
    it "returns true for admin users (backward compatibility)" do
      user = User.create!(email: "admin@tamu.edu", role: 'admin')
      expect(user.is_admin?).to be(true)
    end
  end

  describe "role enum" do
    it "defaults to user role" do
      user = User.create!(email: "test@tamu.edu")
      expect(user.role).to eq('user')
      expect(user.user?).to be(true)
    end

    it "can be set to admin role" do
      user = User.create!(email: "admin@tamu.edu", role: 'admin')
      expect(user.role).to eq('admin')
      expect(user.admin?).to be(true)
    end
  end

  describe "#user?" do
    it "returns true for user role" do
      user = User.create!(email: "user@tamu.edu", role: 'user')
      expect(user.user?).to be(true)
    end

    it "returns false for admin role" do
      user = User.create!(email: "admin@tamu.edu", role: 'admin')
      expect(user.user?).to be(false)
    end
  end

  describe ".find_or_create_from_oauth" do
    context "when updating existing user" do
      it "preserves role when updating OAuth fields" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          role: "admin"
        )
        oauth_auth = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: "Updated Name", image: nil)
        )
        found_user = User.find_or_create_from_oauth(oauth_auth)
        found_user.reload
        expect(found_user.role).to eq("admin")
      end

      it "handles nil name in OAuth info" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          name: "Original Name"
        )
        oauth_auth = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: nil, image: nil)
        )
        found_user = User.find_or_create_from_oauth(oauth_auth)
        found_user.reload
        expect(found_user.name).to eq("Original Name")
      end

      it "handles nil image in OAuth info" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          avatar_url: "https://example.com/existing.jpg"
        )
        oauth_auth = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: "Test", image: nil)
        )
        found_user = User.find_or_create_from_oauth(oauth_auth)
        found_user.reload
        expect(found_user.avatar_url).to eq("https://example.com/existing.jpg")
      end
    end
  end

  describe "display name assignment" do
    it "does not override existing display name" do
      user = User.create!(email: "test@tamu.edu", display_name: "Custom Name")
      expect(user.display_name).to eq("Custom Name")
    end

    it "assigns display name only on create" do
      user = User.create!(email: "test@tamu.edu")
      original_name = user.display_name
      user.update!(email: "new@tamu.edu")
      expect(user.display_name).to eq(original_name)
    end
  end

  describe "set_default_role callback" do
    it "sets default role to user if not provided" do
      user = User.new(email: "test@tamu.edu")
      user.valid?
      expect(user.role).to eq("user")
    end

    it "does not override explicit role" do
      user = User.new(email: "admin@tamu.edu", role: "admin")
      user.valid?
      expect(user.role).to eq("admin")
    end
  end

  describe ".find_or_create_from_oauth" do
    context "when updating existing user with nil fields" do
      it "uses existing name when OAuth name is nil" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          name: "Existing Name"
        )
        oauth_auth = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: nil, image: "http://example.com/img.jpg")
        )
        found_user = User.find_or_create_from_oauth(oauth_auth)
        found_user.reload
        expect(found_user.name).to eq("Existing Name")
      end

      it "uses existing image_url when OAuth image is nil" do
        existing_user = User.create!(
          email: "test@tamu.edu",
          provider: "google_oauth2",
          uid: "12345",
          avatar_url: "http://example.com/existing.jpg"
        )
        oauth_auth = double(
          provider: "google_oauth2",
          uid: "12345",
          info: double(email: "test@tamu.edu", name: "Test", image: nil)
        )
        found_user = User.find_or_create_from_oauth(oauth_auth)
        found_user.reload
        expect(found_user.image_url).to eq("http://example.com/existing.jpg")
      end
    end
  end
end
