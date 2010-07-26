#include "mallocdbg.h"
#include <ctype.h>
#include "cpp.h"
#include "fio.h"
#include "luther.h"
#include "cpperr.h"

#if defined (WIN32)
#undef iscsymf
#undef iscsym
#endif

#define iscsymf(c) ((isalpha(c)) || (c=='_') || (c=='$'))
#define iscsym(c) ((isalnum(c)) || (c=='_') || (c=='$'))
#define isodigit(c) (((c) - '0' >= 0) && ('7' - (c) >= 0))
#define ishexdigit(c) ((c) >= '0' && (c) <= '9' || (c) >= 'a' && (c) <= 'f' \
				|| (c) >= 'A' && (c) <= 'F')

static void luth_char_const();
static void luth_string_const();

static void (*input_function)();
static void (*unget_function)();
static struct char_data inputcd={0,"command line",0,0};
static char **inputstring;
#define INPUT(A) (*input_function)(A)
#define UNGET(A) (*unget_function)(A)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*   luther.c is the lexical analyser input to CPP                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*   collection of all the global variables for implementation of streams */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#define NEXT_NON_WHITE(A)\
 while (1)\
  {\
   if ((!isspace(A.ch))||(A.ch=='\n')) break;\
   if (A.ch==0) break;\
   INPUT(&A);\
  }

#define NEXT_CHAR(A) A.ch=' '; NEXT_NON_WHITE(A)


#define SIMPLE_OPER(A)\
 {\
  active_stream->tok.typ = A;\
  active_stream->yytext[active_stream->yylen]=0;\
  return;\
 }


#define CONST_OPER(A,B,C)\
 {\
  active_stream->tok.typ = A;\
  active_stream->yytext[active_stream->yylen]=0;\
  sscanf (active_stream->yytext,B,C);\
  return;\
 }


#define DOUBLE(D,E)\
 {\
  struct char_data d;\
  NEXT_CHAR(d);\
  if (d.ch==D)\
   {\
    active_stream->yytext[active_stream->yylen++]=d.ch;\
    SIMPLE_OPER(E)\
   }\
  UNGET(d);\
  SIMPLE_OPER(D)\
 }


#define DOUBLE_OR_EQUAL_FOLLOWS(A,B,D,E)\
 {\
  struct char_data d;\
  NEXT_CHAR(d);\
  if (d.ch=='=')\
   {\
    active_stream->yytext[active_stream->yylen++]=d.ch;\
    SIMPLE_OPER(E)\
   }\
  if (d.ch==A)\
   {\
    active_stream->yytext[active_stream->yylen++]=d.ch;\
    SIMPLE_OPER(D)\
   }\
  UNGET (d);\
  SIMPLE_OPER(B)\
 }


#define EQUAL_FOLLOWS(A,B)\
 {\
  struct char_data d;\
  NEXT_CHAR (d);\
  if (d.ch=='=')\
   {\
    active_stream->yytext[active_stream->yylen++]=d.ch;\
    SIMPLE_OPER(B)\
   }\
  UNGET (d);\
  SIMPLE_OPER(A)\
 }


static void greater_less(a,b,c,d,e)
int a,b,c,d,e;
 {
  struct char_data dd;

  INPUT(&dd);
  if (dd.ch==a)
   {
    active_stream->yytext[active_stream->yylen++]=dd.ch;
    NEXT_CHAR (dd)
    if (dd.ch=='=')
     {
      active_stream->yytext[active_stream->yylen++]=dd.ch;
      SIMPLE_OPER (e)
     }
    else
     {
      UNGET (dd);
      SIMPLE_OPER (d)
     }
   }
  else
   {
    NEXT_NON_WHITE (dd)
    if (dd.ch=='=')
     {
      active_stream->yytext[active_stream->yylen++]=dd.ch;
      SIMPLE_OPER (c)
     }
    else
     {
      UNGET (dd);
      SIMPLE_OPER (b)
     }
   }
 }


