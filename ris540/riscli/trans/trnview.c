/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnview.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl view statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscl_sr.h"
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "trans.h"
#include "keyword.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnview_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comdict.prt"
#include "comjmp.prt"
#include "ccoren.prt"
#include "trnkeywd.prt"
#include "trnselct.prt"
#include "trnshare.prt"
#include "trntypsz.prt"
#include "trnview.prt"
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
** checks for same column name in view variable list which is constructed from
** the select list of the query specification
** var_name = variable/column name in question list = the list of variables
** 6.5 <view definition> syntax rule 4
*/

static void RIStrn_check_for_same_col_name(
	char * var_name,
	ristree * list)
{

TRN_DBG(("\nRIStrn_check_for_same_col_name var_name = %s list = 0x%x\n",
 var_name,list));

	for(;list;list=list->rhs)
	{
		if (strcmp(var_name,list->lhs->info.attr->attrname) == 0)
		{
			TRN_ERR_RETURN(RIS_E_NEED_VIEW_VAR_LIST,list->lhs->pos);
		}
	}
}

/******************************************************************************/

/*
** checks for duplicate variables in view variable list
** tp = variable in question var_list = the view variable list
** 6.5 <view definition> syntax rule 5
*/

static void RIStrn_check_for_same_var_name(
	ristree * tp,
	ristree * var_list)
{

TRN_DBG(("\nRIStrn_check_for_same_var_name tp = 0x%x var_list = 0x%x\n",
 tp,var_list));

	for (;var_list != tp;var_list=var_list->rhs)
	{
		/* Jin Jing */
		if  (strcmp(tp->lhs->info.attr->attrname,
			var_list->lhs->info.attr->attrname) == 0)
		{
			TRN_ERR_RETURN(RIS_E_DUP_VAR_NAME,tp->lhs->pos);
		}
		if  (strlen(tp->lhs->info.attr->extern_attrname) &&
			strcmp(tp->lhs->info.attr->extern_attrname,
			var_list->lhs->info.attr->extern_attrname) == 0)
		{
			TRN_ERR_RETURN(RIS_E_DUP_VAR_NAME,tp->lhs->pos);
		}
	}
}

/******************************************************************************/

/*
** create a view variable
** tp1 = variable name list = view variable list
** 6.5 <view definition> syntax rule 4 checked by RIStrn_check_for_same_col_name
*/

static ristree * RIStrn_create_var(
	ristree * tp1,
	ristree * list)
{
	ristree * tp2;
	char * var_name = 0;

TRN_DBG(("\nRIStrn_create_var tp1 = 0x%x list = 0x%x\n",tp1,list));

	switch(tp1->tok)
	{
		case RIS_TOK_AUTH_ID:
			tp1 = tp1->rhs->rhs;
			var_name = tp1->info.val;
		break;
		case RIS_TOK_TABLE_NAME:
			tp1 = tp1->rhs;
			var_name = tp1->info.val;
		break;
		case RIS_TOK_COL_NAME:
			var_name = tp1->info.val;
		break;
		case RIS_TOK_ATTR:
			var_name = tp1->info.attr->attrname;
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp1->pos);
		break;
	}
	RIStrn_check_for_same_col_name(var_name,list);
	tp2 = ALLOCT(ristree);
	tp2->tok = RIS_TOK_LIST;
	tp2->lhs = ALLOCT(ristree);
	tp2->lhs->tok = RIS_TOK_ATTR;
	tp2->lhs->pos = tp1->pos;
	tp2->lhs->info.attr = ALLOCT(risattr);
	strcpy(tp2->lhs->info.attr->attrname,var_name);
	return(tp2);
}

/******************************************************************************/

/*
** creates a view variable list 
** select_list = select list from query spec table_list = query spec from clause
** 6.5 <view definition> syntax rule 4 checked by RIStrn_create_var and this
** routine
*/

static ristree * RIStrn_create_vars(
	ristree * select_list,
	ristree * table_list)
{
	ristree * tp;
	ristree * list = 0;
	ristree * prev = 0;

TRN_DBG(("\nRIStrn_create_vars select_list = 0x%x table_list = 0x%x\n",
 select_list,table_list));

	if (select_list->tok == RIS_TOK_MUL)
	{
		list = RIStrn_create_vars_for_star(table_list);
	}
	else
	{
		for (tp=select_list->rhs;tp;tp=tp->rhs)
		{
			switch(tp->lhs->tok)
			{
				case RIS_TOK_AUTH_ID:
				case RIS_TOK_TABLE_NAME:
				case RIS_TOK_COL_NAME:
					if (prev)
					{
						prev->rhs = RIStrn_create_var(tp->lhs,list);
						prev = prev->rhs;
					}
					else
					{
						list = RIStrn_create_var(tp->lhs,(ristree *)0);
						prev = list;
					}
				break;
				default:
					TRN_ERR_RETURN(RIS_E_NEED_VIEW_VAR_LIST,tp->lhs->pos);
				break;
			}
		}
	}
	return(list);
}

