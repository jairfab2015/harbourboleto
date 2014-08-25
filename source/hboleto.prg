/*
 * $Id$
*/
  
/*
 * Copyright 2006 Mario Simoes Filho mario@argoninformatica.com.br for original demoboleto.prg
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
 
//#include "common.ch"
#define CRLF CHR(13)+CHR(10)
#xtranslate Default( <x>, <y> ) => IIF( <x> == NIL, <y>, <x> )

// Esse programa lê um arquivo .ini de configurações de boletos e gera os boletos a partir dele.
// Gostaria de ter feito com xml, ao invés de ini, mas não conhecia nenhuma classe pronta p/ xml ... e fiz com ini mesmo.
// Se alguém quiser/puder mudar p/ xml, fique à vontade!
// Marcelo Sturm - 01/08/2007

/* -------------------------------------------------------------------------- */

FUNCTION Main( cFileName )

   LOCAL oIni, oRetIni, oBol
   LOCAL cDir, cDirRemessa, lPrint, lPreview, lPromptPrint, cBol, nI := 0

   SET DATE BRIT

   // CriaIni(cFileName)  // Descomentando esta linha, um arquivo de exemplo é gerado.

   oIni = TIniFile():New(Default(cFilename, 'bol.ini'))
   oBol := oBoleto(oIni:ReadString("CAB", "Banco"))
   oBol:lBoleto     := oIni:ReadBool("CAB", "lBoleto", .T.)
   oBol:lRemessa    := oIni:ReadBool("CAB", "lRemessa", .F.)
   oBol:lAnsi       := oIni:ReadBool("CAB", "lAnsi", .F.)
   lPrint           := oIni:ReadBool("CAB", "lPrint", .F.)
   lPreview         := oIni:ReadBool("CAB", "lPreview", .F.)
   lPromptPrint     := oIni:ReadBool("CAB", "lPromptPrint", .F.)
   oBol:nBolsPag    := oIni:ReadNumber("CAB", "nBolsPag", 2)
   oBol:cImageLnk   := oIni:ReadString("CAB", "cImageLnk")
   oBol:Cedente     := oIni:ReadString("CAB", "Cedente")
   oBol:CedenteCNPJ := oIni:ReadString("CAB", "CedenteCNPJ")
   oBol:cNumCC      := oIni:ReadString("CAB", "cNumCC")
   oBol:cNumAgencia := oIni:ReadString("CAB", "cNumAgencia")
   oBol:cCarteira   := oIni:ReadString("CAB", "cCarteira")
   oBol:EspecieTit  := oIni:ReadString("CAB", "EspecieTit")
   oBol:cTipoCob    := oIni:ReadString("CAB", "cTipoCob")
   oBol:nMora       := oIni:ReadNumber("CAB", "nMora", 0)
   oBol:nMulta      := oIni:ReadNumber("CAB", "nMulta", 0)
   oBol:nDiasProt   := oIni:ReadNumber("CAB", "nDiasProt", 0)
   cDir             := oIni:ReadString("CAB", "cDir")
   cDirRemessa      := oIni:ReadString("CAB", "cDirRemessa")
   oBol:Open("boleto") //, cDir, cDirRemessa, cDir)  // Cria html - Sempre colocar após a definição completa do Cedente, pois
                                                     // isso influencia na criação do Arquivo Remessa.
   
   DO WHILE .T.
      cBol := "BOL" + LTRIM(STR(++nI))
      IF EMPTY(oIni:ReadNumber(cBol, "nValor", 0))
         EXIT
      ENDIF
      oBol:Sacado       := oIni:ReadString(cBol, "Sacado")
      oBol:Endereco     := oIni:ReadString(cBol, "Endereco")
      oBol:Bairro       := oIni:ReadString(cBol, "Bairro")
      oBol:Cidade       := oIni:ReadString(cBol, "Cidade")
      oBol:Estado       := oIni:ReadString(cBol, "Estado")
      oBol:CEP          := oIni:ReadString(cBol, "CEP") 
      oBol:CNPJ         := oIni:ReadString(cBol, "CNPJ")
      oBol:Instrucoes   := oIni:ReadString(cBol, "Instrucoes", "")
      oBol:cNumDoc      := oIni:ReadString(cBol, "cNumDoc", "")          // seu numero do documento
      oBol:cNossoNumero := oIni:ReadString(cBol, "cNossoNumero", "")     // numero do banco
      oBol:nValor       := oIni:ReadNumber(cBol, "nValor", 0)            // valor do boleto
      oBol:DtEmis       := oIni:ReadDate(cBol, "DtEmis", DATE())
      oBol:DtVenc       := oIni:ReadDate(cBol, "DtVenc", DATE())
      oBol:Execute() // monta html
   ENDDO

   oBol:Close()
   IF lPrint
      oBol:Print(lPreview, lPromptPrint) // Imprime o boleto */
   ENDIF

   IF oBol:lRemessa .AND. !EMPTY(oBol:oRem:NomeRem)
      oRetIni = TIniFile():New(Default(cFilename, 'bol.ini') + '.ret')
      oRetIni:WriteString("RET", "NomeRem", oBol:oRem:NomeRem)
      oRetIni:WriteString("RET", "Destino", oBol:oRem:Destino)
      oRetIni:WriteString("RET", "cNumSequencial", oBol:oRem:cNumSequencial)
      oRetIni:WriteNumber("RET", "nTitLote", oBol:oRem:nTitLote)
      oRetIni:UpdateFile()
   ENDIF

