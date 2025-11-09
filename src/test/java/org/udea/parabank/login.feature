@parabank_login
Feature: Validar servicio de login con token de autenticación

  Como tester de backend,
  Quiero validar que el servicio de login devuelve un token/autenticación válida,
  Para permitir acceso a usuarios correctos.

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * path 'login'
    * def loginData = data.login

  @happy_path
  Scenario: Login con credenciales validas
    * def user = loginData.validUser
    Given param username = user.username
    And param password = user.password
    When method GET
    Then status 200
    And match response.id == '#number'
    And match response.firstname == '#string'
    * def token = responseHeaders['CF-RAY'][0]
    And match token != null
  
  @alternative_path
  Scenario: Login inválido
    * def user = loginData.invalidUser
    Given param username = user.username
    And param password = user.password
    When method GET
    Then status 400
    And match response == 'Invalid username and/or password'