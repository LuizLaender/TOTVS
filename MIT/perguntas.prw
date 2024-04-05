//--------------------------------------------------------------------
/*/{Protheus.doc} AtuSX1

Atualização do SX1 - Perguntas

@author UPDATE gerado automaticamente
@since  05/04/2024
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtuSX1()
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

aAdd( aDados, {'ZB1MIT','01','De Funcionário?','','','MV_CH0','C',20,0,0,'G','','MV_PAR01','','','','000000','','','','','','','','','','','','','','','','','','','','','US1','','','','',''} )
aAdd( aDados, {'ZB1MIT','02','Até Funcionário?','','','MV_CH0','C',20,0,0,'G','','MV_PAR02','','','','000002','','','','','','','','','','','','','','','','','','','','','US1','','','','',''} )
aAdd( aDados, {'ZB1MIT','03','De Origem?','','','MV_CH0','C',30,0,0,'G','','MV_PAR03','','','','RN','','','','','','','','','','','','','','','','','','','','','ZB1EST','','','','',''} )
aAdd( aDados, {'ZB1MIT','04','Até Destino?','','','MV_CH0','C',30,0,0,'G','','MV_PAR04','','','','RN','','','','','','','','','','','','','','','','','','','','','ZB1EST','','','','',''} )
aAdd( aDados, {'ZB1MIT','05','Da Solicitação?','','','MV_CH0','C',9,0,0,'G','','MV_PAR05','','','','000000062','','','','','','','','','','','','','','','','','','','','','ZB1COD','','','','',''} )
aAdd( aDados, {'ZB1MIT','06','Até Solicitação?','','','MV_CH0','C',9,0,0,'G','','MV_PAR06','','','','67','','','','','','','','','','','','','','','','','','','','','ZB1COD','','','','',''} )
aAdd( aDados, {'ZB1MIT','07','A partir da Data?','','','MV_CH0','D',8,0,0,'G','','MV_PAR07','','','','20240403','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'ZB1MIT','08','Até a Data?','','','MV_CH0','D',8,0,0,'G','','MV_PAR08','','','','20240508','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'ZB1MIT','09','Imprime?','','','MV_CH0','C',20,0,1,'G','','MV_PAR09','','','','TESTE','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'ZB1MIT','10','Incluir data de pg. do Título?','','','MV_CH1','C',3,0,0,'G','','MV_PAR10','','','','NAO','','','','','','','','','','','','','','','','','','','','','','','','','',''} )


//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

// Atualiza Helps
AtuSX1Hlp()

RestArea( aAreaDic )
RestArea( aArea )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} AtuSX1Hlp

Função de processamento da gravação dos Helps de Perguntas

@author UPDATE gerado automaticamente
@since  05/04/2024
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtuSX1Hlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}


aHlpPor := {}
aAdd( aHlpPor, 'TODOS = Imprime todas PCs' )
aAdd( aHlpPor, 'APROVADOS = Imprime apenas PCs aprovados' )

PutSX1Help( "P.ZB1MIT09.", aHlpPor, {}, {}, .T.,,.T. )

aHlpPor := {}
aAdd( aHlpPor, 'SIM' )
aAdd( aHlpPor, 'ou' )
aAdd( aHlpPor, 'NAO' )

PutSX1Help( "P.ZB1MIT10.", aHlpPor, {}, {}, .T.,,.T. )

Return NIL


