#INCLUDE 'FWMVCDEF.CH'
#include "totvs.ch"


Static cTitulo := "Tela MIT"
Static cAliasMVC := "ZB1"


/*/-------------------------------------
{Protheus.doc} User function MIT02
Tela da MIT proposta pelas analistas
@type user function
@author Luiz Lustosa
@since 11/03/2024
@version 2.0
-------------------------------------/*/


User Function MIT02()

    Local   aArea   := FWGetArea()
    Local   oBrowse

    Private lAprova := .F.

    Private aRotina := {}

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    // Filtro respons�vel por mostrar apenas as PCs criadas pelo usu�rio logado
    If cUserName != GetMV("MZ_APRPC")
        oBrowse:SetFilterDefault("ZB1->ZB1_NOMES == cUserName")
    EndIf

    // Legenda representando o status atual de cada PC
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'O'", "WHITE" , "Em Aberto"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'E'", "GREEN" , "Efetivado"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'R'", "YELLOW", "Revis�o"     )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'C'", "GRAY"  , "Cancelado"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'A'", "RED"   , "Aprovado"    )

    oBrowse:Activate()

    FWRestArea(aArea)

Return


Static Function MenuDef()

    Local aRotina := {}

    // Tela padr�o:
    ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.MITMVC" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.MITMVC" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MITMVC" OPERATION 2 ACCESS 0

    // Bot�o "Outras a��es":
    ADD OPTION aRotina TITLE "Efetivar"     ACTION "U_ZB1Efe()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Aprovar"      ACTION "U_ZB1Apr1(4)"   OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Cancelar"     ACTION "U_ZB1Can()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ZB1Leg()"     OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.MITMVC" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Relatorio"    ACTION "VIEWDEF.MITMVC" OPERATION 6 ACCESS 0

Return aRotina


Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    // Condi��o para permitir ou n�o altera��o de campos.
    If lAprova == .T.

        // O bloco {|| .T.}) PERMITE altera��o. As estruturas a seguir ser�o ultilizadas em rotina de "APROVA��O" pelo aprovador.
        oStruct:SetProperty("ZB1_OBSAPR", MODEL_FIELD_WHEN, {|| .T.})

        oStruct:SetProperty("ZB1_DEST"  , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_CDEST" , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_IDA"   , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_VOLTA" , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_OBS"   , MODEL_FIELD_WHEN, {|| .F.})

    Else

        // O bloco {|| .F.}) NAO permite altera��o. As estruturas a seguir ser�o ultilizadas em rotina de "ALTERA��O" pelo funcion�rio.
        oStruct:SetProperty("ZB1_OBSAPR", MODEL_FIELD_WHEN, {|| .F.})

        oStruct:SetProperty("ZB1_DEST"  , MODEL_FIELD_WHEN, {|| .T.})
        oStruct:SetProperty("ZB1_CDEST" , MODEL_FIELD_WHEN, {|| .T.})
        oStruct:SetProperty("ZB1_IDA"   , MODEL_FIELD_WHEN, {|| .T.})
        oStruct:SetProperty("ZB1_VOLTA" , MODEL_FIELD_WHEN, {|| .T.})
        oStruct:SetProperty("ZB1_OBS"   , MODEL_FIELD_WHEN, {|| .T.})


    EndIf

    oModel := MPFormModel():New("MD_ZB1")
    oModel:AddFields("MASTERZB1",, oStruct)
    oModel:SetPrimaryKey({'ZB1_FILIAL','ZB1_COD'})

    // Recebe .T. ou .F. de U_ZB1Alt(). se .T. abre a tela de altera��o, sen�o mostra erro.
    // oModel:SetVldActivate({|oModel|U_ZB1Alt(oModel)})

Return oModel


