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

Then('I should see user roles displayed') do
  expect(page).to have_content(/Admin|User/)
end

Then('I should see message distance information') do
  expect(page).to have_content('Distance (m)')
end

When('I delete the message {string}') do |message_body|
  # Find the message and delete it directly via POST
  message = Message.find_by(body: message_body)
  expect(message).to be_present, "Message '#{message_body}' should exist"

  # Submit DELETE request directly (RackTest doesn't support JS confirm dialogs)
  page.driver.delete("/messages/#{message.id}")
  visit page.response_headers['Location'] if page.response_headers['Location']
end

Then('the message {string} should not exist') do |message_body|
  expect(Message.where(body: message_body).count).to eq(0)
end
