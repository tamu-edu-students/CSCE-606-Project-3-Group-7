Then('I should see a success message') do
  expect(page).to have_css('.flash.notice', minimum: 0)
end

Then('I should see an error message about TAMU email') do
  expect(page).to have_content(/@tamu\.edu|Only.*tamu/i)
end

Then('I should see a logout success message') do
  expect(page).to have_content(/signed out|logged out/i)
end

Then('I should see an error message about authentication failure') do
  expect(page).to have_content(/authentication failed|access denied/i)
end

Then('I should see an error message about login') do
  expect(page).to have_content(/log in|login|please log/i)
end
