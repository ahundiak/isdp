/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcotmess.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Timed Message Box Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>

#define gcotmess_c
#include "gcotmess.prt"

typedef struct MSG_BOX_INFO
{
  LPSTR lptext;
  LPSTR lpcaption;
  UINT  boxtype;
  UINT  defresp;
  UINT  timeoutval;
} MSG_BOX_INFO;

typedef MSG_BOX_INFO FAR *LPMSGBOXINFO;

/****************************************************************************
_TimedMsgBox
****************************************************************************/
extern int _TimedMsgBox(
	HINSTANCE hInst,
	HWND hwnd,
	LPSTR lpText,
	LPSTR lpCaption,
	UINT wBoxType,
	UINT def_resp,
	UINT timeoutval)
{
  FARPROC      lpfnMsgBoxProc;
  HGLOBAL      hGlob;
  LPMSGBOXINFO pBoxInfo;
  int          retval;

  hGlob = GlobalAlloc(GHND, sizeof(MSG_BOX_INFO)); 
  if (hGlob == NULL)
    return(-1);
  pBoxInfo = (LPMSGBOXINFO) GlobalLock(hGlob);

  pBoxInfo->lptext     = lpText;
  pBoxInfo->lpcaption  = lpCaption;
  pBoxInfo->boxtype    = wBoxType;
  pBoxInfo->defresp    = def_resp;
  pBoxInfo->timeoutval = timeoutval * 1000;

  GlobalUnlock(hGlob);

  lpfnMsgBoxProc = MakeProcInstance ((FARPROC)MsgBoxProc,
                                                     hInst);
  retval = DialogBoxParam (hInst, "TimedMsgBoxDummy",
                              hwnd, (DLGPROC)lpfnMsgBoxProc,
                                 (LPARAM)(void FAR *)hGlob);

  FreeProcInstance(lpfnMsgBoxProc);
  GlobalFree(hGlob);
  return(retval);
}

/****************************************************************************
MsgBoxProc
****************************************************************************/
static LRESULT CALLBACK MsgBoxProc(
	HWND hDlg,
	UINT msg,
	WPARAM wParam,
	LPARAM lParam)
{
  HWND         hwnd;
  HGLOBAL      hBoxInfo;
  LPMSGBOXINFO pmBoxInfo;
  LPSTR        lptext;
  LPSTR        lpcaption;
  UINT         boxtype;

  switch (msg)
    {
      case WM_INITDIALOG:
        hBoxInfo   = (HGLOBAL)lParam;
        if (!SetProp(hDlg, "MSGBOXDATA", hBoxInfo))
          {
            EndDialog(hDlg, -1);
            return FALSE;
          }
        pmBoxInfo  = (LPMSGBOXINFO) GlobalLock(hBoxInfo); 
        lptext     = pmBoxInfo->lptext;
        lpcaption  = pmBoxInfo->lpcaption;
        boxtype    = pmBoxInfo->boxtype;

        ShowWindow (hDlg, SW_HIDE);
        if (pmBoxInfo->timeoutval != 0)
          pmBoxInfo->timeoutval = SetTimer(hDlg, pmBoxInfo->defresp,
                                           pmBoxInfo->timeoutval, NULL);
        GlobalUnlock(hBoxInfo);
        EndDialog(hDlg, MessageBoxEx(hDlg, lptext, lpcaption, boxtype,MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT))); 
        return TRUE;

      case WM_TIMER:
        hBoxInfo = GetProp(hDlg, "MSGBOXDATA"); 
        if (hBoxInfo)
          {
            pmBoxInfo = (LPMSGBOXINFO) GlobalLock(hBoxInfo); 
            lpcaption  = pmBoxInfo->lpcaption;
            GlobalUnlock(hBoxInfo);
            if ((hwnd=FindWindow("#32770", lpcaption)) != 0)
              EndDialog(hwnd, (int)wParam);
          }
        return TRUE;

      case WM_DESTROY :
        hBoxInfo = GetProp(hDlg, "MSGBOXDATA"); 
        if (hBoxInfo)
          {
            pmBoxInfo = (LPMSGBOXINFO) GlobalLock(hBoxInfo); 
            if (pmBoxInfo->timeoutval != 0)
              KillTimer(hDlg, pmBoxInfo->timeoutval);
            GlobalUnlock(hBoxInfo);
          }
        break;
    }
  return FALSE;
}

