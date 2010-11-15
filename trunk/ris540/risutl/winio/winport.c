/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */

/* Copyright (c) 1989, 1990, 1991, 1992, 1993, 1994
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
 *
 * from "Undocumented Windows" (Addison-Wesley, 1992)
 * by Andrew Schulman, Dave Maxey and Matt Pietrek.
 * Copyright (c) Dave Maxey and Andrew Schulman 1991-1992. All rights reserved.
*/

/******************************************************************************
	File Name:		winport.c
	Author:			Rick Kramer
	Description:	This program contains win32 porting functions
	Change History:
******************************************************************************/
#include <windows.h>
#include "winport.h"

#include <string.h>

#ifdef WIN32
UINT GetTempFileNamePath(BYTE drv, LPSTR lpszPrefix,
   UINT uUnique,LPSTR lpszTempFile)
{
	char szPath[MAX_PATH];

	if (drv & TF_FORCEDRIVE)
	{
		szPath[0] = drv & ~TF_FORCEDRIVE;
		szPath[1] = ':';
		szPath[2] = 0;
	}
	else
		GetTempPath (MAX_PATH,szPath);
	return GetTempFileName(szPath,lpszPrefix,uUnique,lpszTempFile);
}

unsigned __cdecl _dos_findfirst(
	const char *lpszPath,
	unsigned attrib,
	struct _find_t *pStruct )
{
	BOOL rc;

	pStruct->hFind = FindFirstFile((LPSTR) lpszPath,&pStruct->wfd);
	if (rc = (pStruct->hFind != INVALID_HANDLE_VALUE))
	{
		FileTimeToDosDateTime(&pStruct->wfd.ftLastWriteTime,
			(LPWORD) &pStruct->wr_date,
			(LPWORD) &pStruct->wr_time);
			pStruct->attrib = (char) (pStruct->wfd.dwFileAttributes & 0x7f);
			pStruct->size = pStruct->wfd.nFileSizeLow;
		strcpy(pStruct->name,pStruct->wfd.cFileName);
	}
	return (rc == FALSE);
}

unsigned __cdecl _dos_findnext(struct _find_t *pStruct)
{
	BOOL rc;

	if (rc = FindNextFile(pStruct->hFind,&pStruct->wfd))
	{
		FileTimeToDosDateTime(&pStruct->wfd.ftLastWriteTime,
			(LPWORD) &pStruct->wr_date,
			(LPWORD) &pStruct->wr_time);
		pStruct->attrib = (char) (pStruct->wfd.dwFileAttributes & 0x7f);
		pStruct->size = pStruct->wfd.nFileSizeLow;
		strcpy(pStruct->name,pStruct->wfd.cFileName);
	}
	else
		FindClose(pStruct->hFind);
	return (rc == FALSE);
}

DWORD GetTextExtent(HDC hDC,LPSTR lps,int nLen)
{
	SIZE sizText;

	GetTextExtentPoint(hDC,lps,nLen,&sizText);
	return MAKELONG(LOWORD(sizText.cx),LOWORD(sizText.cy));
}

DWORD GetViewportOrg(HDC hDC)
{
	POINT pt;

	GetViewportOrgEx(hDC,&pt);
	return MAKELONG(LOWORD(pt.x),LOWORD(pt.y));
}

DWORD GetWindowOrg(HDC hDC)
{
	POINT pt;

	GetWindowOrgEx(hDC,&pt);
	return MAKELONG(LOWORD(pt.x),LOWORD(pt.y));
}

#else
// The following code is for Windows 3.1 portability functions that should be
// used in place of their non-portable counterparts.
UINT GetTempFileNamePath(BYTE drv, LPSTR lpszPrefix,
   UINT uUnique,LPSTR lpszTempFile)
{
	BYTE cDrive;

	cDrive = GetTempDrive (0);
	return GetTempFileName (cDrive, lpszPrefix, uUnique, lpszTempFile);
}
#endif

