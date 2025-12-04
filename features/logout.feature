Feature: Logout
  As a logged-in user
  I want to log out
  So that I can end my session

  Background:
    Given OmniAuth is in test mode
    Given Google OAuth returns email "student@tamu.edu"
    When I visit "/auth/google_oauth2/callback"
    Then I should be logged in

  Scenario: Logout via POST
    When I visit "/chat"
    And I submit a POST request to "/logout"
    Then I should be redirected to the homepage
    And I should not be logged in

  Scenario: Logout via GET
    When I visit "/chat"
    And I visit "/logout"
    Then I should be redirected to the homepage
    And I should not be logged in

  Scenario: Logout from chat page
    When I visit "/chat"
    And I click on "Logout"
    Then I should be redirected to the homepage

