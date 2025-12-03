Feature: Homepage
  As a visitor
  I want to see the homepage
  So that I know the app is running

  Scenario: Visiting the homepage
    When I visit the homepage
    Then I should see "Welcome to Location Chat"
    And I should see "Sign in with Google"
