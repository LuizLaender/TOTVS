#INCLUDE 'Rwmake.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'TbIconn.ch'
#INCLUDE 'Topconn.ch'
#INCLUDE 'Parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Cadastro de Calend�rio de Disponiblidade de Recebimento do Parque
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA0054()
    Local oBrowse
    Private cString := 'Z61'
    
    u_GeraLogPrw(, 'CAEA0054', 'CAEA0054')
    //Montagem do Browse principal
    oBrowse := FWMBrowse():New()

    //Legenda
    oBrowse:AddLegend('Z61_STATUS ==  "D" ' , 'BR_VERDE'    , 'Dispon�vel'    )
    oBrowse:AddLegend('Z61_STATUS ==  "N" ' , 'BR_VERMELHO'   , 'N�o Dispon�vel' )

    //Define alias principal
    oBrowse:SetAlias('Z61')
    oBrowse:SetDescription('Calend�rio de Disponiblidade de Recebimento do Parque')
    oBrowse:SetMenuDef('CAEA0054')

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
    aAdd( aRotina, { 'Abrir Calend�rio' , 'u_CAEA054I()' , 0, 3, 0, NIL } )   
    aAdd( aRotina, { 'Alterar Status'   , 'u_CAEA054s()' , 0, 4, 0, NIL } )

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
    Local oStruZ61 := FWFormStruct(1,'Z61')

    //Cria o formulario do modelo  - GravaDados: { |oModel| fGrvDados( oModel ) }
    oModel := MPFormModel():New('CAEA054', /*bPreValidacao*/, { |oModel| fTudoOk(oModel) }, /* GravaDados */, /*bCancel*/ )

    //Cria a estrutura principal(Z61)
    oModel:addFields('MASTERZ61',,oStruZ61)

    //Adiciona a chave
    oModel:SetPrimaryKey({'Z61_FILIAL', 'Z61_CODIGO'})

    //Define a descricao dos modelos
    oModel:GetModel('MASTERZ61'):SetDescription('Calend�rio Disponibilidade')

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
    Local oStrZ61 := FWFormStruct(2, 'Z61')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField('FORM_Z61' , oStrZ61,'MASTERZ61' )

    oView:CreateHorizontalBox('SUPERIOR', 100)

    // Relaciona o ID da View com o 'box' para exibicao
    oView:SetOwnerView('FORM_Z61', 'SUPERIOR')
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fAntesTd
(PE AntesDeTudo) Fun��o para a abertura da tela.
@author  Jerry Junior
@since   14/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function fAntesTd(oModel)
Return .T.

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
Static Function fLinOk(oModel, nLin)
    Local lRet       := .T.
    Local aSaveLines := FWSaveRows()
    Default nLin     := 0

    // Sai da validacao se a linha estiver deletada
    If oModel:IsDeleted()
        Return .T.
    EndIf

    If nLin > 0
        oModel:GoLine(nLin)
    EndIf

    cCampo := oModel:GetValue('Z61_FILIAL')

    FWRestRows(aSaveLines)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Cria UI de calend�rio de disponibilidade
