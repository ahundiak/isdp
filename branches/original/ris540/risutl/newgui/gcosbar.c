/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcosbar.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Status Bar Functions

Revision History:

********************************************************************/
// Used from the sample program fontview

#define NOMINMAX
#include <windows.h>
#include <windowsx.h>
#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h> // For 'abs'
#include "gcosbar.h"
#include "gco.h"
#include "resource.h"

#if !defined (APIENTRY)
#define APIENTRY FAR PASCAL
#endif

#define gcosbar_c
#include "gcosbar.prt"

#define HOUR (datetime->tm_hour)
#define MIN (datetime->tm_min)
#define SEC (datetime->tm_sec)


#define MAXSTATUS 10
typedef struct _tagStatus {
    HWND    hwnd;
    int     iMaxWidth, iMinWidth, iGiveWidth;
} Status;
Status  statusField[MAXSTATUS];

HWND    hwndStatus;
int    cntStatusField = 0;
int    dyStatus, cxStatusBorder, cyStatusBorder, cxFrame, cyFrame, dyField;
HFONT   hfontStatus;
TEXTMETRIC tmStatusFont;
HBRUSH hbrBtnFace;


extern BOOL _InitStatusBar(
	HWND hwnd)
{
    WNDCLASS    wndclass;
	int iId;

    hbrBtnFace = CreateSolidBrush(GetSysColor(COLOR_BTNFACE));

    wndclass.style         = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc   = (WNDPROC)StatusProc;
    wndclass.cbClsExtra    = 0;
    wndclass.cbWndExtra    = 0;
    wndclass.hInstance      = gco.hhInst;
    wndclass.hIcon     = NULL;
    wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW);
    wndclass.hbrBackground = hbrBtnFace;
    wndclass.lpszMenuName  = NULL;
    wndclass.lpszClassName = "SamplerStatus";

    if (!RegisterClass (&wndclass))
	{
        return FALSE;
	}
    wndclass.style         = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc   = (WNDPROC)StatusFieldProc;
    wndclass.cbClsExtra    = 0;
    wndclass.cbWndExtra    = 0;
    wndclass.hInstance      = gco.hhInst;
    wndclass.hIcon     = NULL;
    wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW);
    wndclass.hbrBackground = hbrBtnFace;
    wndclass.lpszMenuName  = NULL;
    wndclass.lpszClassName = "StatusField";

    if (!RegisterClass (&wndclass))
	{
        return FALSE;
	}

	// create statusbar
    cxStatusBorder = GetSystemMetrics (SM_CXBORDER);
    cyStatusBorder = GetSystemMetrics (SM_CYBORDER);

	iId = ID_STATUSBAR;
	hwndStatus = CreateWindow ("SamplerStatus", "SamplerStatus",
        WS_CHILD | WS_BORDER | WS_VISIBLE,
        0, 0, 0, 0,
        hwnd, (HMENU)iId, gco.hhInst, NULL);

	if (!hwndStatus)
	{
		return FALSE;
	}

	hwndMenuField = _AddStatusField (gco.hhInst, ID_MENUFIELD, 100, 0, FALSE);
	hwndTimeField = _AddStatusField (gco.hhInst, ID_TIMEFIELD, -13, -13, TRUE);
	if (hwndTimeField)
	{
		SetTimer (hwnd, 1, 1000, NULL);
	}

	return TRUE;
}

static int StatusBarHeight(
	HWND hwnd)
{
    RECT rect;
    GetClientRect (hwndStatus, &rect);
    return rect.bottom-rect.top;

    hwnd; // unreferenced formal parameter
}

extern BOOL _AdjustStatusBar(
	HWND hwnd)
{
    RECT rect;
    GetClientRect (hwnd, &rect);
    MoveWindow (hwndStatus,
        rect.left-cxStatusBorder,
        rect.bottom - dyStatus + cyStatusBorder,
        rect.right - rect.left + (cxStatusBorder*2),
        dyStatus,
    TRUE);
    return TRUE;
}

static HWND _AddStatusField(
	HANDLE hInst,
	int iId,
	int iMin,
	int iMax,
	BOOL bNewGroup)
{
    LONG lStyle;

    if (cntStatusField >= MAXSTATUS) return (HWND)0; // No room left in our fixed array

    statusField[cntStatusField].hwnd = CreateWindow ("StatusField", "",
        WS_CHILD | WS_VISIBLE,
        0, 0, 0, 0,
        hwndStatus, (HMENU)iId, hInst, NULL);

    if (!statusField[cntStatusField].hwnd) return (HWND)0; // CreateWindow failed for some reason

    if (iMin < 0) {
    statusField[cntStatusField].iMinWidth = tmStatusFont.tmAveCharWidth*abs(iMin);
    } else {
    statusField[cntStatusField].iMinWidth = iMin;
    }

    if (iMax < 0) {
    statusField[cntStatusField].iMaxWidth = tmStatusFont.tmAveCharWidth*abs(iMax);
    } else {
    statusField[cntStatusField].iMaxWidth = iMax;
    }

    if (bNewGroup) {
        lStyle = GetWindowLong (statusField[cntStatusField].hwnd, GWL_STYLE);
        lStyle |= WS_GROUP;
        SetWindowLong (statusField[cntStatusField].hwnd, GWL_STYLE, lStyle);
    }

    return statusField[cntStatusField++].hwnd;
}

