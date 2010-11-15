/* Do not alter this SPC information: $Revision: 1.3.51.1 $ */
/*
**      NAME:                                                   parexpr.c
**      AUTHORS:                                                
**      CREATION DATE:                                  
**      ABSTRACT:
**              
**      
**      REVISION HISTORY:
**
**		12/94:	Added INTERNATIONALIZATION support.  The generate_expr_error() assumes
**				multibyte = 2 bytes.  Paula
*/
 
/*
**      INCLUDES
*/
#include <limits.h>
#include <ctype.h>
#include "parser.h"
#if defined(WIN32)
#include "commacro.h"
#endif

/*
**      FUNCTION PROTOTYPES
*/
#define parexpr_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "parexpr.prt"
#include "sys.prt"
#if defined(WIN32)
#include "comuni.prt"
#include "comalloc.prt"
#endif



/*
**      DEFINES
*/
#if defined (DOS)
#define BITSPERBYTE 8
#define BITS(type) (BITSPERBYTE * (int)sizeof(type))
#define MAXINT  (1 << BITS(int) - 1)
#endif

#define VALUE_SPEC_OPERANDS \
	     RIS_TOK_QUESTION: \
	case RIS_TOK_VAR_NAME: \
	case RIS_TOK_C_CHAR_STR_LIT: \
	case RIS_TOK_CHAR_STR_LIT: \
	case RIS_TOK_EXACT_NUM_LIT: \
	case RIS_TOK_APPROX_NUM_LIT: \
	case RIS_TOK_TIMESTAMP_LIT: \
	case RIS_TOK_USER

#define COLUMN_SPEC_OPERANDS \
	     RIS_TOK_COL_NAME: \
	case RIS_TOK_TABLE_NAME: \
	case RIS_TOK_USR_NAME: \
	case RIS_TOK_AUTH_ID

#define SET_FUNC_OPERANDS \
	     RIS_TOK_SUM: \
	case RIS_TOK_AVG: \
	case RIS_TOK_MAX: \
	case RIS_TOK_MIN: \
	case RIS_TOK_COUNT: \
	case RIS_TOK_CURRENT_TIMESTAMP

#define VALUE_EXPR_OPERANDS \
	     RIS_TOK_PLUS: \
	case RIS_TOK_SUB: \
	case RIS_TOK_MUL: \
	case RIS_TOK_DIV: \
	case RIS_TOK_UNARYMINUS: \
	case VALUE_SPEC_OPERANDS: \
	case COLUMN_SPEC_OPERANDS: \
	case SET_FUNC_OPERANDS



/*
**  VARIABLES
*/

/*
**  FUNCTIONS
*/

/******************************************************************************/

static void generate_operand_error(
	ristree *operator,
	ristree *operand)
{
	char    *operator_ptr;
	char    *operand_ptr;

	operator_ptr = RIScom_get_token_name(operator->tok);
	if (operand->info.val)
		operand_ptr = operand->info.val;
	else
		operand_ptr = RIScom_get_token_name(operand->tok);

	sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_IS_NOT_VALID_OPERAND_FOR) ,
		operand_ptr, operator_ptr);
}

/******************************************************************************/
#if defined(WIN32) 
static void generate_expr_error(
	int     min_pos,
	char *expr_type)
{
	char *msg_ptr;
	wchar_t *beg_ptr;
	wchar_t *end_ptr;

	beg_ptr = RISpar_head_bufp + (min_pos - 1);
	end_ptr = RISpar_head_bufp + (RISpar_lex.pos - 1) - 1;

	while(RIScom_iswspace(*end_ptr))
		end_ptr--;

	msg_ptr = RIS_ERRMSGC;

	msg_ptr += sprintf(msg_ptr, RIScom_umsg(RIS_E_EXPECTED_EXPRESSION_GOT) , expr_type);

	RIScom_multiwide(&beg_ptr, &RISmulti_ptr, &RISmulti_size, WIDETOMULTI, 0 );

	while(beg_ptr <= end_ptr)
	{
		if (RIScom_isleadbyte(*RISmulti_ptr))
			*msg_ptr++ = *RISmulti_ptr++; 
		*msg_ptr++ = *RISmulti_ptr++;
		*beg_ptr++;
	}

	strcpy(msg_ptr, "'.");
}

