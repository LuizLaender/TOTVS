#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#include "FWMVCDEF.CH"
#include "topconn.CH"

/*/{Protheus.doc} CAEA0050
Funcao para cadastro Prestacao de Contas Solicitacao de Suprimento de Fundos
Z12 - Cabecalho
Z13 - Itens
@author Jose Vitor
@since 01/05/2018
@version 1.0
@type function
/*/
User Function CAEA0050()
	Local oBrowse
    Private cMatLog			:= ''//U_CAEA004i(.T.)	
	Private cMatSub 		:= ''//retMatSub(cMatLog)
	Private cString 		:= "Z12"                         
	Private lFinanceiro		:= __cUserId $ SuperGetMv('MS_USRFINA', .F., "000000")   
	Private cProdCXI 		:= u_GetParam('PRODUTOCXI',.T.,'33963')
	//Montagem do Browse principal	
	oBrowse := FWMBrowse():New()

	//Legenda
	oBrowse:AddLegend('Z12_STATUS ==  "R" ' , 'BR_VERDE'    , 'Aberto'  	)
	oBrowse:AddLegend('Z12_STATUS ==  "E" ' , 'BR_VERMELHO' , 'Efetivado'   )
	oBrowse:AddLegend('Z12_STATUS ==  "C" ' , 'BR_CANCEL'   , 'Cancelado'	)
	oBrowse:AddLegend('Z12_STATUS ==  "F" ' , 'BR_PRETO'    , 'Fechado'     )

	//Define alias principal
	oBrowse:SetAlias('Z12')
	oBrowse:SetDescription('Prestacao de Contas Solicitacao de Suprimento de Fundos')
	oBrowse:SetMenuDef('CAEA0050')
	aRet := U_CAEA004i(.T.)
	cMatLog := aRet[1]
	//Se usuario estiver d férias ou não possuir cadastro SFF, não deixa entrar na tela
	If aRet[2] == 1 .Or. (aRet[2] == 2 .AND. !lFinanceiro)
		Return
	EndIf
	//Pega matricula do suprido que estou substituindo
	cMatSub 		:= retMatSub(cMatLog)
    //Valida se o usuario logado tem vinculo no cadastro de funcionario
	//se nao tiver, mas for do finaceiro entao, permitira o acesso     
	If Empty(cMatLog) .AND. !lFinanceiro
		ApMsgInfo('O usuário logado não está vinculado a um funcionario ou está em afastamento/férias. Não é possível continuar.')
		Return		
	ElseIf !Empty(cMatLog) .AND. !lFinanceiro
		SA6->(DbOrderNickName('A6_YCODSRA'))
		If ! SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))   	
			ApMsgInfo('Você não possui um cadastro de fundo fixo para realizar a prestação de contas.')			
			Return
		ElseIf !Empty(SA6->A6_YMATSUP)
			ApMsgInfo('Seu banco está sob responsabilidade do suprido substituto matr.: ' + alltrim(SA6->A6_YMATSUP) + '. Favor, entre em contato com UNFI - UNIDADE DE FINANCAS')
		EndIf
	EndIf

	oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Retorna o menu principal
@author Jose Vitor
@since 01/05/2018
@version 1.0
@type function
@return array, Array com os dados para os botoes do browse
/*/ 
Static Function MenuDef()
	Local aRotina := {}
    
    aAdd( aRotina, { 'Visualizar'		, 'VIEWDEF.CAEA0050'	, 0, 2, 0, NIL } ) 
    aAdd( aRotina, { 'Incluir' 			, 'VIEWDEF.CAEA0050'	, 0, 3, 0, NIL } )    
	//Rotina é chamada quando se clica no menu esquerdo do módulo.
	//Pois é carregado o MenuDef, e nesse momento a variavel lFinanceiro não existe.	
	If Empty(Funname())
		Return aRotina
	EndIf

	aAdd( aRotina, { 'Alterar' 			, 'VIEWDEF.CAEA0050'	, 0, 4, 0, NIL } )
    aAdd( aRotina, { 'Excluir' 			, "VIEWDEF.CAEA0050"	, 0, 5, 0, NIL } )    
	aAdd( aRotina, { 'Fechar'			, "U_CAEA050e('F')"		, 0, 5, 0, NIL } )
    aAdd( aRotina, { 'Reabrir'			, "U_CAEA050h()"		, 0, 5, 0, NIL } )    
	aAdd( aRotina, { 'Imprimir'			, "Iif(Z12->Z12_STATUS $ 'E,F', u_CAER0003(),Alert('Não é possível imprimir com o status atual'))"      , 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Prest. Substituto', "U_CAEA050J()"		, 0, 3, 0, NIL } )


    //Se for um usuario do financeiro entao ira adicionar as opcaoes de cancelamento                   
	//e efetivacao da prestacao de contas, se nao, ira filtrar apenas as solicitacoes do usuario logado
	If lFinanceiro
		aAdd(aRotina, {"Cancelar"			,"MsAguarde({|| U_CAEA050e('C')},'Cancelando Efetivação')"	,0,4})
		aAdd(aRotina, {"Efetivar"			,"MsAguarde({|| U_CAEA050e('E')},'Realizando Efetivação')"	,0,4})
  	Else
		DbSelectArea('Z12')
		SET FILTER TO Z12->Z12_CODSRA == cMatLog .Or. (Z12->Z12_CODSRA == cMatSub .And. Z12->Z12_STATUS $ 'R,F')
  	EndIf

Return aRotina

/*/{Protheus.doc} ModelDef
Construcao do modelo de dados
@author Jose Vitor
@since 01/05/2018
@version 1.0
@type function
@return object, Retorna o objeto do modelo de dados
/*/
Static Function ModelDef()
	Local oModel
	Local oStruZ12 := FWFormStruct(1,"Z12")	
	Local oStruZ13 := FWFormStruct(1,"Z13")
	Local oStruZ14 := FWFormStruct(1,"Z14")

	//Cria o formulario do modelo                                        //TudoOk	           				GravaDados          { |oModel| fGrvDados( oModel ) }
	oModel := MPFormModel():New("CAEA050", /*bPreValidacao*/, { |oModel| U_CAEA050d(oModel) }, /* GravaDados */, /*bCancel*/ )

	//Cria a estrutura principal(Z12)
	oModel:addFields('MASTERZ12',,oStruZ12)

	//Adiciona a chave
	oModel:SetPrimaryKey({'Z12_FILIAL', 'Z12_CODIGO'})

	//bPreValidacao: Antes de entrar no campo para inserir dados
	//Cria estrutura de grid para os itens 											Linok
	oModel:AddGrid('Z13DETAIL','MASTERZ12',oStruZ13, /*bPreValidacao*/, { |oModel| u_CAEA050b(oModel) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	//Define a relacao entre as tabelas
	oModel:SetRelation('Z13DETAIL',{{'Z13_FILIAL','xFilial("Z13")'},{'Z13_CODZ12','Z12_CODIGO'}},Z13->(IndexKey(1)))

    aCamposZ14 := {}
	aAdd(aCamposZ14,{ 'Z14_FILIAL'	, "xFilial('Z14')" })
	aAdd(aCamposZ14,{ 'Z14_CODZ12'	, "Z12_CODIGO" })
	aAdd(aCamposZ14,{ 'Z14_SEQZ13'	, "Z13_SEQ"    })

    //Cria estrutura de grid para os itens
	oModel:AddGrid('Z14DETAIL', 'Z13DETAIL', oStruZ14)
	//Define a relacao entre as tabelas
	oModel:SetRelation('Z14DETAIL', aCamposZ14, Z14->(IndexKey(1)))
    
	//Define a descricao dos modelos
	oModel:GetModel( 'MASTERZ12' ):SetDescription( 'Notas' )
	oModel:GetModel( 'Z13DETAIL' ):SetDescription( 'Notas | Recibos | Depositos | NF-e' )
	oModel:GetModel( 'Z14DETAIL' ):SetDescription( 'Itens | Detalhes' )

	//Define que o preenchimento da grid e' opcional
	oModel:GetModel('Z13DETAIL'):SetOptional( .T. )
	oModel:GetModel('Z14DETAIL'):SetOptional( .T. )

	//Define que a linha nao podera ter o conteudo repetido
	oModel:GetModel('Z13DETAIL'):SetUniqueLine({'Z13_FILIAL','Z13_CODZ12', 'Z13_SEQ', 'Z13_CHVNFE'})
	oModel:GetModel('Z14DETAIL'):SetUniqueLine({'Z14_FILIAL','Z14_CODZ12', 'Z14_SEQ'})

    // AntesDeTudo
    oModel:SetVldActivate( {|oModel| U_CAEA050g(oModel) } )

Return oModel

/*/{Protheus.doc} ViewDef
Monta o view do modelo
@author Jose Vitor
@since 01/05/2018
@version 1.0
@type function
/*/
Static Function ViewDef()
	Local oModel := ModelDef()
	Local oView
	Local oStrZ12:= FWFormStruct(2, 'Z12')
	Local oStrZ13:= FWFormStruct(2, 'Z13')
	Local oStrZ14:= FWFormStruct(2, 'Z14')

	oView := FWFormView():New()
	oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('FORM_Z12' , oStrZ12,'MASTERZ12' ) 

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oView:AddGrid( 'GRID_Z13', oStrZ13, 'Z13DETAIL' )
    oView:AddGrid( 'GRID_Z14', oStrZ14, 'Z14DETAIL' )

    // Define campos que terao Auto Incremento
    oView:AddIncrementField( 'GRID_Z13', 'Z13_SEQ' )
    oView:AddIncrementField( 'GRID_Z14', 'Z14_SEQ' )

    // 30% cabec e 70% para as abas
	oView:CreateHorizontalBox('SUPERIOR', 30)
	oView:CreateHorizontalBox( 'INFERIOR', 70 )
	
    // Cria Folder na View
    oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

    // Crias as pastas (abas)
    oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_Z13'  , "Notas | Recibos | Depositos | NF-e" )
    oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_Z14'  , "Itens | Detalhes" )

    // Criar "box" horizontal com 100% dentro das Abas
    oView:CreateHorizontalBox( 'ITENS' 		,100,,, 'PASTA_INFERIOR', 'ABA_Z13' )
    oView:CreateHorizontalBox( 'DETALHES'   ,100,,, 'PASTA_INFERIOR', 'ABA_Z14' )

    // Liga a identificacao do componente
    // oView:EnableTitleView('GRID_Z13','Itens |')

    // Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('FORM_Z12', 'SUPERIOR')
	oView:SetOwnerView('GRID_Z13', 'ITENS'   )
	oView:SetOwnerView('GRID_Z14', 'DETALHES' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050g
(PE AntesDeTudo) Função para a abertura da tela.
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050g(oModel)
	Local nOperation := oModel:GetOperation()
    Local lInclui := nOperation == MODEL_OPERATION_INSERT
    Local lAltera := nOperation == MODEL_OPERATION_UPDATE
    Local lExclui := nOperation == MODEL_OPERATION_DELETE
    Local MSCAEA05A := Alltrim(cUserName) $ u_NyxGetMV('MS_CAEA05A','004774','Usuarios que alteram presstacao de outros usuarios')
	Local lRet := .T.	
	SA6->(DbOrderNickName('A6_YCODSRA'))
	SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))

	If Z12->Z12_CODSRA == cMatSub
		SA6->(DbSeek(xFilial('SA6') + cMatSub + 'F'))
	Else
		SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))
	EndIf

	If !lInclui .And. !lAltera .And. !lExclui
		Return .T.
	ElseIf lAltera .AND. Z12->Z12_STATUS <> 'R'
		Help(" ",1,'CAEA0050',,"Alteração não permitida no status atual.",1,0,,,,,,{""} )
		lRet := .F.
	ElseIf lAltera .AND. cMatLog <> Z12->Z12_CODSRA .And. cMatSub <> Z12->Z12_CODSRA .AND. !MSCAEA05A
		Help(" ",1,'CAEA0050',,"Não é possível alterar uma prestação de outro funcionário.",1,0,,,,,,{""} )
		lRet := .F.
	ElseIf (lInclui .OR. lAltera) .AND. Empty(cMatLog)
		Help(" ",1,'CAEA0050',,"Não é possivel realizar esta operação pois seu usuário não possui um banco vinculado.",1,0,,,,,,{""} )		
		lRet := .F.
	ElseIf lInclui .AND. temPrest()
		Help(" ",1,'CAEA0050',,"Não é possível incluir uma nova prestação pois você já possui uma prestação em rascunho ou fechada.",1,0,,,,,,{""} )		
		lRet := .F.
	ElseIf !lExclui .And. SA6->A6_SALATU <= 0 .AND. !MSCAEA05A
		Help(" ",1,'CAEA0050',,"Você não possui saldo no banco para poder realizar uma prestação de contas.",1,0,,,,,,{"Aguarde seu banco atualizar os valores para inserir uma prestação."} )		
		lRet := .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} temPrest
