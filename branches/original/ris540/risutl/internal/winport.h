/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */

/* Copyright (c) 1989, 1990, 1991, 1992, 1993, 1994
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
 *
 * from "Undocumented Windows" (Addison-Wesley, 1992)
 * by Andrew Schulman, Dave Maxey and Matt Pietrek.
 * Copyright (c) Dave Maxey and Andrew Schulman 1991-1992. All rights reserved.
*/

/******************************************************************************
	File Name:		winport.h
	Author:			Rick Kramer
	Description:	This is the header file for winport.c
	Change History:
******************************************************************************/
#ifndef winport_h_DEFINED
#define winport_h_DEFINED

#define MAKEPOINTL(l,pt) (pt.x = LOWORD(l), pt.y = HIWORD(l))

#ifndef WIN32

#define SetClassCursor(hwnd,hcur) SetClassWord(hwnd,GCW_HCURSOR,hcur)

// These are already defined for Win32 in <windowsx.h>

typedef LPCSTR LPCTSTR;
typedef LPSTR LPTSTR;
#define EXPORT _export

typedef const unsigned short *LPCWSTR;
typedef unsigned short *LPWSTR;

/****** Alternate porting layer macros ****************************************/
/* from nt file WINDOWSX.H16 */
/* USER MESSAGES: */

#define GET_WPARAM(wp, lp)                      (wp)
#define GET_LPARAM(wp, lp)                      (lp)

#define GET_WM_ACTIVATE_STATE(wp, lp)               (wp)
#define GET_WM_ACTIVATE_FMINIMIZED(wp, lp)          (BOOL)HIWORD(lp)
#define GET_WM_ACTIVATE_HWND(wp, lp)                (HWND)LOWORD(lp)
#define GET_WM_ACTIVATE_MPS(s, fmin, hwnd)   \
        (WPARAM)(s), MAKELONG(hwnd, fmin)

#define GET_WM_CHARTOITEM_CHAR(wp, lp)              (CHAR)(wp)
#define GET_WM_CHARTOITEM_POS(wp, lp)               HIWORD(lp)
#define GET_WM_CHARTOITEM_HWND(wp, lp)              (HWND)LOWORD(lp)
#define GET_WM_CHARTOITEM_MPS(ch, pos, hwnd) \
        (WPARAM)(ch), MAKELONG(hwnd, pos)

#define GET_WM_COMMAND_ID(wp, lp)                   (wp)
#define GET_WM_COMMAND_HWND(wp, lp)                 (HWND)LOWORD(lp)
#define GET_WM_COMMAND_CMD(wp, lp)                  HIWORD(lp)
#define GET_WM_COMMAND_MPS(id, hwnd, cmd)    \
        (WPARAM)(id), MAKELONG(hwnd, cmd)

#define WM_CTLCOLORMSGBOX       0x0132
#define WM_CTLCOLOREDIT         0x0133
#define WM_CTLCOLORLISTBOX      0x0134
#define WM_CTLCOLORBTN          0x0135
#define WM_CTLCOLORDLG          0x0136
#define WM_CTLCOLORSCROLLBAR    0x0137
#define WM_CTLCOLORSTATIC       0x0138

#define GET_WM_CTLCOLOR_HDC(wp, lp, msg)            (HDC)(wp)
#define GET_WM_CTLCOLOR_HWND(wp, lp, msg)           (HWND)LOWORD(lp)
#define GET_WM_CTLCOLOR_TYPE(wp, lp, msg)           HIWORD(lp)
#define GET_WM_CTLCOLOR_MPS(hdc, hwnd, type) \
        (WPARAM)(hdc), MAKELONG(hwnd, type)


#define GET_WM_MENUSELECT_CMD(wp, lp)               (wp)
#define GET_WM_MENUSELECT_FLAGS(wp, lp)             LOWORD(lp)
#define GET_WM_MENUSELECT_HMENU(wp, lp)             (HMENU)HIWORD(lp)
#define GET_WM_MENUSELECT_MPS(cmd, f, hmenu)  \
        (WPARAM)(cmd), MAKELONG(f, hmenu)

// Note: the following are for interpreting MDIclient to MDI child messages.
#define GET_WM_MDIACTIVATE_FACTIVATE(hwnd, wp, lp)  (BOOL)(wp)
#define GET_WM_MDIACTIVATE_HWNDDEACT(wp, lp)        (HWND)HIWORD(lp)
#define GET_WM_MDIACTIVATE_HWNDACTIVATE(wp, lp)     (HWND)LOWORD(lp)
// Note: the following is for sending to the MDI client window.
#define GET_WM_MDIACTIVATE_MPS(f, hwndD, hwndA)\
        (WPARAM)(hwndA), 0

