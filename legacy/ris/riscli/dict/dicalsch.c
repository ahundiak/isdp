/*
**	NAME:							DICalter_sch.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					7/89
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		10/24/94 - Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "risver.h"
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
#define dicalsch_c
#include "ccooutpt.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "ccover.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comstrng.prt"
#include "dicalsch.prt"
#include "dicclsch.prt"
#include "dicadd.prt"
#include "dicdcsch.prt"
#include "dicdrsch.prt"
#include "dicrem.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dictrans.prt"
#include "dicundss.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "usrsndrc.prt"
#include "usrsrv.prt"
#include "usrkill.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_alter_schema(
	ristree *tp,
	int exec_mode)
{
	risschema		*alter_schema = 0;
	rissuperschema	*ss_schema;
	char			*schname = tp->info.val;
	int 			status;

	if (RISdic_debug)
	{
		RIScom_output_debug("RISdic_alter_schema(tp:0x%x exec_mode:0x%x)", tp, exec_mode);
		RIScom_output_debug("\nschema to alter:<%s>", schname);
		RIScom_output_debug("\ndefault_schema:0x%x <%s>\n", RIS_default,
			RIS_default?RIS_default->schname:"");
		RIScco_output_internal_tree(RIScom_output_debug, tp);
	}

	status = SETJMP();
	if (status)
	{
		RESETJMP();

		if (status != STATEMENT_NOT_COMPLETE)
		{
			RIScco_push_risca_dbca();
	
			RISfil_rollback_schema_transact();
			RISdic_rollback_hash();
	
			RIScco_pop_risca_dbca();
		}
		LONGJMP(status);
	}

	/* if its a superschema don't proceed further */
	if (IN_START_MODE(exec_mode) && (ss_schema=RISdic_find_supersch(schname)))
	{
		LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
	}

	switch (tp->lhs->tok)
	{
		case RIS_TOK_SCHEMA:
			alt_sch_passwd(tp, exec_mode);

			RESETJMP();

			if (IN_FINISH_MODE(exec_mode))
			{
				/*
				** No need to call RISfil_commit_schema_transact
				** since we dont read or update the schema file.
				** (We do call RISdic_open_schema, but it does its 
				** own commit)
				*/

				/*
				** Commit schema password change into the hash table.
				*/
				RISdic_commit_hash();
			}
			break;

		case RIS_TOK_SECURE:
			alt_sch_to_secure(tp, exec_mode);
			RESETJMP();
			if (IN_FINISH_MODE(exec_mode))
			{
				RISfil_commit_schema_transact();
				RISdic_commit_hash();
			}
			break;

		case RIS_TOK_EXCLUDE:
		case RIS_TOK_INCLUDE:
			alt_sch_incl_excl(tp, exec_mode);
			RESETJMP();
			if (IN_FINISH_MODE(exec_mode))
			{
				RISfil_commit_schema_transact();
				RISdic_commit_hash();
			}
		break;

		case RIS_TOK_DB2:

			if (IN_START_MODE(exec_mode))
			{
				alt_sch_db2_passwd(tp);
			}
			RESETJMP();
			if (IN_START_MODE(exec_mode))
			{
				RISdic_commit_hash();
			}
		break;

		case RIS_TOK_REMOTE:
		case RIS_TOK_USER:
		case RIS_TOK_OSUSER:
		case RIS_TOK_MAJOR:
			if (IN_START_MODE(exec_mode))
			{
				alt_remote_user_osuser(tp);

				/*
				**	try to start the server
				*/
				alter_schema = RISdic_open_schema_no_commit(schname, SYNC_MODE);

				/*
				**	We know from the translator that remote will always
				**	be first
				*/
				if (tp->lhs->tok == RIS_TOK_REMOTE)
				{
					/*
					**	update the file with all the known addresses
					*/
					RISfil_update_db(alter_schema->db, PROTADDR_FLAG);
				}
			}

			RESETJMP();

			if (IN_START_MODE(exec_mode))
			{
				RISfil_commit_schema_transact();
				RISdic_commit_hash();
			}
		break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
    DIC_DBG(("RISdic_alter_schema done...\n"));
}

/******************************************************************************/

