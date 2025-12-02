Feature: TAMU Google OAuth login
  As a user
  I want to log in using my TAMU Google account
  So that I can anonymously access the chat system

  Background:
    Given OmniAuth is in test mode

  Scenario: Login succeeds with TAMU email
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And a user with email "student@tamu.edu" should exist

  Scenario: Login fails with non-TAMU email
    Given Google OAuth returns email "someone@gmail.com"
    When I visit "/auth/google_oauth2/callback"
    Then I should not be logged in
    And no users should exist
