Feature: Error Handling
  As a user
  I want proper error handling
  So that the application handles edge cases gracefully

  Background:
    Given OmniAuth is in test mode

  Scenario: OAuth failure is handled gracefully
    When I visit "/auth/failure?message=access_denied"
    Then I should be redirected to the homepage
    And I should see an error message about authentication failure

  Scenario: Accessing chat without login shows error
    Given I am logged out
    When I visit "/chat"
    Then I should be redirected to the homepage

