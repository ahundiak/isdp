/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				clnsr.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Clean Server utility

Revision History:

********************************************************************/

typedef struct _clnsr_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   int argc;
   char **argv;
   HWND hIntro;
}  clnsr_globals;
clnsr_globals clnsr;