#define ID_TOKEN(A)\
 {\
  active_stream->tok.typ = A;\
  active_stream->yytext[active_stream->yylen]=0;\
  return;\
 }
  
static int wide_literal = 0;

static void luther_identifier(c)
struct char_data c;
 {
  active_stream->yylen = 0;
  active_stream->yytext[active_stream->yylen++]=c.ch;

  if ('L' == c.ch)
   wide_literal = 1;
  INPUT (&c);
  if (wide_literal)
   {
    if ('\'' == c.ch)
     {
      active_stream->yytext[active_stream->yylen++]=c.ch;
      luth_char_const(c);
      wide_literal = 0;
      return;
     }
    else if ('\"' == c.ch)
     {
      active_stream->yytext[active_stream->yylen++]=c.ch;
      luth_string_const(c);
      wide_literal = 0;
      return;
     }
     wide_literal = 0;
   }

  while (iscsym(c.ch))
   {
    active_stream->yytext[active_stream->yylen++]=c.ch;
    INPUT (&c);
   }
  UNGET (c);
  ID_TOKEN (TOK_ID)
 }


#define EAT_DIGITS(A)\
 {\
  while (isdigit(A.ch))\
   {\
    active_stream->yytext[active_stream->yylen++]=A.ch;\
    INPUT(&A);\
   }\
 }


#define EAT_DECI_DIGITS(A)\
 {\
  while (isdigit(A.ch))\
   {\
    active_stream->yytext[active_stream->yylen++]=A.ch;\
    INPUT(&A);\
   }\
 }


#define EAT_HEX_DIGITS(A)\
 {\
  while (isxdigit(A.ch))\
   {\
    active_stream->yytext[active_stream->yylen++]=A.ch;\
    INPUT(&A);\
   }\
 }


static void luther_floater(c)
struct char_data c;
 {
  struct char_data d;

  active_stream->yytext[active_stream->yylen++]=c.ch;
  INPUT(&d);
  EAT_DECI_DIGITS(d)
  switch (d.ch)
   {
    case 'e':
    case 'E':
     {
      struct char_data b;
      INPUT (&b);
      if ((b.ch=='+')||(b.ch=='-'))
       {
        struct char_data a;
        INPUT (&a);
        if (isdigit(a.ch))
         {
          active_stream->yytext[active_stream->yylen++]=d.ch;
          active_stream->yytext[active_stream->yylen++]=b.ch;
          EAT_DECI_DIGITS(a)
          UNGET (a);
          CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",
            &active_stream->tok.body.flconst);
         }
        else
         {
          UNGET (a);
          UNGET (b);
          UNGET (d);
          CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",
            &active_stream->tok.body.flconst);
         }
       }
      if (isdigit(b.ch))
       {
        active_stream->yytext[active_stream->yylen++]=d.ch;
        EAT_DECI_DIGITS(b)
        UNGET (b);
        CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",&active_stream->tok.body.flconst);
       }
     }
    default:
     UNGET (d);
     CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",&active_stream->tok.body.flconst);
   }
 }


