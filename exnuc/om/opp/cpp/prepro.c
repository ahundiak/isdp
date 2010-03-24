#include <malloc.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include "hiersymtab.h"
#include "cpperr.h"
#include "cpp.h"
#include "omdef.h"
#include "exsysdep.h"
#include "fio.h"
#include "luther.h"
#include "env.h"

#if defined(SYSV) || defined(BSD)

#define isfilec(A) (((A)=='/')||((A)=='.')||(isalnum(A))||((A)=='_'))

#define SEPARATOR_C	'/'
#define convert_filename(F)	F
#elif defined(NT)

#define isfilec(A) (((A)=='/')||((A)=='\\')||((A)=='.')||(isalnum(A))||((A)=='_'))

#define SEPARATOR_C	'\\'
char	*convert_filename(char *);
#else
#error Unknown OS
#endif

int cpp_error_count=0;
static int ternary();
static int cpp_handle_id();
static int dummy = 0;

#define STRUCT_MALLOC(A) (struct A *)malloc(sizeof(struct A))
#define ACTIVE_TOK &(active_stream->tok)


void call_free(t)
void *t;
 {
  free (t);
 } /* call_free */


struct keyword_symbol
 {
  struct symbol symb;
  void (*process)();
  struct cpp_token *toks;
 };
#define KEYWORD_SIZE sizeof(struct keyword_symbol)


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  external symbols                                                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
char *find_file(int mode, char *fn, char *cf);
char *string_malloc(char *);
void ff_add(char *a);
void free_everything(void);

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  global symbols that do not go into streams                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
static char **cpp_switches;	/* from command line */
static char cpp_time[11]="";
static char cpp_date[14]="";
static int last_was_op;
static char msg[200];		/*  error message buffer  */
static symtab_ptr keyword_table=0;
struct cpp_stream *active_stream=0;


static int cpp_check_file(fname)
char *fname;
 {
  struct symbol *fs;
  struct cpp_token *null_token=0;

  if (cpp_options & CPP_DUPE_INCL_FILTER)
   {
    fs = lookup_symbol(active_stream->file_table,fname);
    if (fs)
     {
      sprintf (msg,"file <%s> has previously been included",fname);
      CPPINFO (null_token,msg);
      return (0);
     }
   }
  return (1);
 } /* cpp_check_file */


static void ifstack_push ()
 {
  struct ifstack_struct *tt;

  tt = STRUCT_MALLOC(ifstack_struct);
  tt->a = 0;
  tt->elif = 0;
  tt->next = active_stream->ifstack;
  active_stream->ifstack = tt;
 } /* ifstack_push */


static void ifstack_pop ()
 {
  struct ifstack_struct *tt;

  if (active_stream->ifstack)
   {
    tt = active_stream->ifstack;
    active_stream->ifstack = tt->next;
    free (tt);
   }
 } /* ifstack_pop */


static void eat_line()
 {
  while (1)
   {
    if ((active_stream->tok.typ == TOK_NEW_LINE)||
	(active_stream->tok.typ == TOK_EOF)) break;
    luther_get_tok();
   }
 } /* eat_line */


static int is_op (a)
int a;
 {
  switch (a)
   {
    case TOK_STAR:
    case TOK_DIVIDE:
    case TOK_MOD:
    case TOK_MINUS:
    case TOK_SHIFT_LEFT:
    case TOK_SHIFT_RIGHT:
    case TOK_EQUAL_EQUAL:
    case TOK_NOT_EQUAL:
    case TOK_LESS:
    case TOK_GREATER:
    case TOK_LESS_EQUAL:
    case TOK_GREATER_EQUAL:
    case TOK_AND:
    case TOK_HAT:
    case TOK_OR:
    case TOK_AND_AND:
    case TOK_OR_OR:
    case TOK_SQUIG:
    case TOK_NOT:
    case TOK_QUESTION:
    case TOK_COLEN:
     return (1);
    default:
     return (0);
   }
 } /* is_op */


static int is_unary(a)
int a;
 {
  switch (a)
   {
    case TOK_SQUIG:
    case TOK_NOT:
     return (1);
    case TOK_MINUS:
     if (last_was_op) return (1);
     return (0);
    default:
     return (0);
   }
 } /* is_unary */


static void util_get_tok ()
 {
  while (1)
   {
    luther_get_tok ();
    switch (active_stream->tok.typ)
     {
      case TOK_NULL :
      case TOK_BACKLASH_NL :
       break;

      case TOK_ID :
       if (cpp_handle_id())
	return;
       break;

      default:
       return;
     }
   }
 } /* util_get_tok */


#define NEXT_ATOM()\
 {\
  last_was_op = is_op(active_stream->tok.typ);\
  util_get_tok();\
 }


static int litter()
 {
  int i=1,p;
  struct define_symbol *assertion = 0;
  struct cpp_token *next_param = 0;

  switch (active_stream->tok.typ)
   {
    case TOK_ID :
     if (strcmp("defined",active_stream->yytext))
      {
#if 0
       sprintf(msg,"undefined identifier '\%s' in constant expression",
	 active_stream->yytext);
       CPPWARN(ACTIVE_TOK,msg);
#endif
       NEXT_ATOM();
       return(0);
      }
     luther_get_tok();/* do not expand identifiers */
     p = 0;
     if (active_stream->tok.typ == TOK_LEFT_ROUND)
      {
       luther_get_tok();/* do not expand identifiers */
       p = 1;
      }
     if (active_stream->tok.typ != TOK_ID)
      {
       CPPERROR(ACTIVE_TOK,"identifier expected");
       break;
      }
     i = lookup_symbol(active_stream->define_table,active_stream->yytext)
	  ? 1 : 0;
     NEXT_ATOM();
     if (p)
      {
       if (active_stream->tok.typ == TOK_RIGHT_ROUND)
	{
	 NEXT_ATOM();
	}
       else
	{
	 CPPERROR(ACTIVE_TOK,"')' expected");
	}
      }
     break;
    case TOK_POUND :	/* assertion */
     luther_get_tok();/* do not expand identifiers */
     if (active_stream->tok.typ != TOK_ID)
      {
       CPPERROR(ACTIVE_TOK,"identifier expected");
       i = 0;
       break;
      }
     assertion = (struct define_symbol *)
	lookup_symbol(active_stream->assertion_table,active_stream->yytext);
     luther_get_tok();/* do not expand identifiers */
     if (active_stream->tok.typ == TOK_LEFT_ROUND)
       luther_get_tok();/* do not expand identifiers */
     else
      {
       CPPERROR(ACTIVE_TOK,"'(' expected");
       i = 0;
       break;
      }
     /*  loop through and compare parameters with assertion parameters. */
     if (assertion)
      {
       i = 1;
       next_param = assertion->parameters;
      }
     else
      {
       i = 0;
       next_param = 0;      
      }
     while (active_stream->tok.typ == TOK_ID)
      {
       if (i)
        {
         if (!next_param || strcmp(next_param->constr, active_stream->yytext))
          i = 0;  /* assertion failed */
         if (next_param) next_param = next_param->flink;
        }
       luther_get_tok();
       if (TOK_COMMA == active_stream->tok.typ)
        luther_get_tok();
      }
     if (active_stream->tok.typ == TOK_RIGHT_ROUND)
      {
       NEXT_ATOM();
      }
     else
      {
       CPPERROR(ACTIVE_TOK,"')' expected");
       i = 0;
      }
     break;
    case TOK_LEFT_ROUND :
     NEXT_ATOM();
     i = ternary();
     if (active_stream->tok.typ == TOK_RIGHT_ROUND)
      {
       NEXT_ATOM();
      }
     else
      {
       CPPERROR(ACTIVE_TOK,"')' expected");
      }
     break;
    case TOK_CHAR_CONSTANT :
     i = (int)active_stream->tok.body.charconst;
     NEXT_ATOM();
     break;
    case TOK_WCHAR_CONSTANT :
     i = (int)active_stream->tok.body.wcharconst;
     NEXT_ATOM();
     break;
    case TOK_INT_CONSTANT :
     i = active_stream->tok.body.intconst;
     NEXT_ATOM();
     break;
    case TOK_FLOAT_CONSTANT :
     i = (int)active_stream->tok.body.flconst;
     NEXT_ATOM();
     break;
    default:
     CPPERROR(ACTIVE_TOK,"literal, 'defined', or '(' expected");
     break;
   }
  return (i);
 } /* litter */


