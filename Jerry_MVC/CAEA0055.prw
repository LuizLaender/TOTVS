#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'TbIconn.ch'

#DEFINE OPERATION_INSERT 3
#DEFINE OPERATION_UPDATE 4
#DEFINE OPERATION_DELETE 5

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Cadastro de Agendamento de Recebimento
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA0055()
    Local oBrowse
    Private cString := 'Z62'
    Private aHora := {}
	Private lInclui := .F.
	Private aLegenda := {}
    u_GeraLogPrw(, 'CAEA0055', 'CAEA0055')
    //Montagem do Browse principal
    oBrowse := FWMBrowse():New()

    //Legenda
    oBrowse:AddLegend('Z62_STATUS ==  "R" ' , 'BR_VERDE'    , 'Recebido'    )
    oBrowse:AddLegend('Z62_STATUS ==  "A" ' , 'BR_AZUL'     , 'Agendado'    )
    oBrowse:AddLegend('Z62_STATUS ==  "P" ' , 'BR_AMARELO'  , 'Pendente'    )
    oBrowse:AddLegend('Z62_STATUS ==  "C" ' , 'BR_CANCEL'   , 'Cancelado'   )

	aAdd(aLegenda,{'BR_VERDE'    , 'Recebido'})
	aAdd(aLegenda,{'BR_AZUL'     , 'Agendado'})
	aAdd(aLegenda,{'BR_AMARELO'  , 'Pendente'})
	aAdd(aLegenda,{'BR_CANCEL'   , 'Cancelado'})

	
    //Define alias principal
    oBrowse:SetAlias('Z62')
    oBrowse:SetDescription('Agendamento de Recebimento do Parque')
    oBrowse:SetMenuDef('CAEA0055')

    //Ativa a tela
    oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o menu principal
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
@return array, Array com os dados para os botoes do browse
/*/
//-------------------------------------------------------------------
Static Function MenuDef
    Local aRotina := {}

    //Opcoes do Menu    
    aAdd( aRotina, { 'Incluir'    		, 'u_CAEA055i(3)'   , 0, 3, 0, NIL } )
    aAdd( aRotina, { 'Alterar'    		, 'VIEWDEF.CAEA0055', 0, 4, 0, NIL } )	
	aAdd( aRotina, { 'Visualizar'    	, 'VIEWDEF.CAEA0055', 0, 2, 0, NIL } )
    aAdd( aRotina, { 'Alterar Status'	, 'u_CAEA055n()'	, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Abrir Calendário' , 'u_CAEA054I()'	, 0, 3, 0, NIL } )	
	aAdd( aRotina, { 'Enviar E-mail' 	, 'u_CAEA055S()'	, 0, 3, 0, NIL } )
    aAdd( aRotina, { 'Excluir'    		, 'VIEWDEF.CAEA0055', 0, 5, 0, NIL } )	
    aAdd( aRotina, { 'Legenda'    		, 'u_CAEA055f()', 0, 5, 0, NIL } )	
    aAdd( aRotina, { 'Alterar Aviso Portal' , 'u_CAEA055V()', 0, 4, 0, NIL } )	
    //Exemplo de filtro para exibir a tela
    //DbSelectArea('Z62')
    //SET FILTER TO Z62->Z62_COD == 999
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Construcao do modelo de dados
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
@return object, Retorna o objeto do modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStruZ62 := FWFormStruct(1,'Z62')
	Local oStruZ67 := FWFormStruct(1,'Z67')
    //Gatilhos
	oStruZ62:AddTrigger('Z62_CONTRA', 'Z62_CONTRA', {||.T.},{||U_CAEA055O()})    
	//oStruZ59:AddTrigger('Z62_FORNEC', 'Z62_LOJA', {||.T.},{||U_CAEA052G()})
    //oStruZ59:AddTrigger('Z59_CC', 'Z59_CC', {||.T.},{||U_CAEA052G()})
	
	//Adiciona campo virtual, para mostrar competencias em combobox
	If alltrim(Z62->Z62_ORIGEM) == 'PORTAL' .And. !INCLUI
		oStruZ62:AddField("Notas"				,;	// 	[01]  C   Titulo do campo
					 "Notas e Valores"		,;	// 	[02]  C   ToolTip do campo
					 "Z62_NOTAS"					,;	// 	[03]  C   Id do Field
					 "M"							,;	// 	[04]  C   Tipo do campo
					 84								,;	// 	[05]  N   Tamanho do campo
					 0								,;	// 	[06]  N   Decimal do campo
					 {||.T.}	,;	// 	[07]  B   Code-block de validação do campo
					 NIL							,;	// 	[08]  B   Code-block de validação When do campo
					 {"",""}						,;	//	[09]  A   Lista de valores permitido do campo
					 .F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|a| U_CAEA055U(oModel) }							,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
					 .F.							,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.							)	// 	[14]  L   Indica se o campo é virtual				
	EndIf

    //Cria o formulario do modelo  - GravaDados: { |oModel| fGrvDados( oModel ) }
    oModel := MPFormModel():New('CAEA055', /*bPreValidacao*/, { |oModel| fTudoOk(oModel) }, /* GravaDados */, /*bCancel*/ )

    //Cria a estrutura principal(Z62)
	oModel:addFields('MASTERZ62',,oStruZ62)

	//Adiciona a chave
	oModel:SetPrimaryKey({'Z62_FILIAL', 'Z62_CODIGO'})

	//bPreValidacao: Antes de entrar no campo para inserir dados
	//Cria estrutura de grid para os itens
	oModel:AddGrid('Z67DETAIL','MASTERZ62',oStruZ67, /*bPreValidacao*/, { |oModel| fLinOk(oModel) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	//Define a relacao entre as tabelas
	oModel:SetRelation('Z67DETAIL',{{'Z67_FILIAL','xFilial("Z67")'},{'Z67_CODZ62','Z62_CODIGO'}},Z67->(IndexKey(1)))


	//Define a descricao dos modelos
	oModel:GetModel('MASTERZ62'):SetDescription('Agendamento de Recebimento')
	oModel:GetModel('Z67DETAIL'):SetDescription('Itens Contrato')

	//Define que o preenchimento da grid e' opcional
	oModel:GetModel('Z67DETAIL'):SetOptional(.T.)
	//Bloqueia o modelo para inserção e exclusao de linha
	//oModel:GetModel('Z67DETAIL'):SetNoInsertLine(.T.)
	//oModel:GetModel('Z67DETAIL'):SetNoDeleteLine(.T.)

	//Define que a linha nao podera ter o conteudo repetido
	//oModel:GetModel('Z67DETAIL'):SetUniqueLine({'Z67_FILIAL','Z67_PRODUT','Z67_VLUNIT'})

	//AntesDeTudo
	oModel:SetVldActivate( {|oModel| fAntesTd(oModel) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta o view do modelo
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef
    Local oView
    Local oModel := ModelDef()
    Local oStrZ62 := FWFormStruct(2, 'Z62')
	Local oStrZ67 := FWFormStruct(2, 'Z67')
	Private lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')
    
	//Adiciona campo virtual, para mostrar competencias em combobox
	If alltrim(Z62->Z62_ORIGEM) == 'PORTAL' .And. !INCLUI
		oStrZ62:AddField("Z62_NOTAS"	,;	// [01]  C   Nome do Campo
					"11"			,;	// [02]  C   Ordem
					"Notas"	,;	// [03]  C   Titulo do campo
					"Notas e Valores"	,;	// [04]  C   Descricao do campo
					NIL				,;	// [05]  A   Array com Help
					"M"				,;	// [06]  C   Tipo do campo
					"@!"			,;	// [07]  C   Picture
					NIL				,;	// [08]  B   Bloco de Picture Var
					NIL				,;	// [09]  C   Consulta F3
					.F.				,;	// [10]  L   Indica se o campo é alteravel
					NIL				,;	// [11]  C   Pasta do campo
					NIL				,;	// [12]  C   Agrupamento do campo
					NIL				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL				,;	// [15]  C   Inicializador de Browse
					.T.				,;	// [16]  L   Indica se o campo é virtual
					NIL				,;	// [17]  C   Picture Variavel
					NIL				)	// [18]  L   Indica pulo de linha após o campo
		//oStrZ62:RemoveField("Z62_NOTA")	
	EndIf
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField('FORM_Z62' , oStrZ62,'MASTERZ62' )

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid('GRID_Z67', oStrZ67, 'Z67DETAIL' )	


	// 30% cabec e 70% para as abas
	oView:CreateHorizontalBox('SUPERIOR', 30)
	oView:CreateHorizontalBox('INFERIOR', 70 )

	// Cria Folder na View
	oView:CreateFolder('PASTA_INFERIOR' ,'INFERIOR' )

	// Crias as pastas (abas)
	oView:AddSheet('PASTA_INFERIOR'    , 'ABA_Z67'  , 'Itens Contrato' )	

	// Criar 'box' horizontal com 100% dentro das Abas
	oView:CreateHorizontalBox('ITENS'    ,100,,, 'PASTA_INFERIOR', 'ABA_Z67' )	

	// Relaciona o ID da View com o 'box' para exibicao
	oView:SetOwnerView('FORM_Z62', 'SUPERIOR')
	oView:SetOwnerView('GRID_Z67', 'ITENS'   )

    //Se for inclusão, esconde campo Z62_HORA da view	
	If INCLUI
		oStrZ62:RemoveField("Z62_HORA")					
	ElseIf !ALTERA
		oStrZ62:RemoveField("Z62_RCHORA")
	EndIf

	//oView:SetViewProperty("Z67DETAIL", "GRIDFILTER", {.T.})		

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fAntesTd
(PE AntesDeTudo) Função para a abertura da tela.
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fAntesTd(oModel)
    Local nOperation := oModel:GetOperation()
    Local lAltera    := nOperation == OPERATION_UPDATE
	Local lDelete    := nOperation == OPERATION_DELETE
	Local lRet := .T.
	
	Private lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')

	aHora := {}

	If Z62->Z62_STATUS == 'R' .And. (lAltera .Or. lDelete)
		lRet := .F.
		Help(" ",1,'CAEA0055',,Iif(lAltera,"Alteração","Exclusão") + " não permitida para agendamento com status 'Recebido'.",1,0,,,,,,{""} )
	ElseIf !lUsrAltera .And. lAltera .And. DateDiffDay(Z62->Z62_DATA,dDataBase) < 2
		lRet := .F.
		Help(" ",1,'CAEA0055',,"Alteração não permitida para agendamentos com data inferior a 2 dias úteis da data atual.",1,0,,,,,,{""} )			
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
(PE TudoOk) Validacao da tela.
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fTudoOk(oModel)
    Local lRet       := .T.    
    Local aSaveLines := FWSaveRows()
    Local nOperation := oModel:GetOperation()	
	Local dData      := oModel:Getmodel('MASTERZ62'):Getvalue('Z62_DATA')
	Local dAux 		 := CtoD('//')
	Local nX := 0
	Local oModelZ67 := oModel:Getmodel('Z67DETAIL')
	Local nQtdLine	 := oModelZ67:GetQTDLine()
	Local cHora := FwFldGet('Z62_HORA')
	Local cLocal := FwFldGet('Z62_LOCAL')
	Local cFone := FwFldGet('Z62_FONE')
	Local cContato := FwFldGet('Z62_CONTAT')
	Local cEmail := FwFldGet('Z62_EMAIL')
	Local i := 0
	Private lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')
	dAux := contaDisp(dData)

	If nOperation == OPERATION_DELETE
		Return .T.
	EndIf

	If FwFldGet('Z62_STATUS') == 'R' .And. Z62->Z62_DATA > dDataBase
		Help(" ",1,'CAEA0055',,"Você não pode alterar para status 'Recebido' agendamento com data superior a data atual.",1,0,,,,,,{""} )
		Return .F.
	EndIf
	//Verifica se já existe 2 agendamentos marcados na data e hora escolhida
	If !u_CAEA055P(cHora,cLocal)
		Return .F.
	EndIf

	Z61->(dbSetOrder(2))
    Z61->(lAchou := dbSeek(xFilial('Z61')+DtoS(dData)))	

	If dData < dDataBase
		Help(" ",1,'CAEA0055',,"Data inferior a data atual.",1,0,,,,,,{""} )    
		lRet := .F.
	ElseIf !lUsrAltera .And. dData <= dAux .And. (dData - dDataBase) < 2
		Help(" ",1,'CAEA0055',,"Só é permitido reagendar recebimento após dois dias úteis da data atual baseado no calendário de disponibilidade.",1,0,,,,,,{"Tente partir de " + DtoC(dAux)} )
		lRet := .F.
	ElseIf !lAchou
		Help(" ",1,'CAEA0055',,"Data sem horário disponível.",1,0,,,,,,{"Favor verificar disponibilidade de horários."} )
		lRet := .F.
	ElseIf Z61->Z61_STATUS == "N"
		Help(" ",1,'CAEA0055',,"Data indiponível conforme calendário de disponibilidade.",1,0,,,,,,{"Favor verificar calendário de disponibilidade (CAEA0054)."} )	
		lRet := .F.
	EndIf	
	//Validação local de entrega
	If !u_CAEA055J(.T.)		
		lRet := .F.
	EndIf
	//Validação do contrato
	If !u_CAEA055K('1')
		lRet := .F.
	EndIf

	For nX:=1 to nQtdLine
		
		oModelZ67:GoLine(nX)

		If oModelZ67:IsDeleted()
			Loop
		EndIf
		//Chama linhaOk
		If !fLinok(oModelZ67, nX, .T.)
			Return .F.
		EndIf	
	Next
	//Validacao campo fone e contato
	If !Empty(cFone) .And. Empty(cContato)
		Help(" ",1,'CAEA0055',,"Campo contato em branco.",1,0,,,,,,{"Preencha o nome do contato"} )	
		lRet := .F.
	ElseIf Empty(cFone) .And. !Empty(cContato)
		Help(" ",1,'CAEA0055',,"Campo fone em branco.",1,0,,,,,,{"Preencha o número de telefone."} )		
		lRet := .F.
	EndIf
	
	//Validação do campo email
	If !Empty(cEmail)
		aEmail := Strtokarr2( alltrim(cEmail), ';', .F.)
		cEmail := ''
		For i:=1 to Len(aEmail)
			If IsEmail(aEmail[i])
				cEmail += aEmail[i]
				cEmail += Iif(i < Len(aEmail),';','')
			Else
				Help(" ",1,'CAEA0055',,"Campo e-mail com formato inválido.",1,0,,,,,,{"Digite corretamente o e-mail e utilize o separador ';'"} )
				Return .F.				
			EndIf
		Next
		//oModel:Getmodel('MASTERZ62'):LoadValue("Z62_EMAIL", cEmail)		
	EndIf
	
	FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fLinOk
(PE LinOk) Validacao da linha da primeira grid.
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fLinOk(oModelZ67, nLin, lTOK)
    Local lRet       := .T.
    Local aSaveLines := FWSaveRows()     
	Local cProd 	 := ''
    Default nLin     := oModelZ67:nLine
	Default lTOK := .F.
	//Libera o modelo para inserção e exclusao de linha
	//oModelZ67:SetNoInsertLine(.F.)	
	//oModelZ67:SetNoDeleteLine(.F.)
    // Sai da validacao se a linha estiver deletada
    If oModelZ67:IsDeleted()
        Return .T.
    EndIf

    If nLin > 0
        oModelZ67:GoLine(nLin)
		cProd := alltrim(oModelZ67:GetValue('Z67_PRODUT',nLin))
		If (Empty(cProd) .Or. oModelZ67:GetValue('Z67_QTDENT',nLin) <= 0) .And. lTOK //Se for no TudoOk			
			oModelZ67:DeleteLine()
		ElseIf oModelZ67:GetValue('Z67_QTDENT',nLin) > oModelZ67:GetValue('Z67_SALDO',nLin)
			Help(" ",1,'CAEA0055',,"Valor da quantidade a ser entregue é maior que saldo a ser medido.",1,0,,,,,,{"Verificar Saldo"} )
			lRet := .F.
		EndIf
		
		If vldProduto(cProd) .And. lTOK .And. !Empty(cProd)
			Help(" ",1,'CAEA0055',,"Produto " + cProd + " não está vinculado ao contrato digitado.",1,0,,,,,,{"Mantenha a linha deletada."} )
			oModelZ67:DeleteLine()//Deleta produto da grid
			lRet := .F.
		ElseIf !Empty(cProd) .And. oModelZ67:GetValue('Z67_QTDENT',nLin) > 0 .And. lTOK .And. vldProduto(cProd, lTOK, oModelZ67:GetValue('Z67_QTDENT',nLin))
			Help(" ",1,'CAEA0055',,"Qtd. Entrega do Produto " + cProd + " está maior que o saldo disponível.",1,0,,,,,,{"Insira a quantidade no máximo de [" + cvaltochar(QRY->CNB_SLDMED) + "]."} )
			oModelZ67:DeleteLine()//Deleta produto da grid
			lRet := .F.
		EndIf
    EndIf   
	//Bloqueia o modelo para inserção e exclusao de linha
	//oModelZ67:SetNoInsertLine(.T.)	
	//oModelZ67:SetNoDeleteLine(.T.)
	//oView:Refresh()
	
    FWRestRows(aSaveLines)
Return lRet

User Function CAEA055F()
	BrwLegenda("Agendamento de Recebimento","Legenda",aLegenda)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055I
Função para informar quando for inclusão, aparecer campo Z62_RCHORA
e ocultar campo Z62_HORA
@author  Jerry Junior
@since   20/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055i()
	Local cModel:= 'CAEA0055'
	lInclui := .T.
	aHora	:= {}
	FWExecView('Inclusão de Agendamento',cModel,OPERATION_INSERT,,{|| .T.})
	lInclui := .F.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055G
Gatilho apos preenchimento Z62_DATA
Seta array com os horarios disponiveis conforme calendário de disponibilidade
Preenche campo Z62_RCHORA, campo virtual para aparecer o combobox de horarios
@author  Jerry Junior
@since   20/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055G()
	Local oModel		:= FWModelActive()
	Local dData         := oModel:Getmodel('MASTERZ62'):Getvalue('Z62_DATA')
	Local oView			:= FWViewActive()
	Local oModelStruct	:= NIL
	Local lRet          := .F. //Retorno do gatilho
	Local dAux			:= 0
	Local aHoraSemN     := {}
	Local aArea := {}
	Local lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')
	Private aHorario    := {}
	

	aHora 		:= {}
	aHorario	:= {}
	aHoraSemN	:= {}
	aArea 		:= Z61->(GetArea())
	dAux := contaDisp(dData)
	Z61->(dbSetOrder(2))
    Z61->(dbSeek(xFilial('Z61')+DtoS(dData)))
	aDadosAux := retArrHora(Z61->Z61_ALOC)
		
	If Z61->(!Found())
		Help(" ",1,'CAEA0055',,"Data não cadastrada.",1,0,,,,,,{"Favor verificar calendário de disponibilidade."} )
	ElseIf dData < dDataBase
		Help(" ",1,'CAEA0055',,"Data inferior a data atual.",1,0,,,,,,{""} )	
	ElseIf Z61->Z61_STATUS == "N"//Alias já esta posicionado na rotina retArrHora
		Help(" ",1,'CAEA0055',,"Data indiponível conforme calendário de disponibilidade.",1,0,,,,,,{"Tente partir de " + DtoC(dAux) + " ou verifique o calendário de disponibilidade (CAEA0054)."} )
	ElseIf !lUsrAltera .And. dAux == dDataBase
		Help(" ",1,'CAEA0055',,"Data digitada não está dois dias úteis de diferença de hoje e não há nenhuma data posterior para agendamento.",1,0,,,,,,{"Verifique o calendário de disponibilidade."} )
	ElseIf !lUsrAltera .And. (dData < dAux .Or. DateDiffDay(dData,dDataBase) < 2)
		Help(" ",1,'CAEA0055',,"Só é permitido agendar recebimento após dois dias úteis da data atual baseado no calendário de disponibilidade.",1,0,,,,,,{"Tente partir de " + DtoC(dAux)} )
	ElseIf Empty(aDadosAux[2])
		Help(" ",1,'CAEA0055',,"Data sem horário disponível.",1,0,,,,,,{"Favor verificar disponibilidade de horários."} )	
	Else
		aHoraSemN := aDadosAux[1]
		aHorario  := aDadosAux[2]
		aHora := aClone(aHorario)
		lRet := .T.
	EndIf

	oModelStruct := oModel:GetModel('MASTERZ62'):GetStruct()		
	oModelStruct:SetProperty("Z62_RCHORA", MODEL_FIELD_VALUES,aHoraSemN)	
	//Tratamento para qndo rotina vinher do portal do fornecedor	
	If oView <> Nil
		oView:SetFieldProperty("MASTERZ62","Z62_RCHORA","COMBOVALUES",{aHorario})
	EndIf
	U_CAEA055H(oModel,,,)

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Retorna qual dia disponível no calendário para pode agendar
2 dias úteis do parque baseado na disponibilidade do calendário
@author  Jerry Junior
@since   01/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function contaDisp(dData)
	Local dRet := dDataBase
	Local nCont:= 1
	Local aArea := Z61->(GetArea())
	Z61->(dbSetOrder(2))
	cFiltro := DtoS(dDataBase)
	Z61->(dbGoTop())
	//Z61->(DbSeek(xFilial('Z61')+cFiltro))
	While Z61->(!Eof())
		If Z61->Z61_DATA <= dDataBase
			Z61->(dbSkip())
			Loop
		EndIf
		//Se for sabado ou domingo, pula contagem
		If cValToChar(Dow(Z61->Z61_DATA)) $ '1,7'
			Z61->(dbSkip())
			Loop
		EndIf
		//Se tiver passado 2 dais, status 'D' e não for (sabado ou domingo)
		If nCont > 1 .And. Z61->Z61_STATUS == 'D' .And. !(cValtoChar(Dow(Z61->Z61_DATA)) $ '1,7')
			dRet := Z61->Z61_DATA
			Exit
		EndIf
		nCont++
		Z61->(dbSkip())
	EndDo
	RestArea(aArea)
Return dRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055H
Gatilho Z62_RCHORA - Seta valor do campo virtual Z62_RCHORA para campo real Z62_HORA
@author  Jerry Junior
@since   20/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055H(oModel,cField,nIndex,cOldValue)		

	Default oModel		:= FWModelActive()
	
	oModel := oModel:GetModel('MASTERZ62')
	Default nIndex		:= Val(oModel:GetValue("Z62_RCHORA"))	


	If !Empty(aHora)		
		//nIndex := Val(oModel:GetValue("Z62_RCHORA"))
		If nIndex == 0
			nIndex := 1
			oModel:LoadValue("Z62_RCHORA", '1')
		EndIf
		
		/*If ALTERA .And. Empty(oModel:GetValue("Z62_RCHORA"))
			nIndex := aScan(aHora,{	|x| SubStr(x ,At("=",x)+1,Len(x)) == FwFldGet('Z62_HORA') })
			oModel:LoadValue("Z62_RCHORA", cValToChar(nIndex))
		EndIf*/

		cValue := aHora[IIf(nIndex == 0,1,nIndex)]
		cValue := SubStr(cValue ,At("=",cValue)+1,Len(cValue))	
		If oModel:IsFieldUpdated('Z62_RCHORA')
			oModel:LoadValue("Z62_HORA", cValue)
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055J
Carrega no campo Z62_LOCAL, combobox com os locais de entrega de um agendamento
Com base na tabela Z66, de parametros, que terá os locais como parametros
lOpc = .T. - É a validação do campo Z62_LOCAL para preencher a descricao do local Z62_DSCLOC
lOpc = .F. - É para retornar a lista de opções do campo Z62_LOCAL
@author  Jerry Junior
@since   02/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055J(lOpc)	
	Local xRet 		:= '1=;'
	Local i 		:= 1
	Local cLocal 	:= ''
	Local cHora		:= ''
	Local nPos 		:= 0
	Local aCbox		:= {}
	Local oModel 	:= FWModelActive()
	Default lOpc	:= .F.
	cQuery := " SELECT * FROM "  + RetSqlTab('Z66')
	cQuery += " WHERE " + RetSqlDel('Z66')
	cQuery += " AND Z66_CODIGO = 'PARQLOCAL'"
	
	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	If !lOpc
		TcQuery cQuery New Alias 'QRY'
		If QRY->(!Eof())
			xRet := ''
		EndIf
		While QRY->(!Eof())

			If Empty(xRet)
				xRet := cValtoChar(i) + '=' + alltrim(QRY->Z66_DESCRI)
			Else
				xRet += ';' + cValtoChar(i) + '=' + alltrim(QRY->Z66_DESCRI)
			EndIf

			i++
			QRY->(dbSkip())
		EndDo
	Else
		cLocal := FwFldGet('Z62_LOCAL')
		If Empty(cLocal)
			Help(" ",1,'CAEA0055',,"Local de entrega inválido.",1,0,,,,,,{"Escolha um local de entrega válido."} )	
			oModel:GetModel('MASTERZ62'):LoadValue('Z62_DSCLOC','')
			Return .F.
		EndIf
		SX3->(dbSetOrder(2))
		SX3->(dbSeek('Z62_LOCAL'))
		aCbox 	:= StrTokArr(SX3->(X3Cbox()),';')
		nPos 	:= aScan(aCbox,{|x| left(x,1) == cLocal})		
		cLocal 	:= SubStr(aCbox[nPos],At('=',aCbox[nPos])+1)
		cHora	:= FwFldGet('Z62_HORA')
		//Valida se pode ser agendado no local
		If !u_CAEA055P(cHora,cValToChar(nPos))
			Return .F.
		EndIf
		Z66->(dbSeek(cSeekZ66 := xFilial('Z66')+'PARQLOCAL'))
		While Z66->(!Eof()) .And. cSeekZ66 == (Z66->(Z66_FILIAL + alltrim(Z66_CODIGO)))
			If alltrim(Z66->Z66_DESCRI) == cLocal
				oModel:GetModel('MASTERZ62'):LoadValue('Z62_DSCLOC',alltrim(Z66->Z66_DESCRI) + ' - ' + alltrim(Z66->Z66_CONTEU))
				Exit
			EndIf
			Z66->(dbSkip())
		EndDo
		xRet := .T.
	EndIf


Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055K
cOpc = '1' - Valida se contrato digitado está vinculado ao fornecedor+loja digitado na tela
cOpc = '2' - Valida se fornecedor possui vinculo a algum contrato vigente.
cOpc Vazio - Consulta padrão, para realizar chamada do PesGen, com filtro desejado na CN9.
@author  Jerry Junior
@since   22/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055K(cOpc, cContra)		
	Local lRet := .F.
	Local cFiltro := ''
    Local cFornec := Alltrim(FwFldGet('Z62_FORNEC'))
    //Local cLoja   := Alltrim(FwFldGet('Z62_LOJA'))
	Local cQuery := ''
	Local cContratos := ''
	Local cRecnos	 := ''
	Default cOpc := ''
	Default cContra := Alltrim(FwFldGet('Z62_CONTRA'))
	
	cQuery := " SELECT DISTINCT CN9_NUMERO AS CONTRA, CN9.R_E_C_N_O_ AS RECNO FROM "  + RetSqlTab('CN9')
    cQuery += " INNER JOIN "  + RetSqlTab('CNC') + " ON CN9_NUMERO = CNC_NUMERO AND CN9_REVISA = CNC_REVISA AND CN9.D_E_L_E_T_ = CNC.D_E_L_E_T_"
	cQuery += " INNER JOIN "  + RetSqlTab('SA2') + " ON A2_COD = CNC_CODIGO AND A2_LOJA = CNC_LOJA AND SA2.D_E_L_E_T_ = CNC.D_E_L_E_T_"
    cQuery += " WHERE CN9.D_E_L_E_T_ = ''"
    cQuery += " AND A2_CGC = '" + alltrim(cFornec) + "'"
	cQuery += " AND CN9_SITUAC = '05'"
	
    If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'

	While QRY->(!Eof())
		If Empty(cContratos)            
			cContratos   := QRY->CONTRA 
			cRecnos		 := cValtoChar(QRY->RECNO)
		Else
			cContratos	+= ',' + QRY->CONTRA
			cRecnos		+= ',' + cValtoChar(QRY->RECNO)
		EndIf

		QRY->(dbSkip())
	EndDo

	If cOpc == '1' 
		//Verifica se contrato digitado esta na relaçao de contratos do fornecedor
		//Caso n esteja, retorna .T., pois rotina é usada na validação do fornecedor e consulta padrão
		If !(cContra $ cContratos)
			Help(" ",1,'CAEA0055',,"Contrato não está vinculado ao fornecedor escolhido ou situação não está 'Vigente'.",1,0,,,,,,{"Favor verificar dados do contrato."} )
			Return .F.
		Else
			Return .T.
		EndIf
	ElseIf cOpc == '2' 
		//Verifica se fornecedor digitado teve retorno na consulta da CN9
		//Caso n esteja, retorna .T., pois rotina é usada na validação do contrato e consulta padrão
		If Empty(cContratos)
			Help(" ",1,'CAEA0055',,"Fornecedor não está vinculado a nenhum contrato vigente.",1,0,,,,,,{"Favor verificar CNPJ digitado."} )
			Return .F.
		Else
			Return .T.
		EndIf
	EndIf

	cFiltro := "Alltrim(CN9->CN9_NUMERO) $  '" + cContratos + "' .AND. CN9_SITUAC='05' .AND. cValToChar(CN9->(Recno())) $ '" + cRecnos + "'"
	//U_PesqGen("Pesquisa Contratos","CN9", 1,"CN9_NUMERO","CN9_SITUAC='05'", .F., "CN9_NUMERO")
	lRet := U_PesqGen("Pesquisa Contratos","CN9", 1,"CN9_NUMERO",cFiltro)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA055L
Carrega horarios no campo Z62_RCHORA quando for opção de alteração
@author  Jerry Junior
@since   17/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055L
	Local i, cOpc := '1=;'
	If ALTERA 
		cOpc := ''
		Z61->(dbSetOrder(2))
		Z61->(dbSeek(xFilial('Z61')+DtoS(Z62->Z62_DATA)))
		aaux := retArrHora(Z61->Z61_ALOC)
		aHora := aaux[2]
		For i:=1 to Len(aaux[2])
			If Empty(cOpc)
				cOpc := aaux[2][i]
			Else
				cOpc += ';' + aaux[2][i]
			EndIf
			
		Next
	EndIf
Return cOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Validação do status.
Na inclusão só é permitido status A-Agendado, P-Pendente
@author  Jerry Junior
@since   28/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055M()
	Local lRet := .T.
	If FwFldGet('Z62_STATUS') $ 'R,C' .And. INCLUI
		Help(" ",1,'CAEA0055',,"Tipo de status não permitido para esta ação.",1,0,,,,,,{"Favor, inserir status Agendado ou Pendente"} )
		lRet := .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Abre pergunta para alteração do status do registro selecionado
@author  Jerry Junior
@since   28/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055N()
	Local aPergs 	 := {}
    Local aRet   	 := {}
    Local aStatus 	 := {"P=Pendente","A=Agendado","R=Recebido","C=Cancelado"}
    Local lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')
	
	If Z62->Z62_STATUS $ 'R,C' .And. !lUsrAltera	
		ApMsgInfo("Você não tem permissão para alterar status 'Recebido' ou 'Cancelado'.")
		Return
	EndIf

	If Z62->Z62_DATA == dDataBase .Or. DateDiffDay(Z62->Z62_DATA,dDataBase) < 2
		If Z62->Z62_STATUS == 'A'
			aStatus := {"R=Recebido","C=Cancelado"}
		ElseIf Z62->Z62_STATUS == 'P'
			aStatus := {"C=Cancelado"}
		EndIf
	EndIf

	aAdd(aPergs, {2,"Status",aStatus[1],aStatus,70 ,'.T.',.T.})

	If Z62->Z62_STATUS == 'R' .And. !lUsrAltera
			ApMsgInfo("Alteração não permitida para agendamento com status 'Recebido'.")		
	ElseIf Z62->Z62_STATUS == 'R' .And. Z62->Z62_DATA > dDataBase
		ApMsgInfo("Você não pode alterar para status 'Recebido' agendamento com data superior a data atual.")
		Return .F.	
	ElseIf DateDiffDay(Z62->Z62_DATA,Iif(Dow(dDataBase)==6,DaySum(dDataBase,3),dDataBase)) < 2 .And. Z62->Z62_STATUS $ 'R,C'			
			ApMsgInfo("Agendamento com data inferior a dois dias úteis da data atual.<br>Não permitido alteração de status para agendamento com status 'R' ou 'C'")
	ElseIf ParamBox(aPergs ,"Novo Status",aRet,,,,,,,.F.,.F.)
		If !lUsrAltera .And. aRet[1] == 'C' .And. (DateDiffDay(Z62->Z62_DATA,dDataBase) < 2 .Or. Z62->Z62_DATA < dDataBase)
			ApMsgInfo("Não pode haver cancelamento de agendamento com data inferior a 2 dias úteis da data atual.")
		ElseIf aRet[1] == 'A' .And. !u_CAEA055P(Z62->Z62_HORA,Z62->Z62_LOCAL,Z62->Z62_DATA,Z62->Z62_CODIGO,.T.,Z62->Z62_STATUS)
			ApMsgInfo("Já existem 2 agendamentos marcados neste local no mesmo horário.<br>Favor, alterar data, hora ou local do agendamento.")		
		Else
			RecLock('Z62', .F.)
				Z62->Z62_STATUS := aRet[1]
			Z62->(MsUnLock())
			If Z62->Z62_STATUS $ 'A,R,C' .And. !Empty(Z62->Z62_EMAIL)
				If MsgYesNo('Deseja realizar o envio de e-mail para os destinatários digitados neste agendamento?')
					EnviaEmail(.T.)
				EndIf
			EndIf
		EndIf
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Gatilho do campo Z62_CONTRA, para preencher a grid filha com os itens da CNB
@author  Jerry Junior
@since   30/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055O()
	
	Local oModel 	 := FWModelActive()	
	Local oView 	 := FWViewActive()
	Local oModelZ67  := oModel:GetModel('Z67DETAIL')
	Local cContra 	 := alltrim(FwFldGet('Z62_CONTRA'))
	Local cQuery 	 := ''
	Local nLin := 0
	Local nX := 0
		
	//Limpa grid para adicionar novos dados
	If INCLUI 
		oModelZ67:ClearData()
	Else
		oModelZ67:DelAllLine()
	EndIf

	//Bloqueia o modelo para update, inserção e exclusao de linha	
	For nX := 1 to oModelZ67:GetLine()
		oModelZ67:GoLine(nX)
		//oModelZ67:SetNoInsertLine(.T.)
		//oModelZ67:SetNoDeleteLine(.T.)
		//oModelZ67:SetNoUpdateLine(.T.)
	Next
	
	cQuery := " SELECT CNB_CONTRA, CNB_PRODUT, CNB_DESCRI, CNB_VLUNIT, (sum(CNB_SLDMED)-coalesce(("
	cQuery += " 	SELECT SUM(Z67_QTDENT) FROM " + RetSqlTab('Z62')
	cQuery += " 	LEFT JOIN " + RetSqlTab('Z67') + " ON Z67_CODZ62=Z62_CODIGO AND Z67_PRODUT=CNB_PRODUT AND Z67.D_E_L_E_T_=''"
	cQuery += " 	WHERE Z62_CONTRA=CNB_CONTRA AND Z62_STATUS NOT IN ('R','P','C') AND Z62.D_E_L_E_T_='' 
	cQUery += " ),0)) AS SALDO, SUM(CNB_QUANT) AS QUANT"
	cQuery += " FROM "  + RetSqlTab('CNB')
	cQuery += " LEFT JOIN " + RetSqlTab('Z62') + " ON Z62_CONTRA=CNB_CONTRA AND Z62_STATUS NOT IN ('R','P','C') AND Z62.D_E_L_E_T_=''
	cQuery += " LEFT JOIN " + RetSqlTab('Z67') + " ON Z67_CODZ62=Z62_CODIGO AND Z67_PRODUT=CNB_PRODUT AND Z67.D_E_L_E_T_=''
	cQuery += " WHERE " + RetSqlDel('CNB')
	cQuery += " AND CNB_CONTRA = '" + cContra + "'"
	cQuery += " AND CNB_SLDMED > 0"
	cQuery += " AND CNB_REVISA = ( SELECT MAX(CN9_REVISA) FROM "  + RetSqlTab('CN9')
	cQuery += "				WHERE " + RetSqlDel('CN9')
	cQuery += "				AND CN9_NUMERO =  '" + cContra + "' AND CN9_SITUAC = '05')"
	cQuery += " GROUP BY CNB_CONTRA, CNB_PRODUT, CNB_DESCRI, CNB_VLUNIT"	
	cQuery += " ORDER BY CNB_PRODUT"
	If Select('QRYCNB') > 0
		QRYCNB->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRYCNB'
	i := 1
	//Se não houver produtos, bloqueia inserção de linhas
	If QRYCNB->(Eof())		
		oModelZ67:GoLine(1)	
		oModelZ67:SetNoInsertLine(.T.)
		oModelZ67:SetNoUpdateLine(.T.)
	EndIf

	While QRYCNB->(!Eof())
		If QRYCNB->SALDO <= 0
			QRYCNB->(dbSkip())
			Loop
		EndIf

		//Libera linha para mexer na linha atual
		oModelZ67:SetNoInsertLine(.F.)
		oModelZ67:SetNoDeleteLine(.F.)
		oModelZ67:SetNoUpdateLine(.F.)
		nLin := oModelZ67:GetLine()		
		//Quando i passar o max de linha na grid, é a hora de inserir novas e não alterar as que ja existem
		If i > oModelZ67:Length() 
			oModelZ67:AddLine()
		Else
			oModelZ67:GoLine(i)			
		EndIf
		//Verifica se linha está deletada, e desfaz para ser alterada
		If oModelZ67:IsDeleted()
			oModelZ67:UnDeleteLine()
		EndIf

		oModelZ67:LoadValue('Z67_PRODUT',QRYCNB->CNB_PRODUT)
		oModelZ67:LoadValue('Z67_DESCRI',QRYCNB->CNB_DESCRI)
		oModelZ67:LoadValue('Z67_QTDENT',0)
		oModelZ67:LoadValue('Z67_SALDO',QRYCNB->SALDO)
		oModelZ67:LoadValue('Z67_VLUNIT',QRYCNB->CNB_VLUNIT)
		oModelZ67:LoadValue('Z67_QUANT',QRYCNB->QUANT)
		i++
		QRYCNB->(dbSkip())
		//Bloqueia linha atual
		//oModelZ67:SetNoInsertLine(.T.)
		//oModelZ67:SetNoDeleteLine(.T.)
	EndDo
	//Volta para primeira linha
	oModelZ67:GoLine(1)	
	//Bloqueia linha
	//oModelZ67:SetNoInsertLine(.T.)
	//oModelZ67:SetNoDeleteLine(.T.)
	//Tratamento para qndo rotina vinher do portal do fornecedor
	If oView <> Nil
		oView:Refresh()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Verifica se existe mais de 2 agendamentos para o horário escolhido
@author  Jerry Junior
@since   30/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055P(cHora,cLocal,dData,cCodZ62,lOpc,cStatus)
	Local lRet	:= .T.	
	Local i := 0
	Local aArea := Z62->(GetArea())
	//Default cLocal  := FwFldGet('Z62_LOCAL')
	Default cStatus := FwFldGet('Z62_STATUS')
	Default cCodZ62 := FwFldGet('Z62_CODIGO')
	Default dData 	:= FwFldGet('Z62_DATA')
	Default lOpc 	:= .F.
	
	If cStatus <> 'A' .And. !lOpc
		Return .T.
	EndIf

	Z62->(dbSetOrder(4))
	Z62->(dbGoTop())
	If Z62->(dbSeek(cSeekZ62 := xFilial('Z62')+dtos(dData)+cHora))
		While Z62->(!Eof()) .And. cSeekZ62 == (Z62->(Z62_FILIAL+dtos(Z62_DATA)+Z62_HORA))
			//So considera agendamentos com status 'Agendado'
			If Z62->Z62_STATUS == 'A' .And. cCodZ62 <> Z62->Z62_CODIGO .And. Z62->Z62_LOCAL == cLocal
				i++
			EndIf
			If i > 1
				lRet := .F.
				If !lOpc
					Help(" ",1,'CAEA0055',,"Já existem 2 agendamentos marcados para este horário.",1,0,,,,,,{"Escolher outro horário."} )
				EndIf
				Exit
			EndIf
			Z62->(dbSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Consulta padrão, para realizar chamada do PesGen, com filtro desejado.
Pois o filtro da consulta padrão estava demandando muito tempo para mostrar resultados.
Consulta os produtos e planilhas com saldo na competencia escolhida e disponíveis no contrato
@author  Jerry Junior
@since   09/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055Q()		
	Local lRet := .F.
	Local cFiltro := ''
	Local cContra := Alltrim(M->Z62_CONTRA)	
	Local cQuery := ''
	Local cPlan := ''
	Local cRevisa := ''
	cQuery := " SELECT CNA_NUMERO AS PLANILHA, CNA_REVISA AS REVISA FROM "  + RetSqlTab('CNA')		
	cQuery += " WHERE CNA.D_E_L_E_T_ = ''"	

	cQuery += " AND CNA.CNA_CONTRA = '" + cContra + "'"	
	cQuery += " AND CNA.CNA_SALDO  > 0 "//Filtra planilhas com saldo		
	cQuery += " AND CNA_REVISA = ( "
	cQuery += " 	SELECT MAX(CN9_REVISA) FROM " + RetSqlTab('CN9')
	cQuery += "		WHERE  CN9.D_E_L_E_T_ = ' ' AND CN9_NUMERO =  '" + cContra + "' AND CN9_SITUAC = '05')

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'
	
	While QRY->(!Eof())
		If Empty(cPlan)
			cPlan := QRY->PLANILHA 
			cRevisa := alltrim(QRY->REVISA)
		Else
			cPlan += ',' + QRY->PLANILHA
		EndIf

		QRY->(dbSkip())
	EndDo
	cFiltro := "Alltrim(CNB->CNB_NUMERO) $ '" + cPlan + "' .AND. "
	cFiltro += "Alltrim(CNB->CNB_CONTRA) == '" + cContra + "' .AND. "
	cFiltro += "Alltrim(CNB->CNB_REVISA) == '" + cRevisa + "'"
	lRet := U_PesqGen('Pesquisa Planilha x Produtos', 'CNB', 1, 'CNB_NUMERO', cFiltro)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA052D
Gatilho para preencher automaticamente os campos da tela
Validação do campo Z67_PRODUT
@author  Jerry Junior
@since   09/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055R(cCampo,cOpc)	
	Local cQuery 	:= ''
	Local xRet 		:= ''
	Default cCampo := "*"
	Default cOpc := ''
	cQuery := " SELECT " + cCampo + " FROM "  + RetSqlTab('CNB')
	cQuery += " WHERE " + RetSqlDel('CNB')
	cQuery += " AND CNB_CONTRA = '" + Alltrim(M->Z62_CONTRA) + "'"
	cQuery += " AND CNB_PRODUT = '" + alltrim(M->Z67_PRODUT) + "'"
	
	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'
	//Validação do campo
	If !Empty(cOpc)
		If QRY->(Eof())
			Help(" ",1,'CAEA0055',,"Produto não pertence a nenhuma planilha do contrato selecionado.",1,0,,,,,,{"Digitar um produto vinculado."} )
			Return .F.
		Else
			Return .T.
		EndIf
	EndIf
	//Trigger do campo
	While QRY->(!Eof())
		xRet := QRY->&(cCampo)
		QRY->(dbSkip())
	EndDo
	
Return xRet



//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Chamada para uso externo da Static Function retArrHora
@author  Jerry Junior
@since   23/06/2022
@version 1.0
@type function
@type function
@param cAloc, character, texto codificado de horas
/*/
//-------------------------------------------------------------------
User Function CAEA055X(cAloc)
Return retArrHora(cAloc)

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Retorna em um combobox, as horas disponíveis na data selecionada.
@author  Jerry Junior
@since   01/04/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function retArrHora(cAloc)
	Local nx
    Local nItem := 1
	Local aHoraSemN := {}
	Local aHorario := {}
    Local cHoraStr := ''
    
    cHoraStr := Bin2Str(cAloc)
    nItem := 1
    nMarca := 0
    For nx:=1 to Len(cHoraStr)
        If !Empty(Subs(cHoraStr,nx,1))
            cHora := retHora(nx-1)
            aAdd(aHorario,cValToChar(nItem)+"="+cHora)
            aAdd(aHoraSemN,cValToChar(nItem))
            nItem++
            nx += 3
        EndIf
    Next nx
Return {aHoraSemN,aHorario}


Static Function retHora(nMarca)
    Local cHora := ''
    Local nPrecisao := GETMV("MV_PRECISA")
    Local cHr  := StrZero(Int(nMarca / nPrecisao), 2) // Hora
    Local cMin := StrZero(Iif(nMarca>0,((nMarca % nPrecisao) / nPrecisao ) * 60 , 0) , 2) // Minutos    
    cHora := cHr + ":" + cMin
Return cHora


//-------------------------------------------------------------------
/*/{Protheus.doc} alteraHora
Altera horário da tela com novo valor escolhido na parambox
@author  Jerry Junior
@since   25/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function alteraHora()
	Local oModel	 := FWModelActive()
	Local dData		 := FwFldGet('Z62_DATA')
	Local cHora 	 := ''
	Local aRet 		 := ''
	Z61->(dbSetOrder(2))
    Z61->(dbSeek(xFilial('Z61')+DtoS(dData)))
	aRet := pergHorario(Z61->Z61_ALOC)
	If aRet[1]
		cHora := aRet[2]
		oModel:GetModel('MASTERZ62'):LoadValue("Z62_HORA", cHora)
	Else
		oModel:GetModel('MASTERZ62'):LoadValue("Z62_DATA", Z62->Z62_DATA)
		oModel:GetModel('MASTERZ62'):LoadValue("Z62_HORA", Z62->Z62_HORA)
	EndIf

Return aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Abre parambox para escolher novo horário de agendamento
@author  Jerry Junior
@since   25/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function pergHorario(cAloc)
	Local aPergs := {}
    Local aRet   := {}
	Local aHora  := {}
	Local lRet 	 := .F.
	Local cNewHora := ''
	
	aHora := retArrHora(cAloc)
	aAdd(aPergs, {2,"Horário",aHora[2][1],aHora[2],50 ,'.T.',.T.})
	If ParamBox(aPergs ,"Escolha novo horário de agendamento:",aRet,,,,,,,.F.,.F.)
		cNewHora := substr(aHora[2][val(aRet[1])],at('=',aHora[2][val(aret[1])])+1)
		lRet := .T.
	EndIf
Return {lRet,cNewHora}

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Ponto de Entrada MVC da rotina
@author  Jerry Junior
@since   28/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055
	Local xRet			:= .T.
	Local cAction 		:= ''
	Local cCampo		:= ''
	Local cOpc			:= ''
	Local cGrid			:= ''
	Local aDados := {}
	Local aHoraSemN := {}
	Local aHorario := {}
	Private lValid := .F.
	If PARAMIXB == NIL
        Return
    EndIf
	
	cAction 	:= PARAMIXB[2]
	cGrid 		:= PARAMIXB[3]
	If Len(PARAMIXB) > 4		
		cOpc		:= PARAMIXB[4]
		cCampo		:= PARAMIXB[5]
	EndIf

	If cAction == "FORMPRE" .And. cGrid == 'MASTERZ62' .And. cOpc == 'ISENABLE'
		oModel		:= FWModelActive()
		oView		:= FWViewActive()
		oModelZ62	:= oModel:GetModel("MASTERZ62")
		oStruct		:= oModelZ62:GetStruct()

		If ALTERA			
			Z61->(dbSetOrder(2))
			Z61->(dbSeek(xFilial('Z61')+DtoS(Z62->Z62_DATA)))
			aDados := retArrHora(Z61->Z61_ALOC)
			aHoraSemN	:= aDados[1]
			aHorario	:= aDados[2]
			aHora 		:= aClone(aHorario)		
		EndIf	

		oStruct:SetProperty("Z62_RCHORA", MODEL_FIELD_VALUES,aHoraSemN)			
		oView:SetFieldProperty("MASTERZ62","Z62_RCHORA","COMBOVALUES",{aHorario})	
		xRet := .T.
	EndIf

	If cAction == 'FORMPRE' .And. cCampo == 'Z62_RCHORA' .And. cOpc == 'SETVALUE'
		xRet := u_CAEA055H(,,Val(PARAMIXB[6]))
	EndIf

	If cAction == 'MODELCOMMITTTS'
		oModel		:= FWModelActive()		
		oModelZ62	:= oModel:GetModel("MASTERZ62")
		oModelZ67	:= oModel:GetModel("Z67DETAIL")
		If !Empty(FwFldGet('Z62_EMAIL')) .And. FwFldGet('Z62_STATUS') $ 'A,R,C' .And. ;
		(INCLUI .Or. (ALTERA .And. (oModelZ62:IsFieldUpdated('Z62_DATA') .Or. ;
		oModelZ62:IsFieldUpdated('Z62_STATUS') .Or.	oModelZ62:IsFieldUpdated('Z62_HORA') ;
		.Or. oModelZ62:IsFieldUpdated('Z62_EMAIL'))))
			If MsgYesNo('Deseja realizar o envio de e-mail para os destinatários digitados neste agendamento?')
				EnviaEmail(.F.,oModelZ67)
			EndIf
		EndIf
	EndIf
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Valida se produto está vinculado ao contrato selecionado
@author  Jerry Junior
@since   10/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function vldProduto(cProd, lVldSld, nQtdEnt)
	Local lRet := .F.
	Local cContra := FwFldGet('Z62_CONTRA')
	Default lVldSld := .F.
	cQuery := " SELECT CNB_CONTRA, CNB_PRODUT, CNB_VLUNIT, SUM(CNB_SLDMED) 'CNB_SLDMED'"
	cQuery += " FROM "  + RetSqlTab('CNB')
	cQuery += " WHERE " + RetSqlDel('CNB')
	cQuery += " AND CNB_CONTRA = '" + alltrim(cContra) + "'"
	cQuery += " AND CNB_PRODUT = '" + alltrim(cProd) + "'"
	cQuery += " AND CNB_REVISA = ( SELECT MAX(CN9_REVISA) FROM "  + RetSqlTab('CN9')
	cQuery += "				WHERE " + RetSqlDel('CN9')
	cQuery += "				AND CN9_NUMERO =  '" + cContra + "' AND CN9_SITUAC = '05')"
	cQuery += " GROUP BY CNB_CONTRA, CNB_PRODUT, CNB_VLUNIT"

	If Select('QRY') > 0
		QRY->(dbclosearea())
	EndIf
	
	TcQuery cQuery New Alias 'QRY'
	
	If QRY->(Eof())
		lRet := .T.
	ElseIf lVldSld//Valida se qtd entrega é maior que saldo do item
		lRet := nQtdEnt > QRY->CNB_SLDMED
	EndIf
	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Envio de email pelo browse
@author  Jerry Junior
@since   28/05/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055S()
	Local aEmail := {}	
	Local i
	If Empty(Z62->Z62_EMAIL)
		Help(" ",1,'CAEA0055',,"Não há destinatários cadastrados neste agendamento",1,0,,,,,,{"Cadastre e tente novamente."} )		
		Return
	EndIf

	If Z62->Z62_STATUS == 'P'
		Help(" ",1,'CAEA0055',,"Status não permite envio de e-mail",1,0,,,,,,{"Permitido apenas agendamento 'Agendado', 'Recebido' ou 'Cancelado'"} )		
		Return
	EndIf

	//Validação do campo email
	If !Empty(Z62->Z62_EMAIL)
		aEmail := Strtokarr2( alltrim(Z62->Z62_EMAIL), ';', .F.)		
		For i:=1 to Len(aEmail)
			If !IsEmail(aEmail[i])
				Help(" ",1,'CAEA0055',,"Campo e-mail com formato inválido.",1,0,,,,,,{"Digite corretamente o e-mail e utilize o separador ';'"} )
				Return
			EndIf
		Next			
	EndIf

	If Z62->Z62_STATUS $ 'A,R,C' .And. !Empty(Z62->Z62_EMAIL)
		If MsgYesNo('Deseja realizar o envio de e-mail para os destinatários digitados neste agendamento?')
			EnviaEmail(.T.)
		EndIf
	EndIf
Return

Static Function EnviaEmail(lOpc,oModelZ67)
	Local cMsg 		:= ""
	Local cMsgProd	:= ""
	Local cCodZ62	:= Iif(lOpc,Z62->Z62_CODIGO,FwFldGet('Z62_CODIGO'))
	Local dData 	:= Iif(lOpc,Z62->Z62_DATA,FwFldGet('Z62_DATA'))
	Local cHora 	:= alltrim(Iif(lOpc,Z62->Z62_HORA,FwFldGet('Z62_HORA')))
	Local cFornec 	:= alltrim(Iif(lOpc,Z62->Z62_FORNEC,FwFldGet('Z62_FORNEC')))
	Local cContra 	:= alltrim(Iif(lOpc,Z62->Z62_CONTRA,FwFldGet('Z62_CONTRA')))
	Local cLocal 	:= alltrim(Iif(lOpc,Z62->Z62_DSCLOC,FwFldGet('Z62_DSCLOC')))
	Local cObs 		:= alltrim(Iif(lOpc,Z62->Z62_OBS,FwFldGet('Z62_OBS')))
	Local cNota 	:= alltrim(Iif(lOpc,Z62->Z62_NOTA,FwFldGet('Z62_NOTA')))	
	Local cPara		:= alltrim(Iif(lOpc,Z62->Z62_EMAIL,FwFldGet('Z62_EMAIL')))
	Local cStatus	:= Iif(lOpc,Z62->Z62_STATUS,FwFldGet('Z62_STATUS'))
	Local cAssunto 	:= ''	
	Local nTotal	:= 0
	Local aProd		:= {}
	Local i
	If cStatus == 'A'
		cStatus := 'Agendamento'
	ElseIf cStatus == 'R'
		cStatus := 'Recebimento'
	Else
		cStatus := 'Cancelamento'
	EndIf

	If lOpc
		If Z67->(dbSeek(cSeekZ67 := xFilial('Z67')+cCodZ62))
			While Z67->(!Eof()) .And. cSeekZ67 == Z67->(Z67_FILIAL+Z67_CODZ62)				
				aAdd(aProd,{StrZero(Z67->Z67_QTDENT,3), alltrim(Z67->Z67_DESCRI), Transform(Z67->Z67_VLUNIT,'999,999,999.99') })	
				Z67->(dbSkip())
			EndDo
		EndIf
	Else
		For i:=1 to oModelZ67:GetQTDLine()
			oModelZ67:GoLine(i)
			If oModelZ67:IsDeleted()
				Loop
			EndIf
			aAdd(aProd,{StrZero(oModelZ67:GetValue('Z67_QTDENT'),3), alltrim(oModelZ67:GetValue('Z67_DESCRI')), Transform(oModelZ67:GetValue('Z67_VLUNIT'),'999,999,999.99') })
		Next
	EndIf

	For i:=1 to Len(aProd)
		cMsgProd += '		<tr>'
		cMsgProd += '			<td style="vertical-align: middle;">' + aProd[i,1] + '</td>'
		cMsgProd += '			<td style="vertical-align: middle;">' + aProd[i,2] + '</td>'		
		cMsgProd += '		</tr>'
		nTotal += Val(aProd[i,1]) * Val(aProd[i,3])		
	Next

	cAssunto := '[CAERN] Confirmação de ' + cStatus + ' de Entrega de Materiais no Parque'
	SA2->(dbSetOrder(3))
	SA2->(dbSeek(xFilial('SA2')+cFornec))
	cMsg += '<!DOCTYPE html>'
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<meta content="text/html; charset=windows-1252" http-equiv="Content-Type" />'
	cMsg += '<style type="text/css" media="all">'
	cMsg += '	body{'
	cMsg += '		font-family: Arial, Helvetica, sans-serif;'
	cMsg += '	}'
	cMsg += '	td,th{'
	cMsg += '		text-align: left;'
	cMsg += '		font-size: 20px;'
	cMsg += '	}'
	cMsg += '</style>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<h2 style="text-align:left; ">Confirmação de Entrega</h2>'
	cMsg += '	<table>'
	cMsg += '		<tbody>	'
	cMsg += '			<thead>'
	cMsg += '				<tr>'
	cMsg += '					<th colspan="1" width="10%"></th>'
	cMsg += '					<th colspan="2" width="60%"></th>'
	cMsg += '				</tr>'
	cMsg += '			</thead>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Fornecedor</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + alltrim(SA2->A2_NOME) + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Contrato</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + cContra + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Data</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + DiaSemana(dData,3) + ' ' +  DtoC(dData) + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Hora Inicial</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + cHora + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Local</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + cLocal + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Status</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + Iif(left(cStatus,1)=='A','Agendado',Iif(left(cStatus,1)=='R','Recebido','Cancelado')) + '</td>		'
	cMsg += '			</tr>'
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Nota Fiscal</td>		'
	cMsg += '				<td style="vertical-align:middle;">' + cNota + '</td>		'
	cMsg += '			</tr>'	
	cMsg += '			<tr>'
	cMsg += '				<td style="vertical-align:middle;">Valor Total</td>		'
	cMsg += '				<td style="vertical-align:middle;">R$ ' + Transform(nTotal,'999,999,999.99') + '</td>		'
	cMsg += '			</tr>'
	cMsg += '		</tbody>'
	cMsg += '	</table>	'

	If Len(aProd) > 0
		cMsg += '<h2 style="text-align:left; ">Itens</h2>'	
		cMsg += '<table>				'
		cMsg += '<thead>'
		cMsg += '	<tr>			'
		cMsg += '		<th colspan="1" width="10%">Qtd</th>'
		cMsg += '		<th colspan="2" width="90%">Descrição</th>'
		cMsg += '	</tr>'
		cMsg += '</thread>'
		cMsg += '	<tbody>		'
		cMsg += cMsgProd		
		cMsg += '	</tbody>'
		cMsg += '</table>	'	
	EndIf
	cMsg += '<h2 style="text-align:left; ">Observação</h2>'
	cMsg += '<table>				'
	cMsg += '	<tbody>		'
	cMsg += '		<tr>			'
	cMsg += '			<td style="vertical-align:middle;">' + cObs + '</td>															'
	cMsg += '		</tr>'
	cMsg += '	</tbody>'
	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'
    If ! U_UEnviaEmail(cMsg, cPara, cAssunto)
        ApMsgInfo('Erro ao enviar email')
	Else
		ApMsgInfo('E-mail enviado com sucesso!')
    EndIf 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Inclusão automática para tabela Z62 - Z67
aDados { 
	1 - Z62_FORNEC
	2 - Z62_CONTRA
	3 - Z62_DATA
	4 - Z62_HORA
	5 - Z62_LOCAL
	6 - Z62_NOTA
	7 - Z62_FONE
	8 - Z62_CONTAT
	9 - Z62_EMAIL
	10 - Z62_OBS
}
@author  Jerry Junior
@since   21/06/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA055T(aDados)
	Local cMsg := ''
	Local lVerif := .T. 	
	Local nPosData := aScan(aDados,{|x| AllTrim(x[1]) == 'Z62_DATA'})
	Local nPosHora := aScan(aDados,{|x| AllTrim(x[1]) == 'Z62_HORA'})
	Local nPosFornec	:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_FORNEC'})
	Local nPosContra	:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_CONTRA'})
	Local nPosLocal		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_LOCAL'})
	Local nPosNota		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_NOTA'})
	Local nPosNfDevo	:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_NFDEVO'})
	Local nPosFone		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_FONE'})
	Local nPosContat	:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_CONTAT'})
	Local nPosEmail		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_EMAIL'})
	Local nPosObs		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z62_OBS'})
	Local nPosProd		:= aScan(aDados, {|x| Alltrim(x[1]) == 'Z67DETAIL'})
	Local aProdAux		:= Iif(nPosProd>0, Strtokarr2(aDados[nPosProd,2], '#', .F.), {})
	Local cFornece	:= alltrim(aDados[nPosFornec,2])
	Local cContra 	:= alltrim(aDados[nPosContra,2])
	Local cLocal	:= alltrim(aDados[nPosLocal ,2])
	Local cNota		:= alltrim(aDados[nPosNota  ,2])
	Local cNfDevo	:= alltrim(aDados[nPosNfDevo,2])
	Local cFone		:= alltrim(aDados[nPosFone  ,2])
	Local cContat	:= alltrim(aDados[nPosContat,2])
	Local cEmail	:= alltrim(aDados[nPosEmail ,2])
	Local cObs		:= alltrim(aDados[nPosObs	  ,2])
	Local dData		:= CtoD(aDados[nPosData,2])
	Local cHora		:= aDados[nPosHora,2]
	Local aEmail	:= {}
	Local nQtdEnt	:= 0
	Local dAux, i, j
	Private lMsErroAuto := .F.
	Private aHora := {}
	//Verifica se fornecedor ja tem agendamento para contrato escolhido na data escolhida
	Z62->(dbSetOrder(3))
	If Z62->(dbSeek(cSeekZ62 := xFilial('Z62')+DtoS(dData)+cFornece))
		While Z62->(!Eof()) .And. cSeekZ62 == (Z62->(Z62_FILIAL+DtoS(Z62_DATA)+Z62_FORNEC))
			If alltrim(Z62->Z62_CONTRA) == cContra .And. Z62->Z62_STATUS <> 'C'
				cMsg := 'Ja existe um pedido de agendamento para este contrato neste dia.'
				HttpSession->Msg := cMsg
				
				conout(cMsg)
				limpaVar()
				Return .F.
			EndIf
			Z62->(dbSkip())
		EndDo
	EndIf

	//Validação do campo email
	If !Empty(cEmail)
		aEmail := Strtokarr2( alltrim(cEmail), ',', .F.)
		cEmail := ''
		For i:=1 to Len(aEmail)
			If IsEmail(aEmail[i])
				cEmail += aEmail[i]
				cEmail += Iif(i < Len(aEmail),';','')
			Else		
				cMsg := "Campo e-mail com formato invalido. Digite corretamente o e-mail. Para varios, utilize o separador \',\'"
				HttpSession->Msg := cMsg
				
				conout(cMsg)
				limpaVar()
				Return .F.				
			EndIf
		Next		
	EndIf

	dAux := contaDisp(dData)
	If dData < dAux .Or. DateDiffDay(dData,dDataBase) < 2
		cMsg := "So e permitido agendar recebimento apos dois dias uteis da data atual baseado no calendario de disponibilidade. " + Iif(dAux > dDataBase, "Tente partir de " + DtoC(dAux), "")
		HttpSession->Msg := cMsg
		
		conout(cMsg)
		limpaVar()
		Return .F.
	EndIf
	//Ativa modelo para inclusão
	oModelZ62 := FwLoadModel("CAEA0055")
	oModelZ62:SetOperation(3)
	oModelZ62:Activate()

	oModelZ62:SetValue( "MASTERZ62", "Z62_DATA", dData )
	//Pega posição do horario no combobox
	nPosRCHora := aScan(aHora, {|x| alltrim(right(x,5)) == cHora } )
	oModelZ62:SetValue( "MASTERZ62", "Z62_RCHORA", cValtoChar(nPosRCHora) )
	lVerif := u_CAEA055P(cHora, cLocal ,,,.T.)
		

	If !lVerif
		cMsg := 'Ha mais de 1 agendamento para esse local nesta data e hora, tente em outro local ou data/hora'	
	Else
		If !oModelZ62:SetValue( "MASTERZ62", "Z62_FORNEC", 	cFornece	) .Or.; 
		!oModelZ62:SetValue( "MASTERZ62", "Z62_CONTRA", 	cContra 	) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_LOCAL", 	cLocal		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_NOTA", 	cNota		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_NFDEVO",	cNfDevo		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_FONE", 	cFone		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_CONTAT", 	cContat		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_EMAIL", 	cEmail		) .Or. ;
		!oModelZ62:SetValue( "MASTERZ62", "Z62_OBS", 	cObs		)				
			aErr := oModelZ62:GetErrorMessage()
			cMsg := FwCutOff(aErr[MODEL_MSGERR_MESSAGE]) + ' - ' + FwCutOff(aErr[MODEL_MSGERR_SOLUCTION])
			HttpSession->Msg := cMsg
			
			conout(cMsg)
			limpaVar()
			oModelZ62:DeActivate()
			oModelZ62:Destroy()
			Return .F.
		EndIf
		oModelZ62:LoadValue( "MASTERZ62", "Z62_ORIGEM", 	'PORTAL' )


		//oModelZ67 := oModelZ62:GetModel('Z67DETAIL')
		If Len(aProdAux) > 0
			For i:=1 to oModelZ62:GetModel('Z67DETAIL'):GetQTDLine()
				oModelZ62:GetModel('Z67DETAIL'):GoLine(i)
				For j:=1 to Len(aProdAux)				
					aProd := Strtokarr2(aProdAux[j], ';', .T.)
					nQtdEnt := Val(aProd[2])
					nVlUnit := Val(aProd[3])
					//aProd := retProduto(cContra, aAux[1])
					//CNB_PRODUT, CNB_DESCRI, CNB_QUANT, CNB_SLDMED, CNB_VLUNI
					If alltrim(aProd[1]) == alltrim(oModelZ62:GetValue('Z67DETAIL','Z67_PRODUT')) 	.and. nVlUnit == oModelZ62:GetValue('Z67DETAIL','Z67_VLUNIT')			
						oModelZ62:LoadValue("Z67DETAIL", "Z67_QTDENT", nQtdEnt     )					
					EndIf
				Next
				
			Next
		EndIf

		BeginTran()
		If oModelZ62:VldData()
			oModelZ62:CommitData()
			conout("#####################")
			conout("INCLUIDO COM SUCESSO!")
			conout("#####################")
			//Se chegfou aki, incluiu corretamente e fecha transação
			EndTran()
		Else			
			lVerif := .F.
		EndIf
		//se der erro na inclusão, desarma a transação
		If lMsErroAuto .Or. !lVerif
			lVerif := .F.
			DisarmTransaction()			
			aErr := oModelZ62:GetErrorMessage()
			cMsg := FwCutOff(aErr[MODEL_MSGERR_MESSAGE]) + ' - ' + FwCutOff(aErr[MODEL_MSGERR_SOLUCTION])
			conout("###############")
			conout("ERRO VALIDACAO")
			conout("###############")
			conout(cMsg)
			conout("###############")	
		EndIf

		If Empty(cMsg)
			cMsg := 'Agendamento realizado com sucesso!'
		EndIf

		oModelZ62:DeActivate()
		oModelZ62:Destroy()
	EndIf	

	HttpSession->Msg := cMsg
	
	limpaVar()	
	conout(cMsg)
Return lVerif


Static Function limpaVar()
	HttpPost->Z62_FORNEC := ''
	HttpPost->Z62_CONTRA := ''
	HttpPost->Z62_LOCAL	 := ''
	HttpPost->Z62_NOTA	 := ''
	HttpPost->Z62_FONE	 := ''
	HttpPost->Z62_CONTAT := ''
	HttpPost->Z62_EMAIL	 := ''
	HttpPost->Z67DETAIL	 := ''
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Inicializador do campo virtual Z62_NOTAS
@author  Jerry Junior
@since   15/12/2020
@version 1.0
@type function
@Redmine 19465
/*/
//-------------------------------------------------------------------
User Function CAEA055U(oModel)
	Local cRet := ''
	Local cNotas := FwFldGet('Z62_NOTA')
	Local dData := FwFldGet('Z62_DATA')
	Local aNotas := StrTokArr2(alltrim(cNotas), "#")
	Local aNf 	 := {}
	Local i
	cRet := "       NF        | Valor    " + CHR(10) + CHR(13)
	For i:=1 to Len(aNotas)
		aNf := StrTokArr2(aNotas[i], ";")
		If dData >= CtoD('24/12/2020')
			cRet += Padl(aNf[1], 9, '0') + " | " + alltrim(transform(val(aNf[2]), "@E 999,999,999.99")) + CHR(10) + CHR(13)
		Else
			cRet := cNotas
			exit
		EndIf
	Next
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Alterar parametro com mensagem de aviso na tela de agendamento do portal do forncedor
@author  Jerry Junior
@since   26/11/2021
@version 1.0
@type function
@Redmine 
@param lCarrega, logical, indica se é para apenas retornar conteúdo do arquivo txt de aviso
/*/
//-------------------------------------------------------------------
User Function CAEA055V(lCarrega)
	Local cArq1 := "\web\portal\faq\aviso.txt"
	Local cTexto := ""
	Default lCarrega := .F.
	aOpcs  := {'Sim', 'Não'}
	aPergs := {}
	aRet   := {}

	cTexto := lerTxt(lCarrega)
	
	If Empty(FunName())
        PREPARE ENVIRONMENT EMPRESA '01' FILIAL 'CAEADC0001'
    EndIf

	If lCarrega
		cTexto := EncodeUTF8(cTexto)
		Return cTexto
	EndIf
	aAdd(aPergs,{11,"Mensagem",cTexto,".T.",".T.",.T.})
	
	If ParamBox(aPergs ,'Alteração Aviso Agendamento do Portal',aRet,,,,,,,.F.,.F.)
		cAviso := aRet[1]
		MemoWrite(cArq1, cAviso)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0055
Ler conteúdo do arquivo de aviso
@author  Jerry Junior
@since   26/11/2021
@version 1.0 
@type function
/*/
//-------------------------------------------------------------------
Static Function lerTxt(lCarrega)
	Local cArq1 := "\web\portal\faq\aviso.txt"
	Local cBuffer := ""
	Local cTexto := ""
    
    oFile := FWFileReader():New(cArq1)
    If (oFile:Open())        
        While (oFile:hasLine())
            //Le linha atual
            cBuffer := oFile:GetLine()
			cTexto += cBuffer + Iif(lCarrega, "<br>", CRLF)
        EndDo
        oFile:Close()
    EndIf
Return cTexto
