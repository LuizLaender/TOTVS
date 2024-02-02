/*/{Protheus.doc} RELAT01
@Meu primeiro relatorio
@author Luiz Lustosa
@since 01/02/2024
@version 1.0
/*/

#include "Protheus.ch"
// todos relatorios começam pelos requisitos, exemplo: 
// codigo cliente, loja, razao social, cnpj, minucipio, uf, vlr total faturado, qtde notas fiscais etc.

// Declara inicio da função
User function RELAT01()

// SELECT seleciona quais campos do protheus serão relatados .
SELECT
	ZA1_COD
	, ZA1_DESC
	, ZA1_PESO

// FROM escolhe em qual tabela(ZA1990) procurar os campos e lhe dá um apelido (ZA1).
FROM ZA1990 ZA1

// WHERE filtra as linhas que o SELECT retorna.
WHERE

// filtra os registros deletados, não os apresentando no relatório.
ZA1.D_E_L_E_T_ = ' '

// AND é ultilizado em conjunção com WHERE para indicar outras condições de filtro.
AND

// deixar o campo em branco aqui significa que o uso é compartilhado, ou seja, o SELECT vai retornar todos os campos de todas as filiais. Se tivesse preenchido com alguma filial ex: MATRIZ, retornaria apenas os campos que pertencentes a MATRIZ.
ZA1_FILIAL = ' '