static void luther_number(c)
struct char_data c;
 {
  struct char_data d;

  if (c.ch=='0')
   {

    /* octal or floating or hex */

    active_stream->yytext[active_stream->yylen++]=c.ch;
    INPUT (&d);
    if ((d.ch=='x')||(d.ch=='X'))
     {
      active_stream->yytext[active_stream->yylen++]=d.ch;
      INPUT (&d);
      EAT_HEX_DIGITS(d)
      if ((d.ch=='l')||(d.ch=='L'))
       active_stream->yytext[active_stream->yylen++]=d.ch;
      else
       UNGET (d);
      CONST_OPER(TOK_INT_CONSTANT,"%i",&(active_stream->tok.body.intconst));
     }

    /* octal or floating */

    EAT_DECI_DIGITS(d)
    switch (d.ch)
     {
      case '.':
       luther_floater(d);
       return;
      case 'e':
      case 'E':
       {
        struct char_data b;
        INPUT (&b);
        if ((b.ch=='+')||(b.ch=='-'))
         {
          struct char_data a;
          INPUT (&a);
          if (isdigit(a.ch))
           {
            active_stream->yytext[active_stream->yylen++]=d.ch;
            active_stream->yytext[active_stream->yylen++]=b.ch;
            EAT_DECI_DIGITS(a)
            UNGET (a);
            CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",
                   &active_stream->tok.body.flconst);
           }
          else
           {
            UNGET (a);
            UNGET (b);
            UNGET (d);
            CONST_OPER(TOK_INT_CONSTANT,"%o",
                 &(active_stream->tok.body.intconst));
           }
         }
        if (isdigit(b.ch))
         {
          active_stream->yytext[active_stream->yylen++]=d.ch;
          EAT_DECI_DIGITS(b)
          UNGET (b);
          CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",
                &active_stream->tok.body.flconst);
         }
        UNGET (d);
        CONST_OPER(TOK_INT_CONSTANT,"%o",&(active_stream->tok.body.intconst));
       }
      case 'l':
      case 'L':
       active_stream->yytext[active_stream->yylen++]=d.ch;
       CONST_OPER(TOK_INT_CONSTANT,"%o",&(active_stream->tok.body.intconst));
      default:
       UNGET(d);
       CONST_OPER(TOK_INT_CONSTANT,"%o",&(active_stream->tok.body.intconst));
     }
   }
  if (isdigit(c.ch))
   {

    /* decimal or float */
 
    active_stream->yytext[active_stream->yylen++]=c.ch;
    INPUT (&d);
    EAT_DECI_DIGITS(d);
    switch (d.ch)
     {
      case '.':
       luther_floater(d);
       return;
      case 'e':
      case 'E':
       {
        struct char_data b;
        INPUT (&b);
        if ((b.ch=='+')||(b.ch=='-'))
         {
          struct char_data a;
          INPUT (&a);
          if (isdigit(a.ch))
           {
            active_stream->yytext[active_stream->yylen++]=d.ch;
            active_stream->yytext[active_stream->yylen++]=b.ch;
            EAT_DECI_DIGITS(a)
            UNGET (a);
            CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",
               &active_stream->tok.body.flconst);
           }
          else
           {
            UNGET (a);
            UNGET (b);
            UNGET (d);
            CONST_OPER(TOK_INT_CONSTANT,"%d",
               &(active_stream->tok.body.intconst));
           }
         }
        if (isdigit(b.ch))
         {
          active_stream->yytext[active_stream->yylen++]=d.ch;
          EAT_DECI_DIGITS(b)
          UNGET (b);
          CONST_OPER (TOK_FLOAT_CONSTANT,"%lf",&active_stream->tok.body.flconst);
         }
        UNGET(d);
        CONST_OPER(TOK_INT_CONSTANT,"%d",&(active_stream->tok.body.intconst));
       }
      case 'l':
      case 'L':
       active_stream->yytext[active_stream->yylen++]=d.ch;
       CONST_OPER(TOK_INT_CONSTANT,"%d",&(active_stream->tok.body.intconst));
      default:
       UNGET(d);
       CONST_OPER(TOK_INT_CONSTANT,"%d",&(active_stream->tok.body.intconst));
     }
   }
 }


static void luther_period(c)
struct char_data c;
 {
  struct char_data d;

  INPUT (&d);
  if (isdigit(d.ch))
   {
    UNGET (d);
    luther_floater(c);
    return;
   }
  else if ('.' == d.ch)  /* ... */
   {
    struct char_data e;

    INPUT (&e);
    if ('.' == e.ch)
     {
      active_stream->yytext[active_stream->yylen++]=c.ch;
      active_stream->yytext[active_stream->yylen++]=c.ch;
      active_stream->yytext[active_stream->yylen++]=c.ch;
      SIMPLE_OPER(TOK_ELLIPSIS)
     }
    else
     {
      UNGET (e);
     }
   }
  UNGET (d);
  active_stream->yytext[active_stream->yylen++]=c.ch;
  SIMPLE_OPER(TOK_PERIOD)
 }