/******************************************************************************/

/*
** creates a view variable list when query spec select list = *
** table_list = query spec from clause
** 6.5 <view definition> syntax rule 4 checked by RIStrn_create_var
*/

static ristree * RIStrn_create_vars_for_star(
    ristree *table_list)
{
    ristree * tp1;
    ristree * tp2;
    ristree * list = 0;
    ristree * prev = 0;
	ristree temp;

TRN_DBG(("\nRIStrn_create_vars_for_star table_list = 0x%x\n",table_list));

    for (tp1=table_list;tp1;tp1=tp1->rhs)
    {
		memcpy((char*)&temp ,(char*)tp1->lhs,sizeof(ristree));
		RIStrn_table_name(&temp,SELECT_ACCESS,0,NOT_DEFAULT_USER_SEARCH);
		for (tp2=temp.rhs;tp2;tp2=tp2->rhs)
		{
			if (!prev)
			{
				list = RIStrn_create_var(tp2->lhs,(ristree *)0);
				prev = list;
			}
			else
			{
				prev->rhs = RIStrn_create_var(tp2->lhs,(ristree *)0);
				prev = prev->rhs;
			}
		}
    }
	return(list);
}

/******************************************************************************/

/*
** chains the column attrs together
*/

static void RIStrn_chain_attr_blocks(
	ristree * attr_list)
{
	TRN_DBG(("\nRIStrn_chain_attr_blocks attr_list = 0x%x\n", attr_list));

	for (; attr_list; attr_list=attr_list->rhs)
	{
		if (attr_list->rhs)
		{
			attr_list->lhs->info.attr->next = attr_list->rhs->lhs->info.attr;
		}
		else
		{
			attr_list->lhs->info.attr->next = NULL;
		}
	}
	TRN_DBG(("\nRIStrn_chain_attr_blocks: returning.\n"));
}

/******************************************************************************/

/*
** transform view parse tree to rax
** createp = view parse tree
** 6.5 <view definition> syntax rule 1 not currently supported
** 6.5 <view definition> syntax rule 3 not currently supported
** 6.5 <view definition> syntax rule 4 checked by RIStrn_create_vars
** 6.5 <view definition> syntax rule 5 checked by RIStrn_fix_vars
** 6.5 <view definition> syntax rule 6 checked by RIStrn_fix_vars
** 6.5 <view definition> syntax rule 7 
** 6.5 <view definition> syntax rule 8 not supported 
** 6.5 <view definition> syntax rule 9 not supported 
*/

extern void RIStrn_create_view(
	ristree * createp)
{
	char * temp_name;
	ristree * namep;
	ristree * col_list = 0;
	ristree * query_spec;
	ristree * table_list;
	ristree * tp;
	risschema * schema;
	int updatable;
	int len;
    int new_tree=1;
    ristree * ext_namep=0;
    ristree * ext_option=0;
    ristree * ext_cols=0;


TRN_DBG(("\nRIStrn_create_view createp = 0x%x\n",createp));

/* set up pointers */

	namep = createp->rhs->lhs;
	len = strlen(namep->info.val);			
	if(len > RIS_max_id_size)
	{
		TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,namep->pos);
	}

	if (namep->tok == RIS_TOK_AUTH_ID || namep->tok == RIS_TOK_USR_NAME)
	{
		TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,namep->pos);
	}

	if (createp->rhs->rhs->rhs && 
		createp->rhs->rhs->rhs->lhs->tok == RIS_TOK_EXTERN)
	{
    	ext_option=createp->rhs->rhs->rhs->lhs;
	}
	else if(createp->rhs->rhs->lhs->tok == RIS_TOK_EXTERN)
	{
    	ext_option=createp->rhs->rhs->lhs;
	}

	if (createp->rhs->rhs->lhs->tok == RIS_TOK_COLUMN_LIST)
	{
		col_list = createp->rhs->rhs->lhs;
	}

	
	if(ext_option)
	{
   		ext_namep=ext_option->rhs->lhs;

		if(ext_option->rhs->rhs)
   			ext_cols=ext_option->rhs->rhs->lhs->rhs;

		len = strlen(ext_namep->info.val);			

		if(len > RIS_max_id_size)
			TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,ext_namep->pos);

		if  (RIScom_get_dict_tabid(ext_namep->info.val) != -1)
			LONGJMP(RIS_E_VIEW_ON_RIS_TAB_DISALLOWED);

    	RIStrn_check_keyword ( (char *) ext_namep->info.val,&new_tree);
    	RIStrn_det_dic_tab_mod(ext_namep->info.val,RIS_TOK_CREATE_VIEW);
    	RIStrn_check_dict_select(ext_namep->info.val,RIS_TOK_CREATE_VIEW);
		/* Shorten the tree */
		if(col_list) 
		{
			createp->rhs->rhs = createp->rhs->rhs->rhs->rhs;
		}
		else
		{
			createp->rhs->rhs = createp->rhs->rhs->rhs;
		}
	}
	else
	{
		/* Shorten the tree if there is a column list */
		if(col_list) 
		{
			createp->rhs->rhs = createp->rhs->rhs->rhs;
		}
	}

	query_spec = createp->rhs->rhs->lhs;

	table_list = query_spec->rhs->lhs->rhs->lhs->rhs->rhs->lhs->rhs;


    RIStrn_check_keyword ( (char *) namep->info.val, &new_tree );
    RIStrn_det_dic_tab_mod(namep->info.val, RIS_TOK_CREATE_VIEW);
    RIStrn_check_dict_select(namep->info.val, RIS_TOK_CREATE_VIEW);

	for (tp = table_list; tp; tp = tp->rhs)
	{
		if  (RIScom_get_dict_tabid(tp->lhs->info.val) != -1)
			LONGJMP(RIS_E_VIEW_ON_RIS_TAB_DISALLOWED);
	}


