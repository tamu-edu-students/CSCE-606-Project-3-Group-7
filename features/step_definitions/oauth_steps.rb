Given('OmniAuth is in test mode') do
  OmniAuth.config.test_mode = true
end

Given('Google OAuth returns email {string}') do |email|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '12345',
    info: {
      email: email,
      name: 'Fake Name',
      image: 'http://example.com/img.jpg'
    }
  )
end

When('I visit {string}') do |path|
  visit path
end

Then('I should be logged in') do
  expect(Capybara.current_session.driver.request.session[:user_id]).not_to be_nil
end

Then('I should not be logged in') do
  expect(Capybara.current_session.driver.request.session[:user_id]).to be_nil
end

Then('a user with email {string} should exist') do |email|
  expect(User.where(email: email).exists?).to be(true)
end

Then('no users should exist') do
  expect(User.count).to eq(0)
end

Then('I should see an anonymous display name') do
  visit root_path
  expect(page).to have_content(/Anonymous (Raccoon|Reveille|Aggie|Howdy|Squirrel)/)
end
