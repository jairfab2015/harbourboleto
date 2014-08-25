/*
 * $Id$
*/
  
/*
 * Copyright 2006 Mario Simoes Filho mario@argoninformatica.com.br for original
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
 * This exception does not however invalidate any other reasons why
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
#include "Common.ch"
#include "directry.ch"
#include "fileio.ch"
#include "dbedit.ch"
#include "inkey.ch"
#include "button.ch"
#include "setcurs.ch"
#include "hbclass.ch"

#define CRLF CHR(13)+CHR(10)

FUNCTION MAIN()

  CLS
  CLOSE DATA

  ESCRISAFRA()

  CLOSE DATA

RETURN NIL

* * * * * * * * * * * * * * * * * * * ** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *>

FUNCTION ESCRISAFRA()
   LOCAL RA, MARCA, NDP1, NDP2, NCONTA:=0, RE:=1

   RA:=SPACE(50) ; MARCA:="N" ; BC:=6 ; NDP1:=NDP2:=0 ; AG1:="00000" ; AG2:="000000000"
   TRA:=REPLI("Ä",80)

   CLOSE DATA
   SETCOLOR(COR12)
   @ 01,00 CLEAR
   @ 01,00 SAY TRA
   @ 24,00 SAY PADC("Tecle <ESC> para Sair",80) COLOR(COR10)

   @ 02,00 SAY "Primeira Duplicata :> " GET NDP1 PICT "999999"
   @ 02,40 SAY "Ultima Duplicata ..:> " GET NDP2 PICT "999999" VALID NDP2 >= NDP1

   @ 03,00 SAY "N§ da Agencia ..:> " GET AG1 PICT "99999"
   @ 03,40 SAY "N§ da C/Corrente:> " GET AG2 PICT "999999999"

   @ 04,00 SAY "Enviar Duplicatas marcadas ? (S/N) " GET MARCA PICT "!" VALID MARCA $"SN"
   @ 05,00 SAY "Codigo do Banco :> " GET BC PICT "999"

   @ 07,00 SAY TRA
   READ

   IF LASTKEY() = 27
      SAIR()
      RETURN NIL
   ENDIF

   NOPT:=0
   ALERTVER("Confirma geracao", {"   Sim   ","   Nao   "},1)

   IF LASTKEY() = 27 .OR. nOPT <> 1
      SAIR()
      RETURN NIL
   ENDIF

   @ 24,00 SAY SPACE(80)
   CLOSE DATA

   vND:=0 ; vDE:=1 ; vTP9:="DP" ; ND:=0 ;  DE:=1 ;  TP9:="DP" ;  VLTO:=0

   ARQ:="DP"+STRZERO(DAY(DATE()), 2) + ;
             STRZERO(MONTH(DATE()), 2)+ STRZERO(nCONTA++,2)+ ".DBF"

   DO WHILE .T.
      IF FILE(ARQ)
         ARQ:="DP"+STRZERO(DAY(DATE()), 2) + ;
              STRZERO(MONTH(DATE()), 2)+STRZERO(nCONTA++,2) + ".DBF"
         LOOP
      ELSEIF !FILE(ARQ)
         EXIT
      ELSE
         nCONTA++
      ENDIF
      IF nCONTA = 99
         ARQ:="DP"+STRZERO(DAY(DATE()), 2) + ;
              STRZERO(MONTH(DATE()), 2)+STRZERO(nCONTA++,2) + ".DBF"
         EXIT
      ENDIF
   ENDDO

   DO WHILE .T.
      SETCOLOR(COR12)
      @ 01,00 CLEAR
      @ 01,00 SAY PADC("DUPLICATAS ENVIADAS",80) COLOR(COR3)
      NOPT:=0
      ALERTNEW("Aguarde criando arquivo...",,,.T.)

      aArq:= { {"VECTO","D",08,0},{"NDUPL","N",06,0},{"DESDOBRA","N",01,0}  ,;
               {"VALOR","N",15,2},{"TPCARTEIRA","C",02,0},{"BANCO","N",03,0},;
               {"NUMBANCO","C",15,0},{"HORA","C",05,0},{"USUARIO","C",10,0} ,;
               {"DIA","D",8,0}, {"CODCLI","N",06,0},{"RAZAO","C",50,0}      ,;
               {"DTNEGOCIO","D",08,0},{"PREVISTO","D",08,0},{"TPDP","C",02,0} }

      DBCREATE(ARQ, aArq)
      INDI :=SUBSTR(ARQ,1,8)+".NTX"
      INDI1:=SUBSTR(ARQ,1,6)+"VV.NTX"
      USE(ARQ) NEW EXCLUSIVE
      IF USED()
         INDEX ON NDUPL TO &INDI
         INDEX ON DTOS(VECTO)+STRZERO(VALOR,12,2) TO &INDI1
         CLOSE DATA
         EXIT
      ELSE
         ALERTNEW("Arquivo nÆo localizado")
         SAIR()
         RETURN NIL
      ENDIF
   ENDDO

   SAIR()

   SELECT(1)
   USE DUPLICA NEW SHARED
   SET INDEX TO DUPLIVE, DUPLINU, DUPLIBA, DUPLICO, DUPLIPRE, DUPLIEMI, DUPLIPG, DUPLINB

   SELECT(2)
   USE(ARQ) NEW SHARED
   SET INDEX TO &INDI, &INDI1

   SELECT(1)
   DBSETORDER(2)
   DBSEEK( NDP1, .T. )

   DO WHILE .T.
      IF NDUPL >= NDP1 .AND. NDUPL <= NDP2
         IF SITUACAO = "A" .AND. VECTO > EMISSAO .AND. ;
            IIF( MARCA = "N", DPGERADA = " ",  (DPGERADA = " " .OR. DPGERADA = "E") )

            @ 15,00 SAY PADC("Numero de registros convertido :> " + STRZERO(RE,6),80) COLOR(COR3)

            cNDUPL:=NDUPL      ; cDESDOBRA:=DESDOBRA ; cVECTO:=VECTO ; cVALOR:=VALOR
            cTPCARTEIRA:="CG"  ; cBANCO:=BC ; cCODCLI:=CODCLI ; cRAZAO:=RAZAO
            cDTNEGOCIO:=DATE() ; cTPDP:="CG"

            DO WHILE !RLOCK()
            ENDDO
            REPLACE DTNEGOCIO WITH cDTNEGOCIO, BANCO WITH cBANCO, DPGERADA WITH "E"
            REPLACE USUARIO WITH CUSUARIO, DIA WITH DATE(), HORA WITH TIME()
            REPLACE TPCARTEIRA WITH "CG"
            DBCOMMIT()
            DBUNLOCK()

            SELECT(2)
            DBAPPEND()
            DO WHILE !RLOCK()
            ENDDO
            REPLACE VECTO WITH cVECTO, NDUPL WITH cNDUPL, DESDOBRA WITH cDESDOBRA
            REPLACE VALOR WITH cVALOR, TPCARTEIRA WITH cTPCARTEIRA, BANCO WITH cBANCO
            REPLACE DTNEGOCIO WITH cDTNEGOCIO, CODCLI WITH cCODCLI, RAZAO WITH cRAZAO
            REPLACE TPDP WITH cTPDP
            DBCOMMIT()
            DBUNLOCK()

            SELECT(1)
            DBSETORDER(2)
            DBSKIP()
         ELSE
            SELECT(1)
            DBSETORDER(2)
            DBSKIP()
         ENDIF
      ELSEIF NDUPL > NDP2 .OR. EOF()
         EXIT
      ELSE
         SELECT(1)
         DBSETORDER(2)
         DBSKIP()
      ENDIF
   ENDDO

   SAIR()

   SAFRA()

   SAIR()

RETURN NIL

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *>

FUNCTION SAFRA()

   LOCAL oBol, oRem
   LOCAL RAZ:=SPACE(40), ENDEC:=SPACE(22), CEPC:="00000000"
   LOCAL MUNC:=SPACE(22), ESTC:=SPACE(02), NC:="00000000000000"
   LOCAL NC1:="00000000000000"

   SAIR()

   SET DEFA TO &PASTAFIN
   SELECT(1)
   USE(ARQ) NEW SHARED
   SET INDEX TO &INDI, &INDI1

   SET DEFA TO &PASTAFAT
   SELECT(2)
   USE RCLIENTE NEW SHARED
   SET INDEX TO RCLICO

   SET DEFA TO &PASTAFIN
   SELECT(3)
   USE DUPLICA NEW SHARED
   SET INDEX TO DUPLINU, DUPLIVE, DUPLIBA, DUPLICO, DUPLIPRE, DUPLIEMI, DUPLIPG, DUPLINB
   DBSETORDER(1)

   oBol := oBoleto("422") // Como o "new" e o Constructor não precisa ser especificado
   oBol:lRemessa := .T.   // Se não quiser gerar Arquivo Remessa.
   oBol:lBoleto  := .F.   // Se não quiser gerar Boleto Bancário.
   oBol:nBolsPag := 1

   oBol:Cedente     := "EMPRESA TESTE LTDA"
   oBOL:CedenteCNPJ := "00000000000000"


   oBol:cNumCC      := "00000000"  // numero da conta VINCULADA ou SIMPLES fornecido pelo SAFRA 25/09/2006
   oBol:cDVCC       := "0"         // Digito da conta VINCULADA ou SIMPLES                      22/09/2006
   oBol:cNumAgencia := "0210"      // agencia
   oBol:cDVAgencia  := "0"         // Digito

   oBol:cCarteira   := "2"     // carteira de cobranca VINCULA CONFORME SUPORTE 25/09/2006

 //oBOL:cCDPF       := "00200000000481"  // USO PARA TESTE  fornecido pelo Safra

   oBOL:cCDPF       := AG1+AG2           // USO NORMAL

   oBol:Open("boleto",,,"C:\SAFRA")   // Cria html - Sempre colocar após a definição completa do Cedente, pois
                                      // isso influencia na criação do Arquivo Remessa.

   SELECT(1)
   DBGOTOP()
   cCOD:=CODCLI ; cVECTO:=VECTO ; cVALOR:=VALOR ; cNDUPL:=STRZERO(NDUPL,7)+STRZERO(DESDOBRA,1)

   DO WHILE .T.

      SELECT(2)
      DBSEEK( cCOD, .F.)
      IF FOUND()
         RAZ:=RAZAO ; ENDEC:=ENDCO ; CEPC:=SUBSTR(CEPCO,1,5)+SUBSTR(CEPCO,7,3) ; MUNC:=CIDCO ; ESTC:=ESTCO
         NC :="0"+SUBSTR(CGC,1,2)+SUBSTR(CGC,4,3)+SUBSTR(CGC,8,3)+SUBSTR(CGC,12,4)+SUBSTR(CGC,17,2)
         NC1:="00000000000000"
      ELSE
         RAZ:=SPACE(40)  ; ENDEC:=SPACE(22) ; CEPC:="00000000"
         MUNC:=SPACE(22) ; ESTC:=SPACE(02) ; NC:="00000000000000"
         NC1:="00000000000000"
      ENDIF

      oBol:SACADO       := RAZ
      oBol:ENDERECO     := ENDEC
      oBol:CEP          := CEPC
      oBol:CNPJ         := NC
      oBol:ESTADO       := ESTC
      oBOL:CIDADE       := MUNC
      oBol:INSTRUCOES   := "" + CRLF + "" // aqui voce pode por o que quiser ate CRLF
      oBol:nMulta       :=  2             // % de multa
      oBol:nMora        :=  .03           // % do valor a ser cobrado por dia de atraso
      oBol:DtVenc       := cVECTO         // vencimento
      oBol:cNumDoc      := cNDUPL         // seu numero do documento
      oBol:cNossoNumero := cNDUPL         // numero do banco
      oBol:nValor       := cVALOR         // valor do boleto

      oBol:Execute()                      // monta html

      SELECT(1)
      DBSKIP()

      IF EOF()
         EXIT
      ELSE
         cCOD:=CODCLI ; cVECTO:=VECTO ; cVALOR:=VALOR
         cNDUPL:=STRZERO(NDUPL,7)+STRZERO(DESDOBRA,1)
      ENDIF
   ENDDO

   oBol:Close()
   oBol:Print() // Imprime o boleto

RETURN NIL


