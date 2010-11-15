/* Do not alter this SPC information: $Revision: 1.9.9.1 $ */
/*
**      NAME:                                                   parlex.c
**      AUTHORS:                                                David Michal
**      CREATION DATE:                                  5/88
**      ABSTRACT:
**              The lexical analyzer for the RIS parser.
**      
**      REVISION HISTORY:
*/
 
/*
**      INCLUDES
*/
#if defined(WIN32) || defined(DOS)
#include "RIShsrch.h"
#endif
#include <ctype.h>
#include "parser.h"
#include "commacro.h"

/*
**      TYPES
*/
typedef struct keywords
{
	char    *keyword;
	int     tok;
} keywords;

/*
**      FUNCTION PROTOTYPES
*/
#define parlex_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "comumsg.prt"
#if defined(WIN32) || defined(DOS)
#include "comhsrch.prt"
#endif
#include "parlex.prt"
#include "parutil.prt"
#include "sys.prt"
#include "comuni.prt"

/*
**      DEFINES
*/
#define RISpar_ALPHA 71
#define RISpar_INITIAL 1
#define RISpar_DOT 2
#define RISpar_INTEGER 3
#define RISpar_FRACTION 4
#define RISpar_EXPONENT 5
#define RISpar_EXP_SIGN 6
#define RISpar_APPROX 7

#if defined(WIN32)
#define STRCMP_IC(a,b) RIScom_strcmp_ic2(a,b)
#else
#define STRCMP_IC(a,b)	RIScom_strcmp_ic(a,b) 
#endif

#define RETURN(return_token, return_value) \
{ \
	RISpar_token = return_token; \
	RISpar_lex.val = return_value; \
	if (RISpar_debug) \
	{ \
		RIScom_output_debug("\tRISpar_token:<%s>\n", \
			RIScom_get_token_name(RISpar_token)); \
		RIScom_output_debug("\tRISpar_token:%d\n",RISpar_token); \
		RIScom_output_debug("\tRISpar_lex.pos:%d\n",RISpar_lex.pos); \
		if (RISpar_lex.val) \
			RIScom_output_debug("\tRISpar_lex.val:<%s>\n",RISpar_lex.val); \
		else RIScom_output_debug("\tRISpar_lex.val:\n"); \
		RIScom_output_debug("RISpar_get_next_token:complete\n"); \
	} \
	return; \
}


/*
**      VARIABLES
*/
static keywords reserved[][2] =
{
#include "hashtab.h"
}
;

static int table_size = (sizeof(reserved) / sizeof(reserved[0]));


/*
**      FUNCTIONS
*/

/******************************************************************************/

static int stop_char(
	int     c,
	int     mask)
{
	if ((mask & DOT_FLAG) && c == WIDECHAR('.')) 
	{
		PAR_DBG(("stop_char return DOT\n"));
		return RIS_TOK_DOT;
	}
	if ((mask & SEMICOLON_FLAG) && c == WIDECHAR(';')) 
	{
		PAR_DBG(("stop_char return SEMICOLON\n"));
		return RIS_TOK_SEMICOLON;
	}
	if ((mask & COMMA_FLAG) && c == WIDECHAR(',')) 
	{
		PAR_DBG(("stop_char return COMMA\n"));
		return RIS_TOK_COMMA;
	}
	if ((mask & RPAREN_FLAG) && c == WIDECHAR(')')) 
	{
		PAR_DBG(("stop_char return RPAREN\n"));
		return RIS_TOK_RPAREN;
	}

	PAR_DBG(("stop_char return ZERO\n"));
	return 0;
}

