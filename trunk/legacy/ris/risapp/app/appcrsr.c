/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appcrsr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "rismem.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appcrsr_c
#include "appcrsr.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISapp_alloc_cursor(
	short id)
{
	int size;

	APP_DBG(("RISapp_alloc_cursor(id:%d)\n", id));

	/*
	**	Allocate the fetch buffer
	*/
	if (RIS_stmts[id] && !RIS_stmts[id]->fetch_buf &&
		RIS_stmts[id]->fetch_buf_size > 0)
	{
		size = MAX(RIS_MIN_FETCH_BUF_SIZE, RIS_stmts[id]->fetch_buf_size);
		RIS_stmts[id]->fetch_buf = (ris_cliapp_buf *)NET_alloc(size);
		if (RIS_stmts[id]->fetch_buf == NULL)
		{
			APP_DBG(("RISapp_alloc_cursor: Unable to malloc fetch_buf\n"));
			LONGJMP(RIS_E_NET_ALLOC_ERROR);
		}
	}

	APP_DBG(("RISapp_alloc_cursor:complete\n"));
}

/******************************************************************************/

extern void RISapp_close_cursor(
	short id)
{
	APP_DBG(("RISapp_close_cursor(id:%d)\n", id));

	if( id >= 0 && id < (short)RIS_parms.max_user_stmts )
	{
		/*
		**	Deallocate the fetch buffer
		*/
		if (RIS_stmts[id] && RIS_stmts[id]->fetch_buf)
		{
			NET_free((char *)RIS_stmts[id]->fetch_buf);
			RIS_stmts[id]->fetch_buf = 0;
			RIS_stmts[id]->row_count = 0;
			RIS_stmts[id]->end_of_data = 0;
		}
	}

	APP_DBG(("RISapp_close_cursor: complete\n"));
}

/******************************************************************************/

extern void RISapp_close_all_cursors(
	void)
{
	short	id;

	APP_DBG(("RISapp_close_all_cursors()\n"));

	for (id = 0; id < (short)RIS_max_stmts; id++)
	{
		if (RIS_stmts[id] && RIS_stmts[id]->fetch_buf)
		{
			RISapp_close_cursor(id);
		}
	}

	APP_DBG(("RISapp_close_all_cursors: complete\n"));
}

/******************************************************************************/

extern void RISapp_close_all_cursors_for_schema(
	char	*schname)
{
	short	id;
	APP_DBG(("RISapp_close_all_cursors_for_schema(schname:<%s>)\n", schname));

	for (id = 0; id < (short)RIS_max_stmts; id++)
	{
		if (RIS_stmts[id] && RIS_stmts[id]->fetch_buf &&
			!strcmp(schname, RIS_stmts[id]->schname))
		{
			RISapp_close_cursor(id);
		}
	}

	APP_DBG(("RISapp_close_all_cursors_for_schema: complete\n"));
}

/******************************************************************************/
