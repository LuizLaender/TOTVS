#Include "totvs.ch"
#Include "protheus.ch"

Function U_RELAT_SEM_QUERY_TEXTO

    Local cSaveFile as character    // Local de armazenamento do arquivo.
    Local cBuffer   as character    // Contém o conteúdo que será escrito.
    Local nBuffer   as numeric      // Possui a quantidade de caracteres a serem escritos.
    Local nHandle   as numeric      // Representa em qual arquivo será escrito o relatório.
    Local nWrite    as numeric      // 

    // rpcSetEnv()   = Inicializa o ambiente.
    // File()        = Verifica se o arquivo existe.
    // fErase()      = Deleta o arquivo.
    // fCreate()     = Cria o arquivo.
    // fAlertError() = Exibe janela de erro.
    // rpcClearEnv() = Libera o ambiente aberto.
    // padr()        = Manipula caracteres à direita.
    // len()         = Conta quantos caracteres.
    // fWrite()      = Escreve os dados desejados no arquivo (Retorna quantos caracteres serão escritos).
    // fClose()      = Encerra a gravação do arquivo.
    // space()       = Retorna string com uma quantidade especificada de espaços.
    // strtran()     = Pesquisa e substitui caracteres em uma string.

    //rpcSetEnv('99','0101') // Define qual licensa Protheus será consumida.

    cSaveFile   := 'C:\VSCodeWorkspace\ADVPL_Course\FCreate.txt' // Define o local de criação do arquivo.

    If File(cSaveFile) // Verifica se o arquivo existe.
        fErase(cSaveFile) // Se existe, o deleta.
    EndIf

    nHandle     := fCreate(cSaveFile) // Variável de controle, que representa em qual arquivo será escrito.

    If nHandle > 0 // fCreate retorna um numero := nHandle, se o mesmo for > 0 = erro.
        fwAlertError("Erro ao efetuar a criação do arquivo. Código do erro: " + Str(fError(),4), "ERRO")
        rpcClearEnv() // Libera licensa Protheus.
        Return .F. // Retorna falso para a user function, já que o programa não funcionou corretamente.
    EndIf

    cBuffer     := padr("CODIGO",10) + "- " + padr("NOME",10) + padr("IDADE",10) // Recebe a estrutura do cabeçalho.
    nBuffer     := len(cBuffer) // Recebe a quantidade de caracteres em cBuffer.
    nWrite      := fWrite(nHandle,cBuffer) // Recebe a quantidades de caracteres em fWrite.

    If nWrite <> nBuffer // Se a escrita(nWrite) de caracteres for diferente do desejado(nBuffer), ocorreu algum erro.
        fwAlertError("Erro ao efetuar a gravação do arquivo. Código do erro: " + Str(fError(),4), "ERRO")
        fClose(nHandle()) // Encerra a gravação do arquivo.
        rpcClearEnv() // Libera licensa Protheus.
        Return .F. // Retorna falso para a user function, já que o programa não funcionou corretamente.
    EndIf

    cBuffer     := CRLF + strtran(space(40)," ", "-") // Exibe na tela uma série de hífens logo após a primeira linha.
    nBuffer     := len(cBuffer) // Recebe a quantidade de caracteres em cBuffer.
    nWrite      := fWrite(nHandle,cBuffer) // Recebe a quantidades de caracteres em fWrite.

    If nWrite <> nBuffer // Se a escrita(nWrite) de caracteres for diferente do desejado(nBuffer), ocorreu algum erro.
        fwAlertError("Erro ao efetuar a gravação do arquivo. Código do erro: " + Str(fError(),4), "ERRO")
        fClose(nHandle()) // Encerra a gravação do arquivo.
        rpcClearEnv() // Libera licensa Protheus.
        Return .F. // Retorna falso para a user function, já que o programa não funcionou corretamente.
    EndIf

    fClose(nHandle())

    //rpcClearEnv() // Libera licensa Protheus.

Return
