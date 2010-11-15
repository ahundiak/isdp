/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							ucoerrbx.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
/*START_PRT_INCLUDE*/
#include <stdio.h>
/*STOP_PRT_INCLUDE*/
#include <stdarg.h>
#include "risstjmp.h"
#include "risutl.h"
#include "utl_err.h"
#include "utl_inf.h"

/*
**	DEFINES
*/
#define FILE_MODE			1
#define CHAR_MODE			2

#define WIDTH				71
#define LEADER				"*   "
#define TRAILER				"   *\n"
#define ASTERISK_LEADER		"****"
#define ASTERISK_TRAILER	"****\n"

#define CONTIGUOUS_CHAR(c)	(!RIScom_isspace(c))

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucoerrbx_c
#include "comisfn.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ucoerrbx.prt"
#include "ucoumsg.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static int warning_key[8] = 
{
	0,
	(int) RISUTL_I_RIS_WARNING_1,
	(int) RISUTL_I_RIS_WARNING_2,
	(int) RISUTL_I_RIS_WARNING_3,
	(int) RISUTL_I_RIS_WARNING_4,
	(int) RISUTL_I_RIS_WARNING_5,
	(int) RISUTL_I_RIS_WARNING_6,
	(int) RISUTL_I_RIS_WARNING_7
};

static  int	errbox_col;
static  int	errbox_mode;
static  FILE	*errbox_fp;
static  char	*errbox_ptr;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int get_break_len(
	char *ptr)
{
	int len;

	if (!*ptr) return 0;

	len = 1;
	if (CONTIGUOUS_CHAR(*ptr))
	{
		ptr++;
		while (*ptr && CONTIGUOUS_CHAR(*ptr))
		{
			len++; ptr++;
		}
	}

	return len;
}

/******************************************************************************/

extern void RISuco_errbox_char(
	char c)
{
	if (c == '\n')
	{
		RISuco_errbox_end_line();
		RISuco_errbox_begin_line();
	}
	else
	{
		if (c == '\t')
		{
			/*
			**	Convert tabs to spaces
			*/
			c = ' ';
		}

		if (errbox_mode == FILE_MODE)
		{
			PUTC(c, errbox_fp);
		}
		else if(errbox_mode == CHAR_MODE)
		{
			*errbox_ptr++ = c;
		}
		else
		{
			LONGJMP(RISUTL_E_INTERNAL);
		}
		errbox_col++;
	}
}

/******************************************************************************/

extern void RISuco_errbox_string(
	char *ptr)
{
	int len;

	while(*ptr)
	{
		len = get_break_len(ptr);
		if (errbox_col == 0 && len > WIDTH)
		{
			len = WIDTH;
		}

		if (errbox_col + len > WIDTH)
		{
			RISuco_errbox_end_line();
			RISuco_errbox_begin_line();

			/* skip any leading white space */
			for (; len > 0 && RIScom_isspace(*ptr); len--, ptr++)
				;
		}

		for (; len > 0; len--, ptr++)
		{
			RISuco_errbox_char(*ptr);
		}
	}
}

/******************************************************************************/

static void RISuco_errbox_begin_line()
{
	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, LEADER);
	}
	else if(errbox_mode == CHAR_MODE)
	{
		errbox_ptr += sprintf(errbox_ptr, LEADER);
	}
	else
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}

	errbox_col = 0;
}

/******************************************************************************/

extern void RISuco_errbox_end_line()
{
	while(errbox_col < WIDTH)
	{
		RISuco_errbox_char(' ');
	}

	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, TRAILER);
	}
	else if(errbox_mode == CHAR_MODE)
	{
		errbox_ptr += sprintf(errbox_ptr, TRAILER);
	}
	else
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}
}

/******************************************************************************/

extern void RISuco_errbox_sprintf(
	char *fmt, ... )
{
	va_list	args;
	char s[256];

	va_start(args, fmt);
	vsprintf(s, fmt, args);
	va_end(args);

	RISuco_errbox_string(s);
}

/******************************************************************************/

extern void RISuco_errbox_asterisk_line()
{
	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, ASTERISK_LEADER);
	}
	else if(errbox_mode == CHAR_MODE)
	{
		errbox_ptr += sprintf(errbox_ptr, ASTERISK_LEADER);
	}
	else
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}

	errbox_col = 0;
	while(errbox_col < WIDTH)
	{
		RISuco_errbox_char('*');
	}

	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, ASTERISK_TRAILER);
	}
	else /*CHAR_MODE*/
	{
		errbox_ptr += sprintf(errbox_ptr, ASTERISK_TRAILER);
	}
}

/******************************************************************************/

