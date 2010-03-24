/* -------------------------yacc support----------------------------- */
#include <sli.h>

extern FILE	* yyin;

/* -------------------------yyerror---------------------------------- */
yyerror ( str )
  char	* str;
{
  fprintf ( stderr, (char *) find_msg ( "msg_yyerror" ),
      file_name, line_num, char_num, str );
  fputc ( '\n', stderr );
  ++ errors;
}

/* -------------------------yyincl----------------------------------- */
yyincl ()
{
/*****
  yyin_save = yyin;
  line_num_save = line_num;
  char_num_save = char_num;
*****/
  line_num = 1;
  char_num = 0;
  yyin = fopen ( "whatever", "r" );
} /* yyincl */

/* -------------------------yywrap----------------------------------- */
yywrap ()
{
/*****
  if ( yyin_save )
    {
      yyin = yyin_save;
      line_num = line_num_save;
      char_num = char_num_save;
      yyin_save = NULL;
      return 0;
    }
*****/
  return 1;
} /* yywrap */

/* -------------------------sliyywrap-------------------------------- */
sliyywrap ()
{
  return 1;
} /* sliyywrap */
