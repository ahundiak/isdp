/*
**	NAME:							trnshare.c
**	AUTHORS:						David Michal
**	CREATION DATE:					5/88
**	ABSTRACT:
**		This file contains the routines that are shared by ddl and dml.
**	
**	REVISION HISTORY:
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

/*
**	FUNCTION PROTOTYPES
*/
#define trnshare_c
#include "comaccss.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comauth.prt"
#include "comdict.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "dicacc.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "dicundss.prt"
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
** replace column name with column definition
** tp = [auth_id.[table_name.]column_name table_list = possible containing
** tables access = required privileges
** 5.7 <column specification> syntax rule 1
** 5.7 <column specification> syntax rule 2
** 5.7 <column specification> syntax rule 3a checked by RISdic_lookup_col
** 5.7 <column specification> syntax rule 3b checked by RISdic_lookup_col
** 5.7 <column specification> syntax rule 4
** 5.7 <column specification> syntax rule 5
*/

extern void RIStrn_col_name(
	ristree * tp,
	ristree * table_list,
	char * access)
{
	unsigned short pos;

TRN_DBG(("\nRIStrn_col_name tp = 0x%x table_list = 0x%x access = <%s>\n",
 tp,table_list,access ? access : "NONE"));

TRN_DBG(("RIStrn_col_name: tp->tok:%s\n", RIScom_get_token_name(tp->tok)));
	
	pos = tp->pos;
						 
	switch(tp->tok)
	{
		case RIS_TOK_AUTH_ID:
		case RIS_TOK_USR_NAME:
		case RIS_TOK_TABLE_NAME:
		case RIS_TOK_COL_NAME:
			memcpy((char*)tp,
					(char*)RISdic_lookup_col(table_list,tp,access),
					sizeof(ristree));
			tp->pos = pos;
		break;
		case RIS_TOK_ATTR:
			if (!RISdic_check_col_access(tp->info.attr->tab,tp->info.attr,
			 access))
			{
				TRN_ERR_RETURN(RIS_E_INVALID_ACCESS,tp->pos);
			}
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
		break;
	}
}

/******************************************************************************/

/*
** replace auth id  with schema definition
** tp = auth id
*/

extern void RIStrn_auth_id(
	ristree * tp)
{

	rissuperschema *sschema;

TRN_DBG(("RIStrn_auth_id tp = 0x%x\n",tp));

/*
** Making sure that tp->info.schema will either have a superschema
** or a regular schema. Useful for grant/revoke privileges to a 
** superschema. Also needed to change dicgrant.c, dicrevk.c, and 
** dicacc.c extensively for the same reasons. -prasad 7/92
*/

	if(sschema = RISdic_find_supersch(tp->info.val))
	{
		tp->info.sschema = sschema;
		tp->tok = RIS_TOK_SUPERSCHEMA;
	}
	else
	{
		tp->info.schema = RISdic_open_schema(tp->info.val, SYNC_MODE);
		tp->tok = RIS_TOK_SCHEMA;
	}

}

/******************************************************************************/

/*
** replace table name with table definition
** tp = table name
** access = required privileges
** schema = schema of the schema that must contain the table or view
*/

extern void RIStrn_table_name(
	ristree		*tp,
	char		*access,
	risschema	*schema,
	int			default_login_flag)
{
	risschema	*tab_sch;
	ristab	*tab;
	char	temp[RIS_MAX_ID_SIZE];

	TRN_DBG(("RIStrn_table_name(tp:0x%x access:<%s> schema:0x%x login:%d)\n",
		tp, access ? access : "NONE", schema, default_login_flag));

	switch(tp->tok)
	{
		case RIS_TOK_TABLE_NAME:
            if (default_login_flag)
			{
				tab = RISdic_lookup_rel(RIS_default, RIS_default->login_dbusr, 
					tp->info.val, access);
			}
			else
			{
				tab = RISdic_lookup_rel(RIS_default, "", tp->info.val, access);
			}
			tp->info.tab = tab;
			tp->tok = RIS_TOK_TABLE;
            RIStrn_insert_in_tablist(tp->info.tab);
			RIStrn_generate_attr_list(tp);
			TRN_DBG(("RIStrn_table_name: table_name <%s.%s>\n",
				tp->info.tab->tabowner, tp->info.tab->tabname));
		break;
		case RIS_TOK_USR_NAME:
            tab = RISdic_lookup_rel(RIS_default, tp->info.val, 
				tp->rhs->info.val, access);
			tp->info.tab = tab;
			tp->tok = RIS_TOK_TABLE;
            RIStrn_insert_in_tablist(tp->info.tab);
			RIStrn_generate_attr_list(tp);
			TRN_DBG(("RIStrn_table_name: table_name <%s.%s>\n",
				tp->info.tab->tabowner, tp->info.tab->tabname));
		break;
		case RIS_TOK_AUTH_ID:
            tab_sch = RISdic_open_schema(tp->info.val, SYNC_MODE);
            if (tp->rhs->tok == RIS_TOK_USR_NAME)
			{
				tab = RISdic_lookup_rel(tab_sch, tp->rhs->info.val,
					tp->rhs->rhs->info.val, access);
			}
			else
			{
            	if (default_login_flag)
				{
					tab = RISdic_lookup_rel(tab_sch, tab_sch->login_dbusr, 
						tp->rhs->info.val, access);
				}
				else
				{
					tab = RISdic_lookup_rel(tab_sch, "", tp->rhs->info.val, 
						access);
				}
			}
			tp->info.tab = tab;
			tp->tok = RIS_TOK_TABLE;
            RIStrn_insert_in_tablist(tp->info.tab);
			RIStrn_generate_attr_list(tp);
			TRN_DBG(("RIStrn_table_name: table_name <%s.%s>\n",
				tp->info.tab->tabowner, tp->info.tab->tabname));
		break;
		case RIS_TOK_TABLE:
			if (RIScom_has_auth(RIScom_combine_access(tp->info.tab->acc,
			 RIS_default->schname,1,temp),access) == 0)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_ACCESS,tp->pos);
			}
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
		break;
	}
	if (schema)
	{
		if (tp->info.tab->tabtype == 'A')
		{
			if (schema != tp->info.tab->tab->schema)
			{
				TRN_ERR_RETURN(RIS_E_MULT_SCHEMA_NOT_ALLOWED,tp->pos);
			}
		}
		else
		{
			if (schema != tp->info.tab->schema)
			{
				TRN_ERR_RETURN(RIS_E_MULT_SCHEMA_NOT_ALLOWED,tp->pos);
			}
		}
	}
	TRN_DBG(("RIStrn_table_name: returning\n"));
}

