/*
**	NAME:							trntable.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl table statements.
**	
**	REVISION HISTORY:
**		add function RIStrn_chain_attr_blocks for AS400 by Jin 02/94
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_sr.h"
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "ristypes.h"
#include "trans.h"
#include "keyword.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trntable_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrng.prt"
#include "ccoren.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "trnkeywd.prt"
#include "trnshare.prt"
#include "trntable.prt"
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
** transforms alter table parse tree to rax
** alterp = alter table parse tree
*/

extern void RIStrn_alter_table(
	ristree * alterp)
{

	ristree * tablep;
	ristree * actionp;
	ristree * ext_cols=0;

	int new_tree =1;

TRN_DBG(("\nRIStrn_alter_table alterp= 0x%x\n",alterp));

/* set up pointers */

	tablep = alterp->rhs->lhs;
	actionp = alterp->rhs->rhs->lhs;


	if (tablep->tok == RIS_TOK_AUTH_ID || tablep->tok == RIS_TOK_USR_NAME)
	{
		TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,tablep->pos);
	}

	if ( actionp->rhs &&  actionp->rhs->tok == RIS_TOK_EXTERN)
	{
		ext_cols = actionp->rhs->rhs;	
	}

	actionp->rhs = actionp->lhs; /* fix bug caused by extern clause
									Jin 03/18/94 */
/* make RIS_TOK_TABLE_NAME into a RIS_TOK_TABLE */

	RIStrn_table_name_w_type(tablep,0,0,NOT_DEFAULT_USER_SEARCH);
	if (tablep->info.tab->tabtype == 'V')
	{
		TRN_ERR_RETURN(RIS_E_BASE_TABLE_ONLY,tablep->pos);
	}

    RIStrn_det_dic_tab_mod(tablep->info.tab->tabname,RIS_TOK_ALTER_TABLE);
    RIStrn_check_dict_select(tablep->info.tab->tabname,RIS_TOK_ALTER_TABLE);

/* make RIS_TOK_TABLE the rhs of RIS_TOK_ALTER_TABLE */

	alterp->rhs = tablep;

	switch(actionp->tok)
	{
		case RIS_TOK_ADD:

/* make column def into an RIS_TOK_ATTR */

			actionp->lhs = actionp->rhs;
			actionp->rhs = 0;

            RIStrn_check_keyword ( (char *) actionp->lhs->rhs->lhs->info.val,
                                                &new_tree);
			if(ext_cols)
			{
            	RIStrn_check_keyword ( (char *) ext_cols->lhs->info.val, &new_tree);

			}
			/* We pass null for both internal and external col lists */
			RIStrn_create_attr(actionp,ext_cols,tablep->rhs,tablep->info.tab,RIS_TOK_ALTER_TABLE);

            if ( RIStrn_get_keyword_message () )
            {
                TRN_ERR_RETURN(RIS_E_FOUND_KEYWORD, 0 );
            }

/* check the number of cols and the row length */

			RIStrn_check_row_size(tablep->rhs,actionp,RIS_MAX_TABLE_COLUMNS,
			 RIS_MAX_ROW_LENGTH,RIS_E_TOO_MANY_COLS,RIS_E_ROW_TOO_LONG);

			actionp->rhs = actionp->lhs;
			actionp->lhs =  0;
		break;
		case RIS_TOK_DROP:

/* dictionary cant handle drop yet */

			TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,actionp->pos);

/* make RIS_TOK_COL_NAME into an RIS_TOK_ATTR */

			RIStrn_col_name(actionp->rhs,tablep,0);

/* make sure this isnt the only column of the table */

			if (!tablep->rhs->rhs)
			{
				TRN_ERR_RETURN(RIS_E_CANT_DROP_ONLY_COL,tablep->pos);
			}
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,actionp->pos);
		break;
	}

/* make action the lhs of RIS_TOK_ALTER_TABLE */

	alterp->lhs = actionp;
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
** checks for duplicate attributes
** tp = attribute in question attr_list = the list of attributes
** 6.3 column definition> syntax rule 1
*/

