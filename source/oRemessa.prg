/*
 * $Id$
*/
/*
 * Copyright 2006 Mario Simoes Filho mario@argoninformatica.com.br for original oRemessa.prg
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
#include "fileio.ch"
#include "hbclass.ch"

CLASS oRemessa

DATA cLine           INIT ""  PROTECTED
DATA nSeqReg         INIT 0   PROTECTED  // Sequencial do Registro
DATA cFillTrailer    INIT " " PROTECTED  // Caracter para preencher a ultima linha do arquivo

DATA Destino         INIT ""
DATA nHandle         INIT 0   PROTECTED  // link - Arquivo Remessa (FCREATE)
DATA NomeRem         INIT ""             // Nome do Arquivo Remessa

DATA nTitLote        INIT 0   READONLY   // Numero de Titulos (Boletos) do Lote
DATA cNumSequencial  INIT ""  READONLY   // Numero Sequencial do Arquivo Remessa
DATA NumRemessa      INIT 0              // Numero sequencial do arquivo de remessa, utilizado pelo BRADESCO

DATA cCodBco         INIT ""  READONLY
DATA cNomeBco        INIT ""  READONLY
DATA cData           INIT ""  READONLY   // Data da geracao do arquivo no Formato DDMMAA
DATA cDtVenc         INIT ""  READONLY   // Data de vencimento no Formato DDMMAA
DATA CNAB400         INIT .T.            // .T. = CNAB400 ou .F. = CNAB240(Febraban)

DATA nQtdSimples     INIT 0   READONLY   // Numero de Titulos - Cobrança Simples
DATA nVlrSimples     INIT 0   READONLY   // Valor Total - Cobrança Simples
DATA nQtdVinculada   INIT 0   READONLY   // Numero de Titulos - Cobrança Vinculada
DATA nVlrVinculada   INIT 0   READONLY   // Valor Total - Cobrança Vinculada
DATA nQtdCaucionada  INIT 0   READONLY   // Numero de Titulos - Cobrança Caucionada
DATA nVlrCaucionada  INIT 0   READONLY   // Valor Total - Cobrança Caucionada
DATA nQtdDescontada  INIT 0   READONLY   // Numero de Titulos - Cobrança Descontada
DATA nVlrDescontada  INIT 0   READONLY   // Valor Total - Cobrança Descontada

DATA OCORRENCIA  INIT "01"
DATA INSTRUCAO1  INIT "00"
DATA INSTRUCAO2  INIT "00"
DATA DTDESC      INIT ""
DATA MENSAGEM    INIT ""
DATA cPasta      INIT ""                 // Diretorio onde sera criado o Arquivo Remessa


METHOD New( cBco, nNumRemessa ) CONSTRUCTOR
METHOD Open( oBol, cArq, cPasta )
METHOD Add( oBol )
METHOD Close()
METHOD Line()
ENDCLASS

/* -------------------------------------------------------------------------- */

METHOD new( cBco, nNumRemessa ) CLASS oRemessa
   DEFAULT cBco TO "237"
   DEFAULT nNumRemessa TO 1
   ::cCodBco := cBco
   DO CASE
      CASE cBco $ "001"
         ::cNomeBco   := "BANCO DO BRASIL"
      CASE cBco == "008"
         ::cNomeBco := "Santander"
         ::CNAB400:=.f.
      CASE cBco == "033"
         ::cNomeBco := "Santander"
         ::CNAB400:=.f.
      CASE cBco == "104"
         ::cNomeBco := "CAIXA ECONOMICA FEDERAL"
         ::CNAB400:=.f.
      CASE cBco $ "237"
         ::cNomeBco   := "BRADESCO"
      CASE cBco $ "341"
         ::cNomeBco   := "BANCO ITAU S.A."
         ::cFillTrailer := "0"
      CASE cBco == "353"
         ::cNomeBco := "Santander"
         ::CNAB400:=.f.
      CASE cBco $ "356"
         ::cNomeBco   := "BANCO REAL"
      CASE cBco $ "399"
         ::cNomeBco   := "HSBC"
      CASE cBco $ "409"
         ::cNomeBco   := "UNIBANCO"
      CASE cBco $ "422"
         ::cNomeBco   := "SAFRA"
      CASE cBco $ "739"
         ::cNomeBco   := "BANCO BGN"
         ::cFillTrailer := "0"

   ENDCASE

 //::cNomeBco := PAD(::cNomeBco, 15)
   ::NumRemessa:=nNumRemessa
   
RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Open( oBol, cArq, cPasta ) CLASS oRemessa

   LOCAL nI := 1

   ::cData := STRZERO(DAY(oBol:DtEmis), 2) + STRZERO(MONTH(oBol:DtEmis), 2) + RIGHT(STR(YEAR(oBol:DtEmis)), 2)
   DEFAULT cArq to "cb" + ::cData, cPasta TO LEFT(hb_cmdargargv(), RAT(HB_OSpathseparator(), hb_cmdargargv()))

   IF EMPTY(::Destino)
      cPasta := ALLTRIM(cPasta)
      IF RIGHT(cPasta, 1) != HB_OSpathseparator()
         cPasta += HB_OSpathseparator()
      ENDIF

      IF !IsDirectory( cPASTA )     // Acrescentei para criar a pasta de geracao arq remessa definida em cPastaRem
         MakeDir( ALLTRIM(cPASTA) ) // Open( cArq, cPasta, cArqRem, cPastaRem, nNumRemessa ) de oBoleto  25/09/2006
      ENDIF

      ::Destino := cPasta
   ENDIF

   IF !EMPTY(::NomeRem) // Nunca vai entrar aqui. So entraria se voltassemos ::oRem := oRemessa(::cCodBco) p/ oBoleto:new()
      FERASE(::Destino + ::NomeRem)
      ::nHandle := FCREATE(::Destino + ::NomeRem, FC_NORMAL)
   ELSE
      IF !FILE(::Destino + cArq + ".rem")
         ::nHandle := FCREATE(::Destino + cArq + ".rem", FC_NORMAL)
      ELSE
         WHILE FILE(::Destino + cArq + STRZERO(nI, 2) + ".rem")
           nI++
         END
         ::nHandle := FCREATE(::Destino + cArq + STRZERO(nI, 2) + ".rem")
         ::cNumSequencial := STRZERO(nI, 2)
         cArq += ::cNumSequencial
      ENDIF
      IF ::nHandle > 0
         ::NomeRem := cArq + ".rem"
      ENDIF
   ENDIF
   ::cLine  := ""

   IF ::nHandle < 0 // Header
      
   ELSEIF ::CNAB400

     ::cLine += "0"
     ::cLine += "1"
     ::cLine += "REMESSA"
     ::cLine += "01"
     ::cLine += PAD("COBRANCA", 15)

      DO CASE
         CASE ::cCodBco $ "001" // Banco do Brasil
              ::cLine += PAD(oBol:cNumAgencia, 4, "0")
              ::cLine += oBol:cDvAgencia
              ::cLine += PAD(oBol:cNumCC, 8, "0")
              ::cLine += oBol:cDvCC
              ::cLine += STRZERO(0, 6)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 15)
              ::cLine += ::cData
              ::cLine += STRZERO(::NumRemessa, 7)
              ::cLine += SPACE(22)
              ::cLine += STRZERO(VAL(oBol:cCDPF), 7) // No. do convencio com o banco
              ::cLine += SPACE(258)

         CASE ::cCodBco $ "237" // Bradesco
              ::cLine += STRZERO(VAL(oBol:cCDPF), 20)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 15)
              ::cLine += ::cData
              ::cLine += SPACE(8)
              ::cLine += "MX"
              ::cLine += STRZERO(::NumRemessa, 7)
              ::cLine += SPACE(277)

         CASE ::cCodBco $ "341/739" // Itaú ou BGN
              ::cLine += PAD(oBol:cNumAgencia, 4)
              ::cLine += "00"
              ::cLine += PAD(oBol:cNumCC, 5)
              ::cLine += PAD(oBol:cDVCC, 1)
              ::cLine += SPACE(8)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += ::cNomeBco
              ::cLine += ::cData
              ::cLine += SPACE(294)

         CASE ::cCodBco $ "356" // Real
              ::cLine += "0"
              ::cLine += PAD(oBol:cNumAgencia, 4)
              ::cLine += "0"
              ::cLine += PAD(oBol:cNumCC, 7)
              ::cLine += SPACE(7)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 15)
              ::cLine += ::cData
              ::cLine += "01600BPI"
              ::cLine += SPACE(286)

         CASE ::cCodBco $ "399" // HSBC
              ::cLine += "0"
              ::cLine += PAD(oBol:cNumAgencia, 4)
              ::cLine += "55"
              ::cLine += PAD(oBol:cNumAgencia, 4)
              ::cLine += PAD(oBol:cNumCC + oBol:cDvCC, 7)
              ::cLine += SPACE(2)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 15)
              ::cLine += ::cData
              ::cLine += "01600BPI"
              ::cLine += SPACE(2)
              ::cLine += "LANCV08"
              ::cLine += SPACE(277)

         CASE ::cCodBco $ "409" // Unibanco
            //::cLine += SPACE(7)
              ::cLine += PAD(oBol:cNumAgencia, 4)
              ::cLine += PADL(VAL(oBol:cNumCC), 6, "0")
              ::cLine += PAD(oBol:cDVCC, 1) //37
              ::cLine += STRZERO(0, 9)
              ::cLine += PAD(oBol:Cedente, 30) //66
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 8) //84
              ::cLine += SPACE(7)
              ::cLine += ::cData
              ::cLine += "01600"
              ::cLine += "BPI" //107
              ::cLine += STRZERO(0, 286)

         CASE ::cCodBco $ "422" // Safra - 25/09/2006
            //::cLine += "0"
            //::cLine += "1"
            //::cLine += "REMESSA"
            //::cLine += "01"
            //::cLine += "COBRANCA"
            //::cLine += SPACE(07)

              ::cLine += PAD(oBol:cCDPF, 14)    // Usando cCDPF como CODEMPRE 14/09

              ::cLine += SPACE(06)
              ::cLine += PAD(oBol:Cedente, 30)
              ::cLine += ::cCodBco
              ::cLine += PAD(::cNomeBco, 11)
              ::cLine += SPACE(04)
              ::cLine += ::cData
              ::cLine += SPACE(291)
              ::cLine += "   "

      ENDCASE

      ::Line()

   ELSE // FEBRABAN        
      
      ::cData := STRZERO(DAY(oBol:DtEmis), 2) + STRZERO(MONTH(oBol:DtEmis), 2) + RIGHT(STR(YEAR(oBol:DtEmis)), 4)
      
      If ::cCodBco == "104" // Caixa CNAB240 SIGCB, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09

         // Header Arquivo

         ::cLine += ::cCodBco                              // 01.0 Codigo do Banco
         ::cLine += "0000"                                 // 02.0 Lote de Servico
         ::cLine += "0"                                    // 03.0 Tipo de Registro
         ::cLine += SPAC(9)                                // 04.0 Uso Exclusivo FEBRABAN
         ::cLine += "2"                                    // 05.0 Tipo de Inscricao 0-Isento, 1-CPF, 2-CNPJ, 3-PIS, 9-Outros
         ::cLine += PADL( STR( VAL( oBol:CedenteCNPJ ),,,.t. ), 14, "0")  // 06.0 Numero da Inscricao
         ::cLine += REPL( "0", 20 )                        // 07.0 Uso Exclusivo da Caixa
         ::cLine += "0" + PADL( oBol:cNumAgencia, 4, "0" ) // 08.0 Numero Agencia 5 Digitos
         ::cLine += PAD(  oBol:cDvAgencia, 1 )             // 09.0 Dv Agencia
         ::cLine += oBol:cCDPF                             // 10.0 Cod. Cedente / Cod Convenio no Banco
         ::cLine += REPL("0",7)                            // 11.0 Uso Exclusivo da Caixa
         ::cLine += "0"                                    // 12.0 Uso Exclusivo da Caixa
         ::cLine += PAD( RetiraAcento( oBol:Cedente), 30)  // 13.0 Nome da Empresa
         ::cLine += PAD( RetiraAcento( ::cNomeBco ),  30)  // 14.0 Nome do Banco
         ::cLine += SPAC(10)                               // 15.0 Uso Exclusivo FEBRABAN
         ::cLine += "1"                                    // 16.0 1 = Remessa(Cliente->Banco),  2 = Retorn(Banco->Cliente)
         ::cLine += ::cData                                // 17.0 Data da Geracao do Arquivo
         ::cLine += PAD( STRTRAN( TIME(), ":", ""), 6)     // 18.0 Hora da Geracao do Arquivo
         ::cLine += STRZERO( ::NumRemessa, 6 )             // 19.0 Numero Sequencial do Arquivo
         ::cLine += "050"                                  // 20.0 Numero da Versao do Layout do Arquivo
         ::cLine += REPL("0",5)                            // 21.0 Densidade
         ::cLine += SPAC(20)                               // 22.0 Uso Reservado do Banco
         ::cLine += PAD("REMESSA-PRODUCAO", 20 )           // 23.0 Uso Reservado da Empresa
         ::cLine += SPAC(04)                               // 24.0 Versao Aplicativo Caixa
         ::cLine += SPAC(25)                               // 25.0 Uso Exclusivo FEBRABAN
         ::Line()
         
         // Header Lote
         ::cLine += ::cCodBco                              // 01.1 Codigo do Banco
         ::cLine += "0001"                                 // 02.1 Lote de Servico
         ::cLine += "1"                                    // 03.1 Tipo de Registro
         ::cLine += "R"                                    // 04.1 Tipo de Operacao, (R)emessa, Re(T)orno
         ::cLine += "01"                                   // 05.1 Tipo de Servico, 01 Cobranca
         ::cLine += "00"                                   // 06.1 Uso Exclusivo FEBRABAN
         ::cLine += "030"                                  // 07.1 Numero da Versao do Layout do Lote
         ::cLine += SPAC(1)                                // 08.1 Uso Exclusivo FEBRABAN
         ::cLine += "2"                                    // 09.1 Tipo de Inscricao 0-Isento, 1-Cpf, 2-Cnpj, 3-Pis, 9-Outros
         ::cLine += PADL( oBol:CedenteCNPJ, 15, "0")       // 10.1 Numero Inscricao da Empresa
         ::cLine += oBol:cCDPF                             // 11.1 Cod. Cedente / Cod Convenio no Banco
         ::cLine += REPL("0",14)                           // 12.1 Uso Exclusivo da Caixa
         ::cLine += "0" + PADL( oBol:cNumAgencia, 4, "0" ) // 13.1 Numero Agencia 5 Digitos
         ::cLine += PAD(  oBol:cDvAgencia, 1 )             // 14.1 Dv Agencia
         ::cLine += oBol:cCDPF                             // 15.1 Cod. Cedente / Cod Convenio no Banco
         ::cLine += REPL( "0", 7 )                         // 16.1 Somente Cod. Mod. Bloqueto Personalizado / Autorizado Pela Caixa
         ::cLine += "0"                                    // 17.1 Uso Exclusivo da Caixa
         ::cLine += PAD( RetiraAcento( oBol:Cedente), 30)  // 18.1 Nome da Empresa
         ::cLine += PAD( oBol:Instrucoes,  40)             // 19.1 Mensagem 1
         ::cLine += PAD( oBol:Instrucoes2, 40)             // 20.1 Mensagem 2
         ::cLine += STRZERO( ::NumRemessa, 8 )             // 21.1 Numero da Remessa
         ::cLine += ::cData                                // 22.1 Data da Geracao do Arquivo
         ::cLine += REPL("0", 8)                           // 23.1 Data do Credito
         ::cLine += SPAC(33)                               // 24.1 Uso Exclusivo FEBRABAN
         ::Line()
      
      Else // Outros Bancos, Padrao CNAB240

        // Header Arquivo
        ::cLine += ::cCodBco                        // codigo do banco
        ::cLine += "0000"                           // lote de servico
        ::cLine += "0"                              // tipo de registro
        ::cLine += SPACE(9)                         // use exclusivo FEBRABAN
        ::cLine += "2"                              // tipo de inscricao 0-isento 1-cpf 2-cnpj 3-pis 9-outros
        ::cLine += PADL(str(val(oBol:CedenteCNPJ),,,.t.), 14, "0")  // numero da inscricao
        ::cLine += STRZERO(VAL(oBol:cCDPF), 20)     // convenio
        ::cLine += PADL(oBol:cNumAgencia, 5, "0")   // agencia
        ::cLine += pad(oBol:cDvAgencia,1)           // digito da agencia
        ::cLine += PADL(oBol:cNumCC, 12, "0")       // numero da conta corrente
        ::cLine += pad(oBol:cDvCC,1)                // digito da conta corrente
        ::cLine += pad(oBol:cDvAgCC,1)              // digito da agencia conta
        ::cLine += PAD(RetiraAcento(oBol:Cedente), 30) // nome da Empresa
        ::cLine += PAD(RetiraAcento(::cNomeBco), 30) // nome do banco
        ::cLine += SPACE(10)                        // uso exclusivo FEBRABAN
        ::cLine += "1"                              // remessa 1 - remessa 2 - retorno
        ::cLine += ::cData                          // Data da geracao do arquivo
        ::cLine += PAD(STRTRAN(TIME(), ":", ""), 6) // Hora da geracao
        ::cLine += STRZERO(::NumRemessa, 6)         // numero sequencial do arquivo
        ::cLine += "040"                            // Numero da Versão do Layout do arquivo
        ::cLine += '01600'                          // densidade
        ::cLine += SPACE(20)                        // para uso reservado do banco
        ::cLine += SPACE(20)                        // para uso reservado da empresa
        ::cLine += SPACE(14)                        // uso exclusivo FEBRABAN
        ::cLine += '000'                            //
        ::cLine += SPACE(12)                        // uso exclusivo FEBRABAN
        ::Line()

        // Header Lote
        ::cLine += ::cCodBco                       // codigo do banco
        ::cLine += "0001"                          // lote de servico
        ::cLine += "1"                             // tipo de registro
        ::cLine += "R"                             // tipo de operacao, R - remessa T - retorno
        ::cLine += "01"                            // tipo de servico 01 - cobranca
        ::cLine += SPACE(2)                        // uso exclusivo FEBRABAN
        ::cLine += "040"                           // Numero da Versão do Layout do arquivo
        ::cLine += SPACE(1)                        // uso exclusivo FEBRABAN
        ::cLine += "2"                             // tipo de inscricao 0-isento 1-cpf 2-cnpj 3-pis 9-outros
        ::cLine += PADL(oBol:CedenteCNPJ, 15, "0") // numero da inscricao
        ::cLine += STRZERO(VAL(oBol:cCDPF), 20)    // convenio
        ::cLine += PADL(oBol:cNumAgencia, 5, "0")  // agencia
        ::cLine += pad(oBol:cDvAgencia,1,0)        // digito da agencia
        ::cLine += PADL(oBol:cNumCC, 12, "0")      // numero da conta corrente
        ::cLine += pad(oBol:cDvCC,1)               // digito da conta corrente
        ::cLine += pad(oBol:cDvAgCC,1)             // digito da agencia conta
        ::cLine += PAD(RetiraAcento(oBol:Cedente), 30)// nome da Empresa

        ::cLine += PAD(oBol:Instrucoes, 40)        // mensagem 1
        ::cLine += PAD(oBol:Instrucoes2, 40)       // mensagem 2
        ::cLine += STRZERO(::NumRemessa, 8)        // numero da remessa
        ::cLine += ::cData                         // Data da geracao do arquivo
        ::cLine += "00000000"                      // data do credito
        ::cLine += SPACE(33)                       // uso exclusivo FEBRABAN
        ::Line()
      
      Endif

   ENDIF

