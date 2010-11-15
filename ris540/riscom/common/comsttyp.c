/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comsttyp.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ris_err.h"
#include "risdebug.h"
#include "risstjmp.h"
#include "rissttyp.h"
#include "ristoken.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comsttyp_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "comsttyp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern char RIScom_tok_to_stmt_type(
	int tok)
{
	char	return_value = 0;

	COM_DBG(("RIScom_tok_to_stmt(tok:<%s>)\n", RIScom_get_token_name(tok)));

	switch(tok)
	{
		case RIS_TOK_ALTER_SCHEMA:
			return_value = RIS_ALTER_SCHEMA_STMT;
			break;
		case RIS_TOK_ALTER_TABLE:
			return_value = RIS_ALTER_TABLE_STMT;
			break;
		case RIS_TOK_CLOSE_SCHEMA:
			return_value = RIS_CLOSE_SCHEMA_STMT;
			break;
		case RIS_TOK_COMMIT:
			return_value = RIS_COMMIT_STMT;
			break;
		case RIS_TOK_CREATE_INDEX:
			return_value = RIS_CREATE_INDEX_STMT;
			break;
		case RIS_TOK_CREATE_SCHEMA:
			return_value = RIS_CREATE_SCHEMA_STMT;
			break;
		case RIS_TOK_CREATE_TABLE:
			return_value = RIS_CREATE_TABLE_STMT;
			break;
		case RIS_TOK_CREATE_VIEW:
			return_value = RIS_CREATE_VIEW_STMT;
			break;
		case RIS_TOK_DECLARE_SUPERSCHEMA:
			return_value = RIS_DECLARE_SUPERSCHEMA_STMT;
			break;
		case RIS_TOK_DECLARE_SCHEMA:
			return_value = RIS_DECLARE_SCHEMA_STMT;
			break;
		case RIS_TOK_DECLARE_TABLE:
			return_value = RIS_DECLARE_TABLE_STMT;
			break;
		case RIS_TOK_DECLARE_VIEW:
			return_value = RIS_DECLARE_VIEW_STMT;
			break;
		case RIS_TOK_DEFAULT_SCHEMA:
			return_value = RIS_DEFAULT_SCHEMA_STMT;
			break;
		case RIS_TOK_DELETE:
			return_value = RIS_DELETE_STMT;
			break;
		case RIS_TOK_DROP_INDEX:
			return_value = RIS_DROP_INDEX_STMT;
			break;
		case RIS_TOK_DROP_SCHEMA:
			return_value = RIS_DROP_SCHEMA_STMT;
			break;
		case RIS_TOK_DROP_TABLE:
			return_value = RIS_DROP_TABLE_STMT;
			break;
		case RIS_TOK_DROP_VIEW:
			return_value = RIS_DROP_VIEW_STMT;
			break;
		case RIS_TOK_EXEC:
			return_value = RIS_EXEC_STMT;
			break;
		case RIS_TOK_GRANT:
			return_value = RIS_GRANT_STMT;
			break;
		case RIS_TOK_GRANT_ON_TABLE:
			return_value = RIS_GRANT_ON_TABLE_STMT;
			break;
		case RIS_TOK_GRANT_SCHEMA:
			return_value = RIS_GRANT_SCHEMA_STMT;
			break;
		case RIS_TOK_GRANT_CONNECT:
			return_value = RIS_GRANT_CONNECT_STMT;
			break;
		case RIS_TOK_GRANT_RESOURCE:
			return_value = RIS_GRANT_RESOURCE_STMT;
			break;
		case RIS_TOK_INSERT:
			return_value = RIS_INSERT_STMT;
			break;
		case RIS_TOK_LOCK_TABLES:
			return_value = RIS_LOCK_TABLES_STMT;
			break;
		case RIS_TOK_OPEN_SCHEMA:
			return_value = RIS_OPEN_SCHEMA_STMT;
			break;
		case RIS_TOK_REDECLARE_SUPERSCHEMA:
			return_value = RIS_REDECLARE_SUPERSCHEMA_STMT;
			break;
		case RIS_TOK_REVOKE:
			return_value = RIS_REVOKE_STMT;
			break;
		case RIS_TOK_REVOKE_ON_TABLE:
			return_value = RIS_REVOKE_ON_TABLE_STMT;
			break;
		case RIS_TOK_REVOKE_SCHEMA:
			return_value = RIS_REVOKE_SCHEMA_STMT;
			break;
		case RIS_TOK_REVOKE_CONNECT:
			return_value = RIS_REVOKE_CONNECT_STMT;
			break;
		case RIS_TOK_REVOKE_RESOURCE:
			return_value = RIS_REVOKE_RESOURCE_STMT;
			break;
		case RIS_TOK_ROLLBACK:
			return_value = RIS_ROLLBACK_STMT;
			break;
		case RIS_TOK_SELECT:
			return_value = RIS_SELECT_STMT;
			break;
		case RIS_TOK_SET:
			return_value = RIS_SET_STMT;
			break;
		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			return_value = RIS_UNDECLARE_SUPERSCHEMA_STMT;
			break;
		case RIS_TOK_UNDECLARE_SCHEMA:
			return_value = RIS_UNDECLARE_SCHEMA_STMT;
			break;
		case RIS_TOK_UNDECLARE_TABLE:
			return_value = RIS_UNDECLARE_TABLE_STMT;
			break;
		case RIS_TOK_UNDECLARE_VIEW:
			return_value = RIS_UNDECLARE_VIEW_STMT;
			break;
		case RIS_TOK_UPDATE:
			return_value = RIS_UPDATE_STMT;
			break;
		default:
			COM_DBG(("RIScom_tok_to_stmt:ERROR: invalid token %d\n", tok));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	COM_DBG(("RIScom_tok_to_stmt:returning <%s>\n",
		RIScom_get_stmt_type_name(return_value)));

	return return_value;
}

extern char *RIScom_get_stmt_type_name(
	char	stmt_type)
{
	COM_DBG(("RIScom_get_stmt_type_name(stmt_type:%d)\n", stmt_type));

	if (stmt_type < RIS_UNUSED_STMT || stmt_type >= RIS_LAST_STMT)
	{
		COM_DBG(("RIScom_get_stmt_type_name:ERROR: invalid stmt_type\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	return RIS_stmt_type_names[stmt_type];
}
