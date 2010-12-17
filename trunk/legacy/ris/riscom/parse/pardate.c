/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							pardate.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					5/90
**	ABSTRACT:
**		Datetime parsing functions
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "risdebug.h"
#include "rismem.h"
#include "ristoken.h"
#include "parser.h"

/*
**	FUNCTION PROTOTYPES
*/
#define pardate_c
#include "comalloc.prt"
#include "comdate.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "comstrcp.prt"
#include "pardate.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISpar_parse_datetime(
	ristree * tp)
{
	int			len;
	int			offset;
	dtime	*dtp;


	PAR_DBG(("RISpar_parse_datetime(tp:0x%x)\n\ttp->info.val:<%s>\n",
		tp,tp->info.val));

	dtp = ALLOCT(dtime);

	if (tp->tok != RIS_TOK_TIMESTAMP_LIT)
	{
		RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR, tp->pos);
	}

    /* remove quotes */
	len = RIScom_strcpy(tp->info.val, tp->info.val + 1);
	tp->info.val[len - 1] = '\0';

	PAR_DBG(("RISpar_parse_datetime(): tp->info.val:<%s>\n", tp->info.val));

	if ((offset = RIScom_char_to_datetime(tp->info.val, dtp)) != 0)
		RISpar_ERR_RETURN(RIS_E_INV_DATETIME,tp->pos + offset);

	tp->info.val = (char *)dtp;

	if (RISpar_debug)
	{
		RIScom_output_debug("tp->info.val = ");
#if defined(sun)
		RIScom_output_datetime((int(*)())RIScom_output_debug, (dtime*)tp->info.val);
#elif defined(unix) || defined(WIN32)
		RIScom_output_datetime(RIScom_output_debug, (dtime*)tp->info.val);
#endif
		RIScom_output_debug("\nRISpar_parse_datetime: complete\n");
	}
}

/******************************************************************************/
