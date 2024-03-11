 #include "totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} xMBrowse
Tela de criação de pessoas
@type user function
@author Luiz Lustosa
@since 26/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MIT01()

    Local cAlias := "ZB1"

    Private cCadastro   := "MIT"
    Private aRotina     := { }

    AAdd(aRotina, {"Pesquisar"  ,"AxPesqui" ,0,1})
    AAdd(aRotina, {"Visualizar" ,"AxVisual" ,0,2})
    AAdd(aRotina, {"Incluir"    ,"AxInclui" ,0,3})
    AAdd(aRotina, {"Alterar"    ,"AxAltera" ,0,4})
    AAdd(aRotina, {"Excluir"    ,"AxDeleta" ,0,5})

    DBSelectArea(cAlias)
    DBSetOrder(1)

    mBrowse(6, 1, 22, 75, cAlias)

Return Nil
