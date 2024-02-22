#include 'Totvs.ch'
#include 'TopConn.ch'


User Function RELAT4()

    Local oReport
    Local cAlias := getNextAlias()

    oReport:=RptStruc(cAlias)

    oReport:PrintDialog()

Return


Static Function RPrint(oReport,cAlias)

    Local oSecao1 := oReport:Section(1)

    oSecao1:BeginQuery()

        BeginSQL Alias cAlias

            SELECT F1_DOC, F1_SERIE, F1_FORNECE, F1_EMISSAO
            FROM %Table:SF1% SF1
            WHERE D_E_L_E_T_ =''

        EndSQL

        oSecao1:EndQuery()
        oReport:SetMeter((cAlias)->(RecCount()))

        oSecao1:Print()
Return


Static Function RptStruc(cAlias)

    Local cTitulo := "Pessoas"
    Local cHelp := "Imprime relatório"
    Local oReport
    Local oSection1

    oReport := TReport():New('RELAT4',cTitulo,/**/,{|oReport|RPrint(oReport, cAlias)},cHelp)

    oSection1 := TRSection():New(oReport, "Pessoas", {cAlias})

    TRCell():New(oSection1,"F1_DOC"     ,"SF1"      ,"N. Doc"           ,,27)
    TRCell():New(oSection1,"F1_SERIE"   ,"SF1"		,"Serie"            ,,27)
    TRCell():New(oSection1,"F1_FORNECE" ,"SF1"		,"Cod. Fornecedor"  ,,27)
    TRCell():New(oSection1,"F1_EMISSAO" ,"SF1"		,"Data Emissao"     ,,27)


Return (oReport)
