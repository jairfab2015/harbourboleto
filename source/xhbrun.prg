/*
 * $Id: xhbrun.prg,v 1.11 2013/04/23 11:40:18 marioargon Exp $
*/

#include "common.ch"

/* -------------------------------------------------------------------------- */

FUNCTION xhbrun( cCommand, lWait, lBackG )
   LOCAL hIn, hOut, hProc, nRet

   hProc := HB_OpenProcess(cCommand, @hIn, @hOut, @hOut, lBackG)
   IF hProc > 0
      nRet :=  HB_ProcessValue(hProc, lWait)
   ENDIF
   FCLOSE(hProc)
   FCLOSE(hIn)
   FCLOSE(hOut)
RETURN nRet

#IFNDEF __PLATFORM__Linux
#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

//ShellExecute( cFile, cOperation, cParams, cDir, nFlag )

HB_FUNC( SHELLEXECUTE )
{
   hb_retnl( (LONG) ShellExecute( GetActiveWindow(),
              ISNIL(2) ? NULL : (LPCSTR) hb_parc(2),
              (LPCSTR) hb_parc(1),
              ISNIL(3) ? NULL : (LPCSTR) hb_parc(3),
              ISNIL(4) ? "C:\\" : (LPCSTR) hb_parc(4),
              ISNIL(5) ? 1 : hb_parni(5) ) ) ;
}

#pragma ENDDUMP
#ENDIF
