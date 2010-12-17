/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comstmt.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/88
**	ABSTRACT:
**	contains the functions that classify statements
**		
**	
**	REVISION HISTORY:
*/
 
#define NO_COM_DBG

/*
**	INCLUDES
*/
#include "ris_err.h"
#include "risdebug.h"
#include "risstjmp.h"
#include "rissttyp.h"

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
#define comstmt_c
#include "comjmp.prt"
#include "comstmt.prt"

/******************************************************************************/

/*
** This function determines if a statement is a DDL statement.
** 1 = yes
** 0 = no
*/

extern int RIScom_is_ddl(
	unsigned char stmt_type)
{
	switch(stmt_type)
	{
		case RIS_ALTER_SCHEMA_STMT:
		case RIS_ALTER_TABLE_STMT:
		case RIS_CREATE_INDEX_STMT:
		case RIS_CREATE_SCHEMA_STMT:
		case RIS_CREATE_TABLE_STMT:
		case RIS_CREATE_VIEW_STMT:
		case RIS_DEFAULT_SCHEMA_STMT:
		case RIS_DECLARE_SCHEMA_STMT:
		case RIS_UNDECLARE_SCHEMA_STMT:
		case RIS_DROP_INDEX_STMT:
		case RIS_DROP_SCHEMA_STMT:
		case RIS_DROP_TABLE_STMT:
		case RIS_DROP_VIEW_STMT:
		case RIS_GRANT_STMT:
		case RIS_GRANT_ON_TABLE_STMT:
		case RIS_GRANT_SCHEMA_STMT:
		case RIS_GRANT_CONNECT_STMT:
		case RIS_GRANT_RESOURCE_STMT:
		case RIS_REVOKE_STMT:
		case RIS_REVOKE_ON_TABLE_STMT:
		case RIS_REVOKE_SCHEMA_STMT:
		case RIS_REVOKE_CONNECT_STMT:
		case RIS_REVOKE_RESOURCE_STMT:
		case RIS_OPEN_SCHEMA_STMT:
		case RIS_CLOSE_SCHEMA_STMT:
		case RIS_EXEC_STMT:
			return(1);
		default:
			return(0);
	}
}

/******************************************************************************/

/*
** This function determines if a DML statement can cause changes to a database.
** 1 = yes
** 0 = no
*/

extern int RIScom_is_update(
	unsigned char stmt_type)
{
	switch(stmt_type)
	{
		case RIS_UPDATE_STMT:
		case RIS_DELETE_STMT:
		case RIS_INSERT_STMT:
			return(1);
		default:
			return(0);
	}
}

/******************************************************************************/

/*
**	returns 1 if default schema is required.
**	returns 0 if default schema is not required.
**	LONGJMPS on error
*/
extern int RIScom_default_schema_required(
	unsigned char stmt_type)
{
	int return_sts = 0;

	COM_DBG(("RIScom_default_schema_required(stmt_type:<%s>)\n",
		RIScom_get_stmt_type_name(stmt_type)));

    switch(stmt_type)
    {
        case RIS_DEFAULT_SCHEMA_STMT:
        case RIS_CREATE_SCHEMA_STMT:
        case RIS_DROP_SCHEMA_STMT:
        case RIS_ALTER_SCHEMA_STMT:
        case RIS_OPEN_SCHEMA_STMT:
        case RIS_CLOSE_SCHEMA_STMT:
        case RIS_SET_STMT:
        case RIS_DECLARE_SUPERSCHEMA_STMT:
        case RIS_REDECLARE_SUPERSCHEMA_STMT:
        case RIS_UNDECLARE_SUPERSCHEMA_STMT:
        case RIS_DECLARE_SCHEMA_STMT:
        case RIS_UNDECLARE_SCHEMA_STMT:
			return_sts = 0;
			break;

        case RIS_CREATE_TABLE_STMT:
        case RIS_CREATE_VIEW_STMT:
        case RIS_DROP_TABLE_STMT:
        case RIS_DROP_VIEW_STMT:
        case RIS_ALTER_TABLE_STMT:
        case RIS_CREATE_INDEX_STMT:
        case RIS_DROP_INDEX_STMT:
		case RIS_GRANT_STMT:
		case RIS_GRANT_ON_TABLE_STMT:
		case RIS_GRANT_SCHEMA_STMT:
		case RIS_GRANT_CONNECT_STMT:
		case RIS_GRANT_RESOURCE_STMT:
		case RIS_REVOKE_STMT:
		case RIS_REVOKE_ON_TABLE_STMT:
		case RIS_REVOKE_SCHEMA_STMT:
		case RIS_REVOKE_CONNECT_STMT:
		case RIS_REVOKE_RESOURCE_STMT:
        case RIS_LOCK_TABLES_STMT:
        case RIS_COMMIT_STMT:
        case RIS_ROLLBACK_STMT:
        case RIS_INSERT_STMT:
        case RIS_DELETE_STMT:
        case RIS_UPDATE_STMT:
        case RIS_SELECT_STMT:
        case RIS_EXEC_STMT:
        case RIS_DECLARE_TABLE_STMT:
        case RIS_DECLARE_VIEW_STMT:
        case RIS_UNDECLARE_TABLE_STMT:
        case RIS_UNDECLARE_VIEW_STMT:
			return_sts = 1;
			break;




		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	COM_DBG(("RIScom_default_schema_required:returning %d\n", return_sts));
	return return_sts;
}

extern int RIScom_can_change_dflt_schema(
	unsigned char stmt_type)
{
	int return_sts = 0;

	COM_DBG(("RIScom_can_change_dflt_schema(stmt_type:<%s>)\n",
		RIScom_get_stmt_type_name(stmt_type)));

    switch(stmt_type)
    {
        case RIS_DEFAULT_SCHEMA_STMT:
        case RIS_CREATE_SCHEMA_STMT:
        case RIS_DROP_SCHEMA_STMT:
        case RIS_ALTER_SCHEMA_STMT:
        case RIS_CLOSE_SCHEMA_STMT:
        case RIS_DECLARE_SUPERSCHEMA_STMT:
        case RIS_DECLARE_SCHEMA_STMT:
        case RIS_UNDECLARE_SCHEMA_STMT:
        case RIS_REDECLARE_SUPERSCHEMA_STMT:
        case RIS_UNDECLARE_SUPERSCHEMA_STMT:
			return_sts = 1;
			break;

		default:
			break;
	}

	COM_DBG(("RIScom_can_change_dflt_schema: returning %d\n", return_sts));

	return return_sts;
}
