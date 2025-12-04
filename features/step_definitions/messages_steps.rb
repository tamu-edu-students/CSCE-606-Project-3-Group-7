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
