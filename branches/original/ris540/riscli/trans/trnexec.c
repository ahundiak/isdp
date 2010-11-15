/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnexec.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml exec statements.
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnexec_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trnexec.prt"

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

extern void RIStrn_exec(
	ristree * execp)
{

	TRN_DBG(("\nRIStrn_exec(execp:0x%x)\n",execp));

	if (RIS_dict_select_flag)
	{
		TRN_ERR_RETURN(RIS_E_DICT_SELECT_ONLY,execp->pos);
	}

	/*
	**	Process dbtype
	*/
	if (execp->rhs)
	{
		switch(execp->rhs->tok)
		{
/*
**	Changed reference to rhs from lhs to fix TR# 249403600.
**	It should have been rhs. RAJU 06/30/94
*/
			case RIS_TOK_INFORMIX:
				if (RIS_default->db->dtype != 'X')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_ORACLE:
				if (RIS_default->db->dtype != 'O')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_INGRES:
				if (RIS_default->db->dtype != 'I')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_SQLDS:
				if (RIS_default->db->dtype != 'S')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_DB2:
				if (RIS_default->db->dtype != 'D')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_RDB:
				if (RIS_default->db->dtype != 'R')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_SYBASE:
				if (RIS_default->db->dtype != 'Y')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_MSSQL:
				if (RIS_default->db->dtype != 'M')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			case RIS_TOK_OS400:
				if (RIS_default->db->dtype != '4')
					TRN_ERR_RETURN(RIS_E_INV_DB_TYPE,execp->rhs->pos);
				break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,execp->rhs->pos);
		}

		/*
		**	Process string
		*/
		execp->info.val = execp->rhs->info.val;
		execp->rhs = 0;
	}
	else
	{
		TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,execp->pos);
	}

	TRN_DBG(("RIStrn_exec:complete\n"));
}

/******************************************************************************/