static int unary_oper()
 {
  int i=1;

  if (is_unary(active_stream->tok.typ))
   {
    switch (active_stream->tok.typ)
     {
      case TOK_MINUS :
       NEXT_ATOM();
       i = -unary_oper();
       break;
      case TOK_SQUIG :
       NEXT_ATOM();
       i = ~unary_oper();
       break;
      case TOK_NOT :
       NEXT_ATOM();
       i = !unary_oper();
       break;
      default :
       CPPERROR(ACTIVE_TOK,"unknown unary operator");
       break;
     }
    return (i);
   }
  else
   {
    return (litter());
   }
 } /* unary_oper */


static int multiplicative()
 {
  int i,j;

  i = unary_oper();
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_STAR :
       NEXT_ATOM();
       j = unary_oper();
       i *= j;
       break;
      case TOK_MOD :
       NEXT_ATOM();
       j = unary_oper();
       if (j)
	i %= j;
       break;
      case TOK_DIVIDE :
       NEXT_ATOM();
       j = unary_oper();
       if (j)
	i /= j;
       break;
      default:
       return (i);
     }
   }
 } /* multiplicative */


static int additive()
 {
  int i;

  i = multiplicative();
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_PLUS :
       NEXT_ATOM();
       i += multiplicative();
       break;
      case TOK_MINUS :
       NEXT_ATOM();
       i -= multiplicative();
       break;
      default :
       return (i);
     }
   }
 } /* additive */


static int shifts()
 {
  int i;

  i = additive();
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_SHIFT_LEFT :
       NEXT_ATOM();
       i <<= additive();
       break;
      case TOK_SHIFT_RIGHT :
       NEXT_ATOM();
       i >>= additive();
       break;
      default:
       return (i);
     }
   }
 } /* shifts */


static int inequality ()
 {
  int i;

  i = shifts();
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_LESS :
       NEXT_ATOM();
       i = (i < shifts());
       break;
      case TOK_GREATER :
       NEXT_ATOM();
       i = (i > shifts());
       break;
      case TOK_LESS_EQUAL :
       NEXT_ATOM();
       i = (i <= shifts());
       break;
      case TOK_GREATER_EQUAL :
       NEXT_ATOM();
       i = (i >= shifts());
       break;
      default :
       return (i);
     }
   }
 } /* inequality */
  

static int equality ()
 {
  int i;
  int j;

  i = inequality ();
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case TOK_EQUAL_EQUAL :
       NEXT_ATOM ();
       j = inequality();
       i = (i == j);
       break;
      case TOK_NOT_EQUAL :
       NEXT_ATOM ();
       j = inequality();
       i = (i != j);
       break;
      default :
       return (i);
     }
   }
 } /* equality */


static int bitwise_and()
 {
  int i;

  i = equality();
  while (active_stream->tok.typ == TOK_AND)
   {
    int j;
    NEXT_ATOM ();
    j = equality();
    i &= j;
   }
  return (i);
 } /* bitwise_and */


static int bitwise_xor()
 {
  int i;

  i = bitwise_and();
  while (active_stream->tok.typ == TOK_HAT)
   {
    int j;
    NEXT_ATOM ();
    j = bitwise_and();
    i ^= j;
   }
  return (i);
 } /* bitwise_xor */


static int bitwise_or()
 {
  int i;

  i = bitwise_xor();
  while (active_stream->tok.typ == TOK_OR)
   {
    int j;
    NEXT_ATOM ();
    j = bitwise_xor();
    i |= j;
   }
  return (i);
 } /* bitwise_or */


static int logical_and()
 {
  int i;

  i = bitwise_or();
  while (active_stream->tok.typ == TOK_AND_AND)
   {
    int j;

    NEXT_ATOM ();
    j = bitwise_or();
    i = (i && j);
   }
  return (i);
 } /* logical_and */


static int logical_or()
 {
  int i,j;

  i = logical_and();
  while (active_stream->tok.typ == TOK_OR_OR)
   {
    NEXT_ATOM ();
    j = logical_and();
    i = i || j;
   }
  return (i);
 } /* logical_or */


static int ternary()
 {
  int i,j,k;

  i = logical_or();
  if (active_stream->tok.typ == TOK_QUESTION)
   {
    NEXT_ATOM();
    j = ternary();
    if (active_stream->tok.typ != TOK_COLEN)
     {
      CPPERROR (ACTIVE_TOK,"':' expected");
      return (i);
     }
    NEXT_ATOM();
    k = ternary();
    i = i ? j : k;
   }
  return (i);
 } /* ternary */


static int eval_expr()
 {
  int i;

  last_was_op = 1;
  util_get_tok();
  i = ternary();
  if (active_stream->tok.typ != TOK_NEW_LINE)
   {
    CPPERROR(ACTIVE_TOK,"new line expected");
    eat_line();
   }
  return (i);
 } /* eval_expr */


#define ignore_nulls()\
 {\
  luther_get_tok();\
  while (active_stream->tok.typ == TOK_NULL) luther_get_tok();\
 }


