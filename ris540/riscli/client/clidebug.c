/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clidebug.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clidebug_c
#include "clidebug.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "usrsndrc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_set_debug(
	unsigned int data,
	int	server_flag)
{
	CLI_DBG(("RIScli_set_debug(data:0x%x server_flag:%d)\n",data,server_flag));

	if (RIScom_debug_mask_to_flags(data, SET_AND_CLEAR))
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (server_flag)
	{
		RISusr_send_all_srvs(RIS_DBG_CODE, data, SYNC_MODE);
	}

	CLI_DBG(("RIScli_set_debug:complete\n"));
}

/******************************************************************************/
