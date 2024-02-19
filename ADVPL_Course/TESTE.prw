
#include "totvs.ch"
#define DATA_ATUAL := date()

User Function TESTE

    Local dData     := DATA_ATUAL
    Local nCount    := 1
    Local lReturn   := .T.

    If dDate = date()
        nCount := 2
    Else 
        Return .F.
    Endif

Return lReturn