@author  Jerry Junior
@since   28/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA054I
    Local oDlg, oCalend
    Local nAno := 0
    Local aMeses	:= {"Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
    Local cMes 		:= ''
    Local oSay, oSay2
    Local aCalend1	:={} ,lVazio:=.F. 

    If Empty(FunName())
        PREPARE ENVIRONMENT EMPRESA '01' FILIAL 'CAEADC0001'
    EndIf  

    nAno 		        := YEAR(dDataBase)  
    cMes 		        := aMeses[Month(dDataBase)]
    Private dDate       := dDataBase, aCalend := {}, nOpc, cCalend
    PRIVATE nPrecisao   := GETMV("MV_PRECISA")
    Private c054Status  := Space(TamSX3('Z61_STATUS')[1])
    Private c640Rec     := ""
    Private c640CCusto  := ""
    Private nPosArray   := 0
    Private cTitulo     :="Calend�rio de Disponibilidade"    
    Private inclui      := altera := .F.
    Private lA640Auto   := .F.
    Private lUsrAltera := __cUserId $ superGetMv('MS_USRZ62', .F., '000734')
    //Varre a Z61 para preencher registros existentes
    C054MontArr(@aCalend)
        
    DEFINE MSDIALOG oDlg FROM  13,11 TO 200,600 TITLE "Calend�rio de Disponibilidade Recebimento" PIXEL
   
    oCalend:=MsCalend():New(010,010,oDlg)
    oCalend:ColorDay(1,CLR_HRED)
    oCalend:ColorDay(7,CLR_HRED)
    oCalend:dDiaAtu:=dDataBase

    //��������������������������������������������������������������Ŀ
    //� Monta o array do ListBox.                                    �
    //����������������������������������������������������������������
    u_C054Mont(aCalend,@aCalend1,dDataBase,oSay,,oCalend)

    /*MENU oMenu POPUP
        MENUITEM "Marcar Semana"  Action (C054RMenu(1,oCalend,@aCalend1,oLbx)) //"Marca todo o periodo"
        MENUITEM "Marcar M�s"     Action (C054RMenu(2,oCalend,@aCalend1,oLbx)) //"Desmarca todo o periodo"
	ENDMENU*/

    // Eventos
    oCalend:bChangeMes := {|| u_C054Mark(Month(oCalend:dDiaAtu),oCalend) }
    oCalend:bChange    := {|| u_C054Mont(aCalend,@aCalend1,oCalend:dDiaAtu,oSay,oLbx,oCalend)}    

    u_C054Mark(Month(oCalend:dDiaAtu),oCalend)
    oCalend:CtrlRefresh()

    @ 002,160 SAY oSay PROMPT "Data: "+ DTOC(oCalend:dDiaAtu) SIZE 50,7 OF oDlg PIXEL	//"Data: "
    @ 010,160 LISTBOX oLbx FIELDS HEADER "Status","Carga Horaria" SIZE 130,35 OF oDlg PIXEL	//"Hist�rico"###"Centro de Custos"###"Recurso"
    //tag
    @ 050,155 SAY oSay2 PROMPT "Replicar: " SIZE 50,7 OF oDlg PIXEL
    @ 060,170 BUTTON 'Semana' SIZE 30,010 PIXEL OF oDlg ACTION C054RMenu(1,oCalend,@aCalend1,oLbx)
    @ 060,210 BUTTON 'M�s'    SIZE 30,010 PIXEL OF oDlg ACTION C054RMenu(2,oCalend,@aCalend1,oLbx)    

    oLbx:SetArray(aCalend1)
    oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2]} }

    DEFINE SBUTTON			FROM 080,050  TYPE 4  ACTION (nOpc:=3,C054Proc1(@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend)) ENABLE OF oDlg PIXEL    
    DEFINE SBUTTON oBtnEdit	FROM 080,090  TYPE 11 ACTION (nOpc:=4,C054Proc1(@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend)) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON oBtnDel	FROM 080,130  TYPE 3  ACTION (nOpc:=5,C054Proc1(@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend)) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON oBtnVis	FROM 080,170  TYPE 15 ACTION (nOpc:=2,C054Proc1(@aCalend1,oLbx,oCalend:dDiaAtu,@lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend)) ENABLE OF oDlg PIXEL
    @ 080,210 BUTTON 'Fechar' SIZE 26,010 PIXEL OF oDlg ACTION oDlg:End()
    //DEFINE SBUTTON			FROM 080,210  TYPE 2  ACTION oDlg:End()ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTER ON INIT u_C054Mark(Month(dDataBase),oCalend)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Rotina de Inclus�/Altera��o do Cadastro de Exce��es do Calend�rio