RETURN ::nHandle

/* -------------------------------------------------------------------------- */

METHOD Add( oBol ) CLASS oRemessa

   LOCAL cMsg, cCart

   ::nTitLote++
   IF ::CNAB400
      ::cDtVenc := STRZERO(DAY(oBol:DtVenc), 2) + STRZERO(MONTH(oBol:DtVenc), 2) + RIGHT(STR(YEAR(oBol:DtVenc)), 2)
      DO CASE
      CASE ::cCodBco $ "001" // Banco do Brasil
          ::cLine += "7"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")
          ::cLine += oBol:cDvAgencia
          ::cLine += PADL(oBol:cNumCC, 8, "0")
          ::cLine += PADL(oBol:cDVCC, 1)
          ::cLine += STRZERO(VAL(oBol:cCDPF), 7) // No. do convencio com o banco
          ::cLine += PADL(oBol:cNumDoc, 25)
          ::cLine += PADL(oBol:cNossoNumero, 17, "0")
          ::cLine += "00"
          ::cLine += "00"
          ::cLine += SPACE(3)
          ::cLine += SPACE(1) // Indicativo de Sacador
          IF LEFT(oBol:cCarteira, 2) $ "31/51"
             ::cLine += "SD "
          ELSEIF LEFT(oBol:cCarteira, 2) $ "12"
             ::cLine += "AIU"
          ELSE
             ::cLine += "AI."
          ENDIF
          ::cLine += PADL(SUBSTR(oBol:cCarteira, 3), 3, "0") // Variacao da Carteira
          ::cLine += "0"
          ::cLine += REPLICATE("0", 6)
          ::cLine += SPACE(5) // Display Tipo de Cobranca
          ::cLine += "11"     // Cobranca Simples
          ::cLine += "01"     // Comando

          ::cLine += PAD(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += ::cCodBco
          ::cLine += PADL("", 5, "0") // Agencia-DV de Cobrança
          ::cLine += PAD(oBol:EspecieTit, 2) // Nota 10
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += PADL(::INSTRUCAO1, 2)
          ::cLine += PADL(::INSTRUCAO2, 2)
          ::cLine += STRZERO(oBol:nValMora * 100, 13)

          ::cLine += PAD(::DTDESC, 6, " ")
          ::cLine += STRZERO(0, 13)    // Valor de Desconto
          ::cLine += STRZERO(0, 13)    // Valor do IOF
          ::cLine += STRZERO(0, 13)    // Valor do Abatimento

          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(oBol:cCPF, 14, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 37) + SPACE(3)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 37)
          ::cLine += SPACE(15)
          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)

          ::cLine += SPACE(40) //PAD(oBol:Avalista, 30)
          ::cLine += STRZERO(oBol:nDiasProt, 2) // Prazo de Protesto
          ::cLine += " "

      CASE ::cCodBco $ "237" // Bradesco

          ::cLine += "1"
          ::cLine += REPL('0',19)
          ::cLine += "0" + STRZERO(VAL(oBol:cCarteira),3) + PADL(oBol:cNumAgencia, 5, "0")
          ::cLine += PADL(oBol:cNumCC, 7, "0") + str(val(oBol:cDvCC),1)
          ::cLine += PADL(oBol:cNumDoc, 25)
          ::cLine += "000" // banco debito automatico
          ::cLine += "00000" //zeros
          IF val(oBol:cNossoNumero) # 0
              ::cLine += padl(oBol:cNumAgencia ,4 ,"0") +;
                         padl(oBol:cNossoNumero,7 ,"0") +oBol:cDGNN
          ELSE
              ::cLine += replicate("0",12)
          ENDIF
          ::cLine += STRZERO(0, 10)
          ::cLine += SPACE(2)
          ::cLine += SPACE(10) //espaco
          ::cLine += SPACE(4)
          ::cLine += "01" // REMESSA
          ::cLine += PADL(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += "000"
          ::cLine += "00000"
          ::cLine += PAD(oBol:EspecieTit, 2) // especie titulo
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += PADL(::INSTRUCAO1, 2)
          ::cLine += PADL(::INSTRUCAO2, 2)
          ::cLine += STRZERO(oBol:nValMora * 100, 13)
          ::cLine += PAD(::DTDESC, 6, " ") // dtdesc
          ::cLine += STRZERO(0, 13) // Valor de Desconto
          ::cLine += STRZERO(0, 13) // Valor do IOF
          ::cLine += STRZERO(0, 13) // Valor do Abatimento
          IF EMPTY(oBol:cCPF)
             ::cLine += "02" //::nHandle, "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01" //::nHandle, "01"
             ::cLine += PADL(oBol:cCPF, 14, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40)
          ::cLine += SPACE(12)
          ::cLine += PAD(oBol:CEP, 8)

          cMsg := STRTRAN(oBol:INSTRUCOES, CRLF, " ")
          cMsg := STRTRAN(cMsg, "<BR>", " ")
          ::cLine += PAD(cMsg, 60)
          cMsg := SUBSTR(cMsg, 61)

          WHILE !EMPTY(cMsg)
              ::Line()
              ::cLine += "2"  // registro de mensagem
              ::cLine += PAD(cMsg, 320, " ")
              ::cLine += SPACE(45)
              ::cLine += STRZERO(VAL(oBol:cCarteira), 3)
              ::cLine += PADL(oBol:cNumAgencia, 05, "0")
              ::cLine += PADL(oBol:cNumCC, 7, "0") + STR(VAL(oBol:cDvCC), 1)
              IF VAL(oBol:cNossoNumero) # 0
                 ::cLine += PADL(oBol:cNumAgencia , 4, "0") +;
                            PADL(oBol:cNossoNumero, 7, "0") + oBol:cDGNN
               ELSE
                 ::cLine += REPLICATE("0",12)
              ENDIF
              cMsg := SUBSTR(cMsg, 321)
          END

      CASE ::cCodBco $ "341/739" // Itau ou BGN
          ::cLine += "1"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")

          ::cLine += "00"
          ::cLine += PADL(oBol:cNumCC, 5, "0")
          ::cLine += PADL(oBol:cDVCC, 1)
          ::cLine += SPACE(4)
          ::cLine += PADL("", 4, " ") // "0" COD.INSTRUCAO - NOTA 27
          ::cLine += PADL(oBol:cNumDoc, 25)
          ::cLine += PADL(oBol:cNossoNumero, 08, "0")
          ::cLine += PADL("", 13, "0") // QTD. MOEDA VARIAVEL - NOTA 4
          ::cLine += PADL(oBol:cCarteira, 3, "0") // NOTA 5
          ::cLine += SPACE(21) // USO DO BANCO
          ::cLine += PADL(oBol:TpCarteira, 1, "0") // NOTA 5
          ::cLine += PADL(::OCORRENCIA, 2) // Codigo da Ocorrência - NOTA 6

          ::cLine += PAD(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += ::cCodBco
          ::cLine += PADL("", 5, "0") // Agencia de Cobrança - NOTA 9
          ::cLine += PAD(oBol:EspecieTit, 2) // Nota 10
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += PADL(::INSTRUCAO1, 2)
          ::cLine += PADL(::INSTRUCAO2, 2)
          ::cLine += STRZERO(oBol:nValMora * 100, 13)

          ::cLine += PAD(::DTDESC, 6, " ")

          ::cLine += STRZERO(0, 13)    // Valor de Desconto
          ::cLine += STRZERO(0, 13)    // Valor do IOF
          ::cLine += STRZERO(0, 13)    // Valor do Abatimento

          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(oBol:cCPF, 14, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40)
          ::cLine += PAD(RetiraAcento(oBol:Bairro), 12)
          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)

          ::cLine += SPACE(30) //PAD(oBol:Avalista, 30)
          ::cLine += SPACE(04)
          ::cLine += ::cDtVenc                  // Data de Mora
          ::cLine += STRZERO(oBol:nDiasProt, 2) // Prazo de Protesto
          ::cLine += " "

      CASE ::cCodBco $ "356" // Real
          ::cLine += "1"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")
          ::cLine += "0"
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")
          ::cLine += "0"

          ::cLine += PADL(oBol:cNumCC, 7, "0")
          ::cLine += SPACE(7)
          ::cLine += PADL("", 25, " ") // Campo Especial - Uso Livre do Cedente
          ::cLine += "00"
          ::cLine += PADL(oBol:cNossoNumero, 07, "0")
          ::cLine += "0" // Incidencia de Multa 0-Valor do Titulo 1-Valor Corrigido
          ::cLine += "00" // (n) Dias apos o Vencimento para Multa
          ::cLine += "0" // Multa por 0-Valor 1-Taxa
          ::cLine += STRZERO(oBol:nValMulta * 100, 13)
          ::cLine += SPACE(7)
          ::cLine += PADL(0, 09, "0") // Numero do Contrato - Cobranca Real ou Caucionada
          ::cLine += SPACE(3)
          ::cLine += PAD(oBol:cTipoCob, 1) // Cobranca 1-Simples 5-Escritural
          ::cLine += "01" // Ocorrencia - Entrada

          ::cLine += PAD(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += ::cCodBco
          ::cLine += STRZERO(0, 5) // Agencia Cobradora
          ::cLine += PAD(oBol:EspecieTit, 2)
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += STRZERO(oBol:nDiasProt, 2) // Prazo de Protesto
          ::cLine += SPACE(2)
          ::cLine += "0" // Multa por 0-Valor 1-Taxa
          ::cLine += STRZERO(oBol:nValMora * 100, 12)
          ::cLine += PAD(::DTDESC, 6, " ")
          ::cLine += STRZERO(0, 13)    // Valor de Desconto
          ::cLine += STRZERO(0, 13)    // Valor do IOC
          ::cLine += STRZERO(0, 13)    // Valor do Abatimento

          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(LEFT(oBol:cCPF, 9), 9, "0")
             ::cLine += "000"
             ::cLine += PADL(RIGHT(oBol:cCPF, 2), 2, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40)
          ::cLine += PAD(RetiraAcento(oBol:Bairro), 12)
          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)
          ::cLine += SPACE(40) //PAD(oBol:Avalista, 40)
          ::cLine += "0" // 0-Reais 1-Moeda
          ::cLine += "07" // 07-Real

          ::nVlrSimples  += oBol:nValor

      CASE ::cCodBco $ "399" // HSBC
          ::cLine += "1"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")
          ::cLine += "0"
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")
          ::cLine += "55"
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")
          ::cLine += PAD(oBol:cNumCC + oBol:cDvCC, 7)
          ::cLine += SPACE(2)
          ::cLine += PADL("", 25, " ") // Campo Especial - Uso Livre do Cedente
          ::cLine += PADL(oBol:cNossoNumero + oBol:cDGNN, 11, "0")
          ::cLine += PAD(::DTDESC, 6, "0")
          ::cLine += STRZERO(0, 11)    // Valor de Desconto
          ::cLine += PAD(::DTDESC, 6, "0")
          ::cLine += STRZERO(0, 11)    // Valor de Desconto
          ::cLine += PAD(oBol:cTipoCob, 1) // Cobranca 1-Simples 5-Escritural
          ::cLine += "01" // Ocorrencia - Remessa-Entrada
          ::cLine += PAD(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc

          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += ::cCodBco
          ::cLine += PADL(0, 05, "0") // Agência...
          ::cLine += PAD(oBol:EspecieTit, 2)
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += "00" // 1ª INSTRUÇÃO
          ::cLine += "00" // 2ª INSTRUÇÃO
          ::cLine += STRZERO(oBol:nValMora * 100, 13)
          ::cLine += PAD(::DTDESC, 6, " ")
          ::cLine += STRZERO(0, 13)    // Valor de Desconto
          ::cLine += STRZERO(0, 13)    // Valor do IOF
          ::cLine += STRZERO(0, 13)    // Valor do Abatimento
          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(LEFT(oBol:cCPF, 9), 9, "0")
             ::cLine += "000"
             ::cLine += PADL(RIGHT(oBol:cCPF, 2), 2, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 38)
          ::cLine += "  "
          ::cLine += PAD(RetiraAcento(oBol:Bairro), 12)
          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)
          ::cLine += SPACE(39) //PAD(oBol:Avalista, 39)
          ::cLine += " " // Tipo de Bloqueto
          ::cLine += "  " // Prazo de Protesto
          ::cLine += "9" //

      CASE ::cCodBco $ "409" // Unibanco
          ::cLine += "1"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")
          ::cLine += PADL(oBol:cNumAgencia, 4, "0")

          ::cLine += PADL(VAL(oBol:cNumCC), 6, "0")
          ::cLine += oBol:cDVCC
          ::cLine += STRZERO(0, 9)
          ::cLine += PADL(oBol:cNumDoc, 25, "0")
          ::cLine += PADL(oBol:cNossoNumero, 10, "0")
          ::cLine += oBol:cDGNN
          ::cLine += PADL(::MENSAGEM, 30)
          ::cLine += PADL("", 4)
          ::cLine += PADL(oBol:cCarteira, 1)
          ::cLine += PADL(::OCORRENCIA, 2)

          ::cLine += PAD(oBol:cNumDoc, 10)
          ::cLine += ::cDtVenc
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += ::cCodBco
          ::cLine += PADL("", 5, "0") // Agencia de Cobrança - NOTA 9
          ::cLine += PAD(oBol:EspecieTit, 2) // Nota 10
          ::cLine += "N"
          ::cLine += ::cData
          ::cLine += PADL(::INSTRUCAO1, 2)
          ::cLine += PADL(::INSTRUCAO2, 2)
          ::cLine += STRZERO(oBol:nValMora * 100, 13)

          ::cLine += PAD(TRIM(::DTDESC), 6, "0")

          ::cLine += STRZERO(0, 13)    // Valor de Desconto
          ::cLine += STRZERO(0, 13)    // Valor do IOF
          ::cLine += STRZERO(0, 13)    // Valor do Abatimento

          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(oBol:cCPF, 14, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40)
          ::cLine += PAD(RetiraAcento(oBol:Bairro), 12)
          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)
          ::cLine += SPACE(30) //PAD(oBol:Avalista, 30)
          ::cLine += STRZERO(0, 10)
          ::cLine += IF(::INSTRUCAO1 + ::INSTRUCAO2 == "0000", "00", STRZERO(oBol:nDiasProt, 2)) // Prazo de Protesto
          ::cLine += "0"

      CASE ::cCodBco $ "422" // Carteira Vinculada e Simples, o que muda e oBOL:cCDPF fornecido pelo bco 25/09/2006
          ::cLine += "1"
          ::cLine += "02"
          ::cLine += PADL(oBol:CedenteCNPJ, 14, "0")

          ::cLine += PAD(oBol:cCDPF,14)

          ::cLine += SPACE(06)
          ::cLine += SPACE(25)

          ::cLine += "000000000" // NUMERO TITULO DO BANCO USO BANCO QDO GERAR BOLETO PELO BCO POR ZEROS 25/09/2006

          ::cLine += SPACE(30)
          ::cLine += "0"
          ::cLine += "00" // COD MOEDA REAL
          ::cLine += " "
          ::cLine += "00" // NUMERO DE DIAS PARA PROTESTO
          ::cLine += "2"  // COD CARTEIRA = 2 VINCULADA
          ::cLine += "01" // COD OCORRENCIA 01=REMESSA DE TITULOS
          ::cLine += PADL(oBol:cNumDoc, 10, "0")
          ::cLine += ::cDtVenc // Data de VECTO
          ::cLine += STRZERO(oBol:nValor * 100, 13)
          ::cLine += "422"
          ::cLine += "00000"
          ::cLine += "01"  // DUPLICATA
          ::cLine += "N"
          ::cLine += ::cData

          ::cLine += "01"   // TABELA SAFRA 6.1.5 (25/09/2006)
          ::cLine += PADL(::INSTRUCAO2, 2)

          ::cLine += STRZERO((oBol:nValor*oBol:nMora), 13)

          ::cLine += PAD(::DTDESC, 6, "0") // dtdesc COLOCAR ZERO SE NAO HOUVER DESCONTOS (25/09/2006)
          ::cLine += STRZERO(0, 13) // Valor de Desconto
          ::cLine += STRZERO(0, 13) // Valor do IOF
          ::cLine += STRZERO(0, 13) // Valor do Abatimento

          IF EMPTY(oBol:cCPF)
             ::cLine += "02"
             ::cLine += PADL(oBol:cCNPJ, 14, "0")
          ELSE
             ::cLine += "01"
             ::cLine += PADL(oBol:cCPF, 14, "0")
          ENDIF
          ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)
          ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40)
          ::cLine += PAD(RetiraAcento(oBol:Bairro), 10)
          ::cLine += "  "

          ::cLine += PAD(oBol:CEP, 8)
          ::cLine += PAD(oBol:Cidade, 15)
          ::cLine += PAD(oBol:Estado, 2)
          ::cLine += SPACE(30)
          ::cLine += SPACE(07)
          ::cLine += "422"
          ::cLine +="   "

      ENDCASE

   ELSE // FEBRABAN

      ::cDtVenc := STRZERO(DAY(oBol:DtVenc), 2) + STRZERO(MONTH(oBol:DtVenc), 2) + RIGHT(STR(YEAR(oBol:DtVenc)), 4)

      cCart := "01"

      If ::cCodBco == "104" // Caixa CNAB240 SIGCB, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09

         If oBol:cCarteira = '1' // Cobranca Simples
            ::nQtdSimples++
            ::nVlrSimples += oBol:nValor
            cCart := "1"
         Endif

      Else

        IF oBol:cCarteira = '11'          // cobranca simples
           ::nQtdSimples++
           ::nVlrSimples += oBol:nValor
        ELSEIF oBol:cCarteira = '31'      // cobranca vinculada
           ::nQtdVinculada++
           ::nVlrVinculada += oBol:nValor
           cCart := "02"
        ELSEIF oBol:cCarteira = '71'      // cobranca caucionada
           ::nQtdCaucionada++
           ::nVlrCaucionada += oBol:nValor
           cCart := "03"
        ELSEIF oBol:cCarteira = '51'      // cobranca descontada
           ::nQtdDescontada++
           ::nVlrDescontada += oBol:nValor
           cCart := "04"
        ENDIF

      Endif

      If ::cCodBco == "104" // Caixa CNAB240 SIGCB, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09

         // Registro Detalhe Segmento P

         ::cLine += ::cCodBco                       // 01.3P Codigo do Banco
         ::cLine += "0001"                          // 02.3P Lote de Servico
         ::cLine += "3"                             // 03.3P Tipo de Registro
         ::cLine += STRZERO( ++::nSeqReg, 5 )       // 04.3P Numero Sequencia no Lote
         ::cLine += "P"                             // 05.3P Segmento P
         ::cLine += SPAC(1)                         // 06.3P Exclusivo FEBRABAN
         ::cLine += "01"                            // 07.3P Codigo do Movimento 01 - Entrada de Titulos
         ::cLine += PADL( oBol:cNumAgencia, 5, "0") // 08.3P Agencia
         ::cLine += PADL( oBol:cDvAgencia,  1, "0") // 09.3P Dv Agencia
         ::cLine += oBol:cCDPF                      // 10.3P Cod. Cedente / Cod Convenio no Banco
         ::cLine += REPL("0", 11 )                  // 11.3P Exclusivo Caixa
         ::cLine += oBol:cTipoCob                   // 12.3P Modalidade Nosso Numero P/ Cobranca (Ex: 14 = (1)Registrada + (4)Emissao Cedente ) / (1)Registrada, (2)Sem Registro / (4)Emissao Cedente, (1)Caixa Via Correio, Agencia ou Email ( Forma de Envio )
         ::cLine += PADL(oBol:cNossoNumero, 15,"0") // 13.3P Nosso Numero
         ::cLine += oBol:cCarteira                  // 14.3P Cod. Carteira, 1 Simples
         ::cLine += "1"                             // 15.3P Forma de Cadastramento do Titulo, 1 Cobranca Registrada, 2 Cobranca Sem Registro
         ::cLine += "2"                             // 16.3P Tipo de Documento, 1 Tradicional, 2 Escritural
         ::cLine += "2"                             // 17.3P Identificacao da Emissao do Bloqueto, 1 Banco Emite, 2 Cliente Emite
         ::cLine += "0"                             // 18.3P Identificacao da Entrega do Bloqueto, 0 Postagem Pelo Cedente, 1 Sacado Via Correios, 2 Cedente Via Agencia Caixa
         ::cLine += PAD( oBol:cNumDoc, 11, "0")     // 19.3P Numero de Documento Cobranca, Seu N§
         ::cLine += SPAC(4)                         // 20.3P Exclusivo Caixa
         ::cLine += ::cDtVenc                       // 21.3P Data Vencimento Titulo
         ::cLine += STRZERO(oBol:nValor * 100, 15 ) // 22.3P Valor do Titulo
         ::cLine += Repl("0",5)                     // 23.3P Agencia Encarregada da Cobranca
         ::cLine += "0"                             // 24.3P Dv Agencia
         ::cLine += "02"                            // 25.3P Especie do Titulo, 02 = DM (Duplicata Mercantil)
         ::cLine += "N"                             // 26.3P Identificao de Titulo, (A) = Aceite, (N) = Nao Aceite // Obs (A)ceite so tem funcionalidade quando o banco imprime e entrega os boletos
         ::cLine += ::cData                         // 27.3P Data Emissao do Titulo

         // 28.3P Codigo do Juros de Mora, 1 Valor Por Dia, 2 Taxa Mensal, 3 Isento, 4 Acata Cadastro Caixa
         // 29.3P Data Juros de Mora, Vencimento
         If oBol:nValMora == 0
            ::cLine += "3"                          
            ::cLine += "00000000"                   
         Else                   
            ::cLine += "1"                          
            ::cLine += ::cDtVenc                    
         Endif

         ::cLine += STRZERO( oBol:nValMora * 100, 15) // 30.3P Valor dos Juros de Mora Por Dia
         ::cLine += "0"                               // 31.3P Codigo do Desconto, 0 Sem Desconto
         ::cLine += "00000000"                        // 32.3P Data do Desconto
         ::cLine += STRZERO(0, 15)                    // 33.3P Valor do Desconto
         ::cLine += STRZERO(0, 15)                    // 34.3P Valor do IOF
         ::cLine += STRZERO(0, 15)                    // 35.3P Valor do Abatimento
         ::cLine += PAD( oBol: cNumDoc, 25 )          // 36.3P Identificacao do Titulo na Empresa

         // Codigo Para Protesto, 1 Protestar, 3 Nao Protestar, 9 Cancelamento Protesto Automatico
         If oBol:nDiasProt > 0
            ::cLine += "1"                            // 37.3P Codigo do Protesto
            ::cLine += STRZERO( oBol:nDiasProt, 2 )   // 38.3P Protestar em (nDiasProt) Dias Uteis
            ::cLine += "2"                            // 39.3P Codigo Para Baixa Devolucao, 1 Baixar e Devolver,  2 Nao Baixar e Nao Devolver / Obs (1) Somente Quando nao Protestar
            ::cLine += "000"                          // 40.3P Numero de Dias Para Baixa Devolucao, de 005 a 120 Dias Corridos / (000) Somente Quando Nao Baixar e Nao  Devolver 
         Else
            ::cLine += "3"
            ::cLine += "00"
            ::cLine += "1"                            // 39.3P Codigo Para Baixa Devolucao, 1 Baixar e Devolver,  2 Nao Baixar e Nao Devolver / Obs (1) Somente Quando nao Protestar
            ::cLine += "090"                          // 40.3P Numero de Dias Para Baixa Devolucao, de 005 a 120 Dias Corridos / (000) Somente Quando Nao Baixar e Nao  Devolver 
         Endif
         
         ::cLine += "09"                              // 41.3P Codigo da Moeda 09 R$
         ::cLine += REPL("0", 10 )                    // 42.3P Exclusivo Caixa
         ::cLine += SPAC(1)                           // 43.3P Exclusivo FEBRABAN
         ::Line()
         

         // Registro Detalhe Segmento Q

         ::cLine += ::cCodBco                         // 01.3Q Codigo do Banco
         ::cLine += "0001"                            // 02.3Q Lote de Servico
         ::cLine += "3"                               // 03.3Q Tipo de Registro
         ::cLine += STRZERO( ++::nSeqReg, 5)          // 04.3Q Numero Sequencial do Registro Lote
         ::cLine += "Q"                               // 05.3Q Segmento Q
         ::cLine += SPAC(1)                           // 06.3Q Exclusivo FEBRABAN
         ::cLine += "01"                              // 07.3Q Codigo do Movimento 01 - Entrada de Titulos
                                                           
         // 08.3Q Tipo de Inscricao, 1 CPF, 2 CNPJ
         IF LEN( oBol:CNPJ ) < 14
            ::cLine += "1"
         ELSE
            ::cLine += "2"
         ENDIF

         ::cLine += PADL( oBol:CNPJ, 15, "0" )                // 09.3Q Numero de Inscricao, CPF / CNPJ
         ::cLine += PAD( RetiraAcento( oBol:SACADO ), 40 )    // 10.3Q Nome Sacado
         ::cLine += PAD( RetiraAcento( oBol:Endereco1 ), 40 ) // 11.3Q Endereco
         ::cLine += PAD( RetiraAcento( oBol:Bairro ), 15 )    // 12.3Q Bairro
         ::cLine += PAD( oBol:CEP, 8 )                        // 13.3Q/14.3Q CEP(5)+Sufixo(3)
         ::cLine += PAD( RetiraAcento( oBol:Cidade ), 15 )    // 15.3Q Cidade
         ::cLine += PAD( oBol:Estado, 2 )                     // 16.3Q UF
         ::cLine += "0"                                       // 17.3Q Tipo de Inscricao Avalista
         ::cLine += REPL("0", 15 )                            // 18.3Q Numero de Inscricao Avalista
         ::cLine += SPAC(40)                                  // 19.3Q Nome do Avalista
         ::cLine += SPAC(03)                                  // 20.3Q Banco Correspondente
         ::cLine += SPAC(20)                                  // 21.3Q Nosso Numero no Banco Correspondente
         ::cLine += SPAC(08)                                  // 22.3Q Exclusivo FEBRABAN
    
     Else // Outros Bancos, Padrao CNAB240

         // Registro detalhe Segmento P
         ::cLine += ::cCodBco                      // codigo do banco
         ::cLine += "0001"                         // lote de servico
         ::cLine += "3"                            // tipo de registro
         ::cLine += STRZERO(++::nSeqReg, 5)        // numero sequencia no lote
         ::cLine += "P"                            // segmento
         ::cLine += SPACE(1)                       // uso exclusivo FEBRABAN
         ::cLine += "01"                           // codigo do movimento 01 - entrada de titulos
         ::cLine += PADL(oBol:cNumAgencia, 5, "0") // agencia
         ::cLine += PADL(oBol:cDvAgencia,1,"0")    // digito da agencia
         ::cLine += PADL(oBol:cNumCC, 12, "0")     // numero da conta corrente
         ::cLine += SPACE(2)                       //
         ::cLine += padl(oBol:cCarteira,2,"0")     // carteira
         ::cLine += "00000"                        //
         ::cLine += PADL(oBol:cNossoNumero, 13,"0") // nosso numero
         
         ::cLine += "000"                          //
         ::cLine += "2"                            // emissao do bloqueto 1 - banco emite
         ::cLine += " "                            //
         ::cLine += PAD(oBol:cNumDoc, 15)          // documento
         ::cLine += ::cDtVenc                      // vencimento
         ::cLine += STRZERO(oBol:nValor * 100, 15) // valor do titulo
         ::cLine += "00000"                        //
         ::cLine += " "                            //
         ::cLine += "04"                           //
         ::cLine += PAD(oBol:Aceite, 1)            // aceite do titulo
         ::cLine += ::cData                        // emissao
         IF oBol:nValMora == 0
            ::cLine += "3"                            // codigo do juros de mora 3 - isento
            ::cLine += "00000000"                    // vencimento
         else
            ::cLine += "1"                            // codigo do juros de mora 1 - valor por dia
            ::cLine += ::cDtVenc                      // vencimento
         ENDIF
         ::cLine += STRZERO(oBol:nValMora*100, 15) // valor dos juros por dia
         
         ::cLine += "0"                            // codigo do desconto
         ::cLine += "00000000"                     // Data do desconto
         ::cLine += STRZERO(0, 15)                 // Valor de Desconto
         ::cLine += STRZERO(0, 15)                 // Valor do IOF
         ::cLine += STRZERO(0, 15)                 // Valor do Abatimento
         ::cLine += PAD(oBol:cNumDoc, 25)          // identificacao do titulo na empresa
         IF oBol:nDiasProt > 0
            ::cLine += "2"                         // codigo do protesto protestar dias uteis
            ::cLine += STRZERO(oBol:nDiasProt, 2)  // protestar em (nDiasProt) dias
         ELSE
            ::cLine += "3"
            ::cLine += "00"
         ENDIF
         ::cLine += "0"                               //
         ::cLine += "   "                               //
         ::cLine += "09"                              // moeda
         ::cLine += "0000000000"                      // numero do contrato da operacao de credito
         ::cLine += SPACE(1)                          // use exclusivo FEBRABAN
         ::Line()                                     // imprime
         
         // Registro detalhe segmento Q
         ::cLine += ::cCodBco                      // codigo do banco
         ::cLine += "0001"                         // lote de servico
         ::cLine += "3"                            // tipo de registro
         ::cLine += STRZERO(++::nSeqReg, 5)        // numero sequencia no lote
         ::cLine += "Q"                            // segmento
         ::cLine += SPACE(1)                       // uso exclusivo FEBRABAN
         ::cLine += "01"                           // codigo do movimento 01 - entrada de titulos
         IF EMPTY(oBol:cCPF)
            ::cLine += "2"
         ELSE
            ::cLine += "1"
         ENDIF
         ::cLine += PADL(oBol:CNPJ, 15, "0")
         ::cLine += PAD(RetiraAcento(oBol:SACADO), 40)    // nome do sacado
         ::cLine += PAD(RetiraAcento(oBol:Endereco1), 40) // endereco
         ::cLine += PAD(RetiraAcento(oBol:Bairro), 15)    // bairro
         ::cLine += PAD(oBol:CEP, 8)                      // cep
         ::cLine += PAD(RetiraAcento(oBol:Cidade), 15)    // cidade
         ::cLine += PAD(oBol:Estado, 2)                   // UF
         ::cLine += "0"                            // tipo de inscricao avalista
         ::cLine += "000000000000000"              // tipo da inscricao
         ::cLine += SPACE(40)                      // nome do avalista
         ::cLine += "000"                          // banco correspondente
         ::cLine += SPACE(20)                      // nome do banco correspondente
         ::cLine += SPACE(8)                       // uso exclusivo FEBRABAN

     Endif
         
   ENDIF

   ::Line()

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Close() CLASS oRemessa

   IF ::nTitLote < 1
      FCLOSE(::nHandle)
      FERASE(::Destino + ::NomeRem)
      IF !FILE(::Destino + ::NomeRem)
         ::NomeRem := ""
      ENDIF
   ELSE
      IF ::CNAB400
         IF ::cCodBco $ "356" // Real
            ::cLine += "9" + STRZERO((::nTitLote), 6) + STRZERO(::nVlrSimples * 100, 13) +;
                       REPLICATE(::cFillTrailer, 374)
         ELSE
            ::cLine += "9" + REPLICATE(::cFillTrailer, 393) // conforme os manuais devem ser 'brancos'

         ENDIF

      ELSE

         If ::cCodBco == "104" // Caixa CNAB240 SIGCB, by SysTux (Toninho Silva), systux@yahoo.com.br, 30/10/09

             // Trailer de Lote
             ::cLine += ::cCodBco                             // 01.5 Codigo do Banco
             ::cLine += "0001"                                // 02.5 Lote de Servico
             ::cLine += "5"                                   // 03.5 Tipo de Registro
             ::cLine += SPAC(9)                               // 04.5 Exclusivo FEBRABAN
             ::cLine += STRZERO( ( ::nSeqReg + 2 ), 6 )       // 05.5 Quantidade de Registros no Lote
             ::cLine += STRZERO( ::nQtdSimples, 6 )           // 06.5 Qtde de Titulos - Cobranca Simples
             ::cLine += STRZERO( ::nVlrSimples * 100, 17 )    // 07.5 Valor Total - Cobranca Simples
             ::cLine += STRZERO( ::nQtdCaucionada, 6 )        // 08.5 Qtde de Titulos - Cobranca Caucionada
             ::cLine += STRZERO( ::nVlrCaucionada * 100, 17 ) // 09.5 Valor Total - Cobranca Caucionada
             ::cLine += STRZERO( ::nQtdDescontada, 6 )        // 10.5 Qtde de Titulos - Cobranca Descontada
             ::cLine += STRZERO( ::nVlrDescontada * 100, 17 ) // 11.5 Valor Total - Cobranca Descontada
             ::cLine += SPAC(31)                              // 12.5 Exclusivo FEBRABAN
             ::cLine += SPAC(117)                             // 13.5 Exclusivo FEBRABAN
             ::Line()
             
             // Trailer de Arquivo
             ::cLine += ::cCodBco                       // 01.9 Codigo do Banco
             ::cLine += "9999"                          // 02.9 Lote de Servico
             ::cLine += "9"                             // 03.9 Tipo de Registro
             ::cLine += SPAC(9)                         // 04.9 Exclusivo FEBRABAN
             ::cLine += "000001"                        // 05.9 Quantidade de Lotes do Arquivo
             ::cLine += STRZERO( ( ::nSeqReg + 4 ), 6 ) // 06.9 Quantidade de Registros do Arquivo
             ::cLine += SPAC(6)                         // 07.9 Exclusivo FEBRABAN
             ::cLine += SPAC(205)                       // 08.9 Exclusivo FEBRABAN

         Else // Outros Bancos, Padrao CNAB240

            // Trailer Lote
            ::cLine += ::cCodBco                             // codigo do banco
            ::cLine += "0001"                                // lote de servico
            ::cLine += "5"                                   // tipo de registro
            ::cLine += SPACE(9)                              // use exclusivo FEBRABAN
            ::cLine += STRZERO((::nSeqReg+2), 6)              // quantidade de registros no lote
            ::cLine += replicate("0",92)                     // use exclusivo Banco
            //::cLine += STRZERO(::nQtdSimples, 6)             // Número de Titulos - Cobrança Simples
            //::cLine += STRZERO(::nVlrSimples * 100, 17)      // Valor Total - Cobrança Simples
            //::cLine += STRZERO(::nQtdVinculada, 6)           // Número de Titulos - Cobrança Vinculada
            //::cLine += STRZERO(::nVlrVinculada * 100, 17)    // Valor Total - Cobrança Vinculada
            //::cLine += STRZERO(::nQtdCaucionada, 6)          // Número de Titulos - Cobrança Caucionada
            //::cLine += STRZERO(::nVlrCaucionada * 100, 17)   // Valor Total - Cobrança Caucionada
            //::cLine += STRZERO(::nQtdDescontada, 6)          // Número de Titulos - Cobrança Descontada
            //::cLine += STRZERO(::nVlrDescontada * 100, 17)   // Valor Total - Cobrança Descontada
            ::cLine += "00000000"                            // numero do aviso de lancamento
            ::cLine += SPACE(117)                            // uso exclusivo FEBRABAN
            ::Line()

            // Trailer Arquivo
            ::cLine += ::cCodBco                    // codigo do banco
            ::cLine += "9999"                       // lote de servico
            ::cLine += "9"                          // tipo de registro
            ::cLine += SPACE(9)                     // use exclusivo FEBRABAN
            ::cLine += "000001"                     // Quantidade de lotes do arquivo
            ::cLine += STRZERO((::nSeqReg+4), 6)   // Quantidade de registros do arquivo
            ::cLine += "000000"                     // Quantidade de contas p/conc (lotes) especifico para conciliacao bancaria
            ::cLine += SPACE(205)                   // uso exclusivo FEBRABAN

         Endif

      ENDIF

      ::Line()
      FCLOSE(::nHandle)

   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */

METHOD Line() CLASS oRemessa

   ::cLine := UPPER(::cLine)
   IF ::CNAB400
      ::cLine += STRZERO(++::nSeqReg, 6)
      FWRITE(::nHandle, ::cLine + CRLF)
      IF LEN(::cLine) != 400 // Erro!
         FWRITE(::nHandle, STRZERO(LEN(::cLine), 5) + CRLF)
         Throw(ErrorNew("oRemessa", 0, 400, ProcName(), "Arquivos CNAB400 possuem 400 bytes por registro" + " (" + LTRIM(STR(LEN(::cLine))) + ")", HB_aParams()))
      ENDIF
   ELSE
      FWRITE(::nHandle, ::cLine + CRLF)
      IF LEN(::cLine) != 240 // Erro!
         FWRITE(::nHandle, STRZERO(LEN(::cLine), 5) + CRLF)
         Throw(ErrorNew("oRemessa", 0, 240, ProcName(), "Arquivos FEBRABAN possuem 240 bytes por registro" + " (" + LTRIM(STR(LEN(::cLine))) + ")", HB_aParams()))
      ENDIF
   ENDIF
   ::cLine := ""

RETURN Self

// eof
