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

/* Exemplo de utilizacao

func main()

   set date to brit
   altd(.t.)
   altd()
    oRet:=oRetorno("237")

    IF oRet:cCodBco=="237"
       
       DO WHILE !oRet:eof()
           ? "dados do titulo"
           IF oRet:isPago
              ? "o Titulo abaixo foi pago"
           ENDIF
           IF oRet:isOk
              ? "o Titulo foi processado"
           ENDIF
           ? "Nosso Numero:" + oRet:cNossoNumero
           ? "Vencimento  :" + dtoc(oRet:DtVenc)
           ? "Pago/processado:" + dtoc(oRet:DtPagto)
           ? "a quantia de:" + str(oRet:nValor)
           ? "a Multa foi :" + str(oRet:nMulta)
           ? "Documento No:" + oRet:cNumDoc
           ? "no Banco: " + oRet:cBcoPag
           ? "na agencia " + oRet:cNumAgencia
           ? "Ocorrencia: "+ oRet:cOcorrencia
           ? "Descricao: "+oRet:cDescOcorrencia
           ? "Codigo da rejeicao:" + oRet:cRejeicao
           oRet:Next()
           inkey(0)
       ENDDO
    ENDIF

*/

#include "harbourboleto.ch"
#include "fileio.ch"
#include "hbclass.ch"

CLASS oRetorno

DATA cLine           INIT ""  PROTECTED

DATA nHandle         INIT 0   PROTECTED  // link - Arquivo Retorno (Fopen)
DATA nLen            INIT 0   PROTECTED  // tamanho do arquivo de retorno em bytes

DATA cCodBco         INIT ""  READONLY
DATA cNomeBco        INIT ""  READONLY
DATA DtVenc          INIT ctod("") READONLY   // Data de vencimento no Formato data
DATA DtPagto         INIT ctod("") READONLY   // Data de pagamento no Formato data
DATA nValor          INIT 0   READONLY   // Valor Recebido
DATA nMulta          INIT 0   READONLY   // Valor da Multa
DATA cNumDoc         INIT ""  READONLY
DATA cNossoNumero    INIT ""  READONLY
DATA cBcoPag         INIT ""  READONLY // Banco onde foi feito o pagamento
DATA cNumAgencia     INIT ""  READONLY //  Agencia onde foi feito o pagamento
DATA cRejeicao       INIT ""   READONLY // codigo da ocorrencia
DATA cOcorrencia     INIT ""  READONLY // descri‡Æo das ocorrencias
DATA cDescOcorrencia INIT ""  READONLY // descri‡Æo das ocorrencias
DATA isPago          INIT .f. READONLY //  Titulo foi pago
DATA isOk            INIT .f. READONLY //  titulo processado normalmente

DATA CNAB400         INIT .T.          // .T. = CNAB400 ou .F. = CNAB240(Febraban)


METHOD New( cBco, cArq ) CONSTRUCTOR
METHOD Next()
METHOD eof()
METHOD Close()
METHOD Readln(nBytes) PROTECTED
METHOD OcorrenciaExt() PROTECTED
ENDCLASS

/* -------------------------------------------------------------------------- */

METHOD new( cBco, cArq ) CLASS oRetorno
   local nBytes

   DEFAULT cBco TO "237"

   IF file(cArq)
      ::nHandle :=fopen(cArq)
      ::nLen    := FSEEK(::nHandle,0,FS_END )
      FSEEK(::nHandle,0 )
      HB_FReadLine(::nHandle,@::cLine)
      ::CNAB400:=(len(::cLine) == 400)
      FSEEK(::nHandle,0 )
      IF ::CNAB400
	 DO CASE
	    CASE cBco == "237"
	      ::READLN(402)

	       IF SUBS(::cLine,077 ,3) == cBco
		  ::cNomeBco:= "BRADESCO"
		  ::cCodBco := cBco
	       endif

	    CASE cBco == "341"
	       ::READLN(402)

	       IF SUBS(::cLine,077  ,3) == cBco
		  ::cNomeBco:= "BANCO ITAU  SA"
		  ::cCodBco := cBco
	       endif

	    CASE cBco == "409"
	       ::cNomeBco   := "UNIBANCO"
	       ::cCodBco := cBco
	    CASE cBco == "422"
	       ::cNomeBco := "Safra"
	       ::cCodBco := cBco
	    OTHERWISE
	       ::nLen:=0
	 ENDCASE
	 ::cNomeBco := PAD(::cNomeBco, 15)
      else
        ::READLN(242)
        ::cNomeBco := subs(::cLine,103,40)
        ::cCodBco  := subs(::cLine,1,3)

      ENDIF
      ::Next()
   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */
METHOD Next( ) CLASS oRetorno
   local cIDreg:=""
   ::isPago :=.F.
   ::isOk   :=.F.

   IF ::CNAB400

      DO CASE
                     
         CASE ::cCodBco == "237"
	      DO WHILE cIDreg # "1" .and. .not. ::eof()
		 ::READLN(402)
		 cIDreg:=SUBS(::cLine,1,1)
	      ENDDO
	      IF ::Eof()
		 ::Close()
	      ELSE
                                  
         ::DtVenc      :=ctod(trans(SUBS(::cLine,147,6) ,"@R 99/99/2099"))
		 ::DtPagto     :=ctod(trans(SUBS(::cLine,111,6) ,"@R 99/99/2099"))
		 ::nValor      :=val(SUBS(::cLine,254,13))/100
		 ::nMulta      :=val(SUBS(::cLine,267,13))/100
		 ::cNumDoc     :=SUBS(::cLine,117,10)
		 ::cNossoNumero:=SUBS(::cLine,071,12)
		 ::cBcoPag     :=SUBS(::cLine,166,3)
		 ::cNumAgencia :=SUBS(::cLine,169,5)
		 ::cOcorrencia :=SUBS(::cLine,109,2)
		 ::cRejeicao   :=SUBS(::cLine,319,10)

		 IF "06" $ ::cRejeicao .or."17" $ ::cOcorrencia
		    ::isPago :=.t.
		 ENDIF

		 // temos aqui o problema de acentuacao ANSI/OEM
		 // algo para ser resolvido ...
		 ::OcorrenciaExt()
	      ENDIF
	 CASE ::cCodBco == "341"
	      DO WHILE cIDreg # "1" .and. .not. ::eof()
		 ::READLN(402)
		 cIDreg:=SUBS(::cLine,1,1)
	      ENDDO
	      IF ::Eof()
		 ::Close()
	      ELSE
		 ::DtVenc      :=ctod(trans(SUBS(::cLine,147,6) ,"@R 99/99/2099"))
		 ::DtPagto     :=ctod(trans(SUBS(::cLine,296,6) ,"@R 99/99/2099"))
		 ::nValor      :=val(SUBS(::cLine,153 ,13))/100
		 ::nMulta      :=val(SUBS(::cLine,267,13))/100
		 ::cNumDoc     :=SUBS(::cLine,038,25)
		 ::cNossoNumero:="0000"+SUBS(::cLine,063,08)
		 ::cBcoPag     :=SUBS(::cLine,166 ,3)
		 ::cNumAgencia :=SUBS(::cLine,169 ,5)
		 ::cOcorrencia :=SUBS(::cLine,109,2)
		 ::cRejeicao   :=SUBS(::cLine,378,8)
		 ::cDescOcorrencia:=""
	       ENDIF
	 CASE ::cCodBco == "409"
       DO WHILE cIDreg # "1" .and. .not. ::eof()
          ::READLN(402)
          cIDreg:=SUBS(::cLine,1,1)
       ENDDO
       IF ::Eof()
          ::Close()
       ELSE

         ::DtVenc      :=ctod(trans(SUBS(::cLine,147,6) ,"@R 99/99/2099"))
         ::DtPagto     :=ctod(trans(SUBS(::cLine,111,6) ,"@R 99/99/2099"))
         ::nValor      :=val(SUBS(::cLine,254,13))/100
         ::nMulta      :=val(SUBS(::cLine,267,13))/100
         ::cNumDoc     :=SUBS(::cLine,117,12)
         ::cNossoNumero:=SUBS(::cLine,063,15)
         ::cBcoPag     :=SUBS(::cLine,166,3)
         ::cNumAgencia :=SUBS(::cLine,169,5)
         ::cOcorrencia :=SUBS(::cLine,109,2)
         ::cRejeicao   := ""//SUBS(::cLine,319,10)

         //IF left(::cOcorrencia,2) $ "06 17"
           ::isPago :=.t.
         //ENDIF

         // temos aqui o problema de acentuacao ANSI/OEM
         // algo para ser resolvido ...
         ::OcorrenciaExt()
       ENDIF
	 CASE ::cCodBco == "422"
	      DO WHILE cIDreg # "1" .and. .not. ::eof()
		 ::READLN(402)
		 cIDreg:=SUBS(::cLine,1,1)
	      ENDDO
	      IF ::Eof()
		 ::Close()
	      ELSE
		 ::DtVenc      :=ctod(trans(SUBS(::cLine,147,6) ,"@R 99/99/2099"))
		 ::DtPagto     :=ctod(trans(SUBS(::cLine,111,6) ,"@R 99/99/2099"))
		 ::nValor      :=val(SUBS(::cLine,153 ,13))/100
		 ::nMulta      :=val(SUBS(::cLine,267,13))/100
		 ::cNumDoc     :=SUBS(::cLine,117,10)
		 IF SUBS(::cLine,108,1) =="6"
		    ::cNossoNumero:=SUBS(::cLine,38,17)+" "
		 ELSE
		    ::cNossoNumero:="000"+SUBS(::cLine,63,9)
		 ENDIF
		 ::cBcoPag     := ""
		 ::cNumAgencia := ""
		    ::isPago :=.t.
		 ::cOcorrencia :=SUBS(::cLine,109,2)
		 ::cRejeicao   :=SUBS(::cLine,105,3)
		 ::cDescOcorrencia:=""
		 IF "06" $ ::cOcorrencia
		    ::isPago :=.t.
		 ENDIF
	       ENDIF
      ENDCASE

   ELSE // CNAB240

     If ::cCodBco == "104"

        DO WHILE cIDreg # "3" .and. .not. ::eof()
           ::READLN(242)
           cIDreg:=SUBS(::cLine,8,1)
        ENDDO

        IF ::Eof()
           ::Close()
        ELSE

          Seg := SUBS(::cLine,14,1) // Segmento Detalhe (T) (U)

          If Seg == "T"
             ::cOcorrencia  := SUBS(::cLine,16,2)
             ::cNossoNumero := SUBS(::cLine,40,17)
             ::cNumDoc      := SUBS(::cLine,59,11)
             ::DtVenc       := CTOD(Tran(SUBS(::cLine,74,8)  ,"@R 99/99/9999"))
             ::nValor       := VAL(SUBS(::cLine,82,15))/100
             ::cBcoPag      := SUBS(::cLine,97,3)
             ::cNumAgencia  := SUBS(::cLine,100,5)
             ::cRejeicao    := SUBS(::cLine,214,10)
          Endif

          If Seg == "U"
             ::DtPagto      := CTOD(Tran(SUBS(::cLine,138,8) ,"@R 99/99/9999"))
             ::nMulta       := VAL(SUBS(::cLine,18,15))/100
          Endif
                    
          ::isPago       := ( ::cOcorrencia == "06" )
          ::OcorrenciaExt()
                    
        ENDIF

     Else  // Outros

        DO WHILE cIDreg # "3" .and. .not. ::eof()
           ::READLN(242)
           cIDreg:=SUBS(::cLine,8,1)
        ENDDO
        IF ::Eof()
           ::Close()
        ELSE
           ::DtVenc      :=ctod(trans(SUBS(::cLine,72,8) ,"@R 99/99/9999"))
           ::DtPagto     :=date()
           ::nValor      :=val(SUBS(::cLine,80,15))/100
           ::nMulta      :=val(SUBS(::cLine,110,15))/100
           ::cNumDoc     :=SUBS(::cLine,59,13)
           ::cNossoNumero:=SUBS(::cLine,047,10)
           ::cBcoPag     :=SUBS(::cLine,095,3)
           ::cNumAgencia :=SUBS(::cLine,098,6)
           ::cOcorrencia :=SUBS(::cLine,016,2)
           ::cRejeicao   :=SUBS(::cLine,226,10)
           ::isPago :=( ::cOcorrencia =="06" )
           ::OcorrenciaExt()
        ENDIF

     Endif

   ENDIF