@author  Jerry Junior
@since   18/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function C054Proc1(aCalend1,oLbx,dDate,lVazio,oBtnEdit,oBtnDel,oBtnVis,oCalend)
    Local i, nOpca	:= 0    
    Local lDesmarca		    := .T.
    Local cOldTitulo		:= cTitulo
    Private cCodPict, cCCPict, cCodValid, cCCValid    
    Private cDescValid, a640Calend
    Private aGet2 := Array(48), aGet1 := Array(24)
    Private cArqF3, cCampoF3
    Private Inclui := nOpc = 3
    Private Altera := nOpc = 4    
    //���������������������������������������������������������������������Ŀ
    //� Opcoes de nOpc:= 0-Abandona 2-Visualiza 3-Inclui 4-Altera 5-Exclui  �
    //�����������������������������������������������������������������������
    //Se nOpc for diferente de 3-Inclus�o e aCalend vazio - listbox com status do dia
    If nOpc # 3 .And. aCalend1[1][3] == 0        
        Return Nil        
    EndIf

    //Se for inclus�o e dia selecionado for s�bado ou domingo
    If nOpc == 3 .And. Dow(dDate) == 1 .Or. Dow(dDate) == 7
        Return Nil
    EndIf

    If oCalend:dDiaAtu < dDataBase
        Alert('N�o permitido esta a��o para dias anteriores a data  atual')
        Return Nil
    EndIf

    If !lUsrAltera .And. cValToChar(nOpc) $ '3,4,5' .And. (DateDiffDay(oCalend:dDiaAtu,dDatabase) < 2 .Or. oCalend:dDiaAtu < dDataBase)
        Alert('N�o permitido esta a��o para dias anteriores a data ' + DtoC(DaySum(dDataBase,Iif(Dow(dDataBase)>4,Iif(Dow(dDataBase)==5,4,3),2))))
        Return Nil
    EndIf

    If nOpc = 2
        cTitulo:=cTitulo+" - Visualiza��o"
    ElseIf nOpc = 3
        cTitulo:=cTitulo+" - Inclus�o"	
    ElseIf nOpc = 4
        cTitulo:=cTitulo+" - Altera��o"
        
    ElseIf nOpc = 5
        cTitulo:=cTitulo+" - Exclus�o"
        
    EndIf   
    
    cTitulo += " - Dia " + Dtoc(oCalend:dDiaAtu) //" - Dia "
    
    //��������������������������������������������������������������Ŀ
    //� Recupera o desenho padrao de atualizacoes no DOS e desenha   �
    //� janelas no WINDOWS.                                          �
    //����������������������������������������������������������������

    nOpca    := 0
    oGetHR   := nil
    cCargaHR := "00:00"
    Private aCombo := {'D=Disponivel','N=Nao Disponivel'}
    If nOpc == 3
        cCalend := "                                xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                            "
        //Carrega carga horaria no label cCargaHR
        u_C054Time(cCalend,@cCargaHR)
        If (Valtype(aCalend) == "A")
            Z61->(dbSetOrder(2))
            If Z61->(dbSeek(xFilial('Z61')+Dtos(dDate)))
                Alert("J� existe carga hor�rio neste dia, use a op��o 'Editar'.")
                Return Nil
            EndIf
        EndIf
    Else
        nPosArray   := aCalend1[oLbx:nAt,3]
        c054Status  := aCalend[nPosArray][4]   
        cCalend     := Bin2Str(aCalend[nPosArray][3])
        If nOpc == 5
            //aArrHora := AEval(aAux,{|aAux| aAux := substr(aAux,At('=',aAux)+1)})
            Z62->(dbSetOrder(3))
            If Z62->(dbSeek(xFilial('Z62')+DtoS(dDate)))
               Alert("Exclus�o n�o permitida, pois j� existe agendamento nesta data.")
               Return NIL
            EndIf
        EndIf      
        //Carrega carga horaria no label cCargaHR
        u_C054Time(cCalend,@cCargaHR)
    EndIf

    DEFINE MSDIALOG oDlg FROM  13,11 TO 400,590 TITLE cTitulo PIXEL

    @ 005,003 SAY "Disponibilidade" SIZE 030,008 OF oDlg PIXEL  //

    @ 174,003 SAY "Carga Hor�ria" SIZE 047,008 OF oDlg PIXEL  //"Carga Hor�ria"
    
    @ 005,070 COMBOBOX c054Status ITEMS aCombo SIZE 050,008 OF oDlg PIXEL WHEN (nOpc = 3 .Or. nOpc = 4)

    @ 174,055 MSGET oGetHR VAR cCargaHR SIZE 030,008 OF oDlg PIXEL WHEN .F.

    @ 04,34 WORKTIME oWorkTime SIZE 280,133 RESOLUTION nPrecisao VALUE cCalend;
        WHEN (Inclui .or. Altera) On Change {|oWorkTime| u_C054Time(oWorkTime:GetValue(),@cCargaHR,@oGetHR)}

    DEFINE SBUTTON FROM 174,179 TYPE 1 ACTION { || 	(cCalend := oWorkTime:GetValue(),nOpca:=1,Iif(verificaCH(oCalend,cCalend),oDlg:End(),.F.)) } ENABLE
    // Verifico novamente pois mesmo o retorno do campo centro de custo sendo invalido
    // o foco vai para o objeto oWorkTime
    DEFINE SBUTTON FROM 174,206 TYPE 2 ACTION { || nOpca:=2, oDlg:End() } ENABLE
    ACTIVATE MSDIALOG oDlg CENTERED
        
    If nOpca = 1 .And. (nOpc = 3 .Or. nOpc = 4)
        u_C054Grav(nOpc,@aCalend1,dDate,oCalend)
    ElseIf nOpca = 1 .And. nOpc = 5
        Z62->(dbSetOrder(3))
        If Z62->(dbSeek(xFilial('Z62')+DtoS(aCalend[nPosArray][1])))
            Alert("Exclus�o n�o permitida, pois j� existe agendamento nesta data.")
            Return NIL
        EndIf
        Z61->(dbSetOrder(2))
        lAchou := Z61->(dbSeek(xFilial('Z61')+Dtos(aCalend[nPosArray][1])))
        If !lAchou
            Return NIL
        EndIf
        RecLock("Z61",.F.,.T.)
        Z61->(dbDelete())
        Z61->(MsUnLock())
        
        ADel(aCalend,nPosArray)
        //ADel(aCalend1,oLbx:nAt)
        ASize(aCalend,Len(aCalend)-1)
        aCalend1[1,1] := 'N�o Definido'
        aCalend1[1,2] := '00:00'
        aCalend1[1,3] := 0
        //ASize(aCalend1,Len(aCalend1)-1)
        //��������������������������������������������������������������Ŀ
        //� Verifica se dia deve ser desmarcado                          �
        //����������������������������������������������������������������
        For i:= 1 to Len(aCalend)
            If aCalend[i,1] == dDate
                lDesmarca:=.F.
            EndIf
        Next i
        If lDesmarca
            oCalend:DelRestri(Day(dDate))
            oCalend:Refresh()
        EndIf

    EndIf

    cTitulo:=cOldTitulo
    oLbx:Refresh()
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Fun��o para gravar altera��o na tabela
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function C054Grav(nOpc,aCalend1,dDate,oCalend)
    Local nAcho
        
    If nOpc == 4
        Z61->(dbSetOrder(2))
        Z61->(dbSeek(xFilial('Z61')+Dtos(aCalend[nPosArray][1])))
        If !Z61->(Found())
            Return NIL
        EndIf        
    EndIf

    RecLock("Z61",nOpc==3)
        Z61->Z61_FILIAL  := xFilial("Z61")
        Z61->Z61_CODIGO  := Iif(nOpc==3,CriaVar('Z61_CODIGO'),Z61->Z61_CODIGO)
        Z61->Z61_DATA    := dDate
        Z61->Z61_HORA    := cCargaHR
        Z61->Z61_ALOC    := Str2Bin(cCalend)
        Z61->Z61_STATUS  := c054Status        
    Z61->(MsUnLock())
    ConfirmSx8()
    If nOpc == 3
        aAdd(aCalend,{;
            Z61->Z61_DATA,;
            Z61->Z61_HORA,;
            Z61->Z61_ALOC,;
            Z61->Z61_STATUS;
        })
    
        nAcho:=ASCAN(aCalend1,{|x| x[3] = 0})
        If nAcho = 0
            aAdd(aCalend1,{;
                Iif(Z61->Z61_STATUS=='D','Dispon�vel','N�o Dispon�vel'),;
                Z61->Z61_HORA,;
                Len(aCalend);
            })
        Else
            aCalend1[nAcho][1]:=Iif(Z61->Z61_STATUS=='D','Dispon�vel','N�o Dispon�vel')
            aCalend1[nAcho][2]:=Z61->Z61_HORA
            aCalend1[nAcho][3]:=Len(aCalend)
        EndIf        
    
    ElseIf nOpc == 4
        aCalend[nPosArray][1] := Z61->Z61_DATA
        aCalend[nPosArray][2] := Z61->Z61_HORA
        aCalend[nPosArray][3] := Z61->Z61_ALOC
        aCalend[nPosArray][4] := Z61->Z61_STATUS
        
        aCalend1[oLbx:nAt][1] := Iif(Z61->Z61_STATUS=='D','Dispon�vel','N�o Dispon�vel')
        aCalend1[oLbx:nAt][2] := Z61->Z61_HORA
    EndIf
        
    oLbx:SetArray(aCalend1)
    oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2]} }
    oLbx:Refresh()
    
    //��������������������������������������������������������������Ŀ
    //� Verifica se dia deve ser marcado                             �
    //����������������������������������������������������������������
    oCalend:AddRestri(Day(dDate),CLR_BLACK,Iif(Z61->Z61_STATUS=='D',CLR_GREEN,CLR_HRED))

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Fun��o de remontagem do listbox qdo altera data
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function C054Mont(aCalend,aCalend1,dDia,oSay,oLbx,oCalend)
    Local i:=0
    Local cStrDisp := ''
    aCalend1:={}
    //��������������������������������������������������������������Ŀ
    //� Monta o array do ListBox.                                    �
    //����������������������������������������������������������������
    For i:= 1 to Len(aCalend)
        If aCalend[i,1] == dDia
            cStrDisp := Iif(aCalend[i,4]=='D','Dispon�vel','N�o Dispon�vel')            
            cHora    := aCalend[i,2]
            AADD(aCalend1,{cStrDisp,cHora,i})
            oCalend:AddRestri(Day(dDia),CLR_BLACK,Iif(aCalend[i,4]=='D',CLR_GREEN,CLR_HRED))
        EndIf
    Next i    

    If Empty(aCalend1)
        lVazio:=.T.
        AADD(aCalend1,{'N�o Definido','00:00',0})
    EndIf
    //��������������������������������������������������������������Ŀ
    //� Muda a data do Say                                           �
    //����������������������������������������������������������������
    If oSay != NIL
        oSay:Refresh()
    EndIf
    //��������������������������������������������������������������Ŀ
    //� Monta o objeto do ListBox corretamente                       �
    //����������������������������������������������������������������
    If oLbx != NIL
        oLbx:SetArray(aCalend1)
        oLbx:bLine := { || {aCalend1[oLbx:nAt,1],aCalend1[oLbx:nAt,2]} }
        oLbx:Refresh()
    EndIf        

    dDate := dDia 
    oCalend:CtrlRefresh()   

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Fun��o que marca/desmarca restricoes no calendario
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function C054Mark(nMes,oCalend)
    Local i := 0
    //��������������������������������������������������������������Ŀ
    //� Monta o array do ListBox.                                    �
    //����������������������������������������������������������������
    For i:= 1 to Len(aCalend)
        If Month(aCalend[i,1]) == nMes
            oCalend:AddRestri(Day(aCalend[i,1]),CLR_BLACK,Iif(aCalend[i,4]=='D',CLR_GREEN,CLR_HRED))            
        EndIf
    Next i
    oCalend:CtrlRefresh()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Fun��o que busca registros existentes para ja preencher array aCalend
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function C054MontArr(aCalend)

    Z61->(dbSetOrder(2))
	Z61->(dbGotop())
	If Z61->(!Eof())		
		While Z61->(!Eof())
			aAdd(aCalend,{;
                Z61->Z61_DATA,;
                Z61->Z61_HORA,;
                Z61->Z61_ALOC,;
                Z61->Z61_STATUS;
            })
			Z61->(dbSkip())
		EndDo		
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} C054Time
Fun��o que preenche a Carga Horaria de acordo com o Calend. 
Fonte base: MATA640
@author  Jerry Junior
@since   19/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function C054Time(cCalend,cCargaHR,oGetHR)
    
    Local cHoras, cMinutos
    Local nMarca := 0
    Local nX     := 0

    For nx:=1 to Len(cCalend)
        If !Empty(Subs(cCalend,nx,1))
            nMarca += 1
        EndIf
    Next nx

    cHoras   := StrZero(Int(nMarca / nPrecisao) ,2)
    cMinutos := StrZero( (60 / nPrecisao) * ( ( (nMarca / nPrecisao) - Int(nMarca / nPrecisao) ) * nPrecisao ) , 2 )
    cCargaHR := cHoras + ":" + cMinutos

    If oGetHR != NIL
        oGetHR:Refresh()
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Valida se pode ser inclu�do/alterado carga horario
Seguindo a regra de ter selecionado ao menos 4 per�odos seguidos = 1h
@author  Jerry Junior
@since   20/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function verificaCH(oCalend,cCalend)
    Local nMarca := 0
    Local lMarca := .T.
    Local i,nX := 0    
    Local cMsg := Iif(nOpc==3,"Para inclus�o, marque no m�nimo 1h corrida.","Voc� tem per�odo menor que 1h corrida, por favor corrija.")
    Local aHrAgend := {}
    //se for exclus�o, nao precisa validar.
    If nOpc == 5
        Return .T.
    EndIf
    //se for inclusao, com status 'N' nao precisa validar.
    If Empty(cCalend) .And. c054Status == 'N' .And. nOpc == 3
        Return .T.
    EndIf

    //Separa as horas em que h� agendamento marcado nessa data
    Z62->(dbSetOrder(3))
    If Z62->(dbSeek(cSeekZ62 := xFilial('Z62')+DtoS(oCalend:dDiaAtu)))
        //se tiver agendamento na data e status 'N', n�o permite alterar.
        If c054Status == 'N' .And. nOpc == 4
            Alert("Altera��o n�o permitida, pois j� existe agendamento nesta data.")
            Return .F.
        EndIf

        While Z62->(!Eof()) .And. cSeekZ62 == Z62->Z62_FILIAL+DtoS(Z62->Z62_DATA)
            aAdd(aHrAgend,Left(Z62->Z62_HORA,2))
            Z62->(dbSkip())
        EndDo
        //Alert("Altera��o n�o permitida, pois j� existe agendamento nesta data.")
        //Return .F.
    ElseIf !lUsrAltera .And. oCalend:dDiaAtu == dDataBase
        Alert("Altera��o n�o permitida, s� � permitido alterar disponibilidade do dia seguinte em diante.")
        Return .F.
    EndIf        

    If At('X',upper(cCalend)) <= 31 .Or. RAt('X',upper(cCalend)) > 68
        Alert('S� � permitido incluir per�odo de 08:00 �s 17:00.')
        Return .F.
    EndIf
    For nx:=1 to Len(cCalend)
        If !Empty(Subs(cCalend,nx,1))            
            If ((nx-1) % 4) > 0 .And. nMarca == 0
                Alert('N�o � permitido hor�rios fracionados para esta opera��o. Selecione per�odos fechados de hora em hora.')
            Return .F.
        EndIf    
            //Enquanto estiver marcado, conta+1 e marca flag lMarca
            nMarca += 1 
            lMarca := .T.           
        Else
            If (nMarca > 4 .And. (nMarca % 4) > 0)
                Alert('N�o � permitido hor�rios fracionados para esta opera��o. Selecione per�odos fechados de hora em hora.')
                Return .F.
            EndIf
            //Se estiver desmarcado e ja tiver contado pelo menos 4 periodos
            //Zera contador e desmarca flag lMarca
            If nMarca > 3
                nMarca := 0
            EndIf
            lMarca := .F.
        EndIf

        //Se contador for entre 1 e 3 e tiver sido desmarcado
        //Mostra alerta e n�o deixa salvar
        If nMarca > 0 .And. nMarca < 4 .And. !lMarca .And. c054Status == 'D'
            Alert(cMsg)
            Return .F.
        EndIf
    Next nx

    If nOpc == 4
        //Separa em horas o que foi modificado
        aHoraMod := U_CAEA055X(Str2Bin(cCalend))[2]
        For i:=1 to Len(aHoraMod)
            aHoraMod[i] := substr(aHoraMod[i],At('=',aHoraMod[i])+1,2)
        Next
        
        //Verifica se foi alterado alguma hora que ja tenha sido realizado o agendamento
        If Len(aHoraMod) < 1
            Alert("Voc� n�o pode alterar um hor�rio em qua j� tenha agendamento. Hor�rio - " + aHrAgend[i] + ":00")
            Return .F.
        EndIf        
        For i:=1 to Len(aHrAgend)
            nAchou := aScan(aHoraMod,{|x| x = aHrAgend[i]})
            If nAchou < 1 
                Alert("Voc� n�o pode alterar um hor�rio em qua j� tenha agendamento. Hor�rio - " + aHrAgend[i] + ":00")
                Return .F.                
            EndIf
        Next
    EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} CAEA0054