static risschema *setup_alter_schema_struct(
	char        *schname)
{
	risschema	*sch_tmp;
	risschema	*alter_schema = 0;
	risschema	*schema;

    DIC_DBG(("setup_alter_schema_struct(schname:<%s>)\n",schname));

	/*
	**	Check for other schemas open on the same database
	**  in the hash table.
	*/
	sch_tmp = RISdic_lookup_schema(schname,HASH_TABLE);
	if (sch_tmp)
	{
		for (schema = RIS_srvs; schema; schema = schema->next)
		{
			if (strcmp(sch_tmp->schname, schema->schname) &&
				sch_tmp->dbid == schema->dbid)
			LONGJMP(RIS_E_OPEN_SCHEMAS);
		}
		alter_schema = ALLOCT(risschema);
		memcpy(alter_schema,sch_tmp,sizeof(risschema));
		strcpy(alter_schema->schname,schname);

		/* close the schema and commit if it's open */
		if (!SETJMP()) RISdic_close_schema(schname, SYNC_MODE);
		RESETJMP();
	}
	else
	{
		/*
       	**  Check for other schemas open on the same database
       	**  in the schema file.
       	*/
		sch_tmp = RISdic_lookup_schema(schname,SCHEMA_FILE);
		if (sch_tmp)
		{
			for (schema = RIS_srvs; schema; schema = schema->next)
			{
				if (strcmp(sch_tmp->schname, schema->schname) &&
							sch_tmp->dbid == schema->dbid)
					LONGJMP(RIS_E_OPEN_SCHEMAS);
			}
			alter_schema = ALLOCT(risschema);
		     memcpy(alter_schema,sch_tmp,sizeof(risschema));
		     strcpy(alter_schema->schname,schname);
		}
		else
		{
			LONGJMP(RIS_E_UNKNOWN_SCHEMA);
		}
	}
    DIC_DBG(("setup_alter_schema_struct returning...\n"));
	return (alter_schema);
}

/******************************************************************************/

static void alt_sch_passwd(
	ristree *tp,
	int exec_mode)
{
	risschema	*alter_schema = 0;
	char 		*crpt_schpass;
	char		*schname = tp->info.val;
	char		*old_schpass = tp->rhs->info.val;
	char 		*new_schpass = tp->lhs->info.val;
	risdclrschema  *dschema = 0;
	char        decrpt_schpass[RIS_MAX_ID_SIZE];

	
	DIC_DBG(("alt_sch_passwd(tp:0x%x, exec_mode:0x%x)\n",tp,exec_mode));

	if (IN_START_MODE(exec_mode))
	{
		dschema = RISdic_lookup_risdclrsch(schname);
		if (dschema)
		{
			if (!strlen(old_schpass))
			{
				if (strlen(dschema->schpass))
				{
					RIScom_depd(dschema->schpass, decrpt_schpass);
					old_schpass = decrpt_schpass;
				}
			}
			else if (strlen(dschema->schpass))
			{
				if (!RIScom_pd_same(old_schpass, dschema->schpass))
				{
					LONGJMP(RIS_E_MISMATCH_SCHPASS);
				}
			}
		}

		/* open the schema */
		DIC_DBG(("alt_sch_passwd: opening schema:<%s>\n",schname));
		alter_schema = RISdic_open_schema(schname, SYNC_MODE);

		/* verify the old password */
		DIC_DBG(("alt_sch_passwd: checking the old password\n"));
		if (!RIScom_pd_same(old_schpass, alter_schema->schpass))
		{
/*
**  Changed error to RIS_E_UNKNOWN_SCHEMA to be consistent with RIS 4.3.
**  by checking for application version.
**  This fixes TR# 249406468. RAJU 09/19/94.
**  For V5 application the corresponding error is:
**  LONGJMP(RIS_E_SCHPASS_NOT_SAME);
*/
			if (RIS_app_cli_version < 5)
				LONGJMP(RIS_E_UNKNOWN_SCHEMA);
			else
				LONGJMP(RIS_E_SCHPASS_NOT_SAME);
		}
		DIC_DBG(("alt_sch_passwd: correct password was provided\n"));
	}
	/*
	**	send the new password over
	*/
	DIC_DBG(("alt_sch_passwd: send the new passwd to the server\n"));
	crpt_schpass = ALLOCB(RIS_MAX_PASSWD_SIZE);
	RIScom_pd(new_schpass, crpt_schpass);
	RIS_sdp->query = crpt_schpass;

	if (IN_FINISH_MODE_ONLY(exec_mode))
	{
		alter_schema = RISdic_lookup_schema(schname, HASH_TABLE);
	}

	RIS_sdp->schema = alter_schema;
	RISusr_send_rec(RIS_NEW_SCHPASS_CODE, RIS_sdp, (unsigned short)exec_mode);

	if (IN_FINISH_MODE(exec_mode))
	{
		/*
		** Update the password in memory
		*/
		memcpy(alter_schema->schpass,crpt_schpass, RIS_MAX_PASSWD_SIZE);
	
		/* update the declare schema */
		RISdic_update_declare_schema(schname, 0, new_schpass,
			SCHPASS_FLAG);
	}
	DIC_DBG(("alt_sch_passwd done...\n"));
}

