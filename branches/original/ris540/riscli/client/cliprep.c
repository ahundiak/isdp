/*
**	NAME:							cliprep.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:	Modified for the superschema stuff
**											Prasad Challa 9/92.
**											Prasad Challa 9/92.
**						Added function check_replace_superschema()
**											Jin Jing 04/27/94.
**
**	11/94:	Added support for INTERNATIONALIZATION. Dianne
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
#define cliprep_c
#include "cliclear.prt"
#include "cliid.prt"
#include "cliprep.prt"
#include "clitab.prt"
#include "clisvglb.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comjmp.prt"
#include "comstmt.prt"
#include "comstrng.prt"
#include "comsttyp.prt"
#include "dictrans.prt"
#include "diclook.prt"
#include "dicundss.prt"
#include "pardrive.prt"
#include "trndrive.prt"
#include "sqldrive.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

/*
**	The ref_by_crnt_stmt field of each schema is assigned a zero value.
*/

static void zrisschema_fld()
{
	risschema *sch;

	CLI_DBG(("zrisschema_fld()\n"));

	for (sch = RIS_srvs; sch; sch = sch->next)
	{
		sch->ref_by_crnt_stmt = 0;
	}

	CLI_DBG(("zrisschema_fld:complete\n"));
}

/******************************************************************************/

extern void RIScli_prepare(
	short	id,
	char	*query,
    char    *super_sch_name,
    char    *secondary_sch_name,
	short   primary_stmt_id)