/* make RIS_TOK_TABLE_NAME into a RIS_TOK_TABLE and remove RIS_TOK_LIST*/

	temp_name = namep->info.val;
	namep->tok = RIS_TOK_TABLE;
	namep->info.tab = ALLOCT(ristab);
	namep->info.tab->tabtype = 'V';
	strcpy(namep->info.tab->tabowner,RIS_default->login_dbusr);
	strcpy(namep->info.tab->tabname,temp_name);

	if(ext_namep)
	{
		strcpy(namep->info.tab->extern_tabname,ext_namep->info.val);
		len = strlen(namep->info.tab->extern_tabname);
		if ((len > RIS_max_id_size) || 
			(len > RIS_MAX_OS400_ID_SIZE && RIS_default->db->dtype=='4'))
		{
			TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,ext_namep->pos);
		}
	}
	else
	{
		/* jin */
		if(RIS_default->db->dtype=='4')
		{
			RIScco_extern_table_name(
				temp_name, namep->info.tab->extern_tabname);
		}
		else
		{
			strcpy(namep->info.tab->extern_tabname,temp_name);
		}
	}

	namep->info.tab->schema = RIS_default;
	createp->rhs = namep;

	if (col_list)
	{
/* remove RIS_TOK_COLUMN_LIST */
		namep->rhs = col_list->rhs;
	}
	else
	{

/* create RIS_TOK_ATTRs */
		namep->rhs = RIStrn_create_vars(
			query_spec->rhs->lhs->rhs->lhs->rhs->lhs->rhs,table_list);
	}

	updatable = RIStrn_select(query_spec,(ristree *)0,(ristree *)0,
	 (ristree *)0);
	RIStrn_fix_vars(namep->rhs,query_spec->rhs->rhs,namep->info.tab,updatable,
			ext_cols);

	/* chain the column attrs together... Jin Jing */
	RIStrn_chain_attr_blocks(namep->rhs);
	if (!ext_cols)
	{
		RIScco_extern_column_names(RIS_default, namep->rhs->lhs->info.attr);
	}

    if ( RIStrn_get_keyword_message () )
    {
        TRN_ERR_RETURN(RIS_E_FOUND_KEYWORD, 0 );
    }
/* check the number of cols and the row length */

    RIStrn_check_row_size(namep->rhs,0,RIS_MAX_TABLE_COLUMNS,RIS_MAX_ROW_LENGTH,
     RIS_E_TOO_MANY_COLS,RIS_E_ROW_TOO_LONG);

/* make RIS_TOK_SELECT the lhs of RIS_TOK_TABLE */

	namep->lhs = query_spec;

/* check that tables in from clause are contained in default schema */

	if (query_spec->lhs->rhs->lhs->info.tab->tabtype == 'A')
	{
		schema = query_spec->lhs->rhs->lhs->info.tab->tab->schema;
	}
	else
	{
		schema = query_spec->lhs->rhs->lhs->info.tab->schema;
	}
	if (schema != RIS_default)
	{
		TRN_ERR_RETURN(RIS_E_NOT_DEFAULT_SCHEMA,query_spec->lhs->rhs->lhs->pos);
	}
}

/******************************************************************************/

