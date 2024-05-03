#include 'protheus.ch'

user function REST0003(cCep)

    Local cUrl  :='https://viacep.com.br/ws/'
    Local cPath := ''
    Local cJson
    Local oJson := JsonObject():New()
    Local oRest

    Default cCep := '01001000'

    oRest := FwRest():New(cUrl)
    cPath := cCep + '/json'

    oRest:SetPath(cPath)

    If oRest:Get()
        cJson := DecodeUtf8(oRest:GetResult())

        oJson:FromJson(cJson)

        M->A1_END       := ''

        M->A1_END       := oJson['logradouro']
        M->A1_BAIRRO    := oJson['bairro']
        M->A1_MUN       := oJson['localidade']
        M->A1_EST       := oJson['uf']

    Else
        MsgAlert(oRest:GetLastError())
    EndIf

Return &(ReadVar())