{
	int				status;
	volatile short stmt_id = -1;
	volatile short superschema_flag = 0;
	int len;
    risschema *primary_schema=0;
    risschema *secondary_schema;
    rissuperschema *super_schema=0;
	risstmt *temp;
    int secondary_id;
	int save_globals_flag = 0;

CLI_DBG(("RIScli_prepare(id:%d query:<%s> super_sch_name:<%s> secondary_sch_name:<%s>)\n",id, query, STRING(super_sch_name), STRING(secondary_sch_name)));

	status = SETJMP();
	if (status)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			/*
			** If superschema_flag then clear all superschema stmts
			*/
			RIScli_clear(stmt_id,0,SYNC_MODE,superschema_flag);
		}

		/* Fix TR#249407503, 249407504 :kmreddy */
		/* Maintain upward compatible error messages */

		if ( RIS_app_cli_version < 5 )
		{
			switch ( status )
			{
				case RIS_E_INV_SQL_STATEMENT :
				  status = RIS_E_INV_USER_SPEC; break;
			  	case RIS_E_INV_REVOKE_STMT :
			  	  status = RIS_E_INV_REVOKE_PRIVILEGES; break;
			  	default :
			  	  break;
			  	
			}
		}
		LONGJMP(status);


	}

	/*
	**	Get a new statement id
	*/
	stmt_id = RIScli_new_stmt(id);

	/*
	**  Primary_id field for all the regular schemas will be assigned to -1,
	**  since there is no such thing as a primary schema defined on 'em.
	**
	**  If we are preparing the statement on a secondary schema of a given 
	**	super schema, then the primary_id will be set to the id of the 
	**  statement prepared for the primary schema of that superschema.
	*/
	RIS_stmt->primary_id = primary_stmt_id;
	zrisschema_fld();

    /*
    **  save the query
    */
    len = strlen(query) + 1;
    if (len > RIS_MAX_STMT_LEN)
    {
        CLI_DBG(("RIScli_prepare: length of query(%d) is too long\n", len));
        LONGJMP(RIS_E_INTERNAL_ERROR);
    }
    RIS_stmt->query = ALLOCB(len);
    memcpy(RIS_stmt->query, query, len);
    RIScom_fix_space(RIS_stmt->query);

	/*
    ** make sure there are no stray hash table transactions for this stmt
    */

    RISdic_check_for_transact();

	/*
	**	Parse the statement
	*/
	RIS_stmt->tree = RISpar_driver(query, super_sch_name, secondary_sch_name, NULL, RIS_default);

	/*
	**      Check privileges
	*/
	if (!RIScli_have_privilege(RIS_stmt->tree->tok))
	{
		LONGJMP(RIS_E_HAVE_NO_PRIVILEGE);
	}

	if (!secondary_sch_name)
	{
		check_replace_superschema(RIS_stmt->tree, 
			&super_schema, &primary_schema);
		CLI_DBG(("RIScli_prepare: super_schema=%s primary_schema=%s\n",
			super_schema->schname ? super_schema->schname : "NULL",
			primary_schema->schname ? primary_schema->schname : "NULL"));
 		if (!primary_schema &&
			RIScli_can_execute_on_superschema(RIS_stmt->tree->tok))
		{
			primary_schema = RIS_default;
		}
	}

	if (primary_schema && primary_schema->superschema_flag == PRIMARY_SCHEMA)
	{
		/*
		**	This flag indicates that superschema stmts are being prepared.
		**	It is required to clear superschema stmts if prepare fails.
		*/
		superschema_flag = 1;

		temp = RIS_stmts[stmt_id];
		primary_stmt_id = stmt_id;

	/*
	** Assigning the primary_id field with the id of the statement prepared
	** on the primary schema.
	*/
		RIS_stmt->primary_id = primary_stmt_id;
		
	/*
	** translate and generate sql for the PRIMARY schema
	*/
		RIStrn_driver();
		RISsql_driver();

/* save the view string for create view */

		if (RIS_stmt->sql->stmt_type == RIS_CREATE_VIEW_STMT)
		{
			len = strlen(query)+1;
			RIS_stmt->view_string = ALLOCB(len);
			memcpy(RIS_stmt->view_string,query,len);
			RIScom_fix_space(RIS_stmt->view_string);
		}

		if (RIS_default && RIS_stmt->sql->schema &&
			RIS_default->superschema_flag != REGULAR_SCHEMA &&
			RIS_default->super_schp == RIS_stmt->sql->schema->super_schp)

		{
			save_globals_flag = 1;
			RIScli_save_globals();
		}

		for(secondary_schema=primary_schema->sub_schp; secondary_schema; 
			secondary_schema=secondary_schema->sub_schp)
		{
			if (save_globals_flag)
			{
				RIS_default = secondary_schema;
			}

			for(secondary_id=RIS_parms.max_user_stmts; 
				(unsigned int)secondary_id < (unsigned int)(RIS_parms.max_user_stmts+RIS_max_secondary_stmts);
				secondary_id++)
			{
				if (!RIS_stmts[secondary_id])
				{
					break;
				}
			}
			status = SETJMP();
			if (status)
			{
				RESETJMP();
				if (save_globals_flag)
				{
					RIScli_restore_globals();
				}
				LONGJMP(status);
			}
			RIScli_put_tables_in_hash(stmt_id,primary_schema,secondary_schema);
			if(super_schema)
			{

				RIScli_prepare((short)secondary_id,query,super_schema->schname,
				secondary_schema->schname,primary_stmt_id);
			}
			else
			{
				RIScli_prepare((short)secondary_id,query,0,secondary_schema->schname,
				primary_stmt_id);
			}
			temp->next = RIS_stmts[secondary_id];
			temp = temp->next;
			RESETJMP();
		}

		/*
		** set it to the original default schema, stmt, current_stmt_id
		*/
		if (save_globals_flag)
		{
			RIScli_restore_globals();
		}
	}
	else
	{

	/*
	** translate and generate sql for the secondary schemas and 
	** also for the normal schemas and for the new secondary added
	** because of the redeclare statement.
	*/
		RIStrn_driver();

		RISsql_driver();

/* save the view string for create view */

		if (RIS_stmt->sql->stmt_type == RIS_CREATE_VIEW_STMT)
		{
			len = strlen(query)+1;
			RIS_stmt->view_string = ALLOCB(len);
			memcpy(RIS_stmt->view_string,query,len);
			RIScom_fix_space(RIS_stmt->view_string);
		}

	}
	RESETJMP();

	CLI_DBG(("RIScli_prepare:complete for id = %d\n", RIS_current_stmt_id));
}

/******************************************************************************/

