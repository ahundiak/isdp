/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcocred.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Credits Functions

Revision History:

********************************************************************/
// Used from a article in WindowsDos Magazine 10/93 by Paul Bonneau

#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include <stdio.h>
#include <mmsystem.h>
#include "gco.h"

#define gcocred_c
#include "gcocred.prt"
#include "gcodbg.prt"

#define DefCreditColor	RGB(0xff, 0x00, 0x00)
#define dtimScroll		33     /* ms per scan line. */
#define PalSize			48     /* size of palette. */



extern void _RollCredits(
	HWND hWnd,
	LPSTR TheCredits)
{
HDC	hdc, hdcMem;
HBITMAP	hbmp, hbmpSav;
HPALETTE	hpal;
RECT	rectClient, rectMem;
int	dx, dy, dyScroll;
int	x, y, yBottom;
DWORD	tim;
LOGPALETTE	*LogPal;

_DEBUG(PROG,2,"starting _RollCredits");


/* Initialize some vital variables. */
	hdc = hdcMem = NULL;
	hbmp = hbmpSav = NULL;
	hpal = NULL;

	/* Get the DC to the window to contain credits. */
	if((hdc = GetDC(hWnd)) == NULL)
	{
		return;
	}

	/* Create a compatible memory DC to the DC of the credits window. */
	if((hdcMem = CreateCompatibleDC(hdc)) == NULL)
	{
		goto DTRC_Cleanup;
	}

	/* Make a bitmap big enough for the credits. */
	GetClientRect(hWnd, &rectClient);
//	rectMem = rectClient;
	GetClientRect(hWnd, &rectMem);

_DEBUG(PROG,2,"TheCredits =[%s]",TheCredits);
	if(DrawText(hdc, TheCredits, -1, &rectMem,
		DT_CALCRECT | DT_CENTER | DT_NOPREFIX |
			DT_WORDBREAK | DT_EXPANDTABS) == 0)
	{
		goto DTRC_Cleanup;
	}

    /* Create a monochrome bitmap. */
    dx = rectMem.right - rectMem.left;
    dy = rectMem.bottom - rectMem.top;
    if((hbmp = CreateCompatibleBitmap(hdcMem, dx, dy)) == NULL)
    {
        goto DTRC_Cleanup;
    }
    hbmpSav = SelectObject(hdcMem, hbmp);
    PatBlt(hdcMem, 0, 0, dx, dy, WHITENESS);
    DrawText(hdcMem, TheCredits, -1, &rectMem,
    	DT_CENTER | DT_EXPANDTABS | DT_NOPREFIX | DT_WORDBREAK);

	if(GetDeviceCaps(hdc, RASTERCAPS) & RC_PALETTE)
	{
		LogPal = (LOGPALETTE *)LocalAlloc(LPTR,
			sizeof(LOGPALETTE) + PalSize * sizeof(PALETTEENTRY));
		InitLogPalette(LogPal);
		if((hpal = CreatePalette(LogPal)) != NULL)
		{
			SelectPalette(hdc, hpal, FALSE);
			RealizePalette(hdc);
		}
	}

	if(hpal == NULL)
	{
		SetTextColor(hdc, DefCreditColor);
	}

	SetBkColor(hdc, 0x00000000);
	PatBlt(hdc, 0, 0, rectClient.right,
	rectClient.bottom, BLACKNESS);

	x = (rectClient.right - dx) / 2;
	dyScroll = dy + rectClient.bottom;
	yBottom = rectClient.bottom - 1;
	tim = timeGetTime();
	for(y = 0 ; y < dyScroll ; y++)
	{
	DWORD	timT;
	MSG	msg;

		/* If the user pressed a key or the left mouse button, break out of loop. */
		if(PeekMessage(&msg, hWnd, WM_KEYDOWN, WM_KEYDOWN, PM_REMOVE)
			|| PeekMessage(&msg, hWnd, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_REMOVE))
		{
			break;
		}

		/* If the color palette exists, rotate it. */
		if(hpal != NULL)
		{
			SetTextColor(hdc, PALETTEINDEX(y % PalSize));
			RotatePalette(hpal, LogPal);
		}

		/* Scroll the DC up. */
		ScrollDC(hdc, 0, -1, &rectClient, NULL, NULL, NULL);

		/* BitBlt a 1-pixel line in at the bottom. */
		if(y < dy)
		{
			BitBlt(hdc, x, yBottom, rectClient.right, 1, hdcMem, 0, y, SRCCOPY);
		}

		/* Sit and spin your wheels for a few milliseconds. */
		while((timT = timeGetTime()) - tim < dtimScroll);

		/* Get ready to go again. */
		tim = timT;
		
	} /* for */

	/* Refresh the window. */		
	InvalidateRect(hWnd, NULL, TRUE);

	
DTRC_Cleanup:	/* Labels are a no-no in C! */
	if(hbmpSav != NULL)
	{
		SelectObject(hdcMem, hbmpSav);
	}
	if(hbmp != NULL)
	{
		DeleteObject(hbmp);
	}
	if(hdcMem != NULL)
	{
		DeleteDC(hdcMem);
	}
	if(hdc != NULL)
	{
		ReleaseDC(hWnd, hdc);
	}
	if(hpal != NULL)
	{
		DeleteObject(hpal);
	}
	if(LogPal != NULL)
	{
		LocalFree((HLOCAL)LogPal);
	}
    
_DEBUG(PROG,2,"end RollCredits");
} /* DataTrackRollCredits */


static void RotatePalette(
	HPALETTE hpal,
	LOGPALETTE *logpal)
{
PALETTEENTRY	ple;

	ple = logpal->palPalEntry[0];
	
	memmove(logpal->palPalEntry, logpal->palPalEntry + 1,
		(PalSize - 1) * sizeof(logpal->palPalEntry[0]));
	
	logpal->palPalEntry[PalSize - 1] = ple;
	
	AnimatePalette(hpal, 0, PalSize, logpal->palPalEntry);
	
} /* RotatePalette */


static void InitLogPalette(
	LOGPALETTE *logpal)
{
int	z, w;
BYTE	b;

	w = 0x7f - ((PalSize / 4) * 0x20);

	logpal->palVersion = 0x0300;
	
	logpal->palNumEntries = PalSize;

	for(z = 0 ; z < PalSize ; z++)
	{
		w += z < PalSize / 2 ? 0x20 : -0x20;
		b = w < 0 ? 0 : (w > 0xff ? 0xff : (BYTE)w);
		logpal->palPalEntry[z].peRed = b;
		logpal->palPalEntry[(z + PalSize / 3) % PalSize].peGreen = b;
		logpal->palPalEntry[(z + 2 * PalSize / 3) % PalSize].peBlue = b;
		logpal->palPalEntry[z].peFlags = PC_RESERVED;
	} /* for */

} /* InitLogPalette */