Static Function ViewDef()

    Local oModel := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    oView := FWFormView():New()
    oView:AddUserButton("Aprova��o" , "VIEW_ZB1", {|oView| U_ZB1Apr2()})
    oView:AddUserButton("Aprova��o" , "VIEW_ZB1", {|oView| U_ZB1Apr2()})
    oView:AddUserButton("Revis�o"   , "VIEW_ZB1", {|oView| U_ZB1Rev()})

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

    // Oculta campos respons�veis pelo funcionamento da tela.
    oStruct:RemoveField("ZB1_LEGEND")

Return oView


// Fun��o respons�vel por criar o bot�o "legenda" em "outras a��es" da tela principal
User Function ZB1Leg()

    Local aLegenda := {}

    aAdd(aLegenda, {'BR_BRANCO'     , 'Em Aberto'   })
    aAdd(aLegenda, {'BR_VERDE'      , 'Efetivado'   })
    aAdd(aLegenda, {'BR_AMARELO'    , 'Revis�o'     })
    aAdd(aLegenda, {'BR_CINZA'      , 'Cancelado'   })
    aAdd(aLegenda, {'BR_VERMELHO'   , 'Aprovado'    })

    BrwLegenda("Legenda", "", aLegenda)

Return aLegenda


// Fun��o que verifica se o registro pode ou n�o ser alterado.
User Function ZB1Alt(oModel)

    // If oModel:GetOperation() == 4

    //     If (ZB1->ZB1_LEGEND = "O" .And. cUserName $ ZB1->ZB1_NOMES) // .OR. (cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "E")

    //         Return .T.

    //     ElseIf ZB1->ZB1_LEGEND != "O"

    //         Help(,,"Erro",,"Esta solicita��o n�o pode ser alterada, pois j� est� em processo de aprova��o.", 1, 0,,,,,, {"Tente alterar uma presta��o EM ABERTO"})
    //         Return .F.

    //     ElseIf !(cUserName $ ZB1->ZB1_NOMES)

    //         Help(,,"Erro",,"Apenas o usu�rio que incluiu a presta��o pode realizar modifica��es.", 1, 0,,,,,, {"Tente alterar uma presta��o que voc� incluiu."})
    //         Return .F.

    //     EndIf

    // Else

    //     Return .T.

    // EndIf

Return


// Fun��o respons�vel por efetivar as PCs
User Function ZB1Efe()

    If cUsername == GetMV("MZ_APRPC")

        FWAlertError("Aprovadores n�o podem efetivar presta��es de compra.", "Acesso negado")
        Return

    ElseIf ZB1->ZB1_LEGEND == "E"

        FWAlertError("Esta presta��o j� foi efetivada", "Erro")
        Return

    ElseIf ZB1->ZB1_LEGEND != "O"

        FWAlertError("Apenas presta��es EM ABERTO podem ser efetivadas.", "Erro")
        Return

    Else

        ZB1->ZB1_LEGEND := "E"
        FWAlertSuccess("Presta��o de compra efetivada.", "Sucesso")

    EndIf

Return


// Fun��o respons�vel por abrir a rotina de aprova��o.
User Function ZB1Apr1(nOperation) //fazer ela virar o "tudo ok" (retorna true ou falso)

    If cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "E"

        // Vari�vel de controle. Se for rotina de aprova��o, recebe TRUE e permite visualiza��o de certos campos (confira ModelDef).
        lAprova := .T.
        FWExecView("Aprova��o", "VIEWDEF.MITMVC", nOperation, , { || .T. })
        // Retorna vari�vel a seu estado padr�o depois de ter aberto a rotina com FWExecView.
        lAprova := .F.
    
    ElseIf !(cUserName $ GetMV("MZ_APRPC"))

        FWAlertError("Apenas aprovadores podem executar essa a��o.", "Acesso negado")

    ElseIf !(ZB1->ZB1_LEGEND = "E")

        FWAlertError("Apenas pedidos efetivados podem ser aprovados", "Erro")

    EndIf

Return


