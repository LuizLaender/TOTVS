 #include "Protheus.ch"
 #include "totvs.ch"

/*/{Protheus.doc} RELAT1
@Meu primeiro relatorio
@author Luiz Lustosa
@since 01/02/2024
@version 1.0
/*/

// Declara inicio da fun��o que ir� estabelecer as configura��es do relat�rio.
User function RELAT1()
	// o objeto oReport habilita a customiza��o do relat�rio, tamanho, layout, dados exibidos e etc. Nas proximas linhas deste codigo ele vai receber o valor de ReportDef(aPergs, aResps).
	Local oReport	:= Nil

	// o objeto aPergs ir� receber uma s�rie de configura��es que ser�o determinadas a seguir.
	Local aPergs	:= {}

	// o objeto aResps ir� receber as respostas do usu�rio.
	Local aResps	:= {}

	// aqui estabelecemos quais perguntas aparecer�o  no momento de cria��o do relat�rio.
	AAdd(aPergs, {1, "Filial de", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .F.})
	AAdd(aPergs, {1, "Filial at�", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .F.})

	// SE o usu�rio responder as perguntas, ent�o entregamos as respostas(aResps) para o objeto ReportDef
	If ParamBox(aPergs, "Par�metros do relat�rio", @aResps,,,,,,,, .T., .T.)

		// aqui entregamos todas as respostas do usuario para dentro do objeto ReportDef
		oReport := ReportDef(aResps)

		// faz a impress�o do relat�rio
		oReport:PrintDialog()

	EndIf

Return Nil





// Declara inicio da fun��o que ir� coletar os dados das tabelas para poder gerar o relat�rio.
Static Function ReportDef(aResps)

	Local oReport	:= Nil
	Local oSection	:= Nil

	// armazena area temporaria da query
	Local cAliasTop	:= ""

	// nome do arquivo q vai ser gerado com data e hora
	Local cNomArq	:= "RELAT1_" + DToS(Date()) + StrTran(Time(), ":", "")

	// nome do relatorio
	Local cTitulo	:= "Relatorio Cadastro de Pessoas"


	// oReport receber� o retorno da fun��o padrao TReport()
	oReport := TReport():New(cNomarq, cTitulo, "", {|oReport| ReportPrint(oReport, @cAliasTop, aResps)}, "Este programa tem como objetivo imprimir informa��es do relat�rio")

	// estabelece que o relat�rio seja impresso em formato de retrato
	oReport:SetPortrait()

	// quais tabelas ser�o ultilizadas no relat�rio
	oSection := TRSection():New(oReport, cTitulo, {"ZA1"})

	// determina quais c�lulas o relat�rio ir� gerar de acordo com os campos
	// TRCell():New(ObjetodaSessao, "CodigodoCampo" , "AliasdaTabela", "NomedoCampo", Mascara, Tamanho, lPixel, {|| code-block de impressao })
	TRCell()New:(oSection, "ZA1_COD"	, "cAliasTop"	, "Codigo"				,,,, {|| (cAliasTop)->COD	})
	TRCell()New:(oSection, "ZA1_NOMEC"	, "cAliasTop"	, "Nome Completo"		,,,, {|| (cAliasTop)->NOMEC	})
	TRCell()New:(oSection, "ZA1_NOME"	, "cAliasTop"	, "Primeiro Nome"		,,,, {|| (cAliasTop)->NOME	})
	TRCell()New:(oSection, "ZA1_ALT"	, "cAliasTop"	, "Altura"				,,,, {|| (cAliasTop)->ALT	})
	TRCell()New:(oSection, "ZA1_PESO"	, "cAliasTop"	, "Peso"				,,,, {|| (cAliasTop)->PESO	})
	TRCell()New:(oSection, "ZA1_DATA"	, "cAliasTop"	, "Data de Nascimento"	,,,, {|| (cAliasTop)->DATA	})
	TRCell()New:(oSection, "ZA1_IDADE"	, "cAliasTop"	, "Idade"				,,,, {|| (cAliasTop)->IDADE	})

// retorna valores buscados
Return oReport


// inicia fun��o padrao que cont�m a logica da query recebendo par�metros estabelecidos previamente.
Static Function ReportPrint(oReport, cAliasTop, aResps)

	Local oSection	:= oReport:Section(1)
	Local cQuery	:= ""
	Local cFilDe	:= aResps[1]
	Local cFilDe	:= aResps[2]


	// SELECT seleciona quais campos do protheus ser�o relatados.
	cQuery := "SELECT " 				+ CRLF
	cQuery += "	ZA1_COD " 				+ CRLF
	cQuery += "	, ZA1_NOMEC "		 	+ CRLF
	cQuery += "	, ZA1_NOME "		 	+ CRLF
	cQuery += "	, ZA1_ALT " 			+ CRLF
	cQuery += "	, ZA1_PESO " 			+ CRLF
	cQuery += "	, ZA1_DATA " 			+ CRLF
	cQuery += "	, ZA1_IDADE " 			+ CRLF
	cQuery += "	, ZA1_DESC " 			+ CRLF

	// FROM escolhe em qual tabela(ZA1990) procurar os campos e lhe d� um apelido (ZA1).
	cQuery += "FROM ZA1990 ZA1 " 		+ CRLF

	// WHERE filtra as linhas que o SELECT retorna.
	cQuery += "WHERE"					+ CRLF

	// filtra os registros deletados, n�o os apresentando no relat�rio.
	cQuery += "ZA1.D_E_L_E_T_ = ' ' " 	+ CRLF

	// AND � ultilizado em conjun��o com WHERE para indicar outras condi��es de filtro.
	cQuery += "AND "					+ CRLF

	// deixar o campo em branco aqui significa que o uso � compartilhado, ou seja, o SELECT vai retornar todos os campos de todas as filiais. Se tivesse preenchido com alguma filial ex: MATRIZ, retornaria apenas os campos que pertencentes a MATRIZ.
	cQuery += "ZA1_FILIAL = ' ' "		+ CRLF

	cAliasTop := MPSysOpenQuery(cQuery)

Return
