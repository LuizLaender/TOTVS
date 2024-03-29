#Include "FWMVCDef.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"


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
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'EM ABERTO'   ", "WHITE"  , "EM ABERTO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'EFETIVADO'   ", "GREEN"  , "EFETIVADO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'REVIS�O  '   ", "YELLOW" , "REVIS�O"     )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'CANCELADO'   ", "GRAY"   , "CANCELADO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'APROVADO '   ", "RED"    , "APROVADO"    )

    oBrowse:Activate()

    FWRestArea(aArea)

Return


Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"      ACTION "U_ZB1Add()"     OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ZB1Alt()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MITMVC" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Efetivar"     ACTION "U_ZB1Efe()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Aprovar"      ACTION "U_ZB1Apr1()"    OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Cancelar"     ACTION "U_ZB1Can()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ZB1Leg()"     OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "U_ZB1Del()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Relatorio"    ACTION "U_ZB1Rel()"     OPERATION 6 ACCESS 0

Return aRotina


Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    // Condi��o para permitir ou n�o altera��o de campos.
    If lAprova == .T.

        // O bloco {|| .T.}) PERMITE altera��o. As estruturas a seguir ser�o ultilizadas em rotina de "APROVA��O" pelo APROVADOr.
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

    oModel := MPFormModel():New("MD_ZB1", /*bPreValidacao*/, {|oModel| U_TudoOk(oModel)})
    oModel:AddFields("MASTERZB1",, oStruct)
    oModel:SetPrimaryKey({'ZB1_FILIAL','ZB1_COD'})

Return oModel


Static Function ViewDef()

    Local oModel  := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    oView := FWFormView():New()
    oView:AddUserButton("Aprova��o" , "VIEW_ZB1", {|oView| U_ZB1Apr2()})
    oView:AddUserButton("REVIS�O  "   , "VIEW_ZB1", {|oView| U_ZB1Rev()})

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

    // Oculta campos respons�veis pelo funcionamento da tela.
    oStruct:RemoveField("ZB1_LEGEND")

Return oView


// Fun��o chamada ao clicar em "confirmar". Confere se as datas s�o v�lidas
User Function TudoOk(oModel)

    Local cQuery
    Local lRet      := .T.

    oModel:GetModel("MD_ZB1")

    cQuery := " SELECT ZB1_IDA, ZB1_VOLTA, ZB1_NOMES FROM ZB1990 "
    cQuery += " WHERE   D_E_L_E_T_ = '' AND '" + ZB1->ZB1_NOMES  + "' = '" + cUserName + "' AND ZB1_IDA   BETWEEN '" + Dtos(M->ZB1_IDA) + "' AND '" + Dtos(M->ZB1_VOLTA) + "' "
    cQuery += " OR      D_E_L_E_T_ = '' AND '" + ZB1->ZB1_NOMES  + "' = '" + cUserName + "' AND ZB1_VOLTA BETWEEN '" + Dtos(M->ZB1_IDA) + "' AND '" + Dtos(M->ZB1_VOLTA) + "' "

    If Select("QRY") > 0

        QRY->(DbCloseArea())	    
    
    EndIf
    
    TcQuery cQuery new alias 'QRY'

    If QRY->(!EoF())

        Help(,, "Erro",, "DATA INVALIDA", 1, 0,,,,,, {"Inclua um t�tulo com data diferente"})
        lRet := .F.

    EndIf

Return lRet


// Fun��o respons�vel por criar o bot�o "legenda" em "outras a��es" da tela principal
User Function ZB1Leg()

    Local aLegenda := {}

    aAdd(aLegenda, {'BR_BRANCO'     , 'EM ABERTO'   })
    aAdd(aLegenda, {'BR_VERDE'      , 'EFETIVADO'   })
    aAdd(aLegenda, {'BR_AMARELO'    , 'REVIS�O  '   })
    aAdd(aLegenda, {'BR_CINZA'      , 'CANCELADO'   })
    aAdd(aLegenda, {'BR_VERMELHO'   , 'APROVADO '   })

    BrwLegenda("Legenda", "", aLegenda)

Return aLegenda


//Fun��o respons�vel por verificar se pode ser feita inclus�o.
User Function ZB1Add()

    If cUsername $ GetMV("MZ_APRPC")

        FWAlertError("APROVADORES n�o podem fazer inclus�es.", "Acesso negado!")
        Return

    Else

        FWExecView("Incluir", "MITMVC", 3, , { || .T. })

    EndIf

Return