/******************************************************************************/

/*
** replace table name with table definition
** tp = table name
** access = required privileges
** schema = schema of the schema that must contain the table or view
**
** This routine is partly a pass-through to RIStrn_table_name, 
** but then it makes sure that the tabtype of the object (T,V)
** is set correctly.
*/

extern void RIStrn_table_name_w_type(
	ristree * tp,
	char * access,
	risschema * schema,
	int	default_login_flag)
{
	RIStrn_table_name(tp, access, schema, default_login_flag);

	if (!tp->info.tab->tabtype)
	{
		RISdic_lookup_reltype(tp->info.tab->schema, 
			tp->info.tab->tabowner, tp->info.tab->tabname, access);
	}
}

/******************************************************************************/

/*
** replace RIS_TOK_QUESTION with RIS_TOK_PARAMETER
** parmp = parameter question mark
*/

extern void RIStrn_parm_quest(
	ristree * parmp)
{
	ristree * tp;

TRN_DBG(("\nRIStrn_parm_quest parmp = 0x%x\n",parmp));

	parmp->tok = RIS_TOK_PARAMETER;
	parmp->info.data = ALLOCT(internal_sqlvar);
	tp = ALLOCT(ristree);
	tp->tok = RIS_TOK_LIST;
	tp->lhs = parmp;
	tp->rhs = RIStrn_parm_list;
	RIStrn_parm_list = tp;
	RIStrn_parm_index++;
}

/******************************************************************************/

extern char * RIStrn_get_non_update_access(
	ristree * tp)
{
	char * access;
	char temp[RIS_MAX_ID_SIZE];

TRN_DBG(("\nRIStrn_get_non_update_access tp = 0x%x\n",tp));

	access = ALLOCB(ACC_SIZE);
	RIScom_init_auth(access);
	RIScom_add_auth(access,GRANTABLE_SELECT_ACCESS);
	if (tp)
	{
		switch(tp->tok)
		{
			case RIS_TOK_TABLE:
				RIScom_intersect_auth(access,RIScom_combine_access(
				 tp->info.tab->acc,RIS_default->schname,1,temp));
			break;
			case RIS_TOK_LIST:
				RIScom_intersect_auth(access,RIStrn_get_non_update_access(
				 tp->lhs));
				RIScom_intersect_auth(access,RIStrn_get_non_update_access(
				 tp->rhs));
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
			break;
		}
	}
	return(access);
}

/******************************************************************************/

