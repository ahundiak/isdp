/*
**	NAME:							dicdrsch.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		add RISdic_blank_secure_ospass() for V5 schema by Jin Jing 02/94
**		10/24/94 - Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_pa.h"
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
static risschema *save_default_schema;

/*
**	FUNCTIONS
*/

/*
** 	TYPES
*/
typedef struct RISdic_access_struct
{
    struct RISdic_access_struct *next;
    risaccess                   *list;
    int                         list_len;
} RISdic_access_struct;

/*
**      FUNCTION PROTOTYPES
*/
#define dicdrsch_c
#include "ccoschid.prt"
#include "ccosqlca.prt"
#include "comalloc.prt"
#include "comfree.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "dicdcsch.prt"
#include "dicdrsch.prt"
#include "dicrem.prt"
#include "dictrans.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dicrevk.prt"
#include "dicundss.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "usrsndrc.prt"
#include "usrkill.prt"
#include "usrmisc.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_drop_schema(
	char *schname,
	char *schpass,
	int   exec_mode)
{
	int				status;
	risschema		*drop_schema = 0;
	rissuperschema	*ss_schema;
    risdclrschema   *dschema = 0;
	char            decrpt_schpass[RIS_MAX_ID_SIZE];
	int 	usrsrvdone=0;
	DIC_DBG(("RISdic_drop_schema(schname:<%s> schpass:<%s> exec_mode:0x%x)\n"
		"default_schema:0x%x <%s>\n",schname,schpass,exec_mode,RIS_default,
		RIS_default?RIS_default->schname:""));

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

	status = SETJMP();
	if (status)
	{
		RESETJMP();
		RIScco_push_risca_dbca();

		if (IN_START_MODE(exec_mode) || (IN_FINISH_MODE_ONLY(exec_mode) 
					&& usrsrvdone))
		{
		RISdic_rollback_hash();
		RISfil_rollback_schema_transact();
		}

		RIScco_pop_risca_dbca();
		LONGJMP(status);
	}

	/*
	**	Open drop schema
	*/
	if (IN_START_MODE(exec_mode))
	{
    	/* if its a superschema dont proceed further */
    	if ((ss_schema=RISdic_find_supersch(schname)))
    	{
        	LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
    	}

		status = SETJMP();
		if (status)
		{
			RESETJMP();

			if (status != RIS_E_INV_OPEN_DB &&
				status != RIS_E_NO_SCHEMA_TABLES)
			{
				LONGJMP(status);
			}

			/*
			**	Unable to open schema, but keep going anyway to drop schema
			**	from file.
			*/

			DIC_DBG(("RISdic_drop_schema: dropping schema from file only.\n"));

			drop_schema = ALLOCT(risschema);
			strcpy(drop_schema->schname, schname);
			RISfil_get_schema(drop_schema, ALL_FLAG);

			drop_schema->db = ALLOCT(risdb);
			drop_schema->db->dbid = drop_schema->dbid;
			RISfil_get_db(drop_schema->db, ALL_FLAG);
			RISfil_delete_schema(drop_schema);

			RISdic_blank_secure_ospass(drop_schema);

			RESETJMP();

			RISfil_commit_schema_transact();

			DIC_DBG(("RISdic_drop_sch: returning\n"));
			return;
		}
		else
		{
			drop_schema = RISdic_open_schema(schname, SYNC_MODE);
			RESETJMP();
		}

		/*
		**	For drop schema, one of the following must be true:
		**	the default schema = drop_schema OR
		**	the schema password was provided
		*/
	
		if (RIS_default && RIS_default == drop_schema)
		{
			DIC_DBG(("RISdic_drop_sch:RIS_default == drop_schema\n"));
		}
		else
		{
			DIC_DBG(("RISdic_drop_sch: checking password\n"));
	
			if (!RIScom_pd_same(schpass, drop_schema->schpass))
			{
/*
**  Changed error to RIS_E_UNKNOWN_SCHEMA to be consistent with RIS 4.3.
**	by checking for application version.
**  This fixes TR# 249406468. RAJU 09/19/94.
**  For V5 application the corresponding error is:
**	LONGJMP(RIS_E_SCHPASS_NOT_SAME);
*/
				if (RIS_app_cli_version < 5)
					LONGJMP(RIS_E_UNKNOWN_SCHEMA);
				else
					LONGJMP(RIS_E_SCHPASS_NOT_SAME);
			}
	
			DIC_DBG(("RISdic_drop_sch: correct password was provided\n"));
		}
	
		status = SETJMP();
		if( !status )
		{
			save_default_schema = RIS_default;
			RIS_default = drop_schema;
/*
**	Added check for RIS_upgrade_flag so that the upgrade utility does not
**	have to default to schemas in the grantee list. RAJU 03/25/94
*/
			if (!RIS_upgrade_flag)
				RISdic_rem_sch_reference(drop_schema);
			RIS_default = save_default_schema;
			RESETJMP();
		}
		else
		{
			RESETJMP();
			RIS_default = save_default_schema;
			LONGJMP(status);
		}
	}
	if (IN_FINISH_MODE(exec_mode))
	{
		drop_schema = RISdic_lookup_schema (schname, HASH_TABLE);
		/*
		** If schema doesnt exist in the hash table we assume that
		** we had tried to open the schema earlier, failed and hence
		** we had removed it from the schema file. Therefore there's nothing 
		** else to do but return.
		*/
		if (!drop_schema)
		{
			RESETJMP();
			DIC_DBG(("RISdic_drop_sch: done..\n"));
			return;
		}
		/*
		**	remove the schema def from the schema file
		**	NOTE: RISfil_delete_schema will also drop the database
		**	from the file if drop_schema is the only schema on the database
		*/
		DIC_DBG(("RISdic_drop_sch: Remove the schema from the file\n"));
		if (IN_FINISH_MODE_ONLY(exec_mode))
		{
			RIS_sdp->schema = drop_schema;
			RISusr_send_rec(RIS_DROP_SCHEMA_CODE, RIS_sdp,
				(unsigned short)exec_mode);
			usrsrvdone = 1;
		}
		RISfil_delete_schema(drop_schema);

		RISdic_blank_secure_ospass(drop_schema);
	
		/*
		**	remove schema from hash table
		*/
		DIC_DBG(("RISdic_drop_sch: drop the schema from the hash table\n"));
		RISdic_remove_hash(RIS_TOK_SCHEMA, drop_schema);
	}
	
	/*
	**	drop the schema
	*/
	if (IN_START_MODE(exec_mode))
	{
		RIS_sdp->schema = drop_schema;
		RISusr_send_rec(RIS_DROP_SCHEMA_CODE, RIS_sdp,
			(unsigned short)exec_mode);

	}
	if (IN_FINISH_MODE(exec_mode))
	{
		/*
		**	Kill the server
		*/
		DIC_DBG(("RISdic_drop_sch: kill the server\n"));
	
		if (!SETJMP())
		{
			RISusr_kill_srv(drop_schema, CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET, SYNC_MODE);
		}
		RESETJMP();
	}

	RESETJMP();

	if (IN_FINISH_MODE(exec_mode))
	{
		status = SETJMP();
		if(!status)
		{
			RISdic_commit_hash();
			RISfil_commit_schema_transact();
			if (drop_schema)
			{
				FREES(drop_schema->schid);
				RIScco_clear_schema_id(drop_schema->schid);
			}
			RESETJMP();
		}
		else
		{
			RESETJMP();
			if (drop_schema)
			{
				FREES(drop_schema->schid);
				RIScco_clear_schema_id(drop_schema->schid);
			}
			LONGJMP(status);
		}
	}

	DIC_DBG(("RISdic_drop_sch: exiting: default_schema:0x%x <%s>\n",
 		RIS_default, RIS_default?RIS_default->schname:""));
}

