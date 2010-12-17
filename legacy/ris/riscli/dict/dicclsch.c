/*
**	NAME:							DICclose_sch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
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
#define dicclsch_c
#include "ccoschid.prt"
#include "ccosqlca.prt"
#include "comfree.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "dicclsch.prt"
#include "dicrem.prt"
#include "diclook.prt"
#include "dictrans.prt"
#include "dicundss.prt"
#include "filtrans.prt"
#include "usrkill.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_close_schema(
			char		*schname,
			int			exec_mode)
{
	int				status;
	risschema		*schema;
	rissuperschema	*ss_schema;

	DIC_DBG(("RISdic_close_schema(schname:<%s> exec_mode:%d)\n",
		STRING(schname), exec_mode));

	status = SETJMP();
	if (status)
	{
		RESETJMP();
		RIScco_push_risca_dbca();

		RISdic_rollback_hash();
		RISfil_rollback_schema_transact();

		RIScco_pop_risca_dbca();
		LONGJMP(status);
	}

   	/* if its a superschema dont proceed further */
	if (IN_START_MODE(exec_mode) && 
		(ss_schema=RISdic_find_supersch(schname)))
   	{
        	LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
	}

	schema = RISdic_lookup_schema(schname, HASH_TABLE);
	if (schema)
	{
		if (IN_START_MODE(exec_mode) && 
			(schema->superschema_flag == PRIMARY_SCHEMA ||
			 schema->superschema_flag == SECONDARY_SCHEMA))
		{
			LONGJMP(RIS_E_CANT_EXEC_STMT_ON_SUPERSCHEMA);
		}

		RISusr_kill_srv(schema,CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET, exec_mode);
/*
** Added a check by calling RISdic_lookup_schema again as the call to
** RISusr_kill_srv may have potentially removed the schema from the hash table
** if a RIS_E_SERVER_NOT_RESPONDING error was detected. - 12/25/92
*/
		schema = RISdic_lookup_schema(schname, HASH_TABLE);
		if (IN_FINISH_MODE(exec_mode))
		{
			RISdic_remove_hash(RIS_TOK_SCHEMA, schema);
		}
	}
    else
    {
		if (!RISdic_lookup_schema(schname, SCHEMA_FILE))
		{
           	LONGJMP(RIS_E_UNKNOWN_SCHEMA);
		}
	}
	RESETJMP();

	if (IN_FINISH_MODE(exec_mode))
	{
		RISdic_commit_hash();
	}

	RISfil_commit_schema_transact();

	if (IN_FINISH_MODE(exec_mode))
	{
		if (schema)
		{
			FREES(schema->schid);
			RIScco_clear_schema_id(schema->schid);
		}
	}
	DIC_DBG(("RISdic_close_schema:returning\n"));
}

/******************************************************************************/

extern void RISdic_close_mult_schemas(
	ristree * tp,
	int exec_mode)
{

	DIC_DBG(("RISdic_close_mult_schemas(tp:0x%x exec_mode:0x%x)\n",tp,exec_mode));

	if (tp->rhs->tok == RIS_TOK_ALL)
	{
		if (IN_START_MODE(exec_mode))
		{
			RISdic_close_all_schemas();
		}
	}
	else
	{
		for (tp=tp->rhs;tp;tp=tp->rhs)
		{
			if (tp->rhs)
			{
				if (IN_START_MODE(exec_mode))
				{
					RISdic_close_schema(tp->lhs->info.val, SYNC_MODE);
				}
			}
			else
			{
				RISdic_close_schema(tp->lhs->info.val, exec_mode);
			}
		}
	}

	DIC_DBG(("RISdic_close_mult_schemas:returing\n"));
}

/******************************************************************************/

extern void RISdic_close_all_schemas()
{
	risschema	*schema, *next_schema;

	DIC_DBG(("RISdic_close_all_schemas()\n"));

	/*
	**	NOTE:	We have to traverse the schema list in this strange way
	**			because RISdic_close_schema removes the schema from the
	**			list.  By saving a pointer to the next schema, we won't
	**			loose our place in the list when this happens.
	*/
	schema = RIS_srvs;
	while(schema)
	{
		next_schema = schema->next;
		RISdic_close_schema(schema->schname, SYNC_MODE);
		schema = next_schema;
	}

	DIC_DBG(("RISdic_close_all_schemas:returing\n"));
}

/******************************************************************************/
