/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							cliexec.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/87
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**      Modified by Hitesh R. Patel on 8/92
**
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "ristoken.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cliexec_c
#include "cliexec.prt"
#include "clisvglb.prt"
#include "clistmst.prt"
#include "comsqlca.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "comstmt.prt"
#include "dicundss.prt"
#include "dicopsch.prt"
#include "usrexec.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScli_execute(
	short id,
	unsigned char execute_mode,
	unsigned char blobinfo)
{
	risstmt     	*stmt;
	risstmt			*temp;
	risstmtstat		*stmtstat = 0;
	rissuperschema  *sschema = 0;
	int				status;
    short           stmtstat_indx = 0;
	char			save_ssname[RIS_MAX_ID_SIZE];
	int				save_globals_flag = 0;

	CLI_DBG(("RIScli_execute(id:%d execute_mode:%s)\n", id,
		RIScom_get_execute_mode_name(execute_mode)));

	if (id < 0 ||
		(unsigned int)id > (unsigned int)(RIS_parms.max_user_stmts +
							RIS_max_secondary_stmts) 
		|| !RIS_stmts[id])
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	stmt = RIS_stmts[id];
	RIS_current_stmt_id = id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

/*
**  Making sure that we execute only on the schemas defined for a superschema
**  Select and Default statements are executed only on the primary schema
**  (since it would be redundant to perform them on the secondaries.)
*/

    if (stmt->sql->schema &&
	 stmt->sql->schema->superschema_flag==PRIMARY_SCHEMA &&
     stmt->tree->tok != RIS_TOK_SELECT &&
     stmt->tree->tok != RIS_TOK_DEFAULT_SCHEMA)
    {

		sschema = stmt->sql->schema->super_schp;
		strcpy(save_ssname,sschema->schname);
/*
**  Superschema stuff on statement other than 'select'
*/
        if(RIS_default->superschema_flag != REGULAR_SCHEMA &&
           RIS_default->super_schp == RIS_stmt->sql->schema->super_schp)
        {
			save_globals_flag = 1;
			RIScli_save_globals();
        }


/*
**  Any statement other than 'select' will be executed on all the
**  schemas defined on a superschema
*/

        /*
        **  Initialize error structures of risstmtstat
        **  If it fails during initializing error structures, then it won't
        **  start clear code asynchronously
        */
		sschema->stmt_count = 0;
		for(temp = stmt; temp; temp = temp->next)
		{
            stmtstat_indx = sschema->stmt_count;
			sschema->stmt_count++;
            RIScli_init_error_structs(sschema, stmtstat_indx, temp->stmt_id, 
					temp->sql->schema->schname, temp->query);
		}

        /*
        **  Start execute code asynchronously
        **  Continue ahead even if any of the stmts fails
        */
		for( stmtstat_indx = 0; 
				stmtstat_indx < sschema->stmt_count; 
					stmtstat_indx++ )
		{
			stmtstat = sschema->stmtstat[stmtstat_indx];
			status = SETJMP();
			if (!status)
			{
                if (save_globals_flag)
				{
					RIS_default = RIS_stmts[stmtstat->stmt_id]->sql->schema;
				}
				
				/*  BLOB */
				if (stmt->tree->tok == RIS_TOK_UPDATE ||
                                        stmt->tree->tok == RIS_TOK_DELETE)
                                {
					RIScli_single_stmt_execute(stmtstat->stmt_id, SYNC_MODE,
					blobinfo);

					CLI_DBG(("execution started for schema <%s> \n",
				 	stmtstat->schname));
				}
				else
				{
					RIScli_single_stmt_execute(stmtstat->stmt_id, ASYNC_START_MODE,
					blobinfo);

					stmtstat->state = EXECUTE_STATE;
					CLI_DBG(("execution started for schema <%s> \n",
				 	stmtstat->schname));
				}
			}
			else
			{
				if(!RISdic_find_supersch(save_ssname))
				{
					RESETJMP();
					LONGJMP(RIS_E_FATAL_SUPERSCHEMA_ERROR);
				}
				stmtstat->state = COMPLETE_ERROR_STATE;
				RIScli_copy_sqlcas(sschema, stmtstat_indx, status);

				if( IS_SERVER_DEAD(status) )
				{
					/*
					**	If one of the server dies do:
					**	1. if primary schema dies, assign its id to
					**	   first secondary schema in list
					**	2. set its id to -1
					*/
					if( stmtstat->stmt_id == sschema->primary_id )
					{
						sschema->stmtstat[stmtstat_indx+1]->stmt_id 
							= stmtstat->stmt_id;
					}
					stmtstat->stmt_id = -1;
				}
				CLI_DBG(("failed to start execution for <%s> \n",
				 stmtstat->schname));
			}
			RESETJMP();
		}
/*
**  Check the status of the stmts started asynchronously above. 
**	(risstmtstat structure indicates each stmt's state).
*/

		if( RIScli_debug )
		{
			RIScom_output_superschema_info(RIScom_output_debug, sschema,1);
		}

		do
		{
			for( stmtstat_indx = 0; 
					stmtstat_indx < sschema->stmt_count; 
						stmtstat_indx++)
			{
				if( RIScli_debug )
				{
					RIScom_output_superschema_stmt(RIScom_output_debug,
						sschema, 1);
				}
				stmtstat = sschema->stmtstat[stmtstat_indx];
				if (IN_INCOMPLETE_STATE(stmtstat->state))
				{
                	if (save_globals_flag)
					{
						RIS_default = RIS_stmts[stmtstat->stmt_id]->sql->schema;
					}

					status = SETJMP();
					switch (status)
					{
						case RIS_SUCCESS:
							RIScli_single_stmt_execute(stmtstat->stmt_id,
							 					ASYNC_TEST_MODE,blobinfo);
							/*
							**	Set the state	
							**	Set risca->sqlcode
							*/
							stmtstat->state = COMPLETE_SUCCESS_STATE;
							stmtstat->risca->sqlcode = status;
							CLI_DBG(("execution completed for <%s>\n",
							 stmtstat->schname));
						break;
						case STATEMENT_NOT_COMPLETE:
							CLI_DBG(("execution not complete for <%s>\n",
							 stmtstat->schname));
						break;
						case END_OF_DATA:
							stmtstat->state = COMPLETE_EOD_STATE;
							stmtstat->risca->sqlcode = status;
							CLI_DBG(("execution got eod for <%s> \n",
							 stmtstat->schname));
						break;
						default:
							if(!RISdic_find_supersch(save_ssname))
							{
								RESETJMP();
								LONGJMP(RIS_E_FATAL_SUPERSCHEMA_ERROR);
							}
							stmtstat->state = COMPLETE_ERROR_STATE;
							RIScli_copy_sqlcas(sschema, stmtstat_indx, status);

							if( IS_SERVER_DEAD(status) )
							{
								/*
								**	If one of the server dies do:
								**	1. if primary schema dies, assign its id to
								**	   first secondary schema in list
								**	2. set its id to -1
								*/
								if( stmtstat->stmt_id == sschema->primary_id )
								{
									sschema->stmtstat[stmtstat_indx+1]->stmt_id
										= stmtstat->stmt_id;
								}
								stmtstat->stmt_id = -1;
							}
							CLI_DBG(("execution failed for <%s> \n",
							 stmtstat->schname));
						break;
					}
					RESETJMP();
				}
			}
		}
		while (!RIScli_check_completion(sschema));

       	if (save_globals_flag)
        {
            RIScli_restore_globals();
        }

		/*
		** Check if all schemas had the same success or error
		** Assuming that 0th element is primary schema
		*/
		status = sschema->stmtstat[0]->risca->sqlcode;
		for( stmtstat_indx = 1; 
				stmtstat_indx < sschema->stmt_count; 	
					stmtstat_indx++ )
		{
			stmtstat = sschema->stmtstat[stmtstat_indx];
			if (stmtstat->risca->sqlcode != status)
			{
				CLI_DBG(("RIScli_execute: secondary schema status:%d != "
					"primary schema status:%d\n",
					stmtstat->risca->sqlcode, status));
				LONGJMP(RIS_E_INCONSISTENT_RESULTS);
			}
		}

		if (status != RIS_SUCCESS)
		{
			/*
			** Load the error into the globals
			*/
			stmtstat = sschema->stmtstat[0];
			RIScom_copy_sqlca(risca,stmtstat->risca);
			RIScom_copy_sqlca(dbca,stmtstat->dbca);
			LONGJMP(status);
		}
	}
	else
	{
/*
**  Superschema stuff on statement other than 'select' OR regular schema
*/
		/****  BLOB  ***/
		RIScli_single_stmt_execute(id, execute_mode, blobinfo);
	}
	CLI_DBG(("RIScli_execute: complete\n"));
}

