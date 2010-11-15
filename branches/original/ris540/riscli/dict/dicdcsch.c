/*
**	NAME:							dicdcsch.c
**	AUTHORS:						Jin Jing
**	CREATION DATE:					6/93
**	ABSTRACT: 	
**			process the declare schema statement and construct
**			the risdclrschema node
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
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
#define dicdcsch_c
#include "ccooutpt.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "dicclsch.prt"
#include "dicdcsch.prt"
#include "diclook.prt"
#include "dicmisc.prt"
#include "dicopsch.prt"
#include "dictrans.prt"
#include "dicundss.prt"
#include "filtrans.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_declare_schema(
	ristree *tp,
	int exec_mode)
{
	rissuperschema	*ss_schema;
	risschema		*schema = 0;
	risdclrschema	*dschema;
	risdclrschema	*perm_dschema;
	risdclrschema	*temp_dschema;
	risdclrschema	**dschpp;
	char			*schname = tp->rhs->lhs->info.val;
	char			*schpass = tp->rhs->lhs->rhs->info.val;
	int 			open_flag = 0;
	int 			default_flag = 0;
	int 			status;
	int 			i;

	if (RISdic_debug)
	{
		RIScom_output_debug("RISdic_declare_schema(tp:0x%x exec_mode:0x%x)", 
			tp, exec_mode);
		RIScom_output_debug("\nschema to declare:<%s>", schname);
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

	if (tp->tok != RIS_TOK_DECLARE_SCHEMA)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (IN_START_MODE(exec_mode))
	{
		temp_dschema = ALLOCT(risdclrschema);
		strcpy(temp_dschema->schname, schname);
		RIScom_pd(schpass, temp_dschema->schpass);
		tp = tp->rhs->rhs;
		while (tp)
		{
			switch (tp->lhs->tok)
			{
				case RIS_TOK_USER:
					strcpy(temp_dschema->schuser,tp->lhs->info.val);
					RIScom_pd(tp->lhs->rhs->info.val, temp_dschema->schuserpd);
					break;

				case RIS_TOK_OSUSER:
					strcpy(temp_dschema->osuser,tp->lhs->info.val);
					RIScom_pd(tp->lhs->rhs->info.val, temp_dschema->osuserpd);
					break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			tp = tp->rhs;
		}

		dschema = RISdic_lookup_risdclrsch(schname);
		if ((i = RISdic_comp_dcschs(temp_dschema, dschema)) != 0)
		{
			schema = RISdic_lookup_schema(schname, HASH_TABLE);
			if (schema)
			{
				open_flag = 1;
				if (schema == RIS_default)
				{
					RIS_default = 0; 
						/* somethingelse needed here???? Jin */
					default_flag = 1;
				}
				/* close the schema and commit if it's open */
				if (!SETJMP()) RISdic_close_schema(schname, SYNC_MODE);
				RESETJMP();
			}
          			
			perm_dschema = RIScco_alloc_risdclrschema();
			memcpy(perm_dschema, temp_dschema, sizeof(risdclrschema));
			if (dschema)
			{
				/*
				** remove dschema in both dschema list and hash table
				*/
				for (dschpp = &RIS_declare_schema; *dschpp; 
					dschpp = &(*dschpp)->next)
				{
					if (*dschpp == dschema)
					{
						*dschpp = (*dschpp)->next;
						RISdic_free_dschema(dschema);
						break;
					}
				}
			}
			/* 
			** insert dschema in dschema list and hash table
			*/
			perm_dschema->next = RIS_declare_schema;
			RIS_declare_schema = perm_dschema;

			if (default_flag)
			{
       			RIS_default = 
					RISdic_default_schema(schname, schpass, exec_mode);
			}
			else if (open_flag) 
					schema = RISdic_open_schema(schname, exec_mode);
		}
	}

	RESETJMP();

	if (IN_START_MODE(exec_mode))
	{
		RISdic_commit_hash();
	}
	
	DIC_DBG(("RISdic_declare_schema: returning\n"));
}

/******************************************************************************/