/******************************************************************************/
#if defined(WIN32)
static int RIScom_strcmp_ic2(
	wchar_t *begin,
	char	*string)
{
char multibyte[RIS_MAX_ID_SIZE]; /* this function only used local.  Longest
                                    word compared is VOLITILE below.
                                    RIS_MAX_ID_SIZE = 32. */

	RIScom_wcstombs(multibyte,begin,RIS_MAX_ID_SIZE);
	return(RIScom_strcmp_ic(multibyte,string));
}
#endif
/******************************************************************************/
extern void RISpar_get_next_token()
{
#if defined(WIN32)
	wchar_t     c;
#else
	char     c;
#endif
	int     sts=-1;
	int     tok;
	int     state;

	PAR_DBG(("RISpar_get_next_token()\n"));

	/*
	** skip over white space
	*/
	while (ISSPACE((c = RISpar_input())));

	/*
	** set position to beginning of token
	** clear value pointer;
	*/
	RISpar_lex.pos = RISpar_cur_bufp - RISpar_head_bufp;
	RISpar_lex.val = 0;

	PAR_DBG(("RISpar_get_next_token char = <%C>()\n",c));
	PAR_DBG(("RISpar_get_next_token converted string %S\n",RISpar_head_bufp));

	if  (RISpar_exclude_flag == 2) /*alter schema include statement */
	{
		if (!STRSTR(RISpar_cur_bufp,WIDECHAR(" as "))  &&
			(!STRSTR(RISpar_cur_bufp,WIDECHAR(" AS "))))
		{
			RISpar_exclude_flag = 0; /* ansi std applies to names*/
		}
		PAR_DBG(("RISpar_get_next_token INCLUDE STATEMENT %d\n",RISpar_exclude_flag));
	}
	/*
	** if we have reached end of file, return 0
	*/
	if (!c)
	{
		RETURN(0,NULL);
	}
	else if (RISpar_lex_flag)
	{
		PAR_DBG(("RISpar_get_next_token RISpar_lex_flag %d sts %d!!\n",sts,RISpar_lex_flag));
		if (RISpar_lex_flag & (~ALL_FLAGS))
		{
			PAR_DBG(("RISpar_get_next_token: invalid RISpar_lex_flag:0x%x\n",
				RISpar_lex_flag));
			RISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR, RISpar_lex.pos);
		}

		RISpar_init_str();

		if ((sts = stop_char(c, RISpar_lex_flag)) != 0) 
		{
			*RISpar_cur_ptr++ = c;
			*RISpar_cur_ptr = WIDECHAR('\0');
			RISpar_lex_flag = 0;

#if defined(WIN32)
			RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

			RETURN(sts, RISpar_hold_multi);
#else
			RETURN(sts, RISpar_beg_ptr);
#endif
		}

		while(1)
		{
			RISpar_check_str_size();
			*RISpar_cur_ptr++ = c;
			c = RISpar_input();

			if ((c == WIDECHAR('\0')) 
                        	|| (((RISpar_lex_flag & SPACE_FLAG) && ISSPACE(c)))
				|| (stop_char(c, RISpar_lex_flag)))
			{
				break;
			}
		}
		RISpar_unput(c);
		*RISpar_cur_ptr = WIDECHAR('\0');
		RISpar_lex_flag = 0;

#if defined(WIN32)
		RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
		PAR_DBG(("RISpar_get_next_token RETURN  \n"));
			RETURN(RIS_TOK_CHAR_STR_LIT, RISpar_hold_multi);
#else
			RETURN(RIS_TOK_CHAR_STR_LIT, RISpar_beg_ptr);
#endif
	}

	else if (c == WIDECHAR('.') && RISpar_dot_flag)
	{
		RETURN(RIS_TOK_DOT, ".");
	}
	else if (ISDIGIT(c) || c == WIDECHAR('.'))
	{
		PAR_DBG(("getting a number\n"));

		RISpar_init_str();
		state = RISpar_INITIAL;
		for(;;)
		{
			switch(state)
			{
				case RISpar_INITIAL: 
					/*
					** digit -> RISpar_INTEGER
					** . -> RISpar_DOT
					*/
					if (c == WIDECHAR('.'))           
					{
						state = RISpar_DOT;
					}
					else if (ISDIGIT(c))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_INTEGER;
					}
				break;

				case RISpar_DOT: 
					/*
					** digit -> RISpar_FRACTION
					** default -> return(RIS_TOK_DOT)
					*/
					if (ISDIGIT(c = RISpar_input())) 
					{                                                               
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = WIDECHAR('.');
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_FRACTION;
					}
					else
					{
						RISpar_unput(c);
						RETURN(RIS_TOK_DOT, ".");
					}
				break;

				case RISpar_INTEGER: 
					/*
					** digit -> RISpar_INTEGER
					** . -> RISpar_FRACTION
					** e,E -> RISpar_EXPONENT
					** default -> return(RIS_TOK_EXACT_NUM_LIT)
					*/
					while(ISDIGIT(c = RISpar_input())) 
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
					}
					if (c == WIDECHAR('.'))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_FRACTION;
					}
					else if (c == WIDECHAR('e') || c == WIDECHAR('E'))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_EXPONENT;
					}
					else
					{
						RISpar_unput(c);
						*RISpar_cur_ptr = WIDECHAR('\0');
#if defined(WIN32)
						RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

						RETURN(RIS_TOK_EXACT_NUM_LIT, RISpar_hold_multi);
#else
						RETURN(RIS_TOK_EXACT_NUM_LIT, RISpar_beg_ptr);
#endif
					}
				break;

				case RISpar_FRACTION: 
					/*
					** digit -> RISpar_FRACTION
					** e,E -> RISpar_EXPONENT
					** default -> return(RIS_TOK_EXACT_NUM_LIT)
					*/
					while(ISDIGIT(c = RISpar_input()))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
					}
					if (c == WIDECHAR('e') || c == WIDECHAR('E'))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_EXPONENT;
					}
					else
					{
						RISpar_unput(c);
						*RISpar_cur_ptr = WIDECHAR('\0');
#if defined(WIN32)
						RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

						RETURN(RIS_TOK_EXACT_NUM_LIT, RISpar_hold_multi);
#else
						RETURN(RIS_TOK_EXACT_NUM_LIT, RISpar_beg_ptr);
#endif
					}
				break;

				case RISpar_EXPONENT:
					/*
					** digit -> RISpar_APPROX
					** +,- -> RISpar_EXP_SIGN
					** default -> error
					*/
					if ((c = RISpar_input()) == WIDECHAR('+') || c == WIDECHAR('-'))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_EXP_SIGN;
					}
					else if (ISDIGIT(c))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_APPROX;
					}
					else
					{
						generate_numeric_lit_error();
						RISpar_ERR_RETURN(RIS_E_INVALID_NUMERIC_LIT,
							RISpar_lex.pos);
					}
				break;

				case RISpar_EXP_SIGN: 
					/*
					** digit -> RISpar_APPROX
					** default -> error
					*/
					if (ISDIGIT(c = RISpar_input()))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						state = RISpar_APPROX;
					}
					else
					{
						generate_numeric_lit_error();
						RISpar_ERR_RETURN(RIS_E_INVALID_NUMERIC_LIT,
							RISpar_lex.pos);
					}
				break;

				case RISpar_APPROX: 
					/*
					** digit -> RISpar_APPROX
					** default -> return(RIS_TOK_APPROX_NUM_LIT)
					*/
					while(ISDIGIT(c = RISpar_input()))
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
					}
					RISpar_unput(c);
					RISpar_cur_ptr = WIDECHAR('\0');