RETURN NIL

/* -------------------------------------------------------------------------- */

STATIC FUNCTION CriaIni( cFileName )

   LOCAL oIni

   oIni = TIniFile():New(Default(cFilename, 'bol.ini'))
   oIni:WriteString("CAB", "Banco", "409")
   oIni:WriteString("CAB", "cImageLnk", "")
   oIni:WriteBool("CAB", "lBoleto", .T.)
   oIni:WriteBool("CAB", "lRemessa", .T.)
   oIni:WriteBool("CAB", "lAnsi", .T.)
   oIni:WriteBool("CAB", "lPrint", .T.)
   oIni:WriteBool("CAB", "lPreview", .T.)
   oIni:WriteBool("CAB", "lPromptPrint", .T.)
   oIni:WriteNumber("CAB", "nBolsPag", 2)
   oIni:WriteString("CAB", "Cedente", "Teste de Cedente")
   oIni:WriteString("CAB", "CedenteCNPJ", "11111111111180")
   oIni:WriteString("CAB", "cNumCC", "100778-3")
   oIni:WriteString("CAB", "cNumAgencia", "1748-5")
   oIni:WriteString("CAB", "cCarteira", "1")
   oIni:WriteString("CAB", "EspecieTit", "DM")
   oIni:WriteString("CAB", "cTipoCob", "5")
   oIni:WriteNumber("CAB", "nMora", 0)
   oIni:WriteNumber("CAB", "nMulta", 0)
   oIni:WriteNumber("CAB", "nDiasProt", 0)
   oIni:WriteString("CAB", "cDir", "")
   oIni:WriteString("CAB", "cDirRemessa", "")

   oIni:WriteString("BOL1", "Sacado", "Sacado")
   oIni:WriteString("BOL1", "Endereco", "Endereço")
   oIni:WriteString("BOL1", "Bairro", "Bairro")
   oIni:WriteString("BOL1", "Cidade", "Cidade")
   oIni:WriteString("BOL1", "Estado", "Estado")
   oIni:WriteString("BOL1", "CEP", "20000000")
   oIni:WriteString("BOL1", "CNPJ", "0000000")
   oIni:WriteString("BOL1", "Instrucoes", "Observação")
   oIni:WriteString("BOL1", "cNumDoc", "001396")              // seu numero do documento
   oIni:WriteString("BOL1", "cNossoNumero", "7410114733")     // numero do banco
   oIni:WriteNumber("BOL1", "nValor", 1051.32)                // valor do boleto
   oIni:WriteDate("BOL1", "DtVenc", CTOD("26/09/2006"))

   oIni:WriteString("BOL2", "Sacado", "Cedente 2  - áéíóúàãõâêôüçÁÉÍÓÚÀÃÕÂÊÔÜÇªº°§")
   oIni:WriteString("BOL2", "Endereco", "Endereço")
   oIni:WriteString("BOL2", "Bairro", "Bairro")
   oIni:WriteString("BOL2", "Cidade", "Cidade")
   oIni:WriteString("BOL2", "Estado", "Estado")
   oIni:WriteString("BOL2", "CEP", "20000000")
   oIni:WriteString("BOL2", "CNPJ", "0000000")
   oIni:WriteString("BOL2", "cNumDoc", "001397")              // seu numero do documento
   oIni:WriteString("BOL2", "cNossoNumero", "5682521917")     // numero do banco
   oIni:WriteNumber("BOL2", "nValor", 193.68)                 // valor do boleto
   oIni:WriteDate("BOL2", "DtVenc", CTOD("19/07/2006"))

RETURN oIni:UpdateFile()