Alterar Status de Disponibilidade de Recebimento do dia posicionado
@author  Jerry Junior
@since   20/03/2019
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function CAEA054s
    Local aPergs := {}
    Local aRet   := {}
    Local aStatus := {"D=Dispon�vel","N=N�o Dispon�vel"}
    Z62->(dbSetOrder(3))
    If Z62->(dbSeek(xFilial('Z62')+DtoS(Z61->Z61_DATA)))
        Alert("Altera��o n�o permitida, pois j� existe agendamento nesta data.")
        Return
    EndIf

    aAdd(aPergs, {2,"Status",aStatus[Iif(Z61->Z61_STATUS=='D',1,2)],aStatus,70 ,'.T.',.T.})
	If ParamBox(aPergs ,"Novo Status",aRet,,,,,,,.F.,.F.)
        RecLock('Z61', .F.)
            Z61->Z61_STATUS := aRet[1]
        Z61->(MsUnLock())
    EndIf
Return


Static Function C054RMenu(nOp,oCalend, aCalend1,oLbx)
    Local dDiaAtu   := oCalend:dDiaAtu
    Local nPosArray := Iif(aCalend1<>NIL,aCalend1[1,3],0)
    Local dDiaIni   := Iif(nOp==1,DaySub(dDiaAtu,Dow(dDiaAtu)-1),FirstDate(dDiaAtu))
    Local cHora     := Iif(nPosArray>0,aCalend[nPosArray,2],'')
    Local cAloc     := Iif(nPosArray>0,aCalend[nPosArray,3],'')
    Local cStatus   := Iif(nPosArray>0,aCalend[nPosArray,4],'')
    Local i, nOpc   := 3
    Local nInicio   := Iif(nOp==1,1,Day(FirstDate(dDiaAtu)))
    Local nLimite   := Iif(nOp==1,7,Last_Day(dDiaAtu))//7 para semana, Ultimo dia do m�s, para replica��o no m�s
    Local aErro     := {}
    Local cMsgErro  := ''
    Local cPerg     := 'Deseja replicar esses dados ' + Iif(nOp==1,'na semana','no m�s') + ' ?'
    
    If !MsgYesNo(cPerg)
        Return Nil
    EndIf

    If nPosArray <= 0
        Alert("Defina disponibilidade do dia que deseja replicar.")
        Return Nil
    EndIf
        

    If dDiaAtu > dDataBase .And. Month(dDiaAtu) > Month(dDataBase)
        nInicio := 1        
        If nOp == 1
            //Pega primeiro dia do mes se replica��o semanal
            //for em uma semana quebrada que poder� pegar 
            //dia do mes anterior, se n�o pega primeiro dia da semana
            If DateDiffDay(dDiaAtu,dDataBase) < 2
                Alert('Somente � poss�vel ' + Iif(nOpc==3,'cadastrar','alterar') + ' disponibilidade de recebimento a partir de dois dias �teis a contar da data atual.')
                Return Nil
            EndIf
            dDiaIni := DaySub(dDiaAtu,Dow(dDiaAtu)-2)
            dDiaIni := Iif(Month(dDiaIni)<Month(dDiaAtu),FirstDate(dDiaAtu),dDiaIni)

        Else
            //se for replica��o mensal - pega primeiro dia do mes
            dDiaIni := FirstDate(dDiaAtu)
        EndIf 
    ElseIf dDiaAtu < dDataBase
        Alert('N�o permitido esta a��o para dias anteriores ou igual a data atual.')
        Return Nil
    EndIf

    For i := nInicio to nLimite
        
        If Month(dDiaIni) > Month(dDiaAtu)
            Exit
        EndIf
        //Verifica se usuario escolheu uma data pra frente, pois 
        //enquanto data loop for menor que data do sitema, n�o ir� fazer nada
        If dDiaIni <= DaySum(dDataBase,1)
            dDiaIni := DaySum(dDiaIni,1)            
            Loop
        EndIf

        nPosArray := aScan(aCalend,{|x| x[1] = dDiaIni})        
        //Sabado ou domingo, passa loop
        If Dow(dDiaIni)==1 .Or. Dow(dDiaIni)==7
            dDiaIni := DaySum(dDiaIni,1)            
            Loop
        EndIf
        //Se data j� possuir agendamento, n�o realiza altera��o
        Z62->(dbSetOrder(3))
        If Z62->(dbSeek(xFilial('Z62')+DtoS(dDiaIni)))
            aAdd(aErro,DtoC(Z62->Z62_DATA))
            dDiaIni := DaySum(dDiaIni,1)            
            Loop
        EndIf
        //Se existir registro, ira alterar, se nao, incluir
        Z61->(dbSetOrder(2))
        Z61->(dbSeek(xFilial('Z61')+Dtos(dDiaIni)))
        If Z61->(Found())
            nOpc := 4
        Else 
            nOpc := 3
        EndIf	        

        RecLock("Z61",nOpc==3)
            Z61->Z61_FILIAL  := xFilial("Z61")
            Z61->Z61_CODIGO  := Iif(nOpc==3,CriaVar('Z61_CODIGO'),Z61->Z61_CODIGO)
            Z61->Z61_DATA    := dDiaIni
            Z61->Z61_HORA    := cHora
            Z61->Z61_ALOC    := cAloc
            Z61->Z61_STATUS  := cStatus
        Z61->(MsUnLock())
        ConfirmSx8()
        If nOpc == 3
            aAdd(aCalend,{;
                dDiaIni,;
                Z61->Z61_HORA,;
                Z61->Z61_ALOC,;
                Z61->Z61_STATUS;
            })
            nPosArray := Len(aCalend)
        ElseIf nOpc == 4
            aCalend[nPosArray][1] := dDiaIni
            aCalend[nPosArray][2] := Z61->Z61_HORA
            aCalend[nPosArray][3] := Z61->Z61_ALOC
            aCalend[nPosArray][4] := Z61->Z61_STATUS      
        EndIf
        oCalend:AddRestri(Day(dDiaIni),CLR_BLACK,Iif(aCalend[nPosArray,4]=='D',CLR_GREEN,CLR_HRED))
        dDiaIni := DaySum(dDiaIni,1)        
        aSort(aCalend, , , {|x,y| x[1] < y[1]})
    Next
    //Trata array com as datas que n�o podem ser alteradas
    If Len(aErro) > 0
        For i:=1 to Len(aErro)            
            cMsgErro += aErro[i]
            cMsgErro += Iif(i==Len(aErro),'',',')
        Next
        Alert('N�o houve altera��o na(s) data(s) ' + cMsgErro + ' , pois j� existe agendamento marcado.')
    EndIf
    //monta restri��o em cada dia no calendario
    u_C054Mont(aCalend,@aCalend1,dDiaAtu,,oLbx,oCalend)
    oCalend:CtrlRefresh() //refresh no componente
Return
