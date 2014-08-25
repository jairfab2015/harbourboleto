*-----------------------------------------------*
* Programa..: bibbol.prg (biblioteca de Boletos *
* Objetivo..: Func AcentoHTML(), RetiraAcento() *
*-----------------------------------------------*

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

FUNCTION AcentoHTML( cStr, lAnsi, lTudo )

   DEFAULT lAnsi TO .F., lTudo TO .T.

   IF lTudo
      cStr := STRTRAN(cStr, "&", "&amp;")
      cStr := STRTRAN(cStr, "<", "&lt;")
      cStr := STRTRAN(cStr, ">", "&gt;")
   ENDIF
   IF __ANSI $ cStr
      cStr := STRTRAN(cStr, __ANSI, "")
      lAnsi := .T.
   ENDIF

   IF lAnsi
      cStr := STRTRAN(cStr, "·", "&aacute;")
      cStr := STRTRAN(cStr, "¡", "&Aacute;")
      cStr := STRTRAN(cStr, "‡", "&agrave;")
      cStr := STRTRAN(cStr, "¿", "&Agrave;")
      cStr := STRTRAN(cStr, "È", "&eacute;")
      cStr := STRTRAN(cStr, "…", "&Eacute;")
      cStr := STRTRAN(cStr, "Ë", "&egrave;")
      cStr := STRTRAN(cStr, "»", "&egrave;")
      cStr := STRTRAN(cStr, "Ì", "&iacute;")
      cStr := STRTRAN(cStr, "Õ", "&Iacute;")
      cStr := STRTRAN(cStr, "Ï", "&igrave;")
      cStr := STRTRAN(cStr, "Ã", "&Igrave;")
      cStr := STRTRAN(cStr, "Û", "&oacute;")
      cStr := STRTRAN(cStr, "”", "&Oacute;")
      cStr := STRTRAN(cStr, "Ú", "&ograve;")
      cStr := STRTRAN(cStr, "“", "&Ograve;")
      cStr := STRTRAN(cStr, "˙", "&uacute;")
      cStr := STRTRAN(cStr, "⁄", "&Uacute;")
      cStr := STRTRAN(cStr, "˘", "&ugrave;")
      cStr := STRTRAN(cStr, "Ÿ", "&Ugrave;")
      cStr := STRTRAN(cStr, "‚", "&acirc;")
      cStr := STRTRAN(cStr, "¬", "&Acirc;")
      cStr := STRTRAN(cStr, "Í", "&ecirc;")
      cStr := STRTRAN(cStr, " ", "&Ecirc;")
      cStr := STRTRAN(cStr, "Ù", "&ocirc;")
      cStr := STRTRAN(cStr, "‘", "&Ocirc;")
      cStr := STRTRAN(cStr, "„", "&atilde;")
      cStr := STRTRAN(cStr, "√", "&Atilde;")
      cStr := STRTRAN(cStr, "ı", "&otilde;")
      cStr := STRTRAN(cStr, "’", "&Otilde;")
      cStr := STRTRAN(cStr, "Á", "&ccedil;")
      cStr := STRTRAN(cStr, "«", "&Ccedil;")
      cStr := STRTRAN(cStr, "ˇ", "&yuml;")
      cStr := STRTRAN(cStr, "ˆ", "&ouml;")
      cStr := STRTRAN(cStr, "÷", "&Ouml;")
      cStr := STRTRAN(cStr, "Ò", "&ntilde;")
      cStr := STRTRAN(cStr, "—", "&Ntilde;")
      cStr := STRTRAN(cStr, "¸", "&uuml;")
      cStr := STRTRAN(cStr, "‹", "&Uuml;")
      cStr := STRTRAN(cStr, "∫", "&deg;")
      cStr := STRTRAN(cStr, "∞", "&deg;")
      cStr := STRTRAN(cStr, "™", "&ordf;")
   ELSE
      cStr := STRTRAN(cStr, "†", "&aacute;")
      cStr := STRTRAN(cStr, "µ", "&Aacute;")
      cStr := STRTRAN(cStr, "Ö", "&agrave;")
      cStr := STRTRAN(cStr, "∑", "&Agrave;")
      cStr := STRTRAN(cStr, "Ç", "&eacute;")
      cStr := STRTRAN(cStr, "ê", "&Eacute;")
      cStr := STRTRAN(cStr, "ä", "&egrave;")
      cStr := STRTRAN(cStr, "‘", "&Egrave;")
      cStr := STRTRAN(cStr, "°", "&iacute;")
      cStr := STRTRAN(cStr, "÷", "&Iacute;")
      cStr := STRTRAN(cStr, "ç", "&igrave;")
      cStr := STRTRAN(cStr, "ﬁ", "&Igrave;")
      cStr := STRTRAN(cStr, "¢", "&oacute;")
      cStr := STRTRAN(cStr, "‡", "&Oacute;")
      cStr := STRTRAN(cStr, "ï", "&ograve;")
      cStr := STRTRAN(cStr, "„", "&Ograve;")
      cStr := STRTRAN(cStr, "£", "&uacute;")
      cStr := STRTRAN(cStr, "È", "&Uacute;")
      cStr := STRTRAN(cStr, "ó", "&ugrave;")
      cStr := STRTRAN(cStr, "Î", "&Ugrave;")
      cStr := STRTRAN(cStr, "É", "&acirc;")
      cStr := STRTRAN(cStr, "∂", "&Acirc;")
      cStr := STRTRAN(cStr, "à", "&ecirc;")
      cStr := STRTRAN(cStr, "“", "&Ecirc;")
      cStr := STRTRAN(cStr, "ì", "&ocirc;")
      cStr := STRTRAN(cStr, "‚", "&Ocirc;")
      cStr := STRTRAN(cStr, "∆", "&atilde;")
      cStr := STRTRAN(cStr, "«", "&Atilde;")
      cStr := STRTRAN(cStr, "‰", "&otilde;")
      cStr := STRTRAN(cStr, "Â", "&Otilde;")
      cStr := STRTRAN(cStr, "á", "&ccedil;")
      cStr := STRTRAN(cStr, "Ä", "&Ccedil;")
      cStr := STRTRAN(cStr, "ò", "&yuml;")
      cStr := STRTRAN(cStr, "î", "&ouml;")
      cStr := STRTRAN(cStr, "ô", "&Ouml;")
      cStr := STRTRAN(cStr, "§", "&ntilde;")
      cStr := STRTRAN(cStr, "•", "&Ntilde;")
      cStr := STRTRAN(cStr, "Å", "&uuml;")
      cStr := STRTRAN(cStr, "ö", "&Uuml;")
      cStr := STRTRAN(cStr, "ß", "&deg;")
      cStr := STRTRAN(cStr, "¯", "&deg;")
      cStr := STRTRAN(cStr, "¶", "&ordf;")
   ENDIF

RETURN cStr

/* -------------------------------------------------------------------------- */

FUNCTION RetiraAcento( cStr,  lAll )

   LOCAL nI
   LOCAL nLen := LEN(cStr)
   LOCAL cChar
   LOCAL Ret := ""

   DEFAULT lAll TO .F.

   IF lAll
   #ifdef HB_STD_CH_
      FOR EACH cChar IN cStr
   #else
      FOR nI := 1 TO nLen
          cChar := SUBSTR(cStr,  nI,  1)
   #endif
          DO CASE //SWITCH cChar
          CASE cChar $ "™" + CHR(166)
              cChar := "a."
          CASE cChar $ "∫∞ß"
              cChar := "o."
          CASE cChar $ "†Ö„∆‰ÑÉ"
              cChar := "a"
          CASE cChar $ "¡µ¿∑√¬∂"
              cChar := "A"
          CASE cChar $ "…ê “"
              cChar := "E"
          CASE cChar $ "°"
              cChar := "i"
          CASE cChar $ "Õ÷"
              cChar := "I"
          CASE cChar $ "¢ı‰ˆì"
              cChar := "o"
          CASE cChar $ "”’Â‘‚"
              cChar := "O"
          CASE cChar $ "£Å"
              cChar := "u"
          CASE cChar == "⁄‹ö"
              cChar := "U"
          END
          Ret += cChar
      NEXT
   ELSE
   #ifdef HB_STD_CH_
      FOR EACH cChar IN cStr
   #else
      FOR nI := 1 TO nLen
          cChar := SUBSTR(cStr,  nI,  1)
   #endif
          DO CASE //SWITCH cChar
          CASE cChar $ "™" + CHR(166)
              cChar := "a."
          CASE cChar $ "∫∞ß"
              cChar := "o."
          CASE cChar $ "Áá"
              cChar := "c"
          CASE cChar $ "«Ä"
              cChar := "C"
          CASE cChar $ "·†‡Ö„∆‰Ñ‚É"
              cChar := "a"
          CASE cChar $ "¡µ¿∑√¬∂"
              cChar := "A"
          CASE cChar $ "ÈÇÍà"
              cChar := "e"
          CASE cChar $ "…ê “"
              cChar := "E"
          CASE cChar $ "Ì°"
              cChar := "i"
          CASE cChar $ "Õ÷"
              cChar := "I"
          CASE cChar $ "Û¢ı‰ˆÙì"
              cChar := "o"
          CASE cChar $ "”’Â‘‚"
              cChar := "O"
          CASE cChar $ "˙£¸Å"
              cChar := "u"
          CASE cChar == "⁄‹ö"
              cChar := "U"
          END
          Ret += cChar
      NEXT
   ENDIF

RETURN Ret
