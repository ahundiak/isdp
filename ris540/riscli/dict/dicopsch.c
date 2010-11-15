/*
**	NAME:							dicopsch.c
**	AUTHORS:						Jennifer Xia
**	CREATION DATE:					9/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		add RISdic_add_opsch_user_pass() for V5 schema by Jin Jing 02/94
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "dict.h"

/*
**	DEFINES
*/

#define	NO_COMMIT	0
#define COMMIT		1

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicopsch_c
#include "ccoschid.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "compd.prt"
#include "comstrng.prt"
#include "dicadd.prt"
#include "dictrans.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dicdcsch.prt"
#include "dicundss.prt"
#include "filtrans.prt"
#include "usrsrv.prt"
#include "sys.prt"


/******************************************************************************/
static risschema	*open_schema(
	char	*schname,
	int commit_flag,
	int exec_mode)
{
	int				status;
	risschema		*schema = 0;
	rissuperschema	*ss_schema;
	risschema		*perm_schema;
	risdb			*perm_db;
	static short	schid; /* static so longjmp doesn't change value */

	DIC_DBG(("open_schema(schname:<%s> commit_flag:%d exec_mode:0x%x)\n", 
		STRING(schname), commit_flag, exec_mode));

	schid = -1;
	status = SETJMP();
	if (!status)
	{
    	/* if its a superschema dont proceed further */
		if (IN_START_MODE(exec_mode) &&
			(ss_schema=RISdic_find_supersch(schname)))
    	{
        	LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
    	}

		/*
		**	look for schema in hash table
		*/
		schema = RISdic_lookup_schema(schname, HASH_TABLE);
		if (!schema) 
		{
			if (IN_START_MODE(exec_mode))
			{
				/*
				**  Get the schema id
				*/
				schid = RIScco_new_schema_id(schname);
				/*
				**	look for schema in schema file
				*/
				schema = RISdic_lookup_schema(schname, SCHEMA_FILE);
				if (!schema)
				{
					LONGJMP(RIS_E_UNKNOWN_SCHEMA);
				}
				/*
				**	look for database in hash table
				*/
				schema->db = RISdic_lookup_db(schema->dbid, HASH_TABLE);
				if (!schema->db)
				{
					/*
					**	look for database in schema file
					*/
					schema->db = RISdic_lookup_db(schema->dbid, SCHEMA_FILE);
					if (!schema->db)
					{
						LONGJMP(RIS_E_UNKNOWN_DATABASE);
					}

					/*
					**	add database to hash table
					*/
					perm_db = RIScco_alloc_risdb();
					memcpy(perm_db, schema->db, sizeof(risdb));
					schema->db = perm_db;
					RISdic_add_hash(RIS_TOK_DATABASE, schema->db);
				}
				
		/* check if the type of database for this schema is enabled */
		
				RISdic_is_dbms_enabled(schema->db->dtype);

				/*
				**	create perm risschema, set related parameters, 
				**  and then add schema to hash table
				*/
				perm_schema = RIScco_alloc_risschema();
				memcpy(perm_schema,schema,sizeof(risschema));
				schema = perm_schema;
				schema->schid = schid;

				/*
				** Set default network parameters
				*/
				schema->timestamp.timestamp_interval
					= RIS_timestamp.timestamp_interval;
				schema->timestamp.initial_timeout
					= RIS_timestamp.initial_timeout;
				schema->timestamp.timestamp_tolerance
					= RIS_timestamp.timestamp_tolerance;
				schema->timestamp.buffer_full_size
					= RIS_timestamp.buffer_full_size;
				schema->timestamp.buffer_full_timeout
					= RIS_timestamp.buffer_full_timeout;
				schema->timestamp.response_interval
					= RIS_timestamp.response_interval;
				
				RISdic_add_opsch_user_pass(schema);

				RISdic_add_hash(RIS_TOK_SCHEMA, schema);
				
				/*
				**	start the server
				*/
				RISusr_server(schema, RIS_OPEN_SCHEMA_CODE, 0);
				
				DIC_DBG(("open_schema: schema->DBUSR: <%s>\n",
					schema->dict_dbusr));
			}
			if (IN_FINISH_MODE_ONLY(exec_mode))
			{
				LONGJMP(RIS_E_CANT_OPEN_SCHEMA);
			}
		}
	}
	else
	{
		RESETJMP();
		if (status != STATEMENT_NOT_COMPLETE)
		{
			if (commit_flag)
			{
				RIScco_push_risca_dbca();
/*
** Added an additional check for RIS_E_SERVER_NOT_RESPONDING since
** we dont want to free hash and clear schema id here. It has already
** been done in RISusr_send_rec.
** - Sunil 12/23/92
*/
				if ((status != RIS_E_CANT_OPEN_SCHEMA) &&
					(status != RIS_E_SERVER_NOT_RESPONDING))
				{
					RISdic_rollback_hash();
				}

				RISfil_rollback_schema_transact();

				RIScco_pop_risca_dbca();
			}
			if (schid != -1)
			{
				if (status != RIS_E_SERVER_NOT_RESPONDING)
				{
					if (!SETJMP())
					{
						RIScco_clear_schema_id(schid);
					}
					RESETJMP();
				}
			}
		}
		LONGJMP(status);
	}
	RESETJMP();

	if (IN_FINISH_MODE(exec_mode))
	{
		if (commit_flag)
		{
			RISdic_commit_hash();
			RISfil_commit_schema_transact();
		}
		if (schema)
		{
			schema->ref_by_crnt_stmt = 1;
		}

		DIC_DBG(("open_schema: returning schema:0x%x\n",schema));
		return(schema);
	}
	else
	{
		DIC_DBG(("open_schema: Returning 0 ...\n"));
		return ((risschema *)0);
	}
}

