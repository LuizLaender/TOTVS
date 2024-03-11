#INCLUDE 'FWMVCDEF.CH'
#include "totvs.ch"

/*/------------------------------
| {Protheus.doc} MVC            |
| Tela MIT                      |
| @type user function           |
| @author Luiz Lustosa          |
| @since 11/03/2024             |
| @version 1.0                  |
------------------------------/*/
// User Function MIT02()

//     Local cAlias := "ZB1"

//     Private cCadastro   := "MIT"
//     Private aRotina     := { }

//     AAdd(aRotina, {"Pesquisar"  ,"AxPesqui" ,0,1})
//     AAdd(aRotina, {"Visualizar" ,"AxVisual" ,0,2})
//     AAdd(aRotina, {"Incluir"    ,"AxInclui" ,0,3})
//     AAdd(aRotina, {"Alterar"    ,"AxAltera" ,0,4})
//     AAdd(aRotina, {"Excluir"    ,"AxDeleta" ,0,5})

//     DBSelectArea(cAlias)
//     DBSetOrder(1)

//     mBrowse(6, 1, 22, 75, cAlias)

// Return Nil

// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------

/*/{Protheus.doc} User Function MIT02
Cadastro tabela ZB1
@author LUiz A.
@since 16/11/2023
@version 1.0
@type function
/*/

Static cTitulo := "MIT"
Static cAliasMVC := "ZB1"

User Function MIT02()

    Local aArea   := FWGetArea()
    Local oBrowse
    Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    //Ativa a Browse
    oBrowse:Activate()

    FWRestArea(aArea)

Return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao MIT02
@author LUiz A.
@since 16/11/2023
@version 1.0
@type function
/*/

Static Function MenuDef()

    Local aRotina := {}

    // //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.MIT02" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.MIT02" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.MIT02" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.MIT02" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.MIT02" OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"       ACTION "VIEWDEF.MIT02" OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao MIT02
@author Luiz A.
@since 16/11/2023
@version 1.0
@type function
/*/

Static Function ModelDef()

    Local oModel
    Local oStruct := FWFormStruct(1, cAliasMVC)

    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("MD_ZB1")
    oModel:AddFields("MASTERZB1",, oStruct)
    oModel:SetPrimaryKey({'ZB1_FILIAL','ZB1_COD'})

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao MIT02
@author LUiz A.
@since 16/11/2023
@version 1.0
@type function
/*/

Static Function ViewDef()

    Local oModel := ModelDef()
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    
    oView:AddField("VIEW_ZB1", oStruct, "MASTERZB1")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZB1", "TELA")

Return oView