Valida se ja tem uma prestacao de contas para o funcionario em rascunho ou fechada.
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function temPrest
	Local cQuery 
	Local lRet 

	cQuery := " SELECT * FROM " + RetSqlName('Z12') + " Z12 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND Z12_CODSRA = '" + cMatLog + "'"
	cQuery += " AND Z12_STATUS IN ('R','F') "

	If Select('QRY') > 0
		QRY->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias 'QRY'
	
	lRet := ! QRY->(Eof())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050d
PE - TudoOk
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050d(oModel)
	Local lRet := .T.
    Local oModelZ13		:= oModel:GetModel("Z13DETAIL")
	Local aSaveLines 	:= FWSaveRows()
  	Local nX            := 1
	Local nOperation 	:= oModel:GetOperation()
	Local lExclui 		:= nOperation == MODEL_OPERATION_DELETE
	Local lAltera 		:= nOperation == MODEL_OPERATION_UPDATE
	Local cChaveZ13 	:= ''

	If lExclui .And. Z12->Z12_STATUS <> 'R'		
		Help(" ",1,'CAEA0050',,"Não é possível excluir com o status atual",1,0,,,,,,{""} )		
		Return .F.		
	EndIf
	//Abre a transação se for exclusão, pois em alguns casos, será desfeita qualquer alteração
	If lExclui .Or. lAltera
		Begintran()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a validacao das linhas da primeira aba³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to oModelZ13:Length()
        oModelZ13:GoLine( nX )
		//Linha deletada ou operação Exclusao
		//Percorrerá todos os registros e deletar possiveis vinculos com SF1
		If oModelZ13:IsDeleted() .Or. lExclui			
			cChaveZ13 := oModelZ13:GetValue('Z13_CODZ12') + oModelZ13:GetValue('Z13_SEQ')
			If !ExcluiNF(Z12->Z12_FILIAL,cChaveZ13)
				Help(" ",1,'CAEA0050',,"Não foi possível excluir NF Nro " + oModelZ13:GetValue('Z13_DOC'),1,0,,,,,,{"Tente novamente."} )		
				DisarmTransaction() 
				Return .F.
			EndIf
					
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama funcao para validar linha a linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! u_CAEA050b(oModelZ13, nX)			
			If lExclui .Or. lAltera
				DisarmTransaction()
			EndIf
			Return .F.
		EndIf
	Next

	//Retorna se for exclusão
	If lExclui
		EndTran()
		Return .T.
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o total da prestação é maior que o possível.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	If SA6->(DbSeek(xFilial('SA6') + oModel:GetValue("MASTERZ12",'Z12_CODSRA') + 'F'))
		If !u_CAEF0050(3, .T.)
			lRet := .F.
		EndIf
		//Comentado 19/09 a pedido de Lindberg, de acordo com as validações e regras, não será necessario verificar o SLDATU do banco, visto que eh um valor não utilizado, que está no cartão do suprido
		//Assim não sendo necessário ele prestar coonta
		//If lRet .AND. (oModel:GetValue("MASTERZ12", 'Z12_TOTNFR') > SA6->A6_YVLDISP .Or. oModel:GetValue("MASTERZ12", 'Z12_TOTNFE') > SA6->A6_YVLDISP)
		//	Help(" ",1,'CAEA0050',,"Valor total da prestação de NOTAS não pode ser maior que o valor disponível no Fundo Fixo.",1,0,,,,,,{""} )			
		//	lRet := .F.
		nSoma := Round(oModel:GetValue("MASTERZ12", 'Z12_TOTAL'),2)
		nLim := Round(SA6->A6_YLIMITE, 2)
		If lRet .AND. nSoma > nLim
			Help(" ",1,'CAEA0050',,'Valor total da prestação de NOTAS (R$'+AllTrim(Transform(oModel:GetValue("MASTERZ12", 'Z12_TOTAL'), "@E 999,999.99"))+') não pode ser maior que o valor limite no Fundo Fixo (R$'+AllTrim(Transform(SA6->A6_YLIMITE, "@E 999,999.99"))+').',1,0,,,,,,{""} )	
			lRet := .F.
		EndIf

		//lRet := U_CAEA050K()
	Else
		Help(" ",1,'CAEA0050',,"Fundo Fixo não identificado.",1,0,,,,,,{""} )		
		lRet := .F. // Teste
	EndIf	
	
	//Disarma transacao caso dê erro de validação
	If !lRet
		DisarmTransaction()
	EndIf

	//Encerra transacao na alteração
	If lAltera .And. lRet
		EndTran()
	EndIf	

	FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050b
