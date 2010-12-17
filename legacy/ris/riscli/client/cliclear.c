/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							cliclear.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					10/87
**	ABSTRACT:
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
#include "rismem.h"
#include "rissttyp.h"
#include "ristoken.h"
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
#define cliclear_c
#include "cliclear.prt"
#include "cliexec.prt"
#include "ccosqlca.prt"
#include "clistmst.prt"
#include "comsqlca.prt"
#include "comexmod.prt"
#include "comfree.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "dicundss.prt"
#include "usrsndrc.prt"
#include "usrexec.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_clear(
	short	stmt_id,
	int		set_sqlcode,
    unsigned char execute_mode,
	short	no_exec_but_clear)
{
	int				status;
	short			stmtstat_indx;
    risstmt 		*stmt;
    risstmt 		*temp;
	risstmtstat		*stmtstat = 0;
	risschema		*schema;
    rissuperschema  *sschema = 0;
	char			save_ssname[RIS_MAX_ID_SIZE];

    CLI_DBG(("RIScli_clear(stmt_id:%d set_sqlcode:%d execute_mode:%s no_exec_but_clear:%d)\n",
	 		 stmt_id, set_sqlcode,RIScom_get_execute_mode_name(execute_mode), 
			 no_exec_but_clear));

    if (stmt_id <0 ||
		(unsigned short)stmt_id >= (unsigned short)(RIS_parms.max_user_stmts+RIS_max_secondary_stmts))
    {
		LONGJMP(RIS_E_INTERNAL_ERROR);
    }

	if (!RIS_stmts[stmt_id])
	{
		CLI_DBG(("RIScli_clear RIS_stmts[%d] is NULL. Returning...\n",
			stmt_id));
		return;
	}

	stmt = RIS_stmts[stmt_id];

/*
**  Making sure that we clear only on the primary schemas defined for a
**  superschema
*/

    if (stmt->sql && stmt->sql->schema &&
	 stmt->sql->schema->superschema_flag == PRIMARY_SCHEMA)
    {
		sschema = stmt->sql->schema->super_schp;
		strcpy(save_ssname,sschema->schname);
/*
**  Clearing on all the stmts of schemas defined for a superschema
*/
		/*
		**	Initialize error structures of risstmtstat if 
		**	1. setsqlcode is set or
		**	2. no_exec_but_clear or
		**  3. sschema->primary_id is different than current stmt
		**	4. it is select stmt
		**	While preparing superschema stmts, there might be failure and 
		**	therefore risstmtstat structs needs to be allocated.
		**	While executing 'default schema' or 'select' stmt, risstmtstat	
		**	structs are NOT initialized by RIScli_execute().
		**	If it fails during initializing error structures, then it won't
		**	start clear code asynchronously
		*/
		if (set_sqlcode || sschema->primary_id != stmt_id || no_exec_but_clear)
		{
			sschema->stmt_count = 0;
			for(temp = stmt; temp; temp = temp->next)
			{
				stmtstat_indx = sschema->stmt_count;
				sschema->stmt_count++;
				schema = temp->sql->schema;
				RIScli_init_error_structs(sschema, stmtstat_indx, 
				temp->stmt_id, schema->schname, temp->query);
			}
		}

		/*
		**	Start clear code asynchronously
		**	Continue ahead even if any of the stmts fails
		*/
        for( stmtstat_indx = 0; 
				stmtstat_indx < sschema->stmt_count; 
					stmtstat_indx++ )
        {
			stmtstat = sschema->stmtstat[stmtstat_indx];
			if (stmtstat->stmt_id != -1)
			{
				status = RIScli_single_stmt_clear(stmtstat->stmt_id, 
							set_sqlcode, ASYNC_START_MODE);
				if (!status)
				{
					stmtstat->state = CLEAR_STATE;
					CLI_DBG(("clear started for schema <%s> \n", 
						stmtstat->schname));
				}
				else
				{
					if(!RISdic_find_supersch(save_ssname))
					{
						if (set_sqlcode)
						{
                           	LONGJMP(RIS_E_FATAL_SUPERSCHEMA_ERROR);
						}
						else
						{
							/*
							** Do nothing
							*/
							CLI_DBG(("RIScli_clear: (1) no superschema, returning...\n"));
							return;
						}
					}
					stmtstat->state = COMPLETE_ERROR_STATE;
					if (set_sqlcode)
					{
						RIScli_copy_sqlcas(sschema, stmtstat_indx, status);
					}
                	if( IS_SERVER_DEAD(status) )
                	{
                    	/*
                    	**  If one of the server dies do:
                   		**  1. set its id to -1
                    	*/
                    	stmtstat->stmt_id = -1;
                	}
					CLI_DBG(("failed to start clear for <%s> \n", 
					stmtstat->schname));
				}
			}
        }
		/*
		** Donot swap if primary dies during test completion
		*/
		RIS_stmts[stmt_id]->swap_n_clear_flag = 1;

/*
**  Check the status of the stmts started asynchronously above.
**  (risstmtstat structure indicates each stmt's state).
*/

		if( RIScli_debug )
		{
			RIScom_output_superschema_info(RIScom_output_debug, sschema, 1);
		}

		do
		{
			for( stmtstat_indx = 0;
					stmtstat_indx < sschema->stmt_count;
						stmtstat_indx++)
			{
				if( RIScli_debug )
				{
					RIScom_output_superschema_stmt(RIScom_output_debug, sschema, 1);
				}
				stmtstat = sschema->stmtstat[stmtstat_indx];
                if (stmtstat->state == CLEAR_STATE)
				{
					status = 
						RIScli_single_stmt_clear(stmtstat->stmt_id,
					 						set_sqlcode, ASYNC_TEST_MODE);
					switch (status)
					{
						case RIS_SUCCESS:
							if (set_sqlcode)
							{
                            	stmtstat->risca->sqlcode = status;
							}
							stmtstat->state = COMPLETE_SUCCESS_STATE;
							CLI_DBG((
							 "successfully cleared stmt for schema <%s>\n",
							 stmtstat->schname));
						break;
						case STATEMENT_NOT_COMPLETE:
							CLI_DBG(("clear not complete for <%s>\n",
							 stmtstat->schname));
						break;
						default:
                            if(!RISdic_find_supersch(save_ssname))
                            {
								if (set_sqlcode)
								{
                                	LONGJMP(RIS_E_FATAL_SUPERSCHEMA_ERROR);
								}
								else
								{
									/*
									** Do nothing
									*/
									CLI_DBG(("RIScli_clear: (2) no superschema, returning...\n"));
									return;
								}
                            }
							stmtstat->state = COMPLETE_ERROR_STATE;
							if (set_sqlcode)
							{
								RIScli_copy_sqlcas(sschema, stmtstat_indx, status);
							}
                            if( (status == RIS_E_SCHEMA_RESTARTED) ||
                                (status == RIS_E_SERVER_RESTARTED) ||
                                (status == RIS_E_DEFAULT_SCHEMA_DIED) ||
                                (status == RIS_E_SERVER_DIED) ||
                                (status == RIS_E_SCHEMA_DIED) ||
                                (status == RIS_E_SERVER_NOT_RESPONDING) )
                            {
                                /*
                                **  If one of the server dies do:
                                **  1. if primary schema dies, assign its id to
                                **     first secondary schema in list
                                **  2. set its id to -1
                                */
                                if( stmtstat->stmt_id ==
                                    RIS_stmts[stmtstat->stmt_id]->primary_id )
                                {
                                    sschema->stmtstat[stmtstat_indx+1]->stmt_id
                                        = stmtstat->stmt_id;
                                }
                                stmtstat->stmt_id = -1;
                            }
							CLI_DBG(("failed to clear stmt for schema <%s>\n",
							 stmtstat->schname));
						break;
					}
				}
			}
		} while (!RIScli_check_completion(sschema));

		sschema->primary_id = -1;
		if (set_sqlcode)
		{
			/*
			**	sqlcode of primary schema
			*/
			status = sschema->stmtstat[0]->risca->sqlcode;
			for(stmtstat_indx = 1;
				stmtstat_indx < sschema->stmt_count;
					stmtstat_indx++)
			{
				stmtstat = sschema->stmtstat[stmtstat_indx];
				if (stmtstat->risca->sqlcode != status)
				{
					CLI_DBG(("RIScli_clear: secondary schema status:%d != "
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
    }
	else
	{
		status = 
			RIScli_single_stmt_clear(stmt_id, set_sqlcode, execute_mode);
		if (set_sqlcode && status != RIS_SUCCESS) 
		{
			LONGJMP(status);
		}
	}
	CLI_DBG(("RIScli_clear: complete\n"));
}

/******************************************************************************/

static void decrement_tab_count(
    risstmt *stmt)
{
    ristablist *tablistp;

	CLI_DBG(("decrement_tab_count(stmt:0x%x)\n",stmt));

    tablistp = stmt->tablist;

    while (tablistp)
    {
		if (tablistp->tab)
		{
        	tablistp->tab->ref_count--;
			CLI_DBG(("decremented ref_count to %d tabname:<%s>\n",
				tablistp->tab->ref_count, tablistp->tab->tabname));
		}
		tablistp = tablistp->next;
    }
	CLI_DBG(("decrement_tab_count() done...\n"));
}

/******************************************************************************/

static int RIScli_single_stmt_clear(
	short	stmt_id,
	int		set_sqlcode,
    unsigned char execute_mode)
{
	int				status;
    risstmt 		*stmt=0;

    CLI_DBG(("RIScli_single_stmt_clear(stmt_id:%d set_sqlcode:%d execute_mode:%s )\n",
	 stmt_id, set_sqlcode,RIScom_get_execute_mode_name(execute_mode)));

    if (stmt_id <0 ||
		(unsigned short)stmt_id >= (unsigned short)(RIS_parms.max_user_stmts+RIS_max_secondary_stmts))
    {
		return RIS_E_INTERNAL_ERROR;
    }

	if (!RIS_stmts[stmt_id])
	{
		return RIS_SUCCESS;
	}

	stmt = RIS_stmts[stmt_id];
	RIS_current_stmt_id = stmt_id;
	RIS_stmt = stmt;

	if (!set_sqlcode)
	{
		RIScco_push_risca_dbca();
	}

	status = SETJMP();
	if (!status)
	{
        CLI_DBG(("sql = 0x%x schema = 0x%x dbms = 0x%x stmt_type = %d\n",
         RIS_stmt->sql,RIS_stmt->sql->schema,RIS_stmt->sql->dbms,
         RIS_stmt->sql->stmt_type));

		if (RIS_stmt->sql && RIS_stmt->sql->schema && RIS_stmt->sql->dbms &&
			(RIS_stmt->sql->stmt_type == RIS_INSERT_STMT ||
			 RIS_stmt->sql->stmt_type == RIS_UPDATE_STMT ||
			 RIS_stmt->sql->stmt_type == RIS_DELETE_STMT ||
			 RIS_stmt->sql->stmt_type == RIS_SELECT_STMT))
		{
			RIS_sdp->schema = RIS_stmt->sql->schema;
			RISusr_send_rec(RIS_CLEANUP_CODE, RIS_sdp, execute_mode);
    		if (IN_FINISH_MODE(execute_mode))
			{
				RISusr_close_cursor(RIS_current_stmt_id);
			}
		}
		status = RIS_SUCCESS;
	}
	RESETJMP();

	if (status == RIS_SUCCESS || status != STATEMENT_NOT_COMPLETE)
	{
   		if (IN_FINISH_MODE(execute_mode))
		{
/*
** If server died the statement may already have been cleared or have been
** swapped with a statement that we should not free up here
*/
			CLI_DBG(("RIScli_single_stmt_clear:(FINISH_MODE) stmt_id:%d\n",
				stmt_id));
			if (RIS_stmts[stmt_id])
			{
				CLI_DBG(("RIScli_single_stmt_clear: freeing stmt memory ..\n"));
				/*
				** Decrement ref_count for all tables referenced by this
				** statement from tablist.
				*/
        		decrement_tab_count(RIS_stmt);

				FREE(stmt_id);
				RIS_stmts[stmt_id] = 0;
				RIS_current_stmt_id = -1;
			}
		}
	}

	if (!set_sqlcode)
	{
		RIScco_pop_risca_dbca();
	}
	CLI_DBG(("RIScli_single_stmt_clear: complete\n"));
	return (status);
}

/******************************************************************************/