/******************************************************************************/

static void RISdic_rem_sch_reference(
	risschema	*drping_sch)
{
	risschema				*schema;
	risschema				*schema_list;
	RISdic_access_struct	*access_struct = 0;	
	RISdic_access_struct	*acc_struct;	
	ristab					*tablep;
	ristree					*revokep;

DIC_DBG(("RISdic_rem_sch_reference: drping_sch 0x%x\n", drping_sch);)

	RISfil_get_all_schemas(&schema_list, ALL_FLAG);
	RISfil_commit_schema_transact();

	RISdic_rem_self_samedbsch(&schema_list, drping_sch);
	if (!SETJMP())
	{
		access_struct = RISdic_get_sch_ref(schema_list, drping_sch->schname);
		RESETJMP();
	}
	else
	{
		RESETJMP();
		LONGJMP(RIS_E_ERR_FIND_SCH_REF);
	}
	for (acc_struct = access_struct; acc_struct; acc_struct = acc_struct->next)
	{

#ifdef OLD
		if (SETJMP())	/* catch and ignore error */
		{
			RESETJMP();
			continue;
		}
#endif
		schema = RISdic_lookup_schema(acc_struct->list->schname, HASH_TABLE);
		tablep = RISdic_lookup_rel(schema, acc_struct->list->relowner, 
			acc_struct->list->relname, 0);

		RISdic_linkto_privlist(tablep, acc_struct->list);

		revokep = ALLOCT(ristree);
		revokep->tok = RIS_TOK_REVOKE;
		revokep->info.access = acc_struct->list;

		RISdic_revoke(revokep, SYNC_MODE);

#ifdef OLD
		RESETJMP();
#endif
	}
}

