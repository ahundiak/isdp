/* Do not alter this SPC information: $Revision: 1.3.28.1 $ */
/********************************************************************
Name:		mgrdlg.c
Authors:	Alan Barksdale
Creation Date:	03/31/95
Description:	Dialog code for Schema Manager Utility

Revision History:
	03/31/95 AFB	Created the file.
********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "gcosbar.h"
#include "resource.h"
#include "mgr.h"

#define mgrdlg_c
#include "mgr.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"
#include "gcointro.prt"

/*____________________*/
/* Schema Information */
/*vvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandSchInfo(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandSchInfo");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandSchInfo");
} // Cls_OnCommandSchInfo

static BOOL Cls_OnInitDialogSchInfo(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogSchInfo");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogSchInfo");
	return(TRUE);
} // Cls_OnInitDialogSchInfo

extern LRESULT CALLBACK DlgProcSchInfo(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcSchInfo");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandSchInfo);

			_Debug(PROG,0,"return DlgProcSchInfo");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcSchInfo");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogSchInfo));
		break;
		default:
			_Debug(PROG,0,"return DlgProcSchInfo");
			return(FALSE);
		break;
	}
} // DlgProcSchInfo

/*^^^^^^^^^^^^^^^^^^^^*/
/* Schema Information */
/*____________________*/

/*___________*/
/* Databases */
/*vvvvvvvvvvv*/

static void Cls_OnCommandDbs(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandDbs");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandDbs");
} // Cls_OnCommandDbs

static BOOL Cls_OnInitDialogDbs(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogDbs");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogDbs");
	return(TRUE);
} // Cls_OnInitDialogDbs

static LRESULT CALLBACK DlgProcDbs(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcDbs");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandDbs);

			_Debug(PROG,0,"return DlgProcDbs");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcDbs");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogDbs));
		break;
		default:
			_Debug(PROG,0,"return DlgProcDbs");
			return(FALSE);
		break;
	}
} // DlgProcDbs


/*^^^^^^^^^^^*/
/* Databases */
/*___________*/

/*_______________*/
/* Create Schema */
/*vvvvvvvvvvvvvvv*/

static void Cls_OnCommandCreateSch(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	DWORD dwLastError;
	char szLastError[80];

	_Debug(PROG,0,"enter Cls_OnCommandCreateSch");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		case IDC_MGR_CREATE_SCH_DISP_DBS_BUTTON:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_DBS),hDlg,
				(DLGPROC)DlgProcDbs))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError, "DialogBox() failed; GetLastError returned %d", dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandCreateSch");
} // Cls_OnCommandCreateSch

static BOOL Cls_OnInitDialogCreateSch(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogCreateSch");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogCreateSch");
	return(TRUE);
} // Cls_OnInitDialogCreateSch

extern LRESULT CALLBACK DlgProcCreateSch(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcCreateSch");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandCreateSch);

			_Debug(PROG,0,"return DlgProcCreateSch");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcCreateSch");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogCreateSch));
		break;
		default:
			_Debug(PROG,0,"return DlgProcCreateSch");
			return(FALSE);
		break;
	}
} // DlgProcCreateSch

/*^^^^^^^^^^^^^^^*/
/* Create Schema */
/*_______________*/

/*_____________*/
/* Drop Schema */
/*vvvvvvvvvvvvv*/

static void Cls_OnCommandDropSch(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandDropSch");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandDropSch");
} // Cls_OnCommandDropSch

static BOOL Cls_OnInitDialogDropSch(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogDropSch");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogDropSch");
	return(TRUE);
} // Cls_OnInitDialogDropSch

extern LRESULT CALLBACK DlgProcDropSch(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcDropSch");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandDropSch);

			_Debug(PROG,0,"return DlgProcDropSch");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcDropSch");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogDropSch));
		break;
		default:
			_Debug(PROG,0,"return DlgProcDropSch");
			return(FALSE);
		break;
	}
} // DlgProcDropSch