#if defined(WIN32)
					RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

					RETURN(RIS_TOK_APPROX_NUM_LIT, RISpar_hold_multi);
#else
					RETURN(RIS_TOK_APPROX_NUM_LIT, RISpar_beg_ptr);
#endif
			}
		}
	}
/***************************************************************************

* with this next condition, RISpar_exclude_flag is for "alter schema
* include/exclude type statements only. The following loop will be entered
* into only if:

       	 1.  this is an alter/include-exclude type statement, and
         2.  if it's an include statement, it must include a synonym, AND
             it must currently be sitting before the "as" portion (synonym)
             of the statement, since synonyms need to remain ansi-compliant
 otherwise go and do the ansi-compliant style parsing which follows...
*****************************************************************************/
        else if ((RISpar_exclude_flag)  &&
		(c != WIDECHAR(',')) && 
                (c != WIDECHAR('(')) && 
                (c != WIDECHAR(')')) && 
                (c != WIDECHAR(';'))) /* only for alter schema...include/exclude stmts
                                   allows additional $#@ chars....*/
        {
#if defined(WIN32)
		PAR_DBG(("RISpar_get_next_token INCLUDE/EXCLUDE STATEMENT %d %S\n",
		RISpar_exclude_flag,RISpar_cur_bufp));
#endif
	   if (ISALPHA(c) || ISPUNCT(c))
	   {
		RISpar_init_str();
		while (((ISPUNCT(c) || ISALNUM(c))) && (c != WIDECHAR('(')) 
			&& (c != WIDECHAR('.')) && (c != WIDECHAR(',')) 
			&& (c != WIDECHAR (')') && (c != WIDECHAR(';'))))
		{
			RISpar_check_str_size();
			*RISpar_cur_ptr++ = c;
			c = RISpar_input();
		}
		RISpar_unput(c);
		*RISpar_cur_ptr = WIDECHAR('\0');

		if (PREPROCESSOR)
			if (check_for_macro())
				return;

		/*
		** check identifier size
		*/
		if (RISpar_cur_ptr - RISpar_beg_ptr > RIS_MAX_ID_SIZE-1)
		{
			generate_ident_error();
			RISpar_ERR_RETURN(RIS_E_INVALID_IDENT,RISpar_lex.pos);
		}
		/*
		** check for keywords
		*/

#if defined(WIN32)
		RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
		tok = RISpar_lookup_keyword(RISpar_hold_multi,1);
		if (tok)
		{
			RETURN(tok,RISpar_hold_multi);
		}
		else
		{
			RETURN(RIS_TOK_IDENT,RISpar_hold_multi);
		}
#else
		tok = RISpar_lookup_keyword(RISpar_beg_ptr,1);
		if (tok)
		{
			RETURN(tok,RISpar_beg_ptr);
		}
		else
		{
			RETURN(RIS_TOK_IDENT,RISpar_beg_ptr);
		}
#endif
           }
        } /*end include/exclude parse exceptions */


	else if (RISpar_host_ident_flag && (ISALPHA(c) || c == WIDECHAR('_')))
	{
		PAR_DBG(("getting a host identifier or keyword\n"));

		RISpar_init_str();
		do
		{
			RISpar_check_str_size();
			*RISpar_cur_ptr++ = c;
		}
		while (ISALNUM(c=RISpar_input()) || c == WIDECHAR('_'));
		RISpar_unput(c);
		*RISpar_cur_ptr = WIDECHAR('\0');

	if (PREPROCESSOR)
			if (check_for_macro())
				return;

		if (!STRCMP_IC(RISpar_beg_ptr, "CHAR"))
			RETURN(RIS_TOK_CHAR, "char");

		if (!STRCMP_IC(RISpar_beg_ptr, "SHORT"))
			RETURN(RIS_TOK_SHORT, "short");

		if (!STRCMP_IC(RISpar_beg_ptr, "INT"))
			RETURN(RIS_TOK_INT, "int");

		if (!STRCMP_IC(RISpar_beg_ptr, "LONG"))
			RETURN(RIS_TOK_LONG, "long");

		if (!STRCMP_IC(RISpar_beg_ptr, "UNSIGNED"))
			RETURN(RIS_TOK_UNSIGNED, "unsigned");

		if (!STRCMP_IC(RISpar_beg_ptr, "FLOAT"))
			RETURN(RIS_TOK_FLOAT, "float");

		if (!STRCMP_IC(RISpar_beg_ptr, "DOUBLE"))
			RETURN(RIS_TOK_DOUBLE, "double");

		if (!STRCMP_IC(RISpar_beg_ptr, "SQLDA"))
			RETURN(RIS_TOK_SQLDA, "sqlda");

		if (!STRCMP_IC(RISpar_beg_ptr, "STRUCT"))
			RETURN(RIS_TOK_STRUCT, "struct");

		if (!STRCMP_IC(RISpar_beg_ptr, "DATETIME"))
			RETURN(RIS_TOK_DATETIME, "datetime");

		if (!STRCMP_IC(RISpar_beg_ptr, "SIGNED"))
			RETURN(RIS_TOK_SIGNED, "signed");

		if (!STRCMP_IC(RISpar_beg_ptr, "VOLATILE"))
			RETURN(RIS_TOK_VOLATILE, "volatile");

		if (!STRCMP_IC(RISpar_beg_ptr, "CONST"))
			RETURN(RIS_TOK_CONST, "const");

#if defined(WIN32)
		RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
		RETURN(RIS_TOK_IDENT, RISpar_hold_multi);
#else
		RETURN(RIS_TOK_IDENT, RISpar_beg_ptr);
#endif
	}
	else if (ISALPHA(c))
	{
		PAR_DBG(("getting an identifier or keyword\n"));

		RISpar_init_str();
		do
		{
			RISpar_check_str_size();
			*RISpar_cur_ptr++ = c;
		}
		while (ISALNUM(c=RISpar_input()) || c == WIDECHAR('_'));
		RISpar_unput(c);
		*RISpar_cur_ptr = WIDECHAR('\0');

#if defined(WIN32)
		PAR_DBG(("string = %S\n",RISpar_beg_ptr));
#else
		PAR_DBG(("string = %s\n",RISpar_beg_ptr));
#endif

	if (PREPROCESSOR)
			if (check_for_macro())
				return;

		/*
		** check identifier size
		*/
		if (RISpar_cur_ptr - RISpar_beg_ptr > RIS_MAX_ID_SIZE-1)
		{
			generate_ident_error();
			RISpar_ERR_RETURN(RIS_E_INVALID_IDENT,RISpar_lex.pos);
		}
		/*
		** check for keywords
		*/
#if defined(WIN32)
		RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
		tok = RISpar_lookup_keyword(RISpar_hold_multi,0);
		if (tok)
		{
			RETURN(tok,RISpar_hold_multi);
		}
		else
		{
			RETURN(RIS_TOK_IDENT,RISpar_hold_multi);
		}
#else
		tok = RISpar_lookup_keyword(RISpar_beg_ptr,0);

		if (tok)
		{
			RETURN(tok,RISpar_beg_ptr);
		}
		else
		{
			RETURN(RIS_TOK_IDENT,RISpar_beg_ptr);
		}
#endif
	}
	else if (ISPUNCT(c))
	{
		switch(c)
		{
			case WIDECHAR(','):
				RETURN(RIS_TOK_COMMA, ",");

			case WIDECHAR('('):
				RETURN(RIS_TOK_LPAREN, "(");

			case WIDECHAR(')'):
				RETURN(RIS_TOK_RPAREN, ")");

			case WIDECHAR('!'):
				if ((c = RISpar_input()) == WIDECHAR('='))
				{
					RETURN(RIS_TOK_NE, "!=");
				}
				generate_token_error();
				RISpar_ERR_RETURN(RIS_E_INVALID_TOKEN,RISpar_lex.pos);

			case WIDECHAR('<'):
				if ((c = RISpar_input()) == WIDECHAR('>'))
				{
					RETURN(RIS_TOK_NE, "<>");
				}
				if (c == WIDECHAR('='))
				{
					RETURN(RIS_TOK_LE, "<=");
				}
				RISpar_unput(c);
				RETURN(RIS_TOK_LT, "<");

			case WIDECHAR('>'):
				if ((c = RISpar_input()) == WIDECHAR('='))
				{
					RETURN(RIS_TOK_GE, ">=");
				}
				RISpar_unput(c);
				RETURN(RIS_TOK_GT, ">");

			case WIDECHAR('.'):
				RETURN(RIS_TOK_DOT, ".");

			case WIDECHAR('='):
				RETURN(RIS_TOK_EQ, "=");

			case WIDECHAR('*'):
				RETURN(RIS_TOK_MUL, "*");

			case WIDECHAR('+'):
				RETURN(RIS_TOK_PLUS, "+");

			case WIDECHAR('-'):
				RETURN(RIS_TOK_SUB, "-");

			case WIDECHAR('/'):
				RETURN(RIS_TOK_DIV, "/");

			case WIDECHAR(';'):
				RETURN(RIS_TOK_SEMICOLON, ";");

			case WIDECHAR(':'):
				RETURN(RIS_TOK_COLON, ":");

			case WIDECHAR('?'):
				RETURN(RIS_TOK_QUESTION, "?");

			case WIDECHAR('['):
				RETURN(RIS_TOK_LBRACK, "[");

			case WIDECHAR(']'):
				RETURN(RIS_TOK_RBRACK, "]");

			case WIDECHAR('\''):
				RISpar_init_str();
				RISpar_check_str_size();
				*RISpar_cur_ptr++ = c;
				for (;;)
				{
					while ((c=RISpar_input()) != WIDECHAR('\'') && c)
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
					}
					if (!c)
					{
						RISpar_ERR_RETURN(RIS_E_INVALID_CHAR_STR_LIT,
						RISpar_lex.pos);
					}
					else
					{
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
						if ((c=RISpar_input()) != WIDECHAR('\''))
						{
							RISpar_unput(c);
							*RISpar_cur_ptr = WIDECHAR('\0');
							break;
						}
						else
						{
							RISpar_check_str_size();
							*RISpar_cur_ptr++ = c;
						}
					}
				}
#if defined(WIN32)
				RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
				RETURN(RIS_TOK_CHAR_STR_LIT, RISpar_hold_multi);
#else
				RETURN(RIS_TOK_CHAR_STR_LIT, RISpar_beg_ptr);
#endif

/*
** The following code is only used for the 'prepare' and 'execute immediate'
** commands, used only in the preprocessor. Added by Prasad 12/12/91.
*/
			case WIDECHAR('"'):
			if (PREPROCESSOR)
				{
					RISpar_init_str();
					RISpar_check_str_size();
					*RISpar_cur_ptr++ = c;
					while ((c=RISpar_input()) != WIDECHAR('"') && c)
					{
						if (c == WIDECHAR('\\'))
						{
/*
** if C_CHAR_STR_LIT has \", then we copy only " and we put back the (escape 
** or preceding) \ in the CPPtree_string function. OtherwIse, we copy \ along 
** with the following characters.
*/
							if ((c=RISpar_input()) != WIDECHAR('"'))
							{
								RISpar_check_str_size();
								*RISpar_cur_ptr++ = WIDECHAR('\\');
							}
						}
						RISpar_check_str_size();
						*RISpar_cur_ptr++ = c;
					}
					if (!c)
					{
						RISpar_ERR_RETURN(RIS_E_INVALID_CHAR_STR_LIT,
							RISpar_lex.pos);
					}
					RISpar_check_str_size();
					*RISpar_cur_ptr++ = c;
#if defined(WIN32)
				RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);
					RETURN(RIS_TOK_C_CHAR_STR_LIT, RISpar_hold_multi);
#else
					RETURN(RIS_TOK_C_CHAR_STR_LIT, RISpar_beg_ptr);
#endif
				}
				else
				{
					generate_token_error();
					RISpar_ERR_RETURN(RIS_E_INVALID_TOKEN,RISpar_lex.pos);
				}
				break;

			default:
				generate_token_error();
				RISpar_ERR_RETURN(RIS_E_INVALID_TOKEN,RISpar_lex.pos);
		}
	}
	generate_token_error();
	RISpar_ERR_RETURN(RIS_E_INVALID_TOKEN,RISpar_lex.pos);
}

