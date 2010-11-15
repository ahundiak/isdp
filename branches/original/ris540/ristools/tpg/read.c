/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							read.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#define read_c
#include "read.prt"
#include "sys.prt"


/*
**	VARIABLES
*/
#if defined(__hpux__)
static int              c;
#else
int		c;
#endif

/*
**	FUNCTIONS
*/


/*
**	DEFINES
*/
#define TOKEN		1
#define COLON		2
#define OR			3
#define SEMICOLON	4
#define CODE		5
#define ASTERISK	6
#define POUND		7

#define GET_CHAR() \
{ \
	c = get_char(); \
	if (c == EOF) \
	{ \
		err_msg("unexpected EOF\n"); \
		exit(1); \
	} \
	code[len++] = (char) c; \
}

/******************************************************************************/


extern void err_msg(
	char *fmt,
	...)
{
    va_list	args;

	fprintf(stderr, "\"%s\", line %d: ", in_file, in_line);

    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
}

/******************************************************************************/

extern void getstring(
	char *code,
	int *lenp)
{
	int len = *lenp;

	GET_CHAR();
	while ( c != '\"' )
	{
		if (c == '\\')
		{
			GET_CHAR();
		}
		GET_CHAR();
	}

	*lenp = len;
}

/******************************************************************************/

extern void getcomment(
	char *code,
	int *lenp)
{
	int len = *lenp;

	GET_CHAR();

    while(1)
    {
		if (c == '*')
		{
			GET_CHAR();

		    if (c == '/') break;
		}
		else
		{
			GET_CHAR();
		}
	}

	*lenp = len;
}

/******************************************************************************/

extern void getcharlit(
	char *code,
	int *lenp)
{
	int len = *lenp;

	GET_CHAR();
	if (c == '\\')
	{
		GET_CHAR();
	}

	GET_CHAR();
	if (c != '\'')
	{
		err_msg("c syntax error, problem with character literal\n");
		exit(1);
	}

	*lenp = len;
}

/******************************************************************************/

extern char *get_object_name(
	int object)
{
	switch(object)
	{
		case EOF:
			return("EOF");
		case TOKEN:
			return("TOKEN");
		case COLON:
			return("COLON(:)");
		case OR:
			return("OR(|)");
		case SEMICOLON:
			return("SEMICOLON(;)");
		case CODE:
			return("CODE({)");
		case ASTERISK:
			return("ASTERISK(*)");
		case POUND:
			return("POUND(#)");
	}
	return("UNKNOWN OBJECT");
}

/******************************************************************************/

extern int get_char()
{
	int		ch;

	ch = getc(in_fp);
	if (ch == '\n') in_line++;
	return ch;
}

/******************************************************************************/

extern char *get_s(
	char *s)
{
#if defined(unix)
	char ch;
#endif
#if defined(WIN32) || defined(DOS)
	signed char ch;
#endif
	char *ptr;

	for (ptr = s;;)
	{
		ch = (signed char) get_char();
		if (ch == EOF)
		{
			if (ptr != s) return s;
			return NULL;
		}
		if (ch == '\n') break;
		*ptr++ = ch;
	}
	*ptr = '\0';

	return s;
}

/******************************************************************************/

extern void skip_white_space()
{
	while (isspace(c))
		if ((c = get_char()) == EOF)
			break;
}

/******************************************************************************/

extern void get_next_word(
	char	*ptr)
{
	while (!isspace(c) &&
		c != ':' && c != ';' && c != '|' && c != '@' && c != '*')
	{
		*ptr++ = (char) c;

		if ((c = get_char()) == EOF)
			break;
	}
	*ptr = 0;
}

/******************************************************************************/

extern void get_code(
	code_s	**codep)
{
	int		len;
	int		done;
	char	code[3200];
	int		bracket_count;

	(*codep) = (code_s*)malloc(sizeof(code_s));
	(*codep)->line = in_line;

	/*
	**	skip white space up to and including the newline after the '{'
	*/
	while(1)
	{
		if ((c = get_char()) == EOF)
		{
			err_msg("Unexpected EOF\n");
			exit(1);
		}
		if (!isspace(c))
		{
			break;
		}
		if (c == '\n')
		{
			c = get_char();
			break;
		}
	}
		
	len = 0;
	done = 0;
	bracket_count = 1;
	while(!done)
	{
		switch(c)
		{
			case '{':
				bracket_count++;
				code[len++] = (char)c;
				c = get_char();
			break;

			case '}':
				if (--bracket_count == 0)
				{
					done = 1;
					break;
				}
				code[len++] = (char)c;
				c = get_char();
			break;

			case '/':
				code[len++] = (char)c;
				c = get_char();
				if (c == '*')
				{
					code[len++] = (char)c;
					getcomment(code, &len);
					c = get_char();
				}
			break;

			case '"':
				code[len++] = (char)c;
				getstring(code, &len);
				c = get_char();
			break;

			case '\'':
				code[len++] = (char)c;
				getcharlit(code, &len);
				c = get_char();
			break;

			default:
				code[len++] = (char)c;
				c = get_char();
			break;
		}
	}

	/*
	**	skip backwards over white space up to newline
	*/
	while(len && isspace(code[(len-1)]) && code[(len-1)] != '\n')
		len--;

	(*codep)->data = (char *)malloc(len + 1);
	memcpy((*codep)->data, code, len);
	(*codep)->data[len] = 0;

	c = get_char();
}