(LinOk) Função que faz a validacao da linha da primeria grid.
@author  Jose Vitor
@since   29/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050b(oModelZ13, nLin)
	Local lRet			:= .T.
    Local oModel	    := FWModelActive()
    Local oModelZ12	    := oModel:GetModel("MASTERZ12")
	Local oModelZ14	    := oModel:GetModel("Z14DETAIL")
	Local cDoc, cSerie, dData, cNaturez, cTipo, cFornec, cLoja, cChvnfe, cCodZ12, cSeqZ13
	Local nValor := 0
	Local nSomaZ14 := 0
	Local cChaveZ13 := ''
	Local aSaveLines 	:= FWSaveRows()	
	Local aAreaSF1		:= {}
	Local nLimiteNF := u_GetParam('LIMITNFSFF',.T.,1000)
	Local nX, j
	Default nLin 		:= oModelZ13:GetLine()

	// Sai da validacao se a linha estiver deletada
	If oModelZ13:IsDeleted()		
		Return .T.
	EndIf

	If nLin > 0
        oModelZ13:GoLine(nLin)
	EndIf

	nValor 	:= oModelZ13:GetValue('Z13_VALOR')
	cTipo  	:= oModelZ13:GetValue('Z13_TIPO')
	cChvnfe	:= oModelZ13:GetValue('Z13_CHVNFE')
	dData	:= oModelZ13:GetValue('Z13_DATA')
	
	cQuery := " SELECT MAX(Z11_DTEFET) 'Z11_DTEFET'"
	cQuery += " FROM "  + RetSqlTab('Z11')
	cQuery += " WHERE " + RetSqlDel('Z11')
	cQuery += " AND Z11_CODSRA='" + cMatLog + "'"
	cQuery += " AND Z11_STATUS='P'"
	If Select('QRYZ11') > 0
		QRYZ11->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYZ11'
	
	cQuery := " SELECT *"
	cQuery += " FROM " + RetSqlTab('SE5') + " (nolock)"
	cQuery += " WHERE SE5.D_E_L_E_T_=''"
	cQuery += " AND E5_RECPAG='R'"
	cQuery += " AND E5_AGENCIA='00000'"
	cQuery += " AND E5_BANCO='CXI'"
	cQuery += " AND E5_SITUACA=''"
	cQuery += " AND E5_RECONC<>''"
	cQuery += " AND E5_DATA >= '" + DtoS(FirstDate(StoD(QRYZ11->Z11_DTEFET))) + "'"
	cQuery += " AND E5_DATA <= '" + QRYZ11->Z11_DTEFET + "'"
	cQuery += " AND RIGHT(E5_CONTA,6) = '" + cMatLog + "'"
	cQuery += " ORDER BY E5_DATA"

	If Select('QRYSE5') > 0
		QRYSE5->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYSE5'

	If dData > dDataBase
		Help(" ",1,'CAEA0050',,"Data não pode ser superior a data atual.",1,0,,,,,,{""} )
		Return .F.
	//Foi solicitado remoção da validação sob Trello 2919 / RM 20958 - 02/12/2020
	//ElseIf cTipo <> 'D' .And. !QRYSE5->(!Eof()) .And. QRYZ11->(!Eof()) .And. dData <= StoD(QRYZ11->Z11_DTEFET)
	//	Help(" ",1,'CAEA0050',,"Data não pode ser inferior ou igual a data da última solicitação.",1,0,,,,,,{"Dt da efetivação da última solicitação: " + DtoC(StoD(QRYZ11->Z11_DTEFET))} )
	//	Return .F.
	//ElseIf cTipo <> 'D' .And. dDataBase > DtValida(4)
	//	Help(" ",1,'CAEA0050',,"Você só pode lançar notas até o quarto dia útil do mês subsequente.",1,0,,,,,,{"Ref.: Item 8.1.1 da Norma de Suprimento de Fundos. Entre em contato com a UNFI."} )
	//	Return .F.
	//ElseIf cTipo <> 'D' .And. Month(dData) <> Month(dDataBase) .And. dDataBase > DtValida(4)
	//	Help(" ",1,'COMPET',,"Competência da NF não pode ser diferente da competência da utilização do saldo.",1,0,,,,,,{"Ref.: Item 8.1 da Norma de Suprimento de Fundos. Entre em contato com a UNFI."} )
	//	Return .F.
	EndIf
	
	
	SED->(DbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao do valor max da NF   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))
	nLimiteNF := Iif(SA6->A6_YLIMINF > 0, SA6->A6_YLIMINF, nLimiteNF)

	If lRet .And. nValor > nLimiteNF .And. cTipo <> 'D'
		Help(" ",1,'CAEA0050',,"O valor da NF/Doc é maior do que o valor limite permitido no cadastro do banco.",1,0,,,,,,{"Limite Permitido: R$ " + Alltrim(Transform(nLimiteNF, "@E 999,999.99"))} )
		lRet := .F.
	EndIf    

	//Valida se usuário quer inserir uma NF-e, mas escolheu o tipo incorreto
	If !Empty(cChvnfe) .And. cTipo <> 'S'
		Help(" ",1,'CAEA0050',,"O campo 'Chave da NFe' deve ser preenchida apenas para Tipo Doc igual a NF-e.",1,0,,,,,,{"Escolha a opção 'S - NF-e' no campo Tipo Doc (Z13_TIPO)"} )
		Return .F.
	EndIf

	//Verifica se ja existe SF1 gerada para a linha, caso sim, não permite alterar o tipo
	cChaveZ13   := oModelZ13:GetValue('Z13_CODZ12') + oModelZ13:GetValue('Z13_SEQ')
	aAreaSF1 := SF1->(GetArea())
	SF1->(DbOrderNickName('F1YCODZ13'))
	If SF1->(dbSeek(xFilial('SF1')+cChaveZ13)) .And. cTipo <> 'S'
		Help(" ",1,'CAEA0050',,"Tipo documento não pode ser alterado, pois já há NF gerada. Linha " + cValtoChar(nLin),1,0,,,,,,{""} )		
		Return .F.
	EndIf
	//Ordena no indice 1, para consulta se NFe digitada na linha Z13 já existe na filial
	SF1->(dbSetOrder(1))
	//Validações quando for NF-e
	If cTipo == 'S' .And. (INCLUI .Or. ALTERA)		
		cDoc	:= Padl(alltrim(oModelZ13:GetValue('Z13_DOC')), 9, '0')
		cSerie	:= Padl(alltrim(oModelZ13:GetValue('Z13_SERIE')), 3, '0')
		//Padroniza doc no padrão SPED (9 caracteres)
		oModelZ13:LoadValue('Z13_DOC', cDoc)
		oModelZ13:LoadValue('Z13_SERIE', cSerie)
		
		dData	:= oModelZ13:GetValue('Z13_DATA')
		cFornec	:= oModelZ13:GetValue('Z13_FORNEC')
		cLoja	:= oModelZ13:GetValue('Z13_LOJA')
		cCodZ12 := oModelZ12:GetValue('Z12_CODIGO')
		cSeqZ13 := oModelZ13:GetValue('Z13_SEQ')
		//Busca fornecedor pelo codigo que esta em Z13_FORNEC
		//para pegar o A2_CGC e validar com o que esta na CHVNFE
		SA2->(dbsetorder(1))
		SA2->(dbseek(xFilial('SA2')+cFornec+cLoja))
		If Empty(cFornec)
			Help(" ",1,'CAEA0050',,"Doc tipo NF-e, obrigatório preenchimento do código do fornecedor para continuar.",1,0,,,,,,{""} )
			Return .F.
		ElseIf Empty(cLoja)
			Help(" ",1,'CAEA0050',,"Doc tipo NF-e, obrigatório preenchimento da loja para continuar.",1,0,,,,,,{""} )
			Return .F.
		ElseIf Empty(cSerie)
			Help(" ",1,'CAEA0050',,"Doc tipo NF-e, obrigatório preenchimento da serie para continuar.",1,0,,,,,,{""} )
			Return .F.		
		//Verifica se NF ja está cadastrada, sem vinculo com caixinha
		ElseIf SF1->(dbSeek(xFilial('SF1')+alltrim(cDoc)+cSerie+cFornec+cLoja)) .And. (Empty(SF1->F1_YCODZ13) .Or. SF1->F1_YCODZ13 <> (cCodZ12 + cSeqZ13))//oModelZ13:IsUpdated(nLin)
			Help(" ",1,'CAEA0050',,"NF-e já existe nessa filial. Chave: (Filial+Doc+Série+Fornecedor+Loja). Linha: " + cValToChar(nLin),1,0,,,,,,{"Por favor, informe outra NF-e."} )
			Return .F.
		ElseIf !vldChvNFE(cCodZ12,cSeqZ13,cChvnfe,cDoc,cSerie,alltrim(SA2->A2_EST),dData,alltrim(SA2->A2_CGC),nLin)
			Return .F.			
		EndIf

		For nX:=1 to oModelZ13:Length()
			oModelZ13:GoLine(nX)
			//Se for deletado ou a própria linha, não valida	
			If nX == nLin .Or. oModelZ13:IsDeleted()
				loop
			ElseIf alltrim(oModelZ13:GetValue('Z13_CHVNFE')) == alltrim(cChvnfe)
				Help(" ",1,'CAEA0050',,"Chave NF-e já se encontra na grid. Linha " + cValtoChar(nX) + ".",1,0,,,,,,{"Favor, utilizar outra chave."} )
				Return .F.
			EndIf
		Next
		//Volta para linha que estava
		oModelZ13:GoLine(nLin)
	EndIf

	cDocDevol := oModelZ13:GetValue('Z13_DOCDEV')
	nVlrDevol := oModelZ13:GetValue('Z13_VLRDEV')
	If Empty(cDocDevol) .And. nVlrDevol > 0
		Help(" ",1,'CAEA0050',,"Campo Doc Devol (Z13_DOCDEV) em branco ou com valor nulo, você informou valor de devolução.",1,0,,,,,,{"Favor, digitar o numero do documento de devolução."} )
		Return .F.
	ElseIf !Empty(cDocDevol) .And. nVlrDevol <= 0
		Help(" ",1,'CAEA0050',,"Campo Vlr Devol (Z13_VLRDEV) deve ser maior que zero, você informou o documento de devolução",1,0,,,,,,{"Favor, informar o valor do documento de devolução."} )
		Return .F.	
	EndIf

	cNaturez := oModelZ13:GetValue('Z13_NATURE')
	If Empty(cNaturez) .OR. ! SED->(DbSeek(xFilial('SED') + cNaturez))
		Help(" ",1,'CAEA0050',,"Digite uma natureza válida.",1,0,,,,,,{""} )		
		lRet := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida quando for deposito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipo == 'D'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida a digitacao dos dados do banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cBanco := oModelZ13:GetValue('Z13_BANCO')) ;
			.OR. Empty(cAgencia :=  oModelZ13:GetValue('Z13_AGENCI')) ;
			.OR. Empty(cConta := oModelZ13:GetValue('Z13_CONTA'))
			Help(" ",1,'CAEA0050',,"Para depositos, devem ser digitados os dados de banco, agencia e conta obrigatoriamente.",1,0,,,,,,{""} )			
			lRet := .F.
		Else				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida os dados digitados do banco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA6->(DbSetOrder(1))
			If ! SA6->(DbSeek(xFilial('SA6') + cBanco + cAgencia + cConta))
			Help(" ",1,'CAEA0050',,"Não foi localizado o cadastro do banco/agencia/conta informados.",1,0,,,,,,{""} )				
				lRet := .F.
			EndIf		
		EndIf			
	ElseIf Empty(oModelZ13:GetValue('Z13_NOME'))
		Help(" ",1,'CAEA0050',,"O preenchimento do fornecedor para NOTAS/RECIBOS é obrigatório.",1,0,,,,,,{"Campo Nome Fornec (Z13_NOME)"} )
		lRet := .F.			
	EndIf

	//Se desconto for maior que o subtotal da nota, para evitar incluir valores negativos no campo Z13_VALOR
	If oModelZ13:GetValue('Z13_DESCON') >= oModelZ13:GetValue('Z13_SUBTOT')
		Help(" ",1,'CAEA0050',,'Valor de Desconto não pode ser igual ou superior ao SubTotal da Nota.',1,0,,,,,,{"Insira um valor válido. (Desconto)"} )
		lRet := .F.
	EndIf

	//Se desconto for maior que o subtotal da nota, para evitar incluir valores negativos no campo Z13_VALOR
	If Empty(oModelZ13:GetValue('Z13_JUST'))
		Help(" ",1,'CAEA0050',,'Insira a justificativa de compra no campo "JUSTIFICAT". (Z13_JUST).',1,0,,,,,,{"Insira um valor válido. (Justificat)"} )
		lRet := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma o valor digitado nos itens, na segunda aba³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSomaZ14 := 0
	
	For j := 1 to oModelZ14:Length()
		oModelZ14:GoLine(j)
		
		If oModelZ14:IsDeleted()
			Loop
		EndIf

		If alltrim(oModelZ14:GetValue('Z14_PRODUT')) == alltrim(cProdCXI) .And. Empty(oModelZ14:GetValue('Z14_JUSTIF'))
			Help(" ",1,'CAEA0050',,'Produto descrição obrigatória. (Z14_JUSTIF). Linha: ' + cValToChar(j),1,0,,,,,,{'Você deve preencher o campo de justificativa da compra, com a descrição do produto que consta na NF.'} )
			lRet := .F.
			Exit
		EndIf

		If oModelZ13:GetValue('Z13_SEQ') == oModelZ14:GetValue('Z14_SEQZ13')
			//Valores de vlunit e quant não podem ser vazios
			If oModelZ14:GetValue('Z14_VLUNIT') == 0
				Help(" ",1,'CAEA0050',,'Doc ' + Alltrim(oModelZ13:GetValue('Z13_DOC')) + '. Digite o valor unitário do produto '+ Alltrim(oModelZ14:GetValue('Z14_PRODUT')) + '. Linha: ' + cValToChar(j),1,0,,,,,,{"Insira um valor válido no item."} )				
				lRet := .F.
				Exit
			ElseIf oModelZ14:GetValue('Z14_QUANT') == 0
				Help(" ",1,'CAEA0050',,'Doc ' + Alltrim(oModelZ13:GetValue('Z13_DOC')) + '. Digite o a quantidade do produto '+ Alltrim(oModelZ14:GetValue('Z14_PRODUT')) + '. Linha: ' + cValToChar(j),1,0,,,,,,{"Insira uma quantidade válida no item."} )				
				lRet := .F.
				Exit
			EndIf	

			nSomaZ14 += oModelZ14:GetValue('Z14_TOTAL')
		EndIf
		
	Next
	//Arredonda o terceiro dígito, para bater com valor da nota Z13_VALOR
	//Ex: nSomaZ14 = 6,4155 fica 6,42
	nSomaZ14 := Round(nSomaZ14, 2)

	nTotNota := oModelZ13:GetValue('Z13_VALOR') + oModelZ13:GetValue('Z13_DESCON')	
	//Se for Tipo S - NF-e irá obrigar preenchimento de 1 item/produto - Z14
	If lRet .AND. nSomaZ14 <= 0 .AND. cTipo == 'S'
		Help(" ",1,'CAEA0050',,"Para tipo NF-e é obrigatório preenchimento dos produtos na aba 'Itens | Detalhes'.",1,0,,,,,,{"Insira itens na nota nº " + Alltrim(oModelZ13:GetValue('Z13_DOC')) + "."} )		
		lRet := .F.		
	ElseIf lRet .And. ((cTipo == 'D' .And. nSomaZ14 > 0) .Or. cTipo <> 'D') .And. Round(nSomaZ14,2) <> Round(nTotNota,2) //Valida se o valor total digitado esta correto 
		Help(" ",1,'CAEA0050',,"O valor do Documento " + Alltrim(oModelZ13:GetValue('Z13_DOC')) + " (R$"+cValToChar(nTotNota)+") não bate com o valor total na aba 'Itens | Detalhes'. Valor dos itens: " + cValToChar(nSomaZ14),1,0,,,,,,{"Corrija os valores dos itens."} )
		lRet := .F.
	EndIf

		//Recalcula os valores do cabecalho
	If lRet
		fCalcTots(oModelZ12, oModelZ13)
	EndIf

	RestArea(aAreaSF1)
	FWRestRows(aSaveLines)