extern void RIStrn_check_dict_select(
	char	*tab_name,
	int		token)
{
	TRN_DBG(("RIStrn_check_dict_select tab_name = <%s> token = %d\n",
		tab_name,token));
	if (!RIS_upgrade_flag)
	{
		int		tabid = 0;

		tabid = RIScom_get_dict_tabid(tab_name);
		if (RIS_dict_select_flag && (tabid == -1 || token != RIS_TOK_SELECT))
		{
			LONGJMP(RIS_E_DICT_SELECT_ONLY);
		}
		if(RIScom_is_v4_dict_tabid(tabid) && RIS_app_cli_version > 4)
		{
			LONGJMP(RIS_E_CANT_ACCESS_V4_DICT_OBJECT);
		}
		if(RIScom_is_v5_dict_tabid(tabid) && RIS_app_cli_version < 5)
		{
			LONGJMP(RIS_E_CANT_ACCESS_V5_DICT_OBJECT);
		}
	}
	TRN_DBG(("RIStrn_check_dict_select: returning\n"));
}

/******************************************************************************/

extern void RIStrn_det_dic_tab_mod(
	char	*tab_name,
	int		token)
{
TRN_DBG(("RIStrn_det_dic_tab_mod tab_name = <%s> token = %d\n",tab_name,token));

/*
**  Added condition for RIS_upgrade_flag so that we can bypass this
**  function during the risupgrade process. This will allow us to
**  decalre,insert and update RIS dictionary objects. RAJU 03/02/94
*/

	if  (RIScom_get_dict_tabid(tab_name) != -1 && !RIS_upgrade_flag)
	{
		switch(token)
		{
			case RIS_TOK_INSERT:
			case RIS_TOK_DELETE:
			case RIS_TOK_UPDATE:
				LONGJMP(RIS_E_CANT_MANIPULATE_RISOBJ);
			break;
			case RIS_TOK_ALTER_TABLE:
				LONGJMP(RIS_E_CANT_ALTER_RISOBJ);
			break;
			case RIS_TOK_DROP_INDEX:
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_DROP_VIEW:
				LONGJMP(RIS_E_CANT_DROP_RISOBJ);
			break;
			case RIS_TOK_LOCK_TABLES:
				LONGJMP(RIS_E_CANT_LOCK_RISOBJ);
			break;
			case RIS_TOK_GRANT:
			case RIS_TOK_REVOKE:
				LONGJMP(RIS_E_CANT_DEF_PRIV_ON_RISOBJ);
			break;
			case RIS_TOK_CREATE_TABLE:
			case RIS_TOK_CREATE_VIEW:
			case RIS_TOK_CREATE_INDEX:
				LONGJMP(RIS_E_CANT_CREATE_RISOBJ);
			break;
			case RIS_TOK_DECLARE_TABLE:
			case RIS_TOK_DECLARE_VIEW:
				LONGJMP(RIS_E_CANT_DECLARE_RISOBJ);
			break;
			case RIS_TOK_UNDECLARE_TABLE:
			case RIS_TOK_UNDECLARE_VIEW:
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
}

/******************************************************************************/

extern void RIStrn_check_row_size(
	ristree * tp1,
	ristree * tp2,
	int max_cols,
	int max_row_len,
	int col_error,
	int len_error)
{
	ristree * tp;
	int col_count = 0;
	int row_length = 0;

	TRN_DBG(("RIStrn_check_row_size(tp1:0x%x tp2:0x%x max_cols:%d "
		"max_row_len:%d col_error:%d len_error:%d\n", tp1, tp2, max_cols,
		max_row_len, col_error, len_error));

	for (tp=tp1;tp != tp2;tp=tp2)
	{
		for (;tp;tp=tp->rhs)
		{
			if (++col_count > max_cols)
			{
				TRN_ERR_RETURN(col_error,tp->lhs->pos);
			}
			row_length += 2;
			switch(ATTR_TYPE(tp->lhs->info.attr->atype))
			{
				case RIS_INTEGER:
					row_length += RIS_INTEGER_PRECISION;
				break;
				case RIS_SMALLINT:
					row_length += RIS_SMALLINT_PRECISION;
				break;
				case RIS_REAL:
					row_length += RIS_REAL_PRECISION;
				break;
				case RIS_DOUBLE:
					row_length += RIS_DOUBLE_PRECISION;
				break;
				case RIS_CHARACTER:
					row_length += tp->lhs->info.attr->asize.len;
				break;
				case RIS_DECIMAL:
					row_length += tp->lhs->info.attr->asize.dec.prec;
				break;
				case RIS_DATETIME:
					row_length += RIS_DATETIME_PRECISION;
				break;
				case RIS_BLOB:
				case RIS_TEXT:
					row_length += sizeof(ris_blob);
					TRN_DBG(("RIStrn_chek_row_size,row_length=%d\n",row_length));
					TRN_DBG(("BLOB tp->lhs->info.attr->asize.len=%d\n", 
					tp->lhs->info.attr->asize.len));
				break;
				case RIS_UNSUPPORTED_TYPE:
					row_length += RIS_types[RIS_UNSUPPORTED_TYPE].sqllen;
				break;
				default:
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				break;
			}
			if (row_length > max_row_len)
			{
				TRN_ERR_RETURN(len_error,tp->lhs->pos);
			}
		}
	}

TRN_DBG(("column count = %d row length = %d\n",col_count,row_length));

}

/******************************************************************************/

extern void RIStrn_col_unsupported(
    ristree *cols)
{
    ristree *tp;

    TRN_DBG(("RIStrn_col_unsupported:\n"));

    for (tp=cols;tp;tp=tp->rhs)
    {
        if( tp->lhs && tp->lhs->tok == RIS_TOK_ATTR )
            RIStrn_check_unsupported_type(tp->lhs);
    }
    TRN_DBG(("RIStrn_col_unsupported: complete\n"));
}

/******************************************************************************/

extern void RIStrn_check_unsupported_type(
    ristree *tp)
{
    TRN_DBG(("RIStrn_check_unsupported_type:\n"));

    if( tp && tp->tok == RIS_TOK_ATTR )
            if(ATTR_TYPE(tp->info.attr->atype) == RIS_UNSUPPORTED_TYPE)
                TRN_ERR_RETURN(RIS_E_UNSUPPORTED_TYPE,tp->pos);

    TRN_DBG(("RIStrn_check_unsupported_type: complete\n"));
}

/******************************************************************************/

extern void RIStrn_generate_attr_list(
	ristree *tablep)
{
	risattr *attr;
	ristree *temp;

	TRN_DBG(("RIStrn_generate_attr_list(tablep:0x%x)\n", tablep));

	for (attr = tablep->info.tab->attr; attr; attr = attr->next)
	{
		temp = ALLOCT(ristree);	
		temp->tok = RIS_TOK_LIST;
		temp->lhs = ALLOCT(ristree);
		temp->lhs->tok = RIS_TOK_ATTR;
		temp->lhs->info.attr = attr;
		tablep->rhs = temp;
		tablep = tablep->rhs;
	}

	TRN_DBG(("RIStrn_generate_attr_list:complete\n"));
}

/******************************************************************************/

extern void RIStrn_insert_in_tablist(
    ristab      *tabp)
{
    ristablist *prevlistp = 0;
    ristablist *tablistp;
    ristablist *new;

    TRN_DBG(("RIStrn_insert_in_tablist:(tabname:%s)\n",tabp->tabname));

    for( tablistp = RIS_stmt->tablist; tablistp; tablistp = tablistp->next )
    {
		TRN_DBG(("comparing table pointers\n"));
        if( tabp == tablistp->tab )
        {
			TRN_DBG(("exists in tablist.\n"));
			break;
        }
        if( tabp < tablistp->tab )
        {
			new = ALLOCT(ristablist);
			new->tab = tabp;
			tabp->ref_count++;
			TRN_DBG(("Incrementing ref_count to:%d tab:%s sch:%s\n",
				tabp->ref_count, tabp->tabname, tabp->schema->schname));

            if( prevlistp )
            {
				TRN_DBG(("adding into middle of tablist\n"));
                prevlistp->next = new;
                new->next = tablistp;
            }
            else
            {
				TRN_DBG(("adding to beginning of tablist\n"));
                RIS_stmt->tablist = new;
                new->next = tablistp;
            }
			break;
        }
        prevlistp = tablistp;
    }
	if (!tablistp)
	{
		new = ALLOCT(ristablist);
		new->tab = tabp;
		tabp->ref_count++;
		TRN_DBG(("Incrementing ref_count to:%d tab:%s sch:%s\n",
			tabp->ref_count, tabp->tabname, tabp->schema->schname));

		if (prevlistp)
		{
			TRN_DBG(("adding to end of tablist\n"));
    		prevlistp->next = new;
		}
		else
		{
			TRN_DBG(("creating new tablist\n"));
        	RIS_stmt->tablist = new;
    	}
	}

    TRN_DBG(("RIStrn_insert_in_tablist: complete\n"));
}

/******************************************************************************/