static void RIStrn_check_for_same_attr_name(
	ristree * tp,
	ristree * attr_list,
	ristree * ext_tp)
{

TRN_DBG(("\nRIStrn_check_for_same_attr_name tp = 0x%x attr_list = 0x%x ext_tp 0x%x\n", tp,attr_list, ext_tp));

	for (;attr_list && attr_list != tp;attr_list=attr_list->rhs)
	{
		if (strcmp(tp->lhs->info.attr->attrname,
		 attr_list->lhs->info.attr->attrname) == 0)
		{
			TRN_ERR_RETURN(RIS_E_DUP_ATTR_NAME,tp->lhs->pos);
		}
		if (ext_tp)
		{
			if (strcmp(tp->lhs->info.attr->extern_attrname,
		 	attr_list->lhs->info.attr->extern_attrname) == 0)
			{
				TRN_ERR_RETURN(RIS_E_DUP_ATTR_NAME,ext_tp->lhs->pos);
			}
		}
	}
}

/******************************************************************************/

/*
** replaces attr name etc. with attr info
** tp = attr parse tree list = attr list tabp = table info pointer
** 6.3 <column definition> syntax rule 1 checked by RIStrn_check_for_same_attr_name
** 6.3 <column definition> syntax rule 2
** 6.3 <column definition> syntax rule 3
** 6.3 <column definition> syntax rule 4
** 6.3 <column definition> syntax rule 5
*/

static void RIStrn_create_attr(
	ristree * tp,
	ristree * ext_tp,
	ristree * list,
	ristab * tabp,
	int token)
{
	ristree * temp;
	ristree * decp;
	risattr * attr;
	int len=0, len1=0;

	tp->lhs->tok = RIS_TOK_ATTR;
	attr = ALLOCT(risattr);
	tp->lhs->info.attr = attr;
	strcpy(attr->attrname,tp->lhs->rhs->lhs->info.val);
	len = strlen(attr->attrname);

	if (ext_tp)	
	{
		strcpy(attr->extern_attrname,ext_tp->lhs->info.val);
		len1=strlen(attr->extern_attrname);
	}
	else
	{
		*(attr->extern_attrname)='\0';

	}

	if ((token == RIS_TOK_CREATE_TABLE || token == RIS_TOK_CREATE_VIEW)) 
	{
	 	if(len > RIS_max_id_size)
		{
	    	TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,tp->lhs->rhs->lhs->pos);
		}

	 	if(len1 > RIS_max_id_size)
		{
	    	TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,ext_tp->lhs->pos);
		}
	}
	tp->lhs->pos = tp->lhs->rhs->lhs->pos;

	RIStrn_check_for_same_attr_name(tp,list, ext_tp);

	switch(tp->lhs->rhs->rhs->lhs->tok)
	{
		case RIS_TOK_INT:
			attr->atype = RIS_INTEGER;
			attr->asize.len = RIS_types[RIS_INTEGER].sqllen;
		break;
		case RIS_TOK_SMALLINT:
			attr->atype = RIS_SMALLINT;
			attr->asize.len = RIS_types[RIS_SMALLINT].sqllen;
		break;
		case RIS_TOK_REAL:
			attr->atype = RIS_REAL;
			attr->asize.len = RIS_types[RIS_REAL].sqllen;
		break;
		case RIS_TOK_DOUBLE:
			attr->atype = RIS_DOUBLE;
			attr->asize.len = RIS_types[RIS_DOUBLE].sqllen;
		break;
		case RIS_TOK_CHAR:
			attr->atype = RIS_CHARACTER;
			attr->asize.len = 
				(short)atoi(tp->lhs->rhs->rhs->lhs->rhs->info.val);
            if (attr->asize.len > RIS_MAX_CHAR_STRING_SIZE)
            {
                TRN_ERR_RETURN(RIS_E_CHAR_COL_TOO_BIG,
                	tp->lhs->rhs->rhs->lhs->rhs->pos);
            }
		break;
		case RIS_TOK_DECIMAL:
			attr->atype = RIS_DECIMAL;
			decp = tp->lhs->rhs->rhs->lhs;
			if (decp->rhs)
			{ /* there is a precision */
				int prec;
				int scale;

				prec = atoi(decp->rhs->info.val);
				if (prec <= 0 || prec > RIS_MAX_PRECISION)
					TRN_ERR_RETURN(RIS_E_INVALID_PRECISION,decp->rhs->pos);

				attr->asize.dec.prec = (char)prec;

				if (decp->rhs->rhs)
				{ /* there is a scale */

					scale = atoi(decp->rhs->rhs->info.val);
					if (scale < 0 || scale > prec)
						TRN_ERR_RETURN(RIS_E_INVALID_SCALE,
							decp->rhs->rhs->pos);
					attr->asize.dec.scale = (char)scale;
				}
				else
				{
					attr->asize.dec.scale = RIS_DEFAULT_DECIMAL_SCALE;
				}
			}
			else
			{
				attr->asize.dec.prec = RIS_DEFAULT_DECIMAL_PRECISION;
				attr->asize.dec.scale = RIS_DEFAULT_DECIMAL_SCALE;
			}
		break;
		case RIS_TOK_TIMESTAMP:
			attr->atype = RIS_DATETIME;
			attr->asize.len = sizeof(dtime);
		break;
		/******   BLOB *********/
		case RIS_TOK_RIS_BLOB:
			attr->atype = RIS_BLOB;
			attr->asize.len =
			atoi(tp->lhs->rhs->rhs->lhs->rhs->info.val);
		break;
		
		case RIS_TOK_RIS_TEXT:
			attr->atype = RIS_TEXT;
			attr->asize.len =
			atoi(tp->lhs->rhs->rhs->lhs->rhs->info.val);
		break;
		/******   BLOB *********/

		case RIS_TOK_UNSUPPORTED: /* Hitesh */
			if( token == RIS_TOK_DECLARE_TABLE 
			||	token == RIS_TOK_DECLARE_VIEW )
			{
				attr->atype = RIS_UNSUPPORTED_TYPE;
				attr->asize.len = RIS_types[RIS_UNSUPPORTED_TYPE].sqllen;
			}
			else
				TRN_ERR_RETURN(RIS_E_UNSUPPORTED_TYPE,
								tp->lhs->rhs->rhs->lhs->pos);
		break;
	}