static BOOL DestroyStatusBar()
{
    return DeleteObject (hbrBtnFace);
}

static LONG APIENTRY StatusProc(
	HWND hwnd,
	UINT msg,
	UINT wParam,
	LONG lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    int x, y, i;
    int wAvailWidth, wFlexWidth, cntFlexWidth, wNeedWidth, cntNeedWidth;
    RECT    rect, border;
    HBRUSH  hBrush;
    LOGFONT lfTmp;

    switch (msg) {
        case WM_CREATE:
            hfontStatus = CreateFont(14, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0,
                VARIABLE_PITCH | FF_SWISS, "System");
//                VARIABLE_PITCH | FF_SWISS, "");

                        if (GetObject (hfontStatus, sizeof(LOGFONT), &lfTmp)) {
                                if ((lfTmp.lfPitchAndFamily & VARIABLE_PITCH) &&
                                   (lfTmp.lfPitchAndFamily & FF_SWISS)) {
                                } else {
                                        MessageBox (GetFocus(),
"Unable to get an unnamed variable pitch swiss font", "Status Bar CreateFont Error",
                                                MB_OK);
                hfontStatus = CreateFont(14, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0,
                        VARIABLE_PITCH | FF_SWISS, "System");
//                        VARIABLE_PITCH | FF_SWISS, "Arial");
                                }
                        }


            if (!hfontStatus) {
                MessageBox (GetFocus(), "Failed To Create Font", "StatusProc", MB_OK);
            }
            hdc = GetDC (hwnd);
            SelectObject (hdc, hfontStatus);
            GetTextMetrics (hdc, &tmStatusFont);
            cxStatusBorder = GetSystemMetrics (SM_CXBORDER);
            cyStatusBorder = GetSystemMetrics (SM_CYBORDER);
            cxFrame = 3*cxStatusBorder;
            cyFrame = 3*cyStatusBorder;
            dyField = tmStatusFont.tmHeight + (2*cyStatusBorder);
            dyStatus = dyField + (2*cyFrame);
            ReleaseDC (hwnd, hdc);
            return DefWindowProc (hwnd, msg, wParam, lParam);

        case WM_DESTROY:
            if (hfontStatus) {
                DeleteObject (hfontStatus);
            }
            break;

        case WM_SIZE:
        if (cntStatusField) {
                GetClientRect (hwnd, &rect);
                wAvailWidth = rect.right - rect.left - (cxStatusBorder*8);
                wNeedWidth = 0;
                cntNeedWidth = 0;
                cntFlexWidth = 0;

                /* First Pass: Dole out to fields that have a minimum need */
                for (i=0; i<cntStatusField; i++) {
                    statusField[i].iGiveWidth = 0; // Make sure all are initialized to 0
                    if (statusField[i].iMinWidth) {
                        /* (n, ?) */
                        statusField[i].iGiveWidth = statusField[i].iMinWidth;
                        wAvailWidth -= (statusField[i].iGiveWidth + cxStatusBorder*2);
                        if (GetWindowLong(statusField[i].hwnd, GWL_STYLE) & WS_GROUP) {
                            wAvailWidth -= cxStatusBorder*4;
                        }
                    } else {
                        /* They didn't specify a minimum... don't give them anything yet */
                        /* (0, ?) */
                        statusField[i].iGiveWidth = 0;
                    }

                    /* For those that have a minimum, but can grow to be as large as possible...*/
                    /* (n, 0) */
                    if ((statusField[i].iMinWidth >0) && (statusField[i].iMaxWidth ==0)) {
                        ++cntFlexWidth;
                    }

                    /* For those that have a max that is greater then their min... */
                    /* Includes (0,n) and (n,>n) */
                    if (statusField[i].iMaxWidth > statusField[i].iGiveWidth) {
                        wNeedWidth += (statusField[i].iMaxWidth - statusField[i].iGiveWidth);
                        ++cntNeedWidth;
                    }
                }

                /* Second Pass: Dole out to fields that have a stated maximum need */
                /* This will also hit those who had no minimum, but did have a maximum */
                /* It will still not give anything to those with no min, no max */
                if ((cntNeedWidth > 0) && (wAvailWidth > 0)) {
                    if (wNeedWidth > wAvailWidth) {
                        wNeedWidth = wAvailWidth;
                    }
                    wNeedWidth = wNeedWidth / cntNeedWidth;
                    for (i=0; i<cntStatusField; i++) {
                        if (statusField[i].iMaxWidth > statusField[i].iGiveWidth) {
                            statusField[i].iGiveWidth += wNeedWidth;
                            wAvailWidth -= (statusField[i].iGiveWidth + cxStatusBorder*2);
                            if (GetWindowLong(statusField[i].hwnd, GWL_STYLE) & WS_GROUP) {
                                wAvailWidth -= cxStatusBorder*4;
                            }
                        }
                    }
                }

                /* Third Pass: Dole out the remaining to fields that want all they can get */
                /* This includes those who had a minimum, but no maximum */
                if ((cntFlexWidth > 0) && (wAvailWidth > 0)) {
                    wFlexWidth = wAvailWidth / cntFlexWidth;
                    for (i=0; i<cntStatusField; i++) {
                        if (statusField[i].iMaxWidth==0) {
                            statusField[i].iGiveWidth += wFlexWidth;
                            wAvailWidth -= ((wFlexWidth - statusField[i].iMinWidth) + cxStatusBorder*2);
                            if (GetWindowLong(statusField[i].hwnd, GWL_STYLE) & WS_GROUP) {
                                wAvailWidth -= cxStatusBorder*4;
                            }
                        }
                    }
                }

                x = cxStatusBorder*4;
                y = rect.top + (2*cyStatusBorder);
                for (i=0; i<cntStatusField; i++) {
                    if (GetWindowLong (statusField[i].hwnd, GWL_STYLE) & WS_GROUP) {
                        x += (cxStatusBorder*4);
                    }
                    MoveWindow (statusField[i].hwnd, x, y, statusField[i].iGiveWidth, dyField, TRUE);
                    x += statusField[i].iGiveWidth + (cxStatusBorder*2);
                }
            }
            break;

        case WM_PAINT:
            hdc = BeginPaint (hwnd, &ps);
            GetClientRect (hwnd, &rect);

            hBrush = CreateSolidBrush(GetSysColor(COLOR_WINDOW));
            border = rect;
            border.bottom = border.top + cyStatusBorder;
            FillRect (hdc, &border, hBrush);
            DeleteObject (hBrush);

            hBrush = CreateSolidBrush(GetSysColor(COLOR_BTNSHADOW));
            border = rect;
            border.top = border.bottom - cyStatusBorder;
            FillRect (hdc, &border, hBrush);
            DeleteObject (hBrush);

            EndPaint (hwnd, &ps);

            return DefWindowProc (hwnd, msg, wParam, lParam);

        default:
            return DefWindowProc (hwnd, msg, wParam, lParam);
    }
    return 0L;
}



