/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnindex.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl index statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "riscli.h"
#include "trans.h"
#include "keyword.h"
#include "rismem.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnindex_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "ccoren.prt"
#include "trnindex.prt"
#include "trnkeywd.prt"
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
** transform create index parse tree into rax
** createp = create index parse tree
** create index is an RIS extension to the sql standard
*/

extern void RIStrn_create_index(
	ristree * createp)
{
	ristree * cols;
	ristree * tp;
	ristree * temp;
	ristree * uniquep = 0;
	ristree * indexp;
	ristree * ext_indexp=0;
	ristree * tablep;
	int len, len1=0;
	int	new_tree=1;

	TRN_DBG(("RIStrn_create_index(createp:0x%x)\n",createp));

/* set up pointers */

	if (createp->rhs->lhs->tok == RIS_TOK_UNIQUE)
	{
		uniquep = createp->rhs->lhs;
		createp->rhs = createp->rhs->rhs;
	}

	indexp = createp->rhs->lhs;

	if (createp->rhs->rhs->lhs->tok == RIS_TOK_TABLE_NAME)
    {
		tablep = createp->rhs->rhs->lhs;
		cols = createp->rhs->rhs->rhs->lhs->rhs;
	}
	else
	{
		tablep = createp->rhs->rhs->rhs->lhs;
		cols = createp->rhs->rhs->rhs->rhs->lhs->rhs;
		ext_indexp= createp->rhs->rhs->lhs->rhs->lhs;
		len1=strlen(ext_indexp->info.val);
		RIStrn_check_keyword ( (char *) ext_indexp->info.val, &new_tree );
		RIStrn_det_dic_tab_mod(ext_indexp->info.val, RIS_TOK_CREATE_INDEX);
		RIStrn_check_dict_select(ext_indexp->info.val, RIS_TOK_CREATE_INDEX);
	}

	len = strlen(indexp->info.val);

	if(len > RIS_max_id_size || len1 > RIS_max_id_size)
	{
		TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,indexp->pos);
	}

	RIStrn_check_keyword ( (char *) indexp->info.val, &new_tree );

	RIStrn_det_dic_tab_mod(indexp->info.val, RIS_TOK_CREATE_INDEX);
	RIStrn_check_dict_select(indexp->info.val, RIS_TOK_CREATE_INDEX);

/* make RIS_TOK_UNIQUE to the rhs of RIS_TOK_INDEX_NAME */

	indexp->rhs = uniquep;

/* make RIS_TOK_TABLE_NAME the lhs of RIS_TOK_INDEX_NAME */

	indexp->lhs = tablep;

/* make RIS_TOK_INDEX_NAME the rhs of RIS_TOK_CREATE_INDEX */

	createp->rhs = indexp;

/* If external clause exists, make it the lhs of RIS_TOK_CREATE_INDEX */
	if(ext_indexp)
	{
		createp->lhs=ext_indexp;
	}
	else
	{
		createp->lhs=ALLOCT(ristree);
		createp->lhs->info.val = (char *) ALLOCB(RIS_MAX_ID_SIZE);
		*(createp->lhs->info.val) = '\0';
		len = strlen(createp->rhs->info.val);
		if (RIS_default->db->dtype == '4')
		{
			RIScco_extern_table_name(
				createp->rhs->info.val, createp->lhs->info.val);
		}
		else
		{
			memcpy(createp->lhs->info.val, createp->rhs->info.val,len);
		}
	}
/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	if (tablep->tok == RIS_TOK_AUTH_ID || tablep->tok == RIS_TOK_USR_NAME)
	{
		TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,tablep->pos);
	}
	RIStrn_table_name_w_type(tablep,0,0,NOT_DEFAULT_USER_SEARCH);
	if (tablep->info.tab->tabtype == 'V')
	{
		TRN_ERR_RETURN(RIS_E_BASE_TABLE_ONLY,tablep->pos);
	}

/* replace RIS_TOK_COL_NAMEs with RIS_TOK_ATTRs */

	RIStrn_parm_list = 0;
	RIStrn_parm_index = 0;

	for (tp=cols;tp;tp=tp->rhs)
	{
		RIStrn_col_name(tp->lhs,tablep,0);
		
		temp = ALLOCT(ristree);
		temp->tok = RIS_TOK_LIST;
		temp->lhs = ALLOCT(ristree);
		temp->lhs->tok = RIS_TOK_ATTR;
		temp->lhs->pos = tp->lhs->pos;
		temp->lhs->info.attr = ALLOCT(risattr);
		strcpy(temp->lhs->info.attr->attrname,tp->lhs->info.val);
		temp->rhs = RIStrn_parm_list;
		RIStrn_parm_list = temp;
		RIStrn_parm_index++;
	}

/* check for UNSUPPORTED data type */
	RIStrn_col_unsupported(cols);

    if ( RIStrn_get_keyword_message () )
	{
		TRN_ERR_RETURN(RIS_E_FOUND_KEYWORD, 0 );
	}

/* check the number of cols and the row length */

	RIStrn_check_row_size(cols,0,RIS_MAX_INDEX_COLUMNS,RIS_MAX_INDEX_LENGTH,
	 RIS_E_TOO_MANY_INDEX_COLS,RIS_E_INDEX_TOO_LONG);

/* make column list the rhs of RIS_TOK_TABLE */

	tablep->rhs = cols;

	TRN_DBG(("RIStrn_create_index:complete\n"));
}

/******************************************************************************/

/*
** transform drop index parse tree to rax
** tp = drop index parse tree
** drop index is an RIS extension to the sql standard
*/

extern void RIStrn_drop_index(
	ristree * dropp)
{

	TRN_DBG(("RIStrn_drop_index(dropp:0x%x)\n",dropp));

	dropp->rhs = dropp->rhs->lhs;
	RIStrn_det_dic_tab_mod(dropp->rhs->info.val, RIS_TOK_DROP_INDEX);
	RIStrn_check_dict_select(dropp->rhs->info.val, RIS_TOK_DROP_INDEX);

	TRN_DBG(("RIStrn_drop_index:complete\n"));
}

/******************************************************************************/