/*
** modify atype to indicate if nulls are allowed
*/

	if (!tp->lhs->rhs->rhs->rhs)
	{
		ALLOW_NULLS(attr->atype);
	}

	tp->lhs->rhs = 0;
	attr->tab = tabp;

/* add this attr to the parm list */

    temp = ALLOCT(ristree);
    temp->tok = RIS_TOK_LIST;
    temp->lhs = tp->lhs;
    temp->rhs = RIStrn_parm_list;
    RIStrn_parm_list = temp;
    RIStrn_parm_index++;
}

/******************************************************************************/

/*
** transform create table parse tree into rax
** createp = create table parse tree
** 6.2 <table definition> syntax rule 1 not currently supported
** 6.2 <table definition> syntax rule 3 
*/

extern void RIStrn_create_table(
	ristree * createp)
{
	ristree * tp;
	char * temp_name;
	ristree * tablep;
	ristree * cols;
	ristree * ext_tablep=0;
	ristree * ext_cols=0;
	ristree * ext_tp=0;

	int len;
    int new_tree = 1;


TRN_DBG(("\nRIStrn_create_table createp = 0x%x\n",createp));

	/* set up pointers */
	tablep = createp->rhs->lhs;
	cols = createp->rhs->rhs->lhs->rhs;

	/* 
	** set up pointers if extern table clause or extern cols clause 
	** are not empty... Jin 
	*/
	if (createp->rhs->rhs->rhs)
	{
		ext_tablep = createp->rhs->rhs->rhs->lhs->rhs->lhs;
		if (createp->rhs->rhs->rhs->lhs->rhs->rhs)
		{
			ext_cols = createp->rhs->rhs->rhs->lhs->rhs->rhs->lhs;
		}
	}


	if (tablep->tok == RIS_TOK_AUTH_ID || tablep->tok == RIS_TOK_USR_NAME)
	{
		TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,tablep->pos);
	}

    RIStrn_check_keyword ( (char *) tablep->info.val, &new_tree );
    RIStrn_det_dic_tab_mod(tablep->info.val,RIS_TOK_CREATE_TABLE);
    RIStrn_check_dict_select(tablep->info.val,RIS_TOK_CREATE_TABLE);

	/* james */
	if( ext_tablep)
	{	
    	RIStrn_check_keyword ( (char *) ext_tablep->info.val, &new_tree );
    	RIStrn_det_dic_tab_mod(ext_tablep->info.val,RIS_TOK_CREATE_TABLE);
    	RIStrn_check_dict_select(ext_tablep->info.val,RIS_TOK_CREATE_TABLE);
	}

