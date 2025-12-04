Feature: Admin Dashboard
  As an admin
  I want to view all users and messages
  So that I can manage the system

  Background:
    Given OmniAuth is in test mode

  Scenario: Admin views all users
    Given Google OAuth returns email "harsh.wadhawe@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    When I visit "/chat"
    And I click on "Admin Users"
    Then I should see a list of all users
    And I should see user email addresses
    And I should see user roles displayed

  Scenario: Non-admin cannot access admin users
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    When I visit "/admin/users"
    Then I should be redirected to the chat page

  Scenario: Admin views all messages
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a message exists with body "Test message"
    When I visit "/chat"
    And I click on "Admin Messages"
    Then I should see "All Messages (Admin)"
    And I should see "Test message"
    And I should see message distance information

  Scenario: Admin deletes a message
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a message exists with body "Message to delete"
    When I visit "/chat"
    And I click on "Admin Messages"
    And I delete the message "Message to delete"
    Then the message "Message to delete" should not exist

  Scenario: Non-admin cannot access admin messages
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    When I visit "/admin/messages"
    Then I should be redirected to the chat page