static struct cpp_token *new_char_token(c)
int c;
 {
  if (wide_literal)
   {
    active_stream->tok.typ = TOK_WCHAR_CONSTANT;
    active_stream->tok.body.wcharconst = (wchar_t)c;
   }
  else
   {
    active_stream->tok.typ = TOK_CHAR_CONSTANT;
    active_stream->tok.body.charconst = c;
   }
  return 0;
 }

int	luther_char_value(s)
char	*s;
{
	int	value = 0;

	if (s[1] == '\\')
	{
		if (isodigit(s[2]))
		{
			value = s[2] - '0';
			if (isodigit(s[3]))
			{
				value <<= 3;
				value |= (s[3] - '0');
				if (isodigit(s[4]))
				{
					value <<= 3;
					value |= (s[4] - '0');
				}
			}
		}
		else if ('x' == s[2])
		{
			int i;

			value = 0;
			for (i = 3; ishexdigit(s[i]); ++i)
			{
				char	c = s[i];
				int	n = 0;

				if (c >= '0' && c <= '9')
					n = c - '0';
				else if (c >= 'a' && c <= 'f')
					n = c - 'a' + 10;
				else if (c >= 'A' && c <= 'F')
					n = c - 'A' + 10;
				else
					break;
				value <<= 4;
				value |= n;
			}
		}
		else
		{
			switch (s[2])
			{
			case '\'':	value = (int)'\'';	break;
			case '\"':	value = (int)'\"';	break;
			case '\?':	value = (int)'\?';	break;
			case '\\':	value = (int)'\\';	break;
			case 'a':	value = (int)'\a';	break;
			case 'b':	value = (int)'\b';	break;
			case 'f':	value = (int)'\f';	break;
			case 'n':	value = (int)'\n';	break;
			case 'r':	value = (int)'\r';	break;
			case 't':	value = (int)'\t';	break;
			case 'v':	value = (int)'\v';	break;
			default:
				LEXERROR("invalid character in character constant");
				break;
			}
		}
	}
	else
	{
		switch (s[1])
		{
		case '\'':
			LEXERROR ("empty character constant");
			break;
		default:
			value = (int)s[1];
			break;
		}
	}
	return value;
}

static void luth_char_const(c)
struct char_data c;
 {
  while (1)
   {
    INPUT (&c);
    if (c.ch == '\\')
     {
      active_stream->yytext[active_stream->yylen++]=c.ch;
      INPUT (&c);
      active_stream->yytext[active_stream->yylen++]=c.ch;
      INPUT (&c);
     }
    if (c.ch == 0)
     {
      LEXERROR ("EOF in middle of character constant");
      SIMPLE_OPER(TOK_EOF)
     }
    if (c.ch == '\n')
     {
      LEXERROR ("NEWLINE in middle of character constant");
      SIMPLE_OPER(TOK_NEW_LINE)
     }
    active_stream->yytext[active_stream->yylen++]=c.ch;
    if (c.ch == '\'') break;
   }
  active_stream->yytext[active_stream->yylen]=0;

  new_char_token(luther_char_value(&active_stream->yytext[wide_literal]));
 }

/* ARGSUSED */
static void luth_string_const(c)
struct char_data c;
 {
  struct char_data d;

  while (1)
   {
    INPUT(&d);
    if (d.ch=='\\')
     {
      INPUT(&d);
      active_stream->yytext[active_stream->yylen++]='\\';
      active_stream->yytext[active_stream->yylen++]=d.ch;
     }
    else if (d.ch=='\n')
     {
      LEXERROR ("newline in middle of string constant");
      UNGET (d);
      break;
     }
    else if (d.ch=='\"')
     {
      active_stream->yytext[active_stream->yylen++]='\"';
      break;
     }
    else if (d.ch==0)
     {
      LEXERROR ("eof in middle of string constant");
      break;
     }
    else active_stream->yytext[active_stream->yylen++]=d.ch;
   }
  active_stream->yytext[active_stream->yylen]=0;
  ID_TOKEN (TOK_STRING_CONSTANT)
 }


