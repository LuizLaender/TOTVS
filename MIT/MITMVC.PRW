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

    // Filtro responsável por mostrar apenas as PCs criadas pelo usuário logado
    If cUserName != GetMV("MZ_APRPC")
        oBrowse:SetFilterDefault("ZB1->ZB1_NOMES == cUserName")
    EndIf

    // Legenda representando o status atual de cada PC
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'O'", "WHITE" , "Em Aberto"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'E'", "GREEN" , "Efetivado"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'R'", "YELLOW", "Revisão"     )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'C'", "GRAY"  , "Cancelado"   )
    oBrowse:AddLegend("ZB1->ZB1_LEGEND == 'A'", "RED"   , "Aprovado"    )

    oBrowse:Activate()

    FWRestArea(aArea)

Return


Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"      ACTION "U_ZB1Add()"     OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ZB1Alt1()"    OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MITMVC" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Efetivar"     ACTION "U_ZB1Efe()"     OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Aprovar"      ACTION "U_ZB1Apr1()"    OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Cancelar"     ACTION "U_ZB1Can()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ZB1Leg()"     OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "U_ZB1Del()"     OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Relatorio"    ACTION "VIEWDEF.MITMVC" OPERATION 6 ACCESS 0

Return aRotina


Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    // Condição para permitir ou não alteração de campos.
    If lAprova == .T.

        // O bloco {|| .T.}) PERMITE alteração. As estruturas a seguir serão ultilizadas em rotina de "APROVAÇÃO" pelo aprovador.
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


Static Function ViewDef()

    Local oModel  := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    oView := FWFormView():New()
    oView:AddUserButton("Aprovação" , "VIEW_ZB1", {|oView| U_ZB1Apr2()})
    oView:AddUserButton("Revisão"   , "VIEW_ZB1", {|oView| U_ZB1Rev()})

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

    // Oculta campos responsáveis pelo funcionamento da tela.
    oStruct:RemoveField("ZB1_LEGEND")

Return oView


// Função chamada ao clicar em "confirmar". Confere se as datas são válidas
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


// Função responsável por criar o botão "legenda" em "outras ações" da tela principal
User Function ZB1Leg()

    Local aLegenda := {}

    aAdd(aLegenda, {'BR_BRANCO'     , 'Em Aberto'   })
    aAdd(aLegenda, {'BR_VERDE'      , 'Efetivado'   })
    aAdd(aLegenda, {'BR_AMARELO'    , 'Revisão'     })
    aAdd(aLegenda, {'BR_CINZA'      , 'Cancelado'   })
    aAdd(aLegenda, {'BR_VERMELHO'   , 'Aprovado'    })

    BrwLegenda("Legenda", "", aLegenda)

Return aLegenda


//Função responsável por verificar se pode ser feita inclusão.
User Function ZB1Add()

    If cUsername $ GetMV("MZ_APRPC")

        FWAlertError("Aprovadores não podem fazer inclusões.", "Acesso negado!")
        Return

    Else

        FWExecView("Incluir", "MITMVC", 3, , { || .T. })

    EndIf

Return


// Função que verifica se o registro pode ou não ser alterado.
User Function ZB1Alt1()

    If (ZB1->ZB1_LEGEND = "O" .And. cUserName $ ZB1->ZB1_NOMES) // .OR. (cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "E")

        FWExecView("Alteração", "MITMVC", 4, , { || .T. })
        Return .T.

    ElseIf ZB1->ZB1_LEGEND != "O"

        Help(,,"Erro",,"Esta solicitação não pode ser alterada, pois já está em processo de aprovação.", 1, 0,,,,,, {"Tente alterar uma prestação EM ABERTO"})
        Return .F.

    ElseIf !(cUserName $ ZB1->ZB1_NOMES)

        Help(,,"Erro",,"Apenas o usuário que incluiu a prestação pode realizar modificações.", 1, 0,,,,,, {"Tente alterar uma prestação que você incluiu."})
        Return .F.

    EndIf

Return


// Função responsável por efetivar as PCs
User Function ZB1Efe()

    If cUsername == GetMV("MZ_APRPC")

        FWAlertError("Aprovadores não podem efetivar prestações de compra.", "Acesso negado")
        Return

    ElseIf ZB1->ZB1_LEGEND == "E"

        FWAlertError("Esta prestação já foi efetivada", "Erro")
        Return

    ElseIf ZB1->ZB1_LEGEND != "O"

        FWAlertError("Apenas prestações EM ABERTO podem ser efetivadas.", "Erro")
        Return

    Else

        ZB1->ZB1_LEGEND := "E"
        FWAlertSuccess("Prestação de compra efetivada.", "Sucesso")

    EndIf

