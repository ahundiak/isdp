/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcopsup.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Product Support Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include "gco.h"
#include "gcortns.h"
#include "resource.h"

#define gcopsup_c
#include "gcopsup.prt"
#include "gcortns.prt"
#include "gcosbar.prt"

static BOOL Cls_OnInitDialog(
	HWND hwnd,
	HWND hwndFocus,
	LPARAM lParam)
{
	Edit_SetText(GetDlgItem(hwnd,IDC_PRODSUP_TEXT), _GetResourceString(gco.hhLib,IDS_PRODSUP_TEXT));

	_CenterWindowOnScreen(hwnd);
	return TRUE ;
}


static void Cls_OnCommand(
	HWND hwnd,
	int id,
	HWND hwndCtl,
	UINT codeNotify)
{
	switch (id)
	{
		case IDOK:
		case IDCANCEL:
		{
			EndDialog(hwnd, TRUE);
		}
		break;
	}
}

static void Cls_OnPaint(
	HWND hwnd)
{
	HDC hdc, hdcMemory;
	HBITMAP hBitmap, hbmpOld;
	BITMAP bm;
	HWND hwnd1;
	RECT rect;

	hwnd1 = GetDlgItem(hwnd,IDC_PRODSUP_BITMAP);

	hBitmap = LoadBitmap(gco.hhLib,"RISprodsup");
	GetObject(hBitmap, sizeof(BITMAP), &bm);

	hdc = GetDC(hwnd1);
	hdcMemory = CreateCompatibleDC(hdc);
	hbmpOld = SelectObject(hdcMemory, hBitmap);

	GetClientRect(hwnd1,&rect);
//	StretchBlt(hdc,0,0,bm.bmWidth,bm.bmHeight,hdcMemory,rect.left,rect.top,rect.right,rect.bottom,SRCCOPY);
	BitBlt(hdc, 0, 0, bm.bmWidth, bm.bmHeight, hdcMemory, 0, 0, SRCCOPY);
	SelectObject(hdcMemory, hbmpOld);
	DeleteDC(hdcMemory);
	ReleaseDC(hwnd1, hdc);
}


extern LRESULT CALLBACK ProductSupport(
	HWND hDlg,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	BOOL fProcessed = TRUE;

	switch (uMessage)
	{

		HANDLE_MSG(hDlg,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hDlg,WM_PAINT,Cls_OnPaint);
		HANDLE_MSG(hDlg,WM_INITDIALOG,Cls_OnInitDialog);

		default:
			fProcessed = FALSE;
			break;
	}
	return fProcessed;
}



