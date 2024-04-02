#include 'Totvs.ch'
#include 'TopConn.ch'

User Function RELAT4()

    Local oReport
    Local cAlias := getNextAlias()

    oReport:=RptStruc(cAlias)

    oReport:PrintDialog()

Return

Static Function RptStruc(cAlias)

    Local cTitulo := "Pessoas"
    Local cHelp := "Imprime relatório"
    Local oReport
    Local oSection1
    Local oSection2

    oReport := TReport():New('RELAT4',cTitulo,/**/,{|oReport|RPrint(oReport, cAlias)},cHelp)

    oSection1 := TRSection():New(oReport,"NFs"  , {cAlias})
    TRCell():New(oSection1,"F1_DOC"     ,"SF1"  ,"N. Doc"           ,,27)
    TRCell():New(oSection1,"F1_SERIE"   ,"SF1"	,"Serie"            ,,27)
    TRCell():New(oSection1,"F1_FORNECE" ,"SF1"	,"Cod. Fornecedor"  ,,27)
    TRCell():New(oSection1,"F1_EMISSAO" ,"SF1"	,"Data Emissao"     ,,27)

    oSection2 := TRSection():New(oReport,"Itens", {cAlias})
    TRCell():New(oSection2,"D1_ITEM"    ,"SF1"  ,"Item"             ,,27)
    TRCell():New(oSection2,"D1_COD"     ,"SF1"  ,"Cod. Produto"     ,,27)
    TRCell():New(oSection2,"B1_DESC"    ,"SB1"  ,"Descricao"        ,,27)
    TRCell():New(oSection2,"D1_QUANT"   ,"SF1"  ,"Quantidade"       ,,27)
    TRCell():New(oSection2,"D1_VUNIT"   ,"SF1"  ,"Valor Unitario"   ,,27)
    TRCell():New(oSection2,"D1_TOTAL"   ,"SF1"  ,"Valor Total"      ,,27)

Return (oReport)

Static Function RPrint(oReport,cAlias)

    Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)

    oSection1:BeginQuery()

        BeginSQL Alias cAlias

            SELECT
                F1_DOC,
                F1_SERIE,
                F1_FORNECE,
                F1_EMISSAO
            FROM %Table:SF1% SF1
            WHERE D_E_L_E_T_ =''

            SELECT
                D1_ITEM, 
                D1_COD,
                D1_QUANT, 
                D1_VUNIT, 
                D1_TOTAL
            FROM %Table:SD1% SD1 
            WHERE D_E_L_E_T_ =''

            SELECT
                B1_DESC
            FROM %Table:SB1% SB1
            WHERE D_E_L_E_T_ =''

        EndSQL

        oSection1:EndQuery()
        oSection2:EndQuery()

        oSection1:Print()
        oSection2:Print()
        
        oReport:SetMeter((cAlias)->(RecCount()))
        
Return