/******************************************************************************/

extern int get_next_object(
	char	*ptr)
{
	skip_white_space();

	switch(c)
	{
		case EOF:
			return EOF;

		case ':':
			c = get_char();
			return COLON;

		case ';':
			c = get_char();
			return SEMICOLON;

		case '|':
			c = get_char();
			return OR;

		case '{':
			return CODE;

		case '*':
			c = get_char();
			return ASTERISK;

		case '#':
			c = get_char();
			return POUND;

		default:
			get_next_word(ptr);
			return TOKEN;
	}
}

/******************************************************************************/

extern void get_filename(
	char	*filename)
{
	int		len;

	skip_white_space();

	len = 0;
	while (!isspace(c))
	{
		if (len >= 14)
		{
			err_msg("filename too long\n");
			exit(1);
		}
		filename[len++] = (char)c;
		c = get_char();
	}

	if (filename[len - 2] != '.' || filename[len - 1] != 'c')
	{
		err_msg("Invalid filename, expected a \".c\" suffix got \"%s\" \n",
			filename);
		exit(1);
	}
	filename[len] = '\0';
	
	while((get_char() != '\n'));

	c = get_char();
}

/******************************************************************************/

extern void get_preproc(
	char	*preproc)
{
	int		len;

	len = 0;
	while(c != '\n')
	{
		if (len >= 256)
		{
			err_msg("preprocess directive too long\n");
			exit(1);
		}
		preproc[len++] = (char)c;
		c = get_char();
	}
	preproc[len] = '\0';
	
	c = get_char();
}

/******************************************************************************/

extern void read_rules()
{
	int		object;
	int		ok_to_loop;
	char	name[32];
	char	*e_ptr;
	char	*n_ptr;
	name_s	**preproc_ptr;
	prod_s	**prod_ptr;
	rule_s	**rule_ptr;
	data_s	**data_ptr;
	code_s	**code_ptr;
	int		i;

	in_line = 0;
	in_file = rules_file;

	if ((in_fp = fopen(in_file, OPEN_TO_READ_MODE)) == NULL)
	{
		err_msg("unable to open \"%s\" to read.\n", in_file);
		exit(1);
	}
	in_line++;

	c = get_char();

	prod_list = NULL;
	prod_ptr = &prod_list;

	while ((object = get_next_object(name)) != EOF)
	{
		if (object != TOKEN && object != ASTERISK)
		{
			err_msg("expected TOKEN or ASTERISK(*), got %s\n",
				get_object_name(object));
			exit(1);
		}

		MALLOC((*prod_ptr),prod_s);
		rule_ptr = &((*prod_ptr)->rule);
		code_ptr = &((*prod_ptr)->code);

		if (object == ASTERISK)
		{
			get_filename((*prod_ptr)->filename);

			preproc_ptr = &((*prod_ptr)->preprocs);
			while ((object = get_next_object(name)) == POUND)
			{
				MALLOC((*preproc_ptr), name_s);	
				get_preproc((*preproc_ptr)->name);
				preproc_ptr = &((*preproc_ptr)->next);
			}
			if (object != TOKEN)
			{
				err_msg("expected TOKEN, got %s\n", get_object_name(object));
				exit(1);
			}
		}

		strcpy((*prod_ptr)->name, name);
		e_ptr = (*prod_ptr)->errorname;
		e_ptr += sprintf(e_ptr, "RIS_E_INV_");
		for(n_ptr = name, i = 0; *n_ptr && i<UMS_EXT_MAX; n_ptr++,e_ptr++,i++)
		{
			if (islower(*n_ptr))
			{
				*e_ptr = _toupper(*n_ptr);
			}
			else
			{
				*e_ptr = *n_ptr;
			}
		}
		*e_ptr = '\0';

		if ((object = get_next_object(name)) != COLON && object != CODE)
		{
			err_msg("expected COLON or CODE, got %s\n",
				get_object_name(object));
			exit(1);
		}
		if (object == CODE)
		{
			get_code(code_ptr);
			object = get_next_object(name);
			if (object != COLON)
			{
				err_msg("expected COLON, got %s\n", get_object_name(object));
				exit(1);
			}
		}

		MALLOC((*rule_ptr), rule_s);
		data_ptr = &((*rule_ptr)->data);
		code_ptr = &((*rule_ptr)->code);

		ok_to_loop = 1;
		while(ok_to_loop)
		{
			object = get_next_object(name);

			switch(object)
			{
				case EOF:
					err_msg("unexpected EOF\n");
					exit(1);

				case COLON:
					err_msg("unexpected COLON(:)\n");
					exit(1);

				case SEMICOLON:
					ok_to_loop = 0;
					break;

				case TOKEN:
					MALLOC((*data_ptr), data_s);
					strcpy((*data_ptr)->name, name);
					code_ptr = &((*data_ptr)->code);
					data_ptr = &((*data_ptr)->next);
					break;

				case OR:
					rule_ptr = &((*rule_ptr)->next);
					MALLOC((*rule_ptr), rule_s);
					data_ptr = &((*rule_ptr)->data);
					code_ptr = &((*rule_ptr)->code);
					break;

				case CODE:
					get_code(code_ptr);
					break;
				
				case ASTERISK:
					err_msg("unexpected ASTERISK(*)\n");
					exit(1);
			}
		}
		prod_ptr = &((*prod_ptr)->next);
	}
}

/******************************************************************************/
