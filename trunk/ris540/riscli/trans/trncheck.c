/* Do not alter this SPC information: $Revision: 1.2.30.1 $ */
/*
**	NAME:							trncheck.c
**	AUTHORS:						David Michal
**	CREATION DATE:					5/88
**	ABSTRACT:
**
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
#include "ristypes.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trncheck_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comdcml.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#if defined(WIN32)
#include "comisfn.prt"
#include "comuni.prt"
#endif
#include "trncheck.prt"
#include "trncptyp.prt"
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

extern void RIStrn_typecheck(
	ristree	*tp,
	int		targ_type,
	int		targ_size)
{
#if defined(WIN32)
#else
	int			j;
	int			i, size;	
#endif
	int			size1,size2;
	int			type1,type2,type3;
	char		*set_val;
	union asize	asize;

	TRN_DBG(("RIStrn_typecheck(tp:0x%x targ_type:%s targ_size:%d)\n",
		tp, RIS_types[ATTR_TYPE(targ_type)].string, targ_size));

	switch(tp->tok)
	{
		case RIS_TOK_ASGN:

TRN_DBG(("RIStrn_typecheck:found an assignment operator\n"));

			type1 = RIStrn_get_type(tp->lhs);
			type2 = RIStrn_get_type(tp->rhs);

			RIStrn_compare_types(type1,type2,targ_type, tp->pos);
			if (!NULLS_ALLOWED(targ_type) && tp->rhs->tok == RIS_TOK_NULL)
			{
				TRN_ERR_RETURN(RIS_E_CANT_BE_NULL,tp->pos);
			}
			if (type2 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(targ_type,targ_size,tp->rhs);
			}

/*
** remove trailing blanks from character string literals.
*/
			if (tp->rhs->tok == RIS_TOK_CHAR_STR_LIT)
			{
				RIStrn_remove_trail_blanks(tp->rhs, RIS_blankstrip_mode);
			}

/*
** truncate character string literals if they are too long.
*/

			if (tp->rhs->tok == RIS_TOK_CHAR_STR_LIT &&
			 RIStrn_get_size(tp->rhs) > targ_size)
			{
#if defined(WIN32)
				RIScom_truncate(tp->rhs->info.val,targ_size);
				TRN_DBG(("RIStrn_typecheck:Truncated <%s> size <%d>\n",tp->rhs->info.val,targ_size));
#else
				for (i=1,j=strlen(tp->rhs->info.val),size=1;i < j;i++,size++)
				{
					/* '' must be treated as a single ' */
					if (tp->rhs->info.val[i] == '\'')
					{
						i++;
					}
					if (size == targ_size)
					{
						tp->rhs->info.val[i+1] = '\'';
						tp->rhs->info.val[i+2] = '\0';
						break;
					}
				}
				TRN_DBG(("RIStrn_typecheck:did FOR (%s),(%d %d),\n",tp->rhs->info.val,i,size));
#endif
			}

/*
**	Check if exact number literals are valid values
*/
			else if (tp->rhs->tok == RIS_TOK_EXACT_NUM_LIT)
			{
				int len, prec, scale;

				TRN_DBG(("RIStrn_typecheck:exact number literal val:<%s>\n",
					tp->rhs->info.val));

				len = strlen(tp->rhs->info.val) + 1;
				RIScom_get_prec_scale(tp->rhs->info.val, len, &prec, &scale);
				if (scale == -1)
				{
					TRN_DBG(("RIStrn_typecheck:number is an integer\n"));
				}
				else
				{
					TRN_DBG(("RIStrn_typecheck:number is a decimal\n"));
					if (ATTR_TYPE(targ_type) == RIS_DECIMAL)
					{
						asize.len = (unsigned int)targ_size;
						TRN_DBG(("RIStrn_typecheck:set prec:%d scale:%d\n",
							asize.dec.prec, asize.dec.scale));
						/*
						** Modified 2/9/94 by Sunil.
						** We were passing tp->rhs->info.val as the dest.
						** str. into RIScom_set_prec_scale. If the size
						** of the dest. string was less than the pecision,
						** it writes the rest of the bytes into bad memory
						** location (TR# 249400228). We now allocate a size
						** of the precision + 1(for - or +) + 1 (for .)
						*/
						set_val = ALLOCB(asize.dec.prec + 2);
						if (RIScom_set_prec_scale(tp->rhs->info.val, len,
							set_val, RIS_MAX_ID_SIZE, asize.dec.prec,
							asize.dec.scale))
						{
							TRN_ERR_RETURN(RIS_E_DECIMAL_EXCEEDS_PREC,tp->pos);
						}
						tp->rhs->info.val = set_val;
					}
				}
			}
		break;
		case RIS_TOK_IN:

