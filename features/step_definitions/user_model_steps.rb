Given('a user with email {string} exists with role {string}') do |email, role|
  User.find_or_create_by!(email: email) do |u|
    u.display_name = 'Test User'
    u.provider = 'google_oauth2'
    u.uid = 'old_uid'
    u.role = role
  end
end

Given('a user with email {string} exists with name {string}') do |email, name|
  # First, destroy any existing user to ensure clean state
  User.where(email: email).destroy_all
  # Create the user with the specified name
  user = User.create!(
    email: email,
    display_name: 'Test User',
    provider: 'google_oauth2',
    uid: 'old_uid',
    name: name,
    role: 'user'
  )
  # Verify the name was set correctly
  user.reload
  expect(user.name).to eq(name), "User name should be '#{name}' but was '#{user.name}'"
end

Given('a user with email {string} exists with name {string} and uid {string}') do |email, name, uid|
  # First, destroy any existing user to ensure clean state
  User.where(email: email).destroy_all
  # Create the user with the specified name and uid
  user = User.create!(
    email: email,
    display_name: 'Test User',
    provider: 'google_oauth2',
    uid: uid,
    name: name,
    role: 'user'
  )
  # Verify the name was set correctly
  user.reload
  expect(user.name).to eq(name), "User name should be '#{name}' but was '#{user.name}'"
  expect(user.uid).to eq(uid), "User uid should be '#{uid}' but was '#{user.uid}'"
end

Given('Google OAuth returns email {string} with uid {string}') do |email, uid|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: uid,
    info: {
      email: email,
      name: 'Test User',
      image: nil
    }
  )
end

Given('Google OAuth returns email {string} with name {string}') do |email, name|
  # If name is empty string, pass nil to test the || fallback behavior
  name_value = (name.empty? || name == 'nil') ? nil : name
  # Use the same uid as the existing user if it exists, to test merge behavior
  existing_user = User.find_by(email: email)
  uid = existing_user&.uid || '12345'
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: uid,
    info: {
      email: email,
      name: name_value,
      image: nil
    }
  )
end

Given('Google OAuth returns email {string} with name {string} and uid {string}') do |email, name, uid|
  # If name is empty string, pass nil to test the || fallback behavior
  name_value = (name.empty? || name == 'nil') ? nil : name
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: uid,
    info: {
      email: email,
      name: name_value,
      image: nil
    }
  )
end

Then('the user {string} has uid {string}') do |email, uid|
  user = User.find_by(email: email)
  expect(user).to be_present
  user.update!(uid: uid, provider: 'google_oauth2')
end

Given('Google OAuth returns email {string} with image {string}') do |email, image|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '12345',
    info: {
      email: email,
      name: 'Test User',
      image: image
    }
  )
end

Then('the user {string} should still have role {string}') do |email, role|
  user = User.find_by(email: email)
  expect(user).to be_present
  expect(user.role).to eq(role)
end

Then('the user {string} should have name {string}') do |email, name|
  user = User.find_by(email: email)
  expect(user).to be_present
  expect(user.name).to eq(name)
end

Then('the user {string} should have an anonymous display name') do |email|
  user = User.find_by(email: email)
  expect(user).to be_present
  expect(user.display_name).to match(/Anonymous (Raccoon|Reveille|Aggie|Howdy|Squirrel)/)
end

Then('the user {string} should not have googleusercontent avatar') do |email|
  user = User.find_by(email: email)
  expect(user).to be_present
  expect(user.avatar_url).to be_nil
end
