#include 'protheus.ch'
#include 'restful.ch'
#include 'tbiconn.ch'

WSRESTFUL clientes DESCRIPTION "crud para cadastro de clientes" FORMAT "application/json"

    WSMETHOD GET    DESCRIPTION 'Exibe lista de Clientes'   WSSYNTAX '/clientes/{}'
    WSMETHOD POST   DESCRIPTION 'Inclui Clientes'           WSSYNTAX '/clientes/{}'

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

WSMETHOD POST WSSERVICE clientes

    Local lRet  := .T.
    Local cJson := ::GetContent()
    Local aRet  := {}
    Local oResponse, oJson

    ::SetContentType()

    ConOut(cJson)

    oResponse   := JsonObject():New()
    oJson       := JsonObject():New()

    oJson:FromJson(cJson)

    aRet := RestCliente(oJson, 3)

    If aRet[1]
        oResponse['status']     := 201
        oResponse['message']    := aRet[2]
    Else
        lRet := .F.
        SetRestFault(400, aRet[2])
    EndIf

Return lRet

Static Function RestCliente(oJson, nOpc)

    Local aRet      := {}
    Local aDados    := {}
    Local cArqErro  := 'ErroAutoExec.txt'
    Local cMsg

    Private lMsErroAuto := .F.

    aAdd(aDados,{'A1_COD'   , oJson['A1_COD']   , nil})
    aAdd(aDados,{'A1_LOJA'  , oJson['A1_LOJA']  , nil})
    aAdd(aDados,{'A1_NOME'  , oJson['A1_NOME']  , nil})
    aAdd(aDados,{'A1_END'   , oJson['A1_END']   , nil})
    aAdd(aDados,{'A1_NREDUZ', oJson['A1_NREDUZ'], nil})
    aAdd(aDados,{'A1_TIPO'  , oJson['A1_TIPO']  , nil})
    aAdd(aDados,{'A1_EST'   , oJson['A1_EST']   , nil})
    aAdd(aDados,{'A1_MUN'   , oJson['A1_MUN']   , nil})

    MSExecAuto({|x,y| Mata030(x,y)}, aDados, nOpc)

    If lMsErroAuto
        MostraErro('\system\', cArqErro)
        cMsg := MemoRead('\system\' + cArqErro)
        aRet := (.F., cMsg)
    Else
        aRet := (.T., 'Cliente incluído com sucesso')
    EndIf

Return aRet

User Function testecli

    Local oJson

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

    oJson := JsonObject():New()

    oJson['A1_COD']                     := 'teste'
    oJson['A1_LOJA']                    := '08'
    oJson['A1_NOME']                    := 'joao'
    oJson['A1_END']                     := 'endereco'
    oJson['A1_NREDUZ']/*Nome fantasia*/ := 'nome fantasia'
    oJson['A1_TIPO'] /*F - Cons.Final*/ := 'F'
    oJson['A1_EST']                     := 'RN'
    oJson['A1_MUN']                     := 'Natal'

    aRet := RestCliente(oJson, 3)

    MsgAlert(aRet) // Mensagem aparece no AppServer-Console

Return
