#include 'protheus.ch'
#include 'restful.ch'

WSRESTFUL transferencia DESCRIPTION 'API Rest para transferencia de arquivos'
    WSMETHOD POST DESCRIPTION 'Post' WSSYNTAX '/transferencia/'
END WSRESTFUL

WSMETHOD POST WSSERVICE transferencia

    Local lRet  := .T.
    Local cJson := ::GetContent()
    Local oJson, cFile, nHandle, cBuffer

    ::SetContentType('application/json')

    oJson := JsonObject():New()
    oJson:FromJson(cJson)

    // C:\TOTVS\Protheus2310\protheus_data\temp-api
    // Detalhe: é nescessário digitar no 'body' do postman como JSON o conteudo de cada item.
    // Exemplo: {"arquivo": "nomeDoArquivoASerTransferido", "extensão": "png", "base64": "arquivoConvertidoEmBase64"}
    cFile := '\temp-api\' + oJson['arquivo'] + '.' + oJson['extensao']

    nHandle := FCreate(cFile)

    cBuffer := Decode64(oJson['base64'])

    fWrite(nHandle, cBuffer)

    fClose(nHandle)

Return lRet