/******************************************************************************/

static void RIScli_single_stmt_execute(
	short id,
	unsigned char execute_mode,
	unsigned char blobinfo)
{
	risstmt     *stmt;

	CLI_DBG(("RIScli_single_stmt_execute(id:%d execute_mode:%s)\n", id,
		RIScom_get_execute_mode_name(execute_mode)));

	if (id < 0 ||
		(unsigned int)id > (unsigned int)(RIS_parms.max_user_stmts +
							RIS_max_secondary_stmts) 
		|| !RIS_stmts[id])
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	stmt = RIS_stmts[id];
	RIS_current_stmt_id = id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	if (stmt->sql && stmt->sql->schema == 0 &&
		RIScom_default_schema_required(stmt->sql->stmt_type))
	{
		RIS_stmt->sql->schema = RISdic_open_schema(RIS_stmt->sql->schname,
		SYNC_MODE);
	}
	/***  BLOB    ***/
	RISusr_exec_stmt(stmt, execute_mode, blobinfo);

	CLI_DBG(("RIScli_single_stmt_execute: complete\n"));
}

/******************************************************************************/

extern int RIScli_check_completion(
	rissuperschema * sschema)

{
	int	stmtstat_indx;
	int	ret = 1;

	CLI_DBG(("RIScli_check_completion(sschema: 0x%x)\n", sschema));
	for (stmtstat_indx = 0;stmtstat_indx < sschema->stmt_count;stmtstat_indx++)
	{
		if (IN_INCOMPLETE_STATE(sschema->stmtstat[stmtstat_indx]->state))
		{
			ret = 0;
			break;
		}
	}
	return ret;
}

/******************************************************************************/