Return lRet

Static Function fCalcTots(oModelZ12, oModelZ13)
	Local nX 		:= 1
	Local nTOTNFR 	:= 0
	Local nTOTNFE 	:= 0
	Local nTOTDEP 	:= 0
	Local nTOTAL  	:= 0
	Local nValor 	:= 0
	Local cTipo  	:= 0

	For nX := 1 to oModelZ13:Length()
        oModelZ13:GoLine( nX )
		If oModelZ13:IsDeleted()
			Loop
		EndIf

		nValor 	:= oModelZ13:GetValue('Z13_VALOR') - oModelZ13:GetValue('Z13_VLRDEV')		
		cTipo 	:= oModelZ13:GetValue('Z13_TIPO')

		If cTipo $ 'N,R'
			nTOTNFR += nValor
		EndIf

		If cTipo == 'D'
			nTOTDEP += nValor
		EndIf

		If cTipo == 'S'
			nTOTNFE += nValor
		EndIf
		
		nTOTAL += nValor
	Next

	oModelZ12:LoadValue('Z12_TOTNFR', nTOTNFR)
	oModelZ12:LoadValue('Z12_TOTNFE', nTOTNFE)
	oModelZ12:LoadValue('Z12_TOTDEP', nTOTDEP)
	oModelZ12:LoadValue('Z12_TOTAL' , nTOTAL)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050e
