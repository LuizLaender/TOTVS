#Include "FWMVCDef.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"


Static cTitulo := "Tela MIT"
Static cAliasMVC := "ZB1"


/*/---------------------------------------------------
{Protheus.doc} User function MIT02
Tela em MVC para nova rotina de prestação de contas
@type user function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
---------------------------------------------------/*/
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

    // Filtro responsável por mostrar apenas as PCs criadas pelo usuário logado
    If cUserName != GetMV("MZ_APRPC")

        oBrowse:SetFilterDefault("ZB1->ZB1_NOMES == cUserName")

    EndIf

    // Legenda representando o status atual de cada PC
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'EM ABERTO'   ", "WHITE"  , "EM ABERTO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'EFETIVADO'   ", "GREEN"  , "EFETIVADO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'REVISÃO  '   ", "YELLOW" , "REVISÃO"     )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'CANCELADO'   ", "GRAY"   , "CANCELADO"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'APROVADO '   ", "RED"    , "APROVADO"    )

    oBrowse:Activate()

    FWRestArea(aArea)

Return


/*/----------------------------
{Protheus.doc} MenuDef
Retorna o menu principal
@type Static Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"      ACTION "U_ZB1Add()"     OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "teste"        ACTION "U_teste()"      OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ZB1Alt()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MITMVC" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Efetivar"     ACTION "U_ZB1Efe()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Aprovar"      ACTION "U_ZB1Apr1()"    OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Cancelar"     ACTION "U_ZB1Can()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ZB1Leg()"     OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "U_ZB1Del()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Relatorio"    ACTION "U_ZB1Rel()"     OPERATION 6 ACCESS 0

Return aRotina


/*/----------------------------
{Protheus.doc} ModelDef
Construcao do modelo de dados
@type Static Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    // Condição para permitir ou não alteração de campos.
    If lAprova == .T.

        // O bloco {|| .T.}) PERMITE alteração. As estruturas a seguir serão ultilizadas em rotina de "APROVAÇÃO" pelo APROVADOr.
        oStruct:SetProperty("ZB1_OBSAPR", MODEL_FIELD_WHEN, {|| .T.})
        oStruct:SetProperty("ZB1_DEST"  , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_CDEST" , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_IDA"   , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_VOLTA" , MODEL_FIELD_WHEN, {|| .F.})
        oStruct:SetProperty("ZB1_OBS"   , MODEL_FIELD_WHEN, {|| .F.})

    Else

        // O bloco {|| .F.}) NAO permite alteração. As estruturas a seguir serão ultilizadas em rotina de "ALTERAÇÃO" pelo funcionário.
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


/*/----------------------------
{Protheus.doc} ViewDef
Monta o view do modelo
@type Static Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
Static Function ViewDef()

    Local oModel  := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    oView := FWFormView():New()
    oView:AddUserButton("Aprovação" , "VIEW_ZB1", {|oView| U_ZB1Apr2()})
    oView:AddUserButton("REVISÃO  " , "VIEW_ZB1", {|oView| U_ZB1Rev()})
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

    // Oculta campos responsáveis pelo funcionamento da tela.
    oStruct:RemoveField("ZB1_LEGEND")

Return oView


/*/----------------------------
{Protheus.doc} U_TudoOk
Validacao da tela
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
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

        Help(,, "Erro",, "DATA INVALIDA", 1, 0,,,,,, {"Inclua um título com data diferente"})
        lRet := .F.

    EndIf

Return lRet


/*/----------------------------
{Protheus.doc} U_ZB1Leg
Cria botao 'legenda'
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
User Function ZB1Leg()

    Local aLegenda := {}

    aAdd(aLegenda, {'BR_BRANCO'     , 'EM ABERTO'   })
    aAdd(aLegenda, {'BR_VERDE'      , 'EFETIVADO'   })
    aAdd(aLegenda, {'BR_AMARELO'    , 'REVISÃO  '   })
    aAdd(aLegenda, {'BR_CINZA'      , 'CANCELADO'   })
    aAdd(aLegenda, {'BR_VERMELHO'   , 'APROVADO '   })

    BrwLegenda("Legenda", "", aLegenda)

Return aLegenda


/*/------------------------
{Protheus.doc} U_ZB1Add
Abre tela de inclusao
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
------------------------/*/
User Function ZB1Add()

    If cUsername $ GetMV("MZ_APRPC")

        FWAlertError("APROVADORES não podem fazer inclusões.", "Acesso negado!")
        Return

    Else

        FWExecView("Incluir", "MITMVC", 3, , { || .T. })

    EndIf

Return


/*/------------------------
{Protheus.doc} U_ZB1Alt
Abre tela de alteracao
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
------------------------/*/
User Function ZB1Alt()

    If (ZB1->ZB1_LEGEND = "EM ABERTO" .And. cUserName $ ZB1->ZB1_NOMES)

        FWExecView("Alteração", "MITMVC", 4, , { || .T. })
        Return .T.

    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"

        Help(,,"Erro",,"Esta solicitação não pode ser alterada, pois já está em processo de aprovação.", 1, 0,,,,,, {"Tente alterar uma prestação EM ABERTO"})
        Return .F.

    ElseIf !(cUserName $ ZB1->ZB1_NOMES)

        Help(,,"Erro",,"Apenas o usuário que incluiu a prestação pode realizar modificações.", 1, 0,,,,,, {"Tente alterar uma prestação que você incluiu."})
        Return .F.

    EndIf

Return


/*/----------------------------
{Protheus.doc} U_ZB1Efe
Efetiva prestacao de compra
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
----------------------------/*/
User Function ZB1Efe()

    If cUsername == GetMV("MZ_APRPC")

        FWAlertError("APROVADORES não podem efetivar prestações de compra.", "Acesso negado")
        Return

    ElseIf ZB1->ZB1_LEGEND == "EFETIVADO"

        FWAlertError("Esta prestação já foi efetivada", "Erro")
        Return

    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"

        FWAlertError("Apenas prestações EM ABERTO podem ser efetivadas.", "Erro")
        Return

    Else

        ZB1->ZB1_LEGEND := "EFETIVADO"
        FWAlertSuccess("Prestação de compra efetivada.", "Sucesso")

    EndIf

Return


/*/-----------------------
{Protheus.doc} U_ZB1Apr1
Abre rotina de aprovacao
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
-----------------------/*/
User Function ZB1Apr1()

    Local aButtons :={{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,"Aprovar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

    If cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "EFETIVADO"

        lAprova := .T.
        FWExecView("Aprovação", "MITMVC", 4, , { || .T. },,,aButtons)
        lAprova := .F.

    ElseIf !(cUserName $ GetMV("MZ_APRPC"))

        FWAlertError("Apenas APROVADORES podem executar essa ação.", "Acesso negado")

    ElseIf !(ZB1->ZB1_LEGEND = "EFETIVADO")

        FWAlertError("Apenas pedidos EFETIVADOs podem ser APROVADOS", "Erro")

    EndIf

Return


/*/-------------------------
{Protheus.doc} U_ZB1Apr2
Aprova prestacoes de compra
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
-------------------------/*/
User Function ZB1Apr2()

    // Variável ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem transferidos
    Private aTransf  := {}
    // Tratamento de erro do MsExecAuto
    Private lMsErroAuto := .F.
    // Variáveis com conteúdo dos campos obrigatórios da rotina FINA050
    Private cPrefix     := SuperGetMV('MS_PREFIX'   , .F., "TPC"        )
    Private cNumTit     := ZB1->ZB1_COD
    Private cTipo       := SuperGetMV('MS_TIPO'     , .F., "TF"         )
    Private cNatu       := SuperGetMV('MS_NATURE'   , .F., "SAIDA"      )
    Private cFornece    := SuperGetMV('MS_FORNEC'   , .F., "000001"     )
    Private cLoja       := SuperGetMV('MS_LOJA'     , .F., "01"         )

    // Alguns dos campos obrigatórios da rotina FINA050:
    aAdd(aTransf, {"E2_PREFIXO"  , cPrefix          , NIL})
    aAdd(aTransf, {"E2_NUM"      , cNumTit          , NIL})
    aAdd(aTransf, {"E2_TIPO"     , cTipo            , NIL})
    aAdd(aTransf, {"E2_NATUREZ"  , cNatu            , NIL})
    aAdd(aTransf, {"E2_FORNECE"  , cFornece         , NIL})
    aAdd(aTransf, {"E2_LOJA"     , cLoja            , NIL})
    aAdd(aTransf, {"E2_EMISSAO"  , dDataBase        , NIL})

    // Campos da MIT que o conteúdo será transferido para FINA050
    aAdd(aTransf, {"E2_VENCTO"   , ZB1->ZB1_IDA     , NIL})
    aAdd(aTransf, {"E2_VENCREA"  , ZB1->ZB1_VOLTA   , NIL})
    aAdd(aTransf, {"E2_VALOR"    , ZB1->ZB1_VALOR   , NIL})
    aAdd(aTransf, {"E2_VLCRUZ"   , ZB1->ZB1_VALOR   , NIL})

    Begin Transaction

    // Função padrão TOTVS responsável por transferir os dados de uma rotina para outra.
    MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 3)

    // Verificação de erro padrão do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios foram preenchidos etc.
    If lMsErroAuto

        DisarmTransaction()
        MostraErro()

    ElseIf ZB1->ZB1_LEGEND = "EFETIVADO"

        RecLock("ZB1")
        ZB1->ZB1_LEGEND := "APROVADO "
        ZB1->(msunlock())
        FWAlertSuccess("Título APROVADO com êxito", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "EFETIVADO"

        FWAlertError("Apenas pedidos EFETIVADOs podem ser APROVADOS", "Erro")

    EndIf

    End Transaction

Return


/*/--------------------------
{Protheus.doc} U_ZB1Can
Cancela prestacoes de compra
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
--------------------------/*/
User Function ZB1Can()

    // Variável ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem deletados
    Private aTransf  := {}

    // Tratamento de erro do MsExecAuto
    Private lMsErroAuto := .F.

    // Variáveis com conteúdo dos campos obrigatórios da rotina FINA050
    Private cPrefix     := SuperGetMV('MS_PREFIX'   , .F., "TPC"        )
    Private cNumTit     := ZB1->ZB1_COD
    Private cTipo       := SuperGetMV('MS_TIPO'     , .F., "TF"         )
    Private cNatu       := SuperGetMV('MS_NATURE'   , .F., "SAIDA"      )
    Private cFornece    := SuperGetMV('MS_FORNEC'   , .F., "000001"     )
    Private cLoja       := SuperGetMV('MS_LOJA'     , .F., "01"         )

    // Alguns dos campos obrigatórios da rotina FINA050:
    aAdd(aTransf, {"E2_PREFIXO"  , cPrefix          , NIL})
    aAdd(aTransf, {"E2_NUM"      , cNumTit          , NIL})
    aAdd(aTransf, {"E2_TIPO"     , cTipo            , NIL})
    aAdd(aTransf, {"E2_NATUREZ"  , cNatu            , NIL})
    aAdd(aTransf, {"E2_FORNECE"  , cFornece         , NIL})
    aAdd(aTransf, {"E2_LOJA"     , cLoja            , NIL})
    aAdd(aTransf, {"E2_VENCTO"   , dDataBase        , NIL})

    // Campos da MIT que o conteúdo será deletado da FINA050
    aAdd(aTransf, {"E2_EMISSAO"  , ZB1->ZB1_IDA     , NIL})
    aAdd(aTransf, {"E2_VENCREA"  , ZB1->ZB1_VOLTA   , NIL})
    aAdd(aTransf, {"E2_VALOR"    , ZB1->ZB1_VALOR   , NIL})
    aAdd(aTransf, {"E2_VLCRUZ"   , ZB1->ZB1_VALOR   , NIL})

    // Verifica se usuario é APROVADOR e se pedido está APROVADO para que possa ser CANCELADO, então o cancela.
    If ZB1->ZB1_LEGEND = "APROVADO " .And. cUsername == GetMV("MZ_APRPC")

        If MsgYesNo("Título consta EM ABERTO, ao cancelar essa solicitação, o título gerado também será CANCELADO.", "Deseja prosseguir?")

            Begin Transaction
            // Função padrão TOTVS responsável por transferir os dados de uma rotina para outra, neste caso os deleta.
            MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 5)

            // Verificação de erro padrão do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios estão inclusos etc.
            If lMsErroAuto

                DisarmTransaction()
                MostraErro()

            Else

                RecLock("ZB1")
                ZB1->ZB1_LEGEND := "CANCELADO"
                ZB1->(msunlock())
                FWAlertSuccess("Título CANCELADO com êxito", "Sucesso")

            EndIf

            End Transaction

        Else

            Return

        EndIf

    ElseIf cUsername != GetMV("MZ_APRPC")

        FwAlertError("Apenas APROVADORES podem cancelar títulos.")

    ElseIf ZB1->ZB1_LEGEND != "APROVADO "

        FwAlertError("Apenas títulos APROVADOS podem ser CANCELADOs.")

    EndIf

Return


/*/------------------------------------
{Protheus.doc} U_ZB1Rev
Manda prestacao de compra para revisao
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
------------------------------------/*/
User Function ZB1Rev()

    If ZB1->ZB1_LEGEND = "EFETIVADO"

        RecLock("ZB1")
        ZB1->ZB1_OBSAPR := M->ZB1_OBSAPR
        ZB1->ZB1_LEGEND := "REVISÃO  "
        ZB1->(msunlock())
        FWAlertSuccess("Título em REVISÃO", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "EFETIVADO"

        FWAlertError("Apenas pedidos EFETIVADOs podem entrar para REVISÃO", "Erro")

    EndIf

Return


/*/-------------------------
{Protheus.doc} U_ZB1Del
Deleta prestacoes de compra
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
-------------------------/*/
User Function ZB1Del()

    If cUserName $ ZB1->ZB1_NOMES .And. ZB1->ZB1_LEGEND = "EM ABERTO"

        If MsgYesNo("Deseja excluir o título?", "Atenção")

            FWExecView("Excluir", "MITMVC", 5)

        Else

            Return

        EndIf

    ElseIf !(cUserName $ ZB1->ZB1_NOMES)

        FWAlertError("Apenas usuário que realizou a inclusão da prestação poderá excluir o registro", "Acesso negado!")

    ElseIf ZB1->ZB1_LEGEND != "EM ABERTO"

        FwAlertError("O status atual não permite a operação desejada", "Erro")

    EndIf

Return


/*/-------------------------
{Protheus.doc} U_ZB1Rel
Gera relatorio
@type User Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
-------------------------/*/
User Function ZB1Rel()

	Private oReport     := NIL
	Private oSection    := NIL
	Private cPerg		:= "ZB1MIT"
	Private cAlias      := GetNextAlias()

    // Prepara o relatório
	ReportDef()

    // Monta tela de impressão
	oReport:PrintDialog()

Return


/*/--------------------------
{Protheus.doc} ReportDef
Monta estrutura do relatorio
@type Static Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
--------------------------/*/
Static Function ReportDef()

    oReport := TReport():New("Relatório",,cPerg,{|oReport|PrintReport(oReport)})
    oSection := TRSection():New(oReport,,{"QRY"})

    TRCell():New(oSection,"ZB1_COD"         , "QRY","Cod prestação"     ,, 14   )
    TRCell():New(oSection,"ZB1_SOLIC"       , "QRY","Cod solic"         ,, 11   )
    TRCell():New(oSection,"ZB1_NOMES"       , "QRY","Nome solic"        ,, 13   )
    TRCell():New(oSection,"ZB1_ORIGEM"      , "QRY","Estado origem"     ,, 14   )
    TRCell():New(oSection,"ZB1_DEST"        , "QRY","Estado destino"    ,, 16   )
    TRCell():New(oSection,"ZB1_IDA"         , "QRY","Data ida"          ,, 9 ,, {||SToD(QRY->ZB1_IDA)} )
    TRCell():New(oSection,"ZB1_VOLTA"       , "QRY","Data volta"        ,, 9 ,, {||SToD(QRY->ZB1_VOLTA)} )
    TRCell():New(oSection,"ZB1_CDEST"       , "QRY","Cidade destino"    ,, 16   )
    TRCell():New(oSection,"ZB1_DURACA"      , "QRY","Duração"           ,, 7    )
    TRCell():New(oSection,"ZB1_VALOR"       , "QRY","Valor"             ,, 5    )
    TRCell():New(oSection,"ZB1_LEGEND"      , "QRY","Status"            ,, 9    )
    TRCell():New(oSection,"E2_BAIXA"        , "QRY","Data pg."          ,, 9 ,, {||SToD(QRY->E2_BAIXA)} )

Return (oReport)


/*/-------------------------------
{Protheus.doc} PrintReport
Busca e inclui dados ao relatorio
@type Static Function
@author Luiz Lustosa
@since 11/03/2024
@version 1.0
-------------------------------/*/
Static Function PrintReport(oReport)

    Local oSection := oReport:Section(1)
    Local cQuery

    cQuery :=   " SELECT                                                                            "
    cQuery +=   "   ZB1_COD, ZB1_SOLIC, ZB1_NOMES, ZB1_ORIGEM, ZB1_DEST, ZB1_IDA, ZB1_VOLTA,        "
    cQuery +=   "   ZB1_CDEST, ZB1_DURACA, ZB1_VALOR, ZB1_LEGEND,                                   "
    cQuery +=   "   E2_BAIXA                                                                        "
    cQuery +=   "       FROM ZB1990                                                                 "
    cQuery +=   "       LEFT JOIN SE2990 ON ZB1_COD = E2_NUM                                        "
    cQuery +=   "       WHERE ZB1990.D_E_L_E_T_ = ''                                                "
    cQuery +=   "           AND ZB1_COD BETWEEN     '" + MV_PAR05       + "' AND '" + MV_PAR06 + "' "
    cQuery +=   "           AND ZB1_IDA     >=      '" + DtoS(MV_PAR07) + "'                        "
    cQuery +=   "           AND ZB1_VOLTA   <=      '" + DtoS(MV_PAR08) + "'                        "
    cQuery +=   "           AND ZB1_ORIGEM  =       '" +      MV_PAR03  + "'                        "
    cQuery +=   "           AND ZB1_DEST    =       '" +      MV_PAR04  + "'                        "
    cQuery +=   "           AND ('" + MV_PAR10 + "' = 'SIM' OR E2_BAIXA IS NULL OR E2_BAIXA = '' )  "

    If MV_PAR09 = 'APROVADOS'

        cQuery += " AND ZB1_LEGEND = 'Aprovado' "

    EndIf

    If cUserName $ GetMV("MZ_APRPC")

        cQuery +=   " AND ZB1_SOLIC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "

    Else

        cQuery += " AND ZB1_SOLIC = '" + __cUserID + "' "

    EndIf

    If Select("QRY") > 0

        QRY->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "QRY"

    oSection:init()

    DbGoTop()

    While QRY->(!EoF())

        oSection:PrintLine()
        DbSkip()

    EndDo

    oSection:Finish()

Return