/******************************************************************************/

extern risschema	*RISdic_default_schema(
	char	*schname,
	char	*schpass,
	int 	exec_mode)
{
	risschema		*schema = 0;
	risdclrschema	*dschema = 0;
	char			decrpt_schpass[RIS_MAX_ID_SIZE];

DIC_DBG(("RISdic_default_sch schname = <%s> schpass = <%s>\n",schname,schpass));
	
	dschema = RISdic_lookup_risdclrsch(schname);
	if (dschema)
	{
		if (!strlen(schpass))
		{
			if (strlen(dschema->schpass))
			{
				RIScom_depd(dschema->schpass, decrpt_schpass);
				schpass = decrpt_schpass;
			}	
		}
		else if (strlen(dschema->schpass))
		{
			if (!RIScom_pd_same(schpass, dschema->schpass))
			{
				LONGJMP(RIS_E_MISMATCH_SCHPASS);
			}
		}
	}

	schema = RISdic_open_schema(schname, exec_mode);

/* check the password if necessary */

	if (IN_FINISH_MODE(exec_mode))
	{
		if (!RIScom_pd_same(schpass, schema->schpass))
		{
/*
**	Changed error to RIS_E_UNKNOWN_SCHEMA to be consistent with RIS 4.3.
**  by checking for application version.
**	This fixes TR# 249406468. RAJU 09/19/94.
**  For V5 application the corresponding error is:
**	LONGJMP(RIS_E_SCHPASS_NOT_SAME);
*/
			if (RIS_app_cli_version < 5)
				LONGJMP(RIS_E_UNKNOWN_SCHEMA);
			else
				LONGJMP(RIS_E_SCHPASS_NOT_SAME);
		}
		RIS_default = schema;
		return(schema);
	}
	else
	{
		return(schema);
	}
}

/******************************************************************************/

extern void RISdic_open_mult_schemas(
	ristree * tp,
	int exec_mode)
{

DIC_DBG(("RISdic_open_mult_schemas tp = 0x%x exec_mode = 0x%x\n",tp,exec_mode));

	for (tp=tp->rhs;tp;tp=tp->rhs)
	{
		if (tp->rhs)
		{
			if (IN_START_MODE(exec_mode))
			{
				RISdic_open_schema(tp->lhs->info.val, SYNC_MODE);
			}
		}
		else
		{
			RISdic_open_schema(tp->lhs->info.val, exec_mode);
		}
	}
}

/******************************************************************************/

extern risschema	*RISdic_open_schema(
	char	*schname,
	int 	exec_mode)
{
	DIC_DBG(("RISdic_open_schema(schname:<%s> exec_mode:0x%x)\n", 
		schname,exec_mode));
	return(open_schema(schname, COMMIT, exec_mode));
}

/******************************************************************************/

extern risschema	*RISdic_open_schema_no_commit(
	char	*schname,
	int 	exec_mode)
{
	DIC_DBG(("RISdic_open_schema_no_commit(schname:<%s> exec_mode:0x%x)\n", 
		schname, exec_mode));
	return(open_schema(schname, NO_COMMIT, exec_mode));
}

/******************************************************************************/