static void next_tok ()
 {
  while (1)
   {
    luther_get_tok ();
    switch (active_stream->tok.typ)
     {
      case TOK_NULL :
      case TOK_NEW_LINE :
      case TOK_BACKLASH_NL :
       break;
      default:
       return;
     }
   }
 } /* next_tok */

#define FALSE_IF_ACTION(A) \
  if (active_stream->ifstack && active_stream->ifstack->a)\
   {\
    A;\
    eat_line ();\
    return;\
   }

static int param_index(d, name)
struct define_symbol *d;
char *name;
 {
  struct cpp_token *p;
  int i;

  for (i = 0, p = d->parameters; p; p = p->flink, ++i)
   if (!strcmp(name, p->constr))
    return i;
 
  return -1;
 }

static int equivalent_define(d0, d1)
struct define_symbol *d0;
struct define_symbol *d1;
 {
  struct cpp_token *p0, *p1;

  if (d0->no_of_pars != d1->no_of_pars || d0->parametric != d1->parametric)
   return 0;

  p0 = d0->define_tokens;
  p1 = d1->define_tokens;
  while (p0 && p1)
   {
    if (strcmp(p0->constr, p1->constr))
     {
      /* check to see if these are parameters and 
         if they are the same parameter */
      int i0 = param_index(d0, p0->constr);
      int i1 = param_index(d1, p1->constr);

      if (i0 != i1 || i0 == -1)
       return 0;
     }
    p0 = p0->flink;
    p1 = p1->flink;
   }

  if (p0 || p1)
   return 0;

  return 1;
 }

static void process_assert()
 {
  struct define_symbol *ds;
  struct define_symbol *lsd;
  struct cpp_token *ta;
  int pp;
  struct stripped_tok dup_tok;

  FALSE_IF_ACTION(++dummy);
  ignore_nulls();
  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR(ACTIVE_TOK,"identifier expected");
    eat_line ();
    return;
   }

  ds = STRUCT_MALLOC(define_symbol);
  ds->symb.name = (char *)string_malloc(active_stream->yytext);
  ds->define_tokens = 0;
  ds->no_of_pars = 0;
  ds->parametric = 0;
  ds->parameters = 0;

  lsd = (struct define_symbol *)
	lookup_symbol (active_stream->assertion_table,ds->symb.name);
  if (lsd)
   {
    sprintf (msg,"reassertion of %s",active_stream->yytext);
    dup_tok = *ACTIVE_TOK;
   }

  pp = active_stream->tok.pol + active_stream->yylen;
  ignore_nulls();
  if ((active_stream->tok.typ == TOK_LEFT_ROUND)&&
      (active_stream->tok.pol == pp))
   {
    int i;

    ds->parametric=1;
    i = 0;
    ignore_nulls();
    while (1) /* loop to read in parameters */
     {
      if (active_stream->tok.typ != TOK_ID)
       {
	if ((i==0)&&(active_stream->tok.typ==TOK_RIGHT_ROUND))
	 {
	  ignore_nulls();
	  break;
	 }
	CPPERROR (ACTIVE_TOK,
	 "invalid field. identifier or \')\' expected.");
	eat_line();
	break;
       }
      else     /* identifier found */
       {
	ta = token_malloc();
	/* add to end of circular list */
	if (!ds->parameters)
	 ds->parameters = ta->flink = ta;
        else
         {
	  ta->flink = ds->parameters->flink;
	  ds->parameters->flink = ta;
	  ds->parameters = ta;
	 }
	i++;

	ignore_nulls ();
	if (active_stream->tok.typ != TOK_COMMA)
	 {
	  if (active_stream->tok.typ == TOK_RIGHT_ROUND)
	   {
	    ignore_nulls ();
	    break;
	   }
	  CPPERROR (ACTIVE_TOK,
	    "invalid field. \',\' or \')\' expected.");
	  eat_line();
	  break;
	 }
	else
	 {
	  ignore_nulls ();
	 }
       }
     } /* end of loop to read in parameters */
    ds->no_of_pars = i;
    if (ds->parameters)
     { /* remove circular link */
      struct cpp_token *ds2 = ds->parameters->flink;
      ds->parameters->flink = 0;
      ds->parameters = ds2;
     }
   } /* end of parameter if statement */

  while (1)    /* read tokens until end of line or file is found */
   {
    if (active_stream->tok.typ==TOK_EOF) break;
    if (active_stream->tok.typ==TOK_NEW_LINE) break;
/* +------- 1/93 saw  Added the following clause during NT port */
    if (active_stream->tok.typ==TOK_BACKLASH_NL)
     {
      ignore_nulls ();
      continue;
     }
/* +----------+ */
    ta = token_malloc();
    ta->flink = ds->define_tokens;
    ds->define_tokens = ta;
    ignore_nulls ();
   }
  enter_symbol (active_stream->assertion_table,ds);

  /* check to see if multiple definitions are identical */
  if (lsd && !equivalent_define(lsd, ds))
   {
    CPPWARN (&dup_tok,msg);
   }

  return;
 } /* process_assert */

static void process_define()
 {
  struct define_symbol *ds;
  struct define_symbol *lsd;
  struct cpp_token *ta;
  int pp;
  struct stripped_tok dup_tok;

  FALSE_IF_ACTION(++dummy);
  ignore_nulls();
  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR(ACTIVE_TOK,"identifier expected");
    eat_line ();
    return;
   }

  ds = STRUCT_MALLOC(define_symbol);
  ds->symb.name = (char *)string_malloc(active_stream->yytext);
  ds->define_tokens = 0;
  ds->no_of_pars = 0;
  ds->parametric = 0;
  ds->parameters = 0;

  lsd = (struct define_symbol *)
	lookup_symbol (active_stream->define_table,ds->symb.name);
  if (lsd)
   {
    sprintf (msg,"redefinition of %s",active_stream->yytext);
    dup_tok = *ACTIVE_TOK;
   }

  pp = active_stream->tok.pol + active_stream->yylen;
  ignore_nulls();
  if ((active_stream->tok.typ == TOK_LEFT_ROUND)&&
      (active_stream->tok.pol == pp))
   {
    int i;

    ds->parametric=1;
    i = 0;
    ignore_nulls();
    while (1) /* loop to read in parameters */
     {
      if (active_stream->tok.typ != TOK_ID)
       {
	if ((i==0)&&(active_stream->tok.typ==TOK_RIGHT_ROUND))
	 {
	  ignore_nulls();
	  break;
	 }
        if (active_stream->tok.typ==TOK_BACKLASH_NL)
         {
          ignore_nulls ();
          continue;
         }
	CPPERROR (ACTIVE_TOK,
	 "invalid field. identifier or \')\' expected.");
	eat_line();
	break;
       }
      else     /* identifier found */
       {
	ta = token_malloc();
	/* add to end of circular list */
	if (!ds->parameters)
	 ds->parameters = ta->flink = ta;
        else
         {
	  ta->flink = ds->parameters->flink;
	  ds->parameters->flink = ta;
	  ds->parameters = ta;
	 }
	i++;

	ignore_nulls ();
	if (active_stream->tok.typ != TOK_COMMA)
	 {
	  if (active_stream->tok.typ == TOK_RIGHT_ROUND)
	   {
	    ignore_nulls ();
	    break;
	   }
	  CPPERROR (ACTIVE_TOK,
	    "invalid field. \',\' or \')\' expected.");
	  eat_line();
	  break;
	 }
	else
	 {
	  ignore_nulls ();
	 }
       }
     } /* end of loop to read in parameters */
    ds->no_of_pars = i;
    if (ds->parameters)
     { /* remove circular link */
      struct cpp_token *ds2 = ds->parameters->flink;
      ds->parameters->flink = 0;
      ds->parameters = ds2;
     }
   } /* end of parameter if statement */

  while (1)    /* read tokens until end of line or file is found */
   {
    if (active_stream->tok.typ==TOK_EOF) break;
    if (active_stream->tok.typ==TOK_NEW_LINE) break;
    if (active_stream->tok.typ==TOK_BACKLASH_NL)
     {
      ignore_nulls ();
      continue;
     }
    ta = token_malloc();
    ta->flink = ds->define_tokens;
    ds->define_tokens = ta;
    ignore_nulls ();
   }
  enter_symbol (active_stream->define_table,ds);

  /* check to see if multiple definitions are identical */
  if (lsd && !equivalent_define(lsd, ds))
   {
    CPPWARN (&dup_tok,msg);
   }

  return;
 } /* process_define */


