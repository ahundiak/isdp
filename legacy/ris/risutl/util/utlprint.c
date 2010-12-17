/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							utlprint.c
**	AUTHORS:						Rick Kramer
**	CREATION DATE:					7/15/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
*/

/*
**	DEFINES
*/

/*
**	INCLUDES
*/
/*START_PRT_INCLUDE*/
#include <stdio.h>
/*STOP_PRT_INCLUDE*/
#if defined(unix) || defined(DOS)
#include <stdarg.h>
#elif defined(WIN32)
#else
ERROR - NO CODE
#endif
#include "risutl.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"

#include <malloc.h>
#include <string.h>
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define utlprint_c
#include "utlprint.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static FILE *outfp = NULL;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISutl_printf(
	const char *fmt,
	...)
{
	int sts;
	va_list	args;

#if defined(WIN32S)
	if (outfp == NULL)
	{
		va_start(args, fmt);
		sts = VPRINTF(fmt, args);
	}
	else
	{
		va_start(args, fmt);
		sts = VFPRINTF(outfp, fmt, args);
	}
#else
	if (outfp == NULL)
	{
		outfp = stdout;
	}

	va_start(args, fmt);
	sts = VFPRINTF(outfp, fmt, args);
#endif
	va_end(args);

	return(sts);
}

/******************************************************************************/

extern void RISutl_init_printf(
	FILE *fp)
{
#if defined(WIN32S)
		outfp = fp;
#else
	if (fp == NULL)
	{
		outfp = stdout;
	}
	else
	{
		outfp = fp;
	}
#endif
}

/******************************************************************************/
