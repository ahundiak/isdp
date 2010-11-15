/* Do not alter this SPC information: $Revision: 1.3.30.1 $ */
/*
**	NAME:							trntypsz.c
**	AUTHORS:						David Michal
**	CREATION DATE:					5/88
**	ABSTRACT:
**		This file contains the routines that handle types and sizes.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION. Dianne
*/
 
/*
**	INCLUDES
*/
#include "riscl_sr.h"
#include "riscom.h"
#include "rismem.h"
#include "ristypes.h"
#include "trans.h"
#include "commacro.h"
/*
**	FUNCTION PROTOTYPES
*/
#define trntypsz_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comdcml.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "trncptyp.prt"
#include "trntypsz.prt"
#include "sys.prt"
#include "comuni.prt"

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

extern int RIStrn_get_list_type(
	ristree * list)
{
	ristree * tp;
	ristree * found = 0;
	int type1;
	int type2;

TRN_DBG(("\nRIStrn_get_list_type list = 0x%x\n",list));

	type1 = RIS_UNKNOWN_TYPE;
	for(tp=list;tp;tp=tp->rhs)
	{
		if ((type1=RIStrn_get_type(tp->lhs)) != RIS_UNKNOWN_TYPE)
		{
			found = tp->lhs;
			break;
		}
	}
	if (type1 != RIS_UNKNOWN_TYPE)
	{
		for(tp=list;tp;tp=tp->rhs)
		{
			type2 = RIStrn_get_type(tp->lhs);
			type1 = RIStrn_compare_types(type1,type2,RIS_UNKNOWN_TYPE,tp->lhs->pos);
			if (type2 == RIS_UNKNOWN_TYPE)
			{
				RIStrn_put_type_size(type1,RIStrn_get_size(found),tp->lhs);
				RIStrn_append_type_list(type1,tp->lhs);
			}
		}
	}
	return(type1);
}

/******************************************************************************/

extern int RIStrn_get_list_size(
	ristree * list)
{
	ristree * tp;
	int size;
	int temp;

TRN_DBG(("\nRIStrn_get_list_size list = 0x%x\n",list));

	size = 0;
	for(tp=list;tp;tp=tp->rhs)
	{
		if ((temp=RIStrn_get_size(tp->lhs)) > size)
		{
			size = temp;
		}
	}
	return(size);
}

/******************************************************************************/

extern void RIStrn_put_list_type_size(
	int type,
	int size,
	ristree * list)
{
	ristree * tp;

TRN_DBG(("\nRIStrn_put_list_type_size type = %s size = %d list = 0x%x\n",
 RIS_types[ATTR_TYPE(type)].string,size,list));

	for(tp=list;tp;tp=tp->rhs)
	{
		if (tp->lhs->tok == RIS_TOK_PARAMETER)
		{
			RIStrn_put_type_size(type,size,tp->lhs);
			RIStrn_append_type_list(type,tp->lhs);
		}
	}
}

/******************************************************************************/

