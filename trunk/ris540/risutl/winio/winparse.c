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
	File Name:		winparse.c
	Author:			Rick Kramer
	Description:	This program parses the windows command line into
						the argv and argc values.
	Change History:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <string.h>
#include <malloc.h>
#include "winparse.h"

int ParseCommandLine(HANDLE hInst, char *cline,char ***argv)
{
	char szModuleName[66];
	char wrk[255];
	char tokensep[]=" ";
	char *token;
	int i=0;
	int count =1;
	char **k;
	strcpy(wrk, cline);

	/* get the count */
	token = strtok(wrk,tokensep);

	while(token != NULL)
	{
		count++;
		token = strtok(NULL,tokensep);
	}

	k = (char **)malloc(count * sizeof(char *));
	for (i=0; i<count; i++)
		k[i] = (char *)malloc(80 * sizeof(char));

	/* insert program name */
	GetModuleFileName(hInst, szModuleName, sizeof(szModuleName));
	strcpy(k[0] , AnsiLower(szModuleName));

	/* insert values */
	strcpy(wrk, cline);
	token = strtok(wrk,tokensep);

	i=0;
	while(token != NULL)
	{
		i++;
		strcpy(k[i] , token);
		token = strtok(NULL,tokensep);
	}
	*argv = k;

	return(count);
}/* ParseCommandLine */