// Fun��o respons�vel por aprovar as PCs. Aprovar PCs = incluir dados do t�tulo selecionado em um novo t�tulo da rotina FINA050.
User Function ZB1Apr2()

    FWAlertSuccess("fun��o ZB1Apr2 funfano", "teste")


    // // Vari�vel ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem transferidos
    // Private aTransf  := {}

    // // Tratamento de erro do MsExecAuto
    // Private lMsErroAuto := .F.

    // // Vari�veis com conte�do dos campos obrigat�rios da rotina FINA050
    // Private cPrefix     := SuperGetMV('MS_PREFIX'   , .F., "TPC"        )
    // Private cNumTit     := ZB1->ZB1_COD
    // Private cTipo       := SuperGetMV('MS_TIPO'     , .F., "TF"         )
    // Private cNatu       := SuperGetMV('MS_NATURE'   , .F., "SAIDA"      )
    // Private cFornece    := SuperGetMV('MS_FORNEC'   , .F., "000001"     )
    // Private cLoja       := SuperGetMV('MS_LOJA'     , .F., "01"         )

    // // Alguns dos campos obrigat�rios da rotina FINA050:
    // aAdd(aTransf, {"E2_PREFIXO"  , cPrefix          , NIL})
    // aAdd(aTransf, {"E2_NUM"      , cNumTit          , NIL})
    // aAdd(aTransf, {"E2_TIPO"     , cTipo            , NIL})
    // aAdd(aTransf, {"E2_NATUREZ"  , cNatu            , NIL})
    // aAdd(aTransf, {"E2_FORNECE"  , cFornece         , NIL})
    // aAdd(aTransf, {"E2_LOJA"     , cLoja            , NIL})
    // aAdd(aTransf, {"E2_EMISSAO"  , dDataBase        , NIL})

    // // Campos da MIT que o conte�do ser� transferido para FINA050
    // aAdd(aTransf, {"E2_VENCTO"   , ZB1->ZB1_IDA     , NIL})
    // aAdd(aTransf, {"E2_VENCREA"  , ZB1->ZB1_VOLTA   , NIL})
    // aAdd(aTransf, {"E2_VALOR"    , ZB1->ZB1_VALOR   , NIL})
    // aAdd(aTransf, {"E2_VLCRUZ"   , ZB1->ZB1_VALOR   , NIL})

    // // Verifica se usuario � aprovador e se pedido est� efetivado para que possa ser aprovado, ent�o o aprova.
    // If ZB1->ZB1_LEGEND == "E" .And. cUsername == GetMV("MZ_APRPC")

    //     Begin Transaction

    //     // Fun��o padr�o TOTVS respons�vel por transferir os dados de uma rotina para outra.
    //     MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 3)

    //     // Verifica��o de erro padr�o do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios foram preenchidos etc.
    //     If lMsErroAuto
        
    //         DisarmTransaction()
    //         MostraErro()
        
    //     Else

    //         RecLock("ZB1")
    //         ZB1->ZB1_LEGEND := "A"
    //         ZB1->(msunlock())

    //         FWAlertSuccess("T�tulo aprovado com �xito", "Sucesso")

    //     EndIf

    //     End Transaction

    // ElseIf cUsername != GetMV("MZ_APRPC")

    //     FwAlertError("Apenas aprovadores podem aprovar t�tulos.")

    // ElseIf ZB1->ZB1_LEGEND != "E"

    //     FwAlertError("Apenas t�tulos efetivados podem ser aprovados.")

    // EndIf


Return


