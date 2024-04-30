#include 'protheus.ch'

user function REST0002()

    Local cUrl  := 'http://localhost:8080/rest/'
    Local cPath := 'helloworld'
    Local oRest

    //instancia o objeto
    oRest := FwRest():New(cUrl)

    //define o recurso que sera usado
    oRest:setPath(cPath)

    //chama o metodo get
    If oRest:Get()
        MsgAlert(oRest:GetResult())
    Else
        MsgAlert(oRest:GerLastError())
    EndIf

Return