/******************************************************************************/

static void alt_sch_incl_excl(
	ristree *tp,
	int exec_mode)
{
    ristab      *tab;
	risschema	*alter_schema=0;
	char 		*incl_excl_buf = NULL;
	char		*schname = tp->info.val;
	char		*schpass = tp->rhs->info.val;
	unsigned short action = tp->lhs->tok;
	ristree 	*object = tp->lhs->rhs;
	ristree 	*user = tp->lhs->lhs;
	char		*usrname=0;
	risdclrschema  *dschema = 0;
	char        decrpt_schpass[RIS_MAX_ID_SIZE];
 	char        *cptr;
 	ristree		*tptr;
 	int			ccount = 0;
 	ristree     *rentab; 
 	ristree     *rencol; 

	DIC_DBG(("alt_sch_incl_excl(tp:0x%x, exec_mode:0x%x)\n", tp, exec_mode));

	if (IN_START_MODE(exec_mode))
	{
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

		DIC_DBG(("alt_sch_incl_excl: opening schema:<%s>\n",schname));
		alter_schema = RISdic_open_schema(schname, SYNC_MODE);

		if (alter_schema != RIS_default)
		{
			if (!RIScom_pd_same(schpass, alter_schema->schpass))
			{
/*
**  Changed error to RIS_E_UNKNOWN_SCHEMA to be consistent with RIS 4.3.
**  by checking for application version.
**  This fixes TR# 249406468. RAJU 09/19/94.
**  For V5 application the corresponding error is:
**  LONGJMP(RIS_E_SCHPASS_NOT_SAME);
*/
				if (RIS_app_cli_version < 5)
					LONGJMP(RIS_E_UNKNOWN_SCHEMA);
				else
					LONGJMP(RIS_E_SCHPASS_NOT_SAME);
			}
		}

#ifdef LATER
		/*
		** We took this out because we don't make a similar check for drop table
		*/

		/*
		** Check if table is being excluded while other statements are
		** referencing it.
		*/
		if (action == RIS_TOK_EXCLUDE)
		{
			for (i=0;i<HASH_TAB_SIZE;i++)
			{
				hashptr = RIS_hashtab[i];
				while (hashptr)
				{
					if ((hashptr->tree->tok == RIS_TOK_TABLE) && 
						(alter_schema == hashptr->tree->info.tab->schema) &&
						(!strcmp(object->info.val,
							hashptr->tree->info.tab->tabname)) && 
						(hashptr->tree->info.tab->ref_count))
					{
						LONGJMP(RIS_E_TABLE_BEING_REFERENCED);
					}
					hashptr = hashptr->next;
				}
			}
		}
#endif
		/*  SHIVA
		** 	here we need to traverse the tree to first count the
		**	number of columns then allocate enough memory 
		**	to pack them 
		*/

 		rentab = object->lhs;
 		if (rentab) {
 		rencol = object->rhs;
 		/* Traverse down one more node; tree not fully reduced in
 			this region: Shiva (2/25/94) James to look into it ?
 		*/
 		if (rencol) rencol = rencol->rhs;
 		for (ccount = 0, tptr = rencol; 
 				tptr; 
 				++ccount, tptr = tptr->rhs)
 
 		;
 		incl_excl_buf = ALLOCB(((ccount + 1)* RIS_MAX_ID_SIZE));
 		strcpy(incl_excl_buf, rentab->info.val);
 		
 		for (tptr = rencol, cptr = incl_excl_buf+RIS_MAX_ID_SIZE; 
 				tptr; 
 				 tptr = tptr->rhs, cptr += RIS_MAX_ID_SIZE)
 
 			{
 				strcpy (cptr, tptr->lhs->info.val); 
 			}
 		} /* if rentab */

		if (user && user->tok == RIS_TOK_USR_NAME)
		{
			usrname = user->info.val;
		}
		else
		{
			usrname = alter_schema->schown_dbusr;
		}
 		strcpy(RIS_sdp->relowner,usrname); 
 		strcpy(RIS_sdp->relname,object->info.val); 
 		RIS_sdp->input_len = ccount;

		switch(object->tok)
		{
			case RIS_TOK_TABLE:
				RIS_sdp->stmt_type = 'T';
			break;
			case RIS_TOK_VIEW:
 				RIS_sdp->stmt_type = 'V';
			break;
			case RIS_TOK_INDEX:
 				RIS_sdp->stmt_type = 'I';
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}
 		DIC_DBG(("incl_excl_buf: <%s>, ccount<%d>\n",
				incl_excl_buf ? incl_excl_buf : "<EMPTY>" ,ccount));
 		RIS_sdp->query = incl_excl_buf;
	}
	if (IN_FINISH_MODE_ONLY(exec_mode))
	{
		alter_schema = RISdic_lookup_schema(schname, HASH_TABLE);
	}

	if (IN_START_OR_FINISH_MODE(exec_mode))
	{
		char opcode = 0;
		
		if (action == RIS_TOK_INCLUDE)
		{
			opcode = RIS_ALT_SCHEMA_INCLUDE_CODE;
		}
		else if (action == RIS_TOK_EXCLUDE)
		{
			opcode = RIS_ALT_SCHEMA_EXCLUDE_CODE;
		}
		else
		{
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}

		RIS_sdp->schema = alter_schema;
		RISusr_send_rec(opcode, RIS_sdp, (unsigned short)exec_mode);
	}

	if (IN_FINISH_MODE(exec_mode))
	{
		if ((action == RIS_TOK_EXCLUDE) &&
			(object->tok == RIS_TOK_TABLE || object->tok == RIS_TOK_VIEW))
		{
			if (user && user->tok == RIS_TOK_USR_NAME)
			{
				usrname = user->info.val;
			}
			else
			{
				usrname = alter_schema->schowner;
			}
			tab = RISdic_lookup_rel_in_hash(alter_schema, usrname,
				object->info.val, 0);
			if (tab) 
			{
				RISdic_remove_hash(RIS_TOK_TABLE, tab);
			}
		}
	}
	DIC_DBG(("alt_sch_incl_excl done...\n"));
}