// Fun��o que verifica se o registro pode ou n�o ser alterado.
User Function ZB1Alt()

    If (ZB1->ZB1_LEGEND = "EM ABERTO" .And. cUserName $ ZB1->ZB1_NOMES) // .OR. (cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "E")

        FWExecView("Altera��o", "MITMVC", 4, , { || .T. })
        Return .T.

    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"

        Help(,,"Erro",,"Esta solicita��o n�o pode ser alterada, pois j� est� em processo de aprova��o.", 1, 0,,,,,, {"Tente alterar uma presta��o EM ABERTO"})
        Return .F.

    ElseIf !(cUserName $ ZB1->ZB1_NOMES)

        Help(,,"Erro",,"Apenas o usu�rio que incluiu a presta��o pode realizar modifica��es.", 1, 0,,,,,, {"Tente alterar uma presta��o que voc� incluiu."})
        Return .F.

    EndIf

Return


// Fun��o respons�vel por efetivar as PCs
User Function ZB1Efe()

    If cUsername == GetMV("MZ_APRPC")

        FWAlertError("APROVADORES n�o podem efetivar presta��es de compra.", "Acesso negado")
        Return

    ElseIf ZB1->ZB1_LEGEND == "EFETIVADO"

        FWAlertError("Esta presta��o j� foi efetivada", "Erro")
        Return

    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"

        FWAlertError("Apenas presta��es EM ABERTO podem ser efetivadas.", "Erro")
        Return

    Else

        ZB1->ZB1_LEGEND := "EFETIVADO"
        FWAlertSuccess("Presta��o de compra efetivada.", "Sucesso")

    EndIf

Return