/*^^^^^^^^^^^^^*/
/* Drop Schema */
/*_____________*/

/*______________________*/
/* Secure Schema Access */
/*vvvvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandSecureSchAccess(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandSecureSchAccess");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandSecureSchAccess");
} // Cls_OnCommandSecureSchAccess

static BOOL Cls_OnInitDialogSecureSchAccess(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogSecureSchAccess");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogSecureSchAccess");
	return(TRUE);
} // Cls_OnInitDialogSecureSchAccess

extern LRESULT CALLBACK DlgProcSecureSchAccess(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcSecureSchAccess");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandSecureSchAccess);

			_Debug(PROG,0,"return DlgProcSecureSchAccess");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcSecureSchAccess");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogSecureSchAccess));
		break;
		default:
			_Debug(PROG,0,"return DlgProcSecureSchAccess");
			return(FALSE);
		break;
	}
} // DlgProcSecureSchAccess

/*^^^^^^^^^^^^^^^^^^^^^^*/
/* Secure Schema Access */
/*______________________*/

/*___________________*/
/* Dictionary Access */
/*vvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandDictAccess(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandDictAccess");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandDictAccess");
} // Cls_OnCommandDictAccess

static BOOL Cls_OnInitDialogDictAccess(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogDictAccess");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogDictAccess");
	return(TRUE);
} // Cls_OnInitDialogDictAccess

extern LRESULT CALLBACK DlgProcDictAccess(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcDictAccess");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandDictAccess);

			_Debug(PROG,0,"return DlgProcDictAccess");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcDictAccess");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogDictAccess));
		break;
		default:
			_Debug(PROG,0,"return DlgProcDictAccess");
			return(FALSE);
		break;
	}
} // DlgProcDictAccess

/*^^^^^^^^^^^^^^^^^^^*/
/* Dictionary Access */
/*___________________*/

/*________________________*/
/* Modify Schema Password */
/*vvvvvvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandModSchPasswd(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandModSchPasswd");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandModSchPasswd");
} // Cls_OnCommandModSchPasswd

static BOOL Cls_OnInitDialogModSchPasswd(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogModSchPasswd");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogModSchPasswd");
	return(TRUE);
} // Cls_OnInitDialogModSchPasswd

extern LRESULT CALLBACK DlgProcModSchPasswd(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcModSchPasswd");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandModSchPasswd);

			_Debug(PROG,0,"return DlgProcModSchPasswd");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcModSchPasswd");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogModSchPasswd));
		break;
		default:
			_Debug(PROG,0,"return DlgProcModSchPasswd");
			return(FALSE);
		break;
	}
} // DlgProcModSchPasswd

/*^^^^^^^^^^^^^^^^^^^^^^^^*/
/* Modify Schema Password */
/*________________________*/

/*_________________________*/
/* Modify Node Information */
/*vvvvvvvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandModNodeInfo(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandModNodeInfo");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandModNodeInfo");
} // Cls_OnCommandModNodeInfo

static BOOL Cls_OnInitDialogModNodeInfo(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogModNodeInfo");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogModNodeInfo");
	return(TRUE);
} // Cls_OnInitDialogModNodeInfo

extern LRESULT CALLBACK DlgProcModNodeInfo(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcModNodeInfo");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandModNodeInfo);

			_Debug(PROG,0,"return DlgProcModNodeInfo");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcModNodeInfo");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogModNodeInfo));
		break;
		default:
			_Debug(PROG,0,"return DlgProcModNodeInfo");
			return(FALSE);
		break;
	}
} // DlgProcModNodeInfo

/*^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* Modify Node Information */
/*_________________________*/