/******************************************************************************/

static void alt_sch_db2_passwd(
	ristree *tp)
{
	char 		*old_passwd = tp->lhs->rhs->lhs->info.val;
	char 		*new_passwd = tp->lhs->rhs->rhs->info.val;
	char		*schname = tp->info.val;
	risdb 		alter_db;
	risdb 		*perm_db;
	risschema	*alter_schema;
	risschema	*perm_schema;
	
	alter_schema = setup_alter_schema_struct(schname);

	DIC_DBG(("alt_sch_db2_passwd after setup_alter_schema_struct\n"));

	/*
	**	Gather db information
	*/
	alter_db.dbid = alter_schema->dbid;
	RISfil_get_db(&alter_db, DTYPE_FLAG|DBNAME_FLAG|OSTYPE_FLAG|PARMS_FLAG|PROTADDR_FLAG);
	if (alter_db.dtype != 'D')
	{
		LONGJMP(RIS_E_MUST_BE_DB2_DATABASE);
	}

	/*
	**	Check if the type of database for this schema is enabled
	*/
	RISdic_is_dbms_enabled(alter_db.dtype);

	/*
	**	Check if OLD PASSWORD matches the one in the dictionary.
	*/
	if (!RIScom_pd_same(old_passwd, alter_schema->passwd))
	{
		LONGJMP(RIS_E_WRONG_PASSWORD);
	}

	/* Temporarily change mode value if specified */
	if (tp->lhs->lhs && (tp->lhs->lhs->tok == RIS_TOK_MODE))
	{
		memcpy(alter_db.parms.db2.mode,tp->lhs->lhs->info.val, RIS_MAX_ID_SIZE);
	}

	/* add database to hash table */
	perm_db = RIScco_alloc_risdb();
	memcpy(perm_db, &alter_db, sizeof(risdb));
	RISdic_add_hash(RIS_TOK_DATABASE, perm_db);
	alter_schema->db = perm_db;

	/* Add schema to hash table */
   	perm_schema = RIScco_alloc_risschema();
   	memcpy(perm_schema, alter_schema, sizeof(risschema));
   	RISdic_add_hash(RIS_TOK_SCHEMA, perm_schema);
   	alter_schema = perm_schema;

	/*
	**	Start the server
	**	NOTE:	RISusr_send_rec (which is called by RISusr_server) places
	**			the new password directly in the buffer.
	*/
	RISusr_server(alter_schema, RIS_ALTER_RACF_PWD_CODE, 0);

	/* modify the user passwd */
	RIScom_pd(new_passwd, alter_schema->passwd);

	/*
	** Update the dictionary definition and commit it
	*/
	RISfil_update_schema(alter_schema, SCHOWNPASS_FLAG);
	RISfil_commit_schema_transact();

	/* update the declare schema */
	RISdic_update_declare_schema(schname, 0, new_passwd,
		SCHUSPD_FLAG);

	if (!SETJMP())
	{
		RISusr_kill_srv(alter_schema, CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET,
			SYNC_MODE);
	}
	RESETJMP();

/*
** While killing the server, if we got a RIS_E_SERVER_NOT_RESPONDING error,
** the schema structures would have been cleared. Therefore, we want to
** make sure the schema is still in the hash table before we remove it.
** - Sunil 12/25/92
*/
	alter_schema = RISdic_lookup_schema(schname, HASH_TABLE);

	/* Remove schema and db from hash table */
	if (alter_schema)
	{
		RISdic_remove_hash(RIS_TOK_SCHEMA, alter_schema);
	}
}

