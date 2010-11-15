/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							utlmisc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(DOS)
#include <conio.h>
#endif
#include "util.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define utlmisc_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "utlmisc.prt"
#include "utlprint.prt"
#include "ucofgets.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_ignore_errors(
	int ignore_flag)
{
	UTL_DBG(("RISutl_ignore_errors(ignore_flag:%d)\n", ignore_flag));

	RISutl_ignore_errors_flag = ignore_flag;

	if (RISutl_ignore_errors_flag)
		RISutl_printf(MSG(RISUTL_I_IGNORING_ERRORS));
	else
		RISutl_printf(MSG(RISUTL_I_PROCESSING_ERRORS));

	UTL_DBG(("RISutl_ignore_errors:complete\n"));
}

/******************************************************************************/

extern void RISutl_clear_sqlda(
	sqlda	*ptr)
{
	int i;

	UTL_DBG(("RISutl_clear_sqlda(ptr:0x%x)\n",ptr));

	if (ptr)
	{
		if (ptr->sqlvar)
		{
			for (i = 0; i < ptr->sqln; i++)
			{
				if (ptr->sqlvar[i].sqldata)
				{
					free(ptr->sqlvar[i].sqldata);
				}

				if (ptr->sqlvar[i].sqlind)
				{
					free(ptr->sqlvar[i].sqlind);
				}
			}
		
			free(ptr->sqlvar);
		}
		memset(ptr, 0, sizeof(sqlda));
	}

	UTL_DBG(("RISutl_clear_sqlda:returning\n"));
}

/******************************************************************************/

extern void RISutl_fgets(
	char *s,
	int size,
	FILE *fp)
{
#if defined(DOS)
	int	c;
	int	i;

	if (fp == stdin)
	{
		i = 0;
		while(1)
		{
			c = _getch();
			if (c == '')
			{
				putchar('\n');
				s[0] = '\0';
				SET_INTERRUPT();
				return;
			}
	
			if (c == 13)
			{
				putchar('\n');
				s[i] = '\0';
				return;
			}

			putchar(c);

			if (i < size - 1)
			{
				s[i++] = (char)c;
			}
		}
	}
	else
	{
		RISuco_fgets(s, size, fp);
	}
#elif defined(unix) || defined(WIN32)
	RISuco_fgets(s, size, fp);
#else
	!!! ERROR -- NO CODE !!!
#endif
}

/******************************************************************************/
