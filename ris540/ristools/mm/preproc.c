/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							preproc.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "mm.h"

/*
**	DEFINES
*/
#define MAX_IF_TOKENS	50

#define TOK_FALSE	0
#define TOK_TRUE	1
#define TOK_OR		2
#define TOK_AND		3
#define TOK_NOT		4
#define TOK_LPAREN	5
#define TOK_RPAREN	6
#define TOK_END		7
#define TOK_INVALID	8
#define TOK_UNKNOWN	9

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define preproc_c
#include "define.prt"
#include "preproc.prt"
#include "output.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
/* Add the static to the foll variables in HPUX */
#if defined(__hpux__)
static char     *if_string;
static char     *if_file;
static int              if_line;
static int              if_tokens_index;
static char     if_tokens[MAX_IF_TOKENS];
#else
char	*if_string;
char	*if_file;
int		if_line;
int		if_tokens_index;
char	if_tokens[MAX_IF_TOKENS];
#endif

/*
**	FUNCTIONS
*/


/******************************************************************************/

static int get_next_if_token(
	char	**sp)
{
	char	*ptr;
	int		token = 0;

	DBG(("get_next_if_token(*sp:<%s>)\n", *sp));	

	ptr = *sp;
	
	SKIP_WHITE_SPACE(ptr);
	if (!*ptr)
	{
		token = TOK_END;
	}
	else if (*ptr == '0')
	{
		ptr += 1;
		token = TOK_FALSE;
	}
	else if (*ptr == '1')
	{
		ptr += 1;
		token = TOK_TRUE;
	}
	else if (!strncmp(ptr, "defined", 7))
	{
		int		len;
		int		paren;
		char	*tok;

		ptr += 7;
		paren = 0;

		SKIP_WHITE_SPACE(ptr);
		if (*ptr == '(')
		{
			ptr++;
			paren = 1;
			SKIP_WHITE_SPACE(ptr);
		}
		len = 0;
		tok = ptr;
		while(*ptr && !isspace(*ptr) && *ptr != ')')
		{
			len++;
			ptr++;
		}

		if (paren)
		{
			SKIP_WHITE_SPACE(ptr);
			if (*ptr != ')')
			{
				DBG(("get_next_if_token: Expected a ')' for defined(\n"));
				return TOK_INVALID;
			}
			ptr++;
		}

		token = defined(tok, len);
	}
	else if (*ptr == '&' && *(ptr + 1) == '&')
	{
		ptr += 2;
		token = TOK_AND;
	}
	else if (*ptr == '|' && *(ptr + 1) == '|')
	{
		ptr += 2;
		token = TOK_OR;
	}
	else if (*ptr == '!')
	{
		ptr++;
		token = TOK_NOT;
	}
	else if (*ptr == '(')
	{
		ptr++;
		token = TOK_LPAREN;
	}
	else if (*ptr == ')')
	{
		ptr++;
		token = TOK_RPAREN;
	}
	else
	{
		DBG(("get_next_if_token: Unknown token: <%s>\n", ptr));
		token = TOK_UNKNOWN;
	}

	*sp = ptr;

	DBG(("get_next_if_token: returning token:%d\n", token));	
	return token;
}

/******************************************************************************/

/*
**	get value and increment if_tokens_index
*/

static int get_if_value()
{
	int value = 0;

	DBG(("get_if_value()\n"));

	switch(if_tokens[if_tokens_index])
	{
		case TOK_FALSE:
		case TOK_TRUE:
			value = if_tokens[if_tokens_index];
			if_tokens_index++;
			break;

		case TOK_NOT:
			if_tokens_index++;
			value = !get_if_value();
			break;

		case TOK_LPAREN:
			if_tokens_index++;
			value = evaluate_if_tokens();
			if (if_tokens[if_tokens_index] != TOK_RPAREN)
			{
				DBG(("get_if_value: expected TOK_RPAREN got:%d\n",
					if_tokens[if_tokens_index]));
				return TOK_INVALID;
			}
			if_tokens_index++;
			break;

		default:
			DBG(("get_if_value: invalid token for value:%d\n",
				if_tokens[if_tokens_index]));
			return TOK_INVALID;
	}

	DBG(("get_if_value:returning:%d\n", value));
	return value;
}

/******************************************************************************/

