#include 'Totvs.ch'
#include 'TopConn.ch'


User Function RELAT2()

    Local oReport
    Local cAlias := getNextAlias()

    oReport:=RptStruc(cAlias)

    oReport:PrintDialog()

Return


Static Function RPrint(oReport,cAlias)

    Local oSecao1 := oReport:Section(1)

    oSecao1:BeginQuery()

        BeginSQL Alias cAlias

            SELECT ZA1_COD, ZA1_DESC, ZA1_NOME
            FROM %Table:ZA1% ZA1
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

    oReport := TReport():New('RELAT2',cTitulo,/**/,{|oReport|RPrint(oReport, cAlias)},cHelp)

    oSection1 := TRSection():New(oReport, "Pessoas", {cAlias})

    TRCell():New(oSection1,"ZA1_COD"    , "ZA1", "Codigo"           )
    TRCell():New(oSection1,"ZA1_DESC"   , "ZA1", "Descricao"        )
    TRCell():New(oSection1,"ZA1_NOME"   , "ZA1", "Primeiro nome"    )

Return (oReport)