/*_____________________*/
/* Modify DB2 Password */
/*vvvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandModDb2Passwd(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandModDb2Passwd");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandModDb2Passwd");
} // Cls_OnCommandModDb2Passwd

static BOOL Cls_OnInitDialogModDb2Passwd(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogModDb2Passwd");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogModDb2Passwd");
	return(TRUE);
} // Cls_OnInitDialogModDb2Passwd

extern LRESULT CALLBACK DlgProcModDb2Passwd(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcModDb2Passwd");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandModDb2Passwd);

			_Debug(PROG,0,"return DlgProcModDb2Passwd");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcModDb2Passwd");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogModDb2Passwd));
		break;
		default:
			_Debug(PROG,0,"return DlgProcModDb2Passwd");
			return(FALSE);
		break;
	}
} // DlgProcModDb2Passwd

/*^^^^^^^^^^^^^^^^^^^^^*/
/* Modify DB2 Password */
/*_____________________*/

/*___________________*/
/* Table Information */
/*vvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandTblInfo(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandTblInfo");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandTblInfo");
} // Cls_OnCommandTblInfo

static BOOL Cls_OnInitDialogTblInfo(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogTblInfo");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogTblInfo");
	return(TRUE);
} // Cls_OnInitDialogTblInfo

extern LRESULT CALLBACK DlgProcTblInfo(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcTblInfo");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandTblInfo);

			_Debug(PROG,0,"return DlgProcTblInfo");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcTblInfo");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogTblInfo));
		break;
		default:
			_Debug(PROG,0,"return DlgProcTblInfo");
			return(FALSE);
		break;
	}
} // DlgProcTblInfo

/*^^^^^^^^^^^^^^^^^^^*/
/* Table Information */
/*___________________*/

/*______________*/
/* Create Table */
/*vvvvvvvvvvvvvv*/

static void Cls_OnCommandCreateTbl(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandCreateTbl");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandCreateTbl");
} // Cls_OnCommandCreateTbl

static BOOL Cls_OnInitDialogCreateTbl(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogCreateTbl");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogCreateTbl");
	return(TRUE);
} // Cls_OnInitDialogCreateTbl

extern LRESULT CALLBACK DlgProcCreateTbl(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcCreateTbl");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandCreateTbl);

			_Debug(PROG,0,"return DlgProcCreateTbl");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcCreateTbl");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogCreateTbl));
		break;
		default:
			_Debug(PROG,0,"return DlgProcCreateTbl");
			return(FALSE);
		break;
	}
} // DlgProcCreateTbl

/*^^^^^^^^^^^^^^*/
/* Create Table */
/*______________*/

/*______*/
/* Drop */
/*vvvvvv*/

static void Cls_OnCommandDrop(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandDrop");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandDrop");
} // Cls_OnCommandDrop

static BOOL Cls_OnInitDialogDrop(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogDrop");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogDrop");
	return(TRUE);
} // Cls_OnInitDialogDrop

extern LRESULT CALLBACK DlgProcDrop(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcDrop");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandDrop);

			_Debug(PROG,0,"return DlgProcDrop");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcDrop");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogDrop));
		break;
		default:
			_Debug(PROG,0,"return DlgProcDrop");
			return(FALSE);
		break;
	}
} // DlgProcDrop

/*^^^^^^*/
/* Drop */
/*______*/

/*_____________*/
/* Alter Table */
/*vvvvvvvvvvvvv*/

static void Cls_OnCommandAlterTbl(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandAlterTbl");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandAlterTbl");
} // Cls_OnCommandAlterTbl

static BOOL Cls_OnInitDialogAlterTbl(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogAlterTbl");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogAlterTbl");
	return(TRUE);
} // Cls_OnInitDialogAlterTbl

extern LRESULT CALLBACK DlgProcAlterTbl(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcAlterTbl");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandAlterTbl);

			_Debug(PROG,0,"return DlgProcAlterTbl");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcAlterTbl");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogAlterTbl));
		break;
		default:
			_Debug(PROG,0,"return DlgProcAlterTbl");
			return(FALSE);
		break;
	}
} // DlgProcAlterTbl

