#include "Totvs.ch"

User Function RELAT3

    RpcSetEnv("99","01")

    Public oReport
    
    RptStruc()

    oReport:PrintDialog()

    RpcClearEnv()

Return


Static Function RPrint(oReport)

    Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    
    SF1->(DBSeeK(cSeek := Xfilial("SF1") + SD1->D1_DOC))
    SF1->(DBSetOrder(1))

    SD1->(DBGoTop())
    SF1->(DBGoTop())

    While SF1->(!EoF())

        // Posicione("SB1",1,Xfilial("SB1")+SD1->D1_COD,"B1_DESC")

        oSection1:init()
        oSection1:PrintLine()
        oSection1:Finish()

        While SD1->(!EoF()) .And. (SD1->(D1_DOC) == SF1->(F1_DOC))
          //Posicione == Percorra toda a tabela SB1, procurando o campos das tabelas SB1 e Sd1 com conteudos iguais, e posicione na coluna B1_DESC.
            Posicione("SB1",1,Xfilial("SB1")+SD1->D1_COD,"B1_DESC")
            
            oSection2:init()
            oSection2:PrintLine()

            // oReport:ThinLine()

            SD1->(DbSkip())

        EndDo

        oSection2:Finish()

        SF1->(DbSkip())
        
    EndDo

    oReport:EndPage()

Return


Static Function RptStruc()

    oReport := TReport():New("RELAT3",,,{|oReport|RPrint(oReport)})

    oSection1 := TRSection():New(oReport)
        TRCell():New(oSection1,"F1_DOC"     ,"SF1",,,12)
        TRCell():New(oSection1,"A2_NOME"    ,"SA2",,,20)
        TRCell():New(oSection1,"F1_FORNECE" ,"SF1",,,12)
        TRCell():New(oSection1,"F1_EMISSAO" ,"SF1",,,12)

    oSection2 := TRSection():New(oReport)
        TRCell():New(oSection2,"D1_ITEM"    ,"SD1",,,27)
        TRCell():New(oSection2,"D1_COD"     ,"SD1",,,27)
        TRCell():New(oSection2,"B1_DESC"    ,"SB1",,,27)
        TRCell():New(oSection2,"D1_QUANT"   ,"SD1",,,27)
        TRCell():New(oSection2,"D1_VUNIT"   ,"SD1",,,27)
        TRCell():New(oSection2,"D1_TOTAL"   ,"SD1",,,27)

        TRFunction():New(oSection2:Cell("D1_TOTAL"),,"SUM",,,,,.T.)

Return
