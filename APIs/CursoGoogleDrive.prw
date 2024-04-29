#include 'protheus.ch'
#include 'RestFul.ch'

WSRESTFUL HelloWorld DESCRIPTION "Minha primeira API Rest - Hello World!"

    WSMETHOD GET DESCRIPTION "Método GET para meu Hello World" WSSYNTAX "/HelloWorld/{}"

END WSRESTFUL

WSMETHOD GET WSSERVICE HelloWorld

    Local lRet  := .T.
    // Local oJson := JsonObject():New()
    // Local cMsg  := ''

    // ::setContentType('application/json')
    // cMsg := 'Hello World'
    Conout('Hello world')

    // oJson['Mensagem'] := cMsg
    // cRet := oJson:ToJson()

    // ::SetRespose(cRet)
  //::SetRespose(cRet) e Self:SetResponse(cRet) fazem a mesma coisa

Return lRet