extern int RIStrn_get_size(
	ristree * tp)
{
#if !defined (WIN32)
	int i;
	int j;
#endif
	int size;

TRN_DBG(("\nRIStrn_get_size tp = 0x%x tp->tok = %s\n",tp,RIScom_get_token_name(tp->tok)));

	switch(tp->tok)
	{
		case RIS_TOK_EXACT_NUM_LIT:
		{
			int scale, prec;
			union asize asize;

			RIScom_get_prec_scale(tp->info.val, strlen(tp->info.val) + 1,
				&prec, &scale);

			if (scale == -1)
			{
TRN_DBG(("size = %d\n",RIS_types[RIS_INTEGER].sqllen));
				return(RIS_types[RIS_INTEGER].sqllen);
			}
			else
			{
				asize.dec.prec = (unsigned char)prec;
				asize.dec.scale = (unsigned char)scale;
TRN_DBG(("size = %d\n",asize.len));
				return(asize.len);
			}
		}

		case RIS_TOK_APPROX_NUM_LIT:

TRN_DBG(("size = %d\n",RIS_types[RIS_DOUBLE].sqllen));

			return(RIS_types[RIS_DOUBLE].sqllen);

		case RIS_TOK_CHAR_STR_LIT:

#if defined(WIN32)
			size = RIScom_getticsize(tp->info.val);
#else
			for (i=1,j=strlen(tp->info.val),size=0;i < j;i++,size++)
			{
				/* treat '' as one character representing ' */
				if (tp->info.val[i] == '\'')
					i++;
			}
#endif
TRN_DBG(("size = %d\n",size));

			return(size);

		case RIS_TOK_TIMESTAMP_LIT:
		case RIS_TOK_CURRENT_TIMESTAMP:

TRN_DBG(("size = %d\n",sizeof(dtime)));

			return(sizeof(dtime));

		case RIS_TOK_NULL:

TRN_DBG(("size = 0\n"));

			return(0);

		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_SUB:
		case RIS_TOK_PLUS:
		case RIS_TOK_UNARYMINUS:
		case RIS_TOK_ATTR:
		case RIS_TOK_ANY:
		case RIS_TOK_ALL:
		case RIS_TOK_COUNT:
		case RIS_TOK_MAX:
		case RIS_TOK_MIN:
		case RIS_TOK_SUM:
		case RIS_TOK_AVG:
		case RIS_TOK_BETWEEN_AND:

TRN_DBG(("size = %d\n",tp->info.attr->asize.len));

			return(tp->info.attr->asize.len);

		case RIS_TOK_PARAMETER:

TRN_DBG(("size = %d\n",tp->info.data->sqllen));

			return(tp->info.data->sqllen);

		case RIS_TOK_SELECT:

TRN_DBG(("size = %d\n",tp->rhs->rhs->lhs->info.attr->asize.len));

			return(tp->rhs->rhs->lhs->info.attr->asize.len);

		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);

	}
	return -1;
}

/******************************************************************************/

extern int RIStrn_get_type(
	ristree * tp)
{
	int temp;

TRN_DBG(("\nRIStrn_get_type tp = 0x%x tp->tok = %s\n",tp,RIScom_get_token_name(tp->tok)));

	switch(tp->tok)
	{
		case RIS_TOK_EXACT_NUM_LIT:

/*
** eventually this needs to be fixed so that non-integer exact values are of
** decimal or numeric types not the approximate type of double
*/

			if (strchr(tp->info.val,'.')) /*itbokic */
			{

TRN_DBG(("type = %s\n",RIS_types[RIS_DECIMAL].string));

				return(RIS_DECIMAL);
			}
			else
			{

TRN_DBG(("type = %s\n",RIS_types[RIS_INTEGER].string));


				return(RIS_INTEGER);
			}

		case RIS_TOK_APPROX_NUM_LIT:

TRN_DBG(("type = %s\n",RIS_types[RIS_DOUBLE].string));

			return(RIS_DOUBLE);

		case RIS_TOK_CHAR_STR_LIT:

TRN_DBG(("type = %s\n",RIS_types[RIS_CHARACTER].string));

			return(RIS_CHARACTER);

		case RIS_TOK_TIMESTAMP_LIT:
		case RIS_TOK_CURRENT_TIMESTAMP:

TRN_DBG(("type = %s\n",RIS_types[RIS_DATETIME].string));

			return(RIS_DATETIME);

		case RIS_TOK_UNSUPPORTED:

TRN_DBG(("type = %s\n",RIS_types[RIS_UNSUPPORTED_TYPE].string));

			return(RIS_UNSUPPORTED_TYPE);

		case RIS_TOK_NULL:

TRN_DBG(("type = %s\n",RIS_types[RIS_UNKNOWN_TYPE].string));

			return(RIS_UNKNOWN_TYPE);

		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_SUB:
		case RIS_TOK_PLUS:
		case RIS_TOK_UNARYMINUS:
		case RIS_TOK_ATTR:
		case RIS_TOK_ANY:
		case RIS_TOK_ALL:
		case RIS_TOK_COUNT:
		case RIS_TOK_MAX:
		case RIS_TOK_MIN:
		case RIS_TOK_SUM:
		case RIS_TOK_AVG:
		case RIS_TOK_BETWEEN_AND:

TRN_DBG(("type = %s\n",RIS_types[ATTR_TYPE(tp->info.attr->atype)].string));

			return(tp->info.attr->atype);

		case RIS_TOK_PARAMETER:

TRN_DBG(("type = %s\n",RIS_types[tp->info.data->sqltype].string));

			temp = tp->info.data->sqltype;
			if (tp->info.data->sqlnull)
			{
				ALLOW_NULLS(temp);
			}
			return(temp);

		case RIS_TOK_SELECT:

TRN_DBG(("type = %s\n",RIS_types[ATTR_TYPE(
 tp->rhs->rhs->lhs->info.attr->atype)].string));

			return(tp->rhs->rhs->lhs->info.attr->atype);

		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);

	}
	return -1;
}

