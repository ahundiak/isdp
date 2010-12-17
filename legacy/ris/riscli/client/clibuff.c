/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clibuff.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdarg.h>
#include "client.h"

/*
**	DEFINES
*/
#define WRITE			0
#define SKIP			1

#define TEMP_BUF_SIZE	1024

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clibuff_c
#include "clibuff.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static int	mode;
static int	max_data_len;
static int	last_buffer_len;
static char	*last_var;		/* last variable successfully added to buffer */
static char temp_buf[TEMP_BUF_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_init_string_to_buf(
	int	continue_flag)
{
	CLI_DBG(("RIScli_init_string_to_buf(continue_flag:%d)\n",
		continue_flag));

	RIS_app_write->buf.string.len = 1;
	RIS_app_write->buf.string.data[0] = '\0';
	RIS_app_write->buf.string.more_to_follow = 0;

	if (continue_flag)
	{
		mode = SKIP;
	}
	else
	{
		mode = WRITE;
		last_var = (char *)0;
		last_buffer_len = 0;
		max_data_len = RIS_app_write_size -
			(int)&(((ris_cliapp_buf *)0)->buf.string.data) - 1;
		CLI_DBG(("RIScli_init_string_to_buf:max_data_len:%d\n",
			max_data_len));
	}

	CLI_DBG(("RIScli_init_string_to_buf:complete\n"));
}

/******************************************************************************/

extern int RIScli_string_to_buf(
	const char	*fmt,
	...)
{
	int		len = 0;
	va_list args;

	CLI_DBG(("RIScli_string_to_buf(fmt:<%s>)\n", fmt));

	if (mode != SKIP)
	{
		va_start(args,fmt);
		len = vsprintf(temp_buf, fmt, args) + 1;
		CLI_DBG(("RIScli_string_to_buf:len:%d\n", len));
		va_end(args);

		if (len >= TEMP_BUF_SIZE)
		{
			CLI_DBG(("RIScl_string_to_buf: ERROR: vsprintf overwrote temp_buf\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}

		if (len + RIS_app_write->buf.string.len - 1 > max_data_len)
		{
			if (last_buffer_len == 0)
			{
				CLI_DBG(("RIScli_string_to_buf: last_buffer_len == 0 and "
					"BUFFER_FULL\n"));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			RIS_app_write->buf.string.data[last_buffer_len - 1] = '\0';
			RIS_app_write->buf.string.len = last_buffer_len;
			RIS_app_write->buf.string.more_to_follow = 1;
			CLI_DBG(("RIScli_string_to_buf: buffer full: len:%d buffer:<%s>\n",
				RIS_app_write->buf.string.len, RIS_app_write->buf.string.data));
			LONGJMP(RIS_E_BUFFER_FULL);
		}

		/* Back up over the last null terminator */
		RIS_app_write->buf.string.len--;

		/* Copy the string (including the null terminator) into the buffer */
		memcpy(&RIS_app_write->buf.string.data[RIS_app_write->buf.string.len],
			temp_buf, len);

		/* adjust the total length (include the null terminator) */
		RIS_app_write->buf.string.len += len;

		CLI_DBG(("RIScli_string_to_buf:%d bytes added to buffer:complete\n",
			len));
	}
	CLI_DBG(("RIScli_string_to_buf: Returning len: %d\n", len));
	return len;
}

/******************************************************************************/

extern void RIScli_ckpt_string_to_buf(
	char *cp)
{
	CLI_DBG(("RIScli_ckpt_string_to_buf(cp:0x%x)\n", cp));

	if (mode == SKIP)
	{
		if (cp == last_var)
		{
			CLI_DBG(("RIScli_ckpt_string_to_buf:found last_var\n"));
			RIScli_init_string_to_buf(0);
		}
	}
	else	/* mode == WRITE */
	{
		last_var = cp;
		last_buffer_len = RIS_app_write->buf.string.len;
	}

	CLI_DBG(("RIScli_ckpt_string_to_buf:complete\n"));
}

/******************************************************************************/