/*
** make column names into a view var list
** var_list = column names and vars select list = query spec select list
** viewp = view info pointer updatable 0 = false 1 = true -1 = not applicable
** 6.5 <view definition> syntax rule 5 checked by RIStrn_check_for_same_var_name
** 6.5 <view definition> syntax rule 6
*/

static void RIStrn_fix_vars(
	ristree * var_list,
	ristree * select_list,
	ristab * viewp,
	int updatable,
	ristree * ext_cols 
	)
{
	ristree * tp1;
	ristree * tp2;
	ristree * temp;
	char * temp_name;
	char * ext_temp_name;
	risattr * var;
	risattr * attr;
	int len;
    int new_tree=0;
	ristree * tp3=0;

TRN_DBG(("\nRIStrn_fix_vars var_list = 0x%x select_list = 0x%x viewp = 0x%x updatable = %d\n",var_list,select_list,viewp,updatable));

	tp3= ext_cols; 

	for (tp1=var_list,tp2=select_list;tp1 && tp2;tp1=tp1->rhs,tp2=tp2->rhs)
	{
		switch(tp1->lhs->tok)
		{
			case RIS_TOK_COL_NAME:
                RIStrn_check_keyword ( (char *) tp1->lhs->info.val, &new_tree);
				temp_name = tp1->lhs->info.val;
				tp1->lhs->tok = RIS_TOK_ATTR;
				tp1->lhs->info.attr = ALLOCT(risattr);
				strcpy(tp1->lhs->info.attr->attrname,temp_name);


			break;
			case RIS_TOK_ATTR:
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp1->lhs->pos);
			break;
		}
		temp_name = tp1->lhs->info.val;
		len = strlen(temp_name);
		if(len > RIS_max_id_size)
		{
			TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,tp1->lhs->pos);
		}
		if(ext_cols) 
		{
			ext_temp_name = tp3->lhs->info.val;
			len = strlen(ext_temp_name);
				
           	if((tp1->rhs && ! tp3->rhs) || (!tp1->rhs && tp3->rhs))
			{
       			TRN_ERR_RETURN(RIS_E_MISMATCH_EXT_INT,tp1->pos);
			}	

			if(len > RIS_max_id_size)
			{
				TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,tp1->lhs->pos);
			}
           	RIStrn_check_keyword ( (char *) tp3->lhs->info.val, 
											&new_tree);
			strcpy(tp1->lhs->info.attr->extern_attrname,ext_temp_name);
			tp3=tp3->rhs;
		}
		RIStrn_check_for_same_var_name(tp1,var_list);
		tp1->lhs->info.attr->tab = viewp;

/* make expression from select list the rhs of the var */

		tp1->lhs->rhs = tp2->lhs;

/* fill in type and length values for the var */

		var = tp1->lhs->info.attr;
		switch(tp2->lhs->tok)
		{
			case RIS_TOK_APPROX_NUM_LIT:
			case RIS_TOK_EXACT_NUM_LIT:
			case RIS_TOK_CHAR_STR_LIT:
			case RIS_TOK_TIMESTAMP_LIT:
			case RIS_TOK_CURRENT_TIMESTAMP:
				var->atype = (unsigned char)RIStrn_get_type(tp2->lhs);
				var->asize.len = (unsigned short)RIStrn_get_size(tp2->lhs);
			break;
			case RIS_TOK_ATTR:
			case RIS_TOK_PLUS:
			case RIS_TOK_SUB:
			case RIS_TOK_MUL:
			case RIS_TOK_DIV:
			case RIS_TOK_MAX:
			case RIS_TOK_MIN:
			case RIS_TOK_SUM:
			case RIS_TOK_AVG:
			case RIS_TOK_COUNT:
			case RIS_TOK_UNARYMINUS:
				attr = tp2->lhs->info.attr;
				var->atype = attr->atype;
				if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
				{
					var->asize.dec.prec = attr->asize.dec.prec;
					var->asize.dec.scale = attr->asize.dec.scale;
				}
				else
				{
					var->asize.len = attr->asize.len;
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp2->lhs->pos);
			break;
		}

/* add this var to the parm list */

		temp = ALLOCT(ristree);
		temp->tok = RIS_TOK_LIST;
		temp->lhs = tp1->lhs;
		temp->rhs = RIStrn_parm_list;
		RIStrn_parm_list = temp;
		RIStrn_parm_index++;
	}
	if (tp1 && !tp2)
	{
		TRN_ERR_RETURN(RIS_E_NOT_ENOUGH_SELECT_COLS,tp1->lhs->pos);
	}
	else if (!tp1 && tp2)
	{
		TRN_ERR_RETURN(RIS_E_TOO_MANY_SELECT_COLS,tp2->lhs->pos);
	}
}

/******************************************************************************/
