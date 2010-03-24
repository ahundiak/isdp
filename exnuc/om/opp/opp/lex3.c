/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* lex3.c - lexical analyzer using new cpp functions			*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* April 24, 1986							*/
/*									*/
/* This module replaces opplex.c 					*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#include <stdlib.h>
#include <stddef.h>
#include "lex3.h"
#include <cppout.h>
#include "tokensym.h"
#include "oppy.h"
#include "cpp.h"
#include "opp.h"
#include "k.h"
#include "ptoken.h" /* for struct pnode_token */
#include "lexinput.h"
#include "fio.h"

char *lex_filename;
int found_argsused = 0;

static symtab_ptr reserved_table;
extern symtab_ptr lex_table;

void lex_init_new_file ()
 {
 }

static void handle_undef()
{
   symbol_ptr s;
   int line;

   cpp_get_tok();
   line = active_stream->tok.line_no;
#if 0
   printf("handle_undef: tok=\"%s\"\n", active_stream->yytext);
#endif
   if (active_stream->tok.typ == TOK_ID)
   {
      if (s = lookup_symbol(active_class->sym_tab, active_stream->yytext))
         remove_symbol(active_class->sym_tab, s);
      else
      {
         printerr (0);
         fprintf (stderr, " \"%s\" not found in symbol table\n",
                active_stream->yytext);
         file_traceback ();
      }
   }
   else
   {
      printerr (1);
      fprintf (stderr, " expected identifier after %%undef got \"%s\"\n",
             active_stream->yytext);
      file_traceback ();
   }

   /*
   	clear tokens to the end of the line
   */

   do 
      cpp_get_tok(); 
   while (active_stream->tok.line_no == line &&
          active_stream->tok.typ != TOK_EOF);
   return;
}

void process_percent()
 {
  int line;
  int not_safe = 0;

  cpp_get_tok();
  line = active_stream->tok.line_no;
  if (active_stream->tok.typ!=TOK_ID ||
      ((not_safe = strcmp(active_stream->yytext, "safe"))
	 && strcmp(active_stream->yytext, "undef")))
   {
    printerr (1);
    fprintf (stderr, " unexpected opp control line \"%%%s\"\n",
               active_stream->yytext);
    file_traceback ();
    return;
   }

  if (not_safe)
  {
#if 0
     printf("process_percent: handle_undef\n");
#endif
     handle_undef();
     return;
  }

  if (!oppout)
   {
    printerr (1);
    fprintf (stderr," %%safe is not allowed in a specification file.\n");
    fprintf (stderr," - ignored while processing %s.S\n", active_class->name);
    file_traceback ();
   }

  do cpp_get_tok (); while (active_stream->tok.line_no == line);
   
  while (active_stream->tok.typ != TOK_EOF &&
          (active_stream->tok.typ != '%' || active_stream->tok.pol != 1))
   {
    if (oppout)
     {
      while (line < active_stream->tok.line_no)
       { ++line; ++cur_out_line; putc ('\n', oppout); }
      fprintf (oppout, "%s ", active_stream->yytext);
     }
    else
     line = active_stream->tok.line_no;
    cpp_get_tok ();
   }
  if (oppout)
   while (line < active_stream->tok.line_no)
    { ++line; ++cur_out_line; putc ('\n', oppout); }
  else
   line = active_stream->tok.line_no;
  if (active_stream->tok.typ == TOK_EOF)
   {
    int tmp = active_stream->tok.line_no;
    active_stream->tok.line_no = line;
    printerr (1);
    active_stream->tok.line_no = tmp;
    fprintf (stderr, " matching %endsafe not found.\n");
    file_traceback ();
    return ;
   }
  cpp_get_tok (); /* get word following '%' */
  if (active_stream->tok.typ != TOK_ID)
   {
    printerr (1);
    fprintf (stderr, "keyword expected after '%' in column 1\n");
    file_traceback ();
    return ;
   }
  if (!strcmp ("endsafe", active_stream->yytext))
   {
#if 0
    int line = active_stream->tok.line_no;
    do cpp_get_tok (); while (active_stream->tok.line_no == line);
#else
    cpp_get_tok ();
#endif
    return ;
   }
  else
   {
    printerr (1);
    fprintf (stderr, " unexpected opp control line \"%%%s\"\n"
              , active_stream->yytext);
    file_traceback();
    return ;
   }
 } /* process_percent */