#define GET_WM_MDISETMENU_MPS(hmenuF, hmenuW) 0, MAKELONG(hmenuF, hmenuW)

#define GET_WM_MENUCHAR_CHAR(wp, lp)                (CHAR)(wp)
#define GET_WM_MENUCHAR_HMENU(wp, lp)               (HMENU)LOWORD(lp)
#define GET_WM_MENUCHAR_FMENU(wp, lp)               (BOOL)HIWORD(lp)
#define GET_WM_MENUCHAR_MPS(ch, hmenu, f)    \
        (WPARAM)(ch), MAKELONG(hmenu, f)

#define GET_WM_PARENTNOTIFY_MSG(wp, lp)             (wp)
#define GET_WM_PARENTNOTIFY_ID(wp, lp)              HIWORD(lp)
#define GET_WM_PARENTNOTIFY_HWNDCHILD(wp, lp)       (HWND)LOWORD(lp)
#define GET_WM_PARENTNOTIFY_X(wp, lp)               (INT)LOWORD(lp)
#define GET_WM_PARENTNOTIFY_Y(wp, lp)               (INT)HIWORD(lp)
#define GET_WM_PARENTNOTIFY_MPS(msg, id, hwnd) \
        (WPARAM)(msg), MAKELONG(hwnd, id)
#define GET_WM_PARENTNOTIFY2_MPS(msg, x, y) \
        (WPARAM)(msg), MAKELONG(x, y)

#define GET_WM_VKEYTOITEM_CODE(wp, lp)              (wp)
#define GET_WM_VKEYTOITEM_ITEM(wp, lp)              (INT)HIWORD(lp)
#define GET_WM_VKEYTOITEM_HWND(wp, lp)              (HWND)LOWORD(lp)
#define GET_WM_VKEYTOITEM_MPS(code, item, hwnd) \
        (WPARAM)(code), MAKELONG(hwnd, item)

#define GET_EM_SETSEL_START(wp, lp)                 LOWORD(lp)
#define GET_EM_SETSEL_END(wp, lp)                   HIWORD(lp)
#define GET_EM_SETSEL_MPS(iStart, iEnd) \
        0, MAKELONG(iStart, iEnd)

#define GET_EM_LINESCROLL_MPS(vert, horz)     \
        0, MAKELONG(vert, horz)

#define GET_WM_CHANGECBCHAIN_HWNDNEXT(wp, lp)       (HWND)LOWORD(lp)

#define GET_WM_HSCROLL_CODE(wp, lp)                 (wp)
#define GET_WM_HSCROLL_POS(wp, lp)                  LOWORD(lp)
#define GET_WM_HSCROLL_HWND(wp, lp)                 (HWND)HIWORD(lp)
#define GET_WM_HSCROLL_MPS(code, pos, hwnd)    \
        (WPARAM)(code), MAKELONG(pos, hwnd)

#define GET_WM_VSCROLL_CODE(wp, lp)                 (wp)
#define GET_WM_VSCROLL_POS(wp, lp)                  LOWORD(lp)
#define GET_WM_VSCROLL_HWND(wp, lp)                 (HWND)HIWORD(lp)
#define GET_WM_VSCROLL_MPS(code, pos, hwnd)    \
        (WPARAM)(code), MAKELONG(pos, hwnd)

#else
// from here on down is for Win32 ONLY!
#undef NULL
#define NULL (0)

#define GetInstanceData  /* */

#define SetClassCursor(hwnd,hcur) SetClassLong(hwnd,GCL_HCURSOR,(LONG)hcur)

#define TF_FORCEDRIVE	    (BYTE)0x80

#ifndef _FIND_T_DEFINED
#pragma pack(2)

struct _find_t {
	WIN32_FIND_DATA wfd;
	HANDLE hFind;
	char reserved[21];
	char attrib;
	unsigned wr_time;
	unsigned wr_date;
	long size;
	char name[14];
	};

#define find_t _find_t

#pragma pack()
#define _FIND_T_DEFINED
#endif

unsigned __cdecl _dos_findfirst(const char *, unsigned, struct _find_t *);
unsigned __cdecl _dos_findnext(struct _find_t *);

#define _export
#define EXPORT

#endif
#endif



