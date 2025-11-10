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
    * def fakerObj = new faker()
    * def amount = fakerObj.number().numberBetween(1000, 50000)
    * def downPayment = fakerObj.number().numberBetween(100, amount)

  @happy_path
  Scenario: Solicitud de préstamo exitosa con aprobación

    # Enviar solicitud de préstamo
    Given path 'requestLoan'
    And param customerId = customerId
    And param amount = amount
    And param downPayment = downPayment
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
      newAccountId: '#? _ == null || _ == "#number"'
    }
    """
    * print 'Respuesta del préstamo:', response
    * print 'Aprobado:', response.approved
    * print 'Monto solicitado:', amount
    * print 'Pago inicial:', downPayment

  @alternative_path
  Scenario: Solicitud de préstamo con validación de campos

    # Obtener información del cliente para validar historial
    Given path 'customers', customerId
    When method GET
    Then status 200
    * def customerInfo = response
    * print 'Información del cliente:', customerInfo

    # Enviar solicitud de préstamo
    Given path 'requestLoan'
    And param customerId = customerId
    And param amount = amount
    And param downPayment = downPayment
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
      newAccountId: '#? _ == null || _ == "#number"'
    }
    """
    # Validar que la respuesta incluye campos de validación
    And assert response.responseDate != null
    And assert response.loanProviderName != null
    And assert response.approved != null
    And assert response.accountId == accountId
    * print 'Fecha de respuesta:', response.responseDate
    * print 'Proveedor de préstamo:', response.loanProviderName
    * print 'Estado de aprobación:', response.approved

  @alternative_path
  Scenario: Solicitud de préstamo rechazada con datos inválidos

    * def invalidCustomerId = 999999999
    * def invalidAccountId = 888888888
    * def invalidAmount = 1000000
    * def invalidDownPayment = 500000

    Given path 'requestLoan'
    And param customerId = invalidCustomerId
    And param amount = invalidAmount
    And param downPayment = invalidDownPayment
    And param fromAccountId = invalidAccountId
    When method POST
    Then status 400 || status 404
    * print 'Respuesta de error:', response