Função para efetivar e cancelar a prestacao de contas.
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050e(cNewStatus)
	Local lRet 			:= .F.
	Local cFilAux		:= cFilAnt
	Local cOldStatus 	:= Z12->Z12_STATUS
	Local cMsg := ''
	cFilAnt := Alltrim(SuperGetMv('MS_CAEA0005',.F.,'CAEADC0001'))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o banco do funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	If ! SA6->(DbSeek(xFilial('SA6') + Z12->Z12_CODSRA + 'F'))
		ApMsgInfo('O Banco do usuário não foi localizado.')
		Return .F.
	EndIf

	If ! Z12->Z12_STATUS $ 'F'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao do fundo fixo          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !u_CAEF0050(2)
			Return .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle de transacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begintran()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o status for Efetivar e estiver finalizado baixara os titulos do financeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cNewStatus == 'E' .AND. Z12->Z12_STATUS == 'F'
		If efetiva()
			lRet := .T.
			cMsg := 'Efetivação realizada com sucesso.'
		EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄD¿
	//³Se for cancelar efetivacao, volta status para finalizado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDÙ
	ElseIf cNewStatus == 'C' .AND. Z12->Z12_STATUS == 'E'
		If cancela()
			lRet := .T. 
			cMsg := 'Cancelamento realizado com sucesso.'
		EndIf			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se ainda tiver em rascunho e seja cancelmento entao, apenas ira mudar o status³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cNewStatus $ 'C,F' .AND. Z12->Z12_STATUS == 'R'
		If cNewStatus == 'F'
			lRet := vldFechamento()
			If lRet
				lRet := u_CAEF0072()
				If lRet
					U_CAEF0050(1, .F.)
				EndIf
			EndIf
		Else
			lRet := ExcluiNF()
		EndIf		
	Else
		ApMsgInfo('Não é possível realizar a operação com o status atual.')
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso tenha dado tudo certo, altera o status e confirma a transacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Altera para o novo status³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock('Z12', .F.)
			Z12->Z12_STATUS := cNewStatus
			Z12->Z12_DTEFET := Iif(cNewStatus=='E',dDataBase,CtoD('//'))
		Z12->(MsUnLock())

		If cNewStatus <> 'F'		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira o saldo do funcionario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA6->(DbOrderNickName('A6_YCODSRA'))
			SA6->(DbSeek(xFilial('SA6') + Z12->Z12_CODSRA + 'F'))   	
			
			RecLock('SA6', .F.)			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for efetivacao retira o saldo disponivel, se for cancelamento inclui³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cNewStatus == 'E'
					SA6->A6_YVLDISP -= Z12->Z12_TOTAL
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se era Rascunho nao houve alteracao no valor VLDISP, entao nao precisa adicionar valor          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf cNewStatus == 'C' .AND. cOldStatus <> 'R'
					SA6->A6_YVLDISP += Z12->Z12_TOTAL				
				EndIf
			SA6->(MsUnLock())

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula o VLDISP para evitar erros          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		u_CAEF0050(1, .F.)

		EndTran()
		MsUnlockAll()
	Else
		DisarmTransaction()
	EndIf

	If !Empty(cMsg) .And. lRet
		ApMsgInfo(cMsg)
	EndIf

	cFilAnt := cFilAux
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0050
Inicializador do campo Z14_SEQZ13 'Itens | Detalhes' - Z14
@author  Jerry Junior
@since   17/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050F()
	Local cRet := ''
	Local oModel := FWModelActive()
	Local oModelZ13 := oModel:GetModel('Z13DETAIL')
	Local nLinAtu	:= oModelZ13:GetLine()
	
	cRet := oModelZ13:getvalue('Z13_SEQ')
	If Empty(cRet)		
		nLinAtu := Iif(nLinAtu==1,nLinAtu,nLinAtu-1)
		cRet := Soma1(oModelZ13:getvalue('Z13_SEQ',nLinAtu))
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} efetiva
Função para efetivar a prestacao de contas.
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function efetiva()
	Local cSeekZ13
	Local lRet	:= .T.

	Z13->(DbSetOrder(1))//FILIAL+CODZ12+SEQ
	Z14->(DbSetOrder(1))//FILIAL+CODZ12+SEQZ13+SEQ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o banco do usuario da prestacao de contas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	If ! SA6->(DbSeek(xFilial('SA6') + Z12->Z12_CODSRA + 'F'))
		ApMsgInfo('O Banco do usuário não foi localizado.')
		lRet := .F.
	ElseIf SA6->A6_SALATU < Z12->Z12_TOTAL
		ApMsgInfo('O banco do usuário não tem saldo suficiente para essa efetivação. Saldo Atual: R$ ' + alltrim(transform(SA6->A6_SALATU,'@E 999,999.99')) + '. Aguarde saldo atualizar.')
		lRet := .F.
	ElseIf SA6->A6_YLIMITE < Z12->Z12_TOTAL
		ApMsgInfo('O total da prestação (R$'+AllTrim(Transform(Z12->Z12_TOTAL, "@E 999,999.99"))+') excede o limite do funcionário (R$'+AllTrim(Transform(SA6->A6_YLIMITE, "@E 999,999.99"))+'). Operação cancelada.')
		lRet := .F.
	//ElseIf SA6->A6_YVLDISP > Z12->Z12_TOTAL
	//	ApMsgInfo('O valor da prestação é inferior ao valor do saldo do cartão. Valor no cartão R$'+AllTrim(Transform(SA6->A6_YVLDISP, "@E 999,999.99")) + '.')
	//	lRet := .F.
	EndIf
	
	//nVlrUtiliz := u_CAEA050i()
	////Se estiver em rascunho e usuario fechar a prestação, verifica se prestou conta do valor total utilizado
	//If nVlrUtiliz <> Z12->Z12_TOTAL .And. cNewStatus == 'F' .And. Z12->Z12_STATUS == 'R'
	//	cMsg := 'O total da prestação (R$'+AllTrim(Transform(Z12->Z12_TOTAL, "@E 999,999.99"))+') não confere com o valor total utilizado pelo usuario (R$'+AllTrim(Transform(nVlrUtiliz, "@E 999,999.99"))+').' + CRLF
	//	cMsg += 'Corrija os valores da prestação e tenta novamente.' + CRLF
	//	cMsg += 'Operação cancelada.'
	//	ApMsgInfo(cMsg)
	//	lRet := .F.
	//EndIf
	/*
	A partir de definicao, nao sera mais solicitado empenho na efetivacao da prestacao de contas
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao do empenho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(Z12->Z12_YEMPENH)
		lRet := ValidaEmpenhos()
	Else
		ApMsgInfo('A digiação do número de empenho obrigatório. Operação cancelada.')
		lRet := .F.
   EndIf
   */

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja um banco valido, ira iniciar a geracao dos dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta as notas/recibos/depositos da prestacao de contas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Z13->(DbSeek(cSeekZ13 := Z12->Z12_FILIAL + Z12->Z12_CODIGO))	 	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Percorre por todos os registros para gerar um a um³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While Z13->(!Eof()) .AND. cSeekZ13 == Z13->Z13_FILIAL + Z13->Z13_CODZ12

			If Z13->Z13_TIPO == 'D'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida se o documento existe no SE5, ou seja, se o funcionario ja fez o deposito³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! getDocSE5() 
					ApMsgInfo('Não foi encontrado o documento de depósito: ' + Z13->Z13_DOC)
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a movimentacao bancaria do valor Z13  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! geraMovimento()
				lRet := .F.
				Exit
			EndIf
				
			Z13->(DbSkip())
		EndDo      

	EndIf
	If lRet
		RecLock('SA6', .F.)
			SA6->A6_YMATSUP := Space(6)
		SA6->(MsUnLock())
	EndIf
Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ getDocSE5º Autor ³ Sidney Sales       º Data ³  08/07/16   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Função auxiliar para verificar se o documento existe.      º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function getDocSE5()
	Local cQuery
	Local lRet

	cQuery := " SELECT R_E_C_N_O_ AS RECSE5, E5_VALOR FROM " + RetSqlName('SE5') + " SE5 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