RETURN Self

/* -------------------------------------------------------------------------- */
METHOD eof( ) CLASS oRetorno
return (::nLen == 0)

/* -------------------------------------------------------------------------- */
METHOD Close( ) CLASS oRetorno
   fclose(::nHandle)
RETURN Self

/* -------------------------------------------------------------------------- */
METHOD Readln(nBytes) CLASS oRetorno

   ::cLine:=space(nBytes)
   FREAD(::nHandle,@::cLine,nBytes)
   ::nLen-=nBytes
return ::cLine

METHOD OcorrenciaExt() CLASS oRetorno

      DO CASE
         CASE ::cOcorrencia == "02"
              ::cDescOcorrencia:="Entrada Confirmada"
              ::isOk   :=.t.
         CASE ::cOcorrencia == "03"
              ::cDescOcorrencia:="Entrada Rejeitada motivo "+::cRejeicao
         CASE ::cOcorrencia == "06"
              ::cDescOcorrencia:="Liquida‡Æo normal"
         CASE ::cOcorrencia == "09"
              ::cDescOcorrencia:="Baixado Automat. via Arquivo motivo "+::cRejeicao
         CASE ::cOcorrencia == "10"
              ::cDescOcorrencia:="Baixado conforme instru‡äes da Agˆncia motivo "+::cRejeicao
         CASE ::cOcorrencia == "11"
              ::cDescOcorrencia:="Em Ser - Arquivo de T¡tulos pendentes"
         CASE ::cOcorrencia == "12"
              ::cDescOcorrencia:="Abatimento Concedido"
         CASE ::cOcorrencia == "13"
              ::cDescOcorrencia:="Abatimento Cancelado"
         CASE ::cOcorrencia == "14"
              ::cDescOcorrencia:="Vencimento Alterado"
         CASE ::cOcorrencia == "15"
              ::cDescOcorrencia:="Liquidacao em Cartorio"
         CASE ::cOcorrencia == "16"
              ::cDescOcorrencia:="Titulo Pago em Cheque Vinculado"
         CASE ::cOcorrencia == "17"
              ::cDescOcorrencia:="Liquida‡Æo apos baixa ou Titulo nao registrado"
         CASE ::cOcorrencia == "18"
              ::cDescOcorrencia:="Acerto de Deposit ria"
         CASE ::cOcorrencia == "19"
              ::cDescOcorrencia:="Confirma‡ao Receb. Inst. de Protesto motivo "+::cRejeicao
         CASE ::cOcorrencia == "20"
              ::cDescOcorrencia:="Confirma‡ao Recebimento Instru‡Æo Susta‡ao de Protesto"
         CASE ::cOcorrencia == "21"
              ::cDescOcorrencia:="Acerto do Controle do Participante"
         CASE ::cOcorrencia == "22"
              ::cDescOcorrencia:="Titulo Com Pagamento Cancelado"
         CASE ::cOcorrencia == "23"
              ::cDescOcorrencia:="Entrada do Titulo em Cartorio"
         CASE ::cOcorrencia == "24"
              ::cDescOcorrencia:="Entrada rejeitada por CEP Irregular motivo "+::cRejeicao
         CASE ::cOcorrencia == "27"
              ::cDescOcorrencia:="Baixa Rejeitada motivo "+::cRejeicao
         CASE ::cOcorrencia == "28"
              ::cDescOcorrencia:="Debito de tarifas/custas motivo "+::cRejeicao
         CASE ::cOcorrencia == "30"
              ::cDescOcorrencia:="Altera‡ao de Outros Dados Rejeitados motivo "+::cRejeicao
         CASE ::cOcorrencia == "32"
              ::cDescOcorrencia:="Instru‡ao Rejeitada motivo "+::cRejeicao
         CASE ::cOcorrencia == "33"
              ::cDescOcorrencia:="Confirma‡ao Pedido Alteracao Outros Dados"
         CASE ::cOcorrencia == "34"
              ::cDescOcorrencia:="Retirado de Cartorio e Manutencao Carteira"
         CASE ::cOcorrencia == "35"
              ::cDescOcorrencia:="Desagendamento do debito autom tico motivo "+::cRejeicao
         CASE ::cOcorrencia == "68"
              ::cDescOcorrencia:="Acerto dos dados do rateio de Credito"
         CASE ::cOcorrencia == "69"
              ::cDescOcorrencia:="Cancelamento dos dados do rateio"
         OTHERWISE
              ::cDescOcorrencia:=""
      ENDCASE

return ::cDescOcorrencia

// eof