static void process_undef()
 {
  struct cpp_token *ta;
  struct cpp_token *tb;
  struct define_symbol *lsd;

  FALSE_IF_ACTION(++dummy);
  ignore_nulls();
  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR (ACTIVE_TOK,"identifier expected");
    eat_line();
    return;
   }
  lsd = (struct define_symbol *)
      lookup_symbol(active_stream->define_table,active_stream->yytext);
  if (lsd == 0)
   {
    /*sprintf (msg,"\'%s\' not defined",active_stream->yytext);
    CPPWARN (ACTIVE_TOK,msg);*/
    eat_line();
    return;
   }
  remove_symbol (active_stream->define_table,lsd);
  if (lsd == (struct define_symbol *)lookup_symbol(active_stream->define_table,lsd->symb.name))
   {
    struct define_symbol *ds;

    ds = STRUCT_MALLOC(define_symbol);
    ds->symb.name = (char *)string_malloc(lsd->symb.name);
    ds->define_tokens = 0;
    ds->no_of_pars = -5; /* special marker for undefined inherited macro */
    ds->parametric = 0;
    ds->parameters = 0;

    enter_symbol (active_stream->define_table, ds);
   }
  else
   { /* remove worked */
    ta = lsd->define_tokens;
    while (ta)
     {
      tb = ta->flink;
      free (ta);
      ta = tb;
     }
    ta = lsd->parameters;
    while (ta)
     {
      tb = ta->flink;
      free (ta);
      ta = tb;
     }
    free (lsd->symb.name);
    free (lsd);
   }
 } /* process_undef */

static void push_back_string(c, yytext, yylen)
struct char_data c;
char             *yytext;
int              yylen;
{
   int ii;

   for (ii = yylen - 1; ii >= 0; --ii)
   {
      c.ch = yytext[ii];
      fio_ungetc(c);
      --c.pol;
   }
}

static void process_include_define(p_c)
struct char_data *p_c;
{
   /* define name used for include */

   struct char_data c;
   char name[YYTEXT_SIZE+1];
   int ii;

   char *filename = active_stream->cur_filename;
   int  line_no = active_stream->cur_linenum;
   int  pol;

   c = *p_c;
   pol = c.pol;

   /* read the define name into a local buffer */

   for (name[ii=0] = c.ch; 
        c.ch != ' ' && c.ch != '\t' && c.ch != '\n' && c.ch != 0; 
        name[++ii] = c.ch)
      if (YYTEXT_SIZE == ii)
      {
         CPPERROR (ACTIVE_TOK,"define for file name on include is too long");
         return;
      }
      else
         luther_getc(&c);

   name[ii] = '\0';

   /* get tokens from the local buffer */

   fio_open_string(name);

   /* process one token to expand any #define(s) */

   cpp_get_tok();

   c.filename = filename;
   c.line_no =  line_no;

   if ('"' == active_stream->yytext[0])
   {
      c.pol = pol + active_stream->yylen - 1;
      push_back_string(c, active_stream->yytext, active_stream->yylen);
   }
   else if (TOK_LESS == active_stream->tok.typ)
   {
      /* must concatenate all tokens until the closing > */

      int len = 0;

      name[len] = 0;
      while (active_stream->tok.typ != TOK_EOF &&
             active_stream->tok.typ != '\n' &&
             active_stream->tok.typ != TOK_GREATER)
      {
         if (len + active_stream->yylen >= YYTEXT_SIZE)
         {
            CPPERROR (ACTIVE_TOK,"define for file name on include is too long");
            return;
         }
         strcat(name, active_stream->yytext);
         len += active_stream->yylen;
         luther_get_tok();
      }
      if (TOK_GREATER == active_stream->tok.typ)
      {
         strcat(name, active_stream->yytext);
         len += active_stream->yylen;
         c.pol = pol + len - 1;
         push_back_string(c, name, len);
      }
      else
      {
         CPPERROR (ACTIVE_TOK,"illegal define for file name on include");
         return;
      }
   }
   else
      return;

   /* return to start reading character input from the now expanded filename */

   luther_getc(p_c);
   
} /* process_include_define */

static void process_include()
 {
  char filename[120];
  char *final_file;
  struct char_data c;
  struct char_data d;
  int i;

  FALSE_IF_ACTION (++dummy);
  while (1)
   {
    luther_getc(&c);
    if ((c.ch=='\"')||(c.ch=='<')||(c.ch=='\n')||(c.ch==0)) break;
    else if (c.ch != ' ' && c.ch != '\t')
     {
       process_include_define(&c);
       break;
     }
   }
  switch (c.ch)
   {
    case '\"':
    case '<':
     luther_getc(&d);
     i=0;
     while (isfilec(d.ch))
      {
#if defined(NT)
	if ('/' == d.ch)
		d.ch = '\\';
#endif 
       filename[i++]=d.ch;
       luther_getc(&d);
      }
     filename[i]=0;
#if ! defined(BSD) && defined(SUNOS)
     while ((d.ch!=0)&&(d.ch!='\n')) luther_getc(&d);
#endif
     final_file = find_file (c.ch,filename,c.filename);
     if (final_file)
      {
       if (cpp_check_file(final_file))
	luther_open (final_file);
      }
     else
      {
       sprintf (msg,"file %s not found",filename);
       CPPERROR (ACTIVE_TOK,msg);
      }
     return;
       
    default:
     CPPERROR (ACTIVE_TOK,"invalid file name on include");
     return;
   }
 } /* process_include */


