/*
**	NAME:							cligetfl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		-10/24/94 Radha
**		added changes for MSSQL data server
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "client.h"

#if defined(unix) 
#include <dirent.h>
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define cligetfl_c
#include "cliclear.prt"
#include "cligetfl.prt"
#include "cliid.prt"
#include "clibuff.prt"
#include "comdebug.prt"
#include "ccosqlca.prt"
#include "comjmp.prt"
#include "fildb.prt"
#include "filglob.prt"
#include "filsch.prt"
#include "filtrans.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static char			*filename = 0;
static risdb		*dbs = 0;
static risschema	*schemas = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void add_schema(
	risschema *schema)
{
	CLI_DBG(("add_schema(schema:0x%x)\n", schema));

/*
** Need to handle both V4 and V5 application - Shiva, Dianne 4/11
*/

if (RIS_app_cli_version == 4)

	RIScli_string_to_buf("SCHEMA\n%s\n%s\n%s\n%hd\n",
		schema->schname, schema->schowner, schema->passwd, 
		schema->dbid);
else

	RIScli_string_to_buf("SCHEMA\n%s\n%s\n%s\n%s\n%hd\n%hd\n%hd\n%hd\n",
		schema->schname, schema->schowner, schema->passwd, 
		schema->dictowner,
		schema->secure == 'S' ? 1 : 0,
		schema->major == -1 ? 0 : schema->major,
		schema->feature == -1 ? 0 : schema->feature,
		schema->dbid);
	RIScli_ckpt_string_to_buf((char *)&schema->dbid);

	for (; schema->grantee; schema->grantee = schema->grantee->next)
	{
		RIScli_ckpt_string_to_buf((char *)schema->grantee);

		RIScli_string_to_buf("%s\n", schema->grantee->schname);
	}
	RIScli_ckpt_string_to_buf((char *)&schema->grantee);

	CLI_DBG(("add_schema:complete\n"));
}

/******************************************************************************/

static void add_db(
	risdb *db)
{
	int i;

	CLI_DBG(("add_db(db:0%x)\n", db));

	RIScli_string_to_buf("DB\n%hd\n%c\n%s\n%c\n",
		db->dbid, db->dtype, db->dbname, db->ostype);
	RIScli_ckpt_string_to_buf((char *)&db->ostype);

	for (i=0; i<RIS_MAX_PROTOCOLS; i++)
	{
		if (db->pathways[i].protocol)
		{
			RIScli_string_to_buf("%c\n%s\n",
				db->pathways[i].protocol, db->pathways[i].netaddr);
		}
		else
		{
			RIScli_string_to_buf("\n\n");
		}
		RIScli_ckpt_string_to_buf((char *)&db->pathways[i]);
	}

	switch(db->dtype)
	{
		case 'X':
			RIScli_string_to_buf("%s\n",db->parms.ifx.dir);
			RIScli_ckpt_string_to_buf((char *)db->parms.ifx.dir);

			RIScli_string_to_buf("%s\n",db->parms.ifx.sqlexec);
			RIScli_ckpt_string_to_buf((char *)db->parms.ifx.sqlexec);

			RIScli_string_to_buf("%s\n",db->parms.ifx.dbtemp);
			RIScli_ckpt_string_to_buf((char *)db->parms.ifx.dbtemp);

			RIScli_string_to_buf("%s\n",db->parms.ifx.tbconfig);
			RIScli_ckpt_string_to_buf((char *)db->parms.ifx.tbconfig);
			break;

		case 'O':
			RIScli_string_to_buf("%s\n",db->parms.ora.osuser);
			RIScli_ckpt_string_to_buf((char *)db->parms.ora.osuser);

			RIScli_string_to_buf("%s\n",db->parms.ora.ospass);
			RIScli_ckpt_string_to_buf((char *)db->parms.ora.ospass);

			RIScli_string_to_buf("%s\n",db->parms.ora.dir);
			RIScli_ckpt_string_to_buf((char *)db->parms.ora.dir);
			break;

		case 'I':
			RIScli_string_to_buf("%s\n",db->parms.igs.dir);
			RIScli_ckpt_string_to_buf((char *)db->parms.igs.dir);
			break;

		case 'D':
			RIScli_string_to_buf("%s\n",db->parms.db2.osuser);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.osuser);
			RIScli_string_to_buf("%s\n",db->parms.db2.ospass);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.ospass);

			RIScli_string_to_buf("%s\n",db->parms.db2.arch);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.arch);
			RIScli_string_to_buf("%s\n",db->parms.db2.os);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.os);
			RIScli_string_to_buf("%s\n",db->parms.db2.env);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.env);
			RIScli_string_to_buf("%s\n",db->parms.db2.net_protocol);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.net_protocol);
			RIScli_string_to_buf("%s\n",db->parms.db2.host_program);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.host_program);
			RIScli_string_to_buf("%s\n",db->parms.db2.ris_lu);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.ris_lu);
			RIScli_string_to_buf("%s\n",db->parms.db2.host_lu);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.host_lu);
			RIScli_string_to_buf("%s\n",db->parms.db2.mode);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.mode);
			RIScli_string_to_buf("%s\n",db->parms.db2.group);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.group);
			RIScli_string_to_buf("%s\n",db->parms.db2.node);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.node);
			RIScli_string_to_buf("%d\n",db->parms.db2.port);
			RIScli_ckpt_string_to_buf((char *)db->parms.db2.port);
			break;

       case '4':

           RIScli_string_to_buf("%s\n",db->parms.os400.osuser);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.osuser);
           RIScli_string_to_buf("%s\n",db->parms.os400.ospass);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.ospass);

           RIScli_string_to_buf("%s\n",db->parms.os400.net_protocol);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.net_protocol);

           RIScli_string_to_buf("%s\n",db->parms.os400.host_program);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.host_program);

           RIScli_string_to_buf("%s\n",db->parms.os400.ris_lu);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.ris_lu);

           RIScli_string_to_buf("%s\n",db->parms.os400.host_lu);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.host_lu);

           RIScli_string_to_buf("%s\n",db->parms.os400.mode);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.mode);

           RIScli_string_to_buf("%s\n",db->parms.os400.group);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.group);

           RIScli_string_to_buf("%s\n",db->parms.os400.node);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.node);

           RIScli_string_to_buf("%s\n",db->parms.os400.ris_dict_dbname);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.ris_dict_dbname);

           RIScli_string_to_buf("%d\n",db->parms.os400.port);
           RIScli_ckpt_string_to_buf((char *)db->parms.os400.port);
		break;

		case 'R':
			break;

		case 'Y':
			RIScli_string_to_buf("%s\n",db->parms.syb.osuser);
			RIScli_ckpt_string_to_buf((char *)db->parms.syb.osuser);

			RIScli_string_to_buf("%s\n",db->parms.syb.ospass);
			RIScli_ckpt_string_to_buf((char *)db->parms.syb.ospass);

			RIScli_string_to_buf("%s\n",db->parms.syb.dir);
			RIScli_ckpt_string_to_buf((char *)db->parms.syb.dir);

			RIScli_string_to_buf("%s\n",db->parms.syb.dsquery);
			RIScli_ckpt_string_to_buf((char *)db->parms.syb.dsquery);

			RIScli_string_to_buf("%s\n",db->parms.syb.sybifile);
			RIScli_ckpt_string_to_buf((char *)db->parms.syb.sybifile);
			break;

        case 'M':
            RIScli_string_to_buf("%s\n",db->parms.mssql.osuser);
            RIScli_ckpt_string_to_buf((char *)db->parms.mssql.osuser);

            RIScli_string_to_buf("%s\n",db->parms.mssql.ospass);
            RIScli_ckpt_string_to_buf((char *)db->parms.mssql.ospass);

            RIScli_string_to_buf("%s\n",db->parms.mssql.dir);
            RIScli_ckpt_string_to_buf((char *)db->parms.mssql.dir);

            RIScli_string_to_buf("%s\n",db->parms.mssql.dsquery);
            RIScli_ckpt_string_to_buf((char *)db->parms.mssql.dsquery);

            RIScli_string_to_buf("%s\n",db->parms.mssql.mssqlifile);
            RIScli_ckpt_string_to_buf((char *)db->parms.mssql.mssqlifile);
            break;

	}
	CLI_DBG(("add_db:complete\n"));
}

