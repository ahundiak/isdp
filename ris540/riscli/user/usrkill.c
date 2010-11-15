/*
**	NAME:							usrkill.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/86
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <errno.h>
#include "riscli.h"
#include "risasync.h"
#include "riscom.h"
#include "rishshtb.h"
#include "rismem.h"
#include "riswarn.h"
#include "user.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrkill_c
#include "ccoinvid.prt"
#include "ccostmgr.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#if defined(clipper) || defined(__clipper__)
#include "comwrap.prt"
#endif
#include "dicrdcss.prt"
#include "dicundss.prt"
#include "netgnerc.prt"
#include "usrexec.prt"
#include "usrsndrc.prt"
#include "usrkill.prt"
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

extern void RISusr_check_deadbeat_srvs()
{
	risschema * schema;
	risschema * next;

	USR_DBG(("RISusr_check_deadbeat_srvs()\n"));

	for (schema=RIS_deadbeat_srvs;schema;)
	{
		next = schema->next;
		if (!schema->net->connection_open)
		{
			RISusr_remove_deadbeat_srv(schema);
		}
		schema = next;
	}

	USR_DBG(("RISusr_check_deadbeat_srvs: complete\n"));
}

/******************************************************************************/

extern void RISusr_add_deadbeat_srv(
	risschema	*schema)
{

	risschema * deadbeat_schema;

	USR_DBG(("RISusr_add_deadbeat_srv(schema:0x%x)\n",schema));

	if (!schema)
	{
		USR_DBG(("RISusr_add_deadbeat_srv:complete\n"));
		return;
	}

	deadbeat_schema = RIScco_alloc_risschema();
	deadbeat_schema->net = RIScco_alloc_net_s();
	strcpy(deadbeat_schema->schname,schema->schname);
	memcpy((char *)deadbeat_schema->net,(char *)schema->net,sizeof(net_s));
	deadbeat_schema->next = RIS_deadbeat_srvs;
	RIS_deadbeat_srvs = deadbeat_schema;

	USR_DBG(("schema = <%s> pid = %d\n",
	 deadbeat_schema->schname,deadbeat_schema->net->id.shmem.pid));

	USR_DBG(("RISusr_add_deadbeat_srv:complete\n"));
}

/******************************************************************************/

extern void RISusr_remove_deadbeat_srv(
	risschema	*schema)
{
	risschema **schpp;

	USR_DBG(("RISusr_remove_deadbeat_srv(schema:0x%x)\n",schema));

	if (!schema)
	{
		USR_DBG(("RISusr_remove_deadbeat_srv:complete\n"));
		return;
	}

	/*
	**	stop server process if it exists
	*/
	if (schema->net)
	{
		if (!SETJMP()) NET_close(schema->net);
		RESETJMP();
		schema->net = 0;
	}

	/*
	** clear server info
	*/
	for (schpp = &RIS_deadbeat_srvs; *schpp; schpp = &(*schpp)->next)
	{
		if (*schpp == schema)
		{
			*schpp = (*schpp)->next;
			break;
		}
	}

	RIScco_free_net_s(schema->net);
	RIScco_free_risschema(schema);

	USR_DBG(("RISusr_remove_deadbeat_srv:complete\n"));
}

/******************************************************************************/

