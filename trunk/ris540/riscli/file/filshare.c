/*
**	NAME:							filshare.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**  	common file functions. (originally in FILfile.c)
**		
**	
**	REVISION HISTORY:
**		10/24/94 -Radha 
**			Added changes for MSSQL data server.
*/

/*
**	DEFINES
*/

/*
**	INCLUDES
*/
#include "file.h"

/*
**      FUNCTION PROTOTYPES
*/
#define filshare_c
#include "comdebug.prt"
#include "ccocmpar.prt"
#include "filshare.prt"
#include "comjmp.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISfil_verify_db_list()
{
	int			i, j;
	fildb_list		*db1, *db2;
	filsch_list	*schemap;

	FIL_DBG(("RISfil_verify_db_list()\n"));

	for (db1 = RISfil_db_list; db1; db1 = db1->next)
	{
		/*
		**	Check for valid dbid;
		*/
		if (db1->dbp->dbid == 0)
		{
			FIL_DBG(("Invalid dbid:%d\n", db1->dbp->dbid));
			LONGJMP(RIS_E_INV_DBID);
		}

		/*
		**	Check for duplicate dbids
		*/
		for (db2 = db1->next; db2; db2 = db2->next)
		{
			/*
			**	Check for duplicate dbids
			*/
			if (db1->dbp->dbid == db2->dbp->dbid)
			{
				FIL_DBG(("Found dbid:%d twice in db_list\n", db1->dbp->dbid));
				LONGJMP(RIS_E_DUP_DBID);
			}
		}

		/*
		**	Check dtype
		*/
		if (db1->dbp->dtype != 'X' &&
			db1->dbp->dtype != 'I' &&
			db1->dbp->dtype != 'O' &&
			db1->dbp->dtype != 'D' &&
			db1->dbp->dtype != '4' &&
			db1->dbp->dtype != 'Y' &&
			db1->dbp->dtype != 'M' &&
			db1->dbp->dtype != 'R')
		{
			FIL_DBG(("dbid:%d has an invalid dtype\n", db1->dbp->dbid));
			LONGJMP(RIS_E_INV_DTYPE);
		}

		/*
		** Check protocols & netaddrs
		*/
		for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		{
			/*
			**	Check protocols
			*/
			if (db1->dbp->pathways[i].protocol)
			{
				if (db1->dbp->pathways[i].protocol != 'X' &&
					db1->dbp->pathways[i].protocol != 'T' &&
					db1->dbp->pathways[i].protocol != 'D' &&
					db1->dbp->pathways[i].protocol != 'I')
				{
					FIL_DBG(("dbid:%d has an invalid protocol\n", db1->dbp->dbid));
					LONGJMP(RIS_E_INV_PROTOCOL);
				}

				for (j = i + 1; j < RIS_MAX_PROTOCOLS; j++)
					if (db1->dbp->pathways[i].protocol == db1->dbp->pathways[j].protocol)
					{
						FIL_DBG(("dbid:%d has an duplicate protocol\n",
							db1->dbp->dbid));
						LONGJMP(RIS_E_DUP_PROTOCOL);
					}
			}

			/*
			**	Check if netaddr but no protocol
			*/
			if (db1->dbp->pathways[i].netaddr[0] &&
				!db1->dbp->pathways[i].protocol)
			{
				FIL_DBG(("dbid:%d has a netaddr but no protocol\n", db1->dbp->dbid));
				LONGJMP(RIS_E_NETADDR_NO_PROTOCOL);
			}

			/*
			**	Check if protocol but no netaddr 
			*/
			if (db1->dbp->pathways[i].protocol && !db1->dbp->pathways[i].netaddr[0])
			{
				FIL_DBG(("dbid:%d has a protocol but no netaddr\n", db1->dbp->dbid));
				LONGJMP(RIS_E_PROTOCOL_NO_NETADDR);
			}
		}

		/*
		**	Check for duplicate dbs
		*/
		for (db2 = db1->next; db2; db2 = db2->next)
		{
			if(RIScco_compare_dbs(db1->dbp,db2->dbp,NOT_ALL_PARMS)==SAME_DATABASE)
			{
				FIL_DBG(("dbid:%d and dbid:%d are the same database\n",
					db1->dbp->dbid, db2->dbp->dbid));
				LONGJMP(RIS_E_DUP_DATABASE);
			}
		}

		/*
		**	Check if dbid is refered to be a schema;
		*/
		for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
			if (db1->dbp->dbid == schemap->schemap->dbid) break;
		if (!schemap)
		{
			FIL_DBG(("dbid:%d doesn't have an schema\n", db1->dbp->dbid));
			LONGJMP(RIS_E_DB_NO_SCHEMA);
		}
	}

	FIL_DBG(("RISfil_verify_db_list:returning\n"));
}