/*^^^^^^^^^^^^^*/
/* Alter Table */
/*_____________*/

/*_________*/
/* Include */
/*vvvvvvvvv*/

static void Cls_OnCommandInclude(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandInclude");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandInclude");
} // Cls_OnCommandInclude

static BOOL Cls_OnInitDialogInclude(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogInclude");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogInclude");
	return(TRUE);
} // Cls_OnInitDialogInclude

extern LRESULT CALLBACK DlgProcInclude(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcInclude");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandInclude);

			_Debug(PROG,0,"return DlgProcInclude");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcInclude");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogInclude));
		break;
		default:
			_Debug(PROG,0,"return DlgProcInclude");
			return(FALSE);
		break;
	}
} // DlgProcInclude

/*^^^^^^^^^*/
/* Include */
/*_________*/

/*_________*/
/* Exclude */
/*vvvvvvvvv*/

static void Cls_OnCommandExclude(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandExclude");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandExclude");
} // Cls_OnCommandExclude

static BOOL Cls_OnInitDialogExclude(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogExclude");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogExclude");
	return(TRUE);
} // Cls_OnInitDialogExclude

extern LRESULT CALLBACK DlgProcExclude(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcExclude");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandExclude);

			_Debug(PROG,0,"return DlgProcExclude");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcExclude");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogExclude));
		break;
		default:
			_Debug(PROG,0,"return DlgProcExclude");
			return(FALSE);
		break;
	}
} // DlgProcExclude

/*^^^^^^^^^*/
/* Exclude */
/*_________*/

/*_____________*/
/* Schema File */
/*vvvvvvvvvvvvv*/

static void Cls_OnCommandSchFile(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandSchFile");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandSchFile");
} // Cls_OnCommandSchFile

static BOOL Cls_OnInitDialogSchFile(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogSchFile");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogSchFile");
	return(TRUE);
} // Cls_OnInitDialogSchFile

extern LRESULT CALLBACK DlgProcSchFile(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcSchFile");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandSchFile);

			_Debug(PROG,0,"return DlgProcSchFile");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcSchFile");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogSchFile));
		break;
		default:
			_Debug(PROG,0,"return DlgProcSchFile");
			return(FALSE);
		break;
	}
} // DlgProcSchFile

/*^^^^^^^^^^^^^*/
/* Schema File */
/*_____________*/

/*_______________*/
/* Locate Client */
/*vvvvvvvvvvvvvvv*/

static void Cls_OnCommandLocateClient(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandLocateClient");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandLocateClient");
} // Cls_OnCommandLocateClient

static BOOL Cls_OnInitDialogLocateClient(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogLocateClient");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogLocateClient");
	return(TRUE);
} // Cls_OnInitDialogLocateClient

extern LRESULT CALLBACK DlgProcLocateClient(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcLocateClient");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandLocateClient);

			_Debug(PROG,0,"return DlgProcLocateClient");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcLocateClient");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogLocateClient));
		break;
		default:
			_Debug(PROG,0,"return DlgProcLocateClient");
			return(FALSE);
		break;
	}
} // DlgProcLocateClient

/*^^^^^*/
/* Set */
/*_____*/

/*^^^^^^^^^^^^^^^*/
/* Locate Client */
/*_______________*/

/*_____*/
/* Set */
/*vvvvv*/

static void Cls_OnCommandSet(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandSet");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandSet");
} // Cls_OnCommandSet

static BOOL Cls_OnInitDialogSet(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogSet");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogSet");
	return(TRUE);
} // Cls_OnInitDialogSet

extern LRESULT CALLBACK DlgProcSet(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcSet");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandSet);

			_Debug(PROG,0,"return DlgProcSet");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcSet");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogSet));
		break;
		default:
			_Debug(PROG,0,"return DlgProcSet");
			return(FALSE);
		break;
	}
} // DlgProcSet

/*^^^^^*/
/* Set */
/*_____*/
