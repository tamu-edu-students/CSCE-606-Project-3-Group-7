class User < ApplicationRecord
  has_many :messages, dependent: :destroy
  
  def self.find_or_create_from_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.avatar_url = auth.info.image
      user.display_name = "Anonymous #{['Raccoon', 'Reveille', 'Aggie', 'Howdy'].sample}"
    end
  end
end