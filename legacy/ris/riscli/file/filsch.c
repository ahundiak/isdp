/*
**	NAME:							filsch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/90
**	ABSTRACT:
**		This file contains the routines that manage schemas in 
**		the dictionary file.
**	
**	REVISION HISTORY:
**		add RISfil_has_standard_schema() and RISfil_has_any_schema() 
**			for V5 schema by Jin Jing 02/94
*/
 
/*
**	INCLUDES
*/
#include "file.h"

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
#define filsch_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrcp.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "fillist.prt"
#include "filtrans.prt"
#include "filshare.prt"
#include "sys.prt"


 

/******************************************************************************/

static char *schema_mask_name(
	int mask)
{
	auto	int		i;
	auto	int		first_flag = 1;
	static	char	*ptr;
	static	char	buffer[80];
	static	struct
	{
		int		flag;
		char	*name;
	} schema_flag_name[] =
	{
		{ SCHNAME_FLAG,		"SCHNAME_FLAG"		},
		{ SECURE_FLAG,		"SECURE_FLAG"		},
		{ DICTOWNER_FLAG,	"DICTOWNER_FLAG"	},
		{ SCHOWNER_FLAG,		"SCHOWNER_FLAG"		},
		{ SCHOWNPASS_FLAG,	"SCHOWNPASS_FLAG"	},
		{ GRANTEE_FLAG,		"GRANTEE_FLAG"		},
		{ SCHDBID_FLAG,		"SCHDBID_FLAG"		},
		{ VERSION_FLAG,		"VERSION_FLAG"		},
	};
	/*
	** The count should be equal to the no. of entries in the schema_flag_name
	** array.
	*/
	static	int		flag_count = 8;

	if (mask == ALL_FLAG) return "ALL_FLAG";

	ptr = buffer;
	*ptr = 0;
	for (i = 0; i < flag_count; i++)
	{
		if (mask & schema_flag_name[i].flag)
		{
			if (first_flag)
				first_flag = 0;
			else
				*ptr++ = '|';
			ptr += RIScom_strcpy(ptr, schema_flag_name[i].name);
		}
	}
	return buffer;
}

/******************************************************************************/

extern void RISfil_copy_schema(
			risschema	*to,
			risschema	*from,
			int			mask)
{
	auto	risgrantee		*grantee;
	auto	risgrantee		**granteep;
	if (mask & SCHNAME_FLAG) strcpy(to->schname, from->schname);
	if (mask & SECURE_FLAG)  to->secure = from->secure;
	if (mask & DICTOWNER_FLAG) strcpy(to->dictowner, from->dictowner);
	if (mask & SCHOWNER_FLAG) strcpy(to->schowner, from->schowner);
	if (mask & SCHOWNPASS_FLAG) strcpy(to->passwd, from->passwd);
	if (mask & VERSION_FLAG)
	{
		to->major = from->major;
		to->feature = from->feature;
	}
	if (mask & GRANTEE_FLAG)
	{
		to->grantee = 0;
		for (grantee = from->grantee, granteep = &(to->grantee);
			 grantee;
			 grantee = grantee->next)
		{
			(*granteep) = ALLOCT(risgrantee);
			strcpy((*granteep)->schname, grantee->schname);
			granteep = &((*granteep)->next);
		}
	}
	if (mask & SCHDBID_FLAG) to->dbid = from->dbid;
}

/******************************************************************************/

/*
** Get information about a schema from the dictionary file and put it into an
** risschema struct.  The schname field needs to be filled in with the name
** of schema in question.
*/

extern void RISfil_get_schema(
			risschema	*schema_info,
			int			mask)
{
	auto	filsch_list	*schemap;
	filsch_tmp_list 	*temp;

	FIL_DBG(("RISfil_get_schema(schema_info:0x%x mask:%s)\nschname:<%s>\n", 
		schema_info, schema_mask_name(mask), schema_info->schname));

	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_ONLY_TRANSACTION);

	FIL_DBG(("looking in temp. schema list first.\n"));

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (temp=RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;temp;
				temp = temp->next)
		{
			if (temp->tmp_schemap &&
				!(strcmp(schema_info->schname,temp->tmp_schemap->schname)))
			{
				FIL_DBG(("tmp_schemap exists,schname:%s\n",
					temp->tmp_schemap->schname));
				RISfil_copy_schema(schema_info, temp->tmp_schemap, mask);
				schema_info->next = 0;
				return;
			}
			else if	(temp->master_schp &&
				!(strcmp(schema_info->schname,temp->master_schp->schemap->schname)))
			{
				FIL_DBG(("master_schp exists,schname:%s\n",
					temp->master_schp->schemap->schname));
				RISfil_copy_schema(schema_info, temp->master_schp->schemap, mask);
				schema_info->next = 0;
				return;
			}
		}
	}
	FIL_DBG(("couldnt find it in temp. list. looking in master list\n"));

	for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
	{
		if (strcmp(schema_info->schname, schemap->schemap->schname) == 0)
		{
			FIL_DBG(("found schname:%s in master list\n",
				schemap->schemap->schname));
			RISfil_copy_schema(schema_info,schemap->schemap,mask);
			schema_info->next = 0;

			return;
		}
	}
	LONGJMP(RIS_E_UNKNOWN_SCHEMA);
}

/******************************************************************************/

/*
** Put information from an risschema struct into the dictionary file.
** Duplicate schnames are not allowed.
*/

extern void RISfil_put_schema(
	risschema	*schema_info)
{
	filsch_list	*schemap;
	filsch_tmp_list *tmp_schp;

    FIL_DBG(("RISfil_put_schema(schema_info:0x%x)\n",schema_info));
    FIL_DBG(("schname:<%s> secure:<%c> schowner:<%s> dbid:%d\n",
		schema_info->schname, schema_info->secure,
		schema_info->schowner, schema_info->dbid));

	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_WRITE_TRANSACTION);

if (RISfil_debug) RISfil_print_lists();

	/*
	**  Check for existing schema with same name and 
	**  Check for duplicate user/db combination
	*/
	for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
	{
		if (!strcmp(schema_info->schname, schemap->schemap->schname))
		{
			LONGJMP(RIS_E_DUP_SCHNAME);
		}
		/*
		**  Check for duplicate user/db combinations
		*/
		if (strcmp(schema_info->schowner, schemap->schemap->schowner) == 0 &&
			schema_info->dbid == schemap->schemap->dbid &&
			!(schema_info->privilege & CRE_SCH_USING_FLAG))
		{
			FIL_DBG(("schema:<%s> and schema:<%s> both define user:<%s> dbid:%d\n",
				schema_info->schname, schemap->schemap->schname, 
				schema_info->schowner, schemap->schemap->dbid));
			LONGJMP(RIS_E_DUP_USR_DBID);
		}
	}
	/*
	**	Add new schema
	*/
	tmp_schp = ALLOCT(filsch_tmp_list);
	tmp_schp->tmp_schemap = ALLOCT(risschema);
	RISfil_copy_schema(tmp_schp->tmp_schemap, schema_info, ALL_FLAG);
	tmp_schp->next = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;
	RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list = tmp_schp;

	/*
	**	Update timestamp;
	*/
	RISfil_timestamp = time(0);

if (RISfil_debug) RISfil_print_temp_list(RIS_stmt->stmt_id);
    FIL_DBG(("RISfil_put_schema: returning\n"));
}

/******************************************************************************/

/*
** Remove a schema from the dictionary file.  The name of the schema to be 
** removed should be in the schname field of the risschema struct.
*/

