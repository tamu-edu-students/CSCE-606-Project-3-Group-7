Feature: Message Model Edge Cases
  As the system
  I want to handle message model edge cases
  So that messages are properly formatted

  Background:
    Given OmniAuth is in test mode
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in

  Scenario: Message whitespace is stripped on save
    When I create a message with body "  Hello   World  "
    Then the saved message should have body "Hello World"

  Scenario: Message newlines are converted to spaces
    When I create a message with newlines
    Then the saved message should have body "Line1 Line2 Line3"

  Scenario: Message distance calculation works
    Given a message exists at coordinates with body "Test message"
    When I calculate distance to the message
    Then I should get a valid distance in meters

