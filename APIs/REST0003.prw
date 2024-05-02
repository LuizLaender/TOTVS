#include 'protheus.ch'

user function REST0003()

    Local cUrl  :='https://viacep.com.br/ws'
    Local cPath := ''
    Local oJson := JsonObject():New()
    Local oRest

    oRest := FwRest():New(cUrl)

    cPath := '/01001000' + '/json'

    oRest:SetPath(cPath)

    If oRest:Get()
        MsgAlert(oRest:GetResult())
    Else
        MsgAlert(oRest:GetLastError())
    EndIf

Return