static int evaluate_if_tokens()
{
	int val1 = 0;
	int	op = 0;
	int val2 = 0;

	/*
	**	Get val1 and increment if_tokens_index
	*/
	val1 = get_if_value();
	DBG(("evaluate_if_tokens: val1:%d\n", val1));

	/*
	**	Get op and increment if_tokens_index
	*/
	switch(if_tokens[if_tokens_index])
	{
		case TOK_AND:
		case TOK_OR:
			op = if_tokens[if_tokens_index];
			if_tokens_index++;
			break;

		case TOK_RPAREN:
		case TOK_END:
			DBG(("evaluate_if_tokens: returning:%d\n", val1));
			return val1;

		default:
			DBG(("evaluate_if_tokens: invalid token for op:%d\n",
				if_tokens[if_tokens_index]));
			return TOK_INVALID;
	}
	DBG(("evaluate_if_tokens: op:%d\n", op));

	while(op == TOK_AND)
	{
		val2 = get_if_value();
		DBG(("evaluate_if_tokens: val2:%d\n", val2));
		val1 = val1 && val2;

		switch(if_tokens[if_tokens_index])
		{
			case TOK_AND:
			case TOK_OR:
				op = if_tokens[if_tokens_index];
				if_tokens_index++;
				break;
	
			case TOK_RPAREN:
			case TOK_END:
				DBG(("evaluate_if_tokens: returning:%d\n", val1));
				return val1;
	
			default:
				DBG(("evaluate_if_tokens: invalid token for op:%d\n",
					if_tokens[if_tokens_index]));
				return TOK_INVALID;
		}
		DBG(("evaluate_if_tokens: op:%d\n", op));
	}

	if (op == TOK_OR)
	{
		/*
		**	Get val2
		*/
		val2 = evaluate_if_tokens();
		DBG(("evaluate_if_tokens: val2:%d\n", val2));

		val1 = val1 || val2;
	}
	return val1;
}

/******************************************************************************/

static int evaluate_if(
	char	*file,
	int		line,
	char	*string)
{
	int		i;
	int		sts = 0;
	int		token;

	DBG(("evaluate_if(file:<%s> line:%d string:<%s>)\n", file, line, string));

	if_file = file;
	if_line = line;
	if_string = string;

	for (i = 0; i < MAX_IF_TOKENS; i++)
	{
		if ((token = get_next_if_token(&string)) == TOK_UNKNOWN)
		{
			DBG(("evaluate_if:returning sts:%d\n", IF_UNKNOWN));
			return IF_UNKNOWN;
		}
		if (token == TOK_INVALID)
		{
			DBG(("evaluate_if:returning sts:%d\n", IF_INVALID));
			return IF_INVALID;
		}
		if_tokens[i] = (char)token;
		if (token == TOK_END) break;
	}

	if (i == MAX_IF_TOKENS)
	{
		fprintf(stderr, "%s: increase MAX_IF_TOKENS(%d) in \"%s\".\n",
			exe, MAX_IF_TOKENS, __FILE__);
		EXIT(1);
	}

	if_tokens_index = 0;
	switch(evaluate_if_tokens())
	{
		case TOK_TRUE:
			sts = IF_TRUE;
			break;

		case TOK_FALSE:
			sts = IF_FALSE;
			break;

		default:
			sts = IF_INVALID;
	}
	
	DBG(("evaluate_if:returning sts:%d\n", sts));
	return sts;
}

/******************************************************************************/

static int evaluate_elif(
	char	*file,
	int		line,
	char	*string)
{
	int		sts = 0;

	DBG(("evaluate_elif()\n"));

	switch(evaluate_if(file, line, string))
	{
		case IF_TRUE: sts = ELIF_TRUE; break;
		case IF_FALSE: sts = ELIF_FALSE; break;
		case IF_INVALID: sts = ELIF_INVALID; break;
		case IF_UNKNOWN: sts = ELIF_UNKNOWN; break;
		default: sts = ELIF_INVALID; break;
	}

	DBG(("evaluate_elif:returning sts:%d\n", sts));
	return sts;
}

/******************************************************************************/

static int evaluate_ifdef(
	char *s)
{
	char	*tok;
	int		return_sts;

	SKIP_WHITE_SPACE(s);

	tok = s;
	SKIP_TO_WHITE_SPACE(s);
	if (defined(tok, (int)(s - tok)))
		return_sts = IF_TRUE;
	else
		return_sts = IF_FALSE;

	return return_sts;
}

/******************************************************************************/

extern int preprocessor_directive(
	char	*file,
	int		line,
	char	*s,
	char	**argp,
	char	**type)
{
	int return_sts;

	*argp = NULL;
	return_sts = OTHER;

	s++; /* skip the '#' */

	SKIP_WHITE_SPACE(s);

	if (*s == 'i')
	{
		if (!strncmp(s, "include", 7))
		{
			s += 7;
			SKIP_WHITE_SPACE(s)
			*argp = s;
			*type = "#include";
			return_sts = INCLUDE;
		}
		else if (!strncmp(s, "ifndef", 6))
		{
			s += 6;
			SKIP_WHITE_SPACE(s);
			*type = "#ifndef";
			return_sts = !evaluate_ifdef(s);
		}
		else if (!strncmp(s, "ifdef", 5))
		{
			s += 5;
			SKIP_WHITE_SPACE(s);
			*type = "#ifdef";
			return_sts = evaluate_ifdef(s);

		}
		if (!strncmp(s, "if", 2))
		{
			s += 2;
			SKIP_WHITE_SPACE(s)
			*type = "#if";
			return_sts = evaluate_if(file, line, s);
		}
	}
	else if (*s == 'e')
	{
		if (!strncmp(s, "elif", 4))
		{
			s += 4;
			SKIP_WHITE_SPACE(s)
			*type = "#elif";
			return_sts = evaluate_elif(file, line, s);
		}
		else if (!strncmp(s, "else", 4))
		{
			*type = "#else";
			return_sts = ELSE;
		}
		else if (!strncmp(s, "endif", 5))
		{
			*type = "#endif";
			return_sts = ENDIF;
		}
	}

	return return_sts;
}

/******************************************************************************/
