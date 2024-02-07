 #include "Protheus.ch"

/*/{Protheus.doc} RELAT01
@Meu primeiro relatorio
@author Luiz Lustosa
@since 01/02/2024
@version 1.0
/*/

// Declara inicio da função que irá estabelecer as configurações do relatório.
User function RELAT01()
	// o objeto oReport habilita a customização do relatório, tamanho, layout, dados exibidos e etc. Nas proximas linhas deste codigo ele vai receber o valor de ReportDef(aPergs, aResps).
	Local oReport	:= Nil

	// o objeto aPergs irá receber uma série de configurações que serão determinadas a seguir.
	Local aPergs	:= {}

	// o objeto aResps irá receber as respostas do usuário.
	Local aResps	:= {}

	// aqui estabelecemos quais perguntas aparecerão  no momento de criação do relatório.
	AAdd(aPergs, {1, "Filial de", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .F.})
	AAdd(aPergs, {1, "Filial até", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .F.})

	// SE o usuário responder as perguntas, então entregamos as respostas(aResps) para o objeto ReportDef
	If ParamBox(aPergs, "Parâmetros do relatório", @aResps,,,,,,,, .T., .T.)

		// aqui entregamos todas as respostas do usuario para dentro do objeto ReportDef
		oReport := ReportDef(aResps)

		// faz a impressão do relatório
		oReport:PrintDialog()

	EndIf

Return Nil





// Declara inicio da função que irá coletar os dados das tabelas para poder gerar o relatório.
Static Function ReportDef(aResps)

Local oReport	:= Nil
Local oSection	:= Nil

// armazena area temporaria da query
Local cAliasTop	:= ""

// nome do arquivo q vai ser gerado com data e hora
Local cNomArq	:= "RELAT01_" + DToS(Date()) + StrTran(Time(), ":", "")

// nome do relatorio
Local cTitulo	:= "Relatorio Cadastro de Pessoas"


// oReport receberá o retorno da função padrao TReport()
oReport := TReport():New(cNomarq, cTitulo, "", {|oReport| ReportPrint(oReport, @cAliasTop, aResps)}, "Este programa tem como objetivo imprimir informações do relatório")

// estabelece que o relatório seja impresso em formato de retrato
oReport:SetPortrait()

// quais tabelas serão ultilizadas no relatório
oSection := TRSection():New(oReport, cTitulo, {"ZA1"})

// determina quais células o relatório irá gerar de acordo com os campos
// TRCell():New(ObjetodaSessao, "CodigodoCampo" , "AliasdaTabela", "NomedoCampo", Mascara, Tamanho, lPixel, {|| code-block de impressao })
TRCell()New:(oSection, "ZA1_COD"	, "cAliasTop"	, "Codigo"				,,,, {|| (cAliasTop)->COD	})
TRCell()New:(oSection, "ZA1_NOMEC"	, "cAliasTop"	, "Nome Completo"		,,,, {|| (cAliasTop)->NOMEC	})
TRCell()New:(oSection, "ZA1_NOME"	, "cAliasTop"	, "Primeiro Nome"		,,,, {|| (cAliasTop)->NOME	})
TRCell()New:(oSection, "ZA1_ALT"	, "cAliasTop"	, "Altura"				,,,, {|| (cAliasTop)->ALT	})
TRCell()New:(oSection, "ZA1_PESO"	, "cAliasTop"	, "Peso"				,,,, {|| (cAliasTop)->PESO	})
TRCell()New:(oSection, "ZA1_DATA"	, "cAliasTop"	, "Data de Nascimento"	,,,, {|| (cAliasTop)->DATA	})
TRCell()New:(oSection, "ZA1_IDADE"	, "cAliasTop"	, "Idade"				,,,, {|| (cAliasTop)->IDADE	})
TRCell()New:(oSection, "ZA1_DESC"	, "cAliasTop"	, "Descricao"			,,,, {|| (cAliasTop)->DESC	})

// retorna valores buscados
Return oReport


// inicia função padrao que contém a logica da query recebendo parâmetros estabelecidos previamente.
Static Function ReportPrint(oReport, cAliasTop, aResps)

Local oSection	:= oReport:Section(1)
Local cQuery	:= ""
Local cFilDe	:= aResps[1]
Local cFilDe	:= aResps[2]


// SELECT seleciona quais campos do protheus serão relatados.
cQuery := "SELECT " 				+ CRLF
cQuery += "	ZA1_COD " 				+ CRLF
cQuery += "	, ZA1_NOMEC "		 	+ CRLF
cQuery += "	, ZA1_NOME "		 	+ CRLF
cQuery += "	, ZA1_ALT " 			+ CRLF
cQuery += "	, ZA1_PESO " 			+ CRLF
cQuery += "	, ZA1_DATA " 			+ CRLF
cQuery += "	, ZA1_IDADE " 			+ CRLF
cQuery += "	, ZA1_DESC " 			+ CRLF

// FROM escolhe em qual tabela(ZA1990) procurar os campos e lhe dá um apelido (ZA1).
cQuery += "FROM ZA1990 ZA1 " 		+ CRLF

// WHERE filtra as linhas que o SELECT retorna.
cQuery += "WHERE"					+ CRLF

// filtra os registros deletados, não os apresentando no relatório.
cQuery += "ZA1.D_E_L_E_T_ = ' ' " 	+ CRLF

// AND é ultilizado em conjunção com WHERE para indicar outras condições de filtro.
cQuery += "AND "					+ CRLF

// deixar o campo em branco aqui significa que o uso é compartilhado, ou seja, o SELECT vai retornar todos os campos de todas as filiais. Se tivesse preenchido com alguma filial ex: MATRIZ, retornaria apenas os campos que pertencentes a MATRIZ.
cQuery += "ZA1_FILIAL = ' ' "		+ CRLF

cAliasTop := MPSysOpenQuery(cQuery)