void luther_unget_tok (tt)
struct cpp_token *tt;
 {
  fio_push_rec((int *)tt);
 }


static void luther_get_token()
 {
  struct char_data c;
  register struct cpp_stream *as = active_stream;
#define active_stream as

  active_stream->yytext[0]=0;
  active_stream->yylen = 0;
  while (1)
   {
    INPUT (&c);
    if (c.ch==0)
     {
      active_stream->tok.filename = c.filename;
      active_stream->tok.line_no = c.line_no;
      active_stream->tok.pol = c.pol;
      SIMPLE_OPER(TOK_EOF)
     }
    if ((!isspace(c.ch))||(c.ch=='\n')) break;
   }
  active_stream->tok.filename = c.filename;
  active_stream->tok.line_no = c.line_no;
  active_stream->tok.pol = c.pol;
  if (iscsymf(c.ch)) 
   {
    luther_identifier(c);
    return;
   }
  if (isdigit(c.ch))
   {
    luther_number(c);
    return;
   }
  if (c.ch=='.')
   {
    luther_period(c);
    return;
   }
  active_stream->yytext[active_stream->yylen++]=c.ch;
  switch (c.ch)
   {
    case '!':		/* ! != */
     EQUAL_FOLLOWS (TOK_NOT,TOK_NOT_EQUAL)
    case '%':		/* % %= */
     EQUAL_FOLLOWS (TOK_MOD,TOK_MOD_EQUAL)
    case '*':		/* * *= */
     EQUAL_FOLLOWS (TOK_STAR,TOK_TIMES_EQUAL)
    case '=':		/* = == */
     EQUAL_FOLLOWS (TOK_EQUAL,TOK_EQUAL_EQUAL)

    case '^':		/* ^ ^^ ^= */
     DOUBLE_OR_EQUAL_FOLLOWS ('^',TOK_HAT,TOK_SQOINTER,TOK_HAT_EQUAL)
    case '&':		/* & && &= */
     DOUBLE_OR_EQUAL_FOLLOWS ('&',TOK_AND,TOK_AND_AND,TOK_AND_EQUAL)
    case '|':		/* | || |= */
     DOUBLE_OR_EQUAL_FOLLOWS ('|',TOK_OR,TOK_OR_OR,TOK_OR_EQUAL)
    case '+':		/* + ++ += */
     DOUBLE_OR_EQUAL_FOLLOWS ('+',TOK_PLUS,TOK_PLUS_PLUS,TOK_PLUS_EQUAL)

    case '#':		/* start_of_cpp_command */
     DOUBLE ('#',TOK_CONCAT)

    case '/':
     {
      struct char_data d;

      INPUT(&d);
      if (d.ch=='*')
       {
        INPUT (&d);
        while (1)
         {
          if (d.ch=='*')
           {
            INPUT (&d);
            if (d.ch=='/') SIMPLE_OPER(TOK_NULL)
           }
          else
           {
            if (d.ch==0) SIMPLE_OPER(TOK_EOF)
            INPUT (&d);
           }
         }
       }
      else if (d.ch=='/')
       {
        while (1)
         {
          INPUT(&d);
          if (d.ch=='\n')
           {
            UNGET (d);
            SIMPLE_OPER(TOK_NULL)
           }
          else if (d.ch==0)
           {
            SIMPLE_OPER(TOK_EOF)
           }
         }
       }
      else
       {
        NEXT_NON_WHITE (d)
        if (d.ch=='=')
         {
          active_stream->yytext[active_stream->yylen++]=d.ch;
          SIMPLE_OPER(TOK_DIV_EQUAL)
         }
        else
         {
          UNGET(d);
          SIMPLE_OPER(TOK_DIVIDE)
         }
       }
     }

    case '-':		/* -> -- - -= */
     {
      struct char_data d;

      INPUT (&d);
      if (d.ch=='>')
       {
        active_stream->yytext[active_stream->yylen++]=d.ch;
        SIMPLE_OPER (TOK_POINTER)
       }
      else if (d.ch=='-')
       {
        active_stream->yytext[active_stream->yylen++]=d.ch;
        SIMPLE_OPER (TOK_MINUS_MINUS)
       }
      else
       {
        NEXT_NON_WHITE (d)
        if (d.ch=='=')
         {
          active_stream->yytext[active_stream->yylen++]=d.ch;
          SIMPLE_OPER (TOK_MINUS_EQUAL)
         }
        else
         {
          UNGET (d);
          SIMPLE_OPER (TOK_MINUS)
         }
       }
     }

    case '<':		/* < <= << <<= */
     greater_less('<',
       TOK_LESS,TOK_LESS_EQUAL,TOK_SHIFT_LEFT,TOK_LEFT_SHIFT_EQUAL);
     return;
    case '>':		/* > >= >> >>= */
     greater_less('>',
       TOK_GREATER,TOK_GREATER_EQUAL,TOK_SHIFT_RIGHT,TOK_RIGHT_SHIFT_EQUAL);
     return;

    case '~':		/* ~ ~> */
/*
     {
      struct char_data d;
      INPUT (&d);
      if (d.ch=='>')
       {
        active_stream->yytext[active_stream->yylen++]=d.ch;
        SIMPLE_OPER(TOK_SQOINTER)
       }
      UNGET (d);
      SIMPLE_OPER(c.ch)
     }
*/
    case '\n':
    case '(':		/* ( */
    case ')':		/* ) */
    case ',':		/* , */
    case ':':		/* : */
    case ';':		/* ; */
    case '?':		/* ? */
    case '[':		/* [ */
    case ']':		/* ] */
    case '{':		/* { */
    case '}':		/* } */
/* somethings used elsewhere */
/* plus unknown cpp_token */
    case '`':
    case '@':
    case '$':
     SIMPLE_OPER(c.ch)

    case '\\':
     {
      struct char_data d;
      INPUT (&d);
      if (d.ch=='\n')
       {
        active_stream->yytext[active_stream->yylen++]=d.ch;
        SIMPLE_OPER(TOK_BACKLASH_NL)
       }
#if defined(NT)
      else if (d.ch==0xd) /* look for carriage return linefeed */
       {
        struct char_data dd;
        INPUT (&dd);
        if (dd.ch=='\n')
         {
          active_stream->yytext[active_stream->yylen++]=dd.ch;
          SIMPLE_OPER(TOK_BACKLASH_NL)
         }
        UNGET (dd);
       }
#endif
      UNGET (d);
      SIMPLE_OPER(TOK_BACKLASH)
     }

    case '\'':		/* char_constant */
     luth_char_const(c);
     return;
    case '\"':		/* string_constant */
     luth_string_const(c);
     return;
/* +--------- 1/93 saw  Added following during NT port so luther wouldn't
                        barf on Msft include files containing ^Z */
#if defined (NT)
    case '\032':
     SIMPLE_OPER(TOK_NULL)
#endif
/* +---------- */
    default :
     printf ("character \'\\%03o\' \'%c\' not handled by luther\n",c.ch,c.ch);
     SIMPLE_OPER(TOK_NULL)
   }
#undef active_stream
 }


void luther_get_tok ()
 {
  struct cpp_token *tt;

  input_function = (void (*)())fio_getc;
  unget_function = (void (*)())fio_ungetc;
  
  fio_get_rec((int **)&tt);
  if (tt)
   {
    token_unpack(tt);
    free (tt);
    return;
   }
  luther_get_token();
  return;
 }


static void string_input(A)
struct char_data *A;
 {
  *(A)=inputcd;
  A->ch=((**inputstring == EOF) ? EOF : *((*inputstring)++));
 }


static void string_unget()
 {
  (*inputstring)--;
 }


void luther_tok_from_string (s)
char **s;
 {
  input_function = string_input;
  unget_function = string_unget;
  inputstring = s;
  luther_get_token();
  return;
 }

void luther_open(filename)
char *filename;
 {
  fio_open(filename);
 }


void luther_getc(a)
struct char_data *a;
 {
  INPUT (a);
 }
