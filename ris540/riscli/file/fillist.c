/*
**	NAME:							fillist.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "file.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define fillist_c
#include "comdebug.prt"
#include "comalloc.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "fillist.prt"
#include "filshare.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern fildb_tmp_list *RISfil_set_db_tmp_list(
	fildb_list *dbp)
{
	fildb_tmp_list *databp, *dblistp;

	FIL_DBG(("RISfil_set_db_tmp_list dbp 0x%x\n",dbp));

	for (databp = RISfil_db_tmp_list[RIS_stmt->stmt_id];
		 databp; databp = databp->next)
	{
		if ((databp->tmp_dbp && (databp->tmp_dbp->dbid==dbp->dbp->dbid)) ||
			(databp->master_dbp && (databp->master_dbp->dbp->dbid==dbp->dbp->dbid)))
		{
			dbp->update_lock_flag = UPDATE_LOCK_ON;
			if (!databp->tmp_dbp)
			{
				databp->tmp_dbp = ALLOCT(risdb);
				RISfil_copy_db (databp->tmp_dbp, dbp->dbp, ALL_FLAG);
			}
			FIL_DBG(("found dbid:%d\n",dbp->dbp->dbid));
			return (databp);
		}
	}

	if (!databp)
	{
		/*
		** Initialize the temporary list for this statement.
		*/
		FIL_DBG(("Initializing temp. db list\n"));
		dblistp = ALLOCT(fildb_tmp_list);
		dblistp->next = RISfil_db_tmp_list[RIS_stmt->stmt_id];
		RISfil_db_tmp_list[RIS_stmt->stmt_id] = dblistp;
		dblistp->master_dbp = dbp;

		dbp->update_lock_flag = UPDATE_LOCK_ON;
		dblistp->tmp_dbp = ALLOCT(risdb);
		RISfil_copy_db (dblistp->tmp_dbp, dbp->dbp, ALL_FLAG);
		if (RISfil_debug) 
		{
			RISfil_print_temp_list(RIS_stmt->stmt_id);
		}
		FIL_DBG(("Returning dblistp:0x%x\n",dblistp));
		return (dblistp);
	}
	FIL_DBG(("Returning null\n"));
	return ((fildb_tmp_list *)0);
}

/******************************************************************************/

extern filsch_tmp_list * RISfil_set_sch_tmp_list(
    filsch_list *schp)
{
	filsch_tmp_list *tmp_schp=0, *schlistp;

    FIL_DBG(("RISfil_set_sch_tmp_list schp 0x%x\n",schp));

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (tmp_schp = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;
	 		tmp_schp; tmp_schp = tmp_schp->next)
		{
			if ((tmp_schp->tmp_schemap &&
				!(strcmp(tmp_schp->tmp_schemap->schname,schp->schemap->schname)))||
				(tmp_schp->master_schp &&
				!(strcmp(tmp_schp->master_schp->schemap->schname,
					schp->schemap->schname))))
			{
           		schp->update_lock_flag = UPDATE_LOCK_ON;
           		if (!tmp_schp->tmp_schemap)
           		{
               		tmp_schp->tmp_schemap = ALLOCT(risschema);
               		RISfil_copy_schema (tmp_schp->tmp_schemap, schp->schemap, 
						ALL_FLAG);
           		}
				FIL_DBG(("found schname:%s\n", schp->schemap->schname));
				return (tmp_schp);
			}
		}
	}
    if (!tmp_schp)
    {
		/*
		** Initialize the temporary list for this statement.
		*/
		FIL_DBG(("Initializing temp. schema list\n"));
		schlistp = ALLOCT(filsch_tmp_list);
		schlistp->next = RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;
		RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list = schlistp;
		schlistp->master_schp = schp;

		schp->update_lock_flag = UPDATE_LOCK_ON;
		schlistp->tmp_schemap = ALLOCT(risschema);
		RISfil_copy_schema (schlistp->tmp_schemap, schp->schemap, ALL_FLAG);

if (RISfil_debug) RISfil_print_temp_list(RIS_stmt->stmt_id);

		return (schlistp);
    }

	return ((filsch_tmp_list *)0);
}

/*****************************************************************************/
