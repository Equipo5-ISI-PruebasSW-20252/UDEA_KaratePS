@parabank_loan
Feature: Simulación de préstamo

  Como tester de backend,
  quiero enviar una solicitud de préstamo,
  para evaluar si el sistema responde correctamente.

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    * def customerId = data.loan.customerId
    * def accountId = data.loan.accountId

  @happy_path
  Scenario: Solicitud de préstamo exitosa con aprobación

    # Enviar solicitud de préstamo
    Given path 'requestLoan'
    And param customerId = customerId
    And param amount = data.loan.validAmount
    And param downPayment = data.loan.validAmount
    And param fromAccountId = accountId
    When method POST
    Then status 200
    And match response ==
    """
    {
      responseDate: '#string',
      loanProviderName: '#string',
      approved: '#boolean',
      accountId: '#number',
      newAccountId: '#number'
    }
    """
    * def loanStatus = response.approved
    * def newAccountId = response.newAccountId
    And assert loanStatus == true

    # Validar que la nueva cuenta sea de tipo loan
    Given path 'accounts', newAccountId
    When method GET
    Then status 200
    And response.type == "LOAN"

  @alternative_path
  Scenario: Solicitud de préstamo rechazada con datos inválidos

    Given path 'requestLoan'
    And param customerId = customerId
    And param amount = data.loan.invalidAmount
    And param downPayment = data.loan.invalidAmount
    And param fromAccountId = accountId
    When method POST
    Then status 200
    And match response contains 'insufficient'

