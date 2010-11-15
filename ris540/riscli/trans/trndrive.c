/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trndrive.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routine that drives the translation of parse
**		trees to relational algebra trees.
**	
**	REVISION HISTORY:
*/
 
#define TRANS_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include "riscli.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trndrive_c
#include "ccooutpt.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "trncrsch.prt"
#include "trndel.prt"
#include "trndrive.prt"
#include "trnexec.prt"
#include "trnindex.prt"
#include "trninsrt.prt"
#include "trnlock.prt"
#include "trnparms.prt"
#include "trnpriv.prt"
#include "trnsch.prt"
#include "trnselct.prt"
#include "trntable.prt"
#include "trntrans.prt"
#include "trnupdt.prt"
#include "trnview.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RIStrn_driver()
{
	ristree * tp;
	ristree * temp;
	ristree * prev;
	ristree * next;

	tp = RIS_stmt->tree;

TRN_DBG(("\nRIStrn_driver() tp:0x%x\n",tp));

	if (tp)
	{
		RIStrn_parm_index = 0;
		RIStrn_parm_list = 0;
		switch(tp->tok)
		{
			case RIS_TOK_CLOSE_SCHEMA:
				RIStrn_close_schema(tp);
			break;
			case RIS_TOK_CREATE_SCHEMA:
				RIStrn_create_schema(tp);
			break;
			case RIS_TOK_DROP_SCHEMA:
			break;
			case RIS_TOK_DEFAULT_SCHEMA:
			case RIS_TOK_OPEN_SCHEMA:
				RIStrn_open_default_schema(tp);
			break;
			case RIS_TOK_ALTER_SCHEMA:
				RIStrn_alter_schema(tp);
			break;
			case RIS_TOK_CREATE_TABLE:
				RIStrn_create_table(tp);
			break;
			case RIS_TOK_CREATE_VIEW:
				RIStrn_create_view(tp);
			break;
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_DROP_VIEW:
				RIStrn_drop_table_view(tp);
			break;
			case RIS_TOK_ALTER_TABLE:
				RIStrn_alter_table(tp);
			break;
			case RIS_TOK_CREATE_INDEX:
				RIStrn_create_index(tp);
			break;
			case RIS_TOK_DROP_INDEX:
				RIStrn_drop_index(tp);
			break;
			case RIS_TOK_GRANT:
			case RIS_TOK_GRANT_ON_TABLE:
				RIStrn_grant(tp);
			break;
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_GRANT_RESOURCE:
				break;
			case RIS_TOK_REVOKE:
			case RIS_TOK_REVOKE_ON_TABLE:
				RIStrn_revoke(tp);
			break;
			case RIS_TOK_REVOKE_SCHEMA:
			case RIS_TOK_REVOKE_CONNECT:
			case RIS_TOK_REVOKE_RESOURCE:
				break;
			case RIS_TOK_LOCK_TABLES:
				RIStrn_lock_tables(tp);
			break;
			case RIS_TOK_COMMIT:
			case RIS_TOK_ROLLBACK:
				RIStrn_commit_rollback(tp);
			break;
			case RIS_TOK_INSERT:
				RIStrn_insert(tp);
			break;
			case RIS_TOK_DELETE:
				RIStrn_delete(tp);
			break;
			case RIS_TOK_UPDATE:
				RIStrn_update(tp);
			break;
			case RIS_TOK_SELECT:
				RIStrn_select(tp,(ristree *)0,(ristree *)0,(ristree *)0);
			break;
			case RIS_TOK_EXEC:
				RIStrn_exec(tp);
			break;
			case RIS_TOK_SET:
				RIStrn_set(tp);
			break;
			case RIS_TOK_DECLARE_SUPERSCHEMA:
			case RIS_TOK_DECLARE_SCHEMA:
			case RIS_TOK_UNDECLARE_SCHEMA:
			case RIS_TOK_REDECLARE_SUPERSCHEMA:
			case RIS_TOK_UNDECLARE_SUPERSCHEMA:
				break;
			case RIS_TOK_DECLARE_TABLE:
			case RIS_TOK_DECLARE_VIEW:
				RIStrn_declare_table_view(tp);
			break;
			case RIS_TOK_UNDECLARE_TABLE:
			case RIS_TOK_UNDECLARE_VIEW:
				RIStrn_undeclare_table_view(tp);
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
			break;
		}
		if (RIStrn_parm_list)
		{
			prev = 0;
			for(temp=RIStrn_parm_list;temp->rhs;)
			{
				next = temp->rhs;
				temp->rhs = prev;
				prev = temp;
				temp = next;
			}
			temp->rhs = prev;
			RIStrn_parm_list = temp;
			RIStrn_parms(RIStrn_parm_list,RIStrn_parm_index,1);

/* set sqld to 0 since there aren't any REAL input parameters for these stmts */

			if (tp->tok == RIS_TOK_CREATE_TABLE ||
			 tp->tok == RIS_TOK_ALTER_TABLE ||
			 tp->tok == RIS_TOK_CREATE_VIEW ||
			 tp->tok == RIS_TOK_CREATE_INDEX ||
			 tp->tok == RIS_TOK_DECLARE_TABLE ||
			 tp->tok == RIS_TOK_DECLARE_VIEW)
			{
				RIS_stmt->sql->input->sqld = 0;
			}
		}
		if (RIStrn_debug)
		{
			RIScco_output_internal_tree(RIScom_output_debug, tp);
		}
	}
	TRN_DBG(("RIStrn_driver:complete\n"));
}

/******************************************************************************/