/*
**	Checking the member of superschema and replacing the superschema 
**	with the primary schema in the tree
*/

static void check_replace_superschema(
    ristree *ptr,
	rissuperschema **super_schema,
	risschema **primary_schema)
{
	rissuperschema *super_sch;

	/*
	**	ignore grantee list (or don't return)
	**  schema names for the grant/revoke stmts.
	*/
    if(ptr->tok == RIS_TOK_GRANTEE_LIST)
    {
	 	if (RIScli_can_execute_on_superschema(RIS_stmt->tree->tok))
		{
			/*
			**  Added check for primary_schema to fix TR# 249406854. RAJU
			*/
            if (!(*primary_schema))
				*primary_schema = RIS_default;
		}
		return;
	}
	if(ptr->tok == RIS_TOK_AUTH_ID)
	{
		if(super_sch = RISdic_find_supersch(ptr->info.val))
		{
	 		if (RIScli_can_execute_on_superschema(RIS_stmt->tree->tok))
			{
				ptr->info.val = ALLOCB(RIS_MAX_ID_SIZE);
				strcpy(ptr->info.val, super_sch->sub_schp->schname);
				*super_schema = super_sch;
				*primary_schema = super_sch->sub_schp;
			}
		}
		else
		{
/*
**	Added condition for RIS_TOK_SET to fix TR# 249403158. RAJU 06/21/94
*/
			if (RIS_stmt->tree->tok != RIS_TOK_REDECLARE_SUPERSCHEMA &&
				RIS_stmt->tree->tok != RIS_TOK_UNDECLARE_SUPERSCHEMA &&
				RIS_stmt->tree->tok != RIS_TOK_DECLARE_SUPERSCHEMA &&
				RIS_stmt->tree->tok != RIS_TOK_SET)
			{
				check_for_primary_or_secondary(ptr->info.val);
			}
		}
	}
	if(ptr->lhs)
	{
		check_replace_superschema(ptr->lhs, super_schema, primary_schema);
	}
	if(ptr->rhs)
	{
		check_replace_superschema(ptr->rhs, super_schema, primary_schema);
	}
}

/******************************************************************************/

/*
** Cannot directly prepare on a schema which is involved in a superschema
*/

static void check_for_primary_or_secondary(
	char *sch_name)
{
	risschema *schema;

CLI_DBG(("check_for_primary_or_secondary sch_name <%s>\n", sch_name));

	schema = RISdic_lookup_schema(sch_name,HASH_TABLE);

	if (schema && schema->superschema_flag)
	{
		LONGJMP(RIS_E_CANT_EXECUTE_DIRECT);
	}
}

/******************************************************************************/
/*
**	Replacing the superschema with the primary schema in the tree
*/
/*
static void replace_superschema(
	ristree *tp)
{
	rissuperschema *super_sch;

	CLI_DBG(("replace_superschema(tp:0x%x)\n", tp));

    if(tp->tok == RIS_TOK_GRANTEE_LIST)
    {
		return;
    }
	if(tp->tok == RIS_TOK_AUTH_ID)
	{
		if(super_sch = RISdic_find_supersch(tp->info.val))
		{
			tp->info.val = ALLOCB(RIS_MAX_ID_SIZE);
			strcpy(tp->info.val, super_sch->sub_schp->schname);
		}
	}
	if(tp->lhs)
	{
		replace_superschema(tp->lhs);
	}
	if(tp->rhs)
	{
		replace_superschema(tp->rhs);
	}
	CLI_DBG(("replace_superschema done...\n"));
}
*/
/******************************************************************************/

