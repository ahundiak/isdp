#include <stddef.h>
#include "mallocdbg.h"
#include "cpp.h"


struct cpp_token *token_malloc()
 {
  struct cpp_token *tt;

  tt = (struct cpp_token *)
    malloc((int)offsetof(struct cpp_token, constr) + active_stream->yylen + 1);
    /*malloc(sizeof(struct cpp_token) + active_stream->yylen);*/
  tt->typ = active_stream->tok.typ;
  tt->filename = active_stream->tok.filename;
  tt->line_no = active_stream->tok.line_no;
  tt->pol = active_stream->tok.pol;
  strcpy(tt->constr,active_stream->yytext);
  tt->flink = 0;
  tt->blink = 0;
  return (tt);
 }


void token_unpack(tt)
struct cpp_token *tt;
 {
  extern int luther_char_value();

  active_stream->tok.typ = tt->typ;
  active_stream->tok.filename = tt->filename;
  active_stream->tok.line_no = tt->line_no;
  active_stream->tok.pol = tt->pol;
  switch (tt->typ)
   {
    case TOK_FLOAT_CONSTANT :
     sscanf (tt->constr, "%lf", &active_stream->tok.body.flconst);
     break;
    case TOK_INT_CONSTANT :
     sscanf (tt->constr, "%d", &active_stream->tok.body.intconst);
     break;
    case TOK_CHAR_CONSTANT :
     active_stream->tok.body.charconst = tt->constr[0];
     break;
    case TOK_WCHAR_CONSTANT :
     active_stream->tok.body.wcharconst = (wchar_t)
                                         luther_char_value(&tt->constr[1]);
     break;
   }
  strcpy (active_stream->yytext,tt->constr);
  active_stream->yylen = strlen(tt->constr);
 }


struct cpp_token *cpp_dupe_tok (tt,tm)
struct cpp_token *tt;
struct cpp_token *tm;
 {
  struct cpp_token *ta;
  int s;

  s = sizeof(struct cpp_token)+strlen(tt->constr);
  ta = (struct cpp_token *) malloc(s);
  *ta = *tt;
  strcpy (ta->constr,tt->constr);
  if (tm)
   {
    ta->line_no = tm->line_no;
    ta->filename = tm->filename;
    ta->pol = tm->pol;
   }
  return (ta);
 }
