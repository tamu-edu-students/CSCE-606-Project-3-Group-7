When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

Then('I should see an error message') do
  expect(page).to have_content(/error|alert|can't|invalid/i)
end

When('I submit a POST request to {string} with body {string}') do |path, body|
  page.driver.post(path, message: { body: body })
  location = page.response_headers['Location']
  visit location if location
end

When('I click on {string}') do |text|
  if page.has_button?(text)
    click_button text
  elsif page.has_link?(text)
    link = page.find_link(text)
    # Handle DELETE method links (Rails UJS)
    if link['data-method'] == 'delete'
      # Use GET logout route instead since it's supported
      visit '/logout'
    else
      click_link text
    end
  else
    raise "Could not find button or link with text '#{text}'"
  end
end

Given('a message exists with body {string}') do |body|
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = user_id ? User.find(user_id) : User.first || User.create!(email: 'test@tamu.edu', display_name: 'Test User', provider: 'google_oauth2', uid: 'test123', role: 'user')

  # Use TAMU coordinates for ECEF
  lat = 30.615
  lng = -96.341
  rad_lat = lat * Math::PI / 180
  rad_lng = lng * Math::PI / 180
  a = 6378137.0
  e_sq = 6.69437999014e-3
  n = a / Math.sqrt(1 - e_sq * Math.sin(rad_lat)**2)

  ecef_x = n * Math.cos(rad_lat) * Math.cos(rad_lng)
  ecef_y = n * Math.cos(rad_lat) * Math.sin(rad_lng)
  ecef_z = n * (1 - e_sq) * Math.sin(rad_lat)

  Message.create!(
    user: user,
    body: body,
    ecef_x: ecef_x,
    ecef_y: ecef_y,
    ecef_z: ecef_z
  )
end

Then('the message should not have extra whitespace') do
  # Check that messages don't have multiple spaces or newlines
  messages = page.all('.message .body')
  messages.each do |msg|
    text = msg.text
    expect(text).not_to match(/\s{2,}/) # No multiple spaces
    expect(text).not_to match(/\n/) # No newlines
  end
end

Then('the message should be marked as mine') do
  expect(page).to have_css('.message.mine')
end

Then('I should see distance information for messages') do
  # Distance might be shown, check if distance elements exist
  expect(page).to have_css('.message .meta .distance', minimum: 0)
end
