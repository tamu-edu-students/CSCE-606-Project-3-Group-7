Then('I should see the logged in user\'s display name') do
  user_id = Capybara.current_session.driver.request.session[:user_id]
  expect(user_id).not_to be_nil
  user = User.find(user_id)
  expect(page).to have_content(user.display_name)
end

Given('I am logged out') do
  # Clear session and visit a page to ensure session is cleared
  page.driver.browser.clear_cookies if page.driver.respond_to?(:browser)
  Capybara.current_session.driver.request.session[:user_id] = nil
  visit root_path
end

Then('I should be redirected to the homepage') do
  expect(page).to have_current_path(root_path)
end

Then('I should be on the chat page') do
  expect(page).to have_current_path(chat_path)
end
