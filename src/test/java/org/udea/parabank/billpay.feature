@parabank_billpay_check
Feature: Pago fallido por saldo insuficiente

  Como tester de backend,
  Quiero simular un pago con saldo insuficiente,
  Para verificar la lógica de validación.

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    * def fromAccountId = data.billpay.sourceAccountId

  @happy_path
  Sceneraio: Pago exitoso
    Given path 'billpay'
    And param accountId = fromAccountId
    And param amount = 1
    When method POST
    Then status 200
    And match response ==
    """
    {
        payeeName: '#string',
        amount: '#number',
        accountId: '#number'
    }
    """


  @alternative_path
  Scenario: Pago rechazado por saldo insuficiente

    # Obtener el saldo actual de la cuenta
    Given path 'accounts', fromAccountId
    When method GET
    Then status 200
    * def currentBalance = response.balance
    * print 'Saldo actual:', currentBalance

    # Definir un monto amyor al saldo actual
    * def amount = currentBalance + 100

    # Realizar el pago
    Given path 'billpay'
    And param accountId = fromAccountId
    And param amount = amount
    When method POST
    Then status 400 || status 422
    And match response contains 'insufficient' || response contains 'Insufficient' || response contains 'funds'