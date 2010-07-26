#include "mallocdbg.h"
#include <stdio.h>
#include "cpp.h"
#include "cpperr.h"

#define ABORT(A) { while (tb) {ta = tb->flink; free(tb); tb = ta; }\
	 cpp_stream_close(); active_stream = as; return (A); }

char **parental_units (filename)
char *filename;
 {
  struct cpp_stream *as;
  struct cpp_token *ta=0,*tb=0;
  int count=0;
  char **narray;

  as = active_stream;
  cpp_init_stream(0);
  cpp_open(filename);

  cpp_get_tok();
  if (strcmp(active_stream->yytext,"class"))
   {
    OMDEFERROR (ACT,"expected 'class'");
    ABORT (0);
   }
  cpp_get_tok();
  if (strcmp(active_stream->yytext,"specification"))
   {
    OMDEFERROR (ACT,"expected 'specification'");
    ABORT (0);
   }
  cpp_get_tok();
  if (active_stream->tok.typ != TOK_ID)
   {
    OMDEFERROR (ACT,"expected identifier ");
    ABORT (0);
   }
  cpp_get_tok();
  if (active_stream->tok.typ == '(')
   {
    int depth = 1;
    while (1)
     {
      cpp_get_tok();
      if (active_stream->tok.typ == '(')
       depth++;
      if (active_stream->tok.typ == ')')
       {
        depth--;
        if (!(depth)) break;
       }
      if (active_stream->tok.typ == TOK_EOF)
       {
        OMDEFERROR (ACT,"unexpected end of file");
        ABORT (0);
       }
     }
   }
  cpp_get_tok();
  if (strcmp(active_stream->yytext,"of"))
   {
    OMDEFERROR (ACT,"expected 'of'");
    ABORT (0);
   }
  while (1)
   {
    cpp_get_tok();
    if (active_stream->tok.typ == TOK_EOF)
     {
      OMDEFERROR (ACT,"unexpected end of file");
      ABORT (0);
     }
    if (active_stream->tok.typ != TOK_ID)
     {
      OMDEFERROR (ACT,"expected identifier");
      ABORT (0);
     }
    ta = token_malloc();
    ta->flink = tb;
    tb = ta;
    count++;
    cpp_get_tok();
    if (active_stream->tok.typ == ';')
     break;
    if (active_stream->tok.typ != ',')
     {
      OMDEFERROR (ACT,"expected ',' or ';'");
      ABORT (0);
     }
   }
  if (tb)
   {
    narray = (char * *) malloc (sizeof (char *) * (count + 1));
    narray[count--]=0;
    do
     {
      narray[count--] = (char *) string_malloc(tb->constr);
      ta = tb->flink;
      free (tb);
      tb = ta;
     }
    while (tb);
    ABORT (narray);
   }
  OMDEFERROR (ACT,"null parent list");
  ABORT (0);
 }