#else 
/*note there are two versions of this function...one above! */
static void generate_expr_error(
	int     min_pos,
	char *expr_type)
{
	char *msg_ptr;
	char *beg_ptr;
	char *end_ptr;

	beg_ptr = RISpar_head_bufp + (min_pos - 1);
	end_ptr = RISpar_head_bufp + (RISpar_lex.pos - 1) - 1;
		while(RIScom_isspace(*end_ptr))
		end_ptr--;

	msg_ptr = RIS_ERRMSGC;

	msg_ptr += sprintf(msg_ptr, RIScom_umsg(RIS_E_EXPECTED_EXPRESSION_GOT) , expr_type);

	while(beg_ptr <= end_ptr)
		*msg_ptr++ = *beg_ptr++;

	strcpy(msg_ptr, "'.");
}
#endif

/******************************************************************************/

static int invalid_operand(
	int operator,
	int operand)
{
	PAR_DBG(("invalid_operand(operator:%s operand:%s)\n",
		RIScom_get_token_name(operator), RIScom_get_token_name(operand)));

	switch(operator)
	{
		case RIS_TOK_AND:
		case RIS_TOK_OR:
		case RIS_TOK_NOT:
			switch(operand)
			{
				case RIS_TOK_AND:
				case RIS_TOK_OR:
				case RIS_TOK_NOT:

				case RIS_TOK_EQ:
				case RIS_TOK_NE:
				case RIS_TOK_LT:
				case RIS_TOK_GT:
				case RIS_TOK_LE:
				case RIS_TOK_GE:

				case RIS_TOK_IN:
				case RIS_TOK_LIKE:
				case RIS_TOK_IS:
				case RIS_TOK_EXISTS:
				case RIS_TOK_BETWEEN:
					return 0;
			}
			return 1;

		case RIS_TOK_EQ:
		case RIS_TOK_NE:
		case RIS_TOK_LT:
		case RIS_TOK_GT:
		case RIS_TOK_LE:
		case RIS_TOK_GE:
			switch(operand)
			{
				case VALUE_EXPR_OPERANDS:
				case RIS_TOK_ALL:
				case RIS_TOK_ANY:
				case RIS_TOK_SELECT:
					return 0;
			}
			return 1;

		case RIS_TOK_IN:
			switch(operand)
			{
				case VALUE_EXPR_OPERANDS:
				case RIS_TOK_SELECT:
				case RIS_TOK_VALUES:
					return 0;
			}
			return 1;

		case RIS_TOK_LIKE:
			switch(operand)
			{
				case VALUE_SPEC_OPERANDS:
				case COLUMN_SPEC_OPERANDS:
					return 0;
			}
			return 1;

		case RIS_TOK_IS:
			switch(operand)
			{
				case COLUMN_SPEC_OPERANDS:
				case RIS_TOK_NULL:
					return 0;
			}
			return 1;

		case RIS_TOK_EXISTS:
			switch(operand)
			{
				case RIS_TOK_SELECT:
					return 0;
			}
			return 1;

		case RIS_TOK_PLUS:
		case RIS_TOK_SUB:
		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_UNARYMINUS:
		case RIS_TOK_BETWEEN_AND:
			switch(operand)
			{
				case VALUE_EXPR_OPERANDS:
					return 0;
			}
			return 1;

		case RIS_TOK_BETWEEN:
			switch(operand)
			{
				case VALUE_EXPR_OPERANDS:
				case RIS_TOK_BETWEEN_AND:
					return 0;
			}
			return 1;

		default:
			RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR, RISpar_lex.pos);
	}
	return 0;
}