TRN_DBG(("RIStrn_typecheck:found an IN operator\n"));

			type1 = RIStrn_get_type(tp->lhs);
			if (tp->rhs->tok == RIS_TOK_SELECT)
			{
				type2 = RIStrn_get_type(tp->rhs);
				type3 = RIStrn_compare_types(type1,type2,targ_type,tp->pos);
				if (type1 == RIS_UNKNOWN_TYPE)
				{
					if (targ_type == RIS_UNKNOWN_TYPE &&
						(ATTR_TYPE(type3) == RIS_CHARACTER ||
						 ATTR_TYPE(type3) == RIS_DECIMAL))
					{
						targ_size = RIStrn_get_size(tp->rhs);
					}
					RIStrn_put_type_size(type3,targ_size,tp->lhs);
					RIStrn_append_type_list(type3,tp->lhs);
				}

/* note: parameters are not allowed in a select list at this time */

			}
			else
			{
				type2 = RIStrn_get_list_type(tp->rhs->rhs);
				type3 = RIStrn_compare_types(type1,type2,targ_type,tp->pos);
				if (type1 == RIS_UNKNOWN_TYPE)
				{
					if (targ_type == RIS_UNKNOWN_TYPE &&
						(ATTR_TYPE(type3) == RIS_CHARACTER ||
						 ATTR_TYPE(type3) == RIS_DECIMAL))
					{
						targ_size = RIStrn_get_list_size(tp->rhs->rhs);
					}
					RIStrn_put_type_size(type3,targ_size,tp->lhs);
					RIStrn_append_type_list(type3,tp->lhs);
				}
				else if (type2 == RIS_UNKNOWN_TYPE)
				{
					if (targ_type == RIS_UNKNOWN_TYPE &&
						(ATTR_TYPE(type3) == RIS_CHARACTER ||
						 ATTR_TYPE(type3) == RIS_DECIMAL))
					{
						targ_size = RIStrn_get_size(tp->lhs);
					}
					RIStrn_put_list_type_size(type3,targ_size,tp->rhs->rhs);
				}
			}
			RIStrn_fix_types(type3);
		break;
		case RIS_TOK_LT:
		case RIS_TOK_LE:
		case RIS_TOK_GT:
		case RIS_TOK_GE:
		case RIS_TOK_EQ:
		case RIS_TOK_NE:
		case RIS_TOK_BETWEEN:

TRN_DBG(("RIStrn_typecheck:found a comparison operator\n"));

			type1 = RIStrn_get_type(tp->lhs);
			type2 = RIStrn_get_type(tp->rhs);
			type3 = RIStrn_compare_types(type1,type2,targ_type,tp->pos);
			if (type1 == RIS_UNKNOWN_TYPE)
			{
				if (targ_type == RIS_UNKNOWN_TYPE)
				{
					if (ATTR_TYPE(type3) == RIS_CHARACTER)
					{
						targ_size = RIStrn_get_size(tp->rhs);
					}
					else if (ATTR_TYPE(type3) == RIS_DECIMAL)
					{
						asize.dec.prec = RIS_MAX_PRECISION;
						asize.dec.scale = RIS_ANY_SCALE;
						targ_size = asize.len;
					}
				}
				RIStrn_put_type_size(type3,targ_size,tp->lhs);
				RIStrn_append_type_list(type3,tp->lhs);
			}
			else if (type2 == RIS_UNKNOWN_TYPE)
			{
				if (targ_type == RIS_UNKNOWN_TYPE)
				{
					if (ATTR_TYPE(type3) == RIS_CHARACTER)
					{
						targ_size = RIStrn_get_size(tp->lhs);
					}
					else if (ATTR_TYPE(type3) == RIS_DECIMAL)
					{
						asize.dec.prec = RIS_MAX_PRECISION;
						asize.dec.scale = RIS_ANY_SCALE;
						targ_size = asize.len;
					}
				}
				RIStrn_put_type_size(type3,targ_size,tp->rhs);
				RIStrn_append_type_list(type3,tp->rhs);
			}
			RIStrn_fix_types(type3);
		break;
		case RIS_TOK_LIKE:

