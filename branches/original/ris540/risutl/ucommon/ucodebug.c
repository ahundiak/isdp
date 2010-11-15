/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
**	NAME:							ucodebug.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					4/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risutl.h"
#include "rislimit.h"
#include "ucommon.h"
#include "ris.h"
/*
**	DEFINES
*/
#if defined(unix)
#define DEBUG_FILE			"/usr/tmp/risutl"
#define DEFAULT_OUTPUT_FILE	"/usr/tmp/risutl.out"
#endif
#if defined(WIN32) || defined(DOS)
#define DEBUG_FILE			"c:\\tmp\\risutl"
#define DEFAULT_OUTPUT_FILE	"c:\\tmp\\risutl.out"
#endif

#ifdef DEBUG
# undef DEBUG
#endif

#define OUTPUT			"OUTPUT:"
#define OUTPUT_SIZE		(sizeof(OUTPUT)-1)

#define DEBUG			"DEBUG:"
#define DEBUG_SIZE		(sizeof(DEBUG)-1)

#define SKIP_WHITE_SPACE(ptr)	while(RIScom_isspace(*(ptr))) (ptr)++;

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucodebug_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "ucodebug.prt"
#include "ucofgets.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_initialize_debug(
	debug_info_s	debug_info[],
	int				debug_count)
{
	char	*ptr;
	char	buf[RIS_MAX_PATH_SIZE];
	char	debug_output_device[RIS_MAX_PATH_SIZE];
	FILE	*fp;
	static  int	initialized = 0;

	UCO_DBG(("RISuco_initialize_debug(debug_info:0x%x debug_count:%d)\n",
		debug_info, debug_count));

	if (initialized)
	{
		UCO_DBG(("RISuco_initialize_debug:already initialized:returning\n"));
		return;
	}

	if ((fp = fopen(DEBUG_FILE, "r")) == NULL)
	{
		UCO_DBG(("RISuco_initialize_debug:fopen == NULL:returning\n"));
		return;
	}

	strcpy(debug_output_device, DEFAULT_OUTPUT_FILE);
	while(RISuco_fgets(buf, sizeof(buf), fp))
	{
		if (!strncmp(buf, OUTPUT, OUTPUT_SIZE))
		{
			ptr = buf + OUTPUT_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RIScom_get_output_device_name(ptr, debug_output_device);
		}
		else if (!strncmp(buf, DEBUG, DEBUG_SIZE))
		{
			ptr = buf + DEBUG_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RISuco_process_debug_string(ptr, debug_info, debug_count);
		}
	}
	fclose(fp);

	RIScom_set_debug_output_device(debug_output_device);

	initialized = 1;

	UCO_DBG(("RISuco_initialize_debug:returning\n"));
}

/******************************************************************************/

extern void RISuco_process_debug_string(
	char			*str,
	debug_info_s	debug_info[],
	int				debug_count)
{
	int i;
	int value = 1;
	char *d;
	char *s;

	UCO_DBG(("RISutl_process_debug_string()\n"));

	d = s = str;
	while (*s)
	{
		if (*s == '+')
		{
			value = 1;
			*d++ = *s++;
		}
		else if (*s == '-')
		{
			value = 0;
			*d++ = *s++;
		}
		else if (!strncmp(s, "off", 3))
		{
			for (i = 0; i < debug_count; i++)
			{
				*debug_info[i].flag = 0;
			}
			RISuco_debug = 0;
			*d++ = *s++; /* 'o' */
			*d++ = *s++; /* 'f' */
			*d++ = *s++; /* 'f' */
		}
		else
		{
			for (i = 0; i < debug_count; i++)
			{
				if (!strncmp(s, debug_info[i].name, debug_info[i].len))
				{
					*debug_info[i].flag = value;
					s += debug_info[i].len;
					break;
				}
			}
			if (i == debug_count)
			{
				if (!strncmp(s, "uco", 3))
				{
					RISuco_debug = value;
					s += 3;
				}
				else
				{
					*d++ = *s++;
				}
			}
		}
	}
	*d = '\0';

	if (*str)
	{
		RISint_process_debug_no_output(str);
	}

	UCO_DBG(("RISuco_process_debug:returning\n"));
}

