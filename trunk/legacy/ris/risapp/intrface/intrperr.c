/*
**	NAME:							intrperr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**						Do not display declare schema stmt for security
**							-Hitesh 2/94
**						Fixed a bug - async failure reports a error twice
**							-Hitesh 2/94
**						The above mentioned bug fix is in function 
**						RISXint_error_msg()	and not in RISint_report_error().
**							-Radha 4/94
**						TR fix - async failure does not report right errcode
**						but sets the right errmsg.
**							-Radha 4/94
**						Added changes for MSSQL data server 
**							-Radha 10/94
**		
**      Ashley 7/12/96 - fix for 439500871	
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include <stdarg.h>
#include "intrface.h"
#include "risasync.h"
#include "ris_inf.h"

/*
**	DEFINES
*/
#define WIDTH				71
#define LEADER				"*   "
#define TRAILER				"   *\n"
#define ASTERISK_LEADER		"****"
#define ASTERISK_TRAILER	"****\n"

#define RETURN(pp) \
{ \
	*RIS_error_ptr = '\0'; \
	if (pp) \
	{ \
		*pp = RIS_error_buf; \
	} \
	RISrap_return(); \
	RIS_RETURN(); \
}
#define CONTIGUOUS_CHAR(c)	\
	(!RIScom_isspace(c))/**itbokic 3/30 */

/*
**	FUNCTION PROTOTYPES
*/
#define intrperr_c
#include "comdebug.prt"
#include "comisfn.prt"
#if defined(WIN32)
#include "comuni.prt"
#endif
#if defined (unix) && !defined(sco)
#include "comsyser.prt"
#endif
#include "comsusti.prt"
#include "comumsg.prt"
#include "interror.prt"
#include "intrperr.prt"
#include "intrap.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static	 int		RIS_error_col;
static	 char	*RIS_error_ptr;
static	 char	RIS_error_buf[2 * RIS_MAX_STMT_LEN + 500];

/*
**	FUNCTIONS
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

static void add_string(
	char *ptr)
{
	int len;

	INT_DBG(("add_string(ptr:<%s>)\n",ptr));

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
			for (; len > 0 && RIScom_isspace(*ptr); len--, ptr++)/**itbokic 3/30 */
				;
		}

		for (; len > 0; len--, ptr++)
			add_char(*ptr);
	}
}

/******************************************************************************/

