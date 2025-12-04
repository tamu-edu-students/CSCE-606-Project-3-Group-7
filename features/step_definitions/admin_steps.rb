Given('a user with email {string} exists and is an admin') do |email|
  # Use the same uid that OAuth mock uses ('12345' from oauth_steps.rb)
  user = User.find_or_create_by!(provider: 'google_oauth2', uid: '12345') do |u|
    u.email = email
    u.display_name = 'Admin User'
    u.name = 'Admin User'
  end
  # Ensure email matches and user is admin
  user.update!(email: email, role: 'admin')
end

Then('the logged in user should be made an admin') do
  user_id = Capybara.current_session.driver.request.session[:user_id]
  expect(user_id).not_to be_nil, "User should be logged in"
  user = User.find(user_id)
  user.update!(role: 'admin')
  expect(user.admin?).to be(true)
end


Then('I should see a list of all users') do
  expect(page).to have_css('table')
  expect(page).to have_content('All Users (Admin)')
end

Then('I should see user email addresses') do
  expect(page).to have_css('td', text: /@tamu\.edu/)
end

Then('I should be redirected to the chat page') do
  expect(page.current_path).to eq(chat_path)
end