/**************************************************************************/
/**************************************************************************/
static int check_for_macro()
{
	/*
	**      check if macro, returns 1 if a macro was found, otherwise 0
	*/

	ENTRY *item;
	ENTRY key;
	macro_list_node *temp;

#if defined(WIN32)
	RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

	key.key = RISpar_hold_multi;
#else
	key.key = RISpar_beg_ptr;
#endif
	PAR_DBG(("check_for_macro\n"));
	if ((item = hsearch(key, FIND)) != NULL)
	{
		PAR_DBG(("\tfound macro in hash table\n"));

		for (temp = RISpar_macro_list; temp; temp = temp->next)
		{

			PAR_DBG(("\tlooking for id = %d found %d\n",(int)item->data,
			 temp->ident));

			if (temp->ident == (int)item->data)
			{
				PAR_DBG(("\tfound macro in macro_list temp->value:<%s>\n",
					temp->value ? temp->value : "NULL"));
				if (temp->value)
				{
					RISpar_token = RIS_TOK_EXACT_NUM_LIT;
					RISpar_lex.val = temp->value;
					if (RISpar_debug)
					{
						RIScom_output_debug("\tRISpar_token:<%s>\n", 
							RIScom_get_token_name(RISpar_token)); \
						RIScom_output_debug("\tRISpar_lex.pos:%d\n",
							RISpar_lex.pos);
						RIScom_output_debug("\tRISpar_lex.val:<%s>\n",  
							RISpar_lex.val); \
					}
					return 1;
				}
				else
				{
					RISpar_get_next_token();
					return 1;
				}
			}
		}
	}
	return 0;
}