extern int RIScli_can_execute_on_superschema(
	int tok)
{
	int ret_val=0;

CLI_DBG(("RIScli_can_execute_on_superschema tok %d\n", tok));

    switch(tok)
    {
		case RIS_TOK_CLOSE_SCHEMA:
		case RIS_TOK_CREATE_SCHEMA:
		case RIS_TOK_DROP_SCHEMA:
		case RIS_TOK_OPEN_SCHEMA:
		case RIS_TOK_ALTER_SCHEMA:
		case RIS_TOK_DECLARE_SUPERSCHEMA:
		case RIS_TOK_DECLARE_SCHEMA:
		case RIS_TOK_REDECLARE_SUPERSCHEMA:
		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
		case RIS_TOK_UNDECLARE_SCHEMA:
		case RIS_TOK_SET:
		case RIS_TOK_GRANT_SCHEMA:
		case RIS_TOK_GRANT_CONNECT:
		case RIS_TOK_GRANT_RESOURCE:
		case RIS_TOK_REVOKE_SCHEMA:
		case RIS_TOK_REVOKE_CONNECT:
		case RIS_TOK_REVOKE_RESOURCE:
            ret_val = 0;
        break;

		case RIS_TOK_DEFAULT_SCHEMA:
		case RIS_TOK_CREATE_TABLE:
		case RIS_TOK_CREATE_VIEW:
		case RIS_TOK_DROP_TABLE:
		case RIS_TOK_DROP_VIEW:
		case RIS_TOK_ALTER_TABLE:
		case RIS_TOK_CREATE_INDEX:
		case RIS_TOK_DROP_INDEX:
		case RIS_TOK_GRANT:
		case RIS_TOK_GRANT_ON_TABLE:
		case RIS_TOK_REVOKE:
		case RIS_TOK_REVOKE_ON_TABLE:
		case RIS_TOK_LOCK_TABLES:
		case RIS_TOK_COMMIT:
		case RIS_TOK_ROLLBACK:
		case RIS_TOK_INSERT:
		case RIS_TOK_DELETE:
		case RIS_TOK_UPDATE:
		case RIS_TOK_SELECT:
		case RIS_TOK_EXEC:
		case RIS_TOK_DECLARE_TABLE:
		case RIS_TOK_DECLARE_VIEW:
		case RIS_TOK_UNDECLARE_TABLE:
		case RIS_TOK_UNDECLARE_VIEW:
            ret_val = 1;
		break;
        default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
        break;
    }
	return ret_val;
}

/******************************************************************************/

extern int RIScli_have_privilege(
	int tok)
{
	int ret_val=1;

	CLI_DBG(("RIScli_have_privilege tok %d\n", tok));

	if (RIScom_default_schema_required(RIScom_tok_to_stmt_type(tok)))
	{
		if (!RIS_default)
		{
			LONGJMP(RIS_E_NO_DEFAULT);
		}

		switch(tok)
		{
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_REVOKE_SCHEMA:
				if (RIS_default->privilege == 'D')
				{
					ret_val = 1;
				}
				else
				{
					ret_val = 0;
				}
			break;

			case RIS_TOK_GRANT_RESOURCE:
			case RIS_TOK_REVOKE_RESOURCE:
				if (RIS_default->privilege == 'D' ||
					RIS_default->privilege == 'S')
				{
					ret_val = 1;
				}   
				else
				{
					ret_val = 0;
				}
			break;

			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_REVOKE_CONNECT:
				if (RIS_default->privilege == 'D' ||
					RIS_default->privilege == 'S')
				{
					ret_val = 1;
				}
				else
				{
					ret_val = 0;
				}
			break;
				
			default:
				if (RIScom_is_ddl(RIScom_tok_to_stmt_type(tok)))
				{
					if (RIS_default->privilege == 'D' ||
						RIS_default->privilege == 'S' ||
						RIS_default->privilege == 'R')
					{
						ret_val = 1;
					}
					else
					{
						ret_val = 0;
					}
				}
				else
				{
					if (RIS_default->privilege == 'D' ||
						RIS_default->privilege == 'S' ||
						RIS_default->privilege == 'R' ||
						RIS_default->privilege == 'C')
					{
						ret_val = 1;
					}
					else
					{
						ret_val = 0;
					}
				}
			break;
		}
	CLI_DBG(("RIScli_have_privilege: privilege: <%c>\n",
		RIS_default->privilege))
	}
	CLI_DBG(("RIScli_have_privilege: returning (ret_val: %d)\n", ret_val))
	return ret_val;
}
/******************************************************************************/

				
