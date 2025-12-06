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

  Scenario: Admin can promote a user to admin
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a user with email "regular@tamu.edu" exists with role "user" in admin context
    When I visit "/admin/users"
    And I click on "Make Admin" for user "regular@tamu.edu"
    Then the user "regular@tamu.edu" should have role "admin"
    And I should see a success message about granting admin access

  Scenario: Admin can revoke admin access
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a user with email "otheradmin@tamu.edu" exists with role "admin" in admin context
    When I visit "/admin/users"
    And I click on "Revoke Admin" for user "otheradmin@tamu.edu"
    Then the user "otheradmin@tamu.edu" should have role "user"
    And I should see a success message about revoking admin access

  Scenario: Admin cannot revoke their own admin access
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    When I visit "/admin/users"
    Then I should see "Current user" for the logged in user
    And I should not see a role toggle button for the logged in user

  Scenario: Admin users table is sorted by role by default
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a user with email "regular@tamu.edu" exists with role "user" in admin context
    When I visit "/admin/users"
    Then the users should be sorted by role
    And I should see a sort indicator on the Role column

  Scenario: Admin can toggle sorting to created_at
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    When I visit "/admin/users?sort=created_at"
    Then the users should be sorted by created_at
    And I should not see a sort indicator on the Role column

  Scenario: Admin cannot update user with invalid role
    Given Google OAuth returns email "admin@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in
    And the logged in user should be made an admin
    And a user with email "target@tamu.edu" exists with role "user" in admin context
    When I submit an invalid role update for user "target@tamu.edu"
    Then I should see an error message about invalid role
    And the user "target@tamu.edu" should still have role "user"