/******************************************************************************/

extern void RISfil_verify_schema_list()
{
	fildb_list		*db;
	filsch_list	*sch1, *sch2;
	risgrantee	**granteep;

	FIL_DBG(("RISfil_verify_schema_list()\n"));

	for (sch1 = RISfil_schema_list; sch1; sch1 = sch1->next)
	{
		/*
		**	Make sure all schema dbid's are valid
		*/
		for (db = RISfil_db_list; db; db = db->next)
		{
			if (sch1->schemap->dbid == db->dbp->dbid) break;
		}
		if (!db)
		{
			FIL_DBG(("schema:<%s> has an invalid dbid:%d\n", 
				sch1->schemap->schname, sch1->schemap->dbid));
			LONGJMP(RIS_E_INV_SCHEMA_DBID);
		}

		for (sch2 = sch1->next; sch2; sch2 = sch2->next)
		{
			/*
			**	Check for duplicate schnames
			*/
			if (!strcmp(sch1->schemap->schname, sch2->schemap->schname))
			{
				FIL_DBG(("Found schname:<%s> twice in schema_list\n",
					sch1->schemap->schname));
				LONGJMP(RIS_E_DUP_SCHNAME);
			}
			/*
			**	Check for duplicate user/db combinations, only for
			**  non-secure schema
			*/
			/*
			if (strcmp(sch1->schemap->schowner, sch2->schemap->schowner) == 0 &&
				sch1->schemap->dbid == sch2->schemap->dbid &&
				sch1->schemap->secure != 'S' && sch2->schemap->secure != 'S')
			{
				FIL_DBG(("schema:<%s> and schema:<%s> both define schowner:<%s> dbid:%d\n", sch1->schemap->schname, sch2->schemap->schname, sch1->schemap->schowner, sch1->schemap->dbid));
				LONGJMP(RIS_E_DUP_USR_DBID);
			}
			*/
		}

		/*
		**	Remove an unknown grantee schemas
		*/
		granteep = &sch1->schemap->grantee;
		while (*granteep)
		{
			for (sch2 = RISfil_schema_list; sch2; sch2 = sch2->next)
			{
				if (!strcmp((*granteep)->schname, sch2->schemap->schname))
					break;
			}

			if (!sch2)
			{
				/*
				**	Unknown grantee, remove it.
				*/
				(*granteep) = (*granteep)->next;
			}
			else
			{
				/*
				**	Found it (or running upgrade and ignoring the fact that
				**	it is missing), look at the next grantee
				*/
				granteep = &((*granteep)->next);
			}
		}
	}

	FIL_DBG(("RISfil_verify_schema_list: returning\n"));
}

/******************************************************************************/

extern void RISfil_reset_master_sch_ptrs()
{
	filsch_list *schp;
	filsch_tmp_list *tmp_schp;

	FIL_DBG(("RISfil_reset_master_sch_ptrs()\n"));

	if (RISfil_schema_tmp_list[RIS_stmt->stmt_id])
	{
		for (tmp_schp=RISfil_schema_tmp_list[RIS_stmt->stmt_id]->list;
			 tmp_schp; tmp_schp = tmp_schp->next)
		{
			for (schp=RISfil_schema_list; schp; schp = schp->next)
			{
				if ((tmp_schp->tmp_schemap && 
					!(strcmp(tmp_schp->tmp_schemap->schname, 
						schp->schemap->schname)))	||
					(tmp_schp->master_schp && 
					!(strcmp(tmp_schp->master_schp->schemap->schname,
						 schp->schemap->schname))))
				{
					tmp_schp->master_schp = schp;
					FIL_DBG(("master_schp reset. schname:%s\n",
						schp->schemap->schname));
					break;
				}
			}
		}
	}
	FIL_DBG(("RISfil_reset_master_sch_ptrs done..\n"));
}

/******************************************************************************/