/******************************************************************************/

static void generate_numeric_lit_error()
{
	char *msg_ptr;
#if defined(WIN32)
	wchar_t *numeric_lit_ptr;
	int i;
	char tmp_msg[512]; /* same length as sqlerrmc, RIS_ERRMSGC, in ris.h */
#else
	char *numeric_lit_ptr;
#endif

	msg_ptr = RIS_ERRMSGC;
	numeric_lit_ptr = RISpar_head_bufp + (RISpar_lex.pos - 1);

	msg_ptr += sprintf(msg_ptr, RIScom_umsg(RIS_E_EXPECTED_NUMERIC_LITERAL_GOT));
#if defined(WIN32)
	i = 512;
	RIScom_wcstombs(tmp_msg,numeric_lit_ptr,i);
	i = 0;
	while(numeric_lit_ptr < RISpar_cur_bufp)
	{
		if (RIScom_isleadbyte(tmp_msg[i]))
		{
			*msg_ptr++ = tmp_msg[i];
			i++;
		}
		*msg_ptr++ = tmp_msg[i];
		i++;
		*numeric_lit_ptr++;
	}
#else
	while(numeric_lit_ptr < RISpar_cur_bufp)
	{
		*msg_ptr++ = *numeric_lit_ptr++;
	}
#endif
	strcpy(msg_ptr,"',");
}

