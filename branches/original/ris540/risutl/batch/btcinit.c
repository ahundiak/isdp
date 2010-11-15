/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							btcinit.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					1/93
**	ABSTRACT:
**		Initialization for the risbatch utility.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
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
#define btcinit_c
#include "btcinit.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlerror.prt"

/*
**	VARIABLES
*/


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISbtc_init()
{
	int		i;

	BTC_DBG(("RISbtc_init()\n"));

	/*
	**	Initialize RIS
	*/
	BTC_DBG(("RISbtc_init: Calling RISinitialize() ...\n"));
	RISinitialize(getenv("RIS_LANGUAGE"));
	BTC_DBG(("RISbtc_init: Done with RISinitialize().\n"));
	UTL_ERROR_CHECK();
	UTL_WARNING_CHECK();


	RISutl_file_tos =
		(struct RISutl_file_stack*)malloc(sizeof(struct RISutl_file_stack));
#if defined(WIN32S)
	RISutl_file_tos->file = NULL;
#else
	RISutl_file_tos->file = stdin;
#endif
	RISutl_file_tos->next = 0;

	/*
	**	Fill ris_parameters
	*/
	RISget_parameters(&RISutl_parameters);
	UTL_ERROR_CHECK();
	UTL_WARNING_CHECK();

	/*
	** Dynamic allocate memory for RISutl_stmts
	*/
	RISutl_stmts = (ris_utl_stmt *)calloc(RISutl_parameters.max_user_stmts,
		sizeof(ris_utl_stmt));
	if (RISutl_stmts == NULL)
	{
		LONGJMP(RISUTL_E_MALLOC);
	}

	for (i = 0; i < RISutl_parameters.max_user_stmts; i++)
	{
		RISutl_stmts[i].stmt_id = -1;
	}

	BTC_DBG(("RISbtc_init:returning\n"));
}

/******************************************************************************/