static void process_if()
 {
  FALSE_IF_ACTION ((active_stream->ifstack->a)++);

  ifstack_push();

  if (!eval_expr())
   (active_stream->ifstack->a)++;
  else
   (active_stream->ifstack->elif)++;
 } /* process_if */


static void process_elif()
 {
  if (active_stream->ifstack==0)
   {
    CPPERROR(ACTIVE_TOK,"#if-less #elif");
    eat_line();
    return;
   }

  if (active_stream->ifstack->a < 2)
   {
    if (active_stream->ifstack->a == 0)
     active_stream->ifstack->a = 1;
    else
     if (!(active_stream->ifstack->elif))
      {
       active_stream->ifstack->a = 0;
       if (!eval_expr())
	active_stream->ifstack->a = 1;
       else
	(active_stream->ifstack->elif)++;
      }
     else
      eat_line();
   }
  else
   {
    eat_line();
   }
 } /* process_elif */


static void process_else()
 {
  if (active_stream->ifstack==0)
   {
    CPPERROR(ACTIVE_TOK,"#if-less #else");
    eat_line();
    return;
   }

  if (active_stream->ifstack->a < 2)
   {
    if (active_stream->ifstack->a == 0)
     active_stream->ifstack->a = 1;
    else
     if (!(active_stream->ifstack->elif))
      {
       active_stream->ifstack->elif = 1;
       active_stream->ifstack->a = 0;
      }
   }
  eat_line();
  return;
 } /* process_else */


static void process_endif()
 {
  if (active_stream->ifstack==0)
   {
    CPPERROR(ACTIVE_TOK,"#if-less #endif");
    eat_line();
    return;
   }
  if (active_stream->ifstack->a < 2)
   ifstack_pop();
  else
   (active_stream->ifstack->a)--;
  eat_line();
  return;
 } /* process_endif */


static void process_ifdef()
 {
  struct define_symbol *ds;

  FALSE_IF_ACTION ((active_stream->ifstack->a)++);

  ignore_nulls();

  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR(ACTIVE_TOK,"identifier expected");
    ifstack_push();
    (active_stream->ifstack->elif)++;
    eat_line();
    return;
   }

  ds=(struct define_symbol *)
      lookup_symbol(active_stream->define_table,active_stream->yytext);
  ifstack_push();
  if (!ds)
   (active_stream->ifstack->a)++;
  else
   (active_stream->ifstack->elif)++;
  eat_line();
  return;
 } /* process_ifdef */


static void process_ifndef()
 {
  struct define_symbol *ds;

  FALSE_IF_ACTION ((active_stream->ifstack->a)++);
  ignore_nulls();
  if (active_stream->tok.typ != TOK_ID)
   {
    CPPERROR(ACTIVE_TOK,"identifier expected");
    ifstack_push();
    (active_stream->ifstack->elif)++;
    eat_line();
    return;
   }

  ds=(struct define_symbol *)
       lookup_symbol(active_stream->define_table,active_stream->yytext);
  ifstack_push();
  if (ds)
   (active_stream->ifstack->a)++;
  else
   (active_stream->ifstack->elif)++;
  eat_line();
  return;
 } /* process_ifndef */


static void process_omerror()
 {
  FALSE_IF_ACTION (++dummy);
  ignore_nulls();
  if (active_stream->tok.typ == TOK_STRING_CONSTANT)
   { OMDEFERROR(ACTIVE_TOK,active_stream->yytext); }
  else
   { CPPERROR(ACTIVE_TOK,"String Constant expected in #omerror"); }
  eat_line();
 } /* process_omerror */

static void process_pragma()
 {
  FALSE_IF_ACTION (++dummy);
  eat_line();
 } /* process_pragma */

static void process_error()
 {
  FALSE_IF_ACTION (++dummy);
  ignore_nulls();
  cpp_error_count++;
  fprintf (stderr,"\"%s\", %d: cpp error: #error",active_stream->tok.filename,
   active_stream->tok.line_no);
  while (1)
   {
    if (active_stream->tok.typ == TOK_NEW_LINE || 
        active_stream->tok.typ == TOK_EOF)
     break;
    if (active_stream->yylen)
     fprintf(stderr, " %s", active_stream->yytext);
    luther_get_tok();
   }
  fprintf(stderr, "\n");
  file_traceback ();\
 } /* process_error */

static void process_argsused()
 {
  struct cpp_token *t;

  FALSE_IF_ACTION (++dummy);

  strcpy(active_stream->yytext, "/* ARGSUSED */");
  active_stream->yylen = strlen(active_stream->yytext);
  active_stream->tok.typ = TOK_ARGSUSED;
  t = token_malloc();
  eat_line();
  luther_unget_tok(t);
 } /* process_argsused */

static void cpp_do_inst ()
 {
  struct keyword_symbol *ks;

  luther_get_tok ();
  if (active_stream->tok.typ==TOK_ID)
   {
    ks = (struct keyword_symbol *)
      lookup_symbol(keyword_table,active_stream->yytext);
    if (ks)
     ks->process ();
    else
     {
/*
      CPPWARN(ACTIVE_TOK,"unknown preprocessor command");
*/
      eat_line();
     }
   }
  else
   {
    CPPERROR(ACTIVE_TOK,"cpp keyword expected");
   }
  return;
 } /* cpp_do_inst */


static int token_cat_recurse (so,si,tt,slen)
char *so;
char **si;
struct cpp_token *tt;
int slen;
 {
  if (tt==0) return(0);
  if (token_cat_recurse (so,si,tt->flink,slen)) return(1);
   
  if (slen < (((int)(*si) - (int)so) + (int)strlen(tt->constr) + 3)) return(1);
  if (tt->flink) *(*si)++=' ';
  strcpy (*si,tt->constr);
  while (**si) (*si)++;
  return (0);
 } /* token_cat_recurse */



static int token_cat(tt,s,slen)
struct cpp_token *tt;
char *s;
int slen;
 {
  char *si;

  si = s;
  *si++='"';
  token_cat_recurse (s,&si,tt,slen);
  *si++='"';
  *si=0;
  return ((int)si-(int)s);
 } /* token_cat */