static void delete_schema(
	risschema	*schema_info,
	int			rm_db_flag)
{
	unsigned short dropped_dbid;
	risdb		drop_db;
	filsch_list	*schemap;
	filsch_list	**schemapp;
	filsch_tmp_list *tmp_schp;

	FIL_DBG(("RISfil_delete_schema(schema:0x%x, rm_db_flag:%d)\n",
		schema_info, rm_db_flag));

	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_WRITE_TRANSACTION);

	for (schemapp = &RISfil_schema_list;
	 	 (*schemapp);
		 schemapp = &((*schemapp)->next))
	{
		if (strcmp(schema_info->schname, (*schemapp)->schemap->schname) == 0)
		{
			if (!(tmp_schp=RISfil_set_sch_tmp_list((*schemapp))))
			{
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			/*
			**	Drop the schema from the schema file.
			*/
			dropped_dbid = (*schemapp)->schemap->dbid;
			tmp_schp->tmp_schemap = 0;

			if (rm_db_flag)
			{
				/*
				**	Check if any other schemas on database, if not
				**	drop the db from the schema file.
				*/
				for (schemap = RISfil_schema_list;
					 schemap;
					 schemap = schemap->next)
				{
					if ((schemap != tmp_schp->master_schp) &&
						(schemap->schemap->dbid == dropped_dbid))
					{
						FIL_DBG(("found schema:0x%x on db id:%d\n",
							schemap->schemap, dropped_dbid));
						break;
					}
				}
				if (!schemap)
				{
					/*
					**	got thru the schema list without finding dbid, so
					**	drop db with dbid
					*/
					FIL_DBG(("no more schemas on db, drop dbid:%d\n",
						dropped_dbid));
					drop_db.dbid = dropped_dbid;
					RISfil_delete_db(&drop_db);
				}
			}

			/*
			**	Update timestamp;
			*/
			RISfil_timestamp = time(0)+1; /* TR 439502499 DDF */

if (RISfil_debug) RISfil_print_temp_list(RIS_stmt->stmt_id);

			return;
		}
	}
	LONGJMP(RIS_E_UNKNOWN_SCHEMA);
}

/******************************************************************************/

extern void RISfil_delete_schema_no_rm_db(
	risschema * schema_info)
{
	FIL_DBG(("RISfil_delete_schema_no_rm_db(schema:0x%x)\nschname:<%s>\n",
		schema_info, schema_info->schname));

	delete_schema(schema_info, 0);	/* the 0 means don't remove database */
}

/******************************************************************************/

extern void RISfil_delete_schema(
	risschema * schema_info)
{
	FIL_DBG(("RISfil_delete_schema(schema:0x%x)\nschname:<%s>\n", schema_info,
		schema_info->schname));

	delete_schema(schema_info, 1);	/* the 1 means remove database if needed */
}

/******************************************************************************/

/*
** Update a schema in the dictionary file.  The name of the schema to be 
** updated should be in the schname field of the risschema struct.
** The mask indicates what values are to be updated.
*/

extern void RISfil_update_schema(
	risschema	*schema_info,
	int			mask)
{
	filsch_tmp_list	*schlistp;
	filsch_list *schp;

	FIL_DBG(("RISfil_update_schema(schema_info:0x%x mask:%s)\n", 
		schema_info, schema_mask_name(mask)));
    FIL_DBG(("schname:<%s> passwd:<%s>\n", schema_info->schname,
		schema_info->passwd));
	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_WRITE_TRANSACTION);

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (schlistp = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list; 
		 	schlistp; schlistp = schlistp->next)
		{
			if (schlistp->tmp_schemap && !(strcmp(schema_info->schname, 
									  	schlistp->tmp_schemap->schname)))
			{
				FIL_DBG(("found temp. schema \n"));
				RISfil_copy_schema(schlistp->tmp_schemap, schema_info, mask);
				RISfil_timestamp = time(0);
				return;
			}
		}
	}
	FIL_DBG(("did not find temp. schema , looking in master list\n"));
	for (schp = RISfil_schema_list; schp; schp = schp->next)
	{
		if (strcmp(schema_info->schname, schp->schemap->schname) == 0)
		{
			FIL_DBG(("found schema in master list\n"));
			if (!(schlistp=RISfil_set_sch_tmp_list(schp)))
			{
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			RISfil_copy_schema(schlistp->tmp_schemap, schema_info, mask);
			RISfil_timestamp = time(0);
			return;
		}
	}
	LONGJMP(RIS_E_UNKNOWN_SCHEMA);
}

