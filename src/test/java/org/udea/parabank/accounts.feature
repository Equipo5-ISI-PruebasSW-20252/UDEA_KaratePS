@parabank_accounts_check
Feature: Consulta de cuentas

  Como tester de backend,
  Quiero obtener los datos de las cuentas del usuario,
  Para verificar que el API devuelve información precisa.

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def accountsIds = data.accounts

  @happy_path
  Scenario: Obtener las cuentas de un usuario válido
    * def userId = accountsIds.ValidUserId
    Given path 'customers', userId, 'accounts'
    When method GET
    Then status 200
    And match response == '#[0]'
    And match each response ==
    """
    {
      id: '#number',
      customerId: '#number',
      type: '#string',
      balance: '#number'
    }
    """
    And match each response.customerId == userId

  @alternative_path
  Scenario: Intentar obtener cuentas de un usuario inválido
    * def userId = accountsIds.InvalidUserId
    Given path 'customers', userId, 'accounts'
    When method GET
    Then status 404
    And match response == "Could not find customer #" + userId