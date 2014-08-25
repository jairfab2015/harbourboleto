/*
 * $Id$
*/
 /*
 * Copyright 2006 Mario Simoes Filho mario@argoninformatica.com.br for original oboleto.prg
 * Copyright 2006 Marcelo Sturm <marcelo.sturm@gmail.com> for modifications in the original project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however inVALidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "harbourboleto.ch"
#include "hbclass.ch"

#Translate StoD(<p>) => CTOD(RIGHT(<p>, 2) + "/" + SUBSTR(<p>, 5, 2) + "/" + LEFT(<p>, 4))

#DEFINE dDataBase CTOD("07/10/1997")

CLASS oBoleto

DATA Modelo          INIT ""
DATA AuxModelo       INIT "" // Se Necessario, Auxiliar no Controle de Modelo do Boleto
DATA Bolhtm          INIT ""
DATA Destino         INIT ""
DATA nHandle         INIT 0   PROTECTED  // link - Arquivo do boleto (FCREATE)
DATA NomeHtm         INIT ""
DATA HtmEdit         INIT getenv("ProgramFiles") // o Win 98 nao tem esta variavel !!!
DATA cImageLnk       INIT ""  // Funcao ::merge troca a variavel pelo diretorio no bol.htm
DATA lPreview        INIT .T.
DATA lAnsi           INIT .T.
DATA lBoleto         INIT .T.
DATA lRemessa        INIT .T.
DATA oRem            INIT ""

DATA cLocalPgto      INIT ""
DATA Cedente         INIT ""
DATA CedenteCNPJ     INIT ""

DATA Avalista        INIT ""
DATA cAvalCodBco     INIT ""
DATA cAvalNumAgencia INIT ""
DATA cAvalNumCC      INIT ""
DATA cAvalDvAgencia  INIT ""
DATA cAvalDvCC       INIT ""

//DATA cNumCli         INIT ""  // Numero do cliente no Cód. Barras - 409-Unibanco Cob. Especial (6 posiçoes + DV)
//DATA cNumRefCli      INIT ""  // Numero de Referência Cliente     - 409-Unibanco Cob. Especial (15 posicoes)

DATA SACADO          INIT ""
DATA ENDERECO        INIT ""
DATA COMPLEMENTO     INIT ""
DATA BAIRRO          INIT ""
DATA CIDADE          INIT ""
DATA ESTADO          INIT ""
DATA ENDERECO1       INIT ""  READONLY
DATA ENDERECO2       INIT ""  READONLY
DATA CEP             INIT ""

DATA CNPJ            INIT ""
DATA cCNPJ           INIT ""  READONLY
DATA cCPF            INIT ""  READONLY
DATA TpCarteira      INIT ""  READONLY
DATA EspecieTit      INIT "01"
DATA cTipoCob        INIT ""
DATA ACEITE          INIT "N"
DATA INSTRUCOES      INIT ""
DATA INSTRUCOES2     INIT ""
DATA DtVenc          INIT CTOD("")
DATA DtEmis          INIT DATE()
DATA cCodBco         INIT ""
DATA cDvBco          INIT ""     // Digito Verificador - Banco
DATA cNomeBco        INIT ""
DATA cNumAgencia     INIT ""
DATA cDvAgencia      INIT ""     // Digito Verificador - Agencia
DATA cNumCC          INIT ""
DATA cDvCC           INIT ""     // Digito Verificador - Conta Corrente
DATA cDvAgCC         INIT ""     // Digito Verificador - Agência/Conta Corrente
DATA cCarteira       INIT "6"
DATA cNossoNumero    INIT ""
DATA cNumDoc         INIT ""
DATA cTipoMoeda      INIT "9"
DATA cCDPF           INIT "0"           // Codigo Cedente/Prefixo utilizado por alguns Bancos para identificar o Cliente BB,Unibanco,Bradesco
DATA cDvCDPF         INIT ""            // Digito Verificador do CDPF, usado pela Caixa //*FJF* - 28/09/09
DATA cDGNN           INIT ""
DATA nDiasProt       INIT 0             // Numero de dias p/ protesto
DATA nValor          INIT 0
DATA nMulta          INIT 0             // % Multa - em caso de atraso. No boleto, é mostrado como Valor
DATA nMora           INIT 0             // % Mora diária a ser cobrado por dia de atraso
DATA nDescDia        INIT 0             // % Desconto Diário (pagamento antes do vencimento)
DATA nValMulta       INIT 0  READONLY   // Valor - Multa - em caso de atraso. No boleto, é mostrado como Valor
DATA nValMora        INIT 0  READONLY   // Valor - Mora diária a ser cobrado por dia de atraso
DATA nValDescDia     INIT 0  READONLY   // Valor - Desconto Diário (pagamento antes do vencimento)

DATA nBoletos        INIT 0  READONLY   // Numero de Boletos Impressos
DATA nBolsPag        INIT 1             // Numero de Boletos por Pagina

METHOD New( cBco, cLocalPg ) CONSTRUCTOR
METHOD Open( cArq, cPasta, cArqRem, cPastaRem, nNumRemessa, CNAB400 )
METHOD Close( )
METHOD ERASE()
METHOD Merge( cCampo, cConteudo, lTudo )
METHOD Execute( )
METHOD Remessa( lAdd, cArqRem, cPastaRem, nNumRemessa, CNAB400 )
METHOD Print( lPreview, lPromptPrint, cPrinter )
METHOD Eject( )
METHOD isRegistrada( )
METHOD SetNomeRem( cArq )
ENDCLASS

/* -------------------------------------------------------------------------- */