/******************************************************************************/

static void alt_remote_user_osuser(
	ristree *tp)
{
	int			i;
	char		*osuser;
	char		*ospass;
	char		*schname = tp->info.val;
	risdb 		alter_db;
	risschema	*alter_schema;
	ristree		*action;

	DIC_DBG(("alt_remote_user_osuser(tp:0x%x)\n", tp));

	alter_schema = setup_alter_schema_struct(schname);

	alter_db.dbid = alter_schema->dbid;
	RISfil_get_db(&alter_db, DTYPE_FLAG|PARMS_FLAG|PROTADDR_FLAG);

	for (action = tp->lhs; action; action = action->lhs)
	{
		switch(action->tok)
		{
			case RIS_TOK_REMOTE:
				/*
				**	modify the pathways
				*/
				for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
				{
					alter_db.pathways[i].protocol =
						action->info.db->pathways[i].protocol;
					memcpy(alter_db.pathways[i].netaddr,
						action->info.db->pathways[i].netaddr,
						RIS_MAX_NODE_SIZE);
				}

				/*
				**	update the file with the user supplied address(es)
				*/
				RISfil_update_db(&alter_db, PROTADDR_FLAG);
			break;

			case RIS_TOK_USER:
				/*
				**	If we are altering a DB2 schema , convert the password
				**	to upper case (since in some cases, IBM converts user
				**	passwords to upper case and our risschema file needs to
				**	be consistent with that.	Modified 2/18/92 - Sunil
				*/
				if (alter_db.dtype == 'D' || alter_db.dtype == '4' ||
					alter_db.dtype == 'O' || alter_db.dtype == 'R')
				{
					RIScom_uppercase(strlen(action->info.val),
				    	 (unsigned char *)action->info.val);
				}

				/* modify the user passwd */
				RIScom_pd(action->info.val, alter_schema->passwd);

				/* update the dictionary definition */
				RISfil_update_schema(alter_schema, SCHOWNPASS_FLAG);

				/* update the declare schema */
				RISdic_update_declare_schema(schname, 0, action->info.val, 
					SCHUSPD_FLAG);

				break;
			
			case RIS_TOK_OSUSER:
				osuser = action->info.val;
				ospass = action->rhs ? action->rhs->info.val : "";
				switch(alter_db.dtype)
				{
					case '4':
						strcpy(alter_db.parms.os400.osuser, osuser);
						RIScom_pd(ospass, alter_db.parms.os400.ospass);
						break;
					case 'O':
						strcpy(alter_db.parms.ora.osuser, osuser);
						RIScom_pd(ospass, alter_db.parms.ora.ospass);
						break;
					case 'D':
						strcpy(alter_db.parms.db2.osuser, osuser);
						RIScom_pd(ospass, alter_db.parms.db2.ospass);
						break;
					case 'Y':
						strcpy(alter_db.parms.syb.osuser, osuser);
						RIScom_pd(ospass, alter_db.parms.syb.ospass);
						break;
                    case 'M':
                        strcpy(alter_db.parms.mssql.osuser, osuser);
                        RIScom_pd(ospass, alter_db.parms.mssql.ospass);
                        break;
					default:
						LONGJMP(RIS_E_INV_FOR_DATABASE);
				}
				RISfil_update_db(&alter_db, PARMS_FLAG);
				
				/* update the declare schema */
				RISdic_update_declare_schema(schname, osuser, ospass,
					OSUSRPD_FLAG);

				break;

			case RIS_TOK_MAJOR:
				if ((alter_schema->major =
					RIScco_ver_str_to_number(action->info.val)) == -2)
				{
					LONGJMP(RIS_E_INVALID_MAJOR_SPEC);
				}
				if (strlen(action->rhs->info.val) > 0 )
				{
					if ((alter_schema->feature =
						RIScco_ver_str_to_number(action->rhs->info.val)) == -2)
					{
						LONGJMP(RIS_E_INVALID_FEATURE_SPEC);
					}
                	if (alter_schema->major == -1 && alter_schema->feature >=0)
					{
						LONGJMP(RIS_E_UNEXPECTED_FEATURE_SPEC);
					}
				}
				else
				{
					alter_schema->feature = -1;
				}
				if (alter_schema->major != -1 &&
					alter_schema->major < RIS_version_maj)
				{
					LONGJMP(RIS_E_CLISRV_INCOMPATIBLE);
				}

				RISfil_update_schema(alter_schema, VERSION_FLAG);
				break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}

	DIC_DBG(("alt_remote_user_osuser: returning\n"));
}

/******************************************************************************/

static void alt_sch_to_secure(
	ristree *tp,
	int exec_mode)
{
	risschema   *alter_schema = 0;
	char        *schname = tp->info.val;
	char		*schpass = tp->rhs->info.val;

	DIC_DBG(("alt_sch_to_secure(tp:0x%x, exec_mode:0x%x)\n",tp,exec_mode));

	if (IN_START_MODE(exec_mode))
	{
		/* open the schema */
		DIC_DBG(("alt_sch_to_secure: opening schema:<%s>\n",schname));
		alter_schema = RISdic_default_schema(schname, schpass,SYNC_MODE);
	}
	/*
	**	send RIS_ALT_TO_SECURE_CODE over
	*/
	DIC_DBG(("alt_sch_to_secure: send TO_SECURE to the server\n"));
	RIS_sdp->schema = alter_schema;
	RISusr_send_rec(RIS_ALT_SCHEMA_SECURE_CODE, RIS_sdp, (unsigned short)exec_mode);

	if (IN_FINISH_MODE(exec_mode))
	{
		if (alter_schema->secure != 'S')
		{
			/* modify the secure in memory */
			alter_schema->secure = 'S';

			/* update the secure in schema file */
			RISfil_update_schema(alter_schema, SECURE_FLAG);

			RISdic_blank_secure_ospass(alter_schema);
		}
	}
	DIC_DBG(("alt_sch_to_secure done...\n"));
}

/******************************************************************************/