/******************************************************************************/

static void generate_ident_error()
{
#if defined(WIN32)
	RIScom_alloc_wcstombs(&RISpar_hold_multi,RISpar_beg_ptr);

	sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_IS_LONGER_THAN_CHARACTERS),
		RISpar_hold_multi, RIS_MAX_ID_SIZE-1);
#else
	sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_IS_LONGER_THAN_CHARACTERS),
		RISpar_beg_ptr, RIS_MAX_ID_SIZE-1);
#endif
}

/******************************************************************************/

static void generate_token_error()
{
	char *msg_ptr;
#if defined(WIN32)
	wchar_t *token_ptr;
	char tmp_error[512];/*same size as sqlerrmc in ris.h */
	int i;
#else
	char *token_ptr;
#endif

	msg_ptr = RIS_ERRMSGC;
	token_ptr = RISpar_head_bufp + (RISpar_lex.pos - 1);

	msg_ptr += sprintf(msg_ptr, RIScom_umsg(RIS_E_EXPECTED_VALID_TOKEN_GOT));
#if defined(WIN32)
	i = 512;
	RIScom_wcstombs(tmp_error,token_ptr,i);
	i = 0;
	while(token_ptr < RISpar_cur_bufp)
	{
		if (RIScom_isleadbyte(tmp_error[i]))
		{
			*msg_ptr++ = tmp_error[i];
			i++;
		}
		*msg_ptr++ = tmp_error[i];
		i++;
		*token_ptr++;
	}
#else
	while(token_ptr < RISpar_cur_bufp)
		*msg_ptr++ = *token_ptr++;
#endif
	strcpy(msg_ptr,"',");
}

