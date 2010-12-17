/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							cliid.c
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
#include "riscom.h"
#include "rismem.h"
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
#define cliid_c
#include "cliid.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern short RIScli_new_stmt(
	short	id)
{

	CLI_DBG(("RIScli_new_stmt(id:%d)\n", id));

	if (id < 0 ||
		(unsigned int)id >= (unsigned int)(RIS_parms.max_user_stmts +
							 RIS_max_secondary_stmts) ||
	 RIS_stmts[id])
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Give back next statement id
	*/
	RIS_current_stmt_id = id;

	/*
	**	Fill in new stmt stuff
	*/
	RIS_stmt = ALLOCT(risstmt);
	RIS_stmts[id] = RIS_stmt;
	RIS_stmt->stmt_id = id;
	RIS_stmt->old_stmt_id = -1;
	RIS_stmt->sql = ALLOCT(rissql);
	RIS_stmt->sql->output = ALLOCT(internal_sqlda);
	RIS_stmt->sql->input = ALLOCT(internal_sqlda);

    /*
    **  filling the default schema name at the prepare time for the add
    **  secondary option of redeclare superschema.
    */
	if (RIS_default)
	{
    	strcpy(RIS_stmt->prep_def_schname, RIS_default->schname);
	}

	/*
	**	default size for any dictionary lookups that may occur
	*/
	RIS_stmt->read_buf_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_stmt->write_buf_size = RIS_INITIAL_BUFFER_SIZE;

	CLI_DBG(("RIScli_new_stmt:returning id:%d\n", id));
	return id;
}

