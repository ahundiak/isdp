/*
**	NAME:							ccoclstm.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					7/92
**	ABSTRACT: 		This file is modeled after Terry's ccoeot.c
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "clicom.h"

/*
**	DEFINES
*/
#define MAX_CLEAR_STMT_COUNT RIS_MAX_STMTS - RIS_MAX_DICT_STMTS

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccoclstm_c
#include "ccoclstm.prt"
#include "comdebug.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/
static int 	 clear_stmt_count = 0;
static short clear_stmt_list[MAX_CLEAR_STMT_COUNT];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_clear_clear_stmt_list()
{
	CCO_DBG(("RIScco_clear_clear_stmt_list()\n"));

	clear_stmt_count = 0;

	CCO_DBG(("RIScco_clear_clear_stmt_list:complete\n"));
}

/******************************************************************************/

extern void RIScco_add_to_clear_stmt_list(
	short stmt_id)
{
	CCO_DBG(("RIScco_add_to_clear_stmt_list  stmt_id=%d\n", stmt_id));

	if (clear_stmt_count >= MAX_CLEAR_STMT_COUNT)
	{
		CCO_DBG(("RIScco_clear_stmt_list:ERROR:exceeded "
			"MAX_CLEAR_STMT_COUNT\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	clear_stmt_list[clear_stmt_count] = stmt_id;
	clear_stmt_count++;
	
	CCO_DBG(("RIScco_add_to_clear_stmt_list:complete\n"));
}

/******************************************************************************/

extern void RIScco_get_clear_stmt_list(
	int		*countp,
	short 	**listp)
{
	CCO_DBG(("RIScco_get_clear_stmt_list(countp:0x%x listp:0x%x)\n",
		countp, listp));

	*countp = clear_stmt_count;
	*listp  = clear_stmt_list;

	CCO_DBG(("RIScco_get_clear_stmt_list:complete\n"));
}

/******************************************************************************/