static LONG APIENTRY StatusFieldProc(
	HWND hwnd,
	UINT msg,
	UINT wParam,
	LONG lParam)
{
    HDC     hdc;
    PAINTSTRUCT ps;
    RECT    rect, border;
    HBRUSH  hBrush;
    WORD    edge = 1;
    HFONT   hTmp;
    char szText[80];
    int len;

    switch (msg) {
        case WM_PAINT:
            hdc = BeginPaint (hwnd, &ps);
            GetClientRect (hwnd, &rect);

            hBrush = CreateSolidBrush(GetSysColor(COLOR_BTNSHADOW));
            border = rect;
            border.bottom = border.top + cyStatusBorder;
            FillRect (hdc, &border, hBrush);
            border = rect;
            border.right = border.left + cxStatusBorder;
            FillRect (hdc, &border, hBrush);
            DeleteObject (hBrush);

            hBrush = CreateSolidBrush(GetSysColor(COLOR_WINDOW));
            border = rect;
            border.top = border.bottom - cyStatusBorder;
            FillRect (hdc, &border, hBrush);
            border = rect;
            border.left = border.right - cxStatusBorder;
            FillRect (hdc, &border, hBrush);
            DeleteObject (hBrush);

            if (len = GetWindowText(hwnd, szText, sizeof (szText))) {
                hTmp = SelectObject(hdc, hfontStatus);

                SetTextColor(hdc, GetSysColor(COLOR_BTNTEXT));
                SetBkColor(hdc, GetSysColor(COLOR_BTNFACE));

                InflateRect (&rect, -(cxStatusBorder*2), -cyStatusBorder);
                ExtTextOut(hdc, rect.left, rect.top,
                    ETO_OPAQUE | ETO_CLIPPED,
                    &rect,
                    (LPSTR)szText,
                    len, NULL);

                SelectObject (hdc, hTmp);
            }

            EndPaint (hwnd, &ps);
            break;

        case WM_SETTEXT:
            InvalidateRect (hwnd, NULL, TRUE);
            return DefWindowProc (hwnd, msg, wParam, lParam);

        default:
            return DefWindowProc (hwnd, msg, wParam, lParam);
    }
    return 0L;
}

extern void _UpdateStatusBar(
	char *arg, ...)
{
	va_list	valist;
	char buff[1024];

  	va_start(valist, arg);

  	_vsnprintf(buff,1024,arg,valist);
  	SetWindowText (hwndMenuField, buff);
	va_end(arg);
}

extern void _UpdateStatusBarTime()
{
	time_t  lTime;
	struct tm *datetime;
	char    szTime [20];

	time (&lTime);
	datetime = localtime (&lTime);
	wsprintf (szTime, "%02d:%02d:%02d %s",
		(HOUR%12?HOUR%12:12), MIN, SEC, (LPSTR)(HOUR/12?"PM":"AM"));
	SetWindowText (hwndTimeField, szTime);
}