extern void RISfil_reset_master_db_ptrs()
{
	fildb_list *dbp;
	fildb_tmp_list *tmp_dbp, *tmp1;

	FIL_DBG(("RISfil_reset_master_db_ptrs()\n"));

	tmp1 = RISfil_db_tmp_list[RIS_stmt->stmt_id];
	for (tmp_dbp=RISfil_db_tmp_list[RIS_stmt->stmt_id];
		 tmp_dbp; tmp_dbp = tmp_dbp->next)
	{
		for (dbp=RISfil_db_list; dbp; dbp = dbp->next)
		{
			if ((tmp_dbp->tmp_dbp && 
				(tmp_dbp->tmp_dbp->dbid == dbp->dbp->dbid)) ||
				(tmp_dbp->master_dbp && 
				(tmp_dbp->master_dbp->dbp->dbid == dbp->dbp->dbid)))
			{
				tmp_dbp->master_dbp = dbp;
				FIL_DBG(("master_dbp reset. dbid:%d\n",dbp->dbp->dbid));
				break;
			}
		}
		if (!dbp)
		{
			FIL_DBG(("couldnt find master for db 0x%x\n", tmp_dbp));
			FIL_DBG(("removing it from tmp list.\n"));
			tmp1->next = tmp_dbp->next;
			tmp_dbp = tmp1;
		}
		tmp1 = tmp_dbp;
	}
	FIL_DBG(("RISfil_reset_master_db_ptrs done..\n"));
}

/******************************************************************************/

extern void RISfil_print_lists()
{
	fildb_list		*db;
	filsch_list		*sch;

	RIScom_output_debug("RISfil_db_list: start\n");
	for (db = RISfil_db_list; db; db = db->next)
	{
		RIScom_output_debug("\ndb:0x%x update_lock_flag %d\n", 
			db->dbp, db->update_lock_flag);
		RIScom_output_debug(" dbname %s\n",db->dbp->dbname);
	}
	RIScom_output_debug("RISfil_db_list: end\n");

	RIScom_output_debug("RISfil_schema_list: start\n");
	for (sch = RISfil_schema_list; sch; sch = sch->next)
	{
		RIScom_output_debug("\nschema:0x%x update_lock_flag %d\n", 
			sch->schemap, sch->update_lock_flag);
		RIScom_output_debug(" schname %s\n",sch->schemap->schname);
	}
	RIScom_output_debug("RISfil_schema_list: end\n");

}

/******************************************************************************/

extern void RISfil_print_temp_list(
	int stmt_id)
{
	fildb_tmp_list		*db;
	filsch_tmp_list		*sch;

	RIScom_output_debug("RISfil_db_tmp_list: start\n");
	for (db = RISfil_db_tmp_list[stmt_id]; db; db = db->next)
	{
		RIScom_output_debug("\ntmp_dbp:0x%x stmt_id %d\n", 
			db->tmp_dbp, stmt_id);
		RIScom_output_debug(" tmp_dbname %s\n",
			db->tmp_dbp?db->tmp_dbp->dbname:"NULL");
		if (db->master_dbp)
		{
			RIScom_output_debug("\nmaster_dbp:0x%x update_lock_flag %d", 
				db->master_dbp->dbp, db->master_dbp->update_lock_flag);
			RIScom_output_debug(" dbname %s\n",db->master_dbp->dbp->dbname);
		}
		else
		{
			RIScom_output_debug("New db, does not exist in master list\n");
		}
	}
	RIScom_output_debug("RISfil_db_tmp_list: end\n");

	RIScom_output_debug("RISfil_schema_tmp_list: start\n");
	if (RISfil_schema_tmp_list[stmt_id])
	{
		for (sch = RISfil_schema_tmp_list[stmt_id]->list; sch; sch = sch->next)
		{
			RIScom_output_debug("\ntmp_schemap:0x%x stmt_id %d\n", 
				sch->tmp_schemap, stmt_id);
			RIScom_output_debug(" tmp_schemaname %s\n",
				sch->tmp_schemap?sch->tmp_schemap->schname:"NULL");
			if (sch->master_schp)
			{
				RIScom_output_debug("\nmaster_schp:0x%x update_lock_flag %d\n", 
					sch->master_schp->schemap,
					sch->master_schp->update_lock_flag);
				RIScom_output_debug(" schname %s\n",
					sch->master_schp->schemap->schname);
			}
			else
			{
				RIScom_output_debug(
					"New Schema,does not exist in master list\n");
			}
		}
	}
	RIScom_output_debug("RISfil_schema_tmp_list: end\n");
}

