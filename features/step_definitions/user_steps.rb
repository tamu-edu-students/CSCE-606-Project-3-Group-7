When("I register with email {string}") do |email|
  visit new_user_registration_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  fill_in "Password confirmation", with: "password123"
  click_button "Sign up"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see an anonymous username") do
  expect(page).to have_content(/Aggie\d+/)
end
