/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clisvglb.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					5/92
**	ABSTRACT: 		Saves and Restores globals for superschema execution.
**	
**	REVISION HISTORY:
*/
 
/*
**  INCLUDES
*/
#include "riscom.h"
#include "client.h"

/*
**  DEFINES
*/


/*
** 	VARIABLES
*/
static int save_id;
static char save_superschname[RIS_MAX_ID_SIZE];
static risschema * save_schema;

/*
**  FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define clisvglb_c
#include "clisvglb.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "dicundss.prt"
#include "sys.prt"

/******************************************************************************/

/*
** Saves the global values before prepare/execute are executed on a
** superschema.
*/

extern void RIScli_save_globals()
{

CLI_DBG(("\nRIScli_save_globals()\n"));

	save_id = RIS_current_stmt_id;

	CLI_DBG(("save_id:%d\n", save_id));
	CLI_DBG(("Default Schema:->\n"));
	CLI_DBG(("\tschname:<%s> superschema_flag:%d\n",
			RIS_default->schname, RIS_default->superschema_flag));
	switch(RIS_default->superschema_flag)
	{
		case REGULAR_SCHEMA:
			save_schema = RIS_default;
			*save_superschname = '\0';
		break;
		case PRIMARY_SCHEMA:
			strcpy(save_superschname,RIS_default->super_schp->schname);
			save_schema = 0;
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
}

/******************************************************************************/

/*
** Restores the global values after prepare/execute are completed on a
** superschema.
*/

extern void RIScli_restore_globals()
{
	rissuperschema * superschema;

CLI_DBG(("\nRIScli_restore_globals()\n"));

	if (save_schema)
	{
		RIS_default = save_schema;
		RIS_current_stmt_id = (short)save_id;
		RIS_stmt = RIS_stmts[save_id];
	}
	else
	{
		superschema = RISdic_find_supersch(save_superschname);
		if (superschema)
		{
			RIS_default = superschema->sub_schp;
			RIS_current_stmt_id = (short)save_id;
			RIS_stmt = RIS_stmts[save_id];
		}
		else
		{
			RIS_default = 0;
			RIS_current_stmt_id = -1;
			RIS_stmt = 0;
		}
	}
}

/******************************************************************************/