/* make RIS_TOK_TABLE_NAME into a RIS_TOK_TABLE and remove RIS_TOK_LIST and 
 RIS_TOK_COLUMN_DEF_LIST */

	temp_name = tablep->info.val;
	tablep->tok = RIS_TOK_TABLE;
	tablep->info.tab = ALLOCT(ristab);
	strcpy(tablep->info.tab->tabowner,RIS_default->login_dbusr);
	strcpy(tablep->info.tab->tabname,temp_name);
	/* James */
	if( ext_tablep)
	{	
		strcpy(tablep->info.tab->extern_tabname,ext_tablep->info.val);
		len = strlen(tablep->info.tab->extern_tabname);
		if (len > RIS_max_id_size)
		{
	    	TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,ext_tablep->pos);
		}
	}
	else
	{
		/* jin */
		if(RIS_default->db->dtype=='4')
		{
			RIScco_extern_table_name(
				temp_name, tablep->info.tab->extern_tabname);
		}
		else
		{
			strcpy(tablep->info.tab->extern_tabname, temp_name);
		}
	}

	len = strlen(tablep->info.tab->tabname);
	if (len > RIS_max_id_size)
	{
	    TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,tablep->pos);
	}

	tablep->info.tab->tabtype = 'T';
	tablep->info.tab->schema = RIS_default;
	tablep->rhs = cols;
	createp->rhs = tablep;

/* make RIS_TOK_COLUMN_DEFs into RIS_TOK_ATTRs */
	/* James */
	if(ext_cols)
	{	
		ext_tp=ext_cols;
	}

	for (tp=cols ; tp ; tp=tp->rhs)
	{
		/* Hitesh */
        RIStrn_check_keyword ( (char *) tp->lhs->rhs->lhs->info.val, &new_tree);
		if(ext_cols)
		{	
			ext_tp=ext_tp->rhs;

        	RIStrn_check_keyword ( (char *) ext_tp->lhs->info.val,
								 &new_tree);
			if((tp->rhs && ! ext_tp->rhs) || (!tp->rhs && ext_tp->rhs)) 
			
			TRN_ERR_RETURN(RIS_E_MISMATCH_EXT_INT,tp->pos);
		}

		RIStrn_create_attr(tp,ext_tp, cols, tablep->info.tab,
							RIS_TOK_CREATE_TABLE);
	}
	/* chain the column attrs together... Jin Jing */
	RIStrn_chain_attr_blocks(cols);
	if (!ext_cols)
	{
		RIScco_extern_column_names(tablep->info.tab->schema,
			cols->lhs->info.attr);
	}

    if ( RIStrn_get_keyword_message () )
    {
        TRN_ERR_RETURN(RIS_E_FOUND_KEYWORD, 0 );
    }

/* check the number of cols and the row length */

	RIStrn_check_row_size(cols,0,RIS_MAX_TABLE_COLUMNS,RIS_MAX_ROW_LENGTH,
	 RIS_E_TOO_MANY_COLS,RIS_E_ROW_TOO_LONG);
}

