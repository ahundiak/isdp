/*
**	NAME:							usrtab.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**     Changed fieldname 'usr' into 'schowner' in risschema and
**     and ris_schema_info structures -- Shiva 11/11/93
**
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_pa.h"
#include "riscli.h"
#include "ris.h"
#include "user.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrtab_c
#include "ccosqlca.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "usrtab.prt"
#include "usrmisc.prt"
#include "usrsndrc.prt"
#include "sys.prt"


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

extern void RISusr_update_risdbs(
	risstmt * stmt)
{
	int offset;
	int max_dbs;
	int db_count;
	int first_buffer;
	risdb *dbs = (risdb *)0;
	struct ris_clisrv_buf_load_risdbs *load_risdbs =
		&RIS_srv_write->buf.load_risdbs;

	USR_DBG(("RISusr_update_risdbs(stmt:0x%x)\n", stmt));

	max_dbs = (RIS_srv_write_size -
		(int)&(((ris_clisrv_buf*)0)->buf.load_risdbs.data))/sizeof(risdb);

	USR_DBG(("RISusr_update_risdbs: RIS_srv_write_size:%d max_dbs:%d\n",
		RIS_srv_write_size, max_dbs));

	RISfil_get_all_dbs(&dbs, ALL_FLAG);

	offset = 0;
	db_count = 0;
	first_buffer = 1;
	while(dbs)
	{
		USR_DBG(("RISusr_update_risdbs:\n\tdbs->dbid:%d\n\tdbs->dtype:%c\n"
			"\tdbs->dbname:%s\n", dbs->dbid, dbs->dtype, dbs->dbname));

		RISusr_db_to_db_info(dbs, (ris_db_info *)(load_risdbs->data + offset));

		db_count++;
		offset += sizeof(ris_db_info);
		dbs = dbs->next;

		if (db_count == max_dbs || !dbs)
		{
			load_risdbs->dbs = 0;
			load_risdbs->db_count = db_count;

			if (first_buffer)
			{
				first_buffer = 0;
				load_risdbs->delete_flag = 1;
			}
			else
			{
				load_risdbs->delete_flag = 0;
			}

			if (dbs)
			{
				load_risdbs->more_to_follow = 1;
			}
			else
			{
				load_risdbs->more_to_follow = 0;
			}


			RIS_srv_write_len =
				(int)&(((ris_clisrv_buf *)0)->buf.load_risdbs.data) + offset;

			RISusr_send_rec(RIS_LOAD_RISDBS_CODE, stmt->sql, SYNC_MODE);

			offset = 0;
			db_count = 0;
		}
	}
	USR_DBG(("RISusr_update_risdbs:complete\n"));
}

/******************************************************************************/

extern void RISusr_update_risschemas(
	risstmt * stmt)
{
	int offset;
	int max_schemas;
	int schema_count;
	int first_buffer;
	risschema *schemas = (risschema *)0;
	struct ris_clisrv_buf_load_risschemas *load_risschemas =
		&RIS_srv_write->buf.load_risschemas;

	USR_DBG(("RISusr_update_risschemas(stmt:0x%x)\n", stmt));

	max_schemas = (RIS_srv_write_size -
		(int)&(((ris_clisrv_buf*)0)->buf.load_risschemas.data))/
		sizeof(risschema);

	USR_DBG(("RISusr_update_risschemas: RIS_srv_write_size:%d max_schemas:%d\n",
		RIS_srv_write_size, max_schemas));

	RISfil_get_all_schemas(&schemas,
		SCHNAME_FLAG|SECURE_FLAG|SCHOWNER_FLAG|DICTOWNER_FLAG|SCHDBID_FLAG|VERSION_FLAG);

	offset = 0;
	schema_count = 0;
	first_buffer = 1;
	while(schemas)
	{
		USR_DBG(("RISusr_update_risschemas:\n\tschname:<%s>\n\tschowner:<%s>\n"
			"\tdbid:%d", schemas->schname, schemas->schowner, schemas->dbid));
		USR_DBG(("\n\tdictowner:<%s>\n\tlogin:<%s>\n\tpasswd:<%s>\n", 
			schemas->dictowner, schemas->login, schemas->passwd));
		USR_DBG(("\n\tmajor version:<%d>\n\tfeature version:<%d>\n",
			schemas->major, schemas->feature));

		RISusr_schema_to_schema_info(schemas,
			(ris_schema_info *)(load_risschemas->data + offset));

		schema_count++;
		offset += sizeof(ris_schema_info);
		schemas = schemas->next;

		if (schema_count == max_schemas || !schemas)
		{
			load_risschemas->schemas = 0;
			load_risschemas->schema_count = schema_count;

			if (first_buffer)
			{
				first_buffer = 0;
				load_risschemas->delete_flag = 1;
			}
			else
			{
				load_risschemas->delete_flag = 0;
			}

			if (schemas)
			{
				load_risschemas->more_to_follow = 1;
			}
			else
			{
				load_risschemas->more_to_follow = 0;
			}


			RIS_srv_write_len =
				(int)&(((ris_clisrv_buf *)0)->buf.load_risschemas.data) +
				offset;

			RISusr_send_rec(RIS_LOAD_RISSCHEMAS_CODE, stmt->sql, SYNC_MODE);

			offset = 0;
			schema_count = 0;
		}
	}
	USR_DBG(("RISusr_update_risschemas:complete\n"));
}

/******************************************************************************/

extern void RISusr_update_ristabs(
	risstmt * stmt)
{
	int sts;
	long timestamp;

	if (stmt->flags.risdbs || stmt->flags.risschemas)
	{
		if ((sts = SETJMP()) != 0)
		{
			RESETJMP();

			RIScco_push_risca_dbca();

			RISfil_rollback_schema_transact();

			RIScco_pop_risca_dbca();

			LONGJMP(sts);
		}

		RISfil_get_timestamp(&timestamp);

		if (stmt->flags.risdbs &&
			stmt->sql->schema->risdbs_timestamp != timestamp)
		{
			RISusr_update_risdbs(stmt);
			stmt->sql->schema->risdbs_timestamp = timestamp;
		}
		if (stmt->flags.risschemas)
		{
			if (stmt->sql->schema->risschemas_timestamp != timestamp)
			{
				RISusr_update_risschemas(stmt);
				stmt->sql->schema->risschemas_timestamp = timestamp;
			}
		}

		RESETJMP();
		RISfil_commit_schema_transact();
	}
}

/******************************************************************************/
