/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucoio.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <windows.h>
/*START_PRT_INCLUDE*/
#include <stdio.h>
#include <stdarg.h>
#include "rislimit.h"
/*STOP_PRT_INCLUDE*/

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucoio_c
#include "ucoio.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void set_text_color(
	int mode)
{
#if 0
	static  char valid_wAttribute = 0;
	static  HANDLE hOut = 0;
	static  CONSOLE_SCREEN_BUFFER_INFO screen_info;

	if (hOut == 0)
	{
		hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	}

	if (hOut == INVALID_HANDLE_VALUE)
	{
		return;
	}

	if (mode)
	{
		if (GetConsoleScreenBufferInfo(hOut,&screen_info) == FALSE)
		{
			valid_wAttribute = 0;
			return;
		}
		valid_wAttribute = 1;
	
		SetConsoleTextAttribute(hOut,
			FOREGROUND_INTENSITY|FOREGROUND_GREEN|FOREGROUND_RED);
	}
	else
	{
		if (valid_wAttribute)
		{
			SetConsoleTextAttribute(hOut,screen_info.wAttributes); 
		}
	}
#endif
}

/******************************************************************************/

extern int RISuco_putc(
	int c,
	FILE *stream)
{
	int sts;

#if !defined(WIN32S)
	char buffer[2];
	if (stream == stdout)
	{
		buffer[0] = c;
		buffer[1] = 0;
		CharToOemBuff(buffer, buffer, 1);
		sts = putc(buffer[0], stream);
	}
	else
#endif
	{
		sts = putc(c, stream);
	}
	return sts;
}

/******************************************************************************/

#if !defined(WIN32S)
extern int RISuco_putchar(
	int c)
{
	int sts;
	char buffer[2];

	buffer[0] = c;
	buffer[1] = 0;
	CharToOemBuff(buffer, buffer, 1);
	sts = putchar(buffer[0]);

	return sts;
}
#endif

/******************************************************************************/

extern int RISuco_fputc(
	int c,
	FILE *stream)
{
	int sts;

#if !defined(WIN32S)
	char buffer[2];
	if (stream == stdout)
	{
		buffer[0] = c;
		buffer[1] = 0;
		CharToOemBuff(buffer, buffer, 1);
		sts = fputc(buffer[0], stream);
	}
	else
#endif
	{
		sts = fputc(c, stream);
	}
	return sts;
}

/******************************************************************************/

#if !defined(WIN32S)
extern int RISuco_puts(
	const char *string)
{
	int sts;
	int len;
	static char buffer[5000];

	len = strlen(string);
	if (len > sizeof(buffer) - 1)
	{
		len = sizeof(buffer) - 1;
	}
	CharToOemBuff(string, buffer, len);
	buffer[len] = '\0';
	sts = puts(buffer);
	return sts;
}
#endif

/******************************************************************************/

extern int RISuco_fputs(
	const char *string, 
	FILE * stream)
{
	int sts;

#if !defined(WIN32S)
	static char buffer[5000];
	int len;
	if (stream == stdout)
	{
		len = strlen(string);
		if (len > sizeof(buffer) - 1)
		{
			len = sizeof(buffer) - 1;
		}
		CharToOemBuff(string, buffer, len);
		buffer[len] = '\0';
		sts = fputs(buffer, stream);
	}
	else
#endif
	{
		sts = fputs(string, stream);
	}
	return sts;
}

/******************************************************************************/

#if !defined(WIN32S)
extern int RISuco_printf(
	const char	*fmt,
	...)
{
	int sts;
	va_list	args;
	static char buffer[5000];

	va_start(args, fmt);
	sts = _vsnprintf(buffer, sizeof(buffer), fmt, args);
	va_end(args);

	CharToOem(buffer, buffer);

	fputs(buffer, stdout);

	return sts;
}
#endif

/******************************************************************************/

extern int RISuco_fprintf(
	FILE		*fp,
	const char	*fmt,
	...)
{
	int sts;
	va_list	args;
	static  char buffer[5000];
	
#if !defined(WIN32S)
	if (fp == stdout)
	{
		va_start(args, fmt);
		sts = _vsnprintf(buffer, sizeof(buffer), fmt, args);
		va_end(args);
	
		CharToOem(buffer, buffer);
	
		fputs(buffer, stdout);
	}
	else
#endif
	{
		va_start(args, fmt);
		sts = vfprintf(fp, fmt, args);
		va_end(args);
	}

	return sts;
}

/******************************************************************************/

#if !defined(WIN32S)
extern int RISuco_vprintf(
	const char *fmt, va_list args)
{
	int sts;
	static char buffer[5000];

	sts = _vsnprintf(buffer, sizeof(buffer), fmt, args);

	CharToOem(buffer, buffer);

	fputs(buffer, stdout);

	return sts;
}
#endif

/******************************************************************************/

extern int RISuco_vfprintf(
	FILE *stream,
	const char *fmt,
	va_list args)
{
	int sts;
	static  char buffer[RIS_MAX_STMT_LEN];

#if !defined(WIN32S)
	if (stream == stdout)
	{
		sts = _vsnprintf(buffer, sizeof(buffer), fmt, args);

		CharToOem(buffer, buffer);

		fputs(buffer, stdout);
	}
	else
#endif
	{
		sts = vfprintf(stream, fmt, args);
	}
	return sts;
}

/******************************************************************************/