/******************************************************************************/

extern void RIStrn_put_type_size(
	int type,
	int size,
	ristree * tp)
{
	union asize asize;

TRN_DBG(("\nRIStrn_put_type_size type = %s size = %d tp = 0x%x tok = %s\n",
 RIS_types[ATTR_TYPE(type)].string,size,tp,RIScom_get_token_name(tp->tok)));
	switch(tp->tok)
	{
		case RIS_TOK_PARAMETER:
			tp->info.data->sqltype = (short)ATTR_TYPE(type);
			tp->info.data->sqlnull = (short)ATTR_FLAG(type);

            /*******   BLOB (minor rewrite )   *********/
            switch (ATTR_TYPE(type))
            {
            case RIS_CHARACTER :
                tp->info.data->sqllen = (short)size;
            break;
            case RIS_TEXT:
            case RIS_BLOB:
                tp->info.data->max_blob_sqllen = (unsigned int)size;
            break;
            case RIS_DECIMAL:
                asize.len = size;
                tp->info.data->sqllen = asize.dec.prec + (short)3; 
									/* '-'+'0'+'.' */
                tp->info.data->sqlscale = asize.dec.scale;
            break;
            case RIS_DATETIME:
                tp->info.data->sqllen = sizeof(dtime);
            break;
            default:
                tp->info.data->sqllen = RIS_types[ATTR_TYPE(type)].sqllen;
            break;
            }

		break;
		case RIS_TOK_PLUS:
		case RIS_TOK_SUB:
		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_BETWEEN_AND:
			tp->info.attr->atype = (unsigned char)type;
			if (ATTR_TYPE(type) == RIS_DECIMAL)
			{
/*
**  Following ifdef is added to fix TR# 249406338. Because of the byte
**  ordering on SUN, needed change the cast to int instead of short.
**  RAJU.   09/12/94
*/
				tp->info.attr->asize.len = (unsigned int)size;
			}
			else
			{
				tp->info.attr->asize.len = RIS_types[ATTR_TYPE(type)].sqllen;
			}
		break;
		case RIS_TOK_NULL:
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
		break;
	}
}

/******************************************************************************/

extern void RIStrn_fix_types(
	int targ_type)
{
	ristree * tp;

TRN_DBG(("\nRIStrn_fix_types targ_type = %s\n",
 RIS_types[ATTR_TYPE(targ_type)].string));

	switch(ATTR_TYPE(targ_type))
	{
		case RIS_DOUBLE:
			for (tp=RIStrn_real_list;tp;tp=tp->rhs)
			{
				RIStrn_put_type_size(targ_type,0,tp->lhs);
			}
		case RIS_REAL:
			for (tp=RIStrn_int_list;tp;tp=tp->rhs)
			{
				RIStrn_put_type_size(targ_type,0,tp->lhs);
			}
		case RIS_INTEGER:
			for (tp=RIStrn_smallint_list;tp;tp=tp->rhs)
			{
				RIStrn_put_type_size(targ_type,0,tp->lhs);
			}
		case RIS_SMALLINT:
		case RIS_CHARACTER:
		case RIS_DECIMAL:
		case RIS_DATETIME:
		case RIS_BLOB:
		case RIS_TEXT:
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,0);
		break;
	}
}

/******************************************************************************/

extern int RIStrn_types_compatible(
	int type1,
	int type2)
{
	int	i,j;

TRN_DBG(("\nRIStrn_types_compatible type1(%d) = %s, type2(%d) = %s\n",
	ATTR_TYPE(type1), RIS_types[ATTR_TYPE(type1)].string, 
	ATTR_TYPE(type2), RIS_types[ATTR_TYPE(type2)].string));
	
	for (i=0; i<RIS_MAX_TYPES; i++)
	{
		for (j=0; j<RIS_MAX_TYPES; j++)
		{
			TRN_DBG(("%d, ", RIS_types_matrix[i][j]));
		}
		TRN_DBG(("\n"));
	}

TRN_DBG(("\nRIStrn_types_compatible: returning: %d\n", 
	(int)RIS_types_matrix[ATTR_TYPE(type1)][ATTR_TYPE(type2)]));
	return((int)RIS_types_matrix[ATTR_TYPE(type1)][ATTR_TYPE(type2)]);
}

