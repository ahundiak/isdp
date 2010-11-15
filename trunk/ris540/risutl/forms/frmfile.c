/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:									frmfile.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**		This file contains the routines that manage transactions involving
**		the schema file for the schema manager and other various form utilities.
**	
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmfile_c
#include "comdebug.prt"
#include "comstcmi.prt"
#include "comumsg.prt"
#include "frmerror.prt"
#include "frmfile.prt"
#include "frmutil.prt"
#include "ris.prt"
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

static int compare_schemas(
	ris_schema_info *schema1,
	ris_schema_info *schema2)
{
	return(strcmp(schema1->schname, schema2->schname));
}

/******************************************************************************/

static int compare_dbs(
	ris_db_info *db1,
	ris_db_info *db2)
{
	int		sts;
	char	*dbtype1, *dbtype2;

	dbtype1 = RISfrm_get_dbtypename_from_frmdbtype(RISfrm_get_frmdbtype_from_risdbtype(db1->dtype));
	dbtype2 = RISfrm_get_dbtypename_from_frmdbtype(RISfrm_get_frmdbtype_from_risdbtype(db2->dtype));
	sts = strcmp(dbtype1, dbtype2);
	if (sts == 0)
	{
		sts = strcmp(db1->dbname, db2->dbname);
		if (sts == 0)
		{
			sts = db1->pathways[0].protocol - db2->pathways[0].protocol;
			if (sts == 0)
			{
				sts = RIScom_strcmp_ic(db1->pathways[0].netaddr,
					db2->pathways[0].netaddr);
			}
		}
	}
	return sts;
}

/******************************************************************************/

extern int RISfrm_read_schema_file()
{
	void			*temp;
	ris_db_info		*dbs = NULL;
	ris_schema_info	*schemas = NULL;

	FRM_DBG(("RISfrm_read_schema_file()\n"));

	while (RISfrm_dbs)
	{
		temp = RISfrm_dbs;
		RISfrm_dbs = RISfrm_dbs->next;
		free(temp);
	}
	RISfrm_dbs_cnt = 0;

	while (RISfrm_schemas)
	{
		temp = RISfrm_schemas;
		RISfrm_schemas = RISfrm_schemas->next;
		free(temp);
	}
	RISfrm_schemas_cnt = 0;

	RISget_schema_file(NULL, &dbs, &schemas, NULL);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		FRM_DBG(("RISfrm_read_schema_file:returning :%d\n",
			RIS_forms_error.error));
		return RIS_forms_error.error;
	}

	while(dbs)
	{
		ris_db_info	**dbsp;
		ris_db_info	*temp_db;
		ris_db_info	**max_dbsp;

		max_dbsp = &dbs;
		dbsp = &dbs->next;
		while(*dbsp)
		{
			if (compare_dbs((*dbsp), (*max_dbsp)) > 0)
			{
				max_dbsp = dbsp;
			}
			dbsp = &(*dbsp)->next;
		}

		temp_db = *max_dbsp;
		(*max_dbsp) = (*max_dbsp)->next;
		temp_db->next = RISfrm_dbs;
		RISfrm_dbs = temp_db;
		RISfrm_dbs_cnt++;
	}

	while(schemas)
	{
		ris_schema_info	**schemasp;
		ris_schema_info	*temp_schema;
		ris_schema_info	**max_schemasp;

		max_schemasp = &schemas;
		schemasp = &schemas->next;
		while(*schemasp)
		{
			if (compare_schemas((*schemasp), (*max_schemasp)) > 0)
			{
				max_schemasp = schemasp;
			}
			schemasp = &(*schemasp)->next;
		}

		temp_schema = *max_schemasp;
		(*max_schemasp) = (*max_schemasp)->next;
		temp_schema->next = RISfrm_schemas;
		RISfrm_schemas = temp_schema;
		RISfrm_schemas_cnt++;
	}

	RISfrm_file_info_up_to_date = 1;

	CLEAR_ERROR;

	FRM_DBG(("RISfrm_read_schema_file:returning :%d\n",RIS_SUCCESS));
	return RIS_SUCCESS;
}

/******************************************************************************/

