Feature: Homepage
  As a visitor
  I want to see the homepage
  So that I know the app is running

  Background:
    Given OmniAuth is in test mode

  Scenario: Visiting the homepage when not logged in
    When I visit the homepage
    Then I should see "Welcome to Location Chat"
    And I should see "Sign in with Google"

  Scenario: Visiting the homepage when logged in
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    When I visit the homepage
    Then I should see "Welcome to Location Chat"
    And I should see "Logged in as"
    And I should see "Go to Chat"