//	cQuery += " AND E5_FILIAL  = '" + xFilial('SE5') 	+ "' "
	cQuery += " AND E5_RECPAG  = 'R' "
	cQuery += " AND E5_DATA    = '" + DtoS(Z13->Z13_DATA) + "' AND E5_DOCUMEN = '" + Z13->Z13_DOC + "' "
   cQuery += " AND E5_BANCO   = '" + Z13->Z13_BANCO 	+ "' "
   cQuery += " AND E5_AGENCIA = '" + Z13->Z13_AGENCI 	+ "' "
   cQuery += " AND E5_CONTA   = '" + Z13->Z13_CONTA 	+ "' "

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias 'QRY'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o documento exista, chama funcao que altera a natureza do movimento bancario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QRY->(!Eof()) .AND. QRY->E5_VALOR == Z13->Z13_VALOR
		SE5->(DbGoTo(QRY->RECSE5))
		If Alltrim(SuperGetMv('MS_NATSUPR', .F.,"224002    ")) <> Alltrim(SE5->E5_NATUREZ)
			lRet := U_CAEF0002(QRY->RECSE5, SuperGetMv('MS_NATSUPR', .F.,"224002    "))
		Else	
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} geraMovimento
Função auxiliar para gerar movimentacao bancaria na conta 
do funcionario quando efetivacao pagar e quando estorno faz 
a movimentcao de receber
@author  Jose Vitor
@since   29/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function geraMovimento(nTipo)
	Local aDados
	Local aAreaSA6			:= SA6->(GetArea())
	Local lRet 				:= .T.
	Private lMsErroAuto	:= .F.
	Default nTipo			:= 3 //3 = pagar 4 = receber
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Historico do movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cHist := "PREST-FF " + Z12->Z12_CODIGO + '-' + u_X3_CBOX("Z13_TIPO", Z13->Z13_TIPO)	+ '-'+Z13->Z13_DOC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o banco do funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	SA6->(DbSeek(xFilial('SA6') + Z12->Z12_CODSRA + 'F'))
	
	nValorMov := Round(Z13->Z13_VALOR, 2) - Iif(Z13->Z13_VLRDEV > 0, Z13->Z13_VLRDEV, 0)

	aDados := { {"E5_DATA" 		,dDataBase 					,Nil},;
				{"E5_MOEDA" 	,"R$" 						,Nil},;
				{"E5_VALOR" 	,nValorMov					,Nil},;
				{"E5_NATUREZ" 	,AllTrim(Z13->Z13_NATURE)	,Nil},;
				{"E5_BANCO" 	,AllTrim(SA6->A6_COD)		,Nil},;
				{"E5_AGENCIA" 	,AllTrim(SA6->A6_AGENCIA) 	,Nil},;
				{"E5_CONTA" 	,AllTrim(SA6->A6_NUMCON) 	,Nil},;
				{"E5_YCODZ12" 	,Z12->Z12_CODIGO			,Nil},;
				{"E5_CCUSTO"	,Z13->Z13_CC				,Nil},;
				{"E5_YTPZ13"	,Z13->Z13_TIPO				,Nil},;
				{"E5_RECONC" 	,'x'						,Nil},;
				{"E5_HISTOR" 	,AllTrim(cHist)				,Nil},;
				{"E5_FILORIG"	,"CAEADC0001"				,Nil}}
	
  	SA6->(DbSetOrder(1))

	cBpkFilAnt 	:= cFilAnt
	cFilAnt 	:= Z12->Z12_FILIAL
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aDados,nTipo)
	cFilAnt 	:= cBpkFilAnt
	
	If lMsErroAuto
		lRet := .F.
		// ApMsgInfo('Erro na movimentação bancária de devolução do funcionário, não é possivel prosseguir.')
		MostraErro()
	EndIf
  
  	RestArea(aAreaSA6)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cancela
Função para realizar o cancelamento da prestacao de contas
@author  Jose Vitor
@since   28/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function cancela()
	Local cSeekZ13
	Local lRet 		:= .T.	
	Local aAreaSA6	:= SA6->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta o banco do funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA6->(DbOrderNickName('A6_YCODSRA'))
	If ! SA6->(DbSeek(xFilial('SA6') + Z12->Z12_CODSRA + 'F'))
		ApMsgInfo('O Banco do usuário não foi localizado.')
		lRet := .F.
	EndIf	
	
	RestArea(aAreaSA6)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esteja valido, ira percorrer todas as notas/recibo/depositos fazendo o cancelamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		Z13->(DbSeek(cSeekZ13 := Z12->Z12_FILIAL + Z12->Z12_CODIGO))	 			
		While Z13->(!Eof()) .AND. cSeekZ13 == Z13->Z13_FILIAL + Z13->Z13_CODZ12			 	
		 	If ! GeraMovimento(4)					
  				lRet := .F.
		 		Exit
			EndIf
			If Z13->Z13_TIPO == 'D'
//				PcoDetLan('900002','05',"FINA100", .T.)
			EndIf

			If !ExcluiNF(Z13->Z13_FILIAL,Z13->(Z13_CODZ12+Z13_SEQ))
				ApMsgInfo("Erro na exclusão da NF Nro " + alltrim(Z13->Z13_DOC) + ", não é possivel prosseguir.")
				lRet := .F.
				Exit
			EndIf
			Z13->(DbSkip())
		EndDo		      		
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGrvDados
Realiza a gravação do modelo de dados. Pode ser usado para realizar
processamentos adicionais
@author  Jose Vitor
@since   29/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fGrvDados(oModel)
	//Realiza a gravação do Modelo
	FWFormCommit(oModel)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050h
