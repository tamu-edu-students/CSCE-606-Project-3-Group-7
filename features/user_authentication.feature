Feature: User signup restrictions
  As a TAMU student
  I should only be able to sign up with a tamu.edu email
  And my identity should be anonymous

  Scenario: Signup fails with non-TAMU email
    When I register with email "test@gmail.com"
    Then I should see "must be a tamu.edu email"

  Scenario: Signup succeeds with TAMU email
    When I register with email "howdy@tamu.edu"
    Then I should see "Account created"

  Scenario: Username is anonymous
    When I register with email "anon@tamu.edu"
    Then I should see an anonymous username
