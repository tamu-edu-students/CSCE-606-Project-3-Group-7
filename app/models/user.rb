class User < ApplicationRecord
  has_many :messages, dependent: :destroy

  # Validations
  validates :email, format: { with: /\A.+@tamu\.edu\z/i, message: "must be a tamu.edu address" }

  # Callbacks
  before_validation :assign_display_name, on: :create

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

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.email    = email
      user.name     = auth.info.name
      user.image_url = auth.info.image
    end
  end

  private

  def assign_display_name
    if display_name.blank?
      animal = [ "Raccoon", "Reveille", "Aggie", "Howdy", "Squirrel" ].sample
      self.display_name = "Anonymous #{animal}"
    end
  end
end
