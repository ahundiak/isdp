/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							edtgtcmd.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**		Reads command lines from terminal or file.
**	
**	REVISION HISTORY:
**      Modified to support double-byte char format for Hangul.
**                                -- Hitesh R. Patel (10/19/92)
**
**      Modified EDT_getcmd so that it does not strip off comments from 
**        shell commands.  -- Mark Boswell (04/08/94)
**      
*/
 
/*
**	INCLUDES
*/
#include "edit.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define edtgtcmd_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "edtgets.prt"
#include "edtgtcmd.prt"
#include "ucocmd.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int EDT_getcmd(
	char	*buf,
	int		buf_len,
	FILE	*file)
{
	int		first_time = 1;
	char	*cp;
	char	*end;
	char	*begin_comment = NULL;

	EDT_DBG(("EDT_getcmd(buf:0x%x buf_len:%d file:0x%x)\n",buf,buf_len,file));

	end = cp = buf;
	*buf = '\0';

	if (file && file != stdin)
	{
		do
		{
			if (buf_len < 2)
			{
				EDT_DBG(("EDT_getcmd: returning -1\n"));
				return -1;
			}
				
			if (!fgets(cp, buf_len, file))
			{
				EDT_DBG(("EDT_getcmd: returning 0\n"));
				return(0);
			}

			fputs(cp, stdout);
		
            if ( buf[0] != '!' ) {
			   begin_comment = RISuco_eat_comment(buf);
            }

			end = RISuco_eat_white(buf);

			buf_len -= end - cp;

			cp = end;

			if (begin_comment) continue;
			
			/* see if this statement must end with a semicolon */
			if (first_time)
			{
				if (!RISuco_need_semi(buf)) break;
				first_time = 0;
			}

		} while (*(end-2) != ';');

		printf("\n");
	}
	else
	{
		if (!EDT_gets(cp))
		{
			/* EOF in stdin not good */
			EDT_DBG(("EDT_getcmd: returning 0\n"));
			return(0);
		}

		/* Ignore blank lines */
		if (!*cp)
		{
			EDT_DBG(("EDT_getcmd: returning 1\n"));
			return(1);
		}

		/* if unended comment found, remove it */

        /* 
        ** if buf is a shell command, do not eat comment 
        */
        if ( buf[0] != '!' ) {
		   begin_comment = RISuco_eat_comment(cp);
        }

		if (begin_comment) *begin_comment = 0;

		end = RISuco_eat_white(cp);
	}

	/* remove trailing stuff */
	while (--end >= buf && (RIScom_isspace(*end) || *end == ';')) *end = '\0';

	EDT_DBG(("EDT_getcmd: returning 1\n"));
	return(1);
}
	
/******************************************************************************/