extern void RISuco_errbox_blank_line()
{
	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, LEADER);
	}
	else if(errbox_mode == CHAR_MODE)
	{
		errbox_ptr += sprintf(errbox_ptr, LEADER);
	}
	else
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}

	errbox_col = 0;
	while(errbox_col < WIDTH)
	{
		RISuco_errbox_char(' ');
	}

	if (errbox_mode == FILE_MODE)
	{
		FPRINTF(errbox_fp, TRAILER);
	}
	else /*CHAR_MODE*/
	{
		errbox_ptr += sprintf(errbox_ptr, TRAILER);
	}
}

/******************************************************************************/

extern void RISuco_errbox_string_line(
	char *ptr)
{
	char *lastchp;

	RISuco_errbox_begin_line();
	RISuco_errbox_string(ptr);

	lastchp = ptr + strlen(ptr) - 1;
	if (*lastchp == '\n')
	{
		errbox_col = WIDTH;
	}

	RISuco_errbox_end_line();
}

/******************************************************************************/

extern void RISuco_errbox_init(
	FILE	*fp,
	char	*ptr)
{
	if (fp && ptr)
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}

	if (fp)
	{
		errbox_mode = FILE_MODE;
		errbox_fp = fp;
		errbox_col = 0;
	}
	else if (ptr)
	{
		errbox_mode = CHAR_MODE;
		errbox_ptr = ptr;
		errbox_col = 0;
	}
	else
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}
}

/******************************************************************************/

static int error_box(
	FILE	*fp,
	char	*ptr,
	int		type,
	int		name,
	int		number,
	char	*middle_line,
	int		message,
	int		last_line)
{
	int		status;

	if ((status = SETJMP()) == 0)
	{
		RISuco_errbox_init(fp, ptr);

		RISuco_errbox_asterisk_line();
		RISuco_errbox_begin_line();

		RISuco_errbox_sprintf("%s: ", CHECK_UNINIT_MSG(type, "Error"));

		if (name)
		{
			RISuco_errbox_sprintf("%s ", RIScom_umsg(name));
		}
		else
		{
			RISuco_errbox_sprintf("%s ", RIScom_error_code(number));
		}

		if (number < 0)
		{
			RISuco_errbox_sprintf("(0x%x)", number);
		}
		else
		{
			RISuco_errbox_sprintf("(%d)", number);
		}
		RISuco_errbox_end_line();

		if (middle_line && *middle_line)
		{
			RISuco_errbox_blank_line();
			RISuco_errbox_string_line(middle_line);
		}

		RISuco_errbox_blank_line();

		if (message)
		{
			RISuco_errbox_string_line(RIScom_umsg(message));
		}
		else
		{
			RISuco_errbox_string_line(RIScom_umsg(number));
		}

		if (last_line)
		{
			RISuco_errbox_asterisk_line();
		}
	}
	RESETJMP();

	return status;
}

/******************************************************************************/

extern int RISuco_file_error_box(
	FILE	*fp,
	int		type,
	int		name,
	int		number,
	char	*middle_line,
	int		message,
	int		last_line)
{
	/*
	**	Write a standard error box to fp.  fp can be stdout or stderr.
	**	The parameters are as follows:
	**
	**	fp		-	output file pointer.
	**	type	-	ums key for error type string.
	**	name	-	ums key for error name
	*/
	return error_box(fp,NULL,type,name,number,middle_line,message,last_line);
}

/******************************************************************************/

extern char *RISuco_char_error_box(
	char	*ptr,
	int		type,
	int		name,
	int		number,
	char	*middle_line,
	int		message,
	int		last_line)
{
	if (error_box(NULL,ptr,type,name,number,middle_line,message,last_line))
	{
		return NULL;
	}
	else
	{
		*errbox_ptr = 0;
		return errbox_ptr;
	}
}

/******************************************************************************/

static int warning_box(
	FILE	*fp,
	char	*ptr,
	char	warnings[],
	int		last_line)
{
	int i;
	int status;

	if ((status = SETJMP()) == 0)
	{
		RISuco_errbox_init(fp, ptr);
		RISuco_errbox_asterisk_line();
		for (i = 1; i < 8; i++)
		{
			if (warnings[i])
			{
				RISuco_errbox_string_line(RIScom_umsg(warning_key[i]));
			}
		}

		if (last_line)
		{
			RISuco_errbox_asterisk_line();
		}
	}
	RESETJMP();

	return status;
}

/******************************************************************************/

extern int RISuco_file_warning_box(
	FILE	*fp,
	char	warnings[],
	int		last_line)
{
	/*
	**	Write a standard warning box to fp.  fp can be stdout or stderr.
	*/
	return warning_box(fp,NULL,warnings,last_line);
}

/******************************************************************************/

extern char *RISuco_char_warning_box(
	char	*ptr,
	char	warnings[],
	int		last_line)
{
	if (warning_box(NULL,ptr,warnings,last_line))
	{
		return NULL;
	}
	else
	{
		*errbox_ptr = 0;
		return errbox_ptr;
	}
}

/******************************************************************************/