TRN_DBG(("RIStrn_typecheck:found a LIKE operator\n"));

			type1 = RIStrn_get_type(tp->lhs);
			if (ATTR_TYPE(type1) != RIS_CHARACTER)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->lhs->pos);
			}
			type2 = RIStrn_get_type(tp->rhs);
			RIStrn_compare_types(type1,type2,targ_type, tp->pos);
			if (type2 == RIS_UNKNOWN_TYPE)
			{
				if (targ_type == RIS_UNKNOWN_TYPE)
				{
					targ_size = RIStrn_get_size(tp->lhs);
				}
				RIStrn_put_type_size(type1,targ_size,tp->rhs);
			}
		break;
		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_SUB:
		case RIS_TOK_PLUS:

TRN_DBG(("RIStrn_typecheck:found a binary arithmetic operator\n"));

			type1 = RIStrn_get_type(tp->lhs);
			if (ATTR_TYPE(type1) == RIS_CHARACTER ||
				ATTR_TYPE(type1) == RIS_DATETIME)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->lhs->pos);
			}
			size1 = RIStrn_get_size(tp->lhs);

			type2 = RIStrn_get_type(tp->rhs);
			if (ATTR_TYPE(type2) == RIS_CHARACTER ||
				ATTR_TYPE(type2) == RIS_DATETIME)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->rhs->pos);
			}
			size2 = RIStrn_get_size(tp->rhs);

			type3 = RIStrn_compare_types(type1,type2,targ_type,tp->pos);
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}

			if (ATTR_TYPE(type3) == RIS_DECIMAL)
			{
				if (type1 == RIS_UNKNOWN_TYPE || type2 == RIS_UNKNOWN_TYPE)
				{
					asize.dec.prec = RIS_MAX_PRECISION;
					asize.dec.scale = RIS_ANY_SCALE;
					targ_size = asize.len;
				}
				else
				{
					if (ATTR_TYPE(type1) == RIS_SMALLINT)
					{
						asize.dec.prec = 5;
						asize.dec.scale = 0;
						size1 = asize.len;
					}
					else if (ATTR_TYPE(type1) == RIS_INTEGER)
					{
						asize.dec.prec = 10;
						asize.dec.scale = 0;
						size1 = asize.len;
					}
					if (ATTR_TYPE(type2) == RIS_SMALLINT)
					{
						asize.dec.prec = 5;
						asize.dec.scale = 0;
						size2 = asize.len;
					}
					else if (ATTR_TYPE(type2) == RIS_INTEGER)
					{
						asize.dec.prec = 10;
						asize.dec.scale = 0;
						size2 = asize.len;
					}
					targ_size =
						RIStrn_compare_decimal_sizes(size1,size2,tp->tok);
				}
			}

			RIStrn_put_type_size(type3,targ_size,tp);

			type1 = RIStrn_get_type(tp->lhs);
			type2 = RIStrn_get_type(tp->rhs);

			if (type1 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(type3,targ_size,tp->lhs);
				RIStrn_append_type_list(type3,tp->lhs);
				RIStrn_append_type_list(type3,tp);
			}
			if (type2 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(type3,targ_size,tp->rhs);
				RIStrn_append_type_list(type3,tp->rhs);
				RIStrn_append_type_list(type3,tp);
			}
		break;

		case RIS_TOK_BETWEEN_AND:

TRN_DBG(("RIStrn_typecheck:found a between and\n"));

			type1 = RIStrn_get_type(tp->lhs);
			size1 = RIStrn_get_size(tp->lhs);

			type2 = RIStrn_get_type(tp->rhs);
			size2 = RIStrn_get_size(tp->rhs);

			type3 = RIStrn_compare_types(type1,type2,targ_type,tp->pos);
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}

			if (ATTR_TYPE(type3) == RIS_DECIMAL)
			{
				if (type1 == RIS_UNKNOWN_TYPE || type2 == RIS_UNKNOWN_TYPE)
				{
					asize.dec.prec = RIS_MAX_PRECISION;
					asize.dec.scale = RIS_ANY_SCALE;
					targ_size = asize.len;
				}
				else
				{
					if (ATTR_TYPE(type1) == RIS_SMALLINT)
					{
						asize.dec.prec = 5;
						asize.dec.scale = 0;
						size1 = asize.len;
					}
					else if (ATTR_TYPE(type1) == RIS_INTEGER)
					{
						asize.dec.prec = 10;
						asize.dec.scale = 0;
						size1 = asize.len;
					}
					if (ATTR_TYPE(type2) == RIS_SMALLINT)
					{
						asize.dec.prec = 5;
						asize.dec.scale = 0;
						size2 = asize.len;
					}
					else if (ATTR_TYPE(type2) == RIS_INTEGER)
					{
						asize.dec.prec = 10;
						asize.dec.scale = 0;
						size2 = asize.len;
					}
					targ_size =
						RIStrn_compare_decimal_sizes(size1,size2,tp->tok);
				}
			}

			RIStrn_put_type_size(type3,targ_size,tp);

			type1 = RIStrn_get_type(tp->lhs);
			type2 = RIStrn_get_type(tp->rhs);

			if (type1 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(type3,targ_size,tp->lhs);
				RIStrn_append_type_list(type3,tp->lhs);
				RIStrn_append_type_list(type3,tp);
			}
			if (type2 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(type3,targ_size,tp->rhs);
				RIStrn_append_type_list(type3,tp->rhs);
				RIStrn_append_type_list(type3,tp);
			}
		break;

		case RIS_TOK_UNARYMINUS:

TRN_DBG(("RIStrn_typecheck:found a unary arithmetic operator\n"));

			type1 = RIStrn_get_type(tp->rhs);
			if (ATTR_TYPE(type1) == RIS_CHARACTER ||
				ATTR_TYPE(type1) == RIS_DATETIME ||
				type1 == RIS_UNKNOWN_TYPE)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->rhs->pos);
			}
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}
			tp->info.attr->atype = (unsigned char)type1;
			tp->info.attr->asize.len = (unsigned short)RIStrn_get_size(tp->rhs);
		break;
		case RIS_TOK_ANY:
		case RIS_TOK_ALL:
		case RIS_TOK_MAX:
		case RIS_TOK_MIN:

TRN_DBG(("RIStrn_typecheck:found a quantifier, max, or min\n"));

			type1 = RIStrn_get_type(tp->rhs);
			if (type1 == RIS_UNKNOWN_TYPE)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->rhs->pos);
			}
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}
			tp->info.attr->atype = (unsigned char)type1;
			ALLOW_NULLS(tp->info.attr->atype);
			tp->info.attr->asize.len = (unsigned short)RIStrn_get_size(tp->rhs);
		break;
		case RIS_TOK_SUM:

TRN_DBG(("RIStrn_typecheck:found sum function\n"));

			type1 = RIStrn_get_type(tp->rhs);
			if (ATTR_TYPE(type1) == RIS_CHARACTER || type1 == RIS_UNKNOWN_TYPE)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->rhs->pos);
			}
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}
			tp->info.attr->atype = (unsigned char)type1;
			ALLOW_NULLS(tp->info.attr->atype);
			tp->info.attr->asize.len = (unsigned short)RIStrn_get_size(tp->rhs);
		break;

		case RIS_TOK_AVG:

TRN_DBG(("RIStrn_typecheck:found avg function\n"));

			type1 = RIStrn_get_type(tp->rhs);
			if (ATTR_TYPE(type1) == RIS_CHARACTER || type1 == RIS_UNKNOWN_TYPE)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_TYPE,tp->rhs->pos);
			}
			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}
			tp->info.attr->atype = RIS_DOUBLE;
			ALLOW_NULLS(tp->info.attr->atype);
			tp->info.attr->asize.len = RIS_types[RIS_DOUBLE].sqllen;
		break;

		case RIS_TOK_COUNT:

