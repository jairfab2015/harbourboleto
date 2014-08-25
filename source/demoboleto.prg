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

/* -------------------------------------------------------------------------- */

FUNCTION Main()

   LOCAL oBol, oRem

   SET DATE BRIT

   //oBol := oBoleto("409") // Como o "new" e o Constructor nao precisa ser especificado
   //oBol := oBoleto():new("104")

   oBol := oBoleto("104")

   oBol:lAnsi     := .t.
   oBol:lRemessa  := .f. // Se nao quiser gerar Arquivo Remessa.
   oBol:lBoleto   := .t. // Se nao quiser gerar Boleto Bancario.
   oBol:lPreview  := .f.
   oBol:nBolsPag  := 1
                                   
   oBol:Modelo      := "BOL_SIGCB" // Modelo SIGCB, Padrao da Caixa
   oBol:Cedente     := "MECONI & MECONI LTDA"
   oBol:CedenteCNPJ := "73192601000117"
   oBol:cCDPF       := "214016"    // Cod. Cedente / Cod. Empresa no Banco
   oBol:cNumCC      := "003827"    // Numero da Conta
   oBol:cDvCC       := "9"         // DV Conta 
   oBol:cNumAgencia := "0907"      // Agencia
   oBol:cDVAgencia  := "5"         // Digito Agencia
   oBol:cCarteira   := "1"         // Carteira de Cobranca
   oBol:EspecieTit  := "DM"
   //oBol:cImageLnk   := "http://systux.net/lnk_img_boletos/"
            
   *------------------------------------------------------------------*
   * Cria html - Sempre colocar apos a definicao completa do Cedente, *
   * isso influencia na criacao do Arquivo Remessa.                   *
   *------------------------------------------------------------------*
   //oBol:Open( "boleto", , , "rem", 99974809, .F. ) // .F. Padrao CNAB240
   oBol:Open( "boleto_teste_123", , , "rem", 99974809, .F. ) // .F. Padrao CNAB240

   For iB := 1 To 1
   // while !eof()
      oBol:SACADO       := "TONINHO SILVA"
      oBol:ENDERECO     := "AV J K OLIVEIRA, 332"
      oBol:BAIRRO       := "MONTE ALEGRE"
      oBol:CIDADE       := "CAIEIRAS"
      oBol:ESTADO       := "SP"                           
      oBol:CEP          := "07700000"
      oBol:CNPJ         := "13304115870"    // cnpj sem ".-/"
    //oBol:CNPJ         := "00585770000143" // cnpj sem ".-/"
      oBol:INSTRUCOES   := "." + CRLF + "Txt Livre 1" + CRLF + "Txt Livre 2" // aqui voce pode por o que quiser ate CRLF
      oBol:nMulta       := 1.50   // Multa Apos Vencimento
      oBol:nMora        := 0.40   // Mora Diaria a Ser Cobrado Por Dia de Atraso
      oBol:nDiasProt    := 5      // Dias Para Protesto
      oBol:DtEmis       := CTOD("20/10/2009") // Data Proc/Emissao == DataDoc
      oBol:DtVenc       := CTOD("30/10/2009") // Vencimento
      oBol:cNumDoc      := "12345678900"      // Seu Numero do Documento
      oBol:cNossoNumero := "000000000000019"  // Tam(15)

      oBol:nValor       := 12.34              // Valor do Boleto
      oBol:Aceite       := "S"          
      oBol:Execute()    // monta html

      // skip
     // end
   Next

    //  oBol:SACADO       := "Toninho Silva"
    //  oBol:ENDERECO     := "Av J.K Oliveira, 332"
    //  oBol:BAIRRO       := "Monte Alegre"
    //  oBol:CIDADE       := "Caieiras"
    //  oBol:ESTADO       := "SP"
    //  oBol:CEP          := "07700000"
    //  oBol:CNPJ         := "13304115870" // cnpj sem "-/"
    //  oBol:INSTRUCOES   := "Txt Livre 1" + CRLF + "Txt Livre 2" // aqui voce pode por o que quiser ate CRLF
    //  oBol:nMulta       :=  2   // % de multa 
    //  oBol:nMora        :=  .03 // % do valor a ser cobrado por dia de atraso
    //  oBol:DtVenc       := CTOD("30/10/2009")//date()+30 // vencimento
    //  oBol:cNumDoc      := "123456"   // seu numero do documento
    //  oBol:cNossoNumero := "7410114733"   // numero do banco
    //  oBol:nValor       := 12.34      // valor do boleto
    //  oBol:Execute() // monta html

   //oBol:Cedente      := "Cedente 2  - ·ÈÌÛ˙‡„ı‚ÍÙ¸Á¡…Õ”⁄¿√’¬ ‘‹«™∫∞ß"
   //oBol:SACADO       := "Sacado"
   //oBol:ENDERECO     := "EndereÁo"
   //oBol:Bairro       := "Bairro"
   //oBol:Cidade       := "Cidade"
   //oBol:Estado       := "UF"
   //oBol:CEP          := "20000000"
   //oBol:CNPJ         := "000000000" // cnpj sem "-/"
   //oBol:INSTRUCOES   := "ObservaÁ„o1" + CRLF + "&nbsp;ObservaÁ„o2" // aqui voce pode por o que quiser ate CRLF
   //oBol:nMora        := 1.4       // % - valor a ser cobrado por dia de atraso
   //oBol:DtVenc       := ctod("19/07/2006") // vencimento
   //oBol:cNumDoc      := "12345"   // seu numero do documento
   //oBol:cNossoNumero := "5682521917"   // numero do banco
   //oBol:nValor       := 193.68    // valor do boleto
   //oBol:Execute() // monta html */

   oBol:Close()
   oBol:Print()
   //oBol:Print( .f., .f. ) // Imprime o boleto impressora padrao, sem pergunta

RETURN NIL
