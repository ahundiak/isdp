/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
 * Copyright (c) 1989, 1990, 1991, 1992
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
*/

/******************************************************************************
	File Name:		ep.c
	Author:			Rick Kramer
	Description:	To provide the required (simple) entry point for
						i9ris.dll.
	01/30/05	rlk	Limited to a single instance for Win32s
******************************************************************************/
#include <windows.h>
#include <stdlib.h>

#include "appinit.prt"
#include "comdebug.prt"
#include "complat.prt"
#include "ris.h"

BOOL WINAPI _CRT_INIT (HINSTANCE hDLL, DWORD dwReason, LPVOID lpReserved);
/******************************************************************************
	Function:			DLLEntryPoint
	Description:		i9ris.dll entry point
	Globals Referenced:
	Globals Modified:	

	INPUTS:	hDLL			- handle of DLL
				dwReason		- indicates why DLL called
				lpReserved	- reserved

	RETURNS:	TRUE (always, in this example.)

		Note that the retuRn value is used only when
		dwReason = DLL_PROCESS_ATTACH.

	Normally the function would return TRUE if DLL initialization
	succeeded, or FALSE it it failed.

   Who   When      What
   ----- --------- -----------------------------------------------------------

******************************************************************************/
BOOL WINAPI DllMain (HANDLE hDLL, DWORD dwReason, LPVOID lpReserved)
{
	static cnt=0;

	switch (dwReason)
	{
		case DLL_PROCESS_ATTACH:
			/* DLL is attaching to the address space of the current process. */
			if (!_CRT_INIT (hDLL, dwReason, lpReserved))
				return FALSE;
			if (RIScom_get_platform() == IS_WIN32S)
			{
				cnt++;
				if (cnt >1)
				{
					MessageBox(NULL,"RIS/32 is limited to a single instance",
						  "RIS/32", MB_OK | MB_ICONSTOP | MB_TASKMODAL);
					return(FALSE);
				}
			}
			break;

		case DLL_THREAD_ATTACH:
			/*A new thread is being created in the current process.*/
			break;

		case DLL_THREAD_DETACH:
			/*A thread is exiting cleanly.*/
			break;

		case DLL_PROCESS_DETACH:
			if (RIScom_get_platform() == IS_WIN32S)
				cnt--;
			/*The calling process is detaching the DLL from its address space.*/
			break;

		default:
			if (!_CRT_INIT (hDLL, dwReason, lpReserved))
				return FALSE;
			break;
	}
	return TRUE;
}
