#include 'protheus.ch'
#include 'RestFul.ch'

WSRESTFUL HelloWorld DESCRIPTION "Minha primeira API Rest - Hello World!"

    WSDATA mensagem as STRING

    WSMETHOD GET DESCRIPTION "Método GET para meu Hello World" WSSYNTAX "/HelloWorld/{teste}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE mensagem WSSERVICE HelloWorld

    Local lRet  := .T.
    Local oJson := JsonObject():New()
    Local cMsg  := ''

    ::setContentType('application/json')

    cMsg := 'Hello World'
    Conout(cMsg)

    // Teste: http://localhost:8080/rest/HELLOWORLD/?mensagem= Ola mundo
    If ValType(::mensagem) <> 'U'
        cMsg += ::mensagem + ' via query string'
    EndIf

    // Teste: http://localhost:8080/rest/HELLOWORLD/ ola mundo
    If Len(::aURLParms) > 0
        cMsg += ::aURLParms[1] + ' via parametro URL'
    EndIf

    oJson['mensagem'] := cMsg
    cRet := oJson:ToJson()

    ::SetResponse(cRet)
  //::SetResponse(cRet) e Self:SetResponse(cRet) fazem a mesma coisa

Return lRet
