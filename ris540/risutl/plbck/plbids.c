/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							plbids.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#include "rislimit.h"
#include "risutl.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/
struct id_s
{
	short recorded;
	short playback;
};

/*
**	FUNCTION PROTOTYPES
*/
#define plbids_c
#include "plbids.prt"
#include "plbmisc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
struct id_s	stmt_ids[RIS_MAX_STMTS];
int			async_ids[RIS_MAX_TRANSACTIONS];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void initialize_ids()
{
	int i;

	for (i = 0; i < RIS_MAX_STMTS; i++)
	{
		stmt_ids[i].recorded = -1;
		stmt_ids[i].playback = -1;
	}

	for (i = 0; i < RIS_MAX_TRANSACTIONS; i++)
	{
		async_ids[i] = -1;
	}
}

/******************************************************************************/

extern void kludge_ids()
{
	int i;

	for (i = 0; i < RIS_MAX_STMTS; i++)
	{
		if (stmt_ids[i].playback == -1 && stmt_ids[i].recorded != -1)
		{
			stmt_ids[i].recorded = -1;
		}
	}
}

/******************************************************************************/

extern short *get_playback_stmt_id_addr(
short recorded_stmt_id)
{
	int i;

	kludge_ids();

	for (i = 0; i < RIS_MAX_STMTS; i++)
	{
		if (recorded_stmt_id == stmt_ids[i].recorded)
		{
			return &stmt_ids[i].playback;
		}
	}

	PRINTF("get_playback_stmt_id_addr: error: unable to find recorded_stmt_id:"
		"%d\n", recorded_stmt_id);

	Exit(1);
	return NULL;
}

/******************************************************************************/

extern short get_playback_stmt_id_value(
short recorded_stmt_id)
{
	int i;

	kludge_ids();

	for (i = 0; i < RIS_MAX_STMTS; i++)
	{
		if (recorded_stmt_id == stmt_ids[i].recorded)
		{
			return stmt_ids[i].playback;
		}
	}

	PRINTF("get_playback_stmt_id_value: error: unable to find recorded_stmt_id:"
		"%d\n", recorded_stmt_id);
	Exit(1);
	return 0;
}

/******************************************************************************/

extern void set_recorded_stmt_id_value(
short *playback_stmt_id_addr,
short recorded_stmt_id)
{
	int i;
	int error;

	if (recorded_stmt_id != -1)
	{
		error = 0;
		for (i = 0; i < RIS_MAX_STMTS; i++)
		{
			if (stmt_ids[i].recorded == recorded_stmt_id)
			{
				error = 1;

				PRINTF("set_recorded_stmt_id:error:recorded_stmt_id:%d already in stmt_ids array\n");
				PRINTF("                          :stmts_ids[%d].recorded:%d\n",
					i, stmt_ids[i].recorded);
				PRINTF("                          :stmts_ids[%d].playback:%d\n",
					i, stmt_ids[i].playback);
			}
		}
		if (error)
		{
			Exit(1);
		}
	}

	for (i = 0; i < RIS_MAX_STMTS; i++)
	{
		if (playback_stmt_id_addr == &stmt_ids[i].playback)
		{
			stmt_ids[i].recorded = recorded_stmt_id;			
			return;
		}
	}

	PRINTF("set_recorded_stmt_id: error: unable to find playback_stmt_id_addr:"
		"0x%x\n", playback_stmt_id_addr);
	Exit(1);
}

/******************************************************************************/

extern int *get_playback_async_id_addr(
int recorded_async_id)
{
	if (recorded_async_id < 0 || recorded_async_id >= RIS_MAX_TRANSACTIONS)
	{
		PRINTF("get_playback_async_id_addr: error: invalid recorded_async_id:"
			"%d\n", recorded_async_id);
		Exit(1);
	}
	return &async_ids[recorded_async_id];
}

/******************************************************************************/

extern int get_playback_async_id_value(
int recorded_async_id)
{
	if (recorded_async_id < 0 || recorded_async_id >= RIS_MAX_TRANSACTIONS)
	{
		PRINTF("get_playback_async_id_value: error: invalid recorded_async_id:"
			"%d\n", recorded_async_id);
		Exit(1);
	}
	return async_ids[recorded_async_id];
}

/******************************************************************************/

extern void set_recorded_async_id_value(
int playback_async_id,
int recorded_async_id)
{
	if (recorded_async_id < 0 || recorded_async_id >= RIS_MAX_TRANSACTIONS)
	{
		PRINTF("set_playback_async_id_value: error: invalid recorded_async_id:"
			"%d\n", recorded_async_id);
		Exit(1);
	}

	async_ids[recorded_async_id] = playback_async_id;
}

/******************************************************************************/
