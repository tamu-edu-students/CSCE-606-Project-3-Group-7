Feature: Admin Dashboard
  As an admin
  I want to view all users
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

  Scenario: Non-admin cannot access admin users
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    When I visit "/admin/users"
    Then I should be redirected to the chat page