/******************************************************************************/

static void RISdic_rem_self_samedbsch(
	risschema	**schema_list,
	risschema	*drping_sch)
{
	risschema		*crnt_sch;
	risschema		*pre_sch;
	risschema		*next_sch;

	DIC_DBG(("RISdic_rem_self_samedbsch: schema_list 0x%x, drping_sch 0x%x\n",
				*schema_list, drping_sch);)

	for (pre_sch = 0, crnt_sch = *schema_list; crnt_sch; crnt_sch = next_sch)
	{
		next_sch = crnt_sch->next;
		if (!strcmp(drping_sch->schname, crnt_sch->schname) ||
			!schname_in_grantee_list(drping_sch->schname, crnt_sch->grantee))
		{
    		if (pre_sch)
			{
				pre_sch->next = crnt_sch->next;
			}
    		else
			{
				*schema_list = crnt_sch->next;
			}
		}
		else
		{
			pre_sch = crnt_sch;
		}
	}
}
  
/******************************************************************************/

static RISdic_access_struct *RISdic_get_sch_ref(
	risschema	*schema_list,
	char		*sch_name)
{
	int 					i;
	int						first_pass;
	int						more_to_follow;
	int						new_acc_info_count;
	risschema				*schema;
	risaccess				*access_list;
	risaccess				*acc;
	RISdic_access_struct	*access_struct;
	RISdic_access_struct	*next_accstruct;
	ris_access_info			*new_acc_info_list;
	ris_access_info			*new_acc_info;

	DIC_DBG(("RISdic_get_sch_ref: schema_list 0x%x, sch_name <%s>\n",
				schema_list, sch_name);)

	access_struct = 0;
	for (; schema_list; schema_list = schema_list->next)
	{
		schema = RISdic_open_schema(schema_list->schname, SYNC_MODE);
		RIS_sdp->schema = schema;
		RIS_sdp->query = (char *)sch_name;

		first_pass = 1;
		do
		{
			RISusr_send_rec(RIS_GET_SCHEMA_GRANTORS_CODE, RIS_sdp, SYNC_MODE);
			more_to_follow = RIS_srv_read->buf.get_access.more_to_follow;
			new_acc_info_count = RIS_srv_read->buf.get_access.count;
			DIC_DBG(("new_acc_info_count:%d\n", new_acc_info_count));
			new_acc_info_list =
				(ris_access_info *)RIS_srv_read->buf.get_access.data;
			if (!new_acc_info_count)
			{
				break;
			}

			access_list = ALLOCN(risaccess, new_acc_info_count);
			for (new_acc_info=new_acc_info_list, acc=access_list, i=0;
				 i < new_acc_info_count;
				 new_acc_info++, acc++, i++)
			{
				RISusr_access_info_to_access(new_acc_info, acc);
				DIC_DBG(("schname:<%s>  relname:<%s>\n",	
						acc->schname, acc->relname));
				DIC_DBG(("relid:<%d>  relowner:<%s>\n",	
						acc->relid, acc->relowner));
			}

			if (first_pass)
			{
				next_accstruct = ALLOCT(RISdic_access_struct);
				next_accstruct->list = 0;
				next_accstruct->list_len = 0;
				next_accstruct->next = access_struct;
				access_struct = next_accstruct;

				first_pass = 0;
			}

			for (acc = access_list, i = 0; i < new_acc_info_count; acc++, i++)
			{
	        	if (access_struct->list &&
					(strcmp(acc->relname, access_struct->list->relname)) &&
					(strcmp(acc->relowner, access_struct->list->relowner)))
				{
					next_accstruct = ALLOCT(RISdic_access_struct);
					next_accstruct->next = 0;
					next_accstruct->list = 0;
					next_accstruct->list_len = 1;
					next_accstruct->next = access_struct;
					access_struct = next_accstruct;
				}
				else
				{
					access_struct->list_len++;
				}
	
				acc->next = access_struct->list;
				access_struct->list = acc;
			}
		} while (more_to_follow);
	}	
	return(access_struct);
}