static int get_percent_token()
/*
   Converts all the tokens in between %safe and %endsafe into
   one token.  This allows a safe statements to be entered in the parse
   tree.
*/
 {
  int line, prev_line, len;
  char *tok_string = 0;
  struct pnode_token *p_tok;
  struct pnode_token save;
  int not_safe = 0;
  
  cpp_get_tok();
  line = active_stream->tok.line_no;
  if (active_stream->tok.typ!=TOK_ID ||
      ((not_safe = strcmp(active_stream->yytext, "safe"))
	 && strcmp(active_stream->yytext, "undef")))
   {
    printerr (1);
    fprintf (stderr, " unexpected opp control line \"%%%s\"\n",
               active_stream->yytext);
    file_traceback ();
    return 0;
   }

  if (not_safe)
  {
     handle_undef();
     return 0;
  }

  if (!oppout)
   {
    printerr (1);
    fprintf (stderr," %%safe is not allowed in a specification file.\n");
    fprintf (stderr," - ignored while processing %s.S\n", active_class->name);
    file_traceback ();
   }

  cpp_get_tok (); 
   
  save.filename = active_stream->tok.filename;
  save.line_no  = prev_line = active_stream->tok.line_no;
  save.pol      = active_stream->tok.pol;
  
  while (active_stream->tok.typ != TOK_EOF &&
          (active_stream->tok.typ != '%' || active_stream->tok.pol != 1))
   {
    if (oppout)
     {
      line = active_stream->tok.line_no;
      if (! tok_string)
       {
        len = active_stream->yylen +	/* token length */
              1;			/* null terminator */
        if (NULL == (tok_string = (char *)calloc(len, 1) ))
         {
          printerr (1);
          fprintf (stderr, " unable to calloc %d bytes!", len);
          file_traceback ();
          return 0;
         }
       }/* if first iteration */
      else
       {
       	len = strlen(tok_string) + 	/* current length */
       	      active_stream->yylen +	/* token length */
       	      1 +			/* blank or newline */
       	      1;			/* null terminator */
       	if (NULL == (tok_string = (char *) realloc(tok_string, len) ))
         {
          printerr (1);
          fprintf (stderr, " unable to realloc %d bytes!",
                   len);
          file_traceback ();
          return 0;
         }
        if (line != prev_line)
         {
          prev_line = line;
          strcat(tok_string, "\n");
         }
        else
       	 strcat(tok_string, " ");
       }/* else not first iteration */
      strcat(tok_string, active_stream->yytext);
     }
    cpp_get_tok ();
   }
  line = active_stream->tok.line_no;
  if (active_stream->tok.typ == TOK_EOF)
   {
    int tmp = active_stream->tok.line_no;
    active_stream->tok.line_no = line;
    printerr (1);
    active_stream->tok.line_no = tmp;
    fprintf (stderr, " matching %endsafe not found.\n");
    file_traceback ();
    return 0;
   }
  cpp_get_tok (); /* get word following '%' */
  if (active_stream->tok.typ != TOK_ID)
   {
    printerr (1);
    fprintf (stderr, "keyword expected after '%' in column 1\n");
    file_traceback ();
    return 0;
   }
  if (!strcmp ("endsafe", active_stream->yytext))
   {
    /*  Set up token to be returned.  */
    
    p_tok = (struct pnode_token *)
     malloc((int)offsetof(struct pnode_token, constr) + strlen(tok_string) + 1);
    p_tok->typ = SAFEBLOCK;
    p_tok->filename = save.filename;
    p_tok->line_no = save.line_no;
    p_tok->pol = save.pol;
    strcpy(p_tok->constr, tok_string);
     
    yylval.i = (int)p_tok;
    return (p_tok->typ);
   }
  else
   {
    printerr (1);
    fprintf (stderr, " unexpected opp control line \"%%%s\"\n"
              , active_stream->yytext);
    file_traceback();
    return 0;
   }
 } /* get_percent_token */

