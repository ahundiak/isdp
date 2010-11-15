/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							risutl.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					4/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#ifndef RISUTL_H
#define RISUTL_H
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/
#if defined(unix) || defined(DOS)
#define PUTC		putc
#define PUTCHAR		putchar
#define FPUTC		fputc
#define PUTS		puts
#define FPUTS		fputs
#define PRINTF		printf
#define FPRINTF		fprintf
#define VPRINTF		vprintf
#define VFPRINTF	vfprintf
#elif defined(WIN32)
#include "ucoio.prt"
#define PUTC		RISuco_putc
#define PUTCHAR		RISuco_putchar
#define FPUTC		RISuco_fputc
#define PUTS		RISuco_puts
#define FPUTS		RISuco_fputs
#define PRINTF		RISuco_printf
#define FPRINTF		RISuco_fprintf
#define VPRINTF		RISuco_vprintf
#define VFPRINTF	RISuco_vfprintf
#else
ERROR -- NO CODE
#endif

#ifndef STRING
#define STRING(s)				((s)?(s):"NULL")
#endif
#define MSG(x)					(const char *)RIScom_umsg(x)
#define CHECK_UNINIT_MSG(x,s)	RISuco_check_uninit_msg(x,s)

#define INIT_RIS_UMS_FILE		0x0001
#define INIT_UTL_UMS_FILE		0x0002
#define INIT_NET_UMS_FILE		0x0004

/*
**	TYPES
*/
typedef struct debug_info_s
{
	char	*name;
	int		len;
	int		*flag;
} debug_info_s;

/*
**	VARIABLES
*/
#endif
