/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trntrans.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/88
**	ABSTRACT:
**		This file contains the routines that handle dml transaction statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trntrans_c
#include "ccooutpt.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "trntrans.prt"
#include "trnshare.prt"
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

/*
** transform set transaction parse tree into rax
** tp = set transaction parse tree
*/

extern void RIStrn_set(
	ristree * tp)
{
	TRN_DBG(("RIStrn_set(tp:0x%x)\n",tp));

	switch(tp->rhs->tok)
	{
		case RIS_TOK_DATABASE:
/*
**          convert from:
**
**              SET
**               \
**                \____
**                     \
**                  DATABASE
**                      \
**                       \____
**                            \
**                            LIST
**                             /
**                        ____/
**                       /
**                   ENABLE
**                      \
**                       \____
**                            \
**                    DB_TYPE_LIST or ALL
**
**			to:
**              SET
**               \
**                \____
**                     \
**                  DATABASE
**                      \
**                       \____
**                            \
**                    DB_TYPE_LIST or ALL
**
*/

			tp->rhs->rhs = tp->rhs->rhs->lhs->rhs;
			break;

		case RIS_TOK_MODE:
			/* No change */
			break;

		case RIS_TOK_AUTOCOMMIT:
			/* No change */
			break;

		case RIS_TOK_TRANSACTION:
/*
**			change from:
**              SET
**               \
**                \____
**                     \
**                 TRANSACTION
**                      \
**                       \____
**                            \
**                            LIST
**                             /
**                        ____/
**                       /
**                 AUTOCOMMIT
**                      \
**                       \____
**                            \
**                          ON or OFF
**
**			to:
**              SET
**               \
**                \____
**                     \
**                 TRANSACTION
**                      \
**                       \____
**                            \
**                          ON or OFF
*/
			tp->rhs->rhs = tp->rhs->rhs->lhs->rhs;
			break;
		case RIS_TOK_NETWORK:
/*
**  	change from 
**
**        SET
**         \
**          \____
**               \
**             NETWORK
**                \
**                 \____
**                      \
**                      LIST
**                      / \
**                 ____/   \___________________
**                /                            \
**           PARAM_LIST                      LIST
**                                           /
**                                      ____/
**                                     /
**                                SCHEMA_LIST
**       to:
**
**   				     SET
** 				          \
**                         \____
**                              \
**                            NETWORK
**                              / \
**                         ____/   \____
**                        /             \
**                    PARAM_LIST    SCHEMA_LIST
**
*/
			tp->rhs->lhs = tp->rhs->rhs->lhs;
			if (tp->rhs->rhs->rhs)
			{
				tp->rhs->rhs = tp->rhs->rhs->rhs->lhs;
			}
			else 
			{
				tp->rhs->rhs = 0;
			}
			RIStrn_set_net_params(tp->rhs->lhs);	
			if (tp->rhs->rhs)
			{
				RIStrn_set_net_schema(tp->rhs->rhs);	
			}
			break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->rhs->pos);
			break;
	}

	if(RIStrn_debug)
	{
		RIScco_output_internal_tree(RIScom_output_debug, tp);
	}
	TRN_DBG(("RIStrn_set:complete\n"));
}


/******************************************************************************/

/*
** transform commit and rollback parse tree into rax
** tp = commit [schema] or rollback [schema] parse tree
*/

extern void RIStrn_commit_rollback(
	ristree * tp)
{

TRN_DBG(("\nRIStrn_commit_rollback tp = 0x%x\n",tp));

/* 
** change RIS_TOK_AUTH to RIS_TOK_SCHEMA (if exists )and 
** move it to the rhs of RIS_TOK_COMMIT or RIS_TOK_ROLLBACK 
** otherwise set it to default schema 
*/

	if( tp->rhs->lhs->tok == RIS_TOK_AUTH_ID )
	{
		RIStrn_auth_id(tp->rhs->lhs);
		tp->rhs = tp->rhs->lhs;
	}
	else
	{
		tp->rhs = tp->rhs->lhs;
		tp->rhs->info.schema = RIS_default;
		tp->rhs->tok = RIS_TOK_SCHEMA;
	}
	if(RIStrn_debug)
	{
		RIScco_output_internal_tree(RIScom_output_debug, tp);
	}
}