// Fun��o respons�vel por abrir a rotina de aprova��o.
User Function ZB1Apr1()

    Local aButtons :={{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,"Aprovar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

    If cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "EFETIVADO"

        lAprova := .T.
        
        FWExecView("Aprova��o", "MITMVC", 4, , { || .T. },,,aButtons)

        lAprova := .F.
    
    ElseIf !(cUserName $ GetMV("MZ_APRPC"))

        FWAlertError("Apenas APROVADORES podem executar essa a��o.", "Acesso negado")

    ElseIf !(ZB1->ZB1_LEGEND = "EFETIVADO")

        FWAlertError("Apenas pedidos EFETIVADOs podem ser APROVADOS", "Erro")

    EndIf

Return


// Fun��o respons�vel por aprovar as PCs. Aprovar PCs = incluir dados do t�tulo selecionado em um novo t�tulo da rotina FINA050.
User Function ZB1Apr2()

    // Vari�vel ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem transferidos
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
    aAdd(aTransf, {"E2_EMISSAO"  , dDataBase        , NIL})

    // Campos da MIT que o conte�do ser� transferido para FINA050
    aAdd(aTransf, {"E2_VENCTO"   , ZB1->ZB1_IDA     , NIL})
    aAdd(aTransf, {"E2_VENCREA"  , ZB1->ZB1_VOLTA   , NIL})
    aAdd(aTransf, {"E2_VALOR"    , ZB1->ZB1_VALOR   , NIL})
    aAdd(aTransf, {"E2_VLCRUZ"   , ZB1->ZB1_VALOR   , NIL})

    Begin Transaction

    // Fun��o padr�o TOTVS respons�vel por transferir os dados de uma rotina para outra.
    MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 3)

    // Verifica��o de erro padr�o do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios foram preenchidos etc.
    If lMsErroAuto
    
        DisarmTransaction()
        MostraErro()
    
    ElseIf ZB1->ZB1_LEGEND = "EFETIVADO"

        RecLock("ZB1")
        ZB1->ZB1_LEGEND := "APROVADO "
        ZB1->(msunlock())

        FWAlertSuccess("T�tulo APROVADO com �xito", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "EFETIVADO"

        FWAlertError("Apenas pedidos EFETIVADOs podem ser APROVADOS", "Erro")

    EndIf

    End Transaction

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

    // Verifica se usuario � APROVADOr e se pedido est� APROVADO para que possa ser CANCELADO, ent�o o cancela.
    If ZB1->ZB1_LEGEND = "APROVADO " .And. cUsername == GetMV("MZ_APRPC")

        If MsgYesNo("T�tulo consta EM ABERTO, ao cancelar essa solicita��o, o t�tulo gerado tamb�m ser� CANCELADO.", "Deseja prosseguir?")

            Begin Transaction

            // Fun��o padr�o TOTVS respons�vel por transferir os dados de uma rotina para outra, neste caso os deleta.
            MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 5)

            // Verifica��o de erro padr�o do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios est�o inclusos etc.
            If lMsErroAuto
            
                DisarmTransaction()
                MostraErro()
            
            Else

                RecLock("ZB1")
                ZB1->ZB1_LEGEND := "CANCELADO"
                ZB1->(msunlock())

                FWAlertSuccess("T�tulo CANCELADO com �xito", "Sucesso")

            EndIf

            End Transaction
        
        Else

            Return

        EndIf

    ElseIf cUsername != GetMV("MZ_APRPC")

        FwAlertError("Apenas APROVADORES podem cancelar t�tulos.")

    ElseIf ZB1->ZB1_LEGEND != "APROVADO "

        FwAlertError("Apenas t�tulos APROVADOS podem ser CANCELADOs.")

    EndIf

Return


// Fun��o respons�vel por "Revisar" PCs = volta PC para estado "EM ABERTO"
User Function ZB1Rev()

    If ZB1->ZB1_LEGEND = "EFETIVADO"

        RecLock("ZB1")
        ZB1->ZB1_OBSAPR := M->ZB1_OBSAPR
        ZB1->ZB1_LEGEND := "REVIS�O  "
        ZB1->(msunlock())

        FWAlertSuccess("T�tulo em REVIS�O", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "EFETIVADO"

        FWAlertError("Apenas pedidos EFETIVADOs podem entrar para REVIS�O", "Erro")

    EndIf
    
Return


// Fun��o respons�vel por deletar PCs.
User Function ZB1Del()

    If cUserName $ ZB1->ZB1_NOMES .And. ZB1->ZB1_LEGEND = "EM ABERTO"

        If MsgYesNo("Deseja excluir o t�tulo?", "Aten��o")
        
            FWExecView("Excluir", "MITMVC", 5)
        
        Else
        
            Return
        
        EndIf
    
    ElseIf !(cUserName $ ZB1->ZB1_NOMES)
        
        FWAlertError("Apenas usu�rio que realizou a inclus�o da presta��o poder� excluir o registro", "Acesso negado!")
    
    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"
    
        FwAlertError("O status atual n�o permite a opera��o desejada", "Erro")
    
    EndIf

Return


User Function ZB1Rel()

    Private cPerg	:= "ZB1MIT"
    Public  oReport

    RptStruc()

    oReport:PrintDialog()

Return


Static Function RPrint(oReport)

    Local oSection := oReport:Section(1)
    
    ZB1->(DBSeeK(cSeek := Xfilial("ZB1") + ZB1->ZB1_COD))
    ZB1->(DBSetOrder(1))
    ZB1->(DBGoTop())

    While ZB1->(!EoF())

        oSection:init()
        oSection:PrintLine()
        oSection:Finish()

        ZB1->(DbSkip())
        
    EndDo

    oReport:EndPage()

Return


Static Function RptStruc()

    oReport := TReport():New("Relat�rio",, cPerg,{|oReport|RPrint(oReport)})

    oSection := TRSection():New(oReport)
        TRCell():New(oSection,"ZB1_COD"     , "ZB1","Cod presta��o"     ,, 14)
        TRCell():New(oSection,"ZB1_SOLIC"   , "ZB1","Cod solic"         ,, 11)
        TRCell():New(oSection,"ZB1_NOMES"   , "ZB1","Nome solic"        ,, 13)
        // TRCell():New(oSection,"ZB1_ORIGEM"  , "ZB1","Estado origem"     ,, 14)
        // TRCell():New(oSection,"ZB1_DEST"    , "ZB1","Estado destino"    ,, 16)
        // TRCell():New(oSection,"ZB1_CDEST"   , "ZB1","Cidade destino"    ,, 16)
        // TRCell():New(oSection,"ZB1_IDA"     , "ZB1","Ida"               ,, 8)
        // TRCell():New(oSection,"ZB1_VOLTA"   , "ZB1","Volta"             ,, 8)
        // TRCell():New(oSection,"ZB1_DURACA"  , "ZB1","Dura��o"           ,, 7)
        // TRCell():New(oSection,"ZB1_VALOR"   , "ZB1","Valor"             ,, 5)
        // TRCell():New(oSection,"ZB1_CODAPR"  , "ZB1","Cod aprovador"     ,, 14)
        // TRCell():New(oSection,"ZB1_NOMAPR"  , "ZB1","Nome aprovador"    ,, 15)
        TRCell():New(oSection,"ZB1_LEGEND"  , "ZB1","Status"            ,, 9)
        
Return
