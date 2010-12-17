/*
**  NAME:                           usrinit.c
**  AUTHORS:                        Hitesh Patel
**  CREATION DATE:                  10/19/91
**  ABSTRACT:
**  1.	Allocates memory for RISusr_transact_schemas struct of 
**		sizeof(transact_schemas) of length RIS_parms.max_transactions.
**	2.	Commit or Rollback transaction schemas depending upon normal_flag at 
**		the time of ris termination.
**  REVISION HISTORY:
*/


/*
**  INCLUDES
*/
#include "risasync.h"
#include "riscl_sr.h"
#include "riscli.h"
#include "rismem.h"
#include "user.h"

/*
**  DEFINES
*/

/*
**  VARIABLES
*/

/*
**  FUNCTIONS
*/

/*
**  FUNCTION PROTOTYPES
*/
#define usrinit_c
#include "usrinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comalloc.prt"
#include "usrsndrc.prt"
#include "usrexec.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISusr_init_transact(
	unsigned short max_transactions)
{

	USR_DBG(("RISusr_init_transact: %u\n",max_transactions);)
	
	RISusr_transact_schemas = ALLOCNP(transact_schemas,max_transactions);

	USR_DBG(("RISusr_init_transact: End\n");)
}


extern void RISusr_terminate_transact(
	int	normal_flag)
{
	int schindx;

	USR_DBG(("RISusr_terminate_transact: %d\n",normal_flag);)

	for( schindx = 0; 
		 RISusr_transact_schemas && schindx < RIS_parms.max_transactions;
		 schindx++ )	
	{
		USR_DBG(("RISusr_transact_schemas[%d]=<%s>\n",
			schindx,
			RISusr_transact_schemas[schindx].schema ?
                RISusr_transact_schemas[schindx].schema->schname : "NULL"));
		if( RISusr_transact_schemas[schindx].schema )
		{
			if (!SETJMP())
			{
				RIS_sdp->schema = RISusr_transact_schemas[schindx].schema;
				RIS_stmt = 0;
				if (normal_flag)
				{
					RISusr_send_rec(RIS_COMMIT_WORK_CODE,RIS_sdp, SYNC_MODE);
				}
				else
				{
					RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp, SYNC_MODE);
				}
				RISusr_remove_sch_from_transact(RIS_sdp->schema);
			}
			RESETJMP();
		}
	}

	USR_DBG(("RISusr_terminate_transact: End\n");)
}

