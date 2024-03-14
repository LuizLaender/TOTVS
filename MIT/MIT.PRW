#INCLUDE 'FWMVCDEF.CH'
#include "totvs.ch"

Static cTitulo := "MIT"
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

    Local aArea   := FWGetArea()
    Local oBrowse
    Private aRotina := {}

    // // variaveis responsaveis pelo controle de usuario
    // Private usrapr := .F.

    // // verifica antes de abrir a tela se o usuário logado é aprovador
    // If cUserName == GetMV("MZ_APRPC")
    //     usrapr := .T.
    //     FWAlertInfo("Usuario logado: Aprovador", "Status de login")
    // ElseIf cUserName <> GetMV("MZ_APRPC")
    //     FWAlertInfo("Usuário não é funcionário ou aprovador", "Status de login")
    // Endif

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

    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MIT" OPERATION 2 ACCESS 0

    // Apenas funcionarios podem incluir
    If cUserName != GetMV("MZ_APRPC")
        ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.MIT" OPERATION 3 ACCESS 0
    EndIf

    // Apenas funcionarios podem alterar (suas próprias inclusões)
    If cUserName != GetMV("MZ_APRPC")
        ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.MIT" OPERATION 4 ACCESS 0
    EndIf    

    // Apenas funcionarios podem excluir (suas próprias inclusões)
    If cUserName != GetMV("MZ_APRPC")
        ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.MIT" OPERATION 5 ACCESS 0
    EndIf

    ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.MIT" OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"       ACTION "VIEWDEF.MIT" OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    oModel := MPFormModel():New("MD_ZB1")
    oModel:AddFields("MASTERZB1",, oStruct)
    oModel:SetPrimaryKey({'ZB1_FILIAL','ZB1_COD'})

Return oModel

Static Function ViewDef()

    Local oModel := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

    oStruct:removeField("ZB1_LEGEND")


Return oView

    // ExecAuto
User Function ExeAu()

    // Variável ultilizada no MsExecAuto para receber arrays contendo campo e conteudos a serem transferidos
    Private aExecA  := {}

    // Tratamento de erro do MsExecAuto
    Private lMsErroAuto := .F.

    // Variaveis com conteúdo dos campos que serão enviados para FINA050
    

    // Colocamos em arrays o conteudo que será transferido
  //aAdd(array,  {campo que recebe  , conteudo a ser transferido })
    // aAdd(aExecA, {"E2_NUM"          , })
    // aAdd(aExecA, {"E2_TIPO"         , })
    // aAdd(aExecA, {"E2_NATUREZ"      , })
    // aAdd(aExecA, {"E2_FORNECE"      , })
    // aAdd(aExecA, {"E2_LOJA"         , })
    // aAdd(aExecA, {"E2_EMISSAO"      , })
    // aAdd(aExecA, {"E2_VENCTO"       , })
    // aAdd(aExecA, {"E2_VENCREA"      , })
    // aAdd(aExecA, {"E2_VALOR"        , })
    // aAdd(aExecA, {"E2_VLCRUZ"       , })
    aAdd(aExecA, {"B1_COD"      , "TESTE"})
    aAdd(aExecA, {"B1_DESC"     , "TESTE"})
    aAdd(aExecA, {"B1_TIPO"     , "ME"})
    aAdd(aExecA, {"B1_UM"       , "KG"})
    aAdd(aExecA, {"B1_LOCPAD"   , "01"})

    Begin Transaction

    MsExecAuto({|x,y| MATA010(x,y)}, aExecA, 3)

    If lMsErroAuto
        DisarmTransaction()
        MostraErro()
    EndIf

    End Transaction

    MsgInfo("Processo concluido")

Return
