/* Do not alter this SPC information: $Revision: 1.2.9.2 $ */
/*
**	NAME:							btcgtcmd.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**		Reads command lines from terminal or file.
**	
**	REVISION HISTORY:
**      Modified to support double-byte char format for Hangul.
**                                -- Hitesh R. Patel (10/19/92)
*/
 
/*
**	INCLUDES
*/
#include "batch.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define btcgtcmd_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "btcgtcmd.prt"
#include "utlprint.prt"
#include "ucocmd.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISbtc_getcmd(
	char	*buf,
	int		buf_len,
	FILE	*file)
{
	int		first_time = 1;
	char	*cp;
	char	*end;
	char	*begin_comment;

	BTC_DBG(("RISbtc_getcmd(buf:0x%x buf_len:%d file:0x%x)\n",buf,buf_len,file));

	end = cp = buf;
	*buf = '\0';

	do
	{
		if (buf_len < 2)
		{
			BTC_DBG(("RISbtc_getcmd: returning -1\n"));
			return -1;
		}
#if defined(WIN32S)
		if (file == NULL)
		{
			GETS(cp);
			strcat(cp,"\n");
		}
		else
		if (!fgets(cp, buf_len, file))
		{
			BTC_DBG(("RISbtc_getcmd: returning 0\n"));
			return(0);
		}
#else
		if (!fgets(cp, buf_len, file))
		{
			BTC_DBG(("RISbtc_getcmd: returning 0\n"));
			return(0);
		}
#endif

#if defined(WIN32S)

			if (RISbtc_mode == BATCH_MODE || file != NULL)
			{
				RISutl_printf("%s", cp);
				if (RISbtc_outmode ==1)
				{
					PRINTF("%s", cp);//rick
				}
			}
#else
		if (RISbtc_mode == BATCH_MODE || file != stdin)
		{
			RISutl_printf("%s", cp);
		}
#endif

#if defined (WIN32)
/* mms - TR#439503878 Convert from Oem Code Page to Window Code Page */
/*	fix for TR#439702729, no code page conversion for batch mode -Govi */
		if (RISbtc_mode != BATCH_MODE && file == stdin)
                	OemToChar (buf, buf) ;
#endif

		begin_comment = RISuco_eat_comment(buf);

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

	RISutl_printf("\n");

	/* remove trailing stuff */
	while (--end >= buf && (RIScom_isspace(*end) || *end == ';')) *end = '\0';

	BTC_DBG(("RISbtc_getcmd: returning 1\n"));
	return(1);
}
	
/******************************************************************************/
