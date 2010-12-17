/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**      NAME:                       dlderror.c
**      AUTHORS:                    Hitesh R. Patel
**      CREATION DATE:              4/93
**      ABSTRACT:
**              
**      
**      REVISION HISTORY:
*/
 
/*
**      INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#if defined(WIN32)
#include <windows.h>
#endif
#include "dload.h"

/*
**      DEFINES
*/
#define WIDTH				71
#define LEADER				"*   "
#define TRAILER				"   *\n"
#define ASTERISK_LEADER		"****"
#define ASTERISK_TRAILER	"****\n"

#define CONTIGUOUS_CHAR(c)	\
	(!isspace(c))

#define RETURN(pp) \
{ \
	*RIS_error_ptr = '\0'; \
	if (pp) \
	{ \
		*pp = RIS_error_buf; \
	} \
	return; \
}
/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dlderror_c
#include "dlddebug.prt"
#include "dlderror.prt"
#include "sys.prt"

/*
**      VARIABLES
*/
static	int		RIS_error_col;
static	char	*RIS_error_ptr;
static	char	RIS_error_buf[2 * RIS_MAX_STMT_LEN + 500];


/*
**      FUNCTIONS
*/

/******************************************************************************/

static int get_next_break_len(
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

static void add_string(
	char *ptr)
{
	int len;

	while(*ptr)
	{
		len = get_next_break_len(ptr);
		if (RIS_error_col == 0 && len > WIDTH)
			len = WIDTH;

		if (RIS_error_col + len > WIDTH)
		{
			end_line();
			begin_line();

			/* skip any leading white space */
			for (; len > 0 && isspace(*ptr); len--, ptr++)
				;
		}

		for (; len > 0; len--, ptr++)
			add_char(*ptr);
	}
}

/******************************************************************************/

static void add_char(
	char c)
{
	if (c == '\n')
	{
		end_line();
		begin_line();
	}
	else if (c == '\t')
	{
		*RIS_error_ptr++ = ' ';
		RIS_error_col++;
	}
	else
	{
		*RIS_error_ptr++ = c;
		RIS_error_col++;
	}
}

/******************************************************************************/

static void begin_line()
{
	RIS_error_ptr += sprintf(RIS_error_ptr, LEADER);
	RIS_error_col = 0;
}

/******************************************************************************/

static void end_line()
{
	while(RIS_error_col < WIDTH)
		add_char(' ');
	RIS_error_ptr += sprintf(RIS_error_ptr, TRAILER);
}

/******************************************************************************/

static void add_asterisk_line()
{
	RIS_error_ptr += sprintf(RIS_error_ptr, ASTERISK_LEADER);
	RIS_error_col = 0;
	while(RIS_error_col < WIDTH)
		add_char('*');
	RIS_error_ptr += sprintf(RIS_error_ptr, ASTERISK_TRAILER);
}

/******************************************************************************/

static void add_string_line(
	char *ptr)
{
	char *lastchp;

	begin_line();
	add_string(ptr);

	lastchp = ptr + strlen(ptr) - 1;
	if (*lastchp == '\n')
	{
		RIS_error_ptr -= strlen(LEADER) + strlen(TRAILER);
		RIS_error_col = WIDTH;
	}

	end_line();

}

/******************************************************************************/

extern void RISdld_report_error(
	char **errorp)
{
	RIS_error_col = 0;
	RIS_error_ptr = RIS_error_buf;

	add_asterisk_line();
	add_string_line("Dynamic Loading of RIS objects/DLL has failed.");
	add_asterisk_line();
	RETURN(errorp);
}

/******************************************************************************/

extern void RISdld_error_msg_box(
	int  error_code,
	char *string)
{
	char error_string[512];

	DLD_DBG(("RISdld_error_msg_box(error_code:%d string:%s\n", 
			error_code, STRING(string)));

	switch(error_code)
	{
		case RIS_COULD_NOT_GET_REGISTRY:
			sprintf(error_string,"%s %s %s",
				"Registry Information for RIS", string, "is missing.");
		break;
		case RIS_COULD_NOT_LOAD_RIS_DLL:
			sprintf(error_string,"%s %s",
				"Unable to load RIS DLL\n", string);
		break;
		case RIS_COULD_NOT_FIND_RIS_FUNC:
			sprintf(error_string,"%s %s %s",
				"Unable to find function", string, "in RIS DLL.");
		break;
		default:
		break;
	}
	MessageBox(NULL, error_string, "RIS Error", MB_OK | MB_ICONSTOP);
	DLD_DBG(("RISdld_error_msg_box: complete.\n"));
}
