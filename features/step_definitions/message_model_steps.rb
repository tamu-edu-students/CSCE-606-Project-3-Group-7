When('I create a message with body {string}') do |body|
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = User.find(user_id)

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

  @message = Message.create!(
    user: user,
    body: body,
    ecef_x: ecef_x,
    ecef_y: ecef_y,
    ecef_z: ecef_z
  )
end

When('I create a message with newlines') do
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = User.find(user_id)

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

  # Use actual newline characters
  body_with_newlines = "Line1\nLine2\r\nLine3"

  @message = Message.create!(
    user: user,
    body: body_with_newlines,
    ecef_x: ecef_x,
    ecef_y: ecef_y,
    ecef_z: ecef_z
  )
end

Then('the saved message should have body {string}') do |expected_body|
  @message.reload
  expect(@message.body).to eq(expected_body)
end

Given('a message exists at coordinates with body {string}') do |body|
  user_id = Capybara.current_session.driver.request.session[:user_id]
  user = User.find(user_id)

  lat = 30.615
  lng = -96.341
  rad_lat = lat * Math::PI / 180
  rad_lng = lng * Math::PI / 180
  a = 6378137.0
  e_sq = 6.69437999014e-3
  n = a / Math.sqrt(1 - e_sq * Math.sin(rad_lat)**2)

  @message = Message.create!(
    user: user,
    body: body,
    ecef_x: n * Math.cos(rad_lat) * Math.cos(rad_lng),
    ecef_y: n * Math.cos(rad_lat) * Math.sin(rad_lng),
    ecef_z: n * (1 - e_sq) * Math.sin(rad_lat)
  )
end

When('I calculate distance to the message') do
  lat = 30.615
  lng = -96.341
  rad_lat = lat * Math::PI / 180
  rad_lng = lng * Math::PI / 180
  a = 6378137.0
  e_sq = 6.69437999014e-3
  n = a / Math.sqrt(1 - e_sq * Math.sin(rad_lat)**2)

  @distance = @message.distance_to(
    n * Math.cos(rad_lat) * Math.cos(rad_lng),
    n * Math.cos(rad_lat) * Math.sin(rad_lng),
    n * (1 - e_sq) * Math.sin(rad_lat)
  )
end

Then('I should get a valid distance in meters') do
  expect(@distance).to be_a(Numeric)
  expect(@distance).to be >= 0
  expect(@distance).to be < 1000 # Should be close to 0 since same location
end
