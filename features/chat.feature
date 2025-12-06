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

  Scenario: View empty chat state
    When I visit "/chat?lat=30.615&lon=-96.341"
    Then I should see "No messages yet. Be the first to post!"

  Scenario: View multiple messages
    Given a message exists with body "First message"
    And a message exists with body "Second message"
    When I visit "/chat?lat=30.615&lon=-96.341"
    Then I should see "First message"
    And I should see "Second message"

  Scenario: View message with distance
    Given a message exists with body "Nearby message"
    When I visit "/chat?lat=30.615&lon=-96.341"
    Then I should see "Nearby message"
    And I should see distance information for messages

  Scenario: Location input form is displayed when location not provided
    When I visit "/chat"
    Then I should see "Location not provided"
    And I should see "Enter your location"
    And I should see a location input form
    And I should see "Use My Location" button

