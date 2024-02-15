#include 'Totvs.ch'
#include 'TopConn.ch'


User Function RELAT3()

    Local oReport
    Local cAlias := 'ZA1'

    oReport := RptStruc(cAlias)

    oReport:PrintDialog()

Return


Static Function RPrint(oReport,cAlias)
    Local oSection1 := oReport:Section(1)
    DBSelectArea(cAlias)
    DBGoTop()
    While !Eof()
        oSection1:SetMeter((cAlias)->(RecCount()))
        oSection1:Print()
    EndDo
Return


Static Function RptStruc(cAlias)

    Local cTitulo := "Pessoas"
    Local cHelp := "Imprime relatório"
    Local oReport
    Local oSection1

    oReport := TReport():New('RELAT3',cTitulo,/**/,{|oReport|RPrint(oReport, cAlias)},cHelp)

    oSection1 := TRSection():New(oReport, "Pessoas", {cAlias})

    TRCell():New(oSection1,"ZA1_COD"    , cAlias, "Codigo"            )
    TRCell():New(oSection1,"ZA1_NOMEC"  , cAlias, "Nome Completo"     )
    TRCell():New(oSection1,"ZA1_NOME"   , cAlias, "Primeiro nome"     )
    TRCell():New(oSection1,"ZA1_ALT"    , cAlias, "Altura"            )
    TRCell():New(oSection1,"ZA1_PESO"   , cAlias, "Peso"              )
    TRCell():New(oSection1,"ZA1_DATA"   , cAlias, "Data de Nascimento")
    TRCell():New(oSection1,"ZA1_IDADE"  , cAlias, "Idade"             )

Return (oReport)
