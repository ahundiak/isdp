/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnparms.c
**	AUTHORS:						David Michal
**	CREATION DATE:					9/88
**	ABSTRACT:
**		This file contains the routine that handles parameters.
**	
**	REVISION HISTORY:
**		add RIStrn_parms_compatible() by Jin Jing 8/93
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "riscli.h"
#include "rismem.h"
#include "ristypes.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnparms_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "trnparms.prt"
#include "trntypsz.prt"
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

extern void RIStrn_parms(
	ristree	*list,
	int		count,
	int		input)
{
	int			i;
	int			cur_pos;
	int			init_pos;
	internal_sqlda		*sqldap;
	risattr		*attr;
	ristree		*temp;
	union asize asize;

	TRN_DBG(("RIStrn_parms(list:0x%x count:%d input:%d)\n",list,count,input));

	if (input)
	{

		RIS_stmt->sql->input = (internal_sqlda *)
								ALLOCB(sizeof(internal_sqlda) + sizeof(internal_sqlvar) * count);
		sqldap = RIS_stmt->sql->input;
	}
	else
	{
		RIS_stmt->sql->output = (internal_sqlda *)
								ALLOCB(sizeof(internal_sqlda) + sizeof(internal_sqlvar) * count);
		sqldap = RIS_stmt->sql->output;
	}

	sqldap->sqld = (short)count;
	sqldap->sqln = (short)count;
	sqldap->sqlvar = (internal_sqlvar *)(sqldap + 1);

	TRN_DBG(("RIStrn_parms: internal_sqlda:0x%x sqld:%d sqln:%d sqlvar:0x%x\n",
		sqldap, sqldap->sqld, sqldap->sqln, sqldap->sqlvar));

	init_pos = 0;
	cur_pos = init_pos;
	for (i=0,temp=list;i < count;i++,temp=temp->rhs)
	{
		TRN_DBG(("RIStrn_parms: tok:%s\n",
			RIScom_get_token_name(temp->lhs->tok)));

		switch(temp->lhs->tok)
		{
			case RIS_TOK_APPROX_NUM_LIT:
			case RIS_TOK_EXACT_NUM_LIT:
			case RIS_TOK_CHAR_STR_LIT:
			case RIS_TOK_TIMESTAMP_LIT:
			case RIS_TOK_CURRENT_TIMESTAMP:
				sqldap->sqlvar[i].sqlname.sqlnamel = 8;
				memcpy(sqldap->sqlvar[i].sqlname.sqlnamec,"constant",8);
				sqldap->sqlvar[i].sqltype = (short)RIStrn_get_type(temp->lhs);
				asize.len = (unsigned short)RIStrn_get_size(temp->lhs);

			
/*********  BLOB **************/
                switch (ATTR_TYPE(sqldap->sqlvar[i].sqltype))
                {

                case    RIS_DECIMAL:
                    sqldap->sqlvar[i].sqllen = asize.dec.prec +(short)3;
                    sqldap->sqlvar[i].sqlscale = asize.dec.scale;
                break;

                case    RIS_BLOB:
                case    RIS_TEXT:
                    sqldap->sqlvar[i].sqllen = sizeof(ris_blob);
                    sqldap->sqlvar[i].max_blob_sqllen = asize.len;
                break;

                default:
                    sqldap->sqlvar[i].sqllen = asize.len;
                break;
                }
/*********  BLOB **************/

			break;
			case RIS_TOK_ATTR:
                attr = temp->lhs->info.attr;
if (RIStrn_debug)
{
    RIScom_output_debug("attr->atype = %s\n", RIS_types[ATTR_TYPE(attr->atype)].string);
    RIScom_output_debug("attr->asize.len = %d\n",attr->asize.len);
    if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
    {
        RIScom_output_debug("attr->asize.dec.prec = %d\n",attr->asize.dec.prec);
        RIScom_output_debug("attr->asize.dec.scale = %d\n",attr->asize.dec.scale);
    }
    if (attr->tab)
	{
		RIScom_output_debug("attr->tab->tabowner = %s\n",attr->tab->tabowner);
        RIScom_output_debug("attr->tab->tabname = %s\n",attr->tab->tabname);
	}
    RIScom_output_debug("attr->attrname = %s\n", attr->attrname);
    RIScom_output_debug("attr->extern_attrname = %s\n", attr->extern_attrname);
    RIScom_output_debug("attr->dbsqltype = %d\n", attr->dbsqltype);
    RIScom_output_debug("attr->dbsqllen = %d\n", attr->dbsqllen);
}
				if (ATTR_TYPE(attr->atype) == RIS_CHARACTER &&
					attr->asize.len == 0)
				{
					LONGJMP(RIS_E_CHAR_COL_INVALID);
				}
                if (*attr->attrname)
                {
                    sqldap->sqlvar[i].sqlname.sqlnamel =
						(short)strlen(attr->attrname);
                    memcpy(sqldap->sqlvar[i].sqlname.sqlnamec,
                            attr->attrname,
                            sqldap->sqlvar[i].sqlname.sqlnamel);
					if(*attr->extern_attrname)
					{
                    	sqldap->sqlvar[i].extern_sqlname.sqlnamel =
						(short)strlen(attr->extern_attrname);
                    	memcpy(sqldap->sqlvar[i].extern_sqlname.sqlnamec,
                            attr->extern_attrname,
                            sqldap->sqlvar[i].extern_sqlname.sqlnamel);
					}
					else
					{
			        	/*if (strlen(attr->attrname) > 10 && 
							RIS_stmt->sql->schema->db->dtype == '4')
        				{
            				LONGJMP(RIS_E_NAME_TOO_LONG);
        				}
						else
						{*/
                    		sqldap->sqlvar[i].extern_sqlname.sqlnamel =
											(short)strlen(attr->attrname);
                    		memcpy(sqldap->sqlvar[i].extern_sqlname.sqlnamec,
                            		attr->attrname,
                            		sqldap->sqlvar[i].extern_sqlname.sqlnamel);
						/*}*/
					}	
                }
                else
                {
                    sqldap->sqlvar[i].sqlname.sqlnamel = sizeof("expression")-1;
                    memcpy(sqldap->sqlvar[i].sqlname.sqlnamec,"expression",10);
                    sqldap->sqlvar[i].extern_sqlname.sqlnamel = 
						sizeof("expression")-1;
                    memcpy(sqldap->sqlvar[i].extern_sqlname.sqlnamec,"expression",10);
                }

/*********  BLOB **************/
                sqldap->sqlvar[i].sqltype=(short)ATTR_TYPE(attr->atype);
                switch (sqldap->sqlvar[i].sqltype)
                {

                case  RIS_DECIMAL:
                    sqldap->sqlvar[i].sqllen = attr->asize.dec.prec +(short)3;
                    sqldap->sqlvar[i].sqlscale = attr->asize.dec.scale;
                break;

                case RIS_BLOB:
                case RIS_TEXT:
                    sqldap->sqlvar[i].sqllen = sizeof(ris_blob);
                    sqldap->sqlvar[i].max_blob_sqllen = attr->asize.len;
                break;

                default:
                    sqldap->sqlvar[i].sqllen = attr->asize.len;
                break;
                }
/*********  BLOB **************/

                sqldap->sqlvar[i].sqlnull = (short)ATTR_FLAG(attr->atype);

/* Added 5/19/92 - Sunil */
                sqldap->sqlvar[i].dbsqltype = attr->dbsqltype;
                sqldap->sqlvar[i].dbsqllen = attr->dbsqllen;

            break;

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
				attr = temp->lhs->info.attr;
if (RIStrn_debug)
{
	RIScom_output_debug("attr->atype = %s\n", 
		RIS_types[ATTR_TYPE(attr->atype)].string);
	RIScom_output_debug("attr->asize.len = %d\n",attr->asize.len);
	if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
	{
		RIScom_output_debug("attr->asize.dec.prec = %d\n",attr->asize.dec.prec);
		RIScom_output_debug("attr->asize.dec.scale = %d\n",attr->asize.dec.scale);
	}
	if (attr->tab)
	{
		RIScom_output_debug("attr->tab->tabowner = %s\n",attr->tab->tabowner);
		RIScom_output_debug("attr->tab->tabname = %s\n",attr->tab->tabname);
	}
	RIScom_output_debug("attr->attrname = %s\n", attr->attrname);
	RIScom_output_debug("attr->extern_attrname = %s\n", attr->extern_attrname);
}
				if (*attr->attrname)
				{
					sqldap->sqlvar[i].sqlname.sqlnamel =
						(short)strlen(attr->attrname);
					memcpy(sqldap->sqlvar[i].sqlname.sqlnamec,
							attr->attrname,
							sqldap->sqlvar[i].sqlname.sqlnamel);
                    sqldap->sqlvar[i].extern_sqlname.sqlnamel =
						(short)strlen(attr->extern_attrname);
                    memcpy(sqldap->sqlvar[i].extern_sqlname.sqlnamec,
                            attr->extern_attrname,
                            sqldap->sqlvar[i].extern_sqlname.sqlnamel);
				}
				else
				{
					sqldap->sqlvar[i].sqlname.sqlnamel = sizeof("expression")-1;
					memcpy(sqldap->sqlvar[i].sqlname.sqlnamec,"expression",10);
                    sqldap->sqlvar[i].extern_sqlname.sqlnamel = 
						sizeof("expression")-1;
                    memcpy(sqldap->sqlvar[i].extern_sqlname.sqlnamec,"expression",10);
				}

/*********  BLOB **************/
                sqldap->sqlvar[i].sqltype=(short)ATTR_TYPE(attr->atype);
                switch (ATTR_TYPE(sqldap->sqlvar[i].sqltype))
                {
                case RIS_DECIMAL:
                    sqldap->sqlvar[i].sqllen = attr->asize.dec.prec + (short)3;
                    sqldap->sqlvar[i].sqlscale = attr->asize.dec.scale;
                break;
                case RIS_BLOB:
                case RIS_TEXT:
                    sqldap->sqlvar[i].sqllen = sizeof(ris_blob);
                    sqldap->sqlvar[i].max_blob_sqllen = attr->asize.len;
                break;
                default:
                    sqldap->sqlvar[i].sqllen = attr->asize.len;
                break;
                }
/*********  BLOB **************/


				sqldap->sqlvar[i].sqlnull = (short)ATTR_FLAG(attr->atype);

/* Added 5/19/92 - Sunil */
				sqldap->sqlvar[i].dbsqltype = -9999;
				sqldap->sqlvar[i].dbsqllen = 0;
			break;
			case RIS_TOK_PARAMETER:
				sqldap->sqlvar[i] = *temp->lhs->info.data;
				temp->lhs->info.data = &sqldap->sqlvar[i];
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->lhs->pos);
			break;
		}

		sqldap->sqlvar[i].sqlind = (long *)RIS_ALIGN(RIS_INTEGER,cur_pos);
		cur_pos += RIS_types[RIS_INTEGER].sqllen;
		sqldap->sqlvar[i].sqldata = (char *)RIS_ALIGN(sqldap->sqlvar[i].sqltype,cur_pos);

		if (sqldap->sqlvar[i].sqltype == RIS_DECIMAL &&
			sqldap->sqlvar[i].sqllen < RIS_types[RIS_DOUBLE].sqllen)
		{
			/*
			**	INGRES always needs room for a double so do it here for
			**	all databases.
			*/
			cur_pos += RIS_types[RIS_DOUBLE].sqllen;
		}
		/*******  BLOB *********/
		else if (sqldap->sqlvar[i].sqltype == RIS_BLOB  ||
                sqldap->sqlvar[i].sqltype == RIS_TEXT )
        {
                /* Reserve sizeof(ris_blob) for blob/text type on the buffer */
            cur_pos += sizeof(ris_blob);
        }else 
		{
			cur_pos += sqldap->sqlvar[i].sqllen;
		}

		if (sqldap->sqlvar[i].sqltype == RIS_CHARACTER ||
			sqldap->sqlvar[i].sqltype == RIS_DECIMAL)
		{
			cur_pos++;
		}

		if (RIStrn_debug)
		{
			RIScom_output_debug("parm %d  sqlname = %s  sqltype = %s  sqllen = %d",
			 	i, sqldap->sqlvar[i].sqlname.sqlnamec,
				RIS_types[sqldap->sqlvar[i].sqltype].string,
				sqldap->sqlvar[i].sqllen);
			if (sqldap->sqlvar[i].sqltype == RIS_DECIMAL)
			{
				RIScom_output_debug("  sqlscale = %d", sqldap->sqlvar[i].sqlscale);
			}
			RIScom_output_debug("\nsqlind = 0x%x sqldata = 0x%x\n", 
				sqldap->sqlvar[i].sqlind,
				sqldap->sqlvar[i].sqldata);
		}
	}