static int do_specialdef (typ)
int typ;
 {
  switch (typ)
   {
    case -1: /*__LINE__*/
     sprintf (active_stream->yytext,"%d",active_stream->tok.line_no);
     active_stream->yylen = strlen(active_stream->yytext);
     active_stream->tok.body.intconst = active_stream->tok.line_no;
     active_stream->tok.typ = TOK_INT_CONSTANT;
     return (1);
    case -2: /*__FILE__*/
     sprintf (active_stream->yytext,"\"%s\"",convert_filename(active_stream->tok.filename));
     active_stream->yylen = strlen(active_stream->yytext);
     active_stream->tok.typ = TOK_STRING_CONSTANT;
     return (1);
    case -3: /*__DATE__*/
     sprintf (active_stream->yytext,"%s",cpp_date);
     active_stream->yylen = strlen(active_stream->yytext);
     active_stream->tok.typ = TOK_STRING_CONSTANT;
     return (1);
    case -4: /*__TIME__*/
     sprintf (active_stream->yytext,"%s",cpp_time);
     active_stream->yylen = strlen(active_stream->yytext);
     active_stream->tok.typ = TOK_STRING_CONSTANT;
     return (1);
    case -5: /* undefined inherited macro */
     return 1;
    default:
     return (1);
   }
 } /* do_specialdef */


static void reverse_token_list (head,tail)
struct cpp_token **head,**tail;
 {
  struct cpp_token *tt,*pp;
  if (*tail)
   {
    tt = *head;
    *head = *tail;
    *tail = tt;
    while (tt)
     {
      pp = tt->flink;
      tt->flink = tt->blink;
      tt->blink = pp;
      tt = pp;
     }
   }
 } /* reverse_token_list */


static void add_to_token_list (head,tail,tt)
struct cpp_token **head,**tail,*tt;
 {
  if (*tail)
   {
    (*tail)->flink = tt;
    tt->blink = *tail;
    *tail = tt;
   }
  else
   {
    *head = *tail = tt;
    tt->blink = 0;
   }
  tt->flink = 0;
 } /* add_to_token_list */


static void do_con_cat (tt,old_head)
struct cpp_token **tt;
struct cpp_token **old_head;
 {
  struct cpp_token *t1,*t2,*t3,*t4;
  char *m;
  struct cpp_token *head=0,*tail=0;

  msg[0] = 0;
  if ((*tt)->flink) strcat (msg,(*tt)->flink->constr);
  if ((*tt)->blink) strcat (msg,(*tt)->blink->constr);
  m = msg;
  while (1)
   {
    luther_tok_from_string(&m);
    if (active_stream->tok.typ == TOK_EOF) break;
    active_stream->tok.filename = (*tt)->filename;
    active_stream->tok.line_no = (*tt)->line_no;
    active_stream->tok.pol = (*tt)->pol;
    add_to_token_list (&head,&tail,token_malloc());
   }
  reverse_token_list (&head,&tail);
  t1 = t4 = 0;
  t2 = (*tt)->blink;
  if (t2) { t1 = t2->blink; free (t2); }
  t3 = (*tt)->flink;
  if (t3) { t4 = t3->flink; free (t3); }
  free (*tt);
  if (head)
   {
    if (t1)
     { head->blink = t1; t1->flink = head; }
    if (t4)
     { tail->flink = t4; t4->blink = tail; }
    *tt = head;
    if (!t1) *old_head = head;
    return;
   }
  if (t1) t1->flink = t4;
  if (t4) t4->blink = t1;
  if (t4) *tt=t4;
  else if (t1) *tt=t1;
  else *tt=0;
  if (!t1) *old_head = *tt;
  return;
 } /* do_con_cat */


static symtab_ptr read_parameter_list (ds)
 struct define_symbol *ds;
 {
  struct cpp_token *ta,*tb,*cl=0;
  symtab_ptr p_tab;
  struct keyword_symbol *ps;

  int inside_tik=0;
  int pard=0;
  int too_much = 0;

  p_tab = new_basictab (7, (cpp_options & CPP_DEBUG) ? stderr: 0);
  if (!ds->parametric) return p_tab;

  next_tok();
  if (active_stream->tok.typ != TOK_LEFT_ROUND)
   {
    /*CPPERROR(ACTIVE_TOK,"'(' expected");*/
    ta = token_malloc();
    cpp_unget_tok(ta);
    return 0;
   }
  next_tok();
  if (active_stream->tok.typ == TOK_RIGHT_ROUND) return p_tab;
  tb = ds->parameters;
  while (1)
   {
    switch (active_stream->tok.typ)
     {
      case '`':
       inside_tik = !inside_tik;
       break;
      case ',':
       if (pard || inside_tik)
	{
	 if (!tb) break;
	 ta = token_malloc();
	 ta->flink = cl;
	 cl = ta;
	}
       else
	{ /* finished parameter */
	 if (!tb) { too_much++; break; }
	 ps = STRUCT_MALLOC(keyword_symbol);
	 ps->symb.name = tb->constr;
	 ps->toks = cl;
	 tb = tb->flink;
	 enter_symbol (p_tab,ps);
	 cl = 0;
	}
       break;
      case '{':
       if (tb)
	{
         int toktyp;
         do
	  {
 	   toktyp = active_stream->tok.typ;
	   ta = token_malloc ();
	   ta->flink = cl;
	   cl = ta;
	   next_tok();
	  }
 	 while (active_stream->tok.typ != TOK_EOF && toktyp != '}');
	}
       else
	{
         int toktyp;
         do
	  {
 	   toktyp = active_stream->tok.typ;
	   next_tok();
	  }
 	 while (active_stream->tok.typ != TOK_EOF && toktyp != '}');
	}
       continue; /* skip next_tok() call at bottom */
      case '(':
       pard++;
       if (!tb) break;
       ta = token_malloc();
       ta->flink = cl;
       cl = ta;
       break;
      case TOK_EOF:
       {
	CPPERROR (ACTIVE_TOK,"EOF in middle of macro parameter list");
	while (cl) { struct cpp_token *next = cl->flink; free (cl); cl=next;}
	return p_tab;
       }
      case ')':
       if (pard || inside_tik)
	{
	 pard--;
	 if (!tb) break;
	 ta = token_malloc();
	 ta->flink = cl;
	 cl = ta;
	}
       else
	{
	 if (tb)
  	  {
	   ps = STRUCT_MALLOC(keyword_symbol);
	   ps->symb.name = tb->constr;
	   ps->toks = cl;
	   tb = tb->flink;
	   enter_symbol (p_tab,ps);
  	   if (tb)
  	    { /* too few parameters - issue error message */
	     char msg[100];
  	     int i;
  	     for (i = ds->no_of_pars; tb; --i, tb=tb->flink);
	     sprintf (msg,"<%s> macro arg count, is: %d, should be: %d",
	     ds->symb.name,i,ds->no_of_pars);
	     CPPERROR(ACTIVE_TOK,msg);
     	    }
	  }
	 else
	  { /* too many parameters - issue error message */
	   char msg[100];
	   too_much++;
	   sprintf (msg,"<%s> macro arg count, is: %d, should be: %d",
	   ds->symb.name, ds->no_of_pars + too_much, ds->no_of_pars);
	   CPPERROR(ACTIVE_TOK,msg);
	  }
	 return p_tab;
	}
       break;
      default:
       if (!tb) break;
       ta = token_malloc();
       ta->flink = cl;
       cl = ta;
       break;
     }
    next_tok();
   }
#ifndef __STDC__
  return p_tab; /* never executed */
#endif
 } /* read_parameter_list */