/******************************************************************************/
extern int RISpar_lookup_keyword(char * ptr,int lower_flag)
{
	unsigned int hash;
	int i;
	char tmp_name[256]; /* hold view, index, table name ) */

	PAR_DBG(("RISpar_lookup_keyword ptr = <%s>  flag %d\n", ptr,lower_flag));
/*
** convert to lower case and compute hash value
*/

	hash = 0;
	if ((lower_flag) && (strlen(ptr) < 250))
		strcpy(tmp_name,ptr); /* save for later ,SYBASE TR 439502357*/

#if defined(WIN32)
	RIScom_multiwide(&RISwide_ptr,&ptr, &RISwide_size,MULTITOWIDE,0);
	for (i = 0; RISwide_ptr[i] != L'\0'; i++)
	{
		if (RIScom_iswupper(RISwide_ptr[i]))
			RISwide_ptr[i] = RIScom_towlower(RISwide_ptr[i]);
	}
	i = strlen(ptr); /* it'll be same size, just lowercased */
	RIScom_multiwide(&RISwide_ptr,&ptr, &RISwide_size,WIDETOMULTI,0);
#else
	for (i = 0; ptr[i]; i++)
	{
		if (RIScom_isupper(ptr[i]))
		{
			ptr[i] = (char)RIScom_tolower(ptr[i]);
		}
	}
#endif
	for (i = 0; ptr[i]; i++)
	{
		hash = hash * RISpar_ALPHA + ptr[i];
	}
	hash %= table_size;

/*
** check to see if a keyword was found, if so, return it, else 
** return 0
*/

	if (reserved[hash][0].keyword)
	{
		if (strcmp(reserved[hash][0].keyword,ptr) == 0)
		{
			return(reserved[hash][0].tok);
		}
		else if (reserved[hash][1].keyword && 
				 strcmp(reserved[hash][1].keyword,ptr) == 0)
		{
			return(reserved[hash][1].tok);
		}
		else
		{
			if ((lower_flag) && (strlen(ptr) < 250))
				strcpy(ptr,tmp_name); 
			return(0);
		}
	}
	else
	{
		if ((lower_flag) && (strlen(ptr) < 250))
			strcpy(ptr,tmp_name); 
		return(0);
	}
}

/******************************************************************************/