/******************************************************************************/

static void get_schfile_info()
{
	int			sts;

	CLI_DBG(("get_schfile_info()\n"));

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		RIScco_push_risca_dbca();

		RISfil_rollback_schema_transact();

		RIScco_pop_risca_dbca();
		LONGJMP(sts);
	}

	RISfil_get_filename(&filename);
	if (!RIS_upgrade_flag)
	{
		RISfil_get_all_dbs(&dbs, ALL_FLAG);
		RISfil_get_all_schemas(&schemas, ALL_FLAG);
	}
	RISfil_commit_schema_transact();

	RESETJMP();

	CLI_DBG(("get_schfile_info: complete\n"));
}

/******************************************************************************/

extern void RIScli_get_schfile(
	short id)
{
	int		sts;
	int		continue_flag;
	static short	stmt_id = -1;

	CLI_DBG(("RIScli_get_schfile(id:%d)\n", id));

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		if (sts == RIS_E_BUFFER_FULL) return;

		if (stmt_id != -1)
		{
			RIScli_clear(stmt_id, 0, SYNC_MODE,0);
			stmt_id = -1;
		}
		LONGJMP(sts);
	}

	if (stmt_id != -1)
	{
		continue_flag = 1;
	}
	else
	{
		continue_flag = 0;

		stmt_id = RIScli_new_stmt(id);
		get_schfile_info();
	}

	RIScli_init_string_to_buf(continue_flag);

	RIScli_string_to_buf("FILENAME\n%s\n", filename);
	RIScli_ckpt_string_to_buf(filename);

	for(; schemas; schemas = schemas->next)
	{
		RIScli_ckpt_string_to_buf((char *)schemas);
		add_schema(schemas);
	}

	for(; dbs; dbs = dbs->next)
	{
		RIScli_ckpt_string_to_buf((char *)dbs);
		add_db(dbs);
	}

	RESETJMP();

	RIScli_clear(stmt_id,0,SYNC_MODE,0);
	stmt_id = -1;

	CLI_DBG(("RIScli_get_schfile: complete\n"));
}

/******************************************************************************/
