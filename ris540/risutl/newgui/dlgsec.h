/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				dlgsec.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Dynamic Dialog Box Section Management

Revision History:

********************************************************************/
#ifndef _DLGSEC_H_
#define _DLGSEC_H_

#include "dlgcat.h"

	// Constants

#define DLGSEC_ERR		-1

	// Section category flags

#define DSCF_DISCARDABLE	0x0001
#define DSCF_PRELOAD		0x0002

	// Dialog section notification messages

#define DSN_LOADED		0x0001
#define DSN_DISCARDING		0x0002

	// Category wrapper structure (seccat)

typedef struct tagSECTIONCATEGORY
{
	int		nID;
        UINT		uFlags;
	DLGCATEGORY	dlgcat;
}
SECTIONCATEGORY;

TYPEDEF_POINTERS(SECTIONCATEGORY, SECTIONCATEGORY)

	// Dialog section structure (dlgsec)

typedef struct tagDLGSECTION
{
	int			nID;
	HWND			hwndDlg;
	int			nFrameID;
	int			nCount;
	int			nLoaded;
	int			nMaxThreshold;
	int			nMinThreshold;
	int			nCurrentID;
	LPVOID			lpvData;
	LPSECTIONCATEGORY	lpseccatList;
}
DLGSECTION;

TYPEDEF_POINTERS(DLGSECTION, DLGSECTION)

#endif	// _DLGSEC_H_
