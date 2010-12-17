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
	File Name:		winparse.h
	Author:			Rick Kramer
	Description:	This is the header file for winparse.c
	Change History:
******************************************************************************/
#ifndef winparse_h_DEFINED
#define winparse_h_DEFINED

#include <windows.h>

/* prototypes */
int ParseCommandLine(HANDLE hInst, char *cline,char ***argv);

#endif /* winparse_h_DEFINED*/


