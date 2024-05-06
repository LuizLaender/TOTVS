#include 'protheus.ch'
#include 'restful.ch'

WSRESTFUL clientes DESCRIPTION "crud para cadastro de clientes" FORMAT "application/json"
    WSMETHOD GET DESCRIPTION 'Lista de Clientes' WSSYNTAX '/clientes/{}'
END WSRESTFUL

WSMETHOD GET WSSERVICE clientes

    Local lRet      := .T.
    Local oResponse := JsonObject():New()

    ::SetContentType('application/json')

    oResponse['status'] := 200
    oResponse['dados']  := {}


    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())

    While SA1->(!EoF())

        oJsonSA1 := JsonObject():New()

        oJsonSA1['A1_COD']  := SA1->A1_COD
        oJsonSA1['A1_LOJA'] := SA1->A1_LOJA
        oJsonSA1['A1_NOME'] := SA1->A1_NOME
        oJsonSA1['A1_END']  := SA1->A1_END
        oJsonSA1['A1_EST']  := SA1->A1_EST
        oJsonSA1['A1_MUN']  := SA1->A1_MUN

        aAdd(oResponse['dados'], oJsonSA1)

        SA1->(DbSkip())
    EndDo

    ::SetResponse(oResponse:ToJson())

Return lRet
