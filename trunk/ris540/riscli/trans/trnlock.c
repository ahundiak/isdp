/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnlock.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml lock statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "trans.h"


/*
**	FUNCTION PROTOTYPES
*/
#define trnlock_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trnfrom.prt"
#include "trnlock.prt"
#include "trnshare.prt"

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

/*
** transform lock table parse tree into rax
** tp = lock table parse tree
** lock table is an RIS extension to the sql standard
*/

extern void RIStrn_lock_tables(
	ristree * tp)
{
	ristree * modep;
	ristree * sharep;
	ristree * exclusivep;
	ristree * defaultp;
	ristree * tablep;
	risschema *schema = 0;

TRN_DBG(("\nRIStrn_lock_tables tp = 0x%x\n",tp));

	sharep = 0;
	exclusivep = 0;
	defaultp = 0;
	for (modep = tp->rhs; modep; modep = modep->rhs)
	{
		switch(modep->lhs->tok)
		{
			case RIS_TOK_SHARE:
				if (sharep)
				{
					TRN_ERR_RETURN(RIS_E_DUP_LOCK_MODE, modep->lhs->pos);
				}
				else
				{
					sharep = modep->lhs;
					sharep->rhs = sharep->rhs->rhs;
				}
				break;

			case RIS_TOK_EXCLUSIVE:
				if (exclusivep)
				{
					TRN_ERR_RETURN(RIS_E_DUP_LOCK_MODE, modep->lhs->pos);
				}
				else
				{
					exclusivep = modep->lhs;
					exclusivep->rhs = exclusivep->rhs->rhs;
				}
				break;

			case RIS_TOK_DEFAULT:
				if (defaultp)
				{
					TRN_ERR_RETURN(RIS_E_DUP_LOCK_MODE, modep->lhs->pos);
				}
				else
				{
					defaultp = modep->lhs;
					defaultp->rhs = defaultp->rhs->rhs;
				}
			break;
		}
	}

	for (modep = tp->rhs; modep; modep = modep->rhs)
	{
		for (tablep = modep->lhs->rhs; tablep; tablep = tablep->rhs)
		{
			RIStrn_table_name_w_type(tablep->lhs,ANY_ACCESS,schema,0);
			/*
			** Check for RIS_upgrade_flag is added for the risupgrade 
			** utility to work so that it could lock ris_tables and
			** ris_columns which are base tables for V4 but are views
			** in V5 RIS. RAJU 03/24/94.
			*/
			if (!RIS_upgrade_flag && tablep->lhs->info.tab->tabtype == 'V')
			{
				TRN_ERR_RETURN(RIS_E_BASE_TABLE_ONLY,tablep->lhs->pos);
			}

			RIStrn_det_dic_tab_mod(tablep->lhs->info.tab->tabname,
								   RIS_TOK_LOCK_TABLES);
			RIStrn_check_dict_select(tablep->lhs->info.tab->tabname,
								   RIS_TOK_LOCK_TABLES);

			if (sharep) 
			{
				RIStrn_check_for_dup_tables(RIS_TOK_LOCK_TABLES,tablep,sharep->rhs);
			}
			if (exclusivep) 
			{
				RIStrn_check_for_dup_tables(RIS_TOK_LOCK_TABLES,tablep,exclusivep->rhs);
			}
			if (defaultp) 
			{
				RIStrn_check_for_dup_tables(RIS_TOK_LOCK_TABLES,tablep,defaultp->rhs);
			}

			/*
			** Set schema to the schema of the first table in the list.
			*/
			if (!schema)
			{
				if (tablep->lhs->info.tab->tabtype == 'A')
				{
					schema = tablep->lhs->info.tab->tab->schema;
				}
				else
				{
					schema = tablep->lhs->info.tab->schema;
				}
			}
		}
	}
}

/******************************************************************************/