extern ris_schema_info *RISfrm_get_schema(
	char	*schname,
	void	(*update_msg_func)(),
	void	(*clear_msg_func)())
{
	ris_schema_info	key;
	ris_schema_info	*schema = NULL;

	FRM_DBG(("RISfrm_get_schema(schname:<%s>)\n", schname?schname:"NULL"));

	if (!schname) return NULL;

	if (!RISfrm_file_info_up_to_date)
	{
		if (update_msg_func)
		{
			update_msg_func(MSG(RISUTL_I_READING_SCHFILE));
		}
		RISfrm_read_schema_file();
		if (clear_msg_func)
		{
			clear_msg_func();
		}
		if (RIS_forms_error.error && RISfrm_report_error())
		{
			switch(RIS_forms_error.error)
			{
			}
		}
	}

	strcpy(key.schname, schname);
	for (schema = RISfrm_schemas; schema; schema = schema->next)
	{
		if (!compare_schemas(schema, &key))
		{
			break;
		}
	}

	FRM_DBG(("RISfrm_get_schema:returning schema:0x%x\n", schema));
	return schema;
}

/******************************************************************************/
extern RISfrm_db_id *RISfrm_get_db_id(
	ris_db_info	*db)
{
	int				dbtype;
	int				prot;

	static	 RISfrm_db_id	db_id;;

	FRM_DBG(("RISfrm_get_db_id(db:0x%x)\n", db));

	if ((dbtype = RISfrm_get_frmdbtype_from_risdbtype(db->dtype)) == -1)
		return NULL;

	/*
	**	Fill in type string
	*/
	strcpy(db_id.type, RISfrm_get_dbtypename_from_frmdbtype(dbtype));

	/*
	**	Fill in name string
	*/
	strcpy(db_id.name, db->dbname);

	/*
	**	Fill in location string
	*/
	if ((prot = RISfrm_get_form_prot(db->pathways[0].protocol)) == -1)
		return NULL;

	strcpy(db_id.location, RISfrm_get_prot_name(prot));
	strcat(db_id.location, " ");
	strcat(db_id.location, db->pathways[0].netaddr);

	return &db_id;
}

/******************************************************************************/

extern ris_db_info *RISfrm_get_db(
	RISfrm_db_id	*db_id)
{
	int			i;
	char		*prot;
	char		*addr;
	ris_db_info	key;
	ris_db_info	*db = NULL;

	FRM_DBG(("RISfrm_get_db(db_id:0x%x)\n", db_id));

	if (!db_id) return NULL;

	FRM_DBG(("type:<%s> name:<%s> location:<%s>\n",
		db_id->type ? db_id->type : "NULL", db_id->name ? db_id->name : "NULL",
		db_id->location ? db_id->location : "NULL"));

	/*
	**	Load database type into key
	*/
	if (db_id->type && *db_id->type)
	{
		for (i = 0; i < DB_COUNT; i++)
		{
			if (!strcmp(db_id->type, RISfrm_get_dbtypename_from_frmdbtype(i)))
			{
				key.dtype = RISfrm_get_risdbtype_from_frmdbtype(i);
				break;
			}
		}
		if (i == DB_COUNT) return NULL;
	}
	else return NULL;

	/*
	**	Load database name into key
	*/
	if (db_id->name && *db_id->name)
	{
		strcpy(key.dbname, db_id->name);
	}
	else return NULL;
		
	/*
	**	Load protocol and netaddr into key
	*/
	if (db_id->location && *db_id->location)
	{
		prot = db_id->location;
		if ((addr = strchr(prot,' ')) == NULL)
			return NULL;
		*addr++ = 0;

		for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		{
			if (!strcmp(prot, RISfrm_get_prot_name(i)))
			{
				key.pathways[0].protocol = RISfrm_get_ris_prot(i);
				break;
			}
		}
		if (i == RIS_MAX_PROTOCOLS)
			return NULL;

		strcpy(key.pathways[0].netaddr, addr);
	}
	else return NULL;

	FRM_DBG(("key: dtype:<%c> dbname:<%s> protocol:<%c> netaddr:<%s>\n",
		key.dtype, key.dbname, key.pathways[0].protocol,
		key.pathways[0].netaddr));

	for (db = RISfrm_dbs; db; db = db->next)
	{
		if (!compare_dbs(db, &key))
		{
			break;
		}
	}

	return(db);
}