/******************************************************************************/

static void verify_tp(
	ristree *tp,
	unsigned short *min_posp)
{
	PAR_DBG(("verify_tp(tp:0x%x) tp->tok:%s\n",
		tp, RIScom_get_token_name(tp->tok)));

	if (tp->pos < *min_posp)
		*min_posp = tp->pos;

	switch(tp->tok)
	{
		case VALUE_SPEC_OPERANDS:
		case COLUMN_SPEC_OPERANDS:
		case SET_FUNC_OPERANDS:
		case RIS_TOK_ALL:
		case RIS_TOK_ANY:
		case RIS_TOK_SELECT:
		case RIS_TOK_VALUES:
		case RIS_TOK_NULL:
			return;
	}

	if (!tp->lhs && !tp->rhs)
	{
		PAR_DBG(("verify_tp(): %s has no children\n",
			RIScom_get_token_name(tp->tok)));
		RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR, tp->pos);
	}

	if (tp->lhs)
	{
		verify_tp(tp->lhs, min_posp);

		if (invalid_operand(tp->tok, tp->lhs->tok))
		{
			PAR_DBG(("verify_tp(): operator %s has invalid left operand %s\n",
				RIScom_get_token_name(tp->tok),
				RIScom_get_token_name(tp->lhs->tok)));
			sprintf(RIS_ERRMSGC,RIScom_umsg(RIS_E_IS_NOT_VALID_OPERAND_FOR) ,
				RIScom_get_token_name(tp->lhs->tok),
				RIScom_get_token_name(tp->tok));
				
			generate_operand_error(tp, tp->lhs);
			RISpar_ERR_RETURN(RIS_E_INV_OPERAND, tp->pos);
		}
	}

	if (tp->rhs)
	{
		verify_tp(tp->rhs, min_posp);

		if (invalid_operand(tp->tok, tp->rhs->tok))
		{
			PAR_DBG(("verify_tp(): operator %s has invalid right operand %s\n",
				RIScom_get_token_name(tp->tok),
				RIScom_get_token_name(tp->rhs->tok)));

			generate_operand_error(tp, tp->rhs);
			RISpar_ERR_RETURN(RIS_E_INV_OPERAND, tp->pos);
		}
	}
}

/******************************************************************************/

extern void RISpar_valid_value_expr(
	ristree *tp)
{
	unsigned short min_pos = USHRT_MAX;
	
	PAR_DBG(("valid_value_expr(tp:0x%x) tp->tok:%s\n",
		tp, RIScom_get_token_name(tp->tok)));

	verify_tp(tp, &min_pos);

	switch(tp->tok)
	{
		case VALUE_EXPR_OPERANDS:
			return;
	}

	generate_expr_error(min_pos, "value");
	RISpar_ERR_RETURN(RIS_E_NOT_VALUE_EXPR, min_pos);
}

/******************************************************************************/

extern void RISpar_valid_bool_expr(
	ristree *tp)
{
	unsigned short min_pos = USHRT_MAX;

	PAR_DBG(("valid_bool_expr(tp:0x%x) tp->tok:%s\n",
		tp, RIScom_get_token_name(tp->tok)));

	verify_tp(tp, &min_pos);
	
	switch(tp->tok)
	{
		case RIS_TOK_AND:
		case RIS_TOK_OR:
		case RIS_TOK_NOT:

		case RIS_TOK_EQ:
		case RIS_TOK_NE:
		case RIS_TOK_LT:
		case RIS_TOK_GT:
		case RIS_TOK_LE:
		case RIS_TOK_GE:

		case RIS_TOK_IN:
		case RIS_TOK_LIKE:
		case RIS_TOK_IS:
		case RIS_TOK_EXISTS:
		case RIS_TOK_BETWEEN:
			return;
	}

	generate_expr_error(min_pos, "boolean");
	RISpar_ERR_RETURN(RIS_E_NOT_BOOL_EXPR, min_pos);
}