Funcao para reabrir a prestacao
@author  Jose Vitor
@since   29/11/2018
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050h
	Local lRet := .T.

	If Z12->Z12_STATUS == 'F' 	
		If U_CAEA004H('F')
			ApMsgInfo('Não é possível reabrir pois existe uma solicitação em aberto. Cancele a solicitação e tente novamente.')
			lRet := .F.
		EndIf
	Else
		ApMsgInfo('Não é possível reabrir no status atual.')
		lRet := .F.
	EndIf

	If lRet
		RecLock('Z12',.F.)
			Z12->Z12_STATUS := 'R'
		Z12->(MsUnLock())
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} vldChvNFE
Valida se chave NFE digitada na grid já está cadastrada em outra prestação -Z13
@author  Jerry Junior
@since   11/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function vldChvNFE(cCod,cSeq,cChvnfe,cDoc,cSerie,cEst,dData,cCgc, nLin)
	Local lRet := .T.
	Local cQuery := ""	
	Local cSolucao := "Por favor, informe a chave correta para essa nota."
	Local oModel	    := FWModelActive()
	Local oModelZ13	    := oModel:GetModel("Z13DETAIL")	
	Local cModChvNfe := alltrim(u_GetParam('MODCHVNFE',.T.,'55'))
	Default nLin 		:= oModelZ13:GetLine()

	If Empty(cChvnfe)
		cMsg := "Doc tipo NF-e, obrigatório preenchimento da chave da nota para continuar."
		cSolucao := ''
		lRet := .F.
	ElseIf Len(alltrim(cChvnfe)) < 44
		cMsg := "Tamanho da Chave NF-e inválido."
		cSolucao := "Tam. 44 caracteres"
		lRet := .F.
	ElseIf !(substr(cChvnfe,26,9) == alltrim(cDoc))
		cMsg := "Chave NF-e inválida. Doc não confere"
		lRet := .F. 
	ElseIf !(substr(cChvnfe,23,3) == alltrim(cSerie))
		cMsg := "Chave NF-e inválida. Série não confere"
		lRet := .F.
	ElseIf left(cChvnfe,2) <> U_CTP032EST(alltrim(cEst))
		cMsg := "Chave NF-e inválida. UF do Fornecedor não confere"
		lRet := .F.
	ElseIf !(substr(cChvnfe,3,4) == substr(DtoS(dData),3,4))
		cMsg := "Chave NF-e inválida. Ano/Mês não confere"
		lRet := .F.
	ElseIf !(substr(cChvnfe,7,14) == alltrim(cCgc))
		cMsg := "Fornecedor da Chave NF-e difere do digitado para esta nota."
		cSolucao := "Por favor, informe a chave e fornecedor corretos para esta nota."
		lRet := .F.				
	Else
		cQuery := " SELECT * FROM "  + RetSqlTab('Z13')
		cQUery += " INNER JOIN " + RetSqlTab('Z12') + " ON Z12_CODIGO=Z13_CODZ12 AND Z12.D_E_L_E_T_=Z13.D_E_L_E_T_"
		cQuery += " WHERE " + RetSqlDel('Z13')
		cQuery += " AND Z12_STATUS<>'C'"
		cQuery += " AND Z13_CHVNFE = '" + alltrim(cChvnfe) + "'"

		If Select('QRY') > 0
			QRY->(dbclosearea())
		EndIf

		TcQuery cQuery New Alias 'QRY'

		If QRY->(!Eof())
			If (QRY->Z13_CODZ12 <> cCod .Or. QRY->Z13_SEQ <> cSeq) .And. QRY->Z13_CHVNFE == cChvnfe//Empty(cOp) .Or. (QRY->Z13_CHVNFE <> cChvnfe)
				lRet := .F.
				cMsg := "Chave NF-e já cadastrada em outra prestação."
				cSolucao := "Utilizar outra chave."	
			EndIf
		EndIf		
	EndIf
	//Se ultimo dígito não for numérico e modelo da chave for 55, então bloqueia
	If lRet .And. !IsDigit(Right(cChvnfe,1)) .And. Substr(cChvnfe,21,2) $ cModChvNfe
		cMsg := "Chave NFe inválida para este modelo de Nota."
		cSolucao := "Favor, verificar se nota é tipo NF-e e se Chave está correta."
		lRet := .F.
		//So verifica o digit verificador, caso último dígito seja numérico
	ElseIf lRet .And. IsDigit(Right(cChvnfe,1)) .And. !(MODULO11(left(cChvnfe,43)) == right(cChvnfe,1))
		cMsg := "Dígito verificador da Chave NFe inválido."		
		lRet := .F.
	EndIf

	If !lRet
		Help(" ",1,'CAEA0050',,cMsg + ' Linha: '+cValToChar(nLin) + ". ",1,0,,,,,,{cSolucao} )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0050
Exclui NF caso prestação tenha sido excluída/cancelada
@author  Jerry Junior
@since   21/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ExcluiNF(cFilOri,cChaveZ13)
	Local lRet := .T.
	Local aAreaZ13 := Z13->(GetArea())
	Local aAreaSF1 := SF1->(GetArea())
	Default cFilOri		:= ''
	Default cChaveZ13	:= ''
	If !Empty(cChaveZ13)
		SF1->(DbOrderNickName('F1YCODZ13'))
		If SF1->(dbSeek(cFilOri+cChaveZ13))				
			If !U_CAEF072A()
				lRet := .F.
			EndIf
		EndIf
	Else
		Z13->(DbSeek(cSeekZ13 := Z12->Z12_FILIAL + Z12->Z12_CODIGO))	 	
		While Z13->(!Eof()) .AND. cSeekZ13 == Z13->Z13_FILIAL + Z13->Z13_CODZ12			
			cFilOri		:= Z13->Z13_FILIAL
			cChaveZ13	:= Z13->(Z13_CODZ12+Z13_SEQ)
			SF1->(DbOrderNickName('F1YCODZ13'))
			If SF1->(dbSeek(cFilOri+cChaveZ13))				
				If !U_CAEF072A()
					u_Aviso('Erro', 'Falha na exclusão da NF-e ' + alltrim(Z13->Z13_DOC) + '.' + chr(13) + chr(10), .F.)
					lRet := .F.
					Exit
				EndIf
			EndIf
			Z13->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaZ13)
	RestArea(aAreaSF1)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA050i
Retornar o valor que o usuario utilizou do cartão do caixinha (Valor Sacado)7
@author  Jerry Junior
@since   05/09/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA050i()
	Local nRet := 0
	//SA6->(DbOrderNickName('A6_YCODSRA'))
	//SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))

	cQuery := " SELECT SUM(E5_VALOR) VLRSACADO "
	cQuery += " FROM "  + RetSqlTab('SE5')
	cQuery += " WHERE " + RetSqlDel('SE5')
	cQuery += " AND RIGHT(E5_CONTA,6) = '" + alltrim(&(Iif(INCLUI, 'M', 'Z12')+'->Z12_CODSRA')) + "'"
	cQuery += " AND E5_RECPAG = 'R'"
	cQuery += " AND LEFT(E5_DATA,6) = (SELECT LEFT(MAX(E5_DATA),6) FROM " + RetSqlName('SE5') 	
	cQuery += "  WHERE RIGHT(E5_CONTA,6) = '" + alltrim(&(Iif(INCLUI, 'M', 'Z12')+'->Z12_CODSRA')) + "'"
	cQuery += "  AND E5_RECPAG='R' and D_E_L_E_T_='')"
	//cQuery += " AND E5_HISTOR LIKE '%" + alltrim(SA6->A6_YCARTAO) + "%'"
	
	If Select('QRYSAC') > 0
		QRYSAC->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYSAC'
	
	If QRYSAC->(!Eof())
		nRet := QRYSAC->VLRSACADO
	EndIf
	
Return nRet


User Function CAEA050J()	
	Private cMatSub := retMatSub(cMatLog)
	SA6->(DbOrderNickName('A6_YCODSRA'))
	If Empty(cMatSub)
		ApMsgInfo('Você não é substituto de nenhum suprido.')
		Return	
	ElseIf !SA6->(DbSeek(xFilial('SA6') + cMatSub + 'F'))
		Help(" ",1,'CAEA0050',,"Banco do suprido substituto não cadastrado.",1,0,,,,,,{"Favor, entre em contato com a UFIN - Unidade de Finanças."} )		
		Return	
	EndIf

	cMatLog := cMatSub
	FwClearHLP()
	FWExecView("Prestar Conta Substituto",'CAEA0050', MODEL_OPERATION_INSERT,,{|| .T.})
	//oExecView := FWViewExec():New()
   	//oExecView:setTitle("Prestar Conta Substituto")
   	//oExecView:setSource("CAEA0050")
   	//oExecView:setModal(.F.)
   	//oExecView:setOperation(3)
   	//oExecView:openView(.T.)
	cMatLog := PadL(cUserName, 6, '0')

Return

Static Function retMatSub(cMat)
	Local cQuery := ""
	Local cRet := ""
	Default cMat := cUserName
	cQuery += " SELECT coalesce(A6_YCODSRA,'') 'A6_YCODSRA'"
	cQuery += " FROM " + RetSqlName('SRA') + " SRA "
	cQuery += " INNER JOIN " + RetSqlName('SA6') + " SA6 ON RA_MAT=A6_YMATSUP AND SA6.D_E_L_E_T_='' "
	cQuery += " INNER JOIN " + RetSqlName('SRA') + " SRA1 ON SRA1.RA_MAT=A6_YCODSRA AND (SRA1.RA_AFASFGT NOT LIKE '%N1%' OR SRA1.RA_AFASFGT NOT LIKE '%N2%') AND SRA1.D_E_L_E_T_='' "
	cQuery += " LEFT JOIN " + RetSqlName('SR8') + " SR8 ON R8_MAT=SRA1.RA_MAT AND R8_DATAINI<='" + DtoS(dDataBase) + "' AND R8_DATAFIM>='" + DtoS(dDataBase) + "' AND SR8.D_E_L_E_T_='' "
	cQuery += " WHERE SRA.D_E_L_E_T_='' "	
	cQuery += " AND SRA.RA_MAT='" + alltrim(cMat) + "' "
	cQuery += " AND SRA.RA_SITFOLH<>'D' "
	
	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'
	
	If QRY->(!Eof())
		cRet := QRY->A6_YCODSRA
	EndIf
