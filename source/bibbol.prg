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
      cStr := STRTRAN(cStr, "�", "&aacute;")
      cStr := STRTRAN(cStr, "�", "&Aacute;")
      cStr := STRTRAN(cStr, "�", "&agrave;")
      cStr := STRTRAN(cStr, "�", "&Agrave;")
      cStr := STRTRAN(cStr, "�", "&eacute;")
      cStr := STRTRAN(cStr, "�", "&Eacute;")
      cStr := STRTRAN(cStr, "�", "&egrave;")
      cStr := STRTRAN(cStr, "�", "&egrave;")
      cStr := STRTRAN(cStr, "�", "&iacute;")
      cStr := STRTRAN(cStr, "�", "&Iacute;")
      cStr := STRTRAN(cStr, "�", "&igrave;")
      cStr := STRTRAN(cStr, "�", "&Igrave;")
      cStr := STRTRAN(cStr, "�", "&oacute;")
      cStr := STRTRAN(cStr, "�", "&Oacute;")
      cStr := STRTRAN(cStr, "�", "&ograve;")
      cStr := STRTRAN(cStr, "�", "&Ograve;")
      cStr := STRTRAN(cStr, "�", "&uacute;")
      cStr := STRTRAN(cStr, "�", "&Uacute;")
      cStr := STRTRAN(cStr, "�", "&ugrave;")
      cStr := STRTRAN(cStr, "�", "&Ugrave;")
      cStr := STRTRAN(cStr, "�", "&acirc;")
      cStr := STRTRAN(cStr, "�", "&Acirc;")
      cStr := STRTRAN(cStr, "�", "&ecirc;")
      cStr := STRTRAN(cStr, "�", "&Ecirc;")
      cStr := STRTRAN(cStr, "�", "&ocirc;")
      cStr := STRTRAN(cStr, "�", "&Ocirc;")
      cStr := STRTRAN(cStr, "�", "&atilde;")
      cStr := STRTRAN(cStr, "�", "&Atilde;")
      cStr := STRTRAN(cStr, "�", "&otilde;")
      cStr := STRTRAN(cStr, "�", "&Otilde;")
      cStr := STRTRAN(cStr, "�", "&ccedil;")
      cStr := STRTRAN(cStr, "�", "&Ccedil;")
      cStr := STRTRAN(cStr, "�", "&yuml;")
      cStr := STRTRAN(cStr, "�", "&ouml;")
      cStr := STRTRAN(cStr, "�", "&Ouml;")
      cStr := STRTRAN(cStr, "�", "&ntilde;")
      cStr := STRTRAN(cStr, "�", "&Ntilde;")
      cStr := STRTRAN(cStr, "�", "&uuml;")
      cStr := STRTRAN(cStr, "�", "&Uuml;")
      cStr := STRTRAN(cStr, "�", "&deg;")
      cStr := STRTRAN(cStr, "�", "&deg;")
      cStr := STRTRAN(cStr, "�", "&ordf;")
   ELSE
      cStr := STRTRAN(cStr, "�", "&aacute;")
      cStr := STRTRAN(cStr, "�", "&Aacute;")
      cStr := STRTRAN(cStr, "�", "&agrave;")
      cStr := STRTRAN(cStr, "�", "&Agrave;")
      cStr := STRTRAN(cStr, "�", "&eacute;")
      cStr := STRTRAN(cStr, "�", "&Eacute;")
      cStr := STRTRAN(cStr, "�", "&egrave;")
      cStr := STRTRAN(cStr, "�", "&Egrave;")
      cStr := STRTRAN(cStr, "�", "&iacute;")
      cStr := STRTRAN(cStr, "�", "&Iacute;")
      cStr := STRTRAN(cStr, "�", "&igrave;")
      cStr := STRTRAN(cStr, "�", "&Igrave;")
      cStr := STRTRAN(cStr, "�", "&oacute;")
      cStr := STRTRAN(cStr, "�", "&Oacute;")
      cStr := STRTRAN(cStr, "�", "&ograve;")
      cStr := STRTRAN(cStr, "�", "&Ograve;")
      cStr := STRTRAN(cStr, "�", "&uacute;")
      cStr := STRTRAN(cStr, "�", "&Uacute;")
      cStr := STRTRAN(cStr, "�", "&ugrave;")
      cStr := STRTRAN(cStr, "�", "&Ugrave;")
      cStr := STRTRAN(cStr, "�", "&acirc;")
      cStr := STRTRAN(cStr, "�", "&Acirc;")
      cStr := STRTRAN(cStr, "�", "&ecirc;")
      cStr := STRTRAN(cStr, "�", "&Ecirc;")
      cStr := STRTRAN(cStr, "�", "&ocirc;")
      cStr := STRTRAN(cStr, "�", "&Ocirc;")
      cStr := STRTRAN(cStr, "�", "&atilde;")
      cStr := STRTRAN(cStr, "�", "&Atilde;")
      cStr := STRTRAN(cStr, "�", "&otilde;")
      cStr := STRTRAN(cStr, "�", "&Otilde;")
      cStr := STRTRAN(cStr, "�", "&ccedil;")
      cStr := STRTRAN(cStr, "�", "&Ccedil;")
      cStr := STRTRAN(cStr, "�", "&yuml;")
      cStr := STRTRAN(cStr, "�", "&ouml;")
      cStr := STRTRAN(cStr, "�", "&Ouml;")
      cStr := STRTRAN(cStr, "�", "&ntilde;")
      cStr := STRTRAN(cStr, "�", "&Ntilde;")
      cStr := STRTRAN(cStr, "�", "&uuml;")
      cStr := STRTRAN(cStr, "�", "&Uuml;")
      cStr := STRTRAN(cStr, "�", "&deg;")
      cStr := STRTRAN(cStr, "�", "&deg;")
      cStr := STRTRAN(cStr, "�", "&ordf;")
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
          CASE cChar $ "�" + CHR(166)
              cChar := "a."
          CASE cChar $ "���"
              cChar := "o."
          CASE cChar $ "����䄃"
              cChar := "a"
          CASE cChar $ "�����¶"
              cChar := "A"
          CASE cChar $ "ɐ��"
              cChar := "E"
          CASE cChar $ "�"
              cChar := "i"
          CASE cChar $ "��"
              cChar := "I"
          CASE cChar $ "�����"
              cChar := "o"
          CASE cChar $ "�����"
              cChar := "O"
          CASE cChar $ "��"
              cChar := "u"
          CASE cChar == "�ܚ"
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
          CASE cChar $ "�" + CHR(166)
              cChar := "a."
          CASE cChar $ "���"
              cChar := "o."
          CASE cChar $ "�"
              cChar := "c"
          CASE cChar $ "ǀ"
              cChar := "C"
          CASE cChar $ "�������"
              cChar := "a"
          CASE cChar $ "�����¶"
              cChar := "A"
          CASE cChar $ "��"
              cChar := "e"
          CASE cChar $ "ɐ��"
              cChar := "E"
          CASE cChar $ "�"
              cChar := "i"
          CASE cChar $ "��"
              cChar := "I"
          CASE cChar $ "������"
              cChar := "o"
          CASE cChar $ "�����"
              cChar := "O"
          CASE cChar $ "����"
              cChar := "u"
          CASE cChar == "�ܚ"
              cChar := "U"
          END
          Ret += cChar
      NEXT
   ENDIF

RETURN Ret