Return


// Função responsável por abrir a rotina de aprovação.
User Function ZB1Apr1()

    Local aButtons :={{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,"Aprovar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

    If cUserName $ GetMV("MZ_APRPC") .And. ZB1->ZB1_LEGEND = "E"

        lAprova := .T.
        
        FWExecView("Aprovação", "MITMVC", 4, , { || .T. },,,aButtons)

        lAprova := .F.
    
    ElseIf !(cUserName $ GetMV("MZ_APRPC"))

        FWAlertError("Apenas aprovadores podem executar essa ação.", "Acesso negado")

    ElseIf !(ZB1->ZB1_LEGEND = "E")

        FWAlertError("Apenas pedidos efetivados podem ser aprovados", "Erro")

    EndIf

Return


// Função responsável por aprovar as PCs. Aprovar PCs = incluir dados do título selecionado em um novo título da rotina FINA050.
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
    
    ElseIf ZB1->ZB1_LEGEND = "E"

        RecLock("ZB1")
        ZB1->ZB1_LEGEND := "A"
        ZB1->(msunlock())

        FWAlertSuccess("Título aprovado com êxito", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "E"

        FWAlertError("Apenas pedidos efetivados podem ser aprovados", "Erro")

    EndIf

    End Transaction

Return


// Função responsável por cancelar as PCs aprovadas. Cancelar PCs = deletar o respectivo registo da FINA050.
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

    // Verifica se usuario é aprovador e se pedido está aprovado para que possa ser cancelado, então o cancela.
    If ZB1->ZB1_LEGEND == "A" .And. cUsername == GetMV("MZ_APRPC")

        If MsgYesNo("Título consta em aberto, ao cancelar essa solicitação, o título gerado também será cancelado.", "Deseja prosseguir?")

            Begin Transaction

            // Função padrão TOTVS responsável por transferir os dados de uma rotina para outra, neste caso os deleta.
            MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTransf, , 5)

            // Verificação de erro padrão do MsExecAuto. Verifica campos em conflito, se tds campos obrigatorios estão inclusos etc.
            If lMsErroAuto
            
                DisarmTransaction()
                MostraErro()
            
            Else

                RecLock("ZB1")
                ZB1->ZB1_LEGEND := "C"
                ZB1->(msunlock())

                FWAlertSuccess("Título cancelado com êxito", "Sucesso")

            EndIf

            End Transaction
        
        Else

            Return

        EndIf

    ElseIf cUsername != GetMV("MZ_APRPC")

        FwAlertError("Apenas aprovadores podem cancelar títulos.")

    ElseIf ZB1->ZB1_LEGEND != "A"

        FwAlertError("Apenas títulos aprovados podem ser cancelados.")

    EndIf

Return


// Função responsável por "Revisar" PCs = volta PC para estado "Em Aberto"
User Function ZB1Rev()

    If ZB1->ZB1_LEGEND = "E"

        RecLock("ZB1")
        ZB1->ZB1_OBSAPR := M->ZB1_OBSAPR
        ZB1->ZB1_LEGEND := "O"
        ZB1->(msunlock())

        FWAlertSuccess("Título em revisão", "Sucesso")

    ElseIf ZB1->ZB1_LEGEND != "E"

        FWAlertError("Apenas pedidos efetivados podem entrar para revisão", "Erro")

    EndIf
    
Return


// Função responsável por deletar PCs.
User Function ZB1Del()

    If cUserName $ ZB1->ZB1_NOMES .And. ZB1->ZB1_LEGEND == "O"

        If MsgYesNo("Deseja excluir o título?", "Atenção")
        
            FWExecView("Excluir", "MITMVC", 5)
        
        Else
        
            Return
        
        EndIf
    
    ElseIf !(cUserName $ ZB1->ZB1_NOMES)
        
        FWAlertError("Apenas usuário que realizou a inclusão da prestação poderá excluir o registro", "Acesso negado!")
    
    ElseIf ZB1->ZB1_LEGEND != "O"
    
        FwAlertError("O status atual não permite a operação desejada", "Erro")
    
    EndIf

Return