/******************************************************************************/

/*
** transform drop table/view parse tree to rax
** tp = drop table/view parse tree
** drop table/view is an RIS extension to the sql standard
*/

extern void RIStrn_drop_table_view(
	ristree * dropp)
{

TRN_DBG(("\nRIStrn_drop_table_view dropp = 0x%x\n",dropp));

	if (dropp->rhs->lhs->tok == RIS_TOK_AUTH_ID || 
		dropp->rhs->lhs->tok == RIS_TOK_USR_NAME)
	{
		TRN_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,dropp->rhs->lhs->pos);
	}
	RIStrn_table_name_w_type(dropp->rhs->lhs,0,0,NOT_DEFAULT_USER_SEARCH);

	RIStrn_det_dic_tab_mod(dropp->rhs->lhs->info.tab->tabname,
	 RIS_TOK_DROP_TABLE);
	RIStrn_check_dict_select(dropp->rhs->lhs->info.tab->tabname,
	 RIS_TOK_DROP_TABLE);

	dropp->rhs = dropp->rhs->lhs;
	switch(dropp->tok)
	{
		case RIS_TOK_DROP_TABLE:
			if (dropp->rhs->info.tab->tabtype == 'V')
			{
				TRN_ERR_RETURN(RIS_E_BASE_TABLE_ONLY,dropp->rhs->pos);
			}
		break;
		case RIS_TOK_DROP_VIEW:
			if (dropp->rhs->tok == RIS_TOK_TABLE && 
			 dropp->rhs->info.tab->tabtype == 'T')
			{
				TRN_ERR_RETURN(RIS_E_VIEW_ONLY,dropp->rhs->pos);
			}
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,dropp->pos);
		break;
	}
}

/******************************************************************************/

/*
** transform declare table/view parse tree to rax
** tp = declare table/view parse tree
** declare table/view is an RIS extension to the sql standard
*/

