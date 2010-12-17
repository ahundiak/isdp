/*
**	NAME:							diccrsch.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					11/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		add RISdic_add_crsch_user_pass() for V5 schema by Jin Jing 02/94
**		10/24/94 - Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "dict.h"

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
#define diccrsch_c
#include "ccocmpar.prt"
#include "ccoschid.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comstrng.prt"
#include "dicdcsch.prt"
#include "diccrsch.prt"
#include "dicgrnte.prt"
#include "dicadd.prt"
#include "dictrans.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dicundss.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "usrsndrc.prt"
#include "usrdb.prt"
#include "usrsrv.prt"
#include "usrkill.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_create_schema(
	ristree *tp,
	int exec_mode)
{
	int				status;
	int				new_ifx_db = 0;
	int				new_ifx_user = 0;
	int				cre_sch_options_flag = 0;
	risdb			*db;
	risdb			*perm_db;
	risschema		*schema = 0;
	rissuperschema	*ss_schema;
	risschema		*perm_schema;
	char			ospass[RIS_MAX_PASSWD_SIZE];
		
	DIC_DBG(("RISdic_create_schema(tp:0x%x exec_mode:%d)\n", tp, exec_mode));

/* make copies of the schema, the database and the access structs in permanent
   memory */

	if (exec_mode & START_MODE)
	{
		schema = tp->info.schema;

    	/* if its a superschema dont proceed further */
    	if ((ss_schema=RISdic_find_supersch(schema->schname)))
    	{
        	LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
    	}
		
		/*
		** Verify user_passwd against declared schema
		*/
		RISdic_add_crsch_user_pass(schema);
		
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
		
		/*
		** Set schema->dictowner (dictionary owner), if not specified
		*/
		if (!strlen(schema->dictowner))
		{
			strcpy(schema->dictowner, schema->schowner);
		}
		else
		{
			cre_sch_options_flag |= CRE_SCH_USING_FLAG;
			/* 
			** temporary storage for using flag and effective until 
			** create schema OPCODE executed
			*/
			schema->privilege = cre_sch_options_flag;
		}
		
		schema->schid = RIScco_new_schema_id(schema->schname);
	}
	
	status = SETJMP();
	if (status)
	{
		RESETJMP();
		if (status != STATEMENT_NOT_COMPLETE)
		{
			RIScco_push_risca_dbca();
/*
** Added a check for RIS_E_SERVER_NOT_RESPONDING since we dont want to 
** remove hash, kill server and clear schema id for this error. It would 
** have already been done in RISusr_send_rec. - Sunil 12/23/92
*/
			if (status != RIS_E_SERVER_NOT_RESPONDING)
			{
				RISdic_rollback_hash();
			}
			RISfil_rollback_schema_transact();
			if (status != RIS_E_SERVER_NOT_RESPONDING)
			{
				DIC_DBG(("schema->net = %d\n",schema->net));
				if (schema->net)
				{
					/* 
					** kill the server
					*/
					if (!SETJMP())
					{
						RISusr_kill_srv(schema,
							CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET, SYNC_MODE);
					}
					RESETJMP();
				}
				if (!SETJMP())
				{
					RIScco_clear_schema_id(schema->schid);
				}
				RESETJMP();
			}	
			RIScco_pop_risca_dbca();
		}
		LONGJMP(status);
	}

	if (exec_mode & START_MODE)
	{
		/* Added cre_sch_options_flag 
		   by Jin 11/29/93 for both force and include/exclude clause */

		if ((tp->rhs) && (tp->rhs->tok == RIS_TOK_FORCE))
		{
			cre_sch_options_flag |= CRE_SCH_FORCE_FLAG;
		}
		if ((tp->rhs) && (tp->rhs->tok == RIS_TOK_EXCLUDE))
		{
			cre_sch_options_flag |= CRE_SCH_EXCLUDE_FLAG;
		}
		if ((tp->rhs) && (tp->rhs->tok == RIS_TOK_ALL))
		{
			cre_sch_options_flag |= CRE_SCH_FORCE_FLAG | CRE_SCH_EXCLUDE_FLAG;
		}

		DIC_DBG(("RISdic_create_schema: cre_sch_options_flag %d)\n", 
			cre_sch_options_flag));
/* check if the type of database for the schema is enabled */

    	RISdic_is_dbms_enabled(schema->db->dtype);

		if (!RIS_default || RIS_default->db != schema->db)
		{

/* db clause */

DIC_DBG(("on database clause\n"));

			if (schema->db->dtype == 'X')
			{
				risifxparms	*ifxp = &schema->db->parms.ifx;
				char *str;
				int  first_usable_protocol_index=0;

				if (!RISusr_db_on_remote_machine(schema->db,
					&first_usable_protocol_index))
				{
					if (!*ifxp->dir)
					{
						str = getenv("INFORMIXDIR");
						if (str)
						{

DIC_DBG(("RISdic_create_schema:got $INFORMIXDIR:<%s>\n",str));

							strcpy(ifxp->dir,str);
						}
					}

					if (!*ifxp->tbconfig)
					{
						str = getenv("TBCONFIG");
						if (str)
						{

DIC_DBG(("RISdic_create_schema:got $TBCONFIG:<%s>\n",str));

							strcpy(ifxp->tbconfig,str);
						}
					}

					if (!*ifxp->dbtemp)
					{
						str = getenv("DBTEMP");
						if (str)
						{

DIC_DBG(("RISdic_create_schema:got $DBTEMP:<%s>\n",str));

							strcpy(ifxp->dbtemp,str);
						}
					}

					if (!*ifxp->sqlexec)
					{
						str = getenv("SQLEXEC");
						if (str)
						{

DIC_DBG(("RISdic_create_schema:got $SQLEXEC:<%s>\n",str));

							strcpy(ifxp->sqlexec,str);
						}
					}
				}
	
				if (ifxp->new_database)
				{
					new_ifx_db = 1;
				}

				if (ifxp->new_user || ifxp->new_resource_user)
				{
					new_ifx_user = ACC_RESOURCE;
				}
				else if (ifxp->new_dba_user)
				{
					new_ifx_user = ACC_DBA;
				}
			}

			if (!(status = SETJMP()))
			{
				RISfil_put_db(schema->db);

/* db clause - db not defined */

DIC_DBG(("database not defined\n"));

				RESETJMP();
				schema->dbid = schema->db->dbid;
				RISfil_put_schema(schema);

/* add database to hash table */
/* allocate tree node in permanent memory */
				perm_db = RIScco_alloc_risdb();
				memcpy(perm_db, schema->db, sizeof(risdb));
				schema->db = perm_db;
				RISdic_add_hash(RIS_TOK_DATABASE, schema->db);

/* add schema to hash table */
/* allocate tree node in permanent memory */
				perm_schema = RIScco_alloc_risschema();
				memcpy(perm_schema, schema, sizeof(risschema));
				schema = perm_schema;
				RISdic_add_hash(RIS_TOK_SCHEMA, schema);

/* if trying to create a new informix db then send create database code instead
   of create schema code */

				if (new_ifx_db)
				{
					RISusr_server(schema, RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE,
						cre_sch_options_flag);
				}
				else
				{
					RISusr_server(schema, RIS_CRE_SCH_GET_GRANTEES_CODE,
						cre_sch_options_flag);
				}
				RISfil_update_db(schema->db, PROTADDR_FLAG);
				
				/* if secure schema, null out the ospass */
				if (schema->secure == 'S')
				{
					switch (schema->db->dtype)
					{
						case '4':
							schema->db->parms.os400.ospass[0] = '\0';
						break;
						case 'O':
							schema->db->parms.ora.ospass[0] = '\0';
						break;
						case 'D':
							schema->db->parms.db2.ospass[0] = '\0';
						break;
						case 'Y':
							schema->db->parms.syb.ospass[0] = '\0';
						break;
						case 'M':
							schema->db->parms.mssql.ospass[0] = '\0';
						break;
						default:
						break;
					}
				}
				RISfil_update_db(schema->db, PARMS_FLAG);
			}
			else
			{
				RESETJMP();
				if (status == RIS_E_DUP_DATABASE)
				{

/* db clause - db defined */

DIC_DBG(("database already defined\n"));

                    /* if standard schema, set the ospass */
                    /* FIX TR 249407608 James. 12-16-94
                        We should save opass for secure schema not standard
                        schema  */
                    if (schema->secure == 'S')
					{
						switch (schema->db->dtype)
						{
							case '4':
								strcpy(ospass, schema->db->parms.os400.ospass);
							break;
							case 'O':
								strcpy(ospass, schema->db->parms.ora.ospass);
							break;
							case 'D':
								strcpy(ospass, schema->db->parms.db2.ospass);
							break;
							case 'Y':
								strcpy(ospass, schema->db->parms.syb.ospass);
							break;
							case 'M':
								strcpy(ospass, schema->db->parms.mssql.ospass);
							break;
							default:
							break;
						}
					}
					
					schema->dbid = schema->db->dbid;
					RISfil_put_schema(schema);
					db = RISdic_lookup_db(schema->dbid, HASH_TABLE);
					if (db)
					{
						if (RIScco_compare_dbs(schema->db,db,ALL_PARMS)==DIFF_DATABASE)
						{
							LONGJMP(RIS_E_INCONSISTENT_DBPARMS);
						}
						schema->db = db;
					}
					else
					{

/* get database from schema file to ensure consistency */

						db = ALLOCT(risdb);
						db->dbid = schema->db->dbid;
						RISfil_get_db(db,
							DTYPE_FLAG|DBNAME_FLAG|OSTYPE_FLAG|PARMS_FLAG|PROTADDR_FLAG);
						if(RIScco_compare_dbs(schema->db,db,ALL_PARMS)==DIFF_DATABASE)
						{
							LONGJMP(RIS_E_INCONSISTENT_DBPARMS);
						}
						schema->db = db;

						perm_db = RIScco_alloc_risdb();
						memcpy(perm_db, schema->db, sizeof(risdb));
						schema->db = perm_db;
						RISdic_add_hash(RIS_TOK_DATABASE, schema->db);
					}

                    /* if standard schema, set the ospass */
                    /* FIX TR 249407608 James. 12-16-94
                        We should save opass for secure schema not standard
                        schema  */

                    if (schema->secure == 'S')
					{
						switch (schema->db->dtype)
						{
							case '4':
								strcpy(schema->db->parms.os400.ospass, ospass);
							break;
							case 'O':
								strcpy(schema->db->parms.ora.ospass, ospass);
							break;
							case 'D':
								strcpy(schema->db->parms.db2.ospass, ospass);
							break;
							case 'Y':
								strcpy(schema->db->parms.syb.ospass, ospass);
							break;
							case 'M':
								strcpy(schema->db->parms.mssql.ospass, ospass);
							break;
							default:
							break;
						}
					}
					RISfil_update_db(schema->db, PARMS_FLAG);

/* add schema to hash table */
/* allocate tree node in permanent memory */

					perm_schema = RIScco_alloc_risschema();
					memcpy(perm_schema, schema, sizeof(risschema));
					schema = perm_schema;
					RISdic_add_hash(RIS_TOK_SCHEMA,schema);

/* if trying to create a new user on the same informix db as the default schema
   then send create user code */

					if (new_ifx_user)
					{
						if (RIS_default && RIS_default->db == schema->db)
						{
							RIS_sdp->schema = RIS_default;
							RIS_sdp->query = ALLOCB(RIS_MAX_ID_SIZE+1);
							if (new_ifx_user == ACC_DBA)
							{
								(RIS_sdp->query)[0] = 'D';
							}
							else
							{
								(RIS_sdp->query)[0] = 'R';
							}
							strcpy(RIS_sdp->query+1,schema->schowner);
							RISusr_send_rec(RIS_CREATE_USER_CODE,RIS_sdp,SYNC_MODE);
						}
						else
						{
							LONGJMP(RIS_E_CANT_CREATE_USER);
						}
					}
					RISusr_server(schema, RIS_CRE_SCH_GET_GRANTEES_CODE,
						cre_sch_options_flag);
				}
				else
				{
					LONGJMP(status);
				}
			}
		}
		else
		{

/* default - db defined */

			/* if standard schema, set ospass */
			if (schema->secure != 'S')
			{
				RISfil_update_db(schema->db, PARMS_FLAG);
			}
					
			schema->dbid = schema->db->dbid;
			RISfil_put_schema(schema);

/* add schema to hash table */
/* allocate tree node in permanent memory */

			perm_schema = RIScco_alloc_risschema();
			memcpy(perm_schema, schema, sizeof(risschema));
			schema = perm_schema;
			RISdic_add_hash(RIS_TOK_SCHEMA, schema);
		
			RISusr_server(schema, RIS_CRE_SCH_GET_GRANTEES_CODE,
				cre_sch_options_flag);
		}

/* update grantees */
		RISdic_update_grantees(schema, CREATE_SCHEMA, SYNC_MODE);

		/*
		**	once the grantee list has been added to the file, remove the grantee
		**	list from schema.  This is done because the list was not allocated
		**	in permanent memory, so once the statment is complete, grantee
		**	will point to an invalid address.
		*/
		schema->grantee = 0;

/* set default schema */
		RIS_default = schema;

		RISdic_commit_hash();
		RISfil_commit_schema_transact();
	}
	RESETJMP();

	DIC_DBG(("RISdic_create_schema complete ...\n"));
}

