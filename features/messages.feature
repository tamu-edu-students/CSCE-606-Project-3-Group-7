Feature: Messages
  As a logged-in user
  I want to create and view messages
  So that I can communicate with others

  Background:
    Given OmniAuth is in test mode
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in

  Scenario: Create a message
    When I visit "/chat?lat=30.615&lon=-96.341"
    And I fill in "New Message" with "Hello, world!"
    And I click on "Send"
    Then I should see "Hello, world!"

  Scenario: Cannot create empty message
    When I visit "/chat?lat=30.615&lon=-96.341"
    And I click on "Send"
    Then I should see an error message

  Scenario: Create message with whitespace
    When I visit "/chat?lat=30.615&lon=-96.341"
    And I fill in "New Message" with "  Hello   with   spaces  "
    And I click on "Send"
    Then I should see "Hello with spaces"
    And the message should not have extra whitespace

  Scenario: Admin can view all messages
    Given the logged in user should be made an admin
    And I visit "/chat?lat=30.615&lon=-96.341"
    And I click on "Admin Messages"
    Then I should see "All Messages (Admin)"

  Scenario: Message creation requires login
    Given I am logged out
    When I submit a POST request to "/messages" with body "Hello"
    Then I should be redirected to the homepage

  Scenario: View my own messages
    When I visit "/chat?lat=30.615&lon=-96.341"
    And I fill in "New Message" with "My message"
    And I click on "Send"
    Then I should see "My message"
    And the message should be marked as mine

