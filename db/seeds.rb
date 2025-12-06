# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin users (skip in test environment)
unless Rails.env.test?
  # List of admin user emails
  admin_emails = [ 'harsh.wadhawe@tamu.edu', 'shmishra@tamu.edu' ]

  admin_emails.each do |email|
    # Try to find existing user (created via OAuth sign-in)
    user = User.find_by(email: email.downcase)

    if user
      # User exists (likely from OAuth), just update role to admin
      user.update!(role: 'admin')
      Rails.logger.info "Updated #{email} to admin role"
    else
      # User doesn't exist yet - create placeholder
      # NOTE: This user won't be able to sign in via OAuth until they actually sign in once
      # The placeholder will be updated with real OAuth data on first sign-in
      user = User.create!(
        email: email.downcase,
        display_name: 'System Admin',
        provider: 'google_oauth2',
        uid: 'placeholder', # Will be updated on first OAuth sign-in
        role: 'admin'
      )
      Rails.logger.warn "Created placeholder admin user for #{email}. User must sign in via OAuth to activate."
    end
  end
end