/******************************************************************************/

/*
** Get information about all schemas from the dictionary file and put it into
** risschema structs.  
*/

extern void RISfil_get_all_schemas(
			risschema	**schema_list,
			int			mask)
{
	auto	filsch_list	*schemap;
	auto	risschema	*schema_info;

	FIL_DBG(("RISfil_get_all_schemas(schema_list:0x%x mask:%s)\n",
		schema_list, schema_mask_name(mask)));

	*schema_list = 0;
	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_ONLY_TRANSACTION);

	for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
	{
		schema_info = ALLOCT(risschema);
		RISfil_copy_schema(schema_info,schemap->schemap, mask);
		schema_info->next = 0;

		*schema_list = schema_info;
		schema_list = &(schema_info->next);
	}
}

/******************************************************************************/
/*
** Check if there is any standard or secure schema defined on a given database.
*/

extern int RISfil_has_any_schema(
	short	dbid)
{
	filsch_tmp_list	*schlistp;
	filsch_list *schp;
	int	temp_schema = 0;
	int	master_schema = 0;

	FIL_DBG(("RISfil_has_any_schema(dbid:%d)\n", dbid));
	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_ONLY_TRANSACTION);

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (schlistp = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list; 
		 	schlistp; schlistp = schlistp->next)
		{
			if ((!schlistp->tmp_schemap) && (schlistp->master_schp) &&
				(schlistp->master_schp->schemap->dbid == dbid)) 
			{
				FIL_DBG(("found temp. schema \n"));
				temp_schema++;
			}
		}
	}
	FIL_DBG(("looking standard schemas in master list\n"));
	for (schp = RISfil_schema_list; schp; schp = schp->next)
	{
		if (schp->schemap->dbid == dbid)
		{
			FIL_DBG(("found schema in master list\n"));
			master_schema++;
		}
	}
	FIL_DBG(("RISfil_has_any_schema: %d\n",
		temp_schema != master_schema));
	return ((temp_schema != master_schema));
}

/******************************************************************************/
/*
** Check if there is any standard schema defined on a given database.
*/

extern int RISfil_has_standard_schema(
	short	dbid)
{
	filsch_tmp_list	*schlistp;
	filsch_list *schp;
	int	temp_standard_schema = 0;
	int	master_standard_schema = 0;

	FIL_DBG(("RISfil_has_standard_schema(dbid:%d)\n", dbid));
	/*
	**	begin transaction
	*/
	RISfil_begin_schema_transact(READ_ONLY_TRANSACTION);

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (schlistp = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list; 
		 	schlistp; schlistp = schlistp->next)
		{
			if (((!schlistp->tmp_schemap) && (schlistp->master_schp) &&
				(schlistp->master_schp->schemap->dbid == dbid) &&
				(schlistp->master_schp->schemap->secure != 'S')) ||
				((schlistp->tmp_schemap) && (schlistp->master_schp) &&
				(schlistp->master_schp->schemap->dbid == dbid) &&
				(schlistp->master_schp->schemap->secure != 'S') &&
				(schlistp->tmp_schemap->secure == 'S')))
			{
				FIL_DBG(("found temp. standard schema \n"));
				temp_standard_schema++;
			}
		}
	}
	FIL_DBG(("looking standard schemas in master list\n"));
	for (schp = RISfil_schema_list; schp; schp = schp->next)
	{
		if ((schp->schemap->secure != 'S') && (schp->schemap->dbid == dbid)) 
		{
			FIL_DBG(("found standard schema in master list\n"));
			master_standard_schema++;
		}
	}
	FIL_DBG(("RISfil_has_standard_schema: %d\n",
		temp_standard_schema != master_standard_schema));
	return ((temp_standard_schema != master_standard_schema));
}

/******************************************************************************/
