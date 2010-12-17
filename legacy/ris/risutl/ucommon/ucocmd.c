/* Do not alter this SPC information: $Revision: 1.3.9.1 $ */
/*
**	NAME:							ucocmd.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					1/93
**	ABSTRACT:
**		Reads command lines from terminal or file.
**	
**	REVISION HISTORY:
**		Functions common to risbatch and ris utilities
**		TDM - 1/31/94 - Fixed RISuco_eat_comment to handle mult. comments
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "ucommon.h"
#include "risutl.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucocmd_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "ucocmd.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/* eat white space from line;  return ptr to end of line */

extern char *RISuco_eat_white(
	char *cp)
{
	int		in_string_lit = 0;
	char	*src;
	char	*dst;

	UCO_DBG(("RISuco_eat_white(cp:<%s>)\n", cp));

	dst = src = cp;

	/* remove leading blanks */
	for ( ; *src && RIScom_isspace(*src); ++src) ;

	/* reduce multiple newlines, tabs, and spaces to single spaces */
	while(*src)
	{
		/* don't eat_white within quotes */
		if (*src == '\'')
		{
			if (!in_string_lit) 
			{
				in_string_lit = 1;
			}
			else if (*(src+1) == '\'') 
			{
				/* if this is an embedded quote, copy it and move past it */
				*dst++ = *src++;
			}
			else
			{	
				/* else, turn off the in_string_lit flag */
				in_string_lit = 0;
			}
		}
		else if (RIScom_isspace(*src) && !in_string_lit)
		{
			if (RIScom_isspace(*(src+1)))
			{
				++src;
				*src = ' ';
				continue;
			}
			*src = ' ';
		}
		*dst++ = *src++;
	}
	*dst = '\0';

	UCO_DBG(("cp=<%s>\n", cp));
	return(dst);
}

/******************************************************************************/

/*
**	eat any comments that might exist;
**	return ptr to beginning of comment if still in comment
*/

extern char *RISuco_eat_comment(
	char *cp)
{
	char *ptr;
	char *return_sts = NULL;
	char *begin_comment = NULL;

	UCO_DBG(("RISuco_eat_comment()\n"));

	while (*cp && *cp !='\'' && *cp !='\"')
	{
		/* if comment has started, look for end */
		if (*cp++ == '-' && *cp == '-')
		{
			begin_comment = cp-1;
			++cp;
		
			while (*cp)
			{
				if (*cp++ == '\n' )
				{
					ptr = begin_comment;
					while(*cp)
					{
						*ptr++ = *cp++;
					}
					*ptr = '\0';

					cp = begin_comment;
					begin_comment = NULL;
					break; 
				}
			}

			/* end of comment not found, get more input */
			if (begin_comment)
			{
				return_sts = begin_comment;
				break;
			}
		}
	}

	UCO_DBG(("RISuco_eat_comment:returning %s\n", STRING(return_sts)));
	return return_sts;
}

/******************************************************************************/

/*
**	return pointer to the first significant word of the line (skip comments
**  and whitespace);
**	return 0 if still in comment
*/

extern char *RISuco_skip_trash(
	char *cp)
{
	char *s = cp;
	int in_comment = 0;

	while (*s == ' ' || *s == '\t' || *s == '\n')
		++s;
	if (*s == '-' && *(s+1) == '-')
	{
		in_comment = 1;
		/* if comment has started, look for end */
		s += 2;
		
			/* look for end of comment on this line */
		while (*s)
		{
			if (*s++ == '\n' )
			{
				/* found end of comment; go look for more */
				s++;
				in_comment = 0;
				s = RISuco_skip_trash(s); 
				break;
			}
		}
	}
	if (in_comment || !s)
		return (char *)0;

	return s;
}

/******************************************************************************/

/*
** Does this statement require a terminating semicolon
** (i.e., can it be continued over another line?)
** return 1 if yes, 0 if no
*/


extern int RISuco_need_semi(
	char *cp)
{
	char buf[80];
	char *bufp = buf;
	char *s = cp;

	
	for ( ; *s && (bufp - buf) <= 20; ++s) 
	{
		if (!RIScom_isspace(*s))
		{
			if (RIScom_isupper(*s))
			{
				*bufp++ = ((int) RIScom_tolower(*s)); 
			}
			else
			{
				*bufp++ = *s; 
			}
		}
	}
	*bufp = '\0';

	s = buf;
	
	/* see if this statement must end with a semicolon */
	switch(*s)
	{
		case 'a':
			return (strncmp(s, "add", sizeof("add")-1) == 0 ||
					strncmp(s, "alter", sizeof("alter")-1) == 0);

		case 'c':
			if (strncmp(s, "closecursor", sizeof("closecursor")-1) == 0)
				return(0);
			return (strncmp(s, "close", sizeof("close")-1) == 0 ||
					strncmp(s, "commit", sizeof("commit")-1) == 0 ||
					strncmp(s, "create", sizeof("create")-1) == 0);

		case 'd':
			return (strncmp(s, "default",sizeof("default")-1) == 0 ||
			        strncmp(s, "define",sizeof("define")-1) == 0 ||
			        strncmp(s, "delete",sizeof("delete")-1) == 0 ||
					strncmp(s, "drop",sizeof("drop")-1) == 0 ||
					strncmp(s, "declare",sizeof("declare")-1) == 0);

		case 'e':
			if (strncmp(s, "execute", sizeof("execute")-1) == 0)
				return(0);
			if (strncmp(s, "execimm", sizeof("execimm")-1) == 0)
				return(0);
			return (strncmp(s, "exec", sizeof("exec")-1) == 0);

		case 'g':
			return (strncmp(s, "grant", sizeof("grant")-1) == 0);

		case 'i':
			return (strncmp(s, "insert", sizeof("insert")-1) == 0);

		case 'l':
			return (strncmp(s, "lock", sizeof("lock")-1) == 0);

		case 'o':
			return (strncmp(s, "open", sizeof("open")-1) == 0);

		case 'r':
			return (strncmp(s, "revoke", sizeof("revoke")-1) == 0 ||
			        strncmp(s, "rollback", sizeof("rollback")-1) == 0 ||
			        strncmp(s, "redeclare", sizeof("redeclare")-1) == 0);

		case 's':
			if (strncmp(s, "setpasswords", sizeof("setpasswords")-1) == 0)
				return(0);
			return (strncmp(s, "select", sizeof("select")-1) == 0 ||
			        strncmp(s, "set", sizeof("set")-1) == 0);

		case 'u':
			return (strncmp(s, "update", sizeof("update")-1) == 0 ||
					strncmp(s, "undeclare", sizeof("undeclare")-1) == 0);

		default:
			return(0);

	}
}

/******************************************************************************/