/******************************************************************************/

static void RISdic_linkto_privlist(
	ristab		*tablep,
	risaccess	*access_list)
{

	risaccess	*acc;
	risattr		*attr;

	DIC_DBG(("RISdic_linkto_privlist: tablep 0x%x, access_list 0x%x\n",
				tablep, access_list);)

	for (acc = access_list; acc; acc = acc->next)
	{
		if (!acc->colname[0])
		{
			acc->ptr.tab = tablep;
			acc->flag = 'T';
			DIC_DBG(("\tlinking tablep:0x%x (<%s>)\n", tablep,tablep->tabname));
		}
		else
		{
			for (attr = tablep->attr; attr; attr = attr->next)
			{
				if (!strcmp(acc->colname, attr->attrname))
				{
					acc->ptr.attr = attr;
					acc->flag = 'A';
					DIC_DBG(("\tlinking attr:0x%x (<%s>)\n",
						attr, attr->attrname));
					break;
				}
			}
			if (!attr) LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	DIC_DBG(("RISdic_linkto_privlist: Done..\n"));
}

/******************************************************************************/

static int schname_in_grantee_list(
			char		*schname,
			risgrantee	*grantee)
{
	DIC_DBG(("schname_in_grantee_list(schname:<%s> grantee:0x%x)\n",
		schname, grantee));

	for (;grantee; grantee = grantee->next)
		if (!strcmp(schname, grantee->schname))
			return 1;
	return 0;
}

/******************************************************************************/

extern void RISdic_blank_secure_ospass(
	risschema	*schema)
{
	int	standard_schema;
	int	any_schema;

	DIC_DBG(("RISdic_blank_secure_ospass(schema: 0x%x)\n", schema));

	any_schema = RISfil_has_any_schema(schema->dbid);
	standard_schema = RISfil_has_standard_schema(schema->dbid);
	DIC_DBG(("RISdic_blank_secure_ospass: any_schema %d standard_schema %d\n", 
		any_schema, standard_schema));
	if (any_schema && !standard_schema)
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
		RISfil_update_db(schema->db, PARMS_FLAG);
	}
	DIC_DBG(("RISdic_blank_secure_ospass: returning\n"));
}

/******************************************************************************/