/******************************************************************************/
/** Melania M Stewart - TR#439602060 - No RAP logging for risrecrd if debug is on **/
extern void RISuco_initialize_debug_noRAP(
	debug_info_s	debug_info[],
	int				debug_count)
{
	char	*ptr;
	char	buf[RIS_MAX_PATH_SIZE];
	char	debug_output_device[RIS_MAX_PATH_SIZE];
	FILE	*fp;
	static  int	initialized = 0;

	UCO_DBG(("RISuco_initialize_debug_noRAP(debug_info:0x%x debug_count:%d)\n",
		debug_info, debug_count));

	if (initialized)
	{
		UCO_DBG(("RISuco_initialize_debug_noRAP:already initialized:returning\n"));
		return;
	}

	if ((fp = fopen(DEBUG_FILE, "r")) == NULL)
	{
		UCO_DBG(("RISuco_initialize_debug_noRAP:fopen == NULL:returning\n"));
		return;
	}

	strcpy(debug_output_device, DEFAULT_OUTPUT_FILE);
	while(RISuco_fgets(buf, sizeof(buf), fp))
	{
		if (!strncmp(buf, OUTPUT, OUTPUT_SIZE))
		{
			ptr = buf + OUTPUT_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RIScom_get_output_device_name(ptr, debug_output_device);
		}
		else if (!strncmp(buf, DEBUG, DEBUG_SIZE))
		{
			ptr = buf + DEBUG_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RISuco_process_debug_string_noRAP(ptr, debug_info, debug_count);
		}
	}
	fclose(fp);

	RIScom_set_debug_output_device(debug_output_device);

	initialized = 1;

	UCO_DBG(("RISuco_initialize_debug_noRAP:returning\n"));
}

/******************************************************************************/

extern void RISuco_process_debug_string_noRAP(
	char			*str,
	debug_info_s	debug_info[],
	int				debug_count)
{
	int i;
	int value = 1;
	char *d;
	char *s;

	UCO_DBG(("RISutl_process_debug_string_noRAP()\n"));

	d = s = str;
	while (*s)
	{
		if (*s == '+')
		{
			value = 1;
			*d++ = *s++;
		}
		else if (*s == '-')
		{
			value = 0;
			*d++ = *s++;
		}
		else if (!strncmp(s, "off", 3))
		{
			for (i = 0; i < debug_count; i++)
			{
				*debug_info[i].flag = 0;
			}
			RISuco_debug = 0;
			*d++ = *s++; /* 'o' */
			*d++ = *s++; /* 'f' */
			*d++ = *s++; /* 'f' */
		}
		else
		{
			for (i = 0; i < debug_count; i++)
			{
				if (!strncmp(s, debug_info[i].name, debug_info[i].len))
				{
					*debug_info[i].flag = value;
					s += debug_info[i].len;
					break;
				}
			}
			if (i == debug_count)
			{
				if (!strncmp(s, "uco", 3))
				{
					RISuco_debug = value;
					s += 3;
				}
				else
				{
					*d++ = *s++;
				}
			}
		}
	}
	*d = '\0';

	if (*str)
	{
		RISint_process_debug_no_output_noRAP(str);
	}

	UCO_DBG(("RISuco_process_debug_noRAP:returning\n"));
}

/******************************************************************************/

extern void RISuco_output_debug_flags(
	int             (* output_func)(const char *, ...),
	debug_info_s	debug_info[],
	int				debug_count)
{
	int		i;
	char	need_newline = 0;

	output_func("\n");
	RIScom_output_debug_flags(output_func);
	output_func("\n");
	for (i = 0; i < debug_count; i++)
	{
		output_func("          %-6s:%-3s", debug_info[i].name,
			*debug_info[i].flag ? "ON" : "OFF");
		if (i % 3 == 2)
		{
			output_func("\n");
			need_newline = 0;
		}
		else
		{
			need_newline = 1;
		}
	}

	output_func("          %-6s:%-3s\n\n", "uco", RISuco_debug ? "ON" : "OFF");
}

/******************************************************************************/