/******************************************************************************/

extern void RIStrn_fix_decimal_size(
	int targ_size)
{
	ristree * tp;

TRN_DBG(("\nRIStrn_fix_decimal_size targ_size = %d\n", targ_size));

	for (tp=RIStrn_decimal_list;tp;tp=tp->rhs)
	{
		RIStrn_put_type_size(RIS_DECIMAL,targ_size,tp->lhs);
	}
}

/******************************************************************************/

extern void RIStrn_append_type_list(
	int targ_type,
	ristree * tp)
{
	ristree * temp;

TRN_DBG(("\nRIStrn_append_type_list targ_type = %s tp = 0x%x\n",
 RIS_types[ATTR_TYPE(targ_type)].string,tp));

	switch(ATTR_TYPE(targ_type))
	{
		case RIS_REAL:
			temp = ALLOCT(ristree);
			temp->lhs = tp;
			temp->rhs = RIStrn_real_list;
			RIStrn_real_list = temp;
		break;
		case RIS_INTEGER:
			temp = ALLOCT(ristree);
			temp->lhs = tp;
			temp->rhs = RIStrn_int_list;
			RIStrn_int_list = temp;
		break;
		case RIS_SMALLINT:
			temp = ALLOCT(ristree);
			temp->lhs = tp;
			temp->rhs = RIStrn_smallint_list;
			RIStrn_smallint_list = temp;
		break;
		case RIS_DECIMAL:
			temp = ALLOCT(ristree);
			temp->lhs = tp;
			temp->rhs = RIStrn_decimal_list;
			RIStrn_decimal_list = temp;
		break;
		case RIS_DOUBLE:
		case RIS_CHARACTER:
		case RIS_DATETIME:
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,0);
		break;
	}
}

/******************************************************************************/

extern void RIStrn_remove_trail_blanks(
	ristree *tp,
	int		blankstrip_mode)
{
#if defined (WIN32)
	wchar_t *p;
	int		i = 0;
#else
	char *p;
#endif
	int c=0;

	TRN_DBG(("RIStrn_remove_trail_blanks(tp:0x%x blankstrip_mode:%d)\ntp->info.val:<%s>\n",
		tp, blankstrip_mode, tp->info.val));

	if (blankstrip_mode && tp->tok == RIS_TOK_CHAR_STR_LIT)
	{
#if defined(WIN32)
		RIScom_multiwide(&RISwide_ptr,&tp->info.val,
				&RISwide_size,MULTITOWIDE,0);
		p = RIScom_wcsrchr(RISwide_ptr,WIDECHAR('\''));

		TRN_DBG(("RIStrn_remove_trail_blanks <%s>,<%S>.<%S>\n",
			tp->info.val,p,RISwide_ptr));

		if (p && (p > RISwide_ptr))
			p--; /* assuming that buffer has closing tick(') */

		TRN_DBG(("2RIStrn_remove_trail_blanks <%s>,<%S>.<%S>\n",
			tp->info.val,p,RISwide_ptr));
		while ((p > RISwide_ptr) && (ISSPACE(*p)))
#else
		p = tp->info.val;
		p += (strlen(tp->info.val) - 1);

		/** Assuming that the buffer has a closing tick (') backup 1 character. */
		p = p - 1;		
		while ((p > tp->info.val) && (*p == ' '))
#endif
		{
			c++;
			*p = WIDECHAR('\0');
			--p;
		}
		TRN_DBG(("ate %d spaces\n",c));
		/*
		** If we ate spaces, put the closing tick (') back.
		*/
		if (c)
		{
			p++;
			*p = WIDECHAR('\'');
			p++;
			*p = WIDECHAR('\0');
		}
		TRN_DBG(("tp->info.val <%s>\n",tp->info.val));
#if defined(WIN32)
		i = strlen(tp->info.val);
		RIScom_wcstombs(tp->info.val,RISwide_ptr,i);
		TRN_DBG(("4RIStrn_remove_trail_blanks <%s>,<%S>.<%S>\n",
							tp->info.val,p,RISwide_ptr));
#endif
	}
	TRN_DBG(("RIStrn_remove_trail_blanks: Done..\n"));
}

/******************************************************************************/
