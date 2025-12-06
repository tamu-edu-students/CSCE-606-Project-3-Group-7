Then('I should see the logged in user\'s display name') do
  user_id = Capybara.current_session.driver.request.session[:user_id]
  expect(user_id).not_to be_nil
  user = User.find(user_id)
  expect(page).to have_content(user.display_name)
end

Given('I am logged out') do
  # Visit a page first to initialize the session
  visit root_path
  # Clear session
  page.driver.browser.clear_cookies if page.driver.respond_to?(:browser)
  Capybara.current_session.driver.request.session[:user_id] = nil
end

Then('I should be redirected to the homepage') do
  expect(page).to have_current_path(root_path)
end

Then('I should be on the chat page') do
  expect(page).to have_current_path(chat_path)
end

Then('I should see a location input form') do
  expect(page).to have_css('.location-form')
  expect(page).to have_field('address')
end

Then('I should see {string} button') do |button_text|
  expect(page).to have_button(button_text)
end
