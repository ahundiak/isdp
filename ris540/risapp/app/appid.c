/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appid.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					5/87
**	ABSTRACT:
**		Pass in an address to a statement descriptor.
**		File it in statement map.
**		Return statement id.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "risflags.h"


/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appid_c
#include "appid.prt"
#include "appclear.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/
static  unsigned int timestamp = 1;
static  unsigned int oldest_timestamp = 1;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern short RISapp_new_stmt(
	int	clear_flag,
	int	static_flag) 
{
	short	id;

	APP_DBG(("RISapp_new_stmt(clear_flag:%d static_flag:%d)\n",
		clear_flag, static_flag));

	/*
	**	Search for open slot in statement map for both static and dynamic stmts
	*/
	id = -1;
	if(static_flag == RIS_STATIC_STMT)
	{
		if(clear_flag == RIS_DONT_CLEAR_FLAG)
		{
			RIS_static_stmt_cnt++;
		}

		if (RIS_static_stmt_cnt > RIS_parms.max_static_stmts)
		{
			id = make_open_slot();
    	}
	}
	if (id == -1)
	{
		for (id = 0; id < (short)RIS_max_stmts; id++)
		{
			if (!RIS_stmts[id]) break;
		}
		if (id == (short)RIS_max_stmts)
		{
			id = make_open_slot();
		}
	}

	/*
	**	Give back next statement id
	*/
	RIS_current_stmt_id = id;

	/*
	**	Fill in new stmt stuff
	*/
	RIS_stmt = ALLOCT(ris_app_stmt);
	RIS_stmts[id] = RIS_stmt;
	if (static_flag == RIS_STATIC_STMT && clear_flag == RIS_DONT_CLEAR_FLAG)
	{
		RIS_stmt->timestamp = timestamp++;
		/*
		**	if timestamp exceeds UINT_MAX, it 'wraps' around to
		**	zero.  Since zero is not a valid timestamp, increment it.
		*/
		if(timestamp == 0)
		{
			timestamp = 1;
		}
	}
	else
	{
		RIS_stmt->timestamp = 0;
	}

	APP_DBG(("RISapp_new_stmt: returning id:%d\n", id));
	return id;
}

/******************************************************************************/

/*
** This new routine returns an open slot by clearing the least recently used 
** static statement. If RIS_stmts array runs out of static statements and all 
** the open slots in the array are occupied by dynamic or cursor statements  
** then the function returns an error, when a new statement arrives to be   
** filled. 
** Modified to support superschema execution 11/91
*/

static short make_open_slot(
	void)
{
	short	id;
	short	temp;

	APP_DBG(("make_open_slot()\n"));

	if (!RIS_static_stmt_cnt)
	{
		LONGJMP(RIS_E_TOO_MANY_STMTS);
	}

	for (;;)
	{
		APP_DBG(("looking for timestamp = %d\n",oldest_timestamp));

		for (id = 0; id < (short)RIS_max_stmts; id++)
		{
			if (RIS_stmts[id] && RIS_stmts[id]->timestamp == oldest_timestamp)
			{
				APP_DBG(("found timestamp = %d\n",oldest_timestamp));

				temp = id;
				RISapp_clear(&temp, SET_SQLCODE, CLEAR_CLIENT, SYNC_MODE);

				oldest_timestamp++;
				/*
				**	if oldest_timestamp exceeds UINT_MAX, it 'wraps' around to
				**	zero.  Since zero is not a valid timestamp, increment it.
				*/
				if (oldest_timestamp == 0)
				{
					oldest_timestamp++;
				}

/*				
**				RISapp_clear now decrements RIS_static_stmt_cnt
**
**				if (RIS_static_stmt_cnt > 0) RIS_static_stmt_cnt--;
*/
				break;
			}
		}
		if (id == (short)RIS_max_stmts)
		{

			APP_DBG(("could not find timestamp = %d\n",oldest_timestamp));

			oldest_timestamp++;
			/*
			**	if oldest_timestamp exceeds UINT_MAX, it 'wraps' around to
			**	zero.  Since zero is not a valid timestamp, increment it.
			*/
			if (oldest_timestamp == 0)
			{
				oldest_timestamp++;
			}
		}
		else
		{
			break;
		}
	}

	APP_DBG(("make_open_slot:returning id:%d\n", id));
	return(id);
}	

/******************************************************************************/
