@parabank_transfer
Feature: Transferencia entre cuentas

  Como tester de backend,
  Quiero enviar una solicitud de transferencia,
  Para comprobar que el backend procesa y registra la operación.

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * def fromAccountId = data.transfer.fromAccountId
    * def toAccountId = data.transfer.toAccountId
    * def amount = new faker().number().numberBetween(1,200)

    # Funcion auxiliar para obtener el balance del response, ya sea XML o JSON
    * def getBalance =
    """
    function(res){
      if (typeof res == 'string' && res.startsWith('<')) {
        var parsed = karate.xmlToJson(res);
        return parseFloat(parsed.account.balance);
      } else {
        return parseFloat(res.balance);
      }
    }
    """

  @happy_path
  Scenario: Validar transferencia y actualizacion de saldo

    #Obtener los saldos iniciales de las cuentas
    Given path 'accounts', fromAccountId
    When method GET
    Then status 200
    * def fromInitial = getBalance(response)

    Given path 'accounts', toAccountId
    When method GET
    Then status 200
    * def toInitial = getBalance(response)

    #Hacer la transferencia
    Given path 'transfer'
    And param fromAccountId = fromAccountId
    And param toAccountId = toAccountId
    And param amount = amount
    When method POST
    Then status 200
    And match response == "Successfully transferred $" + amount + " from account #" + fromAccountId + " to account #" + toAccountId


    # Verificar saldos actualizados
    Given path 'accounts', fromAccountId
    When method GET
    Then status 200
    * def fromFinal = getBalance(response)

    Given path 'accounts', toAccountId
    When method GET
    Then status 200
    * def toFinal = getBalance(response)

    # Validar matemáticamente el nuevo saldo
    * print 'Saldo inicial origen:', fromInitial, 'Saldo final:', fromFinal, 'Monto:', amount
    * print 'Saldo inicial destino:', toInitial, 'Saldo final:', toFinal, 'Monto:', amount

    And assert fromFinal == fromInitial - amount
    And assert toFinal == toInitial + amount

  @alternative_path
  Scenario: Transferencia invalida por cuentas inexistentes
    * def invalidFromAccount = 888888888
    * def invalidToAccount = 999999999

  Given path 'transfer'
  And param fromAccountId = invalidFromAccount
  And param toAccountId = invalidToAccount
  And param amount = amount

    When method POST
    Then status 400
    And match response == "Could not find account number " + invalidFromAccount + " and/or " + invalidToAccount