// Fun��o respons�vel por cancelar as PCs aprovadas. Cancelar PCs = deletar o respectivo registo da FINA050.
User Function ZB1Can()

    // Vari�vel ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem deletados
    Private aTransf  := {}

    // Tratamento de erro do MsExecAuto
    Private lMsErroAuto := .F.

    // Vari�veis com conte�do dos campos obrigat�rios da rotina FINA050
    Private cPrefix     := SuperGetMV('MS_PREFIX'   , .F., "TPC"        )
    Private cNumTit     := ZB1->ZB1_COD
    Private cTipo       := SuperGetMV('MS_TIPO'     , .F., "TF"         )
    Private cNatu       := SuperGetMV('MS_NATURE'   , .F., "SAIDA"      )
    Private cFornece    := SuperGetMV('MS_FORNEC'   , .F., "000001"     )
    Private cLoja       := SuperGetMV('MS_LOJA'     , .F., "01"         )

    // Alguns dos campos obrigat�rios da rotina FINA050:
    aAdd(aTransf, {"E2_PREFIXO"  , cPrefix          , NIL})
    aAdd(aTransf, {"E2_NUM"      , cNumTit          , NIL})
    aAdd(aTransf, {"E2_TIPO"     , cTipo            , NIL})
    aAdd(aTransf, {"E2_NATUREZ"  , cNatu            , NIL})
    aAdd(aTransf, {"E2_FORNECE"  , cFornece         , NIL})
    aAdd(aTransf, {"E2_LOJA"     , cLoja            , NIL})
    aAdd(aTransf, {"E2_VENCTO"   , dDataBase        , NIL})

    // Campos da MIT que o conte�do ser� deletado da FINA050
    aAdd(aTransf, {"E2_EMISSAO"  , ZB1->ZB1_IDA     , NIL})
    aAdd(aTransf, {"E2_VENCREA"  , ZB1->ZB1_VOLTA   , NIL})
    aAdd(aTransf, {"E2_VALOR"    , ZB1->ZB1_VALOR   , NIL})
    aAdd(aTransf, {"E2_VLCRUZ"   , ZB1->ZB1_VALOR   , NIL})

    // Verifica se usuario � aprovador e se pedido est� aprovado para que possa ser cancelado, ent�o o cancela.
    If ZB1->ZB1_LEGEND == "A" .And. cUsername == GetMV("MZ_APRPC")

        Begin Transaction

        // Fun��o padr�o TOTVS respons�vel por transferir os dados de uma rotina para outra, neste caso os deleta.
        MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 5)

        // Verifica��o de erro padr�o do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios est�o inclusos etc.
        If lMsErroAuto
        
            DisarmTransaction()
            MostraErro()
        
        Else

            RecLock("ZB1")
            ZB1->ZB1_LEGEND := "C"
            ZB1->(msunlock())

            FWAlertSuccess("T�tulo cancelado com �xito", "Sucesso")

        EndIf

        End Transaction

    ElseIf cUsername != GetMV("MZ_APRPC")

        FwAlertError("Apenas aprovadores podem cancelar t�tulos.")

    ElseIf ZB1->ZB1_LEGEND != "A"

        FwAlertError("Apenas t�tulos aprovados podem ser cancelados.")

    EndIf

Return

// Fun��o respons�vel por "Revisar" PCs = volta PC para estado "Em Aberto"
User Function ZB1Rev()

    // se opera��o for 0, habilita edi��o do camp obsAprov
    // execauto para adicionar obsAprov ao registro

    If !(cUserName $ GetMV("MZ_APRPC")) 
    
        FWAlertError("Apenas aprovadores podem pedir revis�o de um registro.", "Acesso negado")
        Return
    
    ElseIf ZB1->ZB1_LEGEND != "E"

        FWAlertError("Apenas pedidos EM ABERTO podem ser revisados", "Erro")
        Return

    Else

        RecLock("ZB1")
        ZB1->ZB1_LEGEND := "A"
        ZB1->(msunlock())

        SX3_VISUAL := 1
    
    EndIf
    // se opera��o for 0, habilita edi��o do camp obsAprov
    // execauto para adicionar obsAprov ao registro

    If !(cUserName $ GetMV("MZ_APRPC")) 
    
        FWAlertError("Apenas aprovadores podem pedir revis�o de um registro.", "Acesso negado")
        Return
    
    ElseIf ZB1->ZB1_LEGEND != "E"

        FWAlertError("Apenas pedidos EM ABERTO podem ser revisados", "Erro")
        Return

    Else

        RecLock("ZB1")
        ZB1->ZB1_LEGEND := "A"
        ZB1->(msunlock())

        SX3_VISUAL := 1
    
    EndIf

Return