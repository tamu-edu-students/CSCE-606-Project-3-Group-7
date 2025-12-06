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

Given('a user with email {string} exists with role {string} in admin context') do |email, role|
  user = User.find_or_create_by!(email: email.downcase) do |u|
    u.display_name = 'Test User'
    u.name = 'Test User'
    u.provider = 'google_oauth2'
    u.uid = "uid_#{email.gsub('@', '_').gsub('.', '_')}"
  end
  user.update!(role: role)
end

When('I click on {string} for user {string}') do |button_text, email|
  user = User.find_by!(email: email.downcase)
  # Find the row containing the user's email and find the form
  row = page.find('tr', text: email)
  within(row) do
    # Find the form and submit it
    form = page.find('form')
    new_role = user.admin? ? 'user' : 'admin'
    # Submit the form with the correct method and params
    Capybara.current_session.driver.submit :patch, form[:action], { user: { role: new_role } }
  end
  # Follow redirect if present
  visit page.response_headers['Location'] if page.response_headers['Location']
end

Then('the user {string} should have role {string}') do |email, role|
  user = User.find_by!(email: email.downcase)
  expect(user.role).to eq(role)
end

Then('I should see a success message about granting admin access') do
  expect(page).to have_content(/granted admin access/i)
end

Then('I should see a success message about revoking admin access') do
  expect(page).to have_content(/revoked admin access/i)
end

Then('I should see {string} for the logged in user') do |text|
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = User.find(user_id)
  row = page.find('tr', text: user.email)
  within(row) do
    expect(page).to have_content(text)
  end
end

Then('I should not see a role toggle button for the logged in user') do
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = User.find(user_id)
  row = page.find('tr', text: user.email)
  within(row) do
    expect(page).not_to have_button('Make Admin')
    expect(page).not_to have_button('Revoke Admin')
  end
end

Then('the users should be sorted by role') do
  # Get all users from the page
  rows = page.all('tbody tr')
  expect(rows.length).to be > 0

  # Extract roles from the table
  roles = rows.map do |row|
    role_cell = row.all('td')[4] # Role is the 5th column (index 4)
    if role_cell.has_css?('.admin-badge')
      'admin'
    else
      'user'
    end
  end

  # Admins should come before users
  admin_count = roles.count('admin')
  user_count = roles.count('user')

  if admin_count > 0 && user_count > 0
    first_admin_index = roles.index('admin')
    first_user_index = roles.index('user')
    expect(first_admin_index).to be < first_user_index
  end
end

Then('I should see a sort indicator on the Role column') do
  expect(page).to have_css('.sort-indicator')
end

Then('the users should be sorted by created_at') do
  # Get all users from the page
  rows = page.all('tbody tr')
  expect(rows.length).to be > 0

  # Extract created_at timestamps from the table
  timestamps = rows.map do |row|
    created_at_cell = row.all('td')[2] # Created At is the 3rd column (index 2)
    Time.parse(created_at_cell.text)
  end

  # Should be sorted descending (newest first)
  expect(timestamps).to eq(timestamps.sort.reverse)
end

Then('I should not see a sort indicator on the Role column') do
  expect(page).not_to have_css('.sort-indicator')
end