METHOD new( cBco, cLocalPg ) CLASS oBoleto

   LOCAL lFem := .F.
   DEFAULT cBco TO "237"

   #ifndef __PLATFORM__Linux
      IF EMPTY(::HtmEdit)
         ::HtmEdit := "C:\Arquivos de programas" // se algum cliente tiver Windows em ingles ...
      ENDIF
      ::HtmEdit += "\Internet Explorer\iexplore.exe"
   #endif

   DO CASE
      CASE cBco == "001"
         ::cDvBco := "9"
         ::cNomeBco := "Banco do Brasil"
           DEFAULT cLocalPg TO "Pagável em Qualquer Banco Até o Vencimento"
      CASE cBco == "070"  // Colaboracao de Taibnis Vieira <tbnvieira@uol.com.br>
         ::cDvBco := "1"
         ::cNomeBco := "Banco do Brasilia"
      CASE cBco == "008"
         ::cDvBco := "6"
         ::cNomeBco := "Santander Meridional"
      CASE cBco == "033"
         ::cDvBco := "7"
         ::cNomeBco := "Santander Banespa"
      CASE cBco == "104"
         ::cDvBco := "0"
         ::cNomeBco := "Caixa"
         //::lRemessa := .F. // Implementado 30/10/09 ( Padrao SIGCB Caixa ), by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09
         lFem := .T.
         //DEFAULT cLocalPg TO "PREFERENCIALMENTE NAS CASAS LOTÉRICAS E AGÊNCIAS DA CAIXA"
         DEFAULT cLocalPg TO "CASAS LOTÉRICAS, AGÊNCIAS DA CAIXA E REDE BANCÁRIA, APÓS VENC. SOMENTE NA CAIXA"
      CASE cBco == "237"
         ::cDvBco := "2"
         ::cNomeBco := "Bradesco"
      CASE cBco == "244"
         ::cDvBco := "5"
         ::cNomeBco := "Cidade"
         ::lRemessa := .F. // falta implementar no oRemessa
      CASE cBco == "341"
         ::cDvBco := "7"
         ::cNomeBco := "Itau" + __ANSI
      CASE cBco == "353"
         ::cDvBco := "0"
         ::cNomeBco := "Santander"
      CASE cBco == "356"
         ::cDvBco := "5"
         ::cNomeBco := "Real"
      CASE cBco == "399"
         ::cDvBco := "9"
         ::cNomeBco := "HSBC"
      CASE cBco == "409"
         ::cDvBco := "0"
         ::cNomeBco := "Unibanco"
      CASE cBco == "422"
         ::cDvBco := "7"
         ::cNomeBco := "Safra"
         ::EspecieTit:="DS"
      CASE cBco == "739"
         ::cDvBco := "7"
         ::cNomeBco := "Banco BGN"
   ENDCASE

   DEFAULT cLocalPg TO "Até o vencimento, pagável em qualquer banco. Após o vencimento, em qualquer"+;
           " agência d"+IIF(lFem,"a","o")+" "+::cNomeBco+;
           IIF(cBco == "237"," ou Banco Postal","")+"."+__ANSI

   ::cLocalPgto := cLocalPg
   ::cCodBco    := cBco

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Open( cArq, cPasta, cArqRem, cPastaRem, nNumRemessa, CNAB400  ) CLASS oBoleto

   LOCAL nAux

   DEFAULT cArq      TO "BOL" + SUBSTR(Time(), 4, 2) + SUBSTR(Time(), 7, 2),;
           cPasta    TO LEFT(hb_cmdargargv(), RAT(HB_OSpathseparator(), hb_cmdargargv())),;
           cPastaRem TO cPasta,;
           CNAB400   TO .T.

   IF EMPTY(::Destino)
      cPasta := ALLTRIM(cPasta)
      IF RIGHT(cPasta, 1) != HB_OSpathseparator()
         cPasta += HB_OSpathseparator()
      ENDIF
      ::Destino := cPasta + "boleto" + HB_OSpathseparator()
   ENDIF
   IF EMPTY(::NomeHtm)
      ::NomeHtm := cArq
   ENDIF
   IF !("htm" $ LOWER(RIGHT(::NomeHtm, 4)))
      ::NomeHtm += ".htm"
   ENDIF

   //IF EMPTY(::cDvBco) .OR. !FILE(::Destino + "logo" + ::cCodBco + ".gif")

   IF EMPTY(::cDvBco) // Isto e suficiente. No meu caso, os gifs estao hospedados na web.
      ::lBoleto := .F.
   ENDIF

   nAux := AT("-", ::cNumCC)
   IF nAux > 0 .AND. EMPTY(::cDVCC)
      ::cDVCC  := TRIM(SUBSTR(::cNumCC, nAux + 1))            // Digito da conta
      ::cNumCC := LEFT(::cNumCC, nAux - 1)                    // Numero da conta
   ENDIF
   nAux := AT("-", ::cNumAgencia)
   IF nAux > 0 .AND. EMPTY(::cDVAgencia)
      ::cDVAgencia  := TRIM(SUBSTR(::cNumAgencia, nAux + 1))  // Digito da Agencia
      ::cNumAgencia := LEFT(::cNumAgencia, nAux - 1)          // Numero da Agencia
   ENDIF

   IF !EMPTY(::cAvalCodBco)
      nAux := AT("-", ::cAvalNumCC)
      IF nAux > 0 .AND. EMPTY(::cAvalDVCC)
         ::cAvalDVCC  := TRIM(SUBSTR(::cAvalNumCC, nAux + 1))            // Digito da conta
         ::cAvalNumCC := LEFT(::cAvalNumCC, nAux - 1)                    // Numero da conta
      ENDIF
      nAux := AT("-", ::cAvalNumAgencia)
      IF nAux > 0 .AND. EMPTY(::cAvalDVAgencia)
         ::cAvalDVAgencia  := TRIM(SUBSTR(::cAvalNumAgencia, nAux + 1))  // Digito da Agencia
         ::cAvalNumAgencia := LEFT(::cAvalNumAgencia, nAux - 1)          // Numero da Agencia
      ENDIF
   ENDIF

   nAux := AT("-", ::cCDPF) //*FJF* - 28/09/09
   IF nAux > 0 .AND. EMPTY(::cDvCDPF) //*FJF* - 28/09/09
      ::cDvCDPF  := TRIM(SUBSTR(::cCDPF, nAux + 1))            // Digito do CDPF
      ::cCDPF    := LEFT(::cCDPF, nAux - 1)                    // CDPF
   ENDIF

   IF ::lBoleto

      ::AuxModelo := ::Modelo

      vMsg := "Modelo do Boleto < " + Lower( ::Modelo ) + " > Nao Encontrado no Diretorio " + ::Destino

      IF EMPTY(::Modelo)

         IF FILE( Lower( ::Destino + "bol" + ".htm") )             // isto ‚ para manter a compatibilidade
            ::Modelo := MEMOREAD( Lower( ::Destino + "bol.htm") )  // com a primeira versao
         ELSE
            ::Modelo := vMsg
         ENDIF

      ELSE

         IF FILE( Lower( ::Destino + ::Modelo + ".htm") )
            ::Modelo := MEMOREAD( Lower( ::Destino + ::Modelo + ".htm") )
         ELSE
            ::Modelo := vMsg
         ENDIF

      ENDIF

      IF !IsDirectory( ::Destino )
         MakeDir( ALLTRIM(::Destino) )
      ENDIF

      ::nHandle := FCREATE(::Destino + ::Nomehtm)

      FWRITE(Self:nHandle, [<html>] + CRLF)
      FWRITE(Self:nHandle, [<head>] + CRLF)
      FWRITE(Self:nHandle, [<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">] + CRLF)
      FWRITE(Self:nHandle, [<title>Boleto</title>] + CRLF)
      FWRITE(Self:nHandle, [<style>] + CRLF)
      FWRITE(Self:nHandle, [DIV {COLOR: #000000; FONT-FAMILY: Verdana; LINE-HEIGHT: 1; MARGIN: 0px}] + CRLF)
      FWRITE(Self:nHandle, [DIV.Tamanho4 {FONT-SIZE: 4pt}] + CRLF) // acrecentei estes estilos devido ao
      FWRITE(Self:nHandle, [DIV.Tamanho6 {FONT-SIZE: 6pt}] + CRLF) // novo modelo de boleto
      FWRITE(Self:nHandle, [DIV.Tamanho7 {FONT-SIZE: 7pt; LINE-HEIGHT: 8pt}] + CRLF)
      FWRITE(Self:nHandle, [DIV.Tamanho8 {FONT-SIZE: 8pt; LINE-HEIGHT: 9pt}] + CRLF)
      FWRITE(Self:nHandle, [DIV.Tamanho9 {FONT-SIZE: 9pt}] + CRLF)
      FWRITE(Self:nHandle, [DIV.Tamanho10 {FONT-SIZE: 10pt}] + CRLF)
      FWRITE(Self:nHandle, [DIV.Tamanho11 {FONT-SIZE: 11pt}] + CRLF)
      FWRITE(Self:nHandle, [.Section1 {page:Section1;}] + CRLF)
      FWRITE(Self:nHandle, [body {margin-left: 25px;}] + CRLF)
      FWRITE(Self:nHandle, [.pagebreak {page-break-before:always}] + CRLF)
    //FWRITE(Self:nHandle, [td {border: 1px solid #666666;}] + CRLF)
      FWRITE(Self:nHandle, [td {border: 1px solid #000000;}] + CRLF)
      FWRITE(Self:nHandle, [</style>] + CRLF)

      FWRITE(Self:nHandle, [<script language="JavaScript1.2" type="text/JavaScript1.2">] + CRLF)
      FWRITE(Self:nHandle, [<!--] + CRLF)
      FWRITE(Self:nHandle, [/* This will Automatically Maximize The Browser Window*/] + CRLF)
      FWRITE(Self:nHandle, [window.resizeTo(800,screen.availHeight);] + CRLF)
      FWRITE(Self:nHandle, [window.moveTo((screen.availWidth-800)/2,0);] + CRLF)
      FWRITE(Self:nHandle, [self.opener = self;] + CRLF)
      FWRITE(Self:nHandle, [// -->] + CRLF)
      FWRITE(Self:nHandle, [</script>] + CRLF)

      FWRITE(Self:nHandle, [</head>] + CRLF)

      ** Abrir Box de Impressao **

      //Ativar "window.close();" no firefox
      //Na barra de enderecos do firefox, digite: about:config
      //Localize a chave "dom.allow_scripts_to_close_windows", clicar sobre a chave e alterar o valor de <false> para <true>.
      //Feche o firefox e pronto!,
      //by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09

      //Fechar Navegador Apos Impressao//
      //FWRITE(Self:nHandle, [<body bgcolor="#FFFFFF" class="Normal" lang=PT-BR onload=" self.print(); window.open('','_parent',''); self.close()">] + CRLF)
      ////

      //Nao Fechar Navegador

      ** xx **

      FWRITE(Self:nHandle,'<body bgcolor="#FFFFFF" class="Normal" lang=PT-BR'+CRLF)
      FWRITE(Self:nHandle,' onload="')
      FWRITE(Self:nHandle,"alert('Para obter o resultado desejado na impressão do boleto bancário,")
      FWRITE(Self:nHandle," será recomendado imprimir em folha de papel A4 ou Carta\ncom gramatura do papel no mínimo 50g g/m2 (recomendável 75 g/m2) ")
      FWRITE(Self:nHandle," e redefinir as margens de impressão em seu navegador.\nPara isso, siga as instruções\n*  Margens (esquerda, direita, superior e")
      FWRITE(Self:nHandle," inferior): 0mm;\n* Apague todo o texto que aparece nos campos Cabeçalho (Header) e Rodapé (Footer).')")
      //FWRITE(Self:nHandle, [; window.open('','_parent',''); self.print(); self.close()">]+CRLF )
      FWRITE(Self:nHandle,'">'+CRLF)
   ENDIF

   ::Remessa(.F., cArqRem, cPastaRem, nNumRemessa, CNAB400 )

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Close() CLASS oBoleto

   IF ::lBoleto
      FWRITE(Self:nHandle, "</body></html>")
      FCLOSE(Self:nHandle)
   ENDIF
   IF ::lRemessa
      ::oRem:Close()
   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Merge( cCampo, cConteudo, lTudo ) CLASS oBoleto

   IF EMPTY(cConteudo)
      cConteudo := " "
   ENDIF
   IF ::lBoleto
      cConteudo := AcentoHtml(ALLTRIM(cConteudo), ::lAnsi, lTudo)
      cConteudo := STRTRAN(cConteudo, CRLF, "<BR>")
      Self:Bolhtm := STRTRAN(Self:Bolhtm , "{" + cCampo + "}", cConteudo)
   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Execute( ) CLASS oBoleto

   LOCAL cNsNm
   LOCAL cFatorVenc
   LOCAL cDGCB
   LOCAL cCodBar
   LOCAL nX
   LOCAL nY
   LOCAL cC1RN
   LOCAL cC2RN
   LOCAL cC3RN
   LOCAL cC4RN
   LOCAL cC5RN
   LOCAL cRNCB
   LOCAL cInstr
   LOCAL cCpoLivre   := ""
   LOCAL cAgCC
   LOCAL cCarteira
   LOCAL cNumAgencia
   LOCAL cCVT        := ""
   LOCAL cDataHSBC

   IF ::lBoleto
      IF ::nBoletos > 0
         ::Eject() // se chegou aqui entao ja teve um boleto
      ENDIF
      ::nBoletos++
   ENDIF
   ::Bolhtm := ::Modelo
   ::cNumAgencia := STRZERO(VAL(::cNumAgencia),4)

   IF ::nMulta > 0 .OR. ::nMora > 0
      cInstr := "Após vencimento, cobrar "
      IF ::nMulta > 0
         ::nValMulta := ROUND(::nValor * ::nMulta / 100, 2)
         cInstr += "multa de R$ <B>" + LTRIM(TRANSFORM(::nValMulta, "@E 999,999.99"))+"</B>"
         IF ::nMora > 0
            cInstr += " + "
         ENDIF
      ENDIF
      IF ::nMora > 0
         ::nValMora := ROUND(::nValor * ::nMora / 100, 2)
         cInstr += " mora de R$ <B>" + LTRIM(TRANSFORM(::nValMora, "@E 999,999.99")) + "</B> por dia de atraso"
      ENDIF
   ENDIF
   IF ::nDescDia > 0
      ::nValDescDia := ROUND(::nValor * ::nDescDia / 100, 2)
   ENDIF
   IF !EMPTY(cInstr) .AND. RIGHT(cInstr, 1) != "."
      cInstr += "."
   ENDIF

   IF ::nDiasProt > 0

      cInstr += CRLF + "&nbsp;Sujeito a protesto <B>" + LTRIM(STR(::nDiasProt)) + "</B> dia" + IF(::nDiasProt > 1, "s", "") + IF(::nDiasProt > 1, " úteis", " útil") + ;
                       " após o vencimento." + __ANSI

      IF ::cCodBco == "104"
         cInstr += CRLF + "Não receber após a data agendada para protesto." + __ANSI
         cInstr += CRLF + "Após vencimento, pagar somente nas agências da CAIXA." + __ANSI
      ENDIF

   ENDIF

   ::INSTRUCOES2 := cInstr
   ::ENDERECO1   := TRIM(::ENDERECO + IF(EMPTY(::COMPLEMENTO), "", ", " + ::COMPLEMENTO))
   ::ENDERECO2   := TRIM(::BAIRRO) + TRIM(IF(EMPTY(::CIDADE) .OR. EMPTY(::BAIRRO), "", " - ") + ::CIDADE) +;
                    TRIM(IF(EMPTY(::ESTADO), "", " - " + ::ESTADO))

   cCarteira    := ::cCarteira
   cNumAgencia  := ::cNumAgencia
   cAgcc := ::cNumAgencia + IF(EMPTY(::cDvAgencia), "", "-" + ::cDvAgencia) + "/" + ::cNumCC + "-" + ::cDvCC

   DO CASE

      CASE ::cCodBco == "001"  // Brasil

         IF LEFT( cCarteira, 2 ) $ "16,18" // SEM REGISTRO, Carteira com 17 Posicoes Livres

            If Len( ::cCDPF ) == 6 // Convenio BB 6 Posicoes

               ::cCDPF := STRZERO( VAL( ::cCDPF ), 6 )
               ::cNossoNumero := ::cCDPF + STRZERO( VAL( ::cNossoNumero ), 11 )

               cNsNm := ::cNossoNumero // 17 Posicoes Livres, Sem DV
               cCpoLivre := ::cCDPF + ::cNossoNumero + "21" // (21) Para indicacao do NN com 17 Posicoes Livres

            ElseIf Len( ::cCDPF ) == 7 // Convenio BB 7 Posicoes

               ::cCDPF := STRZERO( VAL( ::cCDPF ), 7 )

               ::cNossoNumero := ::cCDPF + STRZERO( VAL( ::cNossoNumero ), 10 )

               cNsNm := ::cNossoNumero // 17 Posicoes Livres, Sem DV

               cCpoLivre := "000000" + ::cNossoNumero + Left( cCarteira, 2 )

            Endif

         ELSE

            ::cCDPF := STRZERO(VAL(::cCDPF), 6)
            cCarteira      := STRZERO(VAL(cCarteira), 2)
            ::cNumCC       := STRZERO(VAL(::cNumCC), 8)
            ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 5)
            ::cDGNN := DC_Mod11(::cCodBco, 9, .F., ::cCDPF + ::cNossoNumero)
            cNsNm := TRANSFORM(::cCDPF + ::cNossoNumero, "@R 99.999.999.999") + "-" + ::cDGNN
            cCpoLivre := ::cCDPF + ::cNossoNumero + cNumAgencia + ::cNumCC + cCarteira

         ENDIF

      CASE ::cCodBco like "(008|033|353)"  //Santander Banespa

         ::cCDPF       := STRZERO(VAL(::cCDPF),7)  // CODIGO FORNECIDO PELO BANCO *** COM DIGITO ***
         ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 12)
         ::cDGNN := DC_Mod11(::cCodBco, 9, .F., ::cNossoNumero)
         cNsNm := ::cNossoNumero + " " + ::cDGNN
         cCarteira      := STRZERO(VAL(cCarteira),3)
         ::cCpoLivre      := "9"+::cCDPF+::cNossoNumero+::cDGNN+"0"+cCarteira

      CASE ::cCodBco == "070"  // BRB
           cCarteira      := alltrim(cCarteira)
           ::cNumCC       := alltrim(::cNumCC)
           ::cNossoNumero := alltrim(::cNossoNumero)

           cNsNm     := TRANSFORM(::cNossoNumero, "@R 999999999999")
           cAgcc     := "000" + "-" + ::cNumAgencia + "-" + ::cNumCC + ::cDvCC
           cCpoLivre := "000" + cNumAgencia + ::cNumCC + ::cDvCC + ::cNossoNumero

      CASE ::cCodBco == "104"  // Caixa

         If ::AuxModelo $ "SIGCB, CARNE_3B, CARNE_4B" // Modelo SIGCB, Padrao da Caixa

            ** Cedente e DV, OK Testado **
            ::cDvCDPF := DC_Mod11(::cCodBco, 9, .F., ::cCDPF )
            ** xx **

            ** NossoNumero e DV, OK Testado **

          //cAux_NN := "14" + ::cNossoNumero // 14 = Modalidade Nosso Numero P/ Cobranca (1)Registrada + Forma de Envio (4)Cedente
            cAux_NN := ::cTipoCob + ::cNossoNumero
            ::cDGNN := DC_Mod11(::cCodBco, 9, .F., cAux_NN )
            cNsNm := cAux_NN + ::cDGNN
            ** xx **

            cAgcc := ::cNumAgencia + "/" + ::cCDPF + "-" + ::cDvCDPF

            ** Campo Livre e DV, OK Testado **
            Aux_Livre := ::cCDPF + ::cDvCDPF + ;
                         SubStr( ::cNossoNumero, 1, 3 ) + SubStr( ::cTipoCob, 1, 1 ) + ; // Constante1, cTipoCob (1)Registrada, (2) Sem Registro
                         SubStr( ::cNossoNumero, 4, 3 ) + SubStr( ::cTipoCob, 2, 1 ) + ; // Constante2, cTipoCob (4)Emissao Cedente, (1)Caixa Via Correio, Agencia ou Email ( Forma de Envio )
                         SubStr( ::cNossoNumero, 7, 9 )
            DG_Livre  := DC_Mod11(::cCodBco, 9, .F., Aux_Livre )
            cCpoLivre := Aux_Livre + DG_Livre
            ** xx *

         Else // Outros

            ::cNossoNumero:= STRZERO(VAL(::cNossoNumero),10)
            cNumAgencia   := STRZERO(VAL(cNumAgencia)   ,04)
            ::cCDPF       := STRZERO(VAL(::cCDPF)       ,06)  // CODIGO FORNECIDO PELO BANCO
            ::cDGNN := DC_Mod11(::cCodBco, 9, .F., ::cNossoNumero)
            cAgcc := cNumAgencia + "." + LEFT( ::cCDPF , 3 ) + "." + SUBSTR( ::cCDPF , 4 ) + "-" + ::cDvCDPF //*FJF* - 28/09/09
            cNsNm := ::cNossoNumero + "-" + ::cDGNN  //*FJF* - 28/09/09
           // cNsNm := TRANSFORM(::cNossoNumero, "@R 9.999.999.999") + "-" + ::cDGNN  //*FJF* - 28/09/09
           cCpoLivre := ::cNossoNumero + cNumAgencia + ::cCDPF
           DO CASE
              CASE val(::cCarteira) ==11
                cCarteira:="CS"
              CASE val(::cCarteira) ==12
                cCarteira:="CR"
              CASE val(::cCarteira) ==14
                cCarteira:="SR"
              OTHERWISE
                cCarteira:=::cCarteira
           ENDCASE

        Endif

      CASE ::cCodBco == "237"  // Bradesco

         cCarteira      := STRZERO(VAL(cCarteira)     , 3) // coloquei aqui
         cNumAgencia    := STRZERO(VAL(cNumAgencia)   , 4) // para nao dar 'confusao'
         ::cNumCC       := STRZERO(VAL(::cNumCC)      , 7)
         cAgcc := ::cNumAgencia + IF(EMPTY(::cDvAgencia), "", "-" + ::cDvAgencia) + "/" + ::cNumCC + "-" + ::cDvCC
         IF ::lBoleto
            IF LEN(::cNossoNumero) < 11
               ::cNossoNumero := cNumAgencia + STRZERO(VAL(::cNossoNumero), 7)
            ELSE
               ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 11)
            ENDIF
            ::cDGNN := DC_Mod11(::cCodBco, 7, .F., cCarteira + ::cNossoNumero)
          // cNsNm := cCarteira + "/" + cNumAgencia + "/" + ::cNossoNumero + "-" + ::cDGNN
            cNsNm := cCarteira + "/" + trans(::cNossoNumero,"@R 9999/9999999") + "-" + ::cDGNN
            cCpoLivre := cNumAgencia + SUBSTR(cCarteira, 2, 2) + ::cNossoNumero + ::cNumCC + "0"
         ENDIF

      CASE ::cCodBco like "(341|739)" // Itaú ou BGN

         cCarteira      := STRZERO(VAL(cCarteira), 3)
         ::cNumCC       := STRZERO(VAL(::cNumCC), 5)
         ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 8)
         IF cCarteira $ "147/"
            ::TpCarteira := "E"
         ELSEIF cCarteira $ "166/"
            ::TpCarteira := "F"
         ELSEIF cCarteira $ "150/"
            ::TpCarteira := "U"
         ELSE
            ::TpCarteira := "I"
         ENDIF
         ::cDGNN := DC_Mod10(::cCodBco, cNumAgencia + ::cNumCC + cCarteira + ::cNossoNumero)
         cNsNm := cCarteira + "/" + ::cNossoNumero + "-" + ::cDGNN
         cCpoLivre := cCarteira + ::cNossoNumero + ::cDGNN + cNumAgencia + ::cNumCC + ::cDvCC + "000"

      CASE ::cCodBco like "(356|275)"  // Real ABN 356 275

         cNumAgencia    := STRZERO(VAL(cNumAgencia), 4)
         cCarteira      := STRZERO(VAL(cCarteira), 2)
         ::cNumCC       := STRZERO(VAL(::cNumCC), 7)
         IF EMPTY(::cTipoCob)
            ::cTipoCob := "1" // Cobranca 1-Simples 5-Escritural
         ENDIF
         IF cCarteira == "20" // Com Registro
            ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 7)
         ELSE                 // Sem Registro
            ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 13)
         ENDIF
         ::cDGNN := DC_Mod10(::cCodBco, STRZERO(VAL(::cNossoNumero), 13) + cNumAgencia + ::cNumCC)
       //cNsNm := cNumAgencia + "/" + ::cNossoNumero + "-" + ::cDGNN
         cNsNm := ::cNossoNumero // + "-" + ::cDGNN
         cCpoLivre := cNumAgencia + ::cNumCC + ::cDGNN + STRZERO(VAL(::cNossoNumero), 13)

      CASE ::cCodBco $ "399"  // HSBC

         cDataHSBC     := STRZERO(::DtVenc - StoD(STR(YEAR(::DtVenc), 4) + "0101"), 3) +;
                          RIGHT(STR(YEAR(::DtVenc), 4), 1)
         ::cCDPF       := STRZERO(VAL(::cCDPF), 7)
         cAgcc         := ::cNumAgencia + IF(EMPTY(::cDvAgencia), "", "-" + ::cDvAgencia) + "/" + ::cNumCC + "-" + ::cDvCC
         IF cCarteira == "00" // Com Registro
            ::cNossoNumero := STRZERO(VAL(::cNossoNumero), 10)
            ::cDGNN := DC_Mod11(::cCodBco, 7, .T., ::cNossoNumero)
            cNsNm := ::cNossoNumero + "-" + ::cDGNN
            cCpoLivre := ::cNossoNumero + ::cDGNN + STRZERO(VAL(::cNumAgencia), 4) + ::cNumCC + ::cDvCC + "00" + "1"
         ELSE                 // Sem Registro
            ::cNossoNumero := cNsNm := STRZERO(VAL(::cNossoNumero), 13)
            cCpoLivre := ::cCDPF + ::cNossoNumero + cDataHSBC + "2"
         ENDIF

      CASE ::cCodBco $ "409"  // Unibanco

         cNumAgencia   := STRZERO(VAL(cNumAgencia), 4)
         ::cNumCC      := STRZERO(VAL(::cNumCC), 7)
         ::cNumDoc     := STRZERO(VAL(::cNumDoc), 6)
         ::cNossoNumero:= STRZERO(VAL(::cNossoNumero), 10)
         ::cDGNN       := DC_Mod11(::cCodBco, 9, .F., ::cNossoNumero, .T.)
         cAgcc         := ::cNumAgencia + IF(EMPTY(::cDvAgencia), "", "-" + ::cDvAgencia) + "/" + ::cNumCC + "-" + ::cDvCC
         cNsNm         := "1/" + ::cNossoNumero + ::cDGNN + "/" + DC_Mod11(::cCodBco, 9, .F., "1" + ::cNossoNumero + ::cDGNN, .T.)

         // cCVT => Código Transação CVT (409-Unibanco)
         IF TRIM(cCarteira) like "(1|4)"
            cCVT := "Cód. Transação CVT: 5539-5" + __ANSI  // cCVT == "5539-5" => "04"
            cCarteira := "DIRETA"
            cCpoLivre := "04" + SUBSTR(DTOS(::DtVenc), 3, 2) + SUBSTR(DTOS(::DtVenc), 5, 1) // 1o. GRUPO
            cCpoLivre += SUBSTR(DTOS(::DtVenc), 6, 3) + cNumAgencia + ::cDvAgencia + STRTRAN(SUBSTR(cNsNm, 3), "/", "") // 2o. e 3o. GRUPO
         ELSE
            cCVT := "Cód. Transação CVT: 7744-5" + __ANSI // cCVT == "7744-5" => "5"
            cCarteira := "ESPECIAL"
            // cCpoLivre := "5" + ::cCDPF + "00" + ::cNossoNumero
         ENDIF

      CASE ::cCodBco == "422"  // Safra

         cCarteira      := STRZERO(VAL(cCarteira), 2)
         ::cNumCC       := STRZERO(VAL(::cNumCC), 8)
         ::cNossoNumero := STRZERO(VAL(::cNossoNumero),17)
         ::cCDPF        := STRZERO(VAL(::cCDPF), 6)
         ::cDGNN := DC_Mod11(::cCodBco, 9, .F., ::cNossoNumero)
         cAgcc := "0" + ::cNumAgencia + "/" + ::cNumCC + "-" + ::cDvCC
         IF val(cCarteira)==6
            ::cNumDoc      := STRZERO(VAL(::cNossoNumero),11)
            cNsNm := "EXPRESS"
            cCpoLivre := "7" +::cCDPF +::cNossoNumero +"4"
         else
            cNsNm := "0"+cNumAgencia + "/" + ::cNossoNumero + "-" + ::cDGNN
            cCpoLivre := "70" + cNumAgencia + ::cNumCC + ::cDvCC + ::cNossoNumero + ::cDGNN + "1"
            //            2        4            8           1          8              1       1
         ENDIF

   ENDCASE

   IF ::cCodBco == "104"  // Caixa  //*FJF* - 28/09/09
        SET CENT ON
   ENDIF

   If ::AuxModelo $ "SIGCB, CARNE_3B, CARNE_4B" // Modelo SIGCB, Padrao da Caixa

      ::Merge("LOGOBANCO",  "logo" + ::cCodBco)
      ::Merge("IMAGELNK",   ::cImageLnk)
      ::Merge("BANCO",      ::cCodBco + "-" + ::cDvBco)
      ::Merge("LOCALPGTO",  ::cLocalPgto)
      ::Merge("CEDENTE",    ::Cedente)
      ::Merge("AVALISTA",   ::AVALISTA)
      ::Merge("SACADO",     ::SACADO)
      ::Merge("ENDERECO1",  ::ENDERECO1)
      ::Merge("ENDERECO2",  ::ENDERECO2)
      ::Merge("CEP",  TRANS(::CEP, "@R 99.999-999"))
      ::Merge("INSTRUCOES", ::INSTRUCOES2, .F.)
      ::Merge("TEXTO",      ::INSTRUCOES)

      IF VAL(SUBSTR(::CNPJ, 10, 4)) == 0
         ::cCNPJ        := ""
         ::cCPF         := SUBSTR(::CNPJ, 1, 9) + SUBSTR(::CNPJ, 14)
         //::Merge("CNPJ", TRANS(::cCPF, "@R 999.999.999-99"))
      ELSE
         ::cCNPJ        := STRZERO(VAL(::CNPJ), 14) // SUBSTR(::CNPJ, 2)
         ::cCPF         := ""
         //::Merge("CNPJ", TRANS(::cCNPJ, "@R 99.999.999/9999-99"))
      ENDIF

      *-------------------------------------------------------------------*
      * Ajustes, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09 *
      *-------------------------------------------------------------------*
      IF LEN( ::CNPJ ) == 11 // CPF
         ::Merge("CNPJ", TRANS(::CNPJ, "@R 999.999.999-99"))
      ELSEIF LEN( ::CNPJ ) == 14 // CNPJ
         ::Merge("CNPJ", TRANS(::CNPJ, "@R 99.999.999/9999-99"))
      ELSE
        ::Merge("CNPJ", "")
      ENDIF
      ** xx **

      ::Merge("DTVENC"    , DTOC(::DtVenc))
      ::Merge("DATA"      , DTOC(::DtEmis))
      ::Merge("DATAPROC"  , DTOC(::DtEmis)) // Nao sei se aqui deveria ser DATE().
      ::Merge("VALOR"     , TRANS(::nValor, "@E 99,999,999.99"))
      ::Merge("NMORA"     , TRANS(::nMora, "@E 999,999.99"))
      ::Merge("CVT"       , cCVT)
      ::Merge("AGCC"      , cAgCC)
      ::Merge("NUMDOC"    , ::cNumDoc)
      ::Merge("CARTEIRA"  , cCarteira)
      ::Merge("ESPECIETIT", ::EspecieTit)
      ::Merge("ACEITE"    , ::Aceite)
      ::Merge("NNUMERO"   , TRAN( cNsNm, "@R 99999999999999999-9" ) )

      cFatorVenc := STRZERO( ::DtVenc - dDataBase , 4 )

      // Monta Código de Barras (p/ Banco)
      cDGCB := DC_Mod11( ::cCodBco, 9, .T., ::cCodBco + ::cTipoMoeda + cFatorVenc + STRZERO( ::nValor * 100, 10 ) + cCpoLivre )
      cCodBar := ::cCodBco + ::cTipoMoeda + cDGCB + cFatorVenc + STRZERO( ::nValor * 100, 10 ) + cCpoLivre
      //           3           1            1       4                       10                   25

      nY := 0
      FOR nX := 1 TO LEN( cCodBar ) STEP 2
          ::Merge( STRZERO( nY++, 2 ), SUBSTR( cCodBar, nX, 2 ) )
      NEXT

      // Monta Representacao Numerica do Codigo de Barras

      ** Campo1 **
      cC1RN := ::cCodBco + ::cTipoMoeda + LEFT( cCpoLivre, 5 )
      cC1RN := cC1RN + DC_Mod10( ::cCodBco, cC1RN )

      ** Campo2 **
      cC2RN := SUBSTR( cCpoLivre, 6, 10)
      cC2RN += DC_Mod10( ::cCodBco, cC2RN )

      ** Campo3 **
      cC3RN := SUBSTR( cCpoLivre, 16, 10)
      cC3RN += DC_Mod10(::cCodBco, cC3RN)

      ** Campo4 **
      cC4RN := cDGCB

      ** Campo5 **
      cC5RN := cFatorVenc + STRZERO( ::nValor * 100, 10 )

      ** Linha Digitavel **
      cRNCB := LEFT( cC1RN, 5 ) + "." + SUBSTR( cC1RN, 6 ) + " " + LEFT( cC2RN, 5 ) + "." +;
               SUBSTR( cC2RN, 6 ) + " " + LEFT( cC3RN, 5 ) + "." + SUBSTR( cC3RN, 6 ) + " " + cC4RN + " " + cC5RN
      ::Merge("LINDIG", cRNCB)
      ** xx **

   Else // Outros Modelos

      ::Merge("LOGOBANCO",  "logo" + ::cCodBco)
      ::Merge("IMAGELNK",   ::cImageLnk)
      ::Merge("BANCO",      ::cCodBco + "-" + ::cDvBco)
      ::Merge("LOCALPGTO",  ::cLocalPgto)
      ::Merge("CEDENTE",    ::Cedente)
      ::Merge("AVALISTA",   ::AVALISTA)
      ::Merge("SACADO",     ::SACADO)
      ::Merge("ENDERECO1",  ::ENDERECO1)
      ::Merge("ENDERECO2",  ::ENDERECO2)
      ::Merge("CEP",        TRANS(::CEP, "@R 99.999-999"))
      ::Merge("INSTRUCOES", ::INSTRUCOES2, .F.)
      ::Merge("TEXTO",      ::INSTRUCOES)

      IF VAL(SUBSTR(::CNPJ, 10, 4)) == 0
         ::cCNPJ        := ""
         ::cCPF         := SUBSTR(::CNPJ, 1, 9) + SUBSTR(::CNPJ, 14)
         //::Merge("CNPJ", TRANS(::cCPF, "@R 999.999.999-99"))
      ELSE
         ::cCNPJ        := STRZERO(VAL(::CNPJ), 14) // SUBSTR(::CNPJ, 2)
         ::cCPF         := ""
         //::Merge("CNPJ", TRANS(::cCNPJ, "@R 99.999.999/9999-99"))
      ENDIF

      *-------------------------------------------------------------------*
      * Ajustes, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09 *
      *-------------------------------------------------------------------*
      IF LEN( ::CNPJ ) == 11 // CPF
         ::Merge("CNPJ", TRANS(::CNPJ, "@R 999.999.999-99"))
      ELSEIF LEN( ::CNPJ ) == 14 // CNPJ
         ::Merge("CNPJ", TRANS(::CNPJ, "@R 99.999.999/9999-99"))
      ELSE
        ::Merge("CNPJ", "")
      ENDIF
      ** xx **

      ::Merge("DTVENC"    , DTOC(::DtVenc))
      ::Merge("DATA"      , DTOC(::DtEmis))
      ::Merge("DATAPROC"  , DTOC(::DtEmis)) // Não sei se aqui deveria ser DATE().
      ::Merge("VALOR"     , TRANS(::nValor, "@E 99,999,999.99"))
      ::Merge("NMORA"     , TRANS(::nMora, "@E 999,999.99"))
      ::Merge("CVT"       , cCVT)
      ::Merge("AGCC"      , cAgCC)
      ::Merge("NUMDOC"    , ::cNumDoc)
      ::Merge("CARTEIRA"  , cCarteira)
      ::Merge("ESPECIETIT", ::EspecieTit)
      ::Merge("ACEITE"    , ::Aceite)
      ::Merge("NNUMERO"   , cNsNm)

      IF ::cCodBco == "104"  // Caixa  //*FJF* - 28/09/09
         SET CENT OFF
      ENDIF

      cFatorVenc := STRZERO(::DtVenc - dDataBase , 4)

      // Monta C¢digo de Barras (p/ Banco)
      cDGCB := DC_Mod11(::cCodBco, 9, .T., ::cCodBco + ::cTipoMoeda + cFatorVenc + STRZERO(::nValor * 100, 10) + cCpoLivre)
      cCodBar := ::cCodBco + ::cTipoMoeda + cDGCB + cFatorVenc + STRZERO(::nValor * 100, 10) + cCpoLivre
      //              3           1            1        4                     10                   25

      nY := 0
      FOR nX := 1 TO LEN(cCodBar) STEP 2
          ::Merge(STRZERO(nY++, 2), SUBSTR(cCodBar, nX, 2))
      NEXT

      // Monta Representação Numérica do Código de Barras
      cC1RN := ::cCodBco + ::cTipoMoeda + LEFT(cCpoLivre, 5)
      cC1RN := cC1RN + DC_Mod10(::cCodBco, cC1RN)

      cC2RN := SUBSTR(cCpoLivre, 6, 10)
      cC2RN += DC_Mod10(::cCodBco, cC2RN)

      cC3RN := SUBSTR(cCpoLivre, 16, 20)
      cC3RN += DC_Mod10(::cCodBco, cC3RN)

      cC4RN :=cDGCB

      cC5RN :=cFatorVenc + STRZERO(::nValor * 100, 10)

      cRNCB := LEFT(cC1RN, 5) + "." + SUBSTR(cC1RN, 6) + " " + LEFT(cC2RN, 5) + "." +;
            SUBSTR(cC2RN, 6) + " " + LEFT(cC3RN, 5) + "." + SUBSTR(cC3RN, 6) + "  " + cC4RN + "  " + cC5RN
      ::Merge("LINDIG", cRNCB)

  Endif

  IF ::lBoleto
     FWRITE(Self:nHandle, Self:Bolhtm)
  ENDIF
  ::Remessa(.T.)

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Remessa( lAdd, cArqRem, cPastaRem, nNumRemessa, CNAB400 ) CLASS oBoleto

   LOCAL cCodBco
   LOCAL cNumAgencia
   LOCAL cNumCC
   LOCAL cDvAgencia
   LOCAL cDvCC
   IF ::lRemessa
      // Gatilho para Avalista, melhorar depois...
      IF !EMPTY(::cAvalCodBco)
         cCodBco       := ::cCodBco
         cNumAgencia   := ::cNumAgencia
         cNumCC        := ::cNumCC
         cDvAgencia    := ::cDvAgencia
         cDvCC         := ::cDvCC
         ::cCodBco     := ::cAvalCodBco
         ::cNumAgencia := ::cAvalNumAgencia
         ::cNumCC      := ::cAvalNumCC
         ::cDvAgencia  := ::cAvalDvAgencia
         ::cDvCC       := ::cAvalDvCC
      ENDIF
      IF lAdd
         ::oRem:add(Self)
      ELSE
         ::oRem         := oRemessa(IF(EMPTY(::cAvalCodBco),::cCodBco,::cAvalCodBco),nNumRemessa)
         ::oRem:CNAB400 := CNAB400
         ::oRem:Open(Self,cArqRem,cPastaRem)
      ENDIF
      IF !EMPTY(::cAvalCodBco)
         ::cCodBco      := cCodBco
         ::cNumAgencia  := cNumAgencia
         ::cNumCC       := cNumCC
         ::cDvAgencia   := cDvAgencia
         ::cDvCC        := cDvCC
      ENDIF
   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Print( lPreview, lPromptPrint, cPrinter ) CLASS oBoleto

   DEFAULT lPreview     TO ::lPreview ,;
           lPromptPrint TO .T.,;
           cPrinter     TO ""

   #ifdef __PLATFORM__Windows
     DEFAULT  cPrinter TO GetDefaultPrinter()
   #Endif

   IF ::lBoleto .AND. ::nBoletos > 0

      //#IFNDEF __PLATFORM__Linux
      //    LOCAL oIE := CREATEOBJECT( "InternetExplorer.Application" )
      //    oIE:Visible = .T.
      //    oIE:Navigate( ::Destino+"\"+ ::Nomehtm + " ")
      //#ENDIF

      #IFNDEF __PLATFORM__Linux  // esta maravilha e de autoria de Laverson Espindola
        // PrintHTML nao funciona no Win98 :-(
        IF Os_IsWinNT()
           PrintHTML(::Destino + ::Nomehtm, cPrinter, lPreview, lPromptPrint, !lPreview )
        ELSE
          ShellExecute(::Nomehtm, "print", NIL, ::Destino, 1)
        ENDIF
      #ELSE

        //xhbrun(["]+ hb_oemtoansi(::HtmEdit) +["] + ::Destino + ::Nomehtm + " ", .T., .F.)

        ** Linux Modo Console, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09 **
        HB_OpenProcess('/usr/bin/firefox ' + ::Destino + ::Nomehtm, , , , .t. )
        ** xx **

      #ENDIF

   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */
METHOD ERASE() CLASS oBoleto

      ::Close()
      IF ::lBoleto
         FERASE(::Destino+::Nomehtm)
      ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Eject() CLASS oBoleto

   IF MOD(::nBoletos, ::nBolsPag) == 0
      FWRITE(Self:nHandle, [<div class="pagebreak">&nbsp;</div>])
   ELSE
      // uma boa opcao e esta
      // apesar de ser uma linha 'simples' nao obrigamos que a imagem esteja junto do html
      // assim da pra mandar so o html para o cliente pagador e os gifs ficam na web

      FWRITE(Self:nHandle, [<TD style="border:none" align=right vAlign=top><hr size="1" noshade></TD>])

      /*
      FWRITE(Self:nHandle, [<TD style="border:none" align=right vAlign=top> <font size=1 face=Arial>] +;
                           [<img src="cortar.gif" width="100%" height="21">Corte aqui</font></TD>]) */
   ENDIF


RETURN Self

/* -------------------------------------------------------------------------- */

METHOD isRegistrada() CLASS oBoleto
   // cobran‡a Registrada e a cobran‡a que precissa ser informada ao banco para
   // que em caso de nao pagamento o banco possa enviar para protesto
   // ja cobran‡a sem registro nao tem esta necessidade basta gerar o Boleto
   // nesta modalidade de cobran‡a nao existe a op‡ao de protesto

   LOCAL lRet
   IF (lRet := ::lRemessa )
      DO CASE
         CASE ::cCodBco == "001"
         CASE ::cCodBco like "(008|033|353)"
              lRet := (VAL(::cCarteira) <> 102)
         CASE ::cCodBco == "104"
         CASE ::cCodBco == "237"
              lRet := (VAL(::cCarteira) == 9)
         CASE ::cCodBco == "341"
         CASE ::cCodBco == "356"
              lRet := (VAL(::cCarteira) == 20)
         CASE ::cCodBco == "422"
      ENDCASE
   ENDIF

RETURN lRet

/* -------------------------------------------------------------------------- */

METHOD SetNomeRem( cArq,cPasta ) CLASS oBoleto
   DEFAULT cPasta TO ""

   ::oRem:Destino:=cPasta
   ::oRem:NomeRem:=cArq

RETURN Self

/* -------------------------------------------------------------------------- */
// Retorna Dígito de Controle Módulo 10                                       //

FUNCTION DC_Mod10( cCodBco, mNMOG )

   LOCAL mVLDG, mSMMD, mCTDG, mRSDV, mDCMD
   mSMMD:=0
   FOR mCTDG := 1 TO LEN(mNMOG)
      mVLDG := VAL(SUBSTR(mNMOG, LEN(mNMOG) - mCTDG + 1, 1)) * IF(MOD(mCTDG,2) == 0, 1, 2)
      mSMMD += mVLDG - IF(mVLDG > 9, 9, 0)
   NEXT
   mRSDV := MOD(mSMMD, 10)
   mDCMD := IF(mRSDV == 0, "0", STR(10 - mRSDV, 1))

RETURN mDCMD

/* -------------------------------------------------------------------------- */
// Retorna Digito de Controle Modulo 11 (p/ Banco)                            //
// bradesco -> DC_Mod11("237", 7, .F., carteira+agencia+nossonumero)

FUNCTION DC_Mod11( mCDBC, mBSDG, mFGCB, mNMOG, lMult10 )

   LOCAL mSMMD, mCTDG, mSQMP, mRSDV, mDCMD
   DEFAULT mFGCB TO .F., lMult10 TO .F.
   mSMMD := 0
   mSQMP := 2

   FOR mCTDG := 1 TO LEN(mNMOG)
       mSMMD += VAL(SUBSTR(mNMOG, LEN(mNMOG) - mCTDG + 1, 1)) * (mSQMP)
       mSQMP := IF(mSQMP == mBSDG, 2, mSQMP+1)
   NEXT
   IF lMult10
      mSMMD *= 10
   ENDIF
   mRSDV := MOD(mSMMD, 11)
   IF mFGCB
      mDCMD := IF(mRSDV > 9 .OR. mRSDV < 2, "1", STR(11 - mRSDV, 1))
   ELSE
      IF mCDBC == "001"        // Brasil
         mDCMD := IF(mRSDV == 0, "0", IF(mRSDV == 1, "X", STR(11 - mRSDV, 1)))
      ELSEIF mCDBC like "(008|033|353)"  //Santander Banespa
         mDCMD := IF(mRSDV < 2, "0", IF(mRSDV == 10, "1", STR(11 - mRSDV, 1)))
       //mDCMD := IF(mRSDV == 0, "0", IF(mRSDV == 1, "X", STR(11 - mRSDV, 1)))
      ELSEIF mCDBC=="104"      // Caixa
         mRSDV := 11 - mRSDV
         mDCMD := IF(mRSDV > 9, "0", STR(mRSDV, 1))
      ELSEIF mCDBC == "237"    // Bradesco
         mDCMD := IF(mRSDV == 0, "0", IF(mRSDV == 1, "P", STR(11 - mRSDV, 1)))
      ELSEIF mCDBC == "341"    // Itau
         mDCMD := IF(mRSDV == 11, "1", STR(11 - mRSDV, 1))
      ELSEIF mCDBC == "409"    // Unibanco
         mDCMD := IF(mRSDV == 0 .OR. mRSDV == 10, "0", STR(mRSDV, 1))
      ELSEIF mCDBC == "422"    // Safra
         mDCMD := IF(mRSDV==0, "1", IF(mRSDV == 1, "0", STR(11 - mRSDV, 1)))
      ENDIF
   ENDIF

RETURN mDCMD

/* -------------------------------------------------------------------------- */
// Retorna Dígito de Controle Módulo Especial                                 //

FUNCTION DC_ModEsp( cCodBco, mNMOG )

   LOCAL mVLDG, mSMMD, mCTDG, mSQMP, mRSDV, mDCMD:=0

   IF cCodBco == "033"  // Banespa
      mSMMD:=0
      mSQMP:=3
      FOR mCTDG := 1 TO LEN(mNMOG)
          mVLDG := VAL(SUBSTR(mNMOG, LEN(mNMOG) - mCTDG + 1, 1)) * (mSQMP)
          mSMMD += mVLDG - (INT(mVLDG / 10) * 10)
          mSQMP := IF(mSQMP == 3, 7, IF(mSQMP == 7, 9, IIF(mSQMP == 9, 1, 3)))
      NEXT
      mRSDV := mSMMD - (INT(mSMMD / 10) * 10)
      mDCMD := IIF(mRSDV == 0, 0, 10 - mRSDV)
   ENDIF

RETURN str(mDCMD,1)
