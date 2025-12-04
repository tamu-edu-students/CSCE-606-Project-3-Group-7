Feature: Chat Interface
  As a logged-in user
  I want to view and interact with the chat
  So that I can communicate with nearby users

  Background:
    Given OmniAuth is in test mode
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in

  Scenario: View chat page
    When I visit "/chat"
    Then I should see "Global Chat"
    And I should see the logged in user's display name

  Scenario: Chat page requires login
    Given I am logged out
    When I visit "/chat"
    Then I should be redirected to the homepage

  Scenario: Refresh chat
    When I visit "/chat"
    And I click on "Refresh"
    Then I should be on the chat page