/******************************************************************************/

extern void RISdic_add_crsch_user_pass(
	risschema   	*schema)
{
	risdclrschema	*dschema;
	char			*osuser = 0;
	char			*ospass = 0;
	risdb			*dp = schema->db;				
	char			usrpass[RIS_MAX_PASSWD_SIZE];

	DIC_DBG(("RISdic_add_crsch_user_pass(schema:0x%x)\n", schema));

	dschema = RISdic_lookup_risdclrsch(schema->schname);
	DIC_DBG(("RISdic_add_crsch_user_pass(dschema:0x%x)\n", dschema));
	if (!dschema)
	{
		/*
		** Check schowner
		*/
		if (!strlen(schema->schowner))
		{
			LONGJMP(RIS_E_CANT_CRE_SCH_WITHOUT_CREATOR);
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
			if (!strlen(osuser))
			{
				LONGJMP(RIS_E_CANT_CRE_SCH_WITHOUT_OSUSER);
			}
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
		** Check schpass
		*/
		if (!strlen(schema->schpass))
		{
			if (strlen(dschema->schpass))
			{
				strcpy(schema->schpass, dschema->schpass);
			}
		}
		else if (strlen(dschema->schpass))
		{
			if (RIScom_pdcmp(dschema->schpass, schema->schpass))
			{
				LONGJMP(RIS_E_MISMATCH_SCHPASS);
			}
		}		
		
		/*
		** Check schowner
		*/
		DIC_DBG(("RISdic_add_crsch_user_pass: schuser <%s> schowner <%s>\n", 
			dschema->schuser, schema->schowner));
		DIC_DBG(("RISdic_add_crsch_user_pass: schuserpd <%s> passwd <%s>\n", 
			dschema->schuserpd, schema->passwd));
		if (!strlen(schema->schowner))
		{
			if (strlen(dschema->schuser))
			{
				strcpy(schema->schowner, dschema->schuser);
				strcpy(schema->passwd, dschema->schuserpd);
			}
			else
			{
				LONGJMP(RIS_E_CANT_CRE_SCH_WITHOUT_CREATOR);
			}
		}
		else if (strlen(dschema->schuser))
		{
			if (strcmp(schema->schowner, dschema->schuser) ||
				RIScom_pdcmp(dschema->schuserpd, schema->passwd))
			{
				LONGJMP(RIS_E_MISMATCH_USER_PASS);
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

		DIC_DBG(("RISdic_add_crsch_user_pass: dschema->osuser <%s> osuser <%s>\n", 			dschema->osuser, osuser));
		DIC_DBG(("RISdic_add_crsch_user_pass: dschema->osuserpd <%s> ospass <%s>\n", 
			dschema->osuserpd, ospass));
		if (dp->dtype == 'O' || dp->dtype == 'D' || dp->dtype == 'Y' || 
			dp->dtype == 'M' || dp->dtype == '4')
		{
			if (!strlen(osuser))
			{
				if (strlen(dschema->osuser))
				{
					strcpy(osuser, dschema->osuser);
					strcpy(ospass, dschema->osuserpd);
				}
				else
				{
					LONGJMP(RIS_E_CANT_CRE_SCH_WITHOUT_OSUSER);
				}
			}
			else if (strlen(dschema->osuser))
			{
				if (schema->secure == 'S')
				{
					strcpy(osuser, dschema->osuser);
					strcpy(ospass, dschema->osuserpd);
				}
				else if (strcmp(osuser, dschema->osuser) ||
					RIScom_pdcmp(dschema->osuserpd, ospass))
				{
					LONGJMP(RIS_E_MISMATCH_OSUSER_OSPASS);
				}
			}
		}
	}
	strcpy(schema->login, schema->schowner);
	strcpy(schema->loginpd, schema->passwd);
	DIC_DBG(("RISdic_add_crsch_user_pass: returning.\n"));
}

/******************************************************************************/
