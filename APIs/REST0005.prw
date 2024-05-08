#include 'protheus.ch'
#include 'restful.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} API REST -> GET, POST, PUT & DELETE
@author Luiz Lustosa
@since 19/05/2024
@version 1.0
/*/

WSRESTFUL clientes DESCRIPTION "crud para cadastro de clientes" FORMAT "application/json"

    // Ambos ultilizados pelos metodos PUT e DELETE p/ localizar o registro
    WSDATA A1_COD   as Optional
    WSDATA A1_LOJA  as Optional

    WSMETHOD GET    DESCRIPTION 'Exibe lista de Clientes'   WSSYNTAX '/clientes/{}'
    WSMETHOD POST   DESCRIPTION 'Inclui Clientes'           WSSYNTAX '/clientes/{}'
    WSMETHOD PUT    DESCRIPTION 'Alteração de Clientes'     WSSYNTAX '/clientes/{A1_COD,A1_LOJA}'
    WSMETHOD DELETE DESCRIPTION 'Deleção de Clientes'       WSSYNTAX '/clientes/{A1_COD,A1_LOJA}'

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

    aRet := RestCliente(oJson, 3) // POST

    If aRet[1]
        oResponse['status']     := 201
        oResponse['message']    := aRet[2]
        ::SetResponse(oResponse:toJson())
    Else
        lRet := .F.
        SetRestFault(400, aRet[2])
    EndIf

Return lRet

WSMETHOD PUT WSRECEIVE A1_COD, A1_LOJA WSSERVICE clientes

    Local lRet  := .T.
    Local cJson := ::GetContent()
    Local aRet  := {}
    Local oResponse, oJson

    ::SetContentType()

    ConOut(cJson)

    oResponse   := JsonObject():New()
    oJson       := JsonObject():New()

    oJson:FromJson(cJson)

    If ValType(::A1_COD) == 'U' .OR. ValType(::A1_LOJA) == 'U'

        SetRestFault(400, 'Informe como parametro da url o codigo do cliente e loja')
        lRet := .F.

    Else

        SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA

        If SA1->(DbSeek(xFilial('SA1') + ::A1_COD + ::A1_LOJA))

            aRet := RestCliente(oJson, 4, ::A1_COD, ::A1_LOJA) // PUT

            If aRet[1]

                oResponse['status']     := 201
                oResponse['message']    := aRet[2]
                ::SetResponse(oResponse:toJson())

            Else

                lRet := .F.
                SetRestFault(400, aRet[2])

            EndIf

        Else

            SetRestFault(400, 'Cliente não foi localizado')
            lRet := .F.

        EndIf

    EndIf

Return lRet

WSMETHOD DELETE WSRECEIVE A1_COD, A1_LOJA WSSERVICE clientes

    Local lRet  := .T.
    Local aRet  := {}
    Local oResponse

    ::SetContentType()

    oResponse   := JsonObject():New()

    If ValType(::A1_COD) == 'U' .OR. ValType(::A1_LOJA) == 'U'

        SetRestFault(400, 'Informe como parametro da url o codigo do cliente e loja')
        lRet := .F.

    Else

        SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA

        If SA1->(DbSeek(xFilial('SA1') + ::A1_COD + ::A1_LOJA))

            aRet := RestCliente(, 5, ::A1_COD, ::A1_LOJA) // DELETE

            If aRet[1]

                oResponse['status']     := 201
                oResponse['message']    := aRet[2]
                ::SetResponse(oResponse:toJson())

            Else

                lRet := .F.
                SetRestFault(400, aRet[2])

            EndIf

        Else

            SetRestFault(400, 'Cliente não foi localizado')
            lRet := .F.

        EndIf

    EndIf

Return lRet

Static Function RestCliente(oJson, nOpc, cCodCli, cLoja)

    Local aRet      := {}
    Local aDados    := {}
    Local cArqErro  := 'ErroAutoExec.txt'
    Local cMsg

    Private lMsErroAuto := .F.

    If nOpc == 4 .OR. nOpc == 5

        aAdd(aDados,{'A1_COD'   , cCodCli   , nil})
        aAdd(aDados,{'A1_LOJA'  , cLoja     , nil})

    Else

        aAdd(aDados,{'A1_COD'   , oJson['A1_COD']   , nil})
        aAdd(aDados,{'A1_LOJA'  , oJson['A1_LOJA']  , nil})

    EndIf

    If nOpc <> 5

        aAdd(aDados,{'A1_NOME'  , oJson['A1_NOME']  , nil})
        aAdd(aDados,{'A1_END'   , oJson['A1_END']   , nil})
        aAdd(aDados,{'A1_NREDUZ', oJson['A1_NREDUZ'], nil})
        aAdd(aDados,{'A1_TIPO'  , oJson['A1_TIPO']  , nil})
        aAdd(aDados,{'A1_EST'   , oJson['A1_EST']   , nil})
        aAdd(aDados,{'A1_MUN'   , oJson['A1_MUN']   , nil})

    EndIf

    MSExecAuto({|x,y| Mata030(x,y)}, aDados, nOpc)

    If lMsErroAuto

        MostraErro('\system\', cArqErro)
        cMsg := MemoRead('\system\' + cArqErro)
        aRet := {.F., cMsg}

    Else

        If nOpc == 3
            cMsgRet := 'incluido'
        ElseIf nOpc == 4
            cMsgRet := 'alterado'
        ElseIf nOpc == 5
            cMsgRet := 'deletado'
        EndIf

        aRet := {.T., 'Cliente ' +cMsgRet+ ' com sucesso'}

    EndIf

Return aRet

User Function testecli // Função obsoleta para o funcionamento da API, ultilizada apenas para testes.

    Local oJson

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

    oJson := JsonObject():New()

    oJson['A1_COD']                     := 'teste'
    oJson['A1_LOJA']                    := '09'
    oJson['A1_NOME']                    := 'PEDRO'
    oJson['A1_END']                     := 'endereco'
    oJson['A1_NREDUZ']/*Nome fantasia*/ := 'nome fantasia'
    oJson['A1_TIPO'] /*F - Cons.Final*/ := 'F'
    oJson['A1_EST']                     := 'RN'
    oJson['A1_MUN']                     := 'Natal'

    aRet := RestCliente(oJson, 4)

    MsgAlert(aRet) // Mensagem aparece no AppServer-Console

Return