static void free_param (s)
 struct keyword_symbol *s;
 {
  struct cpp_token *list = s->toks;
  while (list) { struct cpp_token *t = list->flink; free (list); list = t; }
  free (s);
 } /* free_param */

static int cpp_handle_id ()
 {
  struct cpp_token *hopper=0,*hopper_tail=0;
  struct define_symbol *ds;
  struct cpp_token *tt,*ta,*tb;
  symtab_ptr p_tab;
  struct keyword_symbol *ps;
  struct symbol *ods;
  struct cpp_stream saved_stream;

  ods = lookup_symbol(active_stream->omdef_table,active_stream->yytext);
  if (ods) { cpp_handle_omdef ((struct om_macro *)ods); return (0); }

  ds = (struct define_symbol *)
   lookup_symbol(active_stream->define_table,active_stream->yytext);

  if (!ds) return 1;

  if (ds->no_of_pars < 0) return (do_specialdef(ds->no_of_pars));

  saved_stream = *active_stream;
  tt = token_malloc();
  p_tab = read_parameter_list (ds);
  if (!p_tab)
   {
    /*
    * This means that the ident matches a #define name but the definition has
    * arguments and this ident was not followed by an argument list.
    */
    *active_stream = saved_stream;
    return 1;
   }

  /* process define symbols now */

  for (ta = ds->define_tokens; ta; ta = ta->flink)
   {
    if (ta->typ != TOK_ID)
     add_to_token_list (&hopper,&hopper_tail,cpp_dupe_tok(ta,tt));
    else
     {
      ps = (struct keyword_symbol *)lookup_symbol(p_tab,ta->constr);
      if (ps)
       {
	tb = ta->flink;
	if ((tb)&&(tb->typ=='#'))
	 {
	  ta = tb;
	  active_stream->yylen =
	   token_cat(ps->toks,active_stream->yytext,YYTEXT_SIZE);
	  active_stream->tok.typ = TOK_STRING_CONSTANT;
	  tb = token_malloc();
	  add_to_token_list (&hopper,&hopper_tail,cpp_dupe_tok(tb,tt));
	  free (tb);
	 }
	else
	 {
	  tb = ps->toks;
	  while (tb)
	   {
	    add_to_token_list (&hopper,&hopper_tail,cpp_dupe_tok(tb,tt));
	    tb = tb->flink;
	   }
	 }
       }
      else
       add_to_token_list (&hopper,&hopper_tail,cpp_dupe_tok(ta,tt));
     }
   }
  delete_symbol_table (p_tab,free_param);
  ta = hopper;
  while (ta)
   {
    if (ta->typ == TOK_CONCAT)
     do_con_cat (&ta,&hopper);
    else
     ta = ta->flink;
   }
  ta = hopper;
  while (ta)
   {
    struct cpp_token *tb;
    tb = ta->flink;
    luther_unget_tok (ta);
    ta = tb;
   }
  free (tt);
  return (0);
 } /* cpp_handle_id */


void cpp_get_tok ()
 {

  while (1)
   {
    luther_get_tok ();
    switch (active_stream->tok.typ)
     {
      case TOK_POUND:
/*
       if (active_stream->tok.pol!=1) return;
*/
       cpp_do_inst ();
       break;

      case TOK_NULL :
      case TOK_NEW_LINE :
      case TOK_BACKLASH_NL :
       break;

      case TOK_EOF :
       {
	struct ifstack_struct *ifs,*tt;
	ifs = active_stream->ifstack;
	while (ifs)
	 {
	  CPPERROR(ACTIVE_TOK,"Expected #endif -- got end_of_file");
	  tt = ifs;
	  ifs = ifs->next;
	  free (tt);
	 }
       }
       return;

      case TOK_ID :
       if (active_stream->ifstack && active_stream->ifstack->a > 0) break;
       if (cpp_handle_id()) return;
       break;

      default:
       if (active_stream->ifstack && active_stream->ifstack->a > 0) break;
       return;
     }
   }
 } /* cpp_get_tok */


void cpp_open (a)
char *a;
 {
  char *final_file;
  struct cpp_token *null_token=0;

  if (!strcmp(a,"stdin"))
   {
    luther_open (a);
    return;
   }
  final_file = find_file ('\"',a,"./bilbo");
  if (final_file)
   {
    if (cpp_check_file(final_file))
     luther_open (final_file);
   }
  else
   {
    sprintf (msg,"file %s not found",a);
    CPPERROR (null_token,msg);
   }
 } /* cpp_open */


void cpp_unget_tok (a)
struct cpp_token *a;
 {
  fio_push_rec ((int *)a);
 } /* cpp_unget_tok */


static void load_special_define(name,flag)
char *name;
int flag;
 {
  struct define_symbol *ds;

  ds = STRUCT_MALLOC(define_symbol);
  ds->symb.name = (char *)string_malloc(name);
  ds->no_of_pars = flag;
  ds->parametric = 0;
  ds->parameters = 0;
  ds->define_tokens = 0;
  enter_symbol (active_stream->define_table,ds);
 } /* load_special_define */


static void  load_int_define(name,value)
char *name;
int value;
 {
  struct define_symbol *ds;

  ds = STRUCT_MALLOC(define_symbol);
  ds->symb.name = (char *)string_malloc(name);
  ds->no_of_pars = 0;
  ds->parametric = 0;
  ds->parameters = 0;
  sprintf (active_stream->yytext,"%d",value);
  active_stream->yylen=strlen(active_stream->yytext);
  active_stream->tok.typ = TOK_INT_CONSTANT;
  active_stream->tok.body.intconst = value;
  ds->define_tokens = token_malloc();
  ds->define_tokens->flink = 0;
  enter_symbol (active_stream->define_table,ds);
 } /* load_int_define */