int yylex ()
 {
  struct pnode_token *ta;
  int tok_val = 0;
  static int tag_table_selected_next = 0;
  int tag_table_selected = tag_table_selected_next;
  tag_table_selected_next = 0;

  cpp_get_tok ();
#ifdef DEBUG
  printf ("lex %4d, \"%s\"\n", active_stream->tok.typ, active_stream->yytext);
#endif
 
  if (active_stream->tok.typ == TOK_ARGSUSED)
   {
    found_argsused = 1;
    cpp_get_tok ();
   }

  lex_filename = active_stream->tok.filename;

  if (! building_ptree)
   {
    while (active_stream->tok.typ == '%' 
          && active_stream->tok.pol == 1) process_percent ();
    if (active_stream->tok.typ == TOK_ARGSUSED)
     {
      found_argsused = 1;
      cpp_get_tok ();
     }
   }
  else
   if (active_stream->tok.typ == '%' && active_stream->tok.pol == 1)
    return (get_percent_token());

  switch (active_stream->tok.typ)
   {
    default :			tok_val = active_stream->tok.typ;	break;
    case TOK_POINTER :		tok_val = POINTER; 		break;
    case TOK_PLUS_PLUS :	tok_val = PLUS_PLUS;		break;
    case TOK_MINUS_MINUS :	tok_val = MINUS_MINUS;		break;
    case TOK_SHIFT_LEFT :	tok_val = LEFT_SHIFT;		break;
    case TOK_SHIFT_RIGHT :	tok_val = RIGHT_SHIFT;		break;
    case TOK_LESS_EQUAL :	tok_val = LEQ;			break;
    case TOK_GREATER_EQUAL :	tok_val = GEQ;			break;
    case TOK_EQUAL_EQUAL :	tok_val = EQ;			break;
    case TOK_NOT_EQUAL :	tok_val = NOT_EQ;		break;
    case TOK_AND_AND :		tok_val = AND_AND;		break;
    case TOK_OR_OR :		tok_val = OR_OR;		break;
    case TOK_PLUS_EQUAL :	tok_val = PLUS_EQUAL;		break;
    case TOK_MINUS_EQUAL :	tok_val = MINUS_EQUAL;		break;
    case TOK_TIMES_EQUAL :	tok_val = TIMES_EQUAL;		break;
    case TOK_DIV_EQUAL :	tok_val = DIV_EQUAL;		break;
    case TOK_MOD_EQUAL :	tok_val = MOD_EQUAL;		break;
    case TOK_RIGHT_SHIFT_EQUAL :tok_val = RSHIFT_EQUAL;		break;
    case TOK_LEFT_SHIFT_EQUAL :	tok_val = LSHIFT_EQUAL;		break;
    case TOK_AND_EQUAL :	tok_val = AND_EQUAL;		break;
    case TOK_HAT_EQUAL :	tok_val = XOR_EQUAL;		break;
    case TOK_OR_EQUAL :		tok_val = OR_EQUAL;		break;
    case TOK_SQOINTER :		tok_val = SQOINTER;		break;
    case TOK_ELLIPSIS :		tok_val = ELLIPSIS;		break;
    case TOK_ID :
     {
      register tokensym_ptr s;
      symtab_ptr stab;

      s = (tokensym_ptr)lookup_symbol (reserved_table, active_stream->yytext);

      if (s)
       {
	register int tok = s->tok;
        if (tok == STRUCT || tok == ENUM || tok == UNION || tok == CHANNEL)
         tag_table_selected_next = 1;
        yylval.sym = (identifier_ptr)s;
        tok_val = s->tok;
	break;
       }

      if (building_ptree)
       {
        s = (tokensym_ptr)lookup_symbol (lex_table, active_stream->yytext);
        if (s)
         {
	  tok_val = TYPEDEF_NAME;
          break;
         }
       }

      stab = tag_table_selected ? tag_table : sym_table;

      s = (tokensym_ptr)lookup_symbol (stab, active_stream->yytext);
      if (s)
       {
        yylval.sym = (identifier_ptr)s;
        tok_val = s->tok;
        break;
       }

      if (building_ptree)
       {
	tok_val = IDENTIFIER;
        break;
       }

      s = (tokensym_ptr)new_identifier (active_stream->yytext);
      enter_symbol (stab, s);
      tok_val = s->tok;

      yylval.sym = (identifier_ptr)s;
      break;
     }
    case TOK_STRING_CONSTANT :	tok_val = (STR_CONST);
    break;
    case TOK_CHAR_CONSTANT :
     yylval.i = (int)active_stream->tok.body.charconst;
     tok_val = (DEC_INT);
    break;
    case TOK_WCHAR_CONSTANT :
     if (sizeof(yylval.i) < sizeof(active_stream->tok.body.wcharconst))
      {
       printerr (0);
       fprintf (stderr, " value of wide char constant is being truncated\n");
       file_traceback ();
      }
     yylval.i = (int)active_stream->tok.body.wcharconst;
     tok_val = (DEC_INT);
    break;
    case TOK_INT_CONSTANT :
     yylval.i = active_stream->tok.body.intconst;
     tok_val = (DEC_INT);
    break;
    case TOK_FLOAT_CONSTANT :
     /*yylval.d = active_stream->tok.body.flconst;*/
     tok_val = (FLOAT_CONST);
    break;
    case TOK_NULL :
    case TOK_BACKLASH_NL :
     printerr (1);
     fprintf (stderr, " unexpected token TOK_NULL or TOK_BACKLASH_NL\n");
     file_traceback ();
     exit (1);
   } /* switch */
  if (building_ptree)
   {
    ta = pnode_token_malloc();
    ta->typ = tok_val;
    yylval.i = (int)ta;
   }
  return tok_val;
 } /* yylex */

