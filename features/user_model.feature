Feature: User Model Edge Cases
  As the system
  I want to handle user model edge cases
  So that the application is robust

  Background:
    Given OmniAuth is in test mode

  Scenario: OAuth merge preserves existing user role
    Given a user with email "existing@tamu.edu" exists with role "admin"
    When Google OAuth returns email "existing@tamu.edu" with uid "new_uid"
    And I visit "/auth/google_oauth2/callback"
    Then the user "existing@tamu.edu" should still have role "admin"

  Scenario: User gets display name when blank
    Given Google OAuth returns email "newuser@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then the user "newuser@tamu.edu" should have an anonymous display name

  Scenario: User image_url setter handles googleusercontent URLs
    Given Google OAuth returns email "test@tamu.edu" with image "https://googleusercontent.com/photo.jpg"
    When I visit "/auth/google_oauth2/callback"
    Then the user "test@tamu.edu" should not have googleusercontent avatar