static void cpp_specialdefs()
 {
  load_special_define ("__LINE__",-1);
  load_special_define ("__FILE__",-2);
  load_special_define ("__DATE__",-3);
  load_special_define ("__TIME__",-4);
  load_int_define ("__STDC__", 1);
#if defined(CLIX)
  load_int_define ("clipper", 1);
  load_int_define ("__clipper__", 1);
#elif defined(INTEL)
  load_int_define ("sun", 1);
  load_int_define ("__sun__", 1);
  load_int_define ("i386", 1);
  load_int_define ("__i386__", 1);
#elif defined(SUNOS)
  load_int_define ("sun", 1);
  load_int_define ("__sun__", 1);
  load_int_define ("sparc", 1);
  load_int_define ("__sparc__", 1);
#elif defined(IRIX)
  load_int_define ("mips", 1);
  load_int_define ("__mips__", 1);
  load_int_define ("__mips", 1);
#elif defined(NT)
#if defined(_M_IX86)
  load_int_define ("_M_IX86", _M_IX86);
  load_int_define ("i386", 1);
#endif
#else
#error Unknown OS
#endif
 } /* cpp_specialdefs */


static void define_switch (s)
char *s;
 {
  char *sp;
  struct cpp_token *dt=0;
  struct cpp_token *d=0;
  struct define_symbol *ds;

#ifdef DEBUG
  printf ("define_switch %s\n", s);
#endif
  sp = s;
  luther_tok_from_string (&sp);
  if (active_stream->tok.typ != TOK_ID)
   {
    fprintf (stderr,"cpp error: syntax error in -D switch\n");
    return;
   }
  ds = STRUCT_MALLOC(define_symbol);
  ds->no_of_pars = 0;
  ds->parametric = 0;
  ds->parameters = 0;
  ds->define_tokens = 0;
  ds->symb.next = 0;
  ds->symb.level = 0;
  ds->symb.hash_value = 0;
  ds->symb.name = (char *) string_malloc (active_stream->yytext);
  luther_tok_from_string (&sp);
  if (active_stream->tok.typ == '=')
   {
    while (1)
     {
      luther_tok_from_string (&sp);
      if (active_stream->tok.typ == TOK_EOF) break;
      if (dt)
       { d->flink = token_malloc(); d = d->flink; }
      else
       { d = dt = token_malloc(); }
     }
   }
  ds->define_tokens = dt;
  if (active_stream->tok.typ != TOK_EOF)
   {
    fprintf (stderr,"cpp error: syntax error in -D switch\n");
    return;
   }
  enter_symbol (active_stream->define_table,ds);
 } /* define_switch */


static void undef_switch (s)
char *s;
 {
  struct define_symbol *ds;

  ds = (struct define_symbol *) lookup_symbol (active_stream->define_table,s);
  if (ds)
   {
    struct cpp_token *t,*t1;

    remove_symbol (active_stream->define_table,ds);
    t = ds->define_tokens;
    while (t) { t1 = t->flink; free (t); t=t1; }
    free (ds->symb.name);
    free (ds);
   }
  else
   {
    fprintf (stderr,"cpp error: -U switch: %s is not defined.",s);
   }
 } /* undef_switch */


void cpp_init_stream(owner)
 char *owner; /* pointer to something */
 {
  long i;
  char *the_time;
  char **sw, *path;

  if (cpp_date[0]==0)
   {
    extern char *ctime();

    i = time((long *)0);
    the_time=ctime(&i);
    cpp_date[0]='\"';
    strncpy (cpp_date+1,the_time+4,7);
    strncpy (cpp_date+8,the_time+20,4);
    cpp_date[12]='\"';
    cpp_date[13]=0;
    cpp_time[0]='\"';
    strncpy (cpp_time+1,the_time+11,8);
    cpp_time[9]='\"';
    cpp_time[10]=0;
   }
  active_stream = STRUCT_MALLOC(cpp_stream);
  active_stream->assertion_table = (symtab_ptr)
   new_usagetab (117,(cpp_options & CPP_DEBUG) ? stderr : 0, owner);
  active_stream->define_table = (symtab_ptr)
   new_usagetab (117,(cpp_options & CPP_DEBUG) ? stderr : 0, owner);
  active_stream->omdef_table = (symtab_ptr)
   new_usagetab (117,(cpp_options & CPP_DEBUG) ? stderr : 0, owner);
  active_stream->file_table = (symtab_ptr)
   new_usagetab (17, (cpp_options & CPP_DEBUG) ? stderr : 0, owner);
  active_stream->mcs=0;
  active_stream->mrs=0;
  active_stream->filer_stack=0;
  active_stream->ifstack=0;

  cpp_specialdefs();

  for (sw = cpp_switches; path = *sw; sw++)
   if (*path++ == '-' && *path++ == 'D') define_switch(path);

  for (sw = cpp_switches; path = *sw; sw++)
   if (*path++ == '-' && *path++ == 'U') undef_switch(path);
 } /* cpp_init_stream */

static struct keyword_symbol keywords[]=
 {
  {{"assert"}	,process_assert},
  {{"define"}	,process_define},
  {{"undef"}	,process_undef},
  {{"include"}	,process_include},
  {{"if"}	,process_if},
  {{"elif"}	,process_elif},
  {{"else"}	,process_else},
  {{"endif"}	,process_endif},
  {{"ifdef"}	,process_ifdef},
  {{"ifndef"}	,process_ifndef},
  {{"line"}	,eat_line},
  {{"omdef"}	,(void (*)())process_omdef},
  {{"endomdef"}	,(void (*)())process_endomdef},
  {{"omerror"}	,process_omerror},
  {{"error"}	,process_error},
  {{"pragma"}	,process_pragma},
  {{"argsused"} ,process_argsused},
  {{0}		,0}
 };

void cpp_init (switches,opts, owner)
char **switches;
long opts;
char *owner; /* pointer to something */
 {
  int i;
  char *path;
  char **sw;

  keyword_table = new_basictab (11,(cpp_options & CPP_DEBUG) ? stderr: 0);
  cpp_switches = switches;
  cpp_options = opts;
  cpp_init_stream(owner);

  i=0;
  while (keywords[i].symb.name) enter_symbol (keyword_table,&keywords[i++]);

  /* initialize the search paths for files */

  for (sw = switches; path = *sw; sw++)
   {
    if (*path++ == '-')
     {
      switch (*path++)
       {
	case 'I':
	 ff_add(path); 
	 break;
/*
	case 'D':
	 define_switch(path);
	 break;
*/
       }
     }
   }

#if defined(SYSV) || defined(BSD)
#if defined(BSD) && defined (SUNOS)
#if defined(__STDC__)
  ff_add ("/usr/sunc/lang/SC1.0/ansi_include");
#endif
  ff_add ("/usr/5include");
#endif
  ff_add ("/usr/include");
#elif defined(NT)
  path = 0;
  while (path = getNextEnvIncludeDir())
	ff_add (path);
#else
#error Unknown OS
#endif
 } /* cpp_init */


void cpp_end()
 {
  delete_symbol_table (keyword_table,0);
  keyword_table = 0;
  free_everything();
 } /* cpp_end */
