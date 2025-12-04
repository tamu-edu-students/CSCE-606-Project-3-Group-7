class User < ApplicationRecord
  has_many :messages, dependent: :destroy

  # Roles
  enum :role, { user: "user", admin: "admin" }

  # Validations
  validates :email, format: { with: /\A.+@tamu\.edu\z/i, message: "must be a tamu.edu address" }
  validates :role, presence: true

  # Callbacks
  before_validation :assign_display_name, on: :create
  before_validation :set_default_role, on: :create

  # Virtual attribute: image_url maps to avatar_url
  def image_url=(value)
    if value&.include?("googleusercontent")
      self.avatar_url = nil
    else
      self.avatar_url = value
    end
  end

  def image_url
    avatar_url
  end

  def self.find_or_create_from_oauth(auth)
    email = auth.info.email
    return nil unless email&.downcase&.end_with?("@tamu.edu")

    # First try to find by provider/uid (normal OAuth flow)
    user = where(provider: auth.provider, uid: auth.uid).first

    # If not found, check if user exists by email (merge existing user)
    user ||= where(email: email.downcase).first

    if user
      # Update OAuth fields to keep them in sync, but preserve role and name if OAuth name is nil/blank
      update_params = {
        provider: auth.provider,
        uid: auth.uid
      }
      # Only update name if OAuth provides one, otherwise preserve existing
      update_params[:name] = auth.info.name if auth.info.name.present?
      # Only update image_url if OAuth provides one, otherwise preserve existing
      update_params[:image_url] = auth.info.image if auth.info.image.present?
      user.update!(update_params)
    else
      # Create new user
      user = create!(
        provider: auth.provider,
        uid: auth.uid,
        email: email,
        name: auth.info.name,
        image_url: auth.info.image
      )
    end

    user
  end

  # Helper methods for backward compatibility
  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end

  # Keep is_admin? for backward compatibility during migration
  def is_admin?
    admin?
  end

  private

  def assign_display_name
    if display_name.blank?
      animal = [ "Raccoon", "Reveille", "Aggie", "Howdy", "Squirrel" ].sample
      self.display_name = "Anonymous #{animal}"
    end
  end

  def set_default_role
    self.role ||= "user"
  end
end
