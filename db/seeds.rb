# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sysadmin user (skip in test environment)
unless Rails.env.test?
  user = User.find_or_create_by!(email: 'harsh.wadhawe@tamu.edu') do |u|
    u.display_name = 'System Admin'
    u.provider = 'google_oauth2'
    u.uid = 'sysadmin'
  end
  user.update!(role: 'admin')
end