TRN_DBG(("RIStrn_typecheck:found count function\n"));

			if (!tp->info.attr)
			{
				tp->info.attr = ALLOCT(risattr);
			}
			tp->info.attr->atype = RIS_INTEGER;
			tp->info.attr->asize.len = RIS_types[RIS_INTEGER].sqllen;
		break;
		case RIS_TOK_IS:

TRN_DBG(("RIStrn_typecheck:found an IS predicate\n"));

		break;
		case RIS_TOK_EXISTS:

TRN_DBG(("RIStrn_typecheck:found an EXISTS predicate\n"));

		break;
		case RIS_TOK_ATTR:
		case RIS_TOK_PARAMETER:
		case RIS_TOK_EXACT_NUM_LIT:
		case RIS_TOK_APPROX_NUM_LIT:
		case RIS_TOK_CHAR_STR_LIT:
		case RIS_TOK_TIMESTAMP_LIT:
		case RIS_TOK_CURRENT_TIMESTAMP:

TRN_DBG(("RIStrn_typecheck:found an attr, lit, or a parameter\n"));

/*
** remove trailing blanks from character string literals.
*/
		if (tp->rhs->tok == RIS_TOK_CHAR_STR_LIT)
		{
			RIStrn_remove_trail_blanks(tp->rhs, RIS_blankstrip_mode);
		}

		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
		break;
	}

	TRN_DBG(("RIStrn_typecheck:complete\n"));
}

/******************************************************************************/


extern int RIStrn_compare_decimal_sizes(
	int				size1,
	int				size2,
	unsigned short	op)
{
	int			lead1,lead2;
	union asize	asize1,asize2,asize3;

	TRN_DBG(("RIStrn_compare_decimal_sizes(size1:%d size2:%d op:%d)\n",
		size1, size2, op));

	lead1 = asize1.dec.prec - asize1.dec.scale;
/*
**	Following ifdef is added to fix TR# 249406338. Because of the byte
**	ordering on SUN, needed change the casto int instead of short.
**	RAJU. 	09/12/94
*/
	asize1.len = (unsigned int)size1;
	asize2.len = (unsigned int)size2;
	lead1 = asize1.dec.prec - asize1.dec.scale;
	lead2 = asize2.dec.prec - asize2.dec.scale;

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_compare_decimal_sizes: size1.prec:%d size1.scale:%d\n",
			asize1.dec.prec, asize1.dec.scale);
		RIScom_output_debug("RIStrn_compare_decimal_sizes: size2.prec:%d size2.scale:%d\n",
			asize2.dec.prec, asize2.dec.scale);
		RIScom_output_debug("RIStrn_compare_decimal_sizes: op:%s\n",
			RIScom_get_token_name(op));
	}

	switch(op)
	{
		case RIS_TOK_MUL:
			asize3.dec.scale = asize1.dec.scale + asize2.dec.scale;
			asize3.dec.prec = lead1 + lead2 + asize3.dec.scale;
			break;
		case RIS_TOK_DIV:
			asize3.dec.scale = asize1.dec.scale + asize2.dec.scale;
			asize3.dec.prec = MAX(lead1,lead2) + asize3.dec.scale;
			break;
		case RIS_TOK_PLUS:
		case RIS_TOK_SUB:
			asize3.dec.scale = MAX(asize1.dec.scale,asize2.dec.scale);
			asize3.dec.prec = MAX(lead1,lead2) + 1 + asize3.dec.scale;
			break;
		default:
			break;
	}

	if (asize3.dec.prec > RIS_MAX_PRECISION)
		asize3.dec.prec = RIS_MAX_PRECISION;

	TRN_DBG(("RIStrn_compare_decimal_sizes: returning size3.prec:%d size3.scale:%d\n", asize3.dec.prec, asize3.dec.scale));

	return(asize3.len);
}

/******************************************************************************/