/******************************************************************************/

/*
** do consistency checking for parameters
** tp = param_list parser tree
*/

static void RIStrn_set_net_params(
	ristree * tp)
{

	int	interval_flag = 0;
	int	tolerance_flag = 0;
	int	buffer_size_flag = 0;
	int	buffer_timeout_flag = 0;
	int	initial_timeout_flag = 0;
	int	response_interval_flag = 0;

	ristree *pp;

TRN_DBG(("\nRIStrn_set_net_params tp = 0x%x\n",tp));

	for (pp = tp->rhs; pp; pp = pp->rhs)
	{
		switch(pp->lhs->tok)
		{
			case RIS_TOK_INTERVAL:
			/* timesatmp interval */
				if (!interval_flag)
				{
					interval_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_TIMESTAMP_INTERVAL_MIN ||
					atoi(pp->lhs->rhs->info.val) > RIS_TIMESTAMP_INTERVAL_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_TIMESTAMP_INTERVAL_PARM,pp->lhs->rhs->pos);
				}
				break;

			case RIS_TOK_TOLERANCE: 
			/* timestamp tolerance */
				if (!tolerance_flag)
				{
					tolerance_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_TIMESTAMP_TOLERANCE_MIN ||
					atoi(pp->lhs->rhs->info.val) > RIS_TIMESTAMP_TOLERANCE_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_TIMESTAMP_TOLERANCE_PARM,pp->lhs->rhs->pos);
				}
				break;
			
			case RIS_TOK_BUFFER_SIZE:
			/* buffer size */
				if (!buffer_size_flag)
				{
					buffer_size_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_BUFFER_FULL_SIZE_MIN ||
					atoi(pp->lhs->rhs->info.val) > RIS_BUFFER_FULL_SIZE_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_BUFFER_FULL_SIZE_PARM,pp->lhs->rhs->pos);
				}
				break;
			
			case RIS_TOK_BUFFER_TIMEOUT: 
			/* buffer timeout */
				if (!buffer_timeout_flag)
				{
					buffer_timeout_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_BUFFER_FULL_TIMEOUT_MIN
				 || atoi(pp->lhs->rhs->info.val) > RIS_BUFFER_FULL_TIMEOUT_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_BUFFER_FULL_TIMEOUT_PARM,pp->lhs->rhs->pos);
				}
				break;
			
			case RIS_TOK_INITIAL_TIMEOUT: 
			/* initial timeout */
				if (!initial_timeout_flag)
				{
					initial_timeout_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_INITIAL_TIMEOUT_MIN ||
					atoi(pp->lhs->rhs->info.val) > RIS_INITIAL_TIMEOUT_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_INITIAL_TIMEOUT_PARM,pp->lhs->rhs->pos);
				}
				break;
			
			case RIS_TOK_RESPONSE_INTERVAL: 
			/* initial timeout */
				if (!response_interval_flag)
				{
					response_interval_flag = 1;
 				}
				else
				{
					TRN_ERR_RETURN(RIS_E_DUP_NET_VERIFY_DEF,pp->lhs->pos);
				}
				if (atoi(pp->lhs->rhs->info.val) < RIS_RESPONSE_INTERVAL_MIN ||
					atoi(pp->lhs->rhs->info.val) > RIS_RESPONSE_INTERVAL_MAX)
				{
					TRN_ERR_RETURN(RIS_E_INV_RESPONSE_INTERVAL_PARM,pp->lhs->rhs->pos);
				}
				break;

			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,pp->lhs->pos);
		}
	}

TRN_DBG(("\nRIStrn_set_net_params: complete\n"));
}

/******************************************************************************/

/*
** get info for schema and do consistency checking
** tp = schema_list parser tree
*/

extern void RIStrn_set_net_schema(
	ristree *tp)
{
	ristree *schp;

TRN_DBG(("RIStrn_set_net_schema tp = 0x%x\n", tp);)

	for( schp = tp->rhs; schp; schp = schp->rhs )
	{
TRN_DBG(("schema = <%s>\n", schp->lhs->info.val);)
		RIStrn_auth_id(schp->lhs);
	}
}

/******************************************************************************/