extern void RIStrn_declare_table_view(
ristree * declaretp)
{
	ristree * tp;
	ristree * schemap;
	ristree * tablep;
	ristree * cols;
	char * temp_name;
	ristree * ext_tp=0;
	ristree * ext_tablep=0;
	ristree * ext_cols=0;

	TRN_DBG(("\nRIStrn_declare_table createp = 0x%x\n",declaretp));

/* set up pointers; check for RIS_TOK_AUTH_ID */

	schemap = declaretp->rhs->lhs;
	if(schemap->tok == RIS_TOK_AUTH_ID)
	{
/* open non-default schema */
		schemap->info.schema = RISdic_open_schema(schemap->info.val, SYNC_MODE);
		schemap->tok = RIS_TOK_SCHEMA;
		tablep = schemap->rhs;
	}
	else
	{
		tablep = schemap;
	}
	cols = declaretp->rhs->rhs->lhs->rhs;

	/* James */
	/* The extern clause */
	if(declaretp->rhs->rhs->rhs && declaretp->rhs->rhs->rhs->lhs) 
	{
		ext_tablep=declaretp->rhs->rhs->rhs->lhs->rhs->lhs;
		/* external column list is optional, ext_cols can be null */
				  if(declaretp->rhs->rhs->rhs->lhs->rhs->rhs)
			ext_cols=declaretp->rhs->rhs->rhs->lhs->rhs->rhs->lhs->rhs;
	}


	if( declaretp->tok == RIS_TOK_DECLARE_TABLE )
	{
		RIStrn_det_dic_tab_mod(tablep->info.val,RIS_TOK_DECLARE_TABLE);
		RIStrn_check_dict_select(tablep->info.val,RIS_TOK_DECLARE_TABLE);
		if(ext_tablep)
		{
			if(ext_tablep->tok== RIS_TOK_USR_NAME)
			{
				RIStrn_det_dic_tab_mod(ext_tablep->rhs->info.val,
									RIS_TOK_DECLARE_TABLE);
				RIStrn_check_dict_select(ext_tablep->rhs->info.val,
									RIS_TOK_DECLARE_TABLE);
			}
			else
			{
				RIStrn_det_dic_tab_mod(ext_tablep->info.val,
									RIS_TOK_DECLARE_TABLE);
				RIStrn_check_dict_select(ext_tablep->info.val,
									RIS_TOK_DECLARE_TABLE);
			}
		}
	}
	else if( declaretp->tok == RIS_TOK_DECLARE_VIEW )
	{
		RIStrn_det_dic_tab_mod(tablep->info.val,RIS_TOK_DECLARE_VIEW);
		RIStrn_check_dict_select(tablep->info.val,RIS_TOK_DECLARE_VIEW);

		if(ext_tablep)
		{
			if(ext_tablep->tok== RIS_TOK_USR_NAME)
			{
				RIStrn_det_dic_tab_mod(ext_tablep->rhs->info.val,
										RIS_TOK_DECLARE_VIEW);
				RIStrn_check_dict_select(ext_tablep->rhs->info.val,
										RIS_TOK_DECLARE_VIEW);
			}
			else
			{
				RIStrn_det_dic_tab_mod(ext_tablep->info.val,
										RIS_TOK_DECLARE_VIEW);
				RIStrn_check_dict_select(ext_tablep->info.val,
										RIS_TOK_DECLARE_VIEW);
			}
		}
	}


/* make RIS_TOK_TABLE_NAME into a RIS_TOK_TABLE and remove RIS_TOK_LIST and RIS_TOK_COLUMN_DEF_LIST */

	temp_name = tablep->info.val;
	tablep->tok = RIS_TOK_TABLE;
	tablep->info.tab = ALLOCT(ristab);
	strcpy(tablep->info.tab->tabname,temp_name);
	if( declaretp->tok == RIS_TOK_DECLARE_TABLE )
		tablep->info.tab->tabtype = 'T';
	else if( declaretp->tok == RIS_TOK_DECLARE_VIEW )
			tablep->info.tab->tabtype = 'V';

	if(ext_tablep)
	{
		
		if(ext_tablep->tok== RIS_TOK_USR_NAME)
		{
			strcpy(tablep->info.tab->tabowner,ext_tablep->info.val);
			strcpy(tablep->info.tab->extern_tabname,
								ext_tablep->rhs->info.val);
		}
		else
		{
			if(RIS_default->db->dtype != '4')
			{
				strcpy(tablep->info.tab->tabowner,RIS_default->login_dbusr);
			}
			else
			{
				strcpy(tablep->info.tab->tabowner,
					RIS_default->db->dbname);
			}
			strcpy(tablep->info.tab->extern_tabname,
								ext_tablep->info.val);
		}
	}
	else
	{
		strcpy(tablep->info.tab->extern_tabname,
								tablep->info.tab->tabname);

		if(RIS_default->db->dtype != '4')
		{
			strcpy(tablep->info.tab->tabowner,RIS_default->login_dbusr);
		}
		else
		{
			strcpy(tablep->info.tab->tabowner,
					RIS_default->db->dbname);
		}

	}

   	/* AS/400 requires every thing in uppercase */
   	if(RIS_default->db->dtype == '4' 
           || RIS_default->db->dtype == 'O'
           || RIS_default->db->dtype == 'R'
           || RIS_default->db->dtype == 'D')
   	{
       RIScom_uppercase(strlen(tablep->info.tab->extern_tabname),
             (unsigned char *)tablep->info.tab->extern_tabname);
       RIScom_uppercase(strlen(tablep->info.tab->tabowner),
             (unsigned char *)tablep->info.tab->tabowner);
	}

	ext_tp=ext_cols;

	if(declaretp->rhs->lhs->tok == RIS_TOK_SCHEMA)
	{

		tablep->info.tab->schema = schemap->info.schema;/* non-default schema */
	}
	else
	{
		tablep->info.tab->schema = RIS_default; /* default schema */
	}
	cols = declaretp->rhs->rhs->lhs->rhs;
	tablep->rhs = cols;

/* hang the tablep to rhs of root */
	declaretp->rhs = tablep;

/* make RIS_TOK_COLUMN_DEFs into RIS_TOK_ATTRs */

	for (tp=cols;tp;tp=tp->rhs)
	{
		if( declaretp->tok == RIS_TOK_DECLARE_TABLE )
			RIStrn_create_attr(tp,ext_tp,cols,tablep->info.tab,RIS_TOK_DECLARE_TABLE);
		else if( declaretp->tok == RIS_TOK_DECLARE_VIEW )
				RIStrn_create_attr(tp,ext_tp,cols,tablep->info.tab,RIS_TOK_DECLARE_VIEW);
		if( ext_cols)
		{	
			if((tp->rhs && ! ext_tp->rhs) || (!tp->rhs && ext_tp->rhs)) 
			
			TRN_ERR_RETURN(RIS_E_MISMATCH_EXT_INT,tp->pos);

			ext_tp=ext_tp->rhs;
		}

    }

/* check the number of cols and the row length */

	RIStrn_check_row_size(cols,0,RIS_MAX_TABLE_COLUMNS,RIS_MAX_ROW_LENGTH,
	RIS_E_TOO_MANY_COLS,RIS_E_ROW_TOO_LONG);
}

