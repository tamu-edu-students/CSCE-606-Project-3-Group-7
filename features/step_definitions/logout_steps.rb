When('I submit a POST request to {string}') do |path|
  page.driver.post(path)
  location = page.response_headers['Location']
  visit location if location
end
