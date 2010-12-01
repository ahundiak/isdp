/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appasync.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/12
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#include "risapp.h"
#include "rismem.h"
#include "riscom.h"
#include "risdebug.h"
#include "risstjmp.h"

/******************************************************************************/

extern short RISapp_new_async(
	void)
{
	short	id;


	APP_DBG(("RISapp_new_async()\n"));

	/*
	**	Search for open slot in async map
	*/
	for (id = 0; id < RIS_MAX_TRANSACTIONS; id++)
	{
		if (!RIS_asyncs[id])
		{
			break;
		}
	}
	if(id == RIS_MAX_TRANSACTIONS)
	{
		LONGJMP(RIS_E_EXCEEDED_ASYNC_LIMIT);
	}

	/*
	**	Fill in new async stuff
	*/
	RIS_async = ALLOCTA(id, risasync);
	RIS_async->async_id = id;
	RIS_asyncs[id] = RIS_async;


	APP_DBG(("RISapp_new_async: returning id:%d\n", id));
	return id;
}

/******************************************************************************/