extern void RISusr_kill_srv(
	risschema	*schema,
	int			mode,
	int 		exec_mode)
{
	risschema 	**schpp;
	int			primary_swapped = 0;

	USR_DBG(("RISusr_kill_srv(schema:0x%x mode:0x%x exec_mode:0x%x)\n",
		schema,mode,exec_mode));

	if (!schema)
	{
		USR_DBG(("RISusr_kill_srv:complete\n"));
		return;
	}

	/*
	**	stop server process if it exists
	*/
	if (schema->net)
	{
		RIS_sdp->schema = schema;

		/* Dont send close schema code if we know the server is already dead */

		if (mode & CLOSE_SCHEMA)
		{
			if (!SETJMP()) 
			{

				/* set global for local servers */

				if (schema->net->protocol == SHMEM)
				{
					RIS_killing_srv_pid = schema->net->id.shmem.pid;
				}

				/* only send close schema if the server is still alive */

				if (schema->net->protocol != SHMEM ||
				 RISusr_check_server(schema->net))
				{
					RISusr_send_rec(RIS_CLOSE_SCHEMA_CODE, RIS_sdp,
									(unsigned short)exec_mode);
				}
			}
			RESETJMP();
/*
** If the RIS_CLOSE_SCHEMA_CODE call resulted in a RIS_E_SERVER_NOT_RESPONDING
** error, then it would have called RISusr_kill_srv and cleaned up the schema
** structures. Therefore check for NULL pointers.
*/
			/* reset the global to zero for local servers */

			if (IN_FINISH_MODE(exec_mode) &&
				(schema->net && schema->net->protocol == SHMEM))
			{
				RIS_killing_srv_pid = 0;
			}
		}

		if (IN_FINISH_MODE(exec_mode))
		{
			if (schema->net)
			{
				if (mode & CLOSE_NET)
				{
					if (!SETJMP())
					{
						NET_close(schema->net);
					}
					RESETJMP();
				}
				else
				{
					if (schema->net->protocol == SHMEM)
					{
						*schema->net->id.shmem.break_connectionp = 1;
						RISusr_add_deadbeat_srv(schema);
					}
				}
				schema->net = 0;
			}
		}
	}

	if (IN_FINISH_MODE(exec_mode))
	{
		/*
		**	clear default schema if it's going away
		*/
		if (RIS_default == schema)
		{
			RIS_default = 0;
		}

		/*
		** clear server info
		*/
		for (schpp = &RIS_srvs; *schpp; schpp = &(*schpp)->next)
		{
			if (*schpp == schema)
			{
				*schpp = (*schpp)->next;
				break;
			}
		}

		/*
		**	Close all cursors for schema
		*/
		RISusr_close_all_cursors_for_sch(schema);

		/*
		**	Remove schema from transaction
		*/
		RISusr_remove_sch_from_transact(schema);

    	/*
    	**  if the server is a primary schema of a superschema, operation is 
		**  similar to 'swap primary with secondary ' option of 
		**  redeclare superschema;provided a secondary exists else we undeclare.
		**  the superschema.
    	*/
    	if(schema->superschema_flag == PRIMARY_SCHEMA)
    	{
			/*
			**  Indicate that a primary server died
			*/
			SET_RIS_PRIM_SCH_WARNING(RIS_warning_flag);

			if(schema->sub_schp)
			{
                /*
                **  This primary is swapped and then dropped and so, it will be
                **  also reported secondary died.
                */
                primary_swapped = 1;

        		RISdic_swap(schema->sub_schp->schname, schema->super_schp);
			}
			else
			{
				RISdic_undecl_superschema(schema->super_schp->schname);
			}
    	}

		/*
		** invalidate stmts
		*/
		RIScco_invalidate_ids(schema, 0);/* 0 means leave schema pointers */

    	/*
    	**  if the server is a secondary schema of a superschema, operation is 
		**  similar to 'drop secondary' option of redeclare superschema.
    	*/
    	if(schema->superschema_flag == SECONDARY_SCHEMA)
    	{
            /*
            **  Indicate that a secondary server died
            */
            if( !primary_swapped )
            {
                SET_RIS_SEC_SCH_WARNING(RIS_warning_flag);
            }

        	RISdic_drop_secondary(schema->schname, schema->super_schp);
    	}

		if (mode & CLEAR_SCHEMA)
		{
			/*
			** invalidate stmts
			*/
			RIScco_invalidate_ids(schema, 1);/* 1 means clear schema pointers */
		}

		/*
		** Indicate that the server is no longer busy
		*/
		schema->srv_busy = 0;
		USR_DBG(("RISusr_kill_srv: RIS_default: <%s>\n",
			RIS_default ? RIS_default->schname : "NULL"));
	}

	USR_DBG(("RISusr_kill_srv:complete\n"));
}

/******************************************************************************/

extern void RISusr_kill_all_srvs()
{
	USR_DBG(("RISusr_kill_all_srvs()\n"));

	while (RIS_srvs) 
	{
		RISusr_kill_srv(RIS_srvs,CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET,SYNC_MODE);
	}

	USR_DBG(("RISusr_kill_all_srvs:complete\n"));
}

/******************************************************************************/

#if defined(WIN32)
extern struct event_info NTevents[];
#endif

extern int RISusr_check_server(
	struct net_s * net)
{
	char path[sizeof("/proc/00000")];
#if defined(unix)
	int status;
#endif
#if defined(clipper) || defined(__clipper__)
	struct stat buf;
#endif
	int return_status = 1;

	USR_DBG(("RISusr_check_server(net:0x%x)\n", net));

	if (net->protocol == SHMEM)
	{
		sprintf(path,"/proc/%d",net->id.shmem.pid);
		
		USR_DBG(("looking for server with pid = %d\n",net->id.shmem.pid));

#if defined(clipper) || defined(__clipper__)
		status = RIScom_stat(path,&buf);

		USR_DBG(("status = %d errno = %d process size = %d\n",status,errno,
			status ? 0 : buf.st_size));

		/*
		** the server is dead if process doesn't exist or is a zombie
		*/
    	if ((status && errno == ENOENT) || (!status && !buf.st_size))
		{
			return_status = 0;
		}
#endif
#if defined(unix)
		status = kill((pid_t)net->id.shmem.pid, 0);

		USR_DBG(("status = %d errno = %d\n",status,errno));

		/*
		** the server is dead if process doesn't exist or is a zombie
		*/
		if (status && (errno == ESRCH))
		{
		    return_status = 0;
		}
#endif
#if defined(WIN32)
		if (NTevents[net->id.shmem.semnum].server_died)
		{
			return_status = 0;
		}
#endif
	}
	USR_DBG(("RISusr_check_server: returning\n"));
	return return_status;
}