/*
** This alignment is needed for input beacuse sqlvar structures are put in
** the user buffer immediately after the input data.  It is needed for output
** beacuse there can be multiple rows of output in the server buffer.
*/

    RIS_ALIGN(RIS_DOUBLE,cur_pos);

	if (input)
	{
		RIS_stmt->sql->input_len = cur_pos-init_pos;
		TRN_DBG(("RIStrn_parms:input length:%d\n" ,RIS_stmt->sql->input_len));
	}
	else
	{
		RIS_stmt->row_len = cur_pos-init_pos;
		TRN_DBG(("RIStrn_parms:row length:%d\n",RIS_stmt->row_len));
	}

	TRN_DBG(("RIStrn_parms:complete\n"));
}

/******************************************************************************/

extern void RIStrn_parms_compatible(
	ristree	*list,
	int		count,
	int		input)
{
	int			i;
	int			cur_pos;
	int			init_pos;
	int			type, len;
	internal_sqlda		*sqldap;
	risattr		*attr;
	ristree		*temp;
	union asize asize;

	TRN_DBG(("RIStrn_parms_compatible(list:0x%x count:%d input:%d)\n",list,count,input));

	if (input)
	{
		sqldap = RIS_stmt->sql->input;
	}
	else
	{
		sqldap = RIS_stmt->sql->output;
	}

	TRN_DBG(("RIStrn_parms_compatible: internal_sqlda:0x%x sqld:%d sqln:%d sqlvar:0x%x\n",
		sqldap, sqldap->sqld, sqldap->sqln, sqldap->sqlvar));

	if (sqldap->sqld != count)
	{
		TRN_ERR_RETURN(RIS_E_INCORRECT_NUMBER_OF_COLUMNS,list->lhs->pos);
	}

	init_pos = 0;
	cur_pos = init_pos;
	for (i=0,temp=list;i < count;i++,temp=temp->rhs)
	{
		TRN_DBG(("RIStrn_parms_compatible: tok:%s\n",
			RIScom_get_token_name(temp->lhs->tok)));

		if (!RIStrn_types_compatible(sqldap->sqlvar[i].sqltype, 
			(short)RIStrn_get_type(temp->lhs)))
		{
			TRN_ERR_RETURN(RIS_E_INCOMPATIBLE_TYPE_OF_COLUMNS,temp->lhs->pos);
		}

		switch(temp->lhs->tok)
		{
			case RIS_TOK_APPROX_NUM_LIT:
			case RIS_TOK_EXACT_NUM_LIT:
			case RIS_TOK_CHAR_STR_LIT:
			case RIS_TOK_TIMESTAMP_LIT:
			case RIS_TOK_CURRENT_TIMESTAMP:
				type = (short)RIStrn_get_type(temp->lhs);
				asize.len = (unsigned short)RIStrn_get_size(temp->lhs);
				if (ATTR_TYPE(type) == RIS_DECIMAL)
				{
					len = asize.dec.prec + (short)3;
				}
				else
				{
					len = asize.len;
				}
				if (len > sqldap->sqlvar[i].sqllen)
				{
					sqldap->sqlvar[i].sqltype = 
						(short)RIStrn_get_type(temp->lhs);
					if (ATTR_TYPE(sqldap->sqlvar[i].sqltype) == RIS_DECIMAL)
					{
						sqldap->sqlvar[i].sqllen = asize.dec.prec + (short)3;
						sqldap->sqlvar[i].sqlscale = asize.dec.scale;
					}
					else
					{
						sqldap->sqlvar[i].sqllen = asize.len;
					}
				}
			break;
			case RIS_TOK_ATTR:
                attr = temp->lhs->info.attr;
				if (ATTR_TYPE(attr->atype) == RIS_CHARACTER &&
					attr->asize.len == 0)
				{
					LONGJMP(RIS_E_CHAR_COL_INVALID);
				}
                type=(short)ATTR_TYPE(attr->atype);
                if (type == RIS_DECIMAL)
                {
                    len = attr->asize.dec.prec + (short)3;
                }
                else
                {
                    len = attr->asize.len;
                }
				if (len > sqldap->sqlvar[i].sqllen)
				{
                	if ((sqldap->sqlvar[i].sqltype=
						(short)ATTR_TYPE(attr->atype)) == RIS_DECIMAL)
                	{
                    	sqldap->sqlvar[i].sqllen = 
							attr->asize.dec.prec + (short)3;
                    	sqldap->sqlvar[i].sqlscale = 
							attr->asize.dec.scale;
                	}
                	else
                	{
                    	sqldap->sqlvar[i].sqllen = attr->asize.len;
                	}
                	sqldap->sqlvar[i].sqlnull = (short)ATTR_FLAG(attr->atype);

/* Added 5/19/92 - Sunil */
                	sqldap->sqlvar[i].dbsqltype = attr->dbsqltype;
                	sqldap->sqlvar[i].dbsqllen = attr->dbsqllen;
				}		
            break;

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
				attr = temp->lhs->info.attr;
				if ((type=(short)ATTR_TYPE(attr->atype))== RIS_DECIMAL)
				{
					len = attr->asize.dec.prec + (short)3;
				}
				else
				{
					len = attr->asize.len;
				}
				if (len > sqldap->sqlvar[i].sqllen)
				{
					if ((sqldap->sqlvar[i].sqltype=
						(short)ATTR_TYPE(attr->atype)) == RIS_DECIMAL)
					{
						sqldap->sqlvar[i].sqllen = 
							attr->asize.dec.prec + (short)3;
						sqldap->sqlvar[i].sqlscale = attr->asize.dec.scale;
					}
					else
					{
						sqldap->sqlvar[i].sqllen = attr->asize.len;
					}
					sqldap->sqlvar[i].sqlnull = (short)ATTR_FLAG(attr->atype);
		
/* Added 5/19/92 - Sunil */
					sqldap->sqlvar[i].dbsqltype = -9999;
					sqldap->sqlvar[i].dbsqllen = 0;
				}
			break;
			case RIS_TOK_PARAMETER:
				sqldap->sqlvar[i] = *temp->lhs->info.data;
				temp->lhs->info.data = &sqldap->sqlvar[i];
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->lhs->pos);
			break;
		}

		sqldap->sqlvar[i].sqlind = (long *)RIS_ALIGN(RIS_INTEGER,cur_pos);
		cur_pos += RIS_types[RIS_INTEGER].sqllen;
		sqldap->sqlvar[i].sqldata = (char *)RIS_ALIGN(sqldap->sqlvar[i].sqltype,cur_pos);

		if (sqldap->sqlvar[i].sqltype == RIS_DECIMAL &&
			sqldap->sqlvar[i].sqllen < RIS_types[RIS_DOUBLE].sqllen)
		{
			/*
			**	INGRES always needs room for a double so do it here for
			**	all databases.
			*/
			cur_pos += RIS_types[RIS_DOUBLE].sqllen;
		}
		else
		{
			cur_pos += sqldap->sqlvar[i].sqllen;
		}

		if (sqldap->sqlvar[i].sqltype == RIS_CHARACTER ||
			sqldap->sqlvar[i].sqltype == RIS_DECIMAL)
		{
			cur_pos++;
		}
	}

/*
** This alignment is needed for input beacuse sqlvar structures are put in
** the user buffer immediately after the input data.  It is needed for output
** beacuse there can be multiple rows of output in the server buffer.
*/

    RIS_ALIGN(RIS_DOUBLE,cur_pos);

	if (input)
	{
		RIS_stmt->sql->input_len = cur_pos-init_pos;
		TRN_DBG(("RIStrn_parms_compatible:input length:%d\n" ,RIS_stmt->sql->input_len));
	}
	else
	{
		RIS_stmt->row_len = cur_pos-init_pos;
		TRN_DBG(("RIStrn_parms_compatible:row length:%d\n",RIS_stmt->row_len));
	}

	TRN_DBG(("RIStrn_parms_compatible:complete\n"));
}

/******************************************************************************/
