Feature: Make deposits to a bank account
  A customer can deposit to a bank account and his balance is updated.

  Scenario: open a new account
    Given I open a bank account
    Then The balance is 0

  Scenario: deposit to an account
    Given I open a bank account
    When I deposit 100
    Then The balance is 100