Return cRet


User Function CAEA050()
	Local xRet := .T.
	If PARAMIXB == NIL
        Return
    EndIf
	
	cAction 	:= PARAMIXB[2]
	
	If cAction == "MODELVLDACTIVE"

	EndIf

Return xRet


User Function CAEA050K(cMat)
	Local nTotZ11 := 0
	Local nTotZ12 := 0
	Local cQuery := ''
	Default cMat := oModel:GetValue("MASTERZ12", 'Z12_CODSRA')
	cQuery := " SELECT SUM(Z11_VALOR) AS TOTAL FROM " + RetSQLTab('Z11')
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND Z11_CODSRA = '"+cMat+"' AND Z11_STATUS = 'P' AND Z11_TIPO = 'F' "

	If Select('QRYZ11') > 0		
		QRYZ11->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYZ11'

	If QRYZ11->(!Eof())
        nTotZ11 := Round(QRYZ11->TOTAL,2)
	EndIf
	
	cQuery := " SELECT SUM(Z12_TOTAL) AS TOTAL FROM " + RetSQLTab('Z12')
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND Z12_CODSRA = '"+cMat+"' AND Z12_STATUS = 'E' "

	If Select('QRYZ12') > 0
		QRYZ12->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYZ12'

	If QRYZ12->(!Eof())
        nTotZ12	:= Round(QRYZ12->TOTAL,2)
	EndIf
	//Valor igual, prestou conta de tudo que solicitou
	//nTotZ11 == nTotZ12	
	
	//Valor solicitado maior, falta prestar conta
	//nTotZ11 > nTotZ12
	
Return nTotZ11 == nTotZ12


User Function CAEA050L()
	Local cQuery := ''
	SA6->(DbOrderNickName('A6_YCODSRA'))
	SA6->(DbSeek(xFilial('SA6') + cMatLog + 'F'))
	cQuery := " SELECT TOP 1 * "
	cQuery += " FROM "  + RetSqlTab('Z11')
	cQuery += " WHERE " + RetSqlDel('Z11')
	cQuery += " Z11_STATUS = 'P'"
	cQuery += " Z11_CODSRA = '" + cMatLog + "'"
	cQuery += " ORDER BY R_E_C_N_O_ DESC"
	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'
	//Verifica se valor da soma da Z11 é igual que Z12
	lRet := u_CAEA050K(cMatLog)
	//If lRet .And. SA6->A6_SALATU
	//	
	//ElseIf lRet 	
	//	If QRY->(!Eof())
	//	
	//EndIf
	

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0050
Validação do fechamento da PrestFF, só fecha prestação, se valor total for igual ao valor do saldo no banco
@author  Jerry Junior
@since   24/11/2020
@version 1.0
@type function
@Trello 2878
/*/
//-------------------------------------------------------------------
Static Function vldFechamento()
	Local lRet := .T.
	Local i := 1
	Local nValGasto := 0
	Local nValPrest := 0
	Local cDia := u_GetParam('DIAPRESTFF', .T., '04')
	Local cDataCorte := AnoMes(dDataBase) + cDia
	SA6->(DbOrderNickName('A6_YCODSRA'))
	Z13->(DbSetOrder(1))
	SA6->(dbSeek(xFilial('SA6')+Z12->Z12_CODSRA))
	
	If Month(dDataBase) <> Month(StoD(cDataCorte)) .Or. dDataBase <= StoD(cDataCorte)
		nValGasto := ValGasto()
	EndIf
	//EndIf

	nValPrest := SA6->A6_SALATU - nValGasto

	If Z12->Z12_TOTAL < nValPrest
		Help(" ",1,'CAEA0050',,"Valor total da prestação de contas, não pode ser inferior ao valor utilizado no período (Até o 4º dia do mês vigente).",1,0,,,,,,{"Favor, prestar contas do valor total utilizado no cartão até o 4º dia do mês corrente. Vlr: R$ " + alltrim(Transform(nValPrest,'@E 99,999.99')) } )
		lRet := .F.
	ElseIf Z12->Z12_TOTAL > nValPrest
		Help(" ",1,'CAEA0050',,"Valor total da prestação de contas, não pode ser superior ao valor utilizado no período (Até o 4º dia do mês vigente).",1,0,,,,,,{"Favor, prestar contas do valor total utilizado no cartão até o 4º dia do mês corrente. Vlr: R$ " + alltrim(Transform(nValPrest,'@E 99,999.99')) } )
		lRet := .F.
	ElseIf Empty(Z12->Z12_CODSEI)
		Help(" ",1,'OBRIGAT',,"Cod. SEI em branco.",1,0,,,,,,{"Favor, preencha o Cod. SEI válido." } )
		lRet := .F.
	Else
		If Z13->(dbSeek(Z12->Z12_FILIAL+Z12->Z12_CODIGO))
			CTT->(dbSetOrder(1))
			While Z13->(!Eof()) .And. Z13->Z13_FILIAL+Z13->Z13_CODZ12 == Z12->Z12_FILIAL+Z12->Z12_CODIGO
				If CTT->(dbSeek(xFilial('CTT')+Z13->Z13_CC)) .And. CTT->CTT_BLOQ=='1'
					Help(" ",1,'CTTBLOQ',,"Centro de custo no Doc/NF: " + alltrim(Z13->Z13_DOC) + " está bloqueado/desativado para operações. Linha: " + cvaltochar(i) + ".",1,0,,,,,,{"Favor, ajustar centro de custo para um válido." } )
					Return .F.
				EndIf
				i++
				Z13->(dbSkip())
			EndDo
		EndIf
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0050
Calcula valor gasto no cartao do suprido do dia 4 do mes corrente até a database
Pois esse valor, deverá ser retirado da composição de saldo como referência de obrigatoriedade de prestação de contas.
Ele será obrigado a prestar conta de tudo que foi gasto até o dia 4 de cada mês apenas.
@author  Jerry Junior
@since   10/12/2020
@version 1.0
@type function
@Redmine 21032
/*/
//-------------------------------------------------------------------
Static Function ValGasto()
	Local nRet := 0
	Local cQuery := ''	
	Local cDia := u_GetParam('DIAPRESTFF', .T., '04')
	Local cDataCorte := AnoMes(dDataBase) + cDia
	cQuery := " SELECT SUM(E5_VALOR) 'VALOR'"
	cQuery += " FROM " + RetSqlTab('SE5') + " (nolock)"
	cQuery += " WHERE SE5.D_E_L_E_T_=''"
	cQuery += " and E5_RECPAG='R'"
	cQuery += " and E5_AGENCIA='00000'"
	cQuery += " and E5_BANCO='CXI'"
	cQuery += " and E5_SITUACA=''"
	cQuery += " and E5_RECONC<>''"

	If Month(dDataBase) < Month(Date()) .And. Month(dDataBase) <> Month(Date())
		cQuery += " and E5_DATA > '" + DtoS(dDataBase) + "'"
	Else 
		cQuery += " and E5_DATA > '" + cDataCorte + "'"
		
		If dDataBase > StoD(cDataCorte)
			cQuery += " and E5_DATA <= '" + DtoS(dDataBase) + "'"
		EndIf
	EndIf	
	
	cQuery += " and right(E5_CONTA,6) = '" + Z12->Z12_CODSRA + "'"	

	If Select('QRYSE5') > 0
		QRYSE5->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYSE5'

	If QRYSE5->(!Eof())
		nRet := QRYSE5->VALOR
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DtValida
Retorna o quarto dia útil do mês corrente ou da data enviada como parametro
@author  Jerry Junior
@since   01/12/2020
@version 1.0
@type function
@param nDtMax, numeric, Valor máximo do dia util, default := 4
/*/
//-------------------------------------------------------------------
Static Function DtValida(nDtMax, dRet)	
	Local d := 1	
	Default nDtMax := 4
	Default dRet := FirstDate(dDataBase)
	While d < nDtMax
		If DateWorkDay(dRet, dRet, .F., .F., .F.) > 0
			d++
		EndIf
		dRet++
	EndDo

Return dRet