extern void RISdic_is_dbms_enabled(
	char db_type)
{

DIC_DBG(("RISdic_is_dbms_enabled(db_type:<%c>)\n",db_type));

    switch (db_type)
	{
    	case 'X':
        	if (!IS_INFORMIX_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'I':
        	if (!IS_INGRES_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'O':
        	if (!IS_ORACLE_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'D':
        	if (!IS_DB2_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'R':
        	if (!IS_RDB_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'S':
        	if (!IS_SQLDS_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'A':
        	if (!IS_ADABAS_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'Y':
        	if (!IS_SYBASE_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case 'M':
        	if (!IS_MSSQL_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
    	case '4':
        	if (!IS_OS400_ENABLED(RIS_enable_dbms))
			{
				LONGJMP(RIS_E_DBMS_MODE_INCORRECT);
			}
		break;
		default:
        	LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
    }
}

/******************************************************************************/

extern void RISdic_check_open_sch (
	unsigned int enabled_dbms)
{
	risschema *schema;

DIC_DBG(("RISdic_check_open_sch: enabled 0x%x\n",enabled_dbms));

	for (schema = RIS_srvs; schema ; schema=schema->next)
	{
		switch (schema->db->dtype)
		{
			case 'X':
				if (!IS_INFORMIX_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'I':
				if (!IS_INGRES_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'O':
				if (!IS_ORACLE_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'D':
				if (!IS_DB2_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'R':
				if (!IS_RDB_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'S':
				if (!IS_SQLDS_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'A':
				if (!IS_ADABAS_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'Y':
				if (!IS_SYBASE_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case 'M':
				if (!IS_MSSQL_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			case '4':
				if (!IS_OS400_ENABLED(enabled_dbms))
				{
					LONGJMP(RIS_E_OTHER_OPEN_SCHEMAS);
				}
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
}

/******************************************************************************/

extern void RISdic_add_opsch_user_pass(
	risschema       *schema)
{
	risdclrschema   *dschema;
	char            *osuser = 0;
	char            *ospass = 0;
	risdb           *dp = schema->db;
	char			usrpass[RIS_MAX_PASSWD_SIZE];

	DIC_DBG(("RISdic_add_opsch_user_pass(schema:0x%x)\n", schema));

	dschema = RISdic_lookup_risdclrsch(schema->schname);
	if (!dschema)
	{
		if (schema->secure == 'S')
		{
			LONGJMP(RIS_E_NEED_DECLARE_SCHEMA);
		}
	}
	else
	{
		if ((strlen(dschema->schuser)) && 
			(dp->dtype == 'D' || dp->dtype == '4' ||
			 dp->dtype == 'O' || dp->dtype == 'R'))
		{
			RIScom_uppercase(strlen(dschema->schuser),
				(unsigned char *)(dschema->schuser));
		}
		if ((strlen(dschema->schuserpd)) &&
			(dp->dtype == 'D' || dp->dtype == '4' ||
			 dp->dtype == 'O' || dp->dtype == 'R'))
	 	{
			RIScom_depd(dschema->schuserpd, usrpass);
			RIScom_uppercase(strlen(usrpass), (unsigned char *)(usrpass));
			RIScom_pd(usrpass, dschema->schuserpd);
		}

		/*
		** Check schuser
		*/
		if (schema->secure == 'S')
		{
			if (strlen(dschema->schuser))
			{
				strcpy(schema->login, dschema->schuser);
				strcpy(schema->loginpd, dschema->schuserpd);
				strcpy(schema->passwd, dschema->schuserpd);
			}
			else
			{
				LONGJMP(RIS_E_NEED_DECLARE_SCHEMA);
			}
		}
		else
		{
			if (strlen(dschema->schuser))
			{
				if (strcmp(dschema->schuser, schema->schowner) ||
					RIScom_pdcmp(dschema->schuserpd, schema->passwd))
				{
					LONGJMP(RIS_E_INCONSISTENT_LOGIN_PD);
				}
			}
		}

		/*
		** Check osuser
		*/
		switch(dp->dtype)
		{
			case '4':
				osuser = dp->parms.os400.osuser;
				ospass = dp->parms.os400.ospass;
			break;
			case 'O':
				osuser = dp->parms.ora.osuser;
				ospass = dp->parms.ora.ospass;
			break;
			case 'D':
				osuser = dp->parms.db2.osuser;
				ospass = dp->parms.db2.ospass;
			break;
			case 'Y':
				osuser = dp->parms.syb.osuser;
				ospass = dp->parms.syb.ospass;
			break;
			case 'M':
				osuser = dp->parms.mssql.osuser;
				ospass = dp->parms.mssql.ospass;
			break;
			default:
			break;
		}

		if (dp->dtype == 'O' || dp->dtype == 'D' || dp->dtype == 'Y' || 
			dp->dtype == 'M' || dp->dtype == '4')
		{
			if (schema->secure == 'S')
			{
				if (strlen(dschema->osuser))
				{
					strcpy(osuser, dschema->osuser);
					strcpy(ospass, dschema->osuserpd);
				}
				else
				{
					LONGJMP(RIS_E_NEED_DECLARE_SCHEMA_OSUSER);
				}
				/*if (strlen(dschema->osuser))
				{
					if (strcmp(dschema->osuser, osuser) ||
						(strlen(ospass) && 
							RIScom_pdcmp(dschema->osuserpd, ospass)))
					{
						LONGJMP(RIS_E_INCONSISTENT_OSUSER_PD);
					}
					strcpy(ospass, dschema->osuserpd);
				}
				else if (!strlen(ospass))
				{
					LONGJMP(RIS_E_NEED_DECLARE_SCHEMA_OSUSER);
				}*/
			}
			else
			{
				if (strlen(dschema->osuser))
				{
					if (strcmp(dschema->osuser, osuser) ||
						RIScom_pdcmp(dschema->osuserpd, ospass))
					{
						LONGJMP(RIS_E_INCONSISTENT_OSUSER_PD);
					}
				}
			}
		}
	}

	/*
	**  set login for non-secure schema
	*/
	if (schema->secure != 'S')
	{
		strcpy(schema->login, schema->schowner);
		strcpy(schema->loginpd, schema->passwd);
	}
	DIC_DBG(("RISdic_add_opsch_user_pass: returning.\n"));
}

/******************************************************************************/
