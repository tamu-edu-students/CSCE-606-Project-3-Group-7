When("I visit the homepage") do
  visit root_path
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
