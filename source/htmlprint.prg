/*
 * $Id$
*/
/*
 * xHarbour Project source code:
 * HTMLPRINT engine library class
 *
 * Copyright 2007-2007 Laverson Espíndola <laverson.espindola@gmail.com>
 * www - http://www.xharbour.org http://www.harbour-project.org
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

#include "hbclass.ch"
#include "common.ch"

#command DEFAULT <param> := <val> [, <paramn> := <valn> ];
=> ;
         <param> := IIF(<param> = NIL, <val>, <param> ) ;
         [; <paramn> := IIF(<paramn> = NIL, <valn>, <paramn> ) ]

#DEFINE OLECMDID_PRINT 6
#DEFINE OLECMDEXECOPT_PROMPTUSER 1
#DEFINE LECMDEXECOPT_DONTPROMPTUSER 2

#DEFINE OLECMDF_SUPPORTED 1
#DEFINE OLECMDF_ENABLED 2

#DEFINE READYSTATE_COMPLETE 4
#DEFINE MAX_TIME 30

#define HKEY_LOCAL_MACHINE  0
#define HKEY_CLASSES_ROOT   1
#define HKEY_CURRENT_USER   2
#define HKEY_CURRENT_CONFIG 3
#define HKEY_LOCAL_MACHINE  4
#define HKEY_USERS          5

#define VERSION             "1.0.01"

STATIC IEHeader
STATIC IEFooter
STATIC IEMarginBottom
STATIC IEMarginLeft
STATIC IEMarginRight
STATIC IEMarginTop
STATIC IEKey  := "Software\Microsoft\Internet Explorer\PageSetup"

STATIC WB
STATIC PR

STATIC HP

//--------------------------------------------------------------------------------------------//
FUNCTION PrintHTML(cURL,cPrinter,lPrevIew,lPromptPrint,lPrintHtml,cHeader,cFooter)

   DEFAULT lPrintHtml   := .T.
   DEFAULT lPreview     := .F.
   DEFAULT lPromptPrint := .F.
   DEFAULT cPrinter     := ""
   #ifdef __PLATFORM__Windows
      DEFAULT cPrinter  := GetDefaultPrinter()
   #endif
   DEFAULT cFooter      := ""
   DEFAULT cHeader      := ""

   IF (HP==NIL)
      HP := HTMLPRINT():NEW()
   ENDIF

   HP:PrintUrl     := cURL
   HP:lPreview     := lPreview
   HP:lPromptPrint := lPromptPrint
   HP:lPrintHtml   := lPrintHtml
   HP:PrinterName  := cPrinter
   HP:Footer       := cFooter
   HP:Header       := cHeader

   HP:Print()
   HP:Close()

RETURN .T.
//--------------------------------------------------------------------------------------------//

CLASS HTMLPRINT

   DATA PrinterName
   DATA Orientation            //TO DO  to implement
   DATA Copies                 //TO DO  to implement
   DATA Key  PROTECTED         //TO DO  to implement
   DATA Header
   DATA Footer
   DATA BackGround             //TO DO  to implement
   DATA MarginButtom
   DATA MarginLeft
   DATA MarginTop
   DATA MarginRight
   DATA MarginMeasure          //TO DO  to implement
   DATA PaperSize              //TO DO  to implement
   DATA PrintUrl

   DATA lPreview
   DATA lPromptPrint
   DATA lPrintHtml

   #ifdef __PLATFORM__Windows
     DATA PrintDefault INIT GetDefaultPrinter() PROTECTED
   #Else
     DATA PrintDefault INIT "" PROTECTED
   #Endif

   METHOD New() CONSTRUCTOR
   METHOD Print()
   METHOD savePrintSetup() PROTECTED
   METHOD restorePrintSetup() PROTECTED
   METHOD changePrintSetup PROTECTED
   METHOD Close()

ENDCLASS

//--------------------------------------------------------------------------------------------//

METHOD New() CLASS HTMLPRINT

   StartObjectWs()
   StartObjectPr()

   ::savePrintSetup()

RETURN Self

//--------------------------------------------------------------------------------------------//
METHOD Print() CLASS HTMLPRINT

   LOCAL lnStarted        && Seconds started for the document
   LOCAL lnWaiting   := 0 && Seconds waiting for the document to load

   DEFAULT ::PrinterName  := ::PrintDefault
   DEFAULT ::Orientation  := 2
   DEFAULT ::Copies       := 1
   DEFAULT ::Footer       := ""
   DEFAULT ::Header       := ""
   DEFAULT ::MarginButtom  := IEMarginBottom
   DEFAULT ::MarginLeft    := IEMarginLeft
   DEFAULT ::MarginTop     := IEMarginTop
   DEFAULT ::MarginRight   := IEMarginRight
   DEFAULT ::MarginMeasure := 1
   DEFAULT ::PaperSize     := 9

   DEFAULT ::lPreview     := .F.
   DEFAULT ::lPromptPrint := .F.
   DEFAULT ::lPrintHtml   := .T.

   lnStarted := SECONDS()

   IF ::PrintUrl != NIL

      // Configura impressora  seta impressora como padrao
      IF ::lPrintHtml
         TRY
            IF ::PrintDefault <> ::PrinterName
             //PR:AddWindowsPrinterConnection(::PrinterName)
               PR:SetDefaultPrinter(::PrinterName)
            ENDIF
         CATCH
            RETURN Throw(ErrorNew( "HTMLPrint", 0, 0, ProcName(),"Não foi possivel mapear impressora !"))
         END
      ENDIF

      ::changePrintSetup()

      WB:Visible    := ::lPreview
      WB:Navigate(::PrintUrl)

      WHILE WB:Readystate <> READYSTATE_COMPLETE .OR. lnWaiting >= MAX_TIME
         lnWaiting = Seconds() - lnStarted
      ENDDO

      WHILE WB:QueryStatusWB(OLECMDID_PRINT) != (OLECMDF_SUPPORTED + OLECMDF_ENABLED)
      ENDDO

      // Imprime ou Nao
      IF ::lPrintHtml
        WB:ExecWB(OLECMDID_PRINT, If(::lPromptPrint, OLECMDEXECOPT_PROMPTUSER, LECMDEXECOPT_DONTPROMPTUSER) )
      ENDIF

   ELSE
      RETURN .F.
   ENDIF

RETURN .T.

//--------------------------------------------------------------------------------------------//
METHOD savePrintSetup() CLASS HTMLPRINT

   // Salva o que está definido como padrão
   IEFooter       := getRegistry( HKEY_CURRENT_USER , IEKey, "footer")
   IEHeader       := getRegistry( HKEY_CURRENT_USER , IEKey, "header")
   IEMarginBottom := getRegistry( HKEY_CURRENT_USER , IEKey, "margin_bottom")
   IEMarginLeft   := getRegistry( HKEY_CURRENT_USER , IEKey , "margin_left")
   IEMarginRight  := getRegistry( HKEY_CURRENT_USER , IEKey , "margin_right")
   IEMarginTop    := getRegistry( HKEY_CURRENT_USER , IEKey, "margin_top")

RETURN NIL

//--------------------------------------------------------------------------------------------//
METHOD changePrintSetup() CLASS HTMLPRINT

   SetRegistry(HKEY_CURRENT_USER , IEKey , "footer",::Footer)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "header",::Header)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_bottom",::MarginButtom)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_left",::MarginLeft)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_right",::MarginRight)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_top",::MarginTop)

RETURN .T.

//--------------------------------------------------------------------------------------------//
METHOD restorePrintSetup() CLASS HTMLPRINT

   IF ( Empty(IEFooter) .Or. IEFooter == NIL )
      IEFooter := "&u&b&d"
   ENDIF

   IF ( Empty(IEHeader) .Or. IEFooter == NIL )
      IEHeader := "&w&bPage &p of &P"
   ENDIF

   SetRegistry(HKEY_CURRENT_USER , IEKey , "footer",IEFooter)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "header",IEHeader)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_bottom",IEMarginBottom)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_left",IEMarginLeft)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_right",IEMarginRight)
   SetRegistry(HKEY_CURRENT_USER , IEKey , "margin_top",IEMarginTop)

RETURN .T.

//--------------------------------------------------------------------------------------------//
METHOD close() CLASS HTMLPRINT

   // Restaura impressora se for o caso.
   PR:SetDefaultPrinter(::PrintDefault)
   ::restorePrintSetup()

   WB := NIL
   PR := NIL
   HP := NIL

RETURN NIL

//--------------------------------------------------------------------------------------------//
STATIC FUNCTION startObjectWS()

   TRY
      WB    := GetActiveObject( "InternetExplorer.Application" )
   CATCH
      TRY
         WB := CreateObject( "InternetExplorer.Application" )
      CATCH
         #ifdef __PLATFORM__Windows
           RETURN Throw(ErrorNew( "HTMLPrint", 0, 0, ProcName(),"ERROR! IExplorer not avialable. [" + Ole2TxtError()+ "]" ))
         #Endif
      END
   END

RETURN .T.

//--------------------------------------------------------------------------------------------//
STATIC FUNCTION startObjectPR()

   TRY
     PR := GetActiveObject("WScript.Network")
   CATCH
     TRY
       PR := CreateObject("WScript.Network")
     CATCH
       #ifdef __PLATFORM__Windows
         RETURN Throw(ErrorNew( "HTMLPrint", 0, 0, ProcName(),"ERROR! Printer network not avialable. [" + Ole2TxtError() + "]"))
       #Endif
     END
   END

RETURN .T.

/*
EOF
*/

/*
&w Window title
&u Page address (URL)
&d Date in short format specified by Regional Settings in Control Panel
&D Date in long format specified by Regional Settings in Control Panel
&t Time in the format specified by Regional Settings in Control Panel
&T Time in 24-hour format
&p Current page number
&P Total number of pages
&& A single ampersand (&)
&b The text immediately following these characters as centered
&b&b The text immediately following the first "&b" as centered, and the text following the second "&b" as right-justified
*/

//---------------------------------------------------------------------------//
/*
FUNCTION TWEB()

   StartObjectWs()

   PUBLICVAR("OIE")

   OIE := getWB()

RETURN OIE
*/
//---------------------------------------------------------------------------//
FUNCTION getHP()
RETURN HP

//---------------------------------------------------------------------------//
FUNCTION getWB
RETURN WB

//--------------------------------------------------------------------------//
FUNCTION HtmlPrintVersion()
RETURN VERSION