static void add_sprintf(
	char *fmt, ... )
{
	va_list	args;
	char s[256];

	va_start(args, fmt);
	vsprintf(s, fmt, args);
	va_end(args);

	add_string(s);
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

static void add_blank_line()
{
	RIS_error_ptr += sprintf(RIS_error_ptr, LEADER);
	RIS_error_col = 0;
	while(RIS_error_col < WIDTH)
		add_char(' ');
	RIS_error_ptr += sprintf(RIS_error_ptr, TRAILER);
}

/******************************************************************************/

static void add_string_line(
	char *ptr)
{
	char *lastchp;

	INT_DBG(("add_string_line(ptr:<%s>)\n", ptr));
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

static void add_query_line(
	char *ptr,
	int pos)
{
	int len;
	int pos_col = -1;
	char	*start;
#if defined(WIN32)
	int lcv, multi_char;
#endif

	INT_DBG(("add_query_line(ptr:<%s> pos:%d)\n", ptr, pos));
	start = ptr;

#if defined(WIN32)
/* Ashley fix for 439500871 */
/* adjust position for each multibyte character in the string */
/* pos is given in the number of character and not the number of bytes */
for (lcv=0,multi_char=0;lcv <= pos+multi_char-1;lcv++,start++)
{
  if (RIScom_isleadbyte(*start))
	multi_char++;
}
	INT_DBG(("add_query_line(adjusted pos: <%d>)\n", pos));
	start = ptr; /* put pointer back to beginning */

	pos += multi_char-1;
#else
	pos--;
#endif

	begin_line();
	while(*ptr)
	{
		len = get_next_break_len(ptr);
		if (len > WIDTH)
		{
			len = WIDTH;
		}

		if (RIS_error_col + len > WIDTH)
		{

			end_line();

			if (pos_col >= 0)
			{
				pos_col--;
				begin_line();
				for (; pos_col >= 0; pos_col--)
					add_char(' ');
				add_char('^');
				end_line();
			}

			begin_line();

			/* skip any leading white space */
			for (; len > 0 && RIScom_isspace(*ptr); len--, ptr++)/**itbokic 3/30 */
			{
				if (ptr - start == pos)
				{
					pos_col = RIS_error_col;
				}
			}
		}
		for (; len > 0; len--, ptr++)
		{
			if (ptr - start == pos)
			{
				pos_col = RIS_error_col;
			}
			add_char(*ptr);
		}
	}

	if (ptr - start == pos)
	{
		pos_col = RIS_error_col;
	}

	end_line();

	if (pos_col >= 0)
	{
		pos_col--;
		begin_line();
		for (; pos_col >= 0; pos_col--)
			add_char(' ');
		add_char('^');
		end_line();
	}
}

/******************************************************************************/

/*
**	Create an error string from the database error(s),
**	suitable for printing by RISint_report_error.
*/

static void db_err_str()
{
	char *cp;

	if (!dbca->sqlcode)
		return;

	if (strncmp(dbca->sqlcaid+5, "NET", 3) == 0)/**itbokic 3/30 */
	{
		/*
		**	add the network error string
		*/
		begin_line();
		add_string(RIScom_umsg(RIS_I_NETWORK_ERROR));
		add_sprintf(": %s (0x%x)", NET_error_code(dbca->sqlcode),dbca->sqlcode);
		end_line();

		if (dbca->sqlstmt && *dbca->sqlstmt)
		{
			add_blank_line();
			add_string_line(dbca->sqlstmt);
		}

		if (dbca->sqlerrm.sqlerrml)
		{
			add_blank_line();
			add_string_line(dbca->sqlerrm.sqlerrmc);
		}
	}
	else if (strncmp(dbca->sqlcaid+5, "FRM", 3) == 0)/**itbokic 3/30 */
	{
		/*
		**	add the forms error string
		**
		**	Note:	For a forms error sqlstmt contains the name of the 
		**			FI error and the error number.
		*/

		begin_line();
		add_string(RIScom_umsg(RIS_I_FORMS_INTERFACE_ERROR));
		add_string(dbca->sqlstmt);
		end_line();

		if (dbca->sqlerrm.sqlerrml)
		{
			add_blank_line();
			add_string_line(dbca->sqlerrm.sqlerrmc);
		}
	}
	else if (strncmp(dbca->sqlcaid+5, "OSD", 3) == 0)/**itbokic 3/30 */
	{
		/*
		**	add the operating system error message
		*/

#if defined(WIN32) || defined(DOS) || defined(sco)
		begin_line();
		add_sprintf("%s: %d", RIScom_umsg(RIS_I_OPERATING_SYSTEM_ERROR),
		dbca->sqlcode);
#elif defined(unix)
		begin_line();
		add_sprintf("%s: %s (%d)", RIScom_umsg(RIS_I_OPERATING_SYSTEM_ERROR),
			RIScom_get_errno_name(dbca->sqlcode), dbca->sqlcode);
#endif
		end_line();

		if (dbca->sqlerrm.sqlerrml)
		{
			add_blank_line();
			add_string_line(dbca->sqlerrm.sqlerrmc);
		}
	}
	else
	{
		/*
		**	add the database system error message
		*/
		begin_line();
		if (strncmp(dbca->sqlcaid+5, "IFX", 3) == 0)/**itbokic 3/30 */
            add_string(RIScom_umsg(RIS_I_INFORMIX));
		else if (strncmp(dbca->sqlcaid+5, "ORA", 3) == 0)/**itbokic 3/30 */
            add_string(RIScom_umsg(RIS_I_ORACLE));
		else if (strncmp(dbca->sqlcaid+5, "IGS", 3) == 0)/**itbokic 3/30 */
            add_string(RIScom_umsg(RIS_I_INGRES));
		else if (strncmp(dbca->sqlcaid+5, "SQ4", 3) == 0)/**itbokic 3/30 */
			add_string(RIScom_umsg(RIS_I_SQLDS));
          else if (strncmp(dbca->sqlcaid+5, "DB2", 3) == 0)/**itbokic 3/30 */
			add_string(RIScom_umsg(RIS_I_DB2));
          else if (strncmp(dbca->sqlcaid+5, "SYB", 3) == 0)/**itbokic 3/30 */
			  add_string(RIScom_umsg(RIS_I_SYBASE));
          else if (strncmp(dbca->sqlcaid+5, "RDB", 3) == 0)/**itbokic 3/30 */
			add_string(RIScom_umsg(RIS_I_RDB));
          else if (strncmp(dbca->sqlcaid+5, "ABS", 3) == 0)/**itbokic 3/30 */
			add_string(RIScom_umsg(RIS_I_ADABAS));
          else if (strncmp(dbca->sqlcaid+5, "400", 3) == 0)/**itbokic 3/30 */
			add_string(RIScom_umsg(RIS_I_OS400));
          else if (strncmp(dbca->sqlcaid+5, "MSF", 3) == 0)/**itbokic 3/30 */
              add_string(RIScom_umsg(RIS_I_MSSQL));

		add_sprintf(" %s %d", RIScom_umsg(RIS_I_ERROR), dbca->sqlcode);
		end_line();

		/*
		** This is ok for oracle because add_query_line() does not put
		** a hat in unless the offset (sqlerrd[4]) is non-zero.
		*/
		if (dbca->sqlstmt && *dbca->sqlstmt)
		{
			add_blank_line();
			add_query_line(dbca->sqlstmt, (int)dbca->sqlerrd[4]);
		}
	
		if (dbca->sqlerrm.sqlerrml)
		{
			add_blank_line();
			add_string_line(dbca->sqlerrm.sqlerrmc);

			if (dbca->sqlerrd[1] &&
				dbca->sqlcaid[5] == 'I' &&
				dbca->sqlcaid[6] == 'F' &&
				dbca->sqlcaid[7] == 'X')
			{
				add_blank_line();
				cp = dbca->sqlerrm.sqlerrmc + strlen(dbca->sqlerrm.sqlerrmc)+1;
				add_string_line(cp);
			}
		}
	
	}

	add_asterisk_line();
}

/******************************************************************************/

extern void RISAPI RISXint_report_error(
	int		*async_id,
	char	**ptrp)
{
	risasync	*async;
	int			security_flag = 0;

	INT_DBG(("RISint_report_error(async_id:0x%x ptr:0x%x)\n",
		async_id, ptrp));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "REPORT ERROR\n");
		fprintf(RIS_RAP, "async_id:0x%x\n", async_id);
		if (async_id)
		{
			fprintf(RIS_RAP, "*async_id:%d\n", *async_id);
		}
		fprintf(RIS_RAP, "ptrp:0x%x\n", ptrp);
	RISrap_enter_END();

	if (async_id && *async_id != -1)
	{
		if (*async_id < 0 || *async_id >= RIS_MAX_TRANSACTIONS ||
			!RIS_asyncs[*async_id])
		{
			RIS_CLEAR_ERROR();
			SQLCODE = RIS_ERRCODE = RIS_E_INV_ASYNC_ID;
			RIS_ERRMSGL = (short)RISXint_error_msg(RIS_ERRCODE, RIS_ERRMSGC,
			 RIS_error_name);
		}
		else
		{
			async = RIS_asyncs[*async_id];
			memcpy(risca, &async->risca, sizeof(struct rissqlca));
			memcpy(dbca, &async->dbca, sizeof(struct rissqlca));

			/* The following lines are needed to set the right errcode */ 
			/*            -Radha 4/94 */

		 	SQLCODE = RIS_ERRCODE;
		 	RIS_ERRMSGL = (short)RISXint_error_msg(RIS_ERRCODE, RIS_ERRMSGC, 
							 RIS_error_name);
	
		}
	}
	
	INT_DBG(("RISint_report_error:RIS_ERRCODE:%d\n", RIS_ERRCODE));

	RIS_error_col = 0;
	RIS_error_ptr = RIS_error_buf;

	/* handle success, severe, and end of data specially */

	switch(RIS_ERRCODE)
	{
		case RIS_SUCCESS:
			add_asterisk_line();
			add_string_line(RIScom_umsg(RIS_I_NO_ERRORS_ENCOUNTERED));
			add_asterisk_line();
			INT_DBG(("RISint_report_error: complete\n"));
			RETURN(ptrp);

		case END_OF_DATA:
			add_asterisk_line();
			add_string_line(RIScom_umsg(RIS_I_RIS_INFORMATION_END_OF_DATA));
			add_asterisk_line();
			INT_DBG(("RISint_report_error: complete\n"));
			RETURN(ptrp);

		case STATEMENT_NOT_COMPLETE:
			add_asterisk_line();
			add_string_line(RIScom_umsg(RIS_I_INF_ASYNC_STMT_NOT_COMPLETE));
			add_asterisk_line();
			INT_DBG(("RISint_report_error: complete\n"));
			RETURN(ptrp);

		case STATEMENT_FAILED:

			add_asterisk_line();
			add_string_line(RIScom_umsg(RIS_I_INF_ASYNC_STMT_FAILED));
			add_asterisk_line();
			INT_DBG(("RISint_report_error: complete\n"));
			RETURN(ptrp);
	}

	add_asterisk_line();

	/*
	**	Figure out which subsystem's error it is
	*/
	begin_line();
	add_string("RIS ");

	if (RIS_ERRCODE < 0)
		add_string(RIScom_umsg(RIS_I_ERROR));
	else if (RIS_ERRCODE > 0)
		add_string(RIScom_umsg(RIS_I_INFORMATION));

/* Fix TR# 439502896 TR# 439502890 - kmreddy */
 	
 	if (async_id == 0 && (RIS_ERRCODE == RIS_E_NO_SCHEMA_NO_ACCESS || 
	 					  RIS_ERRCODE == RIS_E_NO_SCHEMA_TABLES ))
 		strcpy(RIS_error_name , RIScom_error_code(RIS_ERRCODE));

	add_sprintf(": %s (0x%x)", RIS_error_name, RIS_ERRCODE);
	end_line();

	/*
	**	Add the query if needed
	*/
	if (risca->sqlstmt && *risca->sqlstmt)
	{
		add_blank_line();
		if (!strncmp(risca->sqlstmt,"declare schema", strlen("declare schema")))/**itbokic 3/30 */
		{
			security_flag = 1;
		}
		if (!strncmp(risca->sqlstmt,"alter schema", strlen("alter schema")))/**itbokic 3/30 */
		{
			if (RIScom_substr_ic(risca->sqlstmt, "modify"))
			{
				security_flag = 1;
			}
		}

		if (security_flag)
		{
			add_query_line(RIScom_umsg(RIS_I_ENSURE_SECURITY_STMT), 0);
		}
		else
		{
			add_query_line(risca->sqlstmt, (int)RIS_ERRPOS);
		}
	}

	/*
	**	Add the error message
	*/	
	add_blank_line();
	add_string_line(RIS_ERRMSGC);

	add_asterisk_line();

	db_err_str();

	INT_DBG(("RISint_report_error: complete\n"));
	RETURN(ptrp);
}

/******************************************************************************/
