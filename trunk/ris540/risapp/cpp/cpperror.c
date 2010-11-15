/*
**	NAME:							cpperror.c
**	AUTHORS:						David Michal
**	CREATION DATE:					7/88
**	ABSTRACT:
**		
**	This file contains routines for printing error messages.
**	
**	REVISION HISTORY:
*/

/*
**	DEFINES
*/
#define LINE_LEN	80

 
/*
**	INCLUDES
*/
#include <string.h>
#include <stdio.h>
#include "cpp.h"
#include "commacro.h"
#include "ris_err.h"
#include "ris_inf.h"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cpperror_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "comumsg.prt"
#include "cpperror.prt"
#include "cppmisc.prt"
#include "comuni.prt"
#include "interror.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_err_return(
    int status,
    char * query,
    int pos,
    char * file,
    int line)
{
#if defined(WIN32)
	char buffer[512];
#endif

CPP_DBG(("RIScpp_err_return: status=%d query=<%s> pos=%d file=<%s> line=%d\n",
status, STRING(query), pos, STRING(file), line));

	RIScom_fputc('\n',STDERR);
    if (file)
    {
#if defined(unix) || defined(DOS)
        fprintf(STDERR,"%s = \"%s\"", RIScom_umsg(RIS_I_FILE), file);
        fprintf(STDERR," %s = %d\n", RIScom_umsg(RIS_I_LINE), line);
#endif
#if defined(WIN32)
        CharToOem(RIScom_umsg(RIS_I_FILE),buffer);
        fprintf(STDERR,"%s = \"%s\"", buffer, file);
        CharToOem(RIScom_umsg(RIS_I_LINE),buffer);
        fprintf(STDERR," %s = %d\n", buffer, line);
#endif
    }
	if (query)
	{
		RIScpp_print_query_hat(query,pos);
	}

/* get the error msg */

	RIS_ERRMSGL = (short)RISXint_error_msg(status, RIS_ERRMSGC, 0);

	/* print out the error message that was found */

	/* In case the error msg size exceeds the limit of 512, using 512 because
	of the size of the array sqlerrmc is 512 in ris.h ----- S.K   */

	if (RIS_ERRMSGL > 512)
	{
		RIS_ERRMSGC[512 - 1] ='\0';
	}

#if defined(unix) || defined(DOS)
	fprintf(STDERR,"%s\n", RIS_ERRMSGC);
#endif
#if defined(WIN32)
    CharToOem(RIS_ERRMSGC,buffer);
	if (status == RIS_E_PROD_NO_REG_QUIT || 
		status == RIS_E_PROD_NO_VALID_LIC_QUIT)
	{
		fprintf(STDERR,buffer);
	}
	else
	{
		fprintf(STDERR,"%s\n", buffer);
	}
#endif

/* clear the error msg */
	memset(risca, 0, sizeof(rissqlca));

	RIScpp_found_error = 1;
	RIScpp_found_error_in_file = 1;

/* turn off licensing */
	RIScpp_serialaudit_end();
}

/******************************************************************************/

extern void RIScpp_print_query_hat(
	char *query,
	int	pos)
{
	int i;
	int j;
	int hat_flag = 1;

#ifdef WIN32
	wchar_t *tmp_query, *c;

	RIScom_multiwide(&RISwide_ptr, &query, &RISwide_size, MULTITOWIDE, 0);
	tmp_query = RISwide_ptr;
#else
	char *tmp_query = query, *c;
#endif
	
/* keep printing until end of the query found */

	for (i=1, c=tmp_query;  *c;  c++,i++)
	{

/* if you find a tab or newline replace it with a space else print the char */

		if ( *c == WIDECHAR('\t') || *c == WIDECHAR('\n') )
		{
			RIScom_fputc(' ',STDERR);
		}
		else
		{
			RIScom_fputc(*c,STDERR);
		}
		if (!(i % LINE_LEN))
		{
			RIScom_fputc('\n',STDERR);
			if ( hat_flag && i >= pos )
			{
				hat_flag = 0;
				for (j=1;j < pos;j++)
				{
					RIScom_fputc(' ',STDERR);
				}
				RIScom_fputs("^\n",STDERR);
			}
		}
	}
	if ((i-1) % LINE_LEN)
	{
		RIScom_fputc('\n',STDERR);
		if (hat_flag && i >= pos)
		{
			for (j=1;j < pos;j++)
			{
				RIScom_fputc(' ',STDERR);
			}
			RIScom_fputs("^\n",STDERR);
		}
	}
}

/******************************************************************************/
