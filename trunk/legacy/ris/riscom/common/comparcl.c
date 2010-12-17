/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/* Copyright (c) 1989, 1990, 1991, 1992
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
*/

/******************************************************************************
	File Name:		comparcl.c
	Author:			Rick Kramer
	Description:	This program parses the windows command line into
						the argv and argc values.

		Add to the calling program in WinMain:
		int argc;
		TCHAR **argv;

		argc = ParseCommandLine(hInst, lpCmdLn, &argv);
								
	Change History:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
/*START_PRT_INCLUDE*/
#include <windows.h>
/*STOP_PRT_INCLUDE*/
#include <string.h>
#include <malloc.h>

extern int RIScom_parse_command_line(
	HANDLE hInst, 
	char *cline,
	char ***argv)
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
	strcpy(k[0] , CharLower(szModuleName));

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
}
