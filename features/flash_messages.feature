Feature: Flash Messages
  As a user
  I want to see feedback messages
  So that I know the result of my actions

  Background:
    Given OmniAuth is in test mode

  Scenario: See success message after login
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should see a success message

  Scenario: See error message for non-TAMU email
    Given Google OAuth returns email "someone@gmail.com"
    When I visit "/auth/google_oauth2/callback"
    Then I should see an error message about TAMU email

  Scenario: See success message after logout
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    When I visit "/logout"
    Then I should see a logout success message

