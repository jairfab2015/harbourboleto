/*
 * $Id$
*/
/*
 * Copyright 2006 Mario Simoes Filho mario@argoninformatica.com.br for original acento.prg
 * Copyright 2006 Marcelo Sturm <marcelo.sturm@gmail.com> for modifications in the original project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2,  or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not,  write to
 * the Free Software Foundation,  Inc.,  59 Temple Place,  Suite 330,
 * Boston,  MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception,  the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that,  if you link the Harbour libraries with other
 * files to produce an executable,  this does not by itself cause the
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
 * Harbour,  as the General Public License permits,  the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files,  you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour,  it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that,  delete this exception notice.
 *
 */

#include "harbourboleto.ch"

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+
*+    Function AcentoHTML()
*+
*+    Called from ( oboleto.prg  )   1 - function acentohtml()
*+
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+
FUNCTION AcentoHTML(cStr,lAnsi,lTudo)

   DEFAULT lAnsi TO .F.,lTudo TO .T.

   IF __ANSI $ cStr
      cStr  := STRTRAN(cStr,__ANSI,"")
      lAnsi := .T.
   ENDIF

   IF lAnsi
      cStr := AnsiToHtml( cStr )
   ELSE
      cStr := OemToHtml( cStr )
   ENDIF
   IF !lTudo
      cStr := STRTRAN(cStr,"&amp;","&")
      cStr := STRTRAN(cStr,"&lt;" ,"<")
      cStr := STRTRAN(cStr,"&gt;" ,">")
   ENDIF

RETURN cStr

/* -------------------------------------------------------------------------- */

/*
FUNCTION RetiraAcento( cStr,  lAll, lAnsi )

   LOCAL nI
   LOCAL nLen := LEN(cStr)
   LOCAL cChar
//   LOCAL Ret := ""

   DEFAULT lAll TO .T., lAnsi TO .F.

   IF __ANSI $ cStr
      cStr := STRTRAN(cStr, __ANSI, "")
      lAnsi := .T.
   ENDIF

   IF lAnsi
      cStr := STRTRAN(cStr, "·", "a")
      cStr := STRTRAN(cStr, "¡", "A")
      cStr := STRTRAN(cStr, "‡", "a")
      cStr := STRTRAN(cStr, "¿", "A")
      cStr := STRTRAN(cStr, "È", "e")
      cStr := STRTRAN(cStr, "…", "E")
      cStr := STRTRAN(cStr, "Ë", "e")
      cStr := STRTRAN(cStr, "»", "e")
      cStr := STRTRAN(cStr, "Ì", "i")
      cStr := STRTRAN(cStr, "Õ", "I")
      cStr := STRTRAN(cStr, "Ï", "i")
      cStr := STRTRAN(cStr, "Ã", "I")
      cStr := STRTRAN(cStr, "Û", "o")
      cStr := STRTRAN(cStr, "”", "O")
      cStr := STRTRAN(cStr, "Ú", "o")
      cStr := STRTRAN(cStr, "“", "O")
      cStr := STRTRAN(cStr, "˙", "u")
      cStr := STRTRAN(cStr, "⁄", "U")
      cStr := STRTRAN(cStr, "˘", "u")
      cStr := STRTRAN(cStr, "Ÿ", "U")
      cStr := STRTRAN(cStr, "‚", "a")
      cStr := STRTRAN(cStr, "¬", "A")
      cStr := STRTRAN(cStr, "Í", "e")
      cStr := STRTRAN(cStr, " ", "E")
      cStr := STRTRAN(cStr, "Ù", "o")
      cStr := STRTRAN(cStr, "‘", "O")
      cStr := STRTRAN(cStr, "„", "a")
      cStr := STRTRAN(cStr, "√", "A")
      cStr := STRTRAN(cStr, "ı", "o")
      cStr := STRTRAN(cStr, "’", "O")
      cStr := STRTRAN(cStr, "Á", "c")
      cStr := STRTRAN(cStr, "«", "C")
      cStr := STRTRAN(cStr, "ˇ", "y")
      cStr := STRTRAN(cStr, "ˆ", "o")
      cStr := STRTRAN(cStr, "÷", "O")
      cStr := STRTRAN(cStr, "Ò", "n")
      cStr := STRTRAN(cStr, "—", "N")
      cStr := STRTRAN(cStr, "¸", "u")
      cStr := STRTRAN(cStr, "‹", "U")
      cStr := STRTRAN(cStr, "∫", "o.")
      cStr := STRTRAN(cStr, "∞", "o.")
      cStr := STRTRAN(cStr, "™", "a.")
   ELSE
      cStr := STRTRAN(cStr, "†", "a")
      cStr := STRTRAN(cStr, "µ", "A")
      cStr := STRTRAN(cStr, "Ö", "a")
      cStr := STRTRAN(cStr, "∑", "A")
      cStr := STRTRAN(cStr, "Ç", "e")
      cStr := STRTRAN(cStr, "ê", "E")
      cStr := STRTRAN(cStr, "ä", "e")
      cStr := STRTRAN(cStr, "‘", "E")
      cStr := STRTRAN(cStr, "°", "i")
      cStr := STRTRAN(cStr, "÷", "I")
      cStr := STRTRAN(cStr, "ç", "i")
      cStr := STRTRAN(cStr, "ﬁ", "I")
      cStr := STRTRAN(cStr, "¢", "o")
      cStr := STRTRAN(cStr, "‡", "O")
      cStr := STRTRAN(cStr, "ï", "o")
      cStr := STRTRAN(cStr, "„", "O")
      cStr := STRTRAN(cStr, "£", "u")
      cStr := STRTRAN(cStr, "È", "U")
      cStr := STRTRAN(cStr, "ó", "u")
      cStr := STRTRAN(cStr, "Î", "U")
      cStr := STRTRAN(cStr, "É", "a")
      cStr := STRTRAN(cStr, "∂", "A")
      cStr := STRTRAN(cStr, "à", "e")
      cStr := STRTRAN(cStr, "“", "E")
      cStr := STRTRAN(cStr, "ì", "o")
      cStr := STRTRAN(cStr, "‚", "O")
      cStr := STRTRAN(cStr, "∆", "a")
      cStr := STRTRAN(cStr, "«", "A")
      cStr := STRTRAN(cStr, "‰", "o")
      cStr := STRTRAN(cStr, "Â", "O")
      cStr := STRTRAN(cStr, "á", "c")
      cStr := STRTRAN(cStr, "Ä", "C")
      cStr := STRTRAN(cStr, "ò", "y")
      cStr := STRTRAN(cStr, "î", "o")
      cStr := STRTRAN(cStr, "ô", "O")
      cStr := STRTRAN(cStr, "§", "n")
      cStr := STRTRAN(cStr, "•", "N")
      cStr := STRTRAN(cStr, "Å", "u")
      cStr := STRTRAN(cStr, "ö", "U")
      cStr := STRTRAN(cStr, "ß", "o.")
      cStr := STRTRAN(cStr, "¯", "o.")
      cStr := STRTRAN(cStr, "¶", "a.")
   ENDIF

RETURN cStr
*/

*+ EOF: ACENTO.PRG