/******************************************************************************/

/*
** transform undeclare table/view parse tree to rax
** tp = undeclare table/view parse tree
** undeclare table/view is an RIS extension to the sql standard
*/

extern void RIStrn_undeclare_table_view(
	ristree * undeclp)
{

	ristab		*tab;
	risschema	*schemap;
	char		*relname;

	TRN_DBG(("\nRIStrn_undeclare_table_view undeclp = 0x%x\n",undeclp));

	if(undeclp->rhs->lhs->tok == RIS_TOK_AUTH_ID)
	{
	   schemap = RISdic_open_schema(undeclp->rhs->lhs->info.val, SYNC_MODE);
	   relname = undeclp->rhs->lhs->rhs->info.val;
	}
	else
	{
	   schemap = RIS_default;
	   relname = undeclp->rhs->lhs->info.val;
	}

   	if (!(tab = RISdic_lookup_rel_in_hash(schemap,0,relname,0)))
	{
	  TRN_ERR_RETURN(RIS_E_REL_NOT_DECLARED,undeclp->rhs->pos);
	}

/* for better error detection below (in switch)*/
	undeclp->rhs->tok = RIS_TOK_TABLE;
	undeclp->rhs->info.tab = tab;
	undeclp->rhs->lhs = 0;
	undeclp->rhs->rhs = 0;

	if ( undeclp->tok == RIS_TOK_UNDECLARE_TABLE )
	{
		RIStrn_det_dic_tab_mod(undeclp->rhs->info.tab->tabname,
		 RIS_TOK_UNDECLARE_TABLE);
		RIStrn_check_dict_select(undeclp->rhs->info.tab->tabname,
		 RIS_TOK_UNDECLARE_TABLE);
	}
	else if( undeclp->tok == RIS_TOK_UNDECLARE_VIEW )
	{
		RIStrn_det_dic_tab_mod(undeclp->rhs->info.tab->tabname,
		 RIS_TOK_UNDECLARE_VIEW);
		RIStrn_check_dict_select(undeclp->rhs->info.tab->tabname,
		 RIS_TOK_UNDECLARE_VIEW);
	}
	
	  switch(undeclp->tok)
	  {
			case RIS_TOK_UNDECLARE_TABLE:
				if (undeclp->rhs->info.tab->tabtype == 'V')
				{
					TRN_ERR_RETURN(RIS_E_BASE_TABLE_ONLY,undeclp->rhs->pos);
				}
			break;
			case RIS_TOK_UNDECLARE_VIEW:
				if (undeclp->rhs->info.tab->tabtype == 'T')
				{
					TRN_ERR_RETURN(RIS_E_VIEW_ONLY,undeclp->rhs->pos);
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,undeclp->pos);
			break;
		}
}

/******************************************************************************/
