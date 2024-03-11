#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'Rwmake.ch'
#INCLUDE 'TbIconn.ch'
#INCLUDE 'Topconn.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Cadastro de Medicao para Contratos de Serviços
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA0052()
	Local oBrowse
	Private cString := 'Z59'
	Private lInclui := .F.
	Private lAltera := .F.

	//Montagem do Browse principal
	oBrowse := FWMBrowse():New()

	//Legenda
	oBrowse:AddLegend('u_CAEA052N() == "A" ' , 'BR_VERDE'    , 'Aberto'    )
	oBrowse:AddLegend('u_CAEA052N() == "E" ' , 'BR_VERMELHO' , 'Efetivado' )
	oBrowse:AddLegend('u_CAEA052N() == "P" ' , 'BR_AZUL' 	 , 'Pendente' )

	//Define alias principal
	oBrowse:SetAlias('Z59')
	oBrowse:SetDescription('Medicao para Contratos de Serviços')
	oBrowse:SetMenuDef('CAEA0052')

	//Ativa a tela
	oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o menu principal
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
@return array, Array com os dados para os botoes do browse
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	//Opcoes do Menu
	aAdd( aRotina, { 'Visualizar' 	, 'VIEWDEF.CAEA0052' , 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'    	, 'U_CAEA052i(3)'    , 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'    	, 'U_CAEA052i(4)'  	 , 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Efetivar'   	, 'u_CAEA052a()' 	 , 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Cancelar'   	, 'u_CAEA052b()' 	 , 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Copiar Lote'	, 'u_CAEA052c()' 	 , 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Gerar NF Lote', 'u_CAEA052m()' 	 , 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'    	, 'VIEWDEF.CAEA0052' , 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir Lote', 'u_CAEA052j()' 	 , 0, 8, 0, NIL } )

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Construcao do modelo de dados
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
@return object, Retorna o objeto do modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruZ59 := FWFormStruct(1,'Z59')
	Local oStruZ60 := FWFormStruct(1,'Z60')
	Local oStruCND := FWFormStruct(1,'CND')
	Local nX := 1
	Public dDtIni52 := nil //Variavel de controle para incializar Z60_DTINIC
	Public dDtFim52	:= nil //Variavel de controle para incializar Z60_DTIFIM

	//Gatilhos
	oStruZ59:AddTrigger('Z59_CC', 'Z59_CC', {||.T.},{||U_CAEA052G()})
	//Adiciona campo virtual, para mostrar competencias em combobox
	oStruZ59:AddField("Competência"				,;	// 	[01]  C   Titulo do campo
		"Competência do contrato"		,;	// 	[02]  C   ToolTip do campo
		"Z59_RCCOMP"					,;	// 	[03]  C   Id do Field
		"C"							,;	// 	[04]  C   Tipo do campo
		5								,;	// 	[05]  N   Tamanho do campo
		0								,;	// 	[06]  N   Decimal do campo
		{|a,b,c,d|U_CAEA052H(a,b,c,d)}	,;	// 	[07]  B   Code-block de validação do campo
		NIL							,;	// 	[08]  B   Code-block de validação When do campo
		{"",""}						,;	//	[09]  A   Lista de valores permitido do campo
		.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
		NIL							,;	//	[11]  B   Code-block de inicializacao do campo
		NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
		.T.							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.							)	// 	[14]  L   Indica se o campo é virtual

	//Cria o formulario do modelo  - GravaDados: { |oModel| fGrvDados( oModel ) }
	oModel := MPFormModel():New('CAEA052', /*bPreValidacao*/, { |oModel| fTudoOk(oModel) }, /* GravaDados */, /*bCancel*/ )

	//Cria a estrutura principal(Z59)
	oModel:addFields('MASTERZ59',,oStruZ59)

	//Adiciona a chave
	oModel:SetPrimaryKey({'Z59_FILIAL', 'Z59_CODIGO'})

	//Cria estrutura de grid para os itens
	oModel:AddGrid('Z60DETAIL','MASTERZ59',oStruZ60, { |oModel, nLin, cAction, cCampo, nNewVal, nOldVal| fAntLinOK(oModel, nLin, cAction, cCampo, nNewVal, nOldVal) }, { |oModel| fLinOk(oModel) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	//Define a relacao entre as tabelas
	oModel:SetRelation('Z60DETAIL',{{'Z60_FILIAL','xFilial("Z60")'},{'Z60_CODZ59','Z59_CODIGO'}},Z60->(IndexKey(1)))

	// Retiro todas as validacoes. A grid sera apenas para visualizacao
	For nX := 1 to Len(oStruCND:aFields)
		oStruCND:aFields[nX][11] := {|a,b,c| FWInitCpo(a,b,c),xRet:=(''),FWCloseCpo(a,b,c,.T.),FwSetVarMem(a,b,xRet),xRet }
	Next

	//Filtro para a terceira tabela (grid)
	aCamposCND := {}
	aAdd(aCamposCND,{'CND_CONTRA','Z59_CONTRA' })
	aAdd(aCamposCND,{'CND_REVISA','Z59_REVISA' })
	aAdd(aCamposCND,{'CND_YZ59'  ,'Z59_CODIGO' })

	//Cria estrutura para a terceira grid
	oModel:AddGrid('CNDDETAIL', 'Z60DETAIL', oStruCND, {|| .F.}, {|| .F.}, {|| .F.})
	//Define a relacao entre as tabelas
	oModel:SetRelation('CNDDETAIL', aCamposCND, CND->(IndexKey(1)))

	//Define a descricao dos modelos
	oModel:GetModel('MASTERZ59'):SetDescription('Contrato de Serviços')
	oModel:GetModel('Z60DETAIL'):SetDescription('Medições Previstas')
	oModel:GetModel('CNDDETAIL'):SetDescription('Medições Geradas')

	//Define que o preenchimento da grid e' opcional
	oModel:GetModel('Z60DETAIL'):SetOptional( .F. )
	oModel:GetModel('CNDDETAIL'):SetOptional( .T. )

	//Define que a linha nao podera ter o conteudo repetido
	//oModel:GetModel('Z60DETAIL'):SetUniqueLine({'Z60_CODZ59'})
	//oModel:GetModel('Z60DETAIL'):SetUniqueLine({'Z60_OBS','Z60_CODZ59'})

	//AntesDeTudo
	oModel:SetVldActivate( {|oModel| fAntesTd(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta o view do modelo
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStrZ59 := FWFormStruct(2, 'Z59')
	Local oStrZ60 := FWFormStruct(2, 'Z60')
	Local oStrCND := FWFormStruct(2, 'CND')
	//Local lInclui := oModel:GetOperation() == MODEL_OPERATION_INSERT
	//Local lAltera := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	//Adiciona campo virtual, para mostrar competencias em combobox
	oStrZ59:AddField("Z59_RCCOMP"	,;	// [01]  C   Nome do Campo
		"07"			,;	// [02]  C   Ordem
		"Competência"	,;	// [03]  C   Titulo do campo
		"Competência do contrato"	,;	// [04]  C   Descricao do campo
		NIL				,;	// [05]  A   Array com Help
		"C"				,;	// [06]  C   Tipo do campo
		"@!"			,;	// [07]  C   Picture
		NIL				,;	// [08]  B   Bloco de Picture Var
		NIL				,;	// [09]  C   Consulta F3
		.T.				,;	// [10]  L   Indica se o campo é alteravel
		NIL				,;	// [11]  C   Pasta do campo
		NIL				,;	// [12]  C   Agrupamento do campo
		{"",""}			,;	// [13]  A   Lista de valores permitido do campo (Combo)
		NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
		NIL				,;	// [15]  C   Inicializador de Browse
		.T.				,;	// [16]  L   Indica se o campo é virtual
		NIL				,;	// [17]  C   Picture Variavel
		NIL				)	// [18]  L   Indica pulo de linha após o campo

	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('FORM_Z59' , oStrZ59,'MASTERZ59' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid('GRID_Z60', oStrZ60, 'Z60DETAIL' )
	oView:AddGrid('GRID_CND', oStrCND, 'CNDDETAIL' )

	// 30% cabec e 70% para as abas
	oView:CreateHorizontalBox('SUPERIOR', 30)
	oView:CreateHorizontalBox('INFERIOR', 70 )

	// Cria Folder na View
	oView:CreateFolder('PASTA_INFERIOR' ,'INFERIOR' )

	// Crias as pastas (abas)
	oView:AddSheet('PASTA_INFERIOR'    , 'ABA_Z60'  , 'Medições Previstas' )
	oView:AddSheet('PASTA_INFERIOR'    , 'ABA_CND'  , 'Medições Geradas'   )

	// Criar 'box' horizontal com 100% dentro das Abas
	oView:CreateHorizontalBox('ITENS'    ,100,,, 'PASTA_INFERIOR', 'ABA_Z60' )
	oView:CreateHorizontalBox('DETALHES' ,100,,, 'PASTA_INFERIOR', 'ABA_CND' )

	// Relaciona o ID da View com o 'box' para exibicao
	oView:SetOwnerView('FORM_Z59', 'SUPERIOR')
	oView:SetOwnerView('GRID_Z60', 'ITENS'   )
	oView:SetOwnerView('GRID_CND', 'DETALHES')

	//oStrZ59:RemoveField("Z59_RCCOMP")
	//oStrZ59:SetProperty('Z59_COMPET', MVC_VIEW_CANCHANGE, .T.)
	//oStrZ59:SetProperty('Z59_CONTRA', MVC_VIEW_CANCHANGE, .T.)
	//Se for inclusão, esconde campo Z59_COMPET da view
	//E destrava edição do campo Z59_CONTRA
	If lInclui
		oStrZ59:RemoveField("Z59_COMPET")
		oStrZ59:SetProperty('Z59_CONTRA', MVC_VIEW_CANCHANGE, .T.)

	Else
		oStrZ59:RemoveField("Z59_RCCOMP")
	EndIf

	oView:SetViewProperty("Z60DETAIL", "GRIDFILTER", {.T.})
	oView:SetViewProperty("Z60DETAIL", "GRIDSEEK", {.T.})
	oView:SetViewProperty("CNDDETAIL", "GRIDFILTER", {.T.})
	oView:SetViewProperty("CNDDETAIL", "GRIDSEEK", {.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052a
Funcao utilizada para efetivar o lote de medicoes
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052a()
	Local cFilAux := cFilAnt
	Local lCtrAutoNF := Alltrim(Z59->Z59_CONTRA) $ u_getParam('REGRAESPEC', .T., "20.00470,20.00469;NFS#20.01807;RECIB#20.00493;NFSC")
	Private nCont := 0
	Private lRet  := .F.
	Private lParalis := .F.

	If U_CAEA052N() == 'E' // STATUS DIFERENTE DE ENCERRADO
		Help("",1,'CAEA0052',,"Só é permitido efetivar lote de medição com status 'Aberto ou Pendente'.",1,0,,,,,,{"Por favor, verifique o status do Lote se ja esta Todo Concluido."} )
		Return
	EndIf

	CNN->(dbsetorder(1))
	If !CNN->(dbseek(xFilial('CNN')+__cUserId+Z59->Z59_CONTRA))
		Help("",1,'CAEA0052',,"Você não tem permissão para realizar esta ação neste contrato.",1,0,,,,,,{"Por favor, verifique a permissão com o responsável."} )
		Return .F.
	EndIf

	If Empty(Z59->Z59_TPDOT)
		Help("",1,'CAEA0052',,"Tipo de Dotação Orçamentária não informado.",1,0,,,,,,{"Por favor, defina qual o Tipo de Dotação Orçamentária do Lote antes de realizar esta ação."} )
		Return .F.
	EndIf

	BeginTran() //Inicia a transação, pois se der erro desfaz o RecLock da situação

	ajustRevis()


	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial('CN9')+Z59->Z59_CONTRA+Z59->Z59_REVISA))
	If CN9->CN9_SITUAC == '06'
		If !MsgYesNo('Este contrato está em situação de paralisação, deseja continuar com a operação?')
			DisarmTransaction()
			Return .F.
		EndIf
		lParalis := .T. //Marca flag, para que seja retornado a situação do contrato para 05
		RecLock('CN9', .F.)
		CN9->CN9_SITUAC := '05'
		CN9->(MsUnLock())
	EndIf

	nCont := contRegistros(Z59->Z59_CODIGO)

	If lCtrAutoNF
		MsgInfo("Esse contrato está parametrizado para geração automática de NF após o encerramento de medição, ou seja, o processo ficará mais lento, por favor aguarde o término da operação.")
	EndIf

	oProcess := MsNewProcess():New( { || lRet := incluiCND() }, "Incluindo Registros", "Aguarde, Incluindo Lote de Medição...", .F. )
	oProcess:Activate()

	//Chama função de inclusão da medição
	If lRet
		If lParalis //Verifica se contrato está paralisado e retorna situação para 05
			CN9->(dbSeek(xFilial('CN9')+Z59->Z59_CONTRA+Z59->Z59_REVISA))
			RecLock('CN9', .F.)
			CN9->CN9_SITUAC := '06'
			CN9->(MsUnLock())
		EndIf
		EndTran()
		If lCtrAutoNF
			oProcess := MsNewProcess():New( { || lRet := incluiSF1() }, "Gerando Notas", "Aguarde, Gerando NFs...", .F. )
			oProcess:Activate()
		EndIf

		ApMsgInfo("Operação realizada com sucesso.")
	EndIf
	cFilAnt := cFilAux
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Ajusta campo Z59_REVISA para a última revisão vigente do contrato
@author  Jerry Junior
@since   08/01/2021
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ajustRevis()
	Local oModel := Nil
	cQuery := " SELECT MAX(CN9_REVISA) 'REVISA' "
	cQuery += " FROM "  + RetSqlTab('CN9')
	cQuery += " WHERE " + RetSqlDel('CN9')
	cQUery += " AND CN9_NUMERO = '" + alltrim(Z59->Z59_CONTRA) + "'"
	cQuery += " AND CN9_SITUAC IN ('05','06')"

	If Select('QRYCN9') > 0
		QRYCN9->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRYCN9'

	If QRYCN9->(!Eof()) .And. QRYCN9->REVISA <> Z59->Z59_REVISA
		If IsInCallStack("U_CAEA052A") .Or. IsInCallStack("CAEA052A") .Or. IsInCallStack("fAntesTd")
			RecLock('Z59', .F.)
			Z59->Z59_REVISA := QRYCN9->REVISA
			Z59->(MsUnLock())
		Else
			oModel:FWModelActive()
			oModelCND := oModel:GetModel("MASTERZ59")
			oModelCND:LoadValue("Z59_REVISA", QRYCN9->REVISA)
		EndIf
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} incluiCND()
	Inclui registros da grid (Z60) na CND
	@author Jerry Junior
	@since   30/01/2019
	@version 1.0
	@type function
/*/
//-------------------------------------------------------------------
Static Function incluiCND()
	Local cQuery := ''
	Local cLog := ''
	Local nX, nY, i
	Local lRet := .T.
	Local cContra := alltrim(Z59->Z59_CONTRA)
	Local cCompet := alltrim(Z59->Z59_COMPET)
	Local lCtrAutoNF := Alltrim(cContra) $ u_getParam('REGRAESPEC', .T., "20.00470,20.00469;NFS#20.01807;RECIB#20.00493;NFSC")
	Local bWhile := {|| Z60->(!EoF()) .AND. Z60->(Z60_FILIAL+Z60_CODZ59) == Z59->(Z59_FILIAL+Z59_CODIGO)}
	Local cRetx			:= ""
	Private lMsErroAuto := .F.
	Private oModelCND
	Private INCLUI      := .T.

	oProcess:SetRegua2(nCont)

	aArea := GetArea()


	Z60->(dbSetOrder(2))
	Z60->(dbSeek(xFilial('Z60')+Z59->Z59_CODIGO))
	FwClearHLP()

	aAreaZ60 := Z60->(GetArea())

	While Eval(bWhile)
		If Empty(Z60->Z60_NUMNF)
			Help(" ",1,'CAEA0052',,"Campo com preenchimento obrigatório em branco.",1,0,,,,,,{"Favor informar o número da NF, filial medição: " + Z60->Z60_FILMED + ". Numero NF (Z60_NUMNF)."} )
			lRet := .F.
			Exit
		ElseIf Empty(Z60->Z60_DTEMNF)
			Help(" ",1,'CAEA0052',,"Campo com preenchimento obrigatório em branco.",1,0,,,,,,{"Favor informar a data de emissão da NF, filial medição: " + Z60->Z60_FILMED + ". Dt Emiss. NF (Z60_DTEMNF)."} )
			lRet := .F.
			Exit
		EndIf
		Z60->(dbSkip())
	EndDo

	If !lRet
		DisarmTransaction()
		Return .F.
	EndIf
	RestArea(aAreaZ60)
	lRet := .F. //Reinicializa a variavel com False
	While Eval(bWhile)
		//Verifica se periodo digita está entre alguma paralisão.
		//Pode ocorrer de haver paralisação posteriormente a criação do lote
		lRet := u_CAEA052L(Z59->Z59_CONTRA, 'Z60_DTINIC', 'Z60->')

		If lRet
			lRet := u_CAEA052L(Z59->Z59_CONTRA, 'Z60_DTFIM', 'Z60->')
		EndIf

		If !lRet
			DisarmTransaction()
			Return .F.
		EndIf


		cQuery := " SELECT CN9_SITUAC "
		cQuery += " FROM "  + RetSqlName('CN9') + " CN9"
		cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
		cQuery += " AND CN9_NUMERO = '" + Z59->Z59_CONTRA + "'"
		cQuery += " AND CN9_REVISA = (SELECT MAX(CN9_REVISA) 'REVISA'"
		cQuery += " 	FROM "  + RetSqlName('CN9')
		cQuery += " 	WHERE D_E_L_E_T_ <> '*'"
		cQuery += " 	AND CN9_NUMERO = '" + Z59->Z59_CONTRA + "'"
		cQuery += " )"
		cQuery += " AND CN9_SITUAC <> '05'"

		If Select('QRYREV') > 0
			QRYREV->(dbclosearea())
		EndIf

		TcQuery cQuery New Alias 'QRYREV'

		If QRYREV->(!Eof())
			Help("",1,'CAEA0052',,"Revisão atual está na situação " + u_X3_CBOX('CN9_SITUAC', QRYREV->CN9_SITUAC ),1,0,,,,,,{"Não é possível medir na situação atual. Por favor, contate a ALC - ASSESSORIA DE LICITACOES E CONTRATOS."} )
			DisarmTransaction()
			Return .F.
		EndIf

		oProcess:IncRegua2('Incluindo medição para filial: ' + Z60->Z60_FILMED)
		cFilAnt := Z60->Z60_FILMED
		//Ativa modelo para inclusão
		oModelCND := FwLoadModel("CNTA121")
		cRetx := CAEA052O(Z60->Z60_FILMED, Z60->Z60_NUMMED) // ANALISA SE JA FOI GERADO O PEDIDO DE COMPRAS
		if cRetx == 'A'
			oModelCND:SetOperation(4)
			oModelCND:Activate()
			oViewCND := FWViewActive()
			oModelCNE := oModelCND:GetModel('CNEDETAIL')
			CN121SetCp(oModelCND:GetModel('CNDMASTER'),,,,,.F.)
			CN120Compet()
			lMsErroAuto := .f.
			If oModelCND:VldData()
				oModelCND:CommitData()
			Else
				aLog := oModelCND:GetErrorMessage()
				For nX := 1 To Len(aLog)
					If (Empty(aLog[nX]) == .F.)
						cLog += AllTrim(aLog[nX]) + CRLF
					EndIf
				Next nX
				lMsErroAuto := .T.
				AutoGRLog(cLog)
			EndIf
			If lMsErroAuto
				MostraErro()
				If Len(aLog) > 0
					Help("",1,'CAEA0052',,cLog,1,0,,,,,,{"Por favor, revise os dados do Lote."} )
				EndIf
				DisarmTransaction()
				Return .F.
			Else
				//Troca filial logada para filial da medição
				cFilAnt := CND->CND_MSFIL
				oProcess:IncRegua2('Efetivando medição No. ' + CND->CND_NUMMED + ' | Filial : ' + CND->CND_MSFIL)

				//Se não for possivel encerrar, disarma transação e retorna
				If !CN121Encerr(.T.)//Cn121Exc()
					DisarmTransaction()
					ApMsgInfo("Operação não pode ser concluída.")
					Return .F.
				EndIf
				RecLock('Z60', .F.)
				Z60->Z60_NUMMED := CND->CND_NUMMED
				Z60->(MsUnLock())

				lRet := .T.
			EndIf
		ELSEIF  cRetx == 'I'
			oModelCND:SetOperation(3)

			If !oModelCND:CanActivate()
				If oModelCND:HasErrorMessage()
					aLog := oModelCND:GetErrorMessage()
					Help("",1,aLog[5],,aLog[6] ,1,0,,,,,,{aLog[7]} )
				EndIf
				Help("",1,'CAEA0052',,"O modelo não pôde ser ativado.",1,0,,,,,,{"Por favor, contate a USAD."} )
				DisarmTransaction()
				Return .F.
			EndIf
			oModelCND:Activate()
			oViewCND := FWViewActive()
			oModelCNE := oModelCND:GetModel('CNEDETAIL')
			//-------------------------------------------------------------------
			//-- Seleciona planilha da Medição
			//-- Preenchimento da Planilha 001
			//-- Seleciona item da planilha
			//-- Preenchimento da CNE (Itens)
			//-------------------------------------------------------------------

			//Dados da CND
			If !oModelCND:SetValue("CNDMASTER", "CND_CONTRA",cContra)
				aLog := oModelCND:GetErrorMessage()
				Help("",1,aLog[2],,aLog[6] ,1,0,,,,,,{aLog[7] + '(CAEA0052)'} )
				DisarmTransaction()
				Return .F.
			EndIf
			//oModelCND:SetValue("CNDMASTER", "CND_REVISA",cRevisa)
			aCompets := CtrCompets()
			nPosCompet := aScan(aCompets, {|x| Alltrim(x) == cCompet })
			cPosComp := cValToChar(nPosCompet)
			//Trava para quando o lote for efetivado, verifique se competencia escolhida ainda está com saldo disponível
			If Empty(cPosComp) .Or. cPosComp == '0'
				Help("",1,'CAEA0052',,"Competência do lote, não possui mais saldo suficiente.",1,0,,,,,,{"Por favor, copie o Lote e altere a competência."} )
				DisarmTransaction()
				Return .F.
			EndIf
			//Utilizado, para que dê tempo de apos inserir o contrato, a tela CNTA121, execute os triggers que alimenta o combobox do campo CND_RCCOMP
			Sleep(1000)
			//Se estiver vazio, é por que não retornou competencias no campo
			If Empty(Fwfldget('CND_RCCOMP'))
				Help("",1,'CAEA0052',,"Problema ao tentar incluir a medição. Rotina será fechada.",1,0,,,,,,{"Por favor, abra e tente novamente efetivar o lote"} )
				DisarmTransaction()
				Final()
			EndIf
			If !oModelCND:SetValue("CNDMASTER", "CND_RCCOMP"	,cPosComp)
				aLog := oModelCND:GetErrorMessage()
				Help("",1,aLog[2],,aLog[6] ,1,0,,,,,,{aLog[7] + '(CAEA0052)'} )
				DisarmTransaction()
				Return .F.
			EndIf
			oModelCND:LoadValue("CNDMASTER", "CND_OBS" 		, alltrim(Z60->Z60_OBS))
			oModelCND:LoadValue("CNDMASTER", "CND_MSFIL" 	, Z60->Z60_FILMED	)
			If !oModelCND:SetValue("CNDMASTER", "CND_YSEI"	, Z60->Z60_NUMSEI	)
				aLog := oModelCND:GetErrorMessage()
				Help("",1,aLog[2],,aLog[6] + ' - Timeout',1,0,,,,,,{aLog[7] + '(CAEA0052)'} )
				DisarmTransaction()
				Return .F.
			EndIf
			oModelCND:LoadValue("CNDMASTER", "CND_YNUMBM"	,Z60->Z60_NUMBM		)
			oModelCND:SetValue("CNDMASTER", "CND_YINIME"	,Z60->Z60_DTINIC	)
			oModelCND:SetValue("CNDMASTER", "CND_YFIMME"	,Z60->Z60_DTFIM		)
			oModelCND:SetValue("CNDMASTER", "CND_YNUMNF"	,Z60->Z60_NUMNF		)
			oModelCND:SetValue("CNDMASTER", "CND_YTPDOT"	,Z59->Z59_TPDOT		)

			If Z60->Z60_VLVINC > 0
				oModelCND:SetValue("CNDMASTER", "CND_YCTVIN"	,Z60->Z60_VLVINC	)
			EndIf

			If lCtrAutoNF
				oModelCND:SetValue("CNDMASTER", "CND_YDEMNF"	,Z60->Z60_DTEMNF	)
			EndIf

			oModelCND:LoadValue("CNDMASTER", "CND_YZ59"  	,Z59->Z59_CODIGO	)

			//Chama função padrao, para preencher o campo CND_COMPET
			//Com a opção que esta no CND_RCCOMP
			//E carrega planilhas disponiveis (CXNDETAIL) na competencia setada
			CN121SetCp(oModelCND:GetModel('CNDMASTER'),,,,,.F.)
			CN120Compet()
			//Faz o loop na CXN, para marcar/check a planilha escolhida na Z60
			//Dados da CXN
			For nY := 1 to oModelCND:GetModel("CXNDETAIL"):GetQtdLine()
				oModelCND:GetModel("CXNDETAIL"):GoLine(nY)
				If FwFldGet('CXN_NUMPLA') == alltrim(Z60->Z60_PLAN)
					oModelCND:SetValue("CXNDETAIL","CXN_CHECK", .T.)
					Exit
				EndIf
			Next nY

			If Empty(FwFldGet('CXN_NUMPLA'))
				Help("",1,'CAEA0052',,"Nenhuma planilha foi selecionada.",1,0,,,,,,{"Por favor, verifique as planilhas disponíveis no contrato."} )
				DisarmTransaction()
				Return .F.
			EndIf

			//Dados da CNE
			nQtd 	:= 1
			nZ60Tot	:= Z60->Z60_VALOR
			nVlAux  := 0
			nCNETot := nZ60Tot
			aVal := {}
			nValDif := 0
			nPosValDif := 0
			CNB->(DbSetOrder(1))
			For i:=1 to oModelCNE:GetQtdLine()
				oModelCNE:GoLine(i)
				oModelCNE:SetValue("CNE_VLTOT", 0)
				//aScan(aVal, {|x| x[1] == CNB->(CNB_NUMERO+CNB_PRODUT) }) > 0
				cPlanProd := oModelCNE:Getvalue("CNE_NUMERO") + oModelCNE:Getvalue("CNE_PRODUT") + oModelCNE:Getvalue("CNE_ITEM")
				If !(Z60->(Z60_PLAN+Z60_PRODUT+Z60_ITEM) == cPlanProd)
					Loop
				EndIf

				oModelCNE:SetValue("CNE_VLTOT", nCNETot)
				oModelCNE:SetValue("CNE_NUMERO", Z60->Z60_PLAN)
				oModelCNE:SetValue("CNE_CC", Z59->Z59_CC)
			Next

			//Valida dados antes de salvar
			If oModelCND:VldData()
				oModelCND:CommitData()
			Else
				aLog := oModelCND:GetErrorMessage()
				For nX := 1 To Len(aLog)
					If (Empty(aLog[nX]) == .F.)
						cLog += AllTrim(aLog[nX]) + CRLF
					EndIf
				Next nX
				lMsErroAuto := .T.
				AutoGRLog(cLog)
			EndIf
			If lMsErroAuto
				MostraErro()
				If Len(aLog) > 0
					Help("",1,'CAEA0052',,cLog,1,0,,,,,,{"Por favor, revise os dados do Lote."} )
				EndIf
				DisarmTransaction()
				Return .F.
			Else
				//Troca filial logada para filial da medição
				cFilAnt := CND->CND_MSFIL
				oProcess:IncRegua2('Efetivando medição No. ' + CND->CND_NUMMED + ' | Filial : ' + CND->CND_MSFIL)

				//Se não for possivel encerrar, disarma transação e retorna
				If !CN121Encerr(.T.)//Cn121Exc()
					DisarmTransaction()
					ApMsgInfo("Operação não pode ser concluída.")
					Return .F.
				EndIf
				RecLock('Z60', .F.)
				Z60->Z60_NUMMED := CND->CND_NUMMED
				Z60->(MsUnLock())

				lRet := .T.
			EndIf
		ENDIF
		oModelCND:DeActivate()
		oModelCND:Destroy()

		Z60->(dbSkip())
	EndDo

	If lRet
		RecLock('Z59', .F.)
		Z59->Z59_STATUS := 'E'
		Z59->(MsUnLock())
	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} efetivaCND
	Efetiva Medições na CND com os dados dos itens da Z60
	@author Jerry Junior
	@since   30/01/2019
	@version 1.0
	@type function
/*/
//-------------------------------------------------------------------
Static Function efetivaCND()
	Local lRet  := .F.

	oProcess:SetRegua2(nCont)
	//Filial + CodZ59 + Revisao
	CND->(dbOrderNickName("CNDYCODZ59"))
	CND->(dbGoTop())
	CND->(dbSeek(xFilial('CND')+Z59->Z59_CODIGO))

	While CND->(!EoF()) .AND. CND->(CND_FILIAL+CND_YZ59) == Z59->(Z59_FILIAL+Z59_CODIGO)

		oProcess:IncRegua2('Efetivando medição No. ' + CND->CND_NUMMED + ' | Filial : ' + CND->CND_MSFIL)
		//Troca filial logada para filial da medição
		cFilAnt := CND->CND_MSFIL

		If !(Alltrim(CND->CND_SITUAC) $ "A")
			DisarmTransaction()
			lRet := .F.
			Help("",1,'CAEA0052',,"Operação não permitida. Somente é possível encerrar Medições que estejam abertas.",1,0,,,,,,{"Por favor, verifique o status das modições."} )
			Return lRet
		EndIF
		If !Empty(CND->CND_DTFIM)
			CND->(dbSkip())
		EndIf

		//Se não for possivel encerrar, disarma transação e retorna
		If !CN121Encerr(.T.)//Cn121Exc()
			DisarmTransaction()
			lRet := .F.
			ApMsgInfo("Operação não pode ser concluída.")
			Return lRet
		Else
			lRet := .T.
		EndIf

		CND->(dbSkip())
	EndDo

	//Se chegar nesse ponto, a transação deu certo e marca status com 'E' - Efetivado
	If lRet
		RecLock('Z59', .F.)
		Z59->Z59_STATUS := 'E'
		Z59->(MsUnLock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Gera
@author  Jerry Junior
@since   13/10/2021
@version 1.0
@type function
@Redmine
/*/
//-------------------------------------------------------------------
Static Function incluiSF1()
	Local lRet := .T.
	Local cEspecie := ''
	Local cSerie := u_getParam('SERMEDNF', .T., 'U')
	Local aRegraCtr := {}
	Local aRegraEsp := StrToKArr2(u_getParam('REGRAESPEC', .T., "20.00470,20.00469;NFS#20.01807;RECIB#20.00493;NFSC"), "#")
	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local aItemCNE := {}
	Local cMsg := ""
	Local cErro := ""
	Local cFilBkp := cFilAnt
	Local aSc7Cne	:= {}
	Local nFor		:= 0
	Local cTRBGY	:= "POLOP"

	//Filial + Cod Z59
	CND->(dbOrderNickName("CNDYCODZ59"))
	CND->(dbSeek(cChaveCND := xFilial('CND') + Z59->Z59_CODIGO))
	oProcess:SetRegua2(nCont)
	//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	SC7->(dbSetOrder(1))

	While CND->(!EoF()) .AND. CND->(CND_FILIAL+CND_YZ59) == cChaveCND

		cContra := CND->CND_CONTRA
		cRevisa := CND->CND_REVISA
		cNumMed := CND->CND_NUMMED
		cNumNF  := CND->CND_YNUMNF
		// TRATAMENTO DO RM 32680 
		iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
		beginsql alias cTRBGY
			SELECT
				COUNT(*) AS QTD
			FROM
				%TABLE:Z59% A,%TABLE:Z60% B,%TABLE:CND% C,%TABLE:SF1% D
			WHERE
				A.Z59_CODIGO = B.Z60_CODZ59
				AND A.%NOTDEL%
				AND B.%NOTDEL%
				AND C.%NOTDEL%
				AND D.%NOTDEL%
				AND A.Z59_CONTRA = %EXP:cContra%
				AND A.Z59_REVISA = %EXP:cRevisa%
				AND B.Z60_NUMMED = %EXP:cNumMed%
				AND B.Z60_NUMNF = %EXP:cNumNF%
				AND A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
				AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
				AND A.Z59_CONTRA = C.CND_CONTRA
				AND A.Z59_REVISA = C.CND_REVISA
				AND C.CND_FILMED = B.Z60_FILMED
				AND C.CND_YZ59 = A.Z59_CODIGO
				AND C.CND_NUMMED = B.Z60_NUMMED
				AND C.CND_FILMED = D.F1_FILIAL
				AND C.CND_YNUMNF = D.F1_DOC
				AND A.Z59_CONTRA = D.F1_YCONTRA
				AND A.Z59_REVISA = D.F1_YREVISA
		EndSql
		DBSELECTAREA(cTRBGY)
		IF (cTRBGY)->QTD <= 0


			nPos := aScan(aRegraEsp, {|x| Alltrim(cContra) $ x })

			aRegraCtr := StrToKArr2(aRegraEsp[nPos], ";")

			cEspecie := aRegraCtr[2]


			//CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED+CXN_NUMPLA+CXN_PARCEL
			CXN->(dbSetOrder(1))
			CXN->(dbSeek(xFilial('CXN') + cContra + cRevisa + cNumMed))
			While !CXN->(Eof()) .And. CXN->(CXN_FILIAL+CXN_CONTRA+CXN_REVISA+CXN_NUMMED) == (xFilial('CXN') + cContra + cRevisa + cNumMed)
				If CXN->CXN_CHECK
					Exit
				Endif
				CXN->(dbSkip())
			EndDo

			cFornece := CXN->CXN_FORNEC
			cLoja := CXN->CXN_LJFORN
			cPlanilha := CXN->CXN_NUMPLA

			//CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM
			CNE->(dbSetOrder(1))
			CNE->(dbSeek(cChaveCNE := xFilial('CNE') + cContra + cRevisa + cPlanilha + cNumMed))
			// regra da Chave da CNE para ajustar a SC7 para corrigir a origem do erro RM 32550 by Leandro Duarte
			aAreaCne	:= CNE->(Getarea())
			While CNE->(!Eof()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == cChaveCNE
				If CNE->CNE_VLTOT > 0
					aAdd(aSc7Cne, {CNE->CNE_PRODUT, CNE->CNE_QUANT, CNE->CNE_VLUNIT, CNE->CNE_VLTOT})
				EndIf
				CNE->(dbSkip())
			EndDo
			RESTAREA(aAreaCne)

			aItemCNE := {}
			//Posiciona na primeira CNE que tenha valor medido, para posicionar a CXJ, para posicionar a SC7
			While CNE->(!Eof()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == cChaveCNE
				If CNE->CNE_VLTOT > 0
					aAdd(aItemCNE, {CNE->CNE_QUANT, CNE->CNE_VLUNIT, CNE->CNE_VLTOT})
					Exit
				EndIf
				CNE->(dbSkip())
			EndDo

			cItemPla := CNE->CNE_ITEM

			//CXJ_FILIAL+CXJ_CONTRA+CXJ_NUMMED+CXJ_NUMPLA+CXJ_ITEMPL+CXJ_PRTENV+CXJ_ID
			CXJ->(dbSetOrder(1))
			CXJ->(dbSeek(xFilial('CXJ') + cContra + cNumMed + cPlanilha + cItemPla))

			cNumPed := CXJ->CXJ_NUMPED
			//C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM
			SC7->(dbSetOrder(3))
			If !SC7->(dbSeek(xFilial('SC7') + cFornece + cLoja + cNumPed))
				cErro += 'Não foi gerado pedido para esta medição [' + cNumMed + ']. Favor, tente gerar o pedido menual em Outras Ações > Gerar Pedido Manual' + "<br>"
				CND->(dbSkip())
				Loop
			ELSE
				// regra da Chave da CNE para ajustar a SC7 para corrigir a origem do erro RM 32550 by Leandro Duarte
				aAreaSC7	:= SC7->(Getarea())
				SC7->(dbSetOrder(2))
				For nFor := 1 to len(aSc7Cne)
					if SC7->(dbSeek(xFilial('SC7') + aSc7Cne[nFor][1] + cFornece + cLoja + cNumPed))
						RecLock("SC7",.f.)
						SC7->C7_QUANT	:= aSc7Cne[nFor][2]
						SC7->C7_PRECO	:= aSc7Cne[nFor][3]
						SC7->C7_TOTAL	:= aSc7Cne[nFor][4]
						MsUnlock()
					endif
				Next nFor
				RestArea(aAreaSC7)
			EndIf

			//D1_FILIAL+D1_PEDIDO
			SD1->(dbSetOrder(22))
			If SD1->(dbSeek(CND->CND_MSFIL + SC7->C7_NUM))
				CND->(dbSkip())
				Loop
			EndIf

			aCab := {}
			//Cabeçalho
			aAdd(aCab, {"F1_TIPO" 		, "N" , Nil})
			aAdd(aCab, {"F1_FORMUL"		, "N" , Nil})
			aAdd(aCab, {"F1_DOC" 		, CND->CND_YNUMNF , Nil})
			aAdd(aCab, {"F1_SERIE" 		, cSerie , Nil})
			aAdd(aCab, {"F1_EMISSAO" 	, CND->CND_YDEMNF , Nil})
			aAdd(aCab, {"F1_DTDIGIT" 	, dDataBase , Nil})
			aAdd(aCab, {"F1_FORNECE" 	, cFornece , Nil})
			aAdd(aCab, {"F1_LOJA" 		, cLoja , Nil})
			aAdd(aCab, {"F1_ESPECIE" 	, cEspecie , Nil})
			aAdd(aCab, {"F1_VALBRUT" 	, CNE->CNE_VLTOT , Nil})
			aAdd(aCab, {"F1_VALMERC" 	, CNE->CNE_VLTOT , Nil})
			aAdd(aCab, {"F1_COND" 		, "001" , Nil})
			aAdd(aCab, {"F1_DESCONT" 	, 0 , Nil})
			aAdd(aCab, {"F1_SEGURO" 	, 0 , Nil})
			aAdd(aCab, {"F1_FRETE" 		, 0 , Nil})
			aAdd(aCab, {"F1_MOEDA" 		, 1 , Nil})
			aAdd(aCab, {"F1_TXMOEDA" 	, 1 , Nil})
			aAdd(aCab, {"F1_STATUS" 	, "A" , Nil})
			aAdd(aCab, {"F1_YCONTRA" 	, cContra , Nil})
			aAdd(aCab, {"F1_YREVISA" 	, cRevisa , Nil})


			cItem := '0001'
			aItens := {}
			While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM) == (xFilial('SC7') + cFornece + cLoja + cNumPed)
				aItem := {}
				aAdd(aItem, {"D1_ITEM"  , cItem, Nil})
				aAdd(aItem, {"D1_COD"   , SC7->C7_PRODUTO, Nil})
				aAdd(aItem, {"D1_UM"    , SC7->C7_UM, Nil})
				aAdd(aItem, {"D1_LOCAL" , SC7->C7_LOCAL, Nil})
				aAdd(aItem, {"D1_QUANT" , CNE->CNE_QUANT, Nil})
				aAdd(aItem, {"D1_VUNIT" , CNE->CNE_VLUNIT, Nil})
				aAdd(aItem, {"D1_TOTAL" , CNE->CNE_VLTOT, Nil})
				aAdd(aItem, {"D1_TES"   , SC7->C7_TES, Nil})
				aadd(aItens,aItem)
				aadd(aItens[Len(aItens)], {'D1_PEDIDO ', SC7->C7_NUM ,}) // Número do Pedido de Compras
				aadd(aItens[Len(aItens)], {'D1_ITEMPC ', SC7->C7_ITEM ,}) // Item do Pedido de Compras

				cItem := Soma1(cItem)
				SC7->(dbSkip())
			EndDo

			oProcess:IncRegua2('Incluindo Doc.:' + CND->CND_YNUMNF + ' | Medição:' + CND->CND_NUMMED)

			Private aHeader := aClone(aItens[1])

			cNaturez := ExecBlock("MT103NTZ",.F.,.F.,{''})
			aAdd(aCab, { "F1_NATUREZ", cNaturez, Nil})
			aAdd(aCab, { "E2_NATUREZ", cNaturez, Nil})

			Private dMV_ULMES := GetMv('MV_ULMES')
			Private dMV_DBLQMV := GetMv('MV_DBLQMOV')
			Private sDtMov := DtoS(LastDate(MonthSub(dDataBase,2)))
			//Abre parametro do estoque e compras
			PutMv('MV_ULMES', sDtMov)
			PutMv('MV_DBLQMOV', sDtMov)

			lMsErroAuto := .F.
			cFunAux := FunName()
			cModAux := cModulo
			u_SetFilial(CND->CND_MSFIL)
			SetFunName('MATA103')
			SetModulo( "SIGACOM", "COM" )
			MATA103(aCab,aItens,3)
			SetFunName(cFunAux)
			SetModulo( "SIGA"+cModAux, cModAux )

			//Abre parametro do estoque e compras
			PutMv('MV_ULMES', DtoS(dMV_ULMES))
			PutMv('MV_DBLQMOV', DtoS(dMV_DBLQMV))

			If lMsErroAuto
				cErro += "Falha na inclusão da NF-e: " + CND->CND_YNUMNF + ". Medição: " + CND->CND_NUMMED + "<br>"
				cErro += MostraErro('\temp\nfeauto\','caea0052_'+CND->CND_YZ59+'.txt') + "<br>"
				cErro += "_________________________________________________________________________________________________<br><br>"
			Endif
		ENDIF
		CND->(dbSkip())
	EndDo

	If !Empty(cErro)
		cAssunto := "[ALERTA] Inclusão Automática NF-e. Contrato: " + Alltrim(Z59->Z59_CONTRA) + " / Lote de Medição: " + Z59->Z59_CODIGO
		cPara := u_GetParam('MAILCALEND',.T.,"jerry.junior@totvs.com.br;contabilidade@caern.com.br")
		cMsg := "Houve problema na inclusão automática de NF-e após a efetivação do Lote de Medição.<br>"
		cMsg += "Usuário: " + cUserName + "<br>"
		cMsg += "Favor, verificar mensagem abaixo.<br><br>"
		cMsg += cErro
		If ! U_UEnviaEmail(cMsg, cPara, cAssunto)
			conout("Falha ao enviar email > CAEA0052")
		EndIf
	EndIf

	u_SetFilial(cFilBkp)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052b
Funcao utilizada para Cancelar (Estornar e Excluir) o lote de medicoes
@author  Jery Junior
@since   30/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052b()
	Local cFilAux := cFilAnt
	Private nCont := 0
	Private lRet  := .F.

	If !Z59->Z59_STATUS $ 'E'
		Help("",1,'CAEA0052',,"Operação não permitida. Somente é possível cancelar Lote de Medições que esteja efetivado.",1,0,,,,,,{"Por favor, verifique o status do lote."} )
		Return .F.
	EndIf

	CNN->(dbsetorder(1))
	If !CNN->(dbseek(xFilial('CNN')+__cUserId+Z59->Z59_CONTRA))
		Help("",1,'CAEA0052',,"Você não tem permissão para realizar esta ação neste contrato.",1,0,,,,,,{"Por favor, verifique a permissão com o responsável."} )
		Return .F.
	EndIf

	ApMsgInfo("Esta ação irá Estornar e Excluir todas as Medições do Lote.")

	If !MsgYesNo("Você realmente deseja cancelar este Lote de Medição?")
		Return .F.
	EndIf

	BeginTran()

	nCont := contRegistros(Z59->Z59_CODIGO)
	SetFunName("CNTA121")
	oProcess := MsNewProcess():New( { || lRet := cancelaCND() }, "Cancelamento de Lote", "Aguarde, Cancelando Lote de Medição...", .F. )
	oProcess:Activate()


	//Se incluir todas as medições, chama função para efetivar medições
	If lRet
		EndTran()
	EndIf

	SetFunName("CAEA0052")
	cFilAnt := cFilAux

Return

Static Function cancelaCND()
	Local lRet := .T.

	oProcess:SetRegua2(nCont)
	//Filial + CodZ59 + Revisao
	CND->(dbOrderNickname('CNDYCODZ59'))
	CND->(dbGoTop())
	If CND->(dbseek(xFilial('CND')+Z59->Z59_CODIGO))

		While CND->(!EoF()) .AND. CND->(CND_FILIAL+CND_YZ59) == Z59->(Z59_FILIAL+Z59_CODIGO)
			cFilAnt := CND->CND_MSFIL

			If !(Alltrim(CND->CND_SITUAC) $ "E|FE|SE")
				DisarmTransaction()
				Help("",1,'CAEA0052',,"Operação não permitida. Somente é possível estornar Medições que estejam encerradas.",1,0,,,,,,{"Por favor, verifique o status do lote."} )
				lRet := .F.
				Exit
			ElseIf lRet .AND. !CN121Estorn(.T.)
				DisarmTransaction()
				ApMsgInfo("Operação não pode ser concluída.")
				lRet := .F.
				Exit
			EndIf

			If lRet
				oProcess:IncRegua2('Estornando medição No. ' + CND->CND_NUMMED + ' | Filial : ' + CND->CND_MSFIL)
				//Abre modelo com operação de exclusão
				oModelCND := FwLoadModel("CNTA121")
				oModelCND:SetOperation(5)
				oModelCND:Activate()

				If !oModelCND:CommitData()
					DisarmTransaction()
					ApMsgInfo("Operação não pode ser concluída.")
					lRet := .F.
					Exit
				EndIf
			EndIf

			CND->(dbSkip())
		EndDo

		If lRet //Se chegar nesse ponto, a transação deu certo e marca status com 'A' - Aberto
			RecLock('Z59', .F.)
			Z59->Z59_STATUS := 'A'
			Z59->(MsUnLock())

			ApMsgInfo("Operação realizada com sucesso.")
		EndIf

	Else
		ApMsgInfo('Não há um vínculo desse lote com alguma medição.')
	EndIf
	FwClearHLP()
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052c
Realiza copia de medição, para agilizar processo de preenchimento
@author  Jerry Junior
@since   29/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052c()
	//Guarda codigo do registro selecionado
	Local cContra := Z59->Z59_CONTRA
	Local cRevisa := Z59->Z59_REVISA
	Local aRet    := {}
	Private cNewCompet := ''
	Private aComp := {}// atribuição a regra do RM 32955 by Leandro duarte
	Private aCompSemN := {} // atribuição a regra do RM 32955 by Leandro duarte
	Private aCompets := {} // atribuição a regra do RM 32955 by Leandro duarte
	Private lMedSemCmp := .F. // Controle para quando contrato não tiver cronograma financeiro na CNF
	Private lParalis := .F. // Controle para contratos com situação Paralisado


	CNN->(dbsetorder(1))
	If !CNN->(dbseek(xFilial('CNN')+__cUserId+Z59->Z59_CONTRA))
		Help("",1,'CAEA0052',,"Você não tem permissão para realizar esta ação neste contrato.",1,0,,,,,,{"Por favor, verifique a permissão com o responsável."} )
		Return .F.
	EndIf

	If MsgYesNo("Deseja copiar essa medição de contrato?")
		aRet := pergCompet(cContra,cRevisa)
		If aRet[1]
			lInclui := .F.
			BeginTran()
			If copiaLote(aRet[2])
				EndTran()
				ApMsgInfo("Lote copiado com sucesso!")
			EndIf
			lInclui := .F.
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAntesTd
(PE AntesDeTudo) Função para a abertura da tela.
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fAntesTd(oModel)
	Local lRet     	 := .T.
	Local nOperation := oModel:GetOperation()
	Local lAltera    := nOperation == MODEL_OPERATION_UPDATE
	Local lExclui    := nOperation == MODEL_OPERATION_DELETE

	If (lAltera .OR. lExclui)
		If Z59->Z59_STATUS <> 'A'
			Help("",1,'CAEA0052',,"Não é possível "+Iif(lAltera, "alterar", "excluir")+" um lote de medição com status "+u_X3_CBOX('Z59_STATUS', Z59->Z59_STATUS)+".",1,0,,,,,,{"Por favor, verifique o Status do lote."} )
			lRet := .F.
		Else
			//Se for alterar ou excluir algum item com contrato que não tenha acesso, não permite
			CNN->(dbsetorder(1))
			If !CNN->(dbseek(xFilial('CNN')+__cUserId+Z59->Z59_CONTRA))
				Help("",1,'CAEA0052',,"Você não tem permissão para realizar esta ação neste contrato.",1,0,,,,,,{"Por favor, verifique a permissão com o responsável."} )
				lRet := .F.
			EndIf
		EndIf

		If lAltera
			lMedSemCmp := !CNF->(dbSeek(xFilial('CNF')+Z59->Z59_CONTRA+Z59->Z59_REVISA))
		EndIf
	EndIf
	ajustRevis()
	FwClearHLP()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
(PE TudoOk) Validacao da tela.
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fTudoOk(oModel)
	Local lRet       := .T.
	Local oModelZ59  := oModel:GetModel('MASTERZ59')
	Local oModelZ60  := oModel:GetModel('Z60DETAIL')
	Local aSaveLines := FWSaveRows()
	Local nOperation := oModel:GetOperation()
	Local nQtd 			 := oModelZ60:GetQtdLine()
	Local nX
	Local nTOTLOTE := 0

	FwClearHLP()
	//Valida se é possivel realizar exclusao do lote
	If nOperation == MODEL_OPERATION_DELETE
		If Z59->Z59_STATUS == 'A'
			Return .T.
		Else
			Help("",1,'CAEA0052',,"Não é possível excluir um lote de medição com status "+u_X3_CBOX('Z59_STATUS', Z59->Z59_STATUS)+".",1,0,,,,,,{"Por favor, verifique o Status do lote."} )
			Return .F.
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		CNN->(dbsetorder(1))
		If !CNN->(dbseek(xFilial('CNN')+__cUserId+FwFldGet('Z59_CONTRA')))
			Help("",1,'CAEA0052',,"Você não tem permissão para realizar esta ação neste contrato.",1,0,,,,,,{"Por favor, verifique a permissão com o responsável."} )
			Return .F.
		EndIf
	EndIf

	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. Empty(FwFldGet("Z59_TPDOT"))
		Help("",1,'CAEA0052',,"Tipo de Dotação Orçamentária não preenchida.",1,0,,,,,,{"Por favor, escolha uma das opções."} )
		Return .F.
	EndIf


	For nX := 1 to nQtd
		// Se a linha estiver deletada, pula
		If oModelZ60:IsDeleted()
			Loop
		EndIf

		//Chama linhaOk
		If !fLinok(oModelZ60, nX)
			Return .F.
		EndIf

		nTOTLOTE += oModelZ60:GetValue('Z60_VALOR', nX)

	Next

	If ! (nTOTLOTE == FwFldGet('Z59_VLLOTE'))
		oModelZ59:LoadValue('Z59_VLLOTE', nTOTLOTE)
	EndIf

	FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Atualiza o campo Z59_VLLOTE quando deletar uma linha
@author  Jerry Junior
@since   27/03/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fAntLinOK(oModel, nLin, cAction, cCampo, nNewVal, nOldVal)
	Local oModelo := FWModelActive()
	Local oModelZ59  := oModelo:GetModel('MASTERZ59')
	Local lRet := .T.
	Local nVlLote := FwFldGet('Z59_VLLOTE')
	Local nVlLin := FwFldGet('Z60_VALOR', nLin)
	Default cCampo := ''

	//If cAction == 'SETVALUE' .And. alltrim(cCampo) <> 'Z60_VALOR'
	//	Return .T.
	//EndIf
	//
	If cAction == "DELETE"
		oModelZ59:LoadValue('Z59_VLLOTE', nVlLote - nVlLin)
	ElseIf cAction == "UNDELETE"
		oModelZ59:LoadValue('Z59_VLLOTE', nVlLote + nVlLin)
	EndIf
	//ElseIf cAction == 'SETVALUE'
	//	If round(nOldVal,2) == round(nNewVal,2)
	//		nVlLin := 0
	//	Else
	//    	nOp := Iif(nOldVal < nNewVal, 1, -1)
	//		nVlLin := nOldVal + Abs(nOldVal - nNewVal) * nOp
	//	EndIf
	//EndIf
	//
	//oModelZ59:LoadValue('Z59_VLLOTE', nVlLote + nVlLin)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fLinok
(PE LinOk) Validacao da linha da primeira grid.
@author  Jose Vitor
@since   15/01/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fLinok(oModel, nLin)
	Local lRet       := .T.
	Local aSaveLines := FWSaveRows()
	Local oModelZ60	 := oModel:GetModel('Z60DETAIL')
	Local cProdBM	 := SuperGetMv('MS_PRODBM', .F., '7.02')
	Local cContra	 := FWFldGet('Z59_CONTRA')
	Local cRevisa 	 := FWFldGet('Z59_REVISA')
	Local cCompet 	 := alltrim(FWFldGet('Z59_COMPET'))
	Local cPlan		 := ""
	Local cProd   	 := ""
	Local cBM	     := ""
	Local cSei		 := ""
	Local nQtd		 := oModel:GetQtdLine()
	Local nJ
	Local nCont 	 := 0
	Local cFilMed 	 := ''
	Default nLin     := oModel:nLine
	Private nTotal 	 := 0 // Controle soma total de cada planilha na grid
	Private nSldPlan := 0 // Controle de saldo disponivel de cada planilha na grid
	FwClearHLP()
	If !oModel:IsDeleted() .And. nLin > 0
		cFilMed := alltrim(FWFldGet('Z60_FILMED'  , nLin))
		cPlan 	:= alltrim(FWFldGet('Z60_PLAN'  , nLin))
		cProd 	:= alltrim(FWFldGet('Z60_PRODUT', nLin))
		cItem 	:= alltrim(FWFldGet('Z60_ITEM', nLin))
		nValor 	:= FWFldGet('Z60_VALOR', nLin)
		cBM	  	:= alltrim(FWFldGet('Z60_NUMBM' , nLin))
		cSei  	:= alltrim(FWFldGet('Z60_NUMSEI', nLin))
		cObs  	:= alltrim(FWFldGet('Z60_OBS', nLin))
		cNumNf	:= alltrim(FWFldGet('Z60_NUMNF', nLin))
		dDtEmiNf:= FWFldGet('Z60_DTEMNF', nLin)
		dDtIni  := FWFldGet('Z60_DTINIC', nLin)
		dDtFim  := FWFldGet('Z60_DTFIM' , nLin)
		nVlVinc := FWFldGet('Z60_VLVINC', nLin)
		SB1->(DbSeek(xFilial('SB1')+cProd))
		lServ := lServ .OR. AllTrim(SB1->B1_TIPO) $ 'SE,MO'

		oModel:GoLine(nLin)

		If Empty(cFilMed)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento da filial de medição.",1,0,,,,,,{"Favor informar o código da filial de medição. (Z60_FILMED)"} )
			Return .F.
		ElseIf Empty(cPlan)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento da planilha da medição.",1,0,,,,,,{"Favor informar o código da planilha da medição. (Z60_PLAN)"} )
			Return .F.
		ElseIf Empty(cProd)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento do produto da medição.",1,0,,,,,,{"Escolha a planilha no campo Z60_PLAN 'Planilha' através da consulta da tecla F3, para preenchimento automático do produto."} )
			Return .F.
		ElseIf Empty(cItem)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento do item da medição.",1,0,,,,,,{"Escolha a planilha no campo Z60_PLAN 'Planilha' através da consulta da tecla F3, para preenchimento automático do produto e item."} )
			Return .F.
		ElseIf Empty(cObs)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento da observação da medição.",1,0,,,,,,{"Favor informar a observação da medição (Z60_OBS)."} )
			Return .F.
		ElseIf Empty(dDtIni)
			Help(" ",1,'CAEA0052',,"Dt Início não pode ser vazio.",1,0,,,,,,{"Digite uma data dentro do período de vigência do contrato."} )
			Return .F.
		ElseIf Empty(dDtFim)
			Help(" ",1,'CAEA0052',,"Dt Fim não pode ser vazio.",1,0,,,,,,{"Digite uma data dentro do período de vigência do contrato."} )
			Return .F.
		ElseIf nValor <= 0 //Verifica se valor está valido
			Help(" ",1,'CAEA0052',,"Insira um valor válido no produto " + cProd + " na linha " + cValtoChar(nLin) + ", valores zerados não são aceitos.",1,0,,,,,,{"Preencher valor do item maior que zero."} )
			Return .F.
		EndIf

		If !Empty(cNumNf) .And. Len(cNumNf) < 9
			oModelZ60:LoadValue('Z60DETAIL','Z60_NUMNF', PadL(cNumNF, 9, '0'))
		EndIf

		//Verifica se existe alguma paralisação no periodo digitado de Dt Inicio e Dt Fim
		If !u_CAEA052k('Z60_DTFIM', '')
			Return .F.
		EndIf

		/*If Posicione('CN9',1,xFilial('CN9')+cContra+cRevisa,'CN9_YPRVIN') > 0 .And. nVlVinc <= 0
			Help(" ",1,'CAEA0052',,"Contrato possui percentual para Conta Vinculada.",1,0,,,,,,{"Preencher valor destinado a conta vinculada. (Vl. Vinculad)"} )
			Return .F.
		EndIf*/

		//Verfica se planilha da linha possui saldo na competencia do cabeçalho
		If CNA->(dbSeek(xFilial('CNA')+cContra+cRevisa+cPlan))
			CNF->(dbSetOrder(2))
			If CNF->(dbSeek(xFilial('CNF')+cContra+cRevisa+CNA->CNA_CRONOG+cCompet))

				For nJ := 1 to nQtd
					//Vai para linha a ser validada
					oModel:GoLine(nJ)
					//Se estiver deletada, ignora
					If oModel:IsDeleted()
						Loop
					EndIf

					cPlanAtu := FWFldGet('Z60_PLAN', nLin)
					If FWFldGet('Z60_PLAN',nJ) == cPlanAtu
						nTotal += FWFldGet('Z60_VALOR', nJ)
						nCont++
					EndIf
				Next
				//Volta para linha que estava validando
				oModel:GoLine(nLin)
				nSldPlan := CNA->CNA_SALDO
				If (nSldPlan-nTotal) < 0 .AND. nCont > 1
					Help(" ",1,'CAEA0052',,"Soma dos itens da planilha selecionada, irá exceder o saldo para esta planilha. Saldo da Planilha: R$ " + alltrim(Transform(nSldPlan, "@E 99,999,999,999.99")),1,0,,,,,,{"Favor, incluir apenas medições que somam o valor máximo da planilha ou faça uma revisão de ajuste de valor da planilha." } )
					Return .F.
				EndIf

				/*If CNF->CNF_SALDO <= 0
					Help(" ",1,'CAEA0052',,"Planilha " + cPlan + " na linha " + cValtoChar(nLin) + " não possui saldo na competência escolhida.",1,0,,,,,,{"Preencher planilha em outro Lote de Medição com outra competência."} )
					//Retira do total da planilha
					nTotal -= FWFldGet('Z60_VALOR',nLin)
					Return .F.
				EndIf*/
			EndIf
		EndIf
		If Empty(cSei)
			Help(" ",1,'CAEA0052',,"É obrigatório o preenchimento do número do SEI para medição.",1,0,,,,,,{"Favor informar o número SEI na grid para cada medição."} )
			Return .F.
		EndIf

		If Left(cProd, 4) $ cProdBM .AND. Empty(cBM)
			Help(" ",1,'CAEA0052',,"Para o produto "+AllTrim(cProd)+" é obrigatório informar o código BM.",1,0,,,,,,{"Favor informar um número BM."} )
			Return .F.
		EndIf
	EndIf

	fCalcTots()
	FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Calcula total do lote
@author  Jerry Junior
@since   27/03/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fCalcTots()
	Local nJ 		:= 1
	Local oModel := FWModelActive()
	Local oModelZ59  := oModel:GetModel('MASTERZ59')
	Local oModelZ60  := oModel:GetModel('Z60DETAIL')
	Local nTOTLOTE := 0
	Local nLinAtu := oModelZ60:GetLine()

	For nJ := 1 to oModelZ60:GetQtdLine()
		//Vai para linha a ser validada
		oModelZ60:GoLine(nJ)
		//Se estiver deletada, ignora
		If oModelZ60:IsDeleted()
			Loop
		EndIf
		nTOTLOTE += FWFldGet('Z60_VALOR', nJ)
	Next

	oModelZ59:LoadValue('Z59_VLLOTE', nTOTLOTE)
	oModelZ60:GoLine(nLinAtu)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052D
Gatilho para preencher automaticamente os campos da tela
@author  Jerry Junior
@since   11/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052D(cCampo)
	Local cQuery 	:= ''
	Local cRet 		:= ''
	Local oModel	:= FWModelActive()


	cQuery := " SELECT * FROM "  + RetSqlTab('CN9')
	cQuery += " WHERE " + RetSqlDel('CN9')
	cQuery += " AND CN9_NUMERO = '" + Alltrim(M->Z59_CONTRA) + "'"
	cQuery += " AND CN9_REVISA = (SELECT MAX(CN9_REVISA) FROM " + RetSqlName('CN9')
	cQuery += "			WHERE D_E_L_E_T_='' AND CN9_NUMERO='" + Alltrim(M->Z59_CONTRA) + "' )"
	cQuery += " AND CN9_SITUAC IN ('05','06')"

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRY'

	If QRY->(!Eof())
		cRet := QRY->&(cCampo)
		//QRY->(dbSkip())
	Else
		Help(" ",1,'CAEA0052',,"Não há revisões em vigência no contrato digitado.",1,0,,,,,,{"Favor verificar dados do contrato."} )
		Return .F.
	EndIf

	//Para que seja permitido lançar medição em contrato paralisado.
	//Será alterado a situação do contrato para que seja preenchido as competências na tela,
	//após preenchimento das competências, situação voltará para vigente.
	If cCampo == 'CN9_NUMERO'
		lParalis := .F.
		If QRY->CN9_SITUAC == '06'
			If !MsgYesNo('Este contrato está em situação de paralisação, deseja realmente continuar com o preenchimento dos dados?')
				Return .F.
			EndIf
			lParalis := .T. //Marca flag, para que seja retornado a situação do contrato para 05
			CN9->(dbSeek(xFilial('CN9')+QRY->CN9_NUMERO+QRY->CN9_REVISA))
			RecLock('CN9', .F.)
			CN9->CN9_SITUAC := '05'
			CN9->(MsUnLock())
		EndIf
		Return .T.
	EndIf

	If cCampo == 'CN9_YCCUST'
		oModel:GetModel('MASTERZ59'):LoadValue("Z59_CC", "")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052E
Consulta padrão, para realizar chamada do PesGen, com filtro desejado.
Pois o filtro da consulta padrão estava demandando muito tempo para mostrar resultados.
Consulta os produtos e planilhas com saldo na competencia escolhida e disponíveis no contrato
@author  Jerry Junior
@since   11/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052E()
	Local lRet := .F.
	Local cFiltro := ''
	Local cContra := Alltrim(FwFldGet('Z59_CONTRA'))
	Local cRevisa := Alltrim(FwFldGet('Z59_REVISA'))
	Local cCompet := alltrim(FwFldGet('Z59_COMPET'))
	Local cQuery := ''
	Local cPlan := ''

	cQuery := " SELECT CNA_NUMERO AS PLANILHA FROM "  + RetSqlName('CNA') + " CNA"

	If !lMedSemCmp
		cQuery += " INNER JOIN "  + RetSqlName('CNF') + " CNF ON CNA_CRONOG=CNF_NUMERO AND CNA_CONTRA=CNF_CONTRA AND CNA_REVISA=CNF_REVISA AND CNA.D_E_L_E_T_=CNF.D_E_L_E_T_"
		cQuery += " WHERE CNA.D_E_L_E_T_ = ''"
		cQuery += " AND CNF_COMPET='" + cCompet + "'"
		cQuery += " AND CNF_SALDO > 0 "
	Else
		cQuery += " WHERE CNA.D_E_L_E_T_ = ''"
	EndIf

	cQuery += " AND CNA.CNA_CONTRA = '" + cContra + "'"
	cQuery += " AND CNA.CNA_REVISA = '" + cRevisa + "'"
	cQuery += " AND CNA.CNA_SALDO  > 0 "//Filtra planilhas com saldo


	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRY'

	While QRY->(!Eof())
		If Empty(cPlan)
			cPlan := QRY->PLANILHA
		Else
			cPlan += ',' + QRY->PLANILHA
		EndIf

		QRY->(dbSkip())
	EndDo
	cFiltro := "Alltrim(CNB->CNB_NUMERO) $ '" + cPlan + "' .AND. "
	cFiltro += "Alltrim(CNB->CNB_CONTRA) == '" + cContra + "' .AND. "
	cFiltro += "Alltrim(CNB->CNB_REVISA) == '" + cRevisa + "' .AND. "

	If !lMedSemCmp
		cFiltro += "CNB->CNB_SLDMED > 0 .AND. "
	EndIf

	cFiltro += "Empty(CNB->CNB_ITMDST)"

	lRet := U_PesqGen('Pesquisa Planilha x Produtos', 'CNB', 1, 'CNB_NUMERO', cFiltro, , , 'CNB_NUMERO,CNB_ITEM,CNB_PRODUT,CNB_DESCRI,CNB_UM,CNB_QUANT,CNB_VLUNIT,CNB_VLTOT,CNB_QTDMED,CNB_SLDMED,CNB_CC')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052F
Validação se filmed/planilha tem acesso a realizar medição no contrato
@author  Jerry Junior
@since   18/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052F(cOpc)
	Local lRet := .T.
	Local cContra 	:= FwFldGet('Z59_CONTRA')
	Local cPlan		:= FwFldGet('Z60_PLAN')
	Local cFilMed	:= FwFldGet('Z60_FILMED')
	Local cFiltro := ''
	Local cMsg := ''
	Default cOpc := ''
	//
	If !IsDigit(Right(cFilMed,1))
		Help(" ",1,'CAEA0052',,"Não pode ser incluído medição para filiais terminadas em letras. (" + cFilMed + ").",1,0,,,,,,{"Por favor, realize a operação com uma filial correta."} )
		Return .F.
	ElseIf !Empty(cOpc)
		CPD->(dbOrderNickName('CONTRAFIL'))
		cFiltro := cContra+cFilMed
		cMsg := "A filial selecionada não esta autorizada a lançar medições neste contrato."
	Else
		CPD->(dbSetOrder(1))
		cFiltro := cContra+cPlan+cFilMed
		cMsg := "A filial selecionada não esta autorizada a lançar medições nesta planilha."
	EndIf

	If !CPD->(dbSeek(xFilial('CPD')+cFiltro)) .AND. !Empty(cPlan)
		Help(" ",1,'CAEA0052',,cMsg,1,0,,,,,,{"Favor verificar autorização com responsável do contrato."} )
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052G
Gatilho apos preenchimento do centro de custo
Seta array com as competencias disponiveis no contrato
Preenche campo Z59_RCCOMP, campo virtual para aparecer o combobox de competencias
@author  Jerry Junior
@since   25/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052G()
	Local oModel		:= FWModelActive()
	Local cContra := FwFldGet('Z59_CONTRA')
	Local cRevisa := FwFldGet('Z59_REVISA')
	Local cCC := alltrim(FwFldGet('Z59_CC'))
	Local oView			:= FWViewActive()
	Local oModelStruct	:= NIL
	Local cRet := cCC //Retorno do gatilho


	if len(aComp)<=0
		aDadosAux := retCompet(cContra,cRevisa)
		aCompSemN := aDadosAux[1]
		aCompets  := aDadosAux[2]
	endif
	CN9->(DbSetOrder(1))

	If Empty(aCompets)
		Help(" ",1,'CAEA0052',,"Contrato sem competências previstas.",1,0,,,,,,{"Favor verificar cronograma financeiro do contrato."} )
		aComp 		:= {}
		aCompets	:= {"",""}
		aCompSemN	:= {"",""}
	Else
		aComp := aClone(aCompets)
		oModelStruct := oModel:GetModel('MASTERZ59'):GetStruct()
		oModelStruct:SetProperty("Z59_RCCOMP", MODEL_FIELD_VALUES,aCompSemN)
		oView:SetFieldProperty("MASTERZ59","Z59_RCCOMP","COMBOVALUES",{aCompets})
		U_CAEA052H(oModel:GetModel('MASTERZ59'),,,)

		//Após preenchimento das competências, situação voltará para vigente, se flag for igual a .T.
		//Reposiciona contrato para alterar situação para Paralisado
		If lParalis
			CN9->(dbSeek(xFilial('CN9')+cContra+cRevisa))
			RecLock('CN9', .F.)
			CN9->CN9_SITUAC := '06'
			CN9->(MsUnLock())
		EndIf
	EndIf
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052H
Gatilho Z59_RCCMP - Seta valor do campo virtual Z59_RCCOMP para campo real Z59_COMPET
@author  Jerry Junior
@since   25/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052H(oModel,cField,cValue,cOldValue)
	Local 	nIndex	:= 0

	If !Empty(aComp)
		nIndex := Val(oModel:GetValue("Z59_RCCOMP"))
		cValue := aComp[IIf(nIndex == 0,1,nIndex)]
		cValue := SubStr(cValue ,At("=",cValue)+1,Len(cValue))
		oModel:LoadValue("Z59_COMPET", cValue)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052I
Função para informar quando for inclusão, aparecer campo Z59_RCCOMP
e ocultar campo Z59_COMPET
@author  Jerry Junior
@since   25/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052I(nOpration)
	Local cModel:= 'CAEA0052'
	Private aComp := {}// atribuição a regra do RM 32850 by Leandro duarte
	Private aCompSemN := {} // atribuição a regra do RM 32850 by Leandro duarte
	Private aCompets := {} // atribuição a regra do RM 32850 by Leandro duarte
	Private lMedSemCmp := .F. // Controle para quando contrato não tiver cronograma financeiro na CNF
	Private lParalis := .F. // Controle para contratos com situação Paralisado

	lInclui := nOpration == 3
	lAltera := nOpration == 4
	FWExecView("Inclusão de Lote de Medição",cModel,nOpration,,{|| .T.})
	lInclui := .F.
	lAltera := .F.
Return


Static Function retCompet(cContra,cRevisa)
	Local nItem := 1
	Local nMes  := 0
	Local nAno  := 0
	Local nMesF := 0
	Local nAnoF := 0
	Local i
	CN9->(DbSetOrder(7))
	CN9->(dbSeek(xFilial('CN9')+cContra+'05'))
	aComp  := CtrCompets()
	cQuery := "SELECT DISTINCT CNF_COMPET, CNF_DTVENC FROM " +RetSQLName("CNF") +" CNF WHERE "
	cQuery += " CNF.D_E_L_E_T_ <> '*'"
	cQuery += " AND CNF.CNF_CONTRA = '" +alltrim(cContra) +"' AND CNF.CNF_REVISA = '" +alltrim(cRevisa) +"' "
	cQuery += " AND CNF_SALDO > 0"
	cQuery += " ORDER BY CNF_DTVENC"

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRY'

	If QRY->(!EoF())
		lMedSemCmp := .F.
		For i:=1 to Len(aComp)
			aAdd(aCompets,cValToChar(i) + "=" + aComp[i])
			aAdd(aCompSemN,cValToChar(i))
		Next
		//While QRY->(!Eof())
		//	If aScan(aCompets, {|x| Right(x,7) == (QRY->CNF_COMPET) }) <= 0
		//		aAdd(aCompets,cValToChar(nItem) + "=" + QRY->CNF_COMPET)
		//		aAdd(aCompSemN,cValToChar(nItem))
		//		nItem++
		//	EndIf
		//	QRY->(dbSkip())
		//EndDo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando o contrato não tiver cronograma CNF seleciona ³
		//³competencias de acordo com a vigencia do mesmo       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Posiciona contrato, para pegar informações da data de vigencia
		lMedSemCmp := .T.
		CN9->(dbSetOrder(7))
		CN9->(dbSeek(xFilial('CN9')+cContra+'05'))
		nMes := Month(CN9->CN9_DTINIC)
		nAno := Year(CN9->CN9_DTINIC)
		nMesF:= Month(CN9->CN9_DTFIM)
		nAnoF:= Year(CN9->CN9_DTFIM)
		While nMes <= nMesF .Or. nAno < nAnoF
			If nMes > 12
				nMes := 1
				nAno++
			EndIf
			//If !lMVCNFCOMP .Or. StrZero(nMes,2) +"/" +Str(nAno,4) < StrZero(Month(dDataBase),2) +"/" +Str(Year(dDataBase),4)
			aAdd(aCompets,cValtoChar(nItem)+"="+StrZero(nMes,2) +"/" +Str(nAno,4))
			aAdd(aCompSemN,cValToChar(nItem))
			nItem++
			//EndIf
			nMes++
		EndDo
	EndIf
Return {aCompSemN,aCompets}

//-------------------------------------------------------------------
/*/{Protheus.doc} retPosCompet
Retorna a posicao que esta a competencia selecionada no combobox
No modelo CNTA121 - CNDMASTER, quando ativado.
@author Jerry Junior
@since   27/02/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function retPosCompet(cCompet,cContra,cRevisa)
	Local cRet := ""
	Local nPos := 1
	Local aCompet := {}
	cQuery := "SELECT DISTINCT CNF_COMPET, CNF_DTVENC FROM " +RetSQLName("CNF") +" CNF WHERE "
	cQuery += " CNF.D_E_L_E_T_ <> '*'"
	cQuery += " AND CNF.CNF_CONTRA = '" +cContra +"' AND CNF.CNF_REVISA = '" +cRevisa +"' "
	cQuery += " AND CNF_SALDO > 0"
	cQuery += " ORDER BY CNF_DTVENC"

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRY'

	If QRY->(!Eof())
		While QRY->(!Eof())
			If aScan(aCompet, {|x| x == (QRY->CNF_COMPET) }) <= 0
				aAdd(aCompet, QRY->CNF_COMPET)
				If QRY->CNF_COMPET == alltrim(cCompet)
					cRet := cValToChar(nPos)
					Exit
				EndIf
				nPos++
			EndIf
			QRY->(dbSkip())
		EndDo
	Else
		//Tratamento para quando não existir cronograma financeiro na CNF para o contrato
		CN9->(dbSetOrder(7))
		CN9->(dbSeek(xFilial('CN9')+Z59->Z59_CONTRA+'05'))
		nMes := Month(CN9->CN9_DTINIC)
		nAno := Year(CN9->CN9_DTINIC)
		nMesF:= Month(CN9->CN9_DTFIM)
		nAnoF:= Year(CN9->CN9_DTFIM)
		While nMes <= nMesF .Or. nAno < nAnoF
			If nMes > 12
				nMes := 1
				nAno++
			EndIf
			If StrZero(nMes,2) +"/" +Str(nAno,4) == alltrim(cCompet)//If !lMVCNFCOMP .Or. StrZero(nMes,2) +"/" +Str(nAno,4) < StrZero(Month(dDataBase),2) +"/" +Str(Year(dDataBase),4)
				cRet := cValToChar(nPos)
				Exit
			EndIf
			nPos++
			nMes++
		EndDo
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} copiarLote
Copia lote de medição sem ser pelo modelo MVC, pois no modelo MVC,
não permite copiar Lote já efetivado.
@author  Jerry Junior
@since   18/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function copiaLote(cNewCompet)
	Local lRet := .T.
	Local cContra, cRevisa, cDescr, cCC, cCodZ59
	Local cFilMed, cPlan, cProdut, cDesc, nValor, cNumSei, cNumBm, cObs
	Local nTotLote := 0
	cCodOld := Z59->Z59_CODIGO
	cContra := Z59->Z59_CONTRA
	cRevisa := Z59->Z59_REVISA
	cCC		:= Z59->Z59_CC
	cDescr	:= Z59->Z59_DESCR

	RecLock('Z59', .T.)
	Z59->Z59_FILIAL := xFilial('Z59')
	cCodZ59 := CriaVar('Z59_CODIGO')
	If Empty(cCodZ59)
		Help("NOCODE",1,'CAEA0052',,"Código não atribuído, problema inicializador padrão.",1,0,,,,,,{"Contate a USAD."} )
		DisarmTransaction()
		Return .F.
	EndIf
	ConfirmSx8()
	Z59->Z59_CODIGO := cCodZ59
	Z59->Z59_DESCR 	:= cDescr
	Z59->Z59_CONTRA := cContra
	Z59->Z59_REVISA := cRevisa
	Z59->Z59_CC 	:= cCC
	Z59->Z59_COMPET := cNewCompet
	Z59->Z59_STATUS := 'A'
	Z59->(MsUnLock())
	Z60->(dbSetOrder(2))
	If Z60->(dbSeek(xFilial('Z60')+cCodOld))
		While Z60->(!Eof())
			If Z60->Z60_CODZ59 == cCodOld
				//Guarda valores do item atual
				cFilMed := Z60->Z60_FILMED
				cPlan 	:= Z60->Z60_PLAN
				cProdut := Z60->Z60_PRODUT
				cItem   := Z60->Z60_ITEM
				cDesc 	:= Z60->Z60_DESC
				nValor 	:= Z60->Z60_VALOR
				nTotLote += Z60->Z60_VALOR
				cNumSei := Z60->Z60_NUMSEI
				cNumBm 	:= Z60->Z60_NUMBM
				cObs 	:= Z60->Z60_OBS
				nRecno  := Z60->(Recno())
				RecLock('Z60', .T.)
				Z60->Z60_FILIAL := xFilial('Z60')
				Z60->Z60_FILMED	:= cFilMed
				Z60->Z60_PLAN	:= cPlan
				Z60->Z60_PRODUT	:= cProdut
				Z60->Z60_ITEM	:= cItem
				Z60->Z60_DESC	:= cDesc
				Z60->Z60_VALOR	:= nValor
				Z60->Z60_NUMSEI	:= cNumSei
				Z60->Z60_NUMBM	:= cNumBm
				Z60->Z60_OBS	:= cObs
				Z60->Z60_CODZ59 := Z59->Z59_CODIGO
				Z60->(MsUnLock())
				//Volta para item anterior a inserção
				Z60->(dbgoto(nRecno))
			EndIf
			Z60->(dbSkip())
		EndDo
		RecLock('Z59', .F.)
		Z59->Z59_VLLOTE := nTotLote
		Z59->(MsUnLock())
	Else
		Help(" ",1,'CAEA0052',,"Não encontrado itens para este lote",1,0,,,,,,{"Favor verificar preenchimento da Z59."} )
		lRet := .F.
		DisarmTransaction()
	EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Impressão de Lote de Medição
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052j()
	Local aAreaCND := CND->(GetArea())
	If Z59->Z59_STATUS <> 'E'
		Help("",1,'CAEA0052',,"Só é permitido imprimir Lote com status 'Efetivado'.",1,0,,,,,,{"Por favor, verifique o status do Lote."} )
		Return
	EndIf
	//Verifica se ha vinculo existente da Z59 com CND
	CND->(dbOrderNickName("CNDYCODZ59"))
	CND->(dbGoTop())
	If !CND->(dbSeek(cSeekCND := xFilial('CND')+Z59->Z59_CODIGO))
		Help("",1,'CAEA0052',,"Lote Cod. " + alltrim(Z59->Z59_CODIGO) + " não está vinculado a nenhuma medição.",1,0,,,,,,{"Por favor, verifique se há medições realizadas sem vínculo (CND_YZ59)."} )
		Return
	EndIf
	RestArea(aAreaCND)
	//Faz chamada da impressão html das medições
	u_CAER073a()
	//FWExecView("Impressão de Lote",cModel,8,,{|| .T.})//"Exclusão de Medição"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Validação da inclusão de data inicio e fim dos itens (Z60)
@author  Jerry Junior
@since   19/11/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052k(cCampo, cAlias)
	Local lRet := .F.
	Local dData
	Local cPeriodo := '' //Texto com periodo de vigência do contrato
	Default cAlias := 'M->'
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial('CN9')+Fwfldget('Z59_CONTRA')+Fwfldget('Z59_REVISA')))
	Posicione("SX3",2,cCampo,"X3_ARQUIVO")

	dData := Iif(cAlias=='',Fwfldget(cCampo), &(cAlias+cCampo))
	cPeriodo := "(Período de vigência: " + DtoC(CN9->CN9_DTINIC) + " à " + DtoC(CN9->CN9_DTFIM) + ")."
	If dData < CN9->CN9_DTINIC
		Help("",1,'CAEA0052',,X3TITULO() + " não pode ser menor que início da vigência do contrato.",1,0,,,,,,{"Insira uma data dentro do período de vigência do contrato. " + cPeriodo } )
	ElseIf dData > CN9->CN9_DTFIM
		Help("",1,'CAEA0052',,X3TITULO() + " não pode ser maior que fim da vigência do contrato.",1,0,,,,,,{"Insira uma data dentro do período de vigência do contrato." + cPeriodo } )
	ElseIf cCampo == 'Z60_DTFIM' .And. dData <= Fwfldget('Z60_DTINIC')
		Help("",1,'CAEA0052',,X3TITULO() + " não pode ser menor que data de início da medição.",1,0,,,,,,{"Insira uma data maior que data de início e dentro do período de vigência do contrato." + cPeriodo } )
	Else
		lRet := .T.
	EndIf

	If lRet
		lRet := u_CAEA052L(CN9->CN9_NUMERO, cCampo, cAlias)
	EndIf

	//M->Z60_DTINIC > CN9->CN9_DTINIC .And. M->Z60_DTINIC < CN9->CN9_DTFIM
	//M->Z60_DTIFIM > CN9->CN9_DTINIC .And. M->Z60_DTFIM < CN9->CN9_DTFIM .And. M->Z60_DTFIM > M->Z60_DTINIC

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Validação adicionada a pedido de Lindberg anexada ao trello n. 1708
Para que seja permitido lançar medição em contrato paralisado.
Validação servirá também para saber se a data digitada de Inicio e Fim da linha da medição
Entá ou possui alguma paralisção entre o período digitado, caso sim, avisa ao usuário e não permite salvar
@author  Jerry Junior
@since   13/12/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052L(cContra, cCampo, cAlias)
	Local lRet := .T.
	Local cQuery := ''
	Local dData, dDataIni
	Local i
	// Tipo de paralisação {
	// 1-Periodo digitado entre periodo paralisado
	// 2-Periodo digitado depois da paralisão, caso não tenha dado reinicio ainda
	// 3-Há algum período paralisado entre a data digitada
	//}
	Local cTipoP := ''
	Default cAlias := 'R' //Se for chamada pela validação do campo da parambox
	Default cContra := Fwfldget('Z59_CONTRA')
	Default cCampo := Iif(readvar()=='MV_PAR01', 'Z60_DTINIC', 'Z60_DTFIM')

	dData 	 := Iif(cAlias=='R', &(readvar()), Iif(Empty(cAlias), Fwfldget(cCampo), &(cAlias+cCampo)) )

	cQuery += " SELECT R_E_C_N_O_ 'RECNOCN9' FROM CN9010 CN9 "
	cQuery += " WHERE CN9.D_E_L_E_T_=''"
	cQuery += " AND CN9_TIPREV IN ('005','006')"
	cQuery += " and CN9_NUMERO='" + cContra + "'"
	cQuery += " ORDER BY CN9_NUMERO, CN9_REVISA, R_E_C_N_O_, CN9_TIPREV"

	If Select('QRYCN9') > 0
		QRYCN9->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRYCN9'

	aAreaCN9 := CN9->(GetArea())
	Posicione("SX3",2,cCampo,"X3_ARQUIVO")
	i := 1
	aParaAux := {}
	aParalis := {}

	While QRYCN9->(!Eof())
		nRecno := QRYCN9->RECNOCN9
		If i == 3 .Or. QRYCN9->(Eof())
			aAdd(aParalis, aParaAux)
			aParaAux := {}
			i := 1
		EndIf
		aAdd(aParaAux, nRecno)
		i++
		QRYCN9->(dbskip())
		If QRYCN9->(Eof())
			aAdd(aParalis, aParaAux)
		EndIf
	EndDo

	For i:=1 to Len(aParalis)
		CN9->(dbGoto(aParalis[i,1]))
		//Data de inclusão da revisão de paralisação
		dDataP := CN9->CN9_DTREV//CtoD(FWLeUserlg("CN9_USERGI", 2))
		dDataFimP := CN9->CN9_DTFIMP
		dDataR := Ctod('//')
		If Len(aParalis[i]) > 1 //Se registro setado possui revisao de reinicio, verificara De/Até da paralisação
			CN9->(dbGoto(aParalis[i,2]))
			//Data de inclusão da revisão de reinicio
			dDataR := DaySub(CN9->CN9_DTREIN, 1)//CtoD(FWLeUserlg("CN9_USERGI", 2))
			If dData >= dDataP .And. dData <= dDataR //Está dentro de algum periodo de/até paralisado
				lRet := .F.
				cTipoP := '1'
				Exit
			EndIf
		ElseIf dData >= dDataP //Esta no periodo posterior da paralisação
			lRet := .F.
			cTipoP := '2'
			Exit
		EndIf

		If cCampo == 'Z60_DTFIM'
			dDataIni := Iif(cAlias=='Z60->', Z60->Z60_DTINIC, Iif(cAlias=='R', MV_PAR01, Fwfldget('Z60_DTINIC')))
			If dDataP >= dDataIni .And. dDataP <= dData //Dt paralisação entre a data de inicio e fim digitado
				lRet := .F.
				cTipoP := '3'
				Exit
			EndIf
		EndIf

	Next

	If !lRet
		If cTipoP == '1'
			Help("",1,'CAEA0052',,X3TITULO() + " não pode estar dentro do período de paralisação.",1,0,,,,,,{"Insira uma data que não esteja dentro do período da paralisação. (Período paralisado: " + DtoC(dDataP) + " à " + DtoC(dDataR) + ")."} )
		ElseIf cTipoP == '2'
			Help("",1,'CAEA0052',,X3TITULO() + " não pode estar dentro do período de paralisação. Contrato atualmente paralisado.",1,0,,,,,,{"Insira uma data que não esteja dentro do período da paralisação. (Período paralisado: " + DtoC(dDataP) + " até " + DtoC(dDataFimP) + ")."} )
		Else
			Help("",1,'CAEA0052',,"Existe algum período de paralisção entre a Dt Inicio e Dt Fim digitado.",1,0,,,,,,{"Insira uma data fora do período da paralisação. (Período paralisado: " + DtoC(dDataP) + " até " + DtoC(Iif( Empty(dDataR), dDataFimP, dDataR)) + ")."} )
		EndIf
	EndIf
	RestArea(aAreaCN9)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Ponto de Entrada MVC
@author  Jerry Junior
@since   22/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA052()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.

	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )

		//Adicionar botão em 'Outras Ações' quando operação for 4 - Alteração
		If cIdPonto == 'BUTTONBAR'
			aButon := { {'Aplicar/Replicar Dados', 'Aplicar/Replicar Dados', { || replicarDados()  }, 'Aplicar/Replicar Dados das Medições.' } }
			If ALTERA
				aAdd(aButon, {'Alterar Competência', 'Alterar Competência', { || alteraCompet()  }, 'Altera competência do lote.' } )
			EndIf

			xRet := aButon
		EndIf
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Altera competência da tela com novo valor escolhido na parambox
@author  Jerry Junior
@since   22/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function alteraCompet()
	Local oModel	 := FWModelActive()
	Local cContra    := Z59->Z59_CONTRA
	Local cRevisa	 := Z59->Z59_REVISA
	Local cCompet 	 := ''
	Local aRet 		 := pergCompet(cContra,cRevisa)

	If aRet[1]
		cCompet := aRet[2]
		oModel:GetModel('MASTERZ59'):LoadValue("Z59_COMPET", cCompet)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Replicar DadoComplementares na grid de Medições
@author  Jerry Junior
@since   19/12/2019
@version 1.0
@type function
@Redmine 18164
/*/
//-------------------------------------------------------------------
Static Function replicarDados()
	Local oModel	 := FWModelActive()
	Local aPergs := {}
	Local aRet   := {}
	Local oModelZ60 := oModel:GetModel('Z60DETAIL')
	Local dDataI := Iif(Type('dDtIni52')<>'U', dDtIni52, Ctod("//"))
	Local dDataF := Iif(Type('dDtIni52')<>'U', dDtFim52, Ctod("//"))
	Local cNumSei	:= Space(30)
	Local cObs	:= Space(254)
	Local nValor	:= 0
	Local cPlanilha	:= Space(6)
	Local cProduto	:= Space(15)
	Local cItem		:= Space(3)
	Local cDescric	:= Space(120)
	Local cLog := ''
	Local cLinha := ''
	Local i
	Private cNewCompet := ''
	//If oModelZ60:GetQtdLine() < 2
	//	Help("",1,'CAEA0052',,"Insira pelo menos 2 linhas de medições na grid.",1,0,,,,,,{"Operação só pode ser executada com número mínimo de linhas na grid. (Min. 2 linhas)"} )
	//	Return .F.
	//EndIf

	aAdd(aPergs, {1,"Data Início",dDataI,"","U_CAEA052L() .And. NaoVazio()",,".T.",50,.T.})
	aAdd(aPergs, {1,"Data Fim",dDataF,"","U_CAEA052L() .And. NaoVazio()",,".T.",50,.T.})
	aAdd(aPergs, {1,"Número SEI",cNumSei,"","IIF(Vazio(), , U_CAEF0066(.T.))",,".T.",50,.F.})
	aAdd(aPergs, {1,"Observação",cObs,"","",,".T.",50,.F.})
	aAdd(aPergs, {1,"Valor",nValor,"@E 999,999,999.99","Positivo()",,".T.",50,.F.})
	aAdd(aPergs, {1,"Planilha",cPlanilha,"","","Z60PLA",".T.",50,.F.})
	aAdd(aPergs, {1,"Produto",cProduto,"","",,".F.",50,.F.})
	aAdd(aPergs, {1,"Item",cItem,"","",,".F.",50,.F.})
	aAdd(aPergs, {1,"Descrição",cDescric,"","",,".F.",50,.F.})
	If ParamBox(aPergs, "Dados para as medições:", aRet, {|| vldParam()})
		dDtIni52 	:= aRet[1]
		dDtFim52 	:= aRet[2]
		dDataI		:= aRet[1]
		dDataF		:= aRet[2]
		cNumSei		:= aRet[3]
		cObs		:= aRet[4]
		nValor		:= aRet[5]
		cPlanilha	:= aRet[6]
		cProduto	:= aRet[7]
		cItem		:= aRet[8]
		cDescric	:= aRet[9]

		For i:=1 to oModelZ60:GetQtdLine()
			oModelZ60:GoLine(i)
			oModelZ60:LoadValue('Z60_DTINIC', dDtIni52)
			oModelZ60:LoadValue('Z60_DTFIM' , dDtFim52)
			cPlanAtu := Fwfldget('Z60_PLAN')
			If !Empty(cNumSei)
				oModelZ60:LoadValue('Z60_NUMSEI', cNumSei)
			EndIf

			If !Empty(cObs)
				oModelZ60:LoadValue('Z60_OBS', cObs)
			EndIf

			If nValor > 0
				oModelZ60:LoadValue('Z60_VALOR', nValor)
			EndIf

			If !Empty(cPlanilha) .And. oModelZ60:SetValue('Z60_PLAN', cPlanilha)
				oModelZ60:LoadValue('Z60_PRODUT', cProduto)
				oModelZ60:LoadValue('Z60_ITEM', cItem)
				oModelZ60:LoadValue('Z60_DESC', cDescric)
			Else
				aLog := oModel:GetErrorMessage()
				cLog += Iif(Empty(cLog), aLog[6], '')
				cLinha += cvaltochar(i) + Iif(i == oModelZ60:GetQtdLine(), '', ', ')
				oModelZ60:LoadValue('Z60_PLAN', cPlanAtu)
			EndIf
		Next
		oModelZ60:GoLine(1)
	EndIf

	If !Empty(cLog)
		Help("",1,'VLDACESSPLAN',,cLog + ' nas linhas ' + cLinha,1,0,,,,,,{"Insira manualmente ou replique uma planilha que tenha acesso as filiais já preenchidas."} )
	EndIf
Return .T.

Static Function vldParam()
	Local lRet := .T.

	If !Empty(MV_PAR06) .And. Empty(MV_PAR07)
		lRet := .F.
		MsgAlert("Produto em branco. Favor preencher o campo de produto através de rotina de busca ou tecla de atalho 'F3' no campo.")
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Abre parambox para escolher nova competência do Lote
@author  Jerry Junior
@since   22/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function pergCompet(cContra,cRevisa)
	Local aPergs := {}
	Local aRet   := {}
	Local aComp  := {}
	Local lRet 	 := .F.
	Private cNewCompet := ''
	aComp := retCompet(cContra,cRevisa)
	aAdd(aPergs, {2,"Competência",aComp[2][1],aComp[2],50 ,'.T.',.T.})
	If ParamBox(aPergs ,"Escolha a competência do Lote:",aRet,,,,,,,.F.,.F.)
		cNewCompet := substr(acomp[2][val(aRet[1])],at('=',acomp[2][val(aret[1])])+1)
		lRet := .T.
	EndIf
Return {lRet,cNewCompet}


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Conta registros da Z60 vinculados a uma Z59 para contagem no oProcess
@author  Jerry Junior
@since   25/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function contRegistros(cCodZ59)
	Local nCount := 0
	cQuery := " SELECT count(Z60_CODZ59) as QTD FROM "  + RetSqlTab('Z60')
	cQuery += " WHERE " + RetSqlDel('Z60')
	cQuery += " AND Z60_CODZ59 = '" + alltrim(cCodZ59) + "'"

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf

	TcQuery cQuery New Alias 'QRY'
	If QRY->(!Eof())
		nCount := QRY->QTD
	EndIf

Return nCount

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0052
Geração de NFs em caso de não geração automática na efetivação do LOTE
@author  Jerry Junior
@since   19/11/2021
@version 1.0
@type function
@Redmine 24726
/*/
//-------------------------------------------------------------------
User Function CAEA052m()
	Local lCtrAutoNF := Alltrim(Z59->Z59_CONTRA) $ u_getParam('REGRAESPEC', .T., "20.00470,20.00469;NFS#20.01807;RECIB#20.00493;NFSC")

	If Z59->Z59_STATUS <> "E"
		Alert("Você não pode realizar essa operação. Somente Lote Efetivado")
		Return
	EndIf

	If lCtrAutoNF
		nCont := contRegistros(Z59->Z59_CODIGO)
		oProcess := MsNewProcess():New( { || lRet := incluiSF1() }, "Gerando Notas Pendentes", "Aguarde, Gerando NFs...", .F. )
		oProcess:Activate()
	Else
		Alert("Contrato não está parametrizado para esta operação.")
		Return
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052N
Rotina para efetuar analise completa das medições e de suas notas fiscais
TRATAMENTO DO RM 32680
@author  Leandro Duarte
@since   01/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function CAEA052N(cTipo)
	Local CRet 		:= ""
	Local cTRBGY	:= "TRBSXW"
	Local cCod		:= Z59->Z59_CODIGO
	Local nQtdE		:= 0
	Local nQtdA		:= 0
	Local nQtdB		:= 0
	Local nQtdC		:= 0
	Local nQtdD		:= 0

	/// analisa se possui numero de itens
	iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
	beginsql alias cTRBGY
		SELECT
			COUNT(*) AS QTD
		FROM
			%TABLE:Z59% A,%TABLE:Z60% B
		WHERE
			A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
			AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
			AND A.%NOTDEL%
			AND B.%NOTDEL%
			AND A.Z59_CODIGO = %EXP:cCod%
			AND A.Z59_CODIGO = B.Z60_CODZ59
	EndSql
	DBSELECTAREA(cTRBGY)
	IF (cTRBGY)->(!EOF())
		nQtdE		:= (cTRBGY)->QTD
	ENDIF

	/// analisa se possui numero de medição dos itens
	iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
	beginsql alias cTRBGY
		SELECT
			COUNT(*) AS QTD
		FROM
			%TABLE:Z59% A,%TABLE:Z60% B
		WHERE
			A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
			AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
			AND A.%NOTDEL%
			AND B.%NOTDEL%
			AND A.Z59_CODIGO = %EXP:cCod%
			AND A.Z59_CODIGO = B.Z60_CODZ59
			AND B.Z60_NUMMED = '      '
	EndSql
	DBSELECTAREA(cTRBGY)
	IF (cTRBGY)->(!EOF())
		nQtdA		:= (cTRBGY)->QTD
	ENDIF

	// analisa se possui medição informada
	iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
	beginsql alias cTRBGY
		SELECT
			COUNT(*) AS QTD
		FROM
			%TABLE:Z59% A,%TABLE:Z60% B
		WHERE
			A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
			AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
			AND A.%NOTDEL%
			AND B.%NOTDEL%
			AND A.Z59_CODIGO = %EXP:cCod%
			AND A.Z59_CODIGO = B.Z60_CODZ59
			AND B.Z60_NUMMED <> '      '
	EndSql
	DBSELECTAREA(cTRBGY)
	IF (cTRBGY)->(!EOF())
		nQtdB		:= (cTRBGY)->QTD
	ENDIF

	// analisa se possui cadastro na medição
	iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
	beginsql alias cTRBGY
		SELECT
			COUNT(*) AS QTD
		FROM
			%TABLE:Z59% A,%TABLE:Z60% B,%TABLE:CND% C
		WHERE
			A.Z59_CODIGO = B.Z60_CODZ59
			AND A.%NOTDEL%
			AND B.%NOTDEL%
			AND C.%NOTDEL%
			AND A.Z59_CODIGO = %EXP:cCod%
			AND A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
			AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
			AND A.Z59_CONTRA = C.CND_CONTRA
			AND A.Z59_REVISA = C.CND_REVISA
			AND C.CND_FILMED = B.Z60_FILMED
			AND C.CND_YZ59 = A.Z59_CODIGO
			AND C.CND_NUMMED = B.Z60_NUMMED
	EndSql
	DBSELECTAREA(cTRBGY)
	IF (cTRBGY)->(!EOF())
		nQtdC		:= (cTRBGY)->QTD
	ENDIF

	// analisa se possui Nota Fiscal
	iif(select(cTRBGY)>0,(cTRBGY)->(dbclosearea()),nil)
	beginsql alias cTRBGY
		SELECT
			COUNT(*) AS QTD
		FROM
			%TABLE:Z59% A,%TABLE:Z60% B,%TABLE:CND% C,%TABLE:SF1% D
		WHERE
			A.Z59_CODIGO = B.Z60_CODZ59
			AND A.%NOTDEL%
			AND B.%NOTDEL%
			AND C.%NOTDEL%
			AND D.%NOTDEL%
			AND A.Z59_CODIGO = %EXP:cCod%
			AND A.Z59_FILIAL = %EXP:FWXFILIAL("Z59")%
			AND B.Z60_FILIAL = %EXP:FWXFILIAL("Z60")%
			AND A.Z59_CONTRA = C.CND_CONTRA
			AND A.Z59_REVISA = C.CND_REVISA
			AND C.CND_FILMED = B.Z60_FILMED
			AND C.CND_YZ59 = A.Z59_CODIGO
			AND C.CND_NUMMED = B.Z60_NUMMED
			AND C.CND_FILMED = D.F1_FILIAL
			AND C.CND_YNUMNF = D.F1_DOC
			AND A.Z59_CONTRA = D.F1_YCONTRA
			AND A.Z59_REVISA = D.F1_YREVISA
	EndSql
	DBSELECTAREA(cTRBGY)
	IF (cTRBGY)->(!EOF())
		nQtdD		:= (cTRBGY)->QTD
	ENDIF

	if  ((nQtdA == nQtdE .AND. nQtdA >= 0) .and. (nQtdb == 0 .and. nQtdc == 0 .and. nQtdd == 0))
		cRet	:= "A" 
	ELSEIF ((nQtdA == 0 .and. nQtdb == nQtdc) .and. (nQtdC == nQtdD .AND. nQtdE == nQtdD))
		cRet	:= "E" 
	ELSE
		//lRet := (nQtdA != nQtdE) .OR. !(nQtdb >= 0 .and. nQtdc >= 0 .and. nQtdd != nQtdc)
		cRet	:= "P"
	ENDIF
Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052O
Rotina para saber se existe a medição informada pela parametro
TRATAMENTO DO RM 32680
@author  Leandro Duarte
@since   01/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CAEA052O(cFilMed,cNumed)
	Local aAreaCND 	:= CND->(GETAREA())
	Local cRet	:= ""

	CND->(DbSetOrder(4))
	IF CND->(dbSeek(xfilial("CND")+cNumed)) .AND. CND->CND_MSFIL == cFilMed
		IF ALLTRIM(CND->CND_SITUAC) == 'A' .OR. ALLTRIM(CND->CND_SITUAC) == 'SA'
			cRet	:= "A"
		endif
	Else
		cRet	:= "I"
	ENDIF
	Restarea(aAreaCND)
Return cRet