extern void RISdic_undeclare_schema(
	ristree *tp,
	int exec_mode)
{
	ristree 		*temp_tp;
	risschema		*schema = 0;
	risdclrschema	*dschema;
	risdclrschema	*next_dschema;
	risdclrschema	**dschpp;
	int 			status;

	if (RISdic_debug)
	{
		RIScom_output_debug("RISdic_declare_schema(tp:0x%x exec_mode:0x%x)", 
			tp, exec_mode);
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

	if (tp->tok != RIS_TOK_UNDECLARE_SCHEMA)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (IN_START_MODE(exec_mode))
	{
		if (tp->rhs->lhs->tok == RIS_TOK_ALL)
		{
			dschema = RIS_declare_schema;
			while(dschema)
			{
				next_dschema = dschema->next;
				schema = RISdic_lookup_schema(dschema->schname, HASH_TABLE);
				if (schema)
				{
					if (schema == RIS_default)
					{
						RIS_default = 0; 
						/* Jin: somethingelse needed here????? */
					}
					/* close the schema and commit if it's open */
					if (!SETJMP()) 
						RISdic_close_schema(dschema->schname, SYNC_MODE);
					RESETJMP();
				}
				RISdic_free_dschema(dschema);
				dschema = next_dschema;
			}
			RIS_declare_schema = 0;
		}
		else	
		{
			for (temp_tp=tp->rhs->lhs->rhs; temp_tp; temp_tp=temp_tp->rhs)
			{
				dschema = RISdic_lookup_risdclrsch(temp_tp->lhs->info.val);
				if (dschema)
				{
					schema = RISdic_lookup_schema(dschema->schname, HASH_TABLE);
					if (schema)
					{
						if (schema == RIS_default)
						{
							RIS_default = 0; /* ????? */
						}
						/* close the schema and commit if it's open */
						if (!SETJMP())
							RISdic_close_schema(dschema->schname, SYNC_MODE);
						RESETJMP();
					}
					/*
					** remove dschema in both dschema list and hash table
					*/
					for (dschpp = &RIS_declare_schema; *dschpp; 
						dschpp = &(*dschpp)->next)
					{
						if (*dschpp == dschema)
						{
							*dschpp = (*dschpp)->next;
							RISdic_free_dschema(dschema);
							break;
						}
					}
				}
				else
				{
						LONGJMP(RIS_E_UNKNOWN_DECLARE_SCHEMA);
				}
			}
		}
	}

	RESETJMP();

	if (IN_START_MODE(exec_mode))
	{
		RISfil_commit_schema_transact();
		RISdic_commit_hash();
	}
	
	DIC_DBG(("RISdic_undeclare_schema: returning\n"));
}

/******************************************************************************/
/*
**	return 1: two schema declarations are NOT same;
**         0: otherwise;
*/
extern int RISdic_comp_dcschs(
	risdclrschema	*dschema1,
	risdclrschema	*dschema2)
{
	DIC_DBG(("RISdic_comp_dcschs dschema1 <0x%x> dschema2 <0x%x>\n", 
		dschema1, dschema2));

	if (!dschema1 || !dschema2)
	{
		DIC_DBG(("RISdic_comp_dcschs: returning 1\n"));
		return (1);
	}

	if (RIScom_pdcmp(dschema1->schpass, dschema2->schpass) ||
		strcmp(dschema1->schuser, dschema2->schuser) ||
		RIScom_pdcmp(dschema1->schuserpd, dschema2->schuserpd) ||
		strcmp(dschema1->osuser, dschema2->osuser) ||
		RIScom_pdcmp(dschema1->osuserpd, dschema2->osuserpd))
	{
		DIC_DBG(("RISdic_comp_dcschs: returning 1\n"));
		return (1);
	}
	else
	{
		DIC_DBG(("RISdic_comp_dcschs: returning 0\n"));
		return (0);
	}
}

/******************************************************************************/

extern risdclrschema *RISdic_lookup_risdclrsch(
	char *name)
{
	risdclrschema **dschpp;

	DIC_DBG(("RISdic_lookup_risdclrsch name <%s>\n", 
		STRING(name)));
	/*
	**  Look for declared schema in hash table
	*/
	for (dschpp = &RIS_declare_schema; *dschpp;
		dschpp = &(*dschpp)->next)
	{
		if (!strcmp(name, (*dschpp)->schname))
		{
			DIC_DBG(("RISdic_lookup_risdclrsch: returning <0x%x>\n", *dschpp));
			return *dschpp;
		}
	}

	DIC_DBG(("RISdic_lookup_risdclrsch: returning NULL \n"));
	return(NULL);
}

/******************************************************************************/

extern void RISdic_update_declare_schema(
	char *schname,
	char *user,
	char *passwd,
	int  mask)
{
	risdclrschema	*dschema;

	DIC_DBG(("RISdic_update_declare_schema(schname <%s> user <%s> passwd <%s> mask %d\n", schname, user, passwd, mask));

	dschema = RISdic_lookup_risdclrsch(schname);
	if (dschema)
	{
		switch (mask)
		{
			case SCHPASS_FLAG:
				RIScom_pd(passwd, dschema->schpass);
			break;
			case SCHUSPD_FLAG:
				if (strlen(dschema->schuser))
				{
					RIScom_pd(passwd, dschema->schuserpd);
				}
			break;
			case OSUSRPD_FLAG:
				if (strlen(dschema->osuser))
				{
					strcpy(dschema->osuser, user);
					RIScom_pd(passwd, dschema->osuserpd);
				}
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	DIC_DBG(("RISdic_update_declare_schema: returning\n"));
}

/******************************************************************************/
