/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				dlgcat.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Dynamic Dialog Box Category Management

Revision History:

********************************************************************/
#ifndef _DLGCAT_H_
#define _DLGCAT_H_

//debug
#ifdef DEBUG

	#include <assert.h>

	#define ASSERT(f)		assert(f)
        #define CHECK_PARAMETER(f, r)	ASSERT(f)	

#else

	#ifndef NULL
        	#include <stddef.h>
        #endif

	#define ASSERT(f)		((void) 0)
	#define CHECK_PARAMETER(f, r)	if (!(f)) return (r);

#endif


#include "dlgres.h"

	// ShowDlgCategory constants

#define SDC_SHOW	(TRUE)
#define SDC_HIDE	(FALSE)

	// Dialog Box Section (dlgcat)

typedef struct tagDLGCATEGORY
{
	HINSTANCE		hinst;
	LPCTSTR			lpcszTemplateName;
	LPVOID			lpvData;

	// --- the following are used internally

	HGLOBAL			hglbTemplate;
        int			nItemCount;	
	LPDLGITEMTEMPLATE	lpditList;
	HLOCAL			hlocWndList;
}
DLGCATEGORY;

TYPEDEF_POINTERS(DLGCATEGORY, DLGCATEGORY)

#define GetDlgCategoryData(lpdlgcat)	((dlgcat)->lpvData)

#endif	// _DLGCAT_H_