void init_reserved_table()
 {
  static struct token_symbol knownsyms[] = 
  {
   {{"ME"},BIG_ME},
   {{"abs_ordered"},ABS_ORDERED},
   {{"auto"},AUTO},
   {{"break"},BREAK},
   {{"case"},CASE},
   {{"channel"},CHANNEL},
   {{"char"},CHAR},
   {{"continue"},CONTINUE},
   {{"const"}, CONST},
   {{"default"},DEFAULT},
   {{"do"},DO},
   {{"double"},DOUBLE},
   {{"else"},ELSE},
   {{"end"},END},
   {{"enum"},ENUM},
   {{"extern"},EXTERN},
   {{"float"},FLOAT},
   {{"for"},FOR},
   {{"from"},FROM},
   {{"goto"},GOTO},
   {{"if"},IF},
   {{"implementation"},IMPLEMENTATION},
   {{"import"},IMPORT},
   {{"increment"},INCREMENT},
   {{"inherit"},INHERIT},
   {{"initial"},INITIAL},
   {{"instance"},INSTANCE},
   {{"int"},INT},
   {{"is"},IS},
   {{"long"},LONG},
   {{"many_to_many"},MANY_TO_MANY},
   {{"many_to_one"},MANY_TO_ONE},
   {{"me"},ME},
   {{"message"},MESSAGE},
   {{"method"},METHOD},
   {{"not_taggable"},NOT_TAGGABLE},
   {{"of"},OF},
   {{"one_to_many"},ONE_TO_MANY},
   {{"one_to_one"},ONE_TO_ONE},
   {{"override"},OVERRIDE},
   {{"private"},PRIVATE},
   {{"querynomod"},NOMOD},
   {{"register"},REGISTER},
   {{"reject"},REJECT},
   {{"rel_ordered"},REL_ORDERED},
   {{"return"},RETURN},
   {{"short"},SHORT},
   {{"signed"},SIGNED},
   {{"sizeof"},SIZEOF},
   {{"specification"},SPECIFICATION},
   {{"static"},STATIC},
   {{"struct"},STRUCT},
   {{"switch"},SWITCH},
   {{"taggable"},TAGGABLE},
   {{"typedef"},TYPEDEF},
   {{"union"},UNION},
   {{"unsigned"},UNSIGNED},
   {{"variable"},VARIABLE},
   {{"void"},VOID},
   {{"volatile"},VOLATILE},
   {{"while"},WHILE},
   {{0},0}
  };
  register struct token_symbol *p;

  reserved_table = new_basictab (53, yydebug ? stdout : NULL);

  for (p = knownsyms; p->s.name; ++p) enter_symbol(reserved_table, p);
 } /* init_reserved_table */

