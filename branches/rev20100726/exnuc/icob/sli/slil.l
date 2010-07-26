%{
/*extern   char * calloc( );*/

#define YYLMAX	 515
#define _debug_lex(x)
#include "sli.h"
#include "../sli/y.tab.h"
#define RETURN(x) \
	if (! ignore && ! flush && ! arg_list) return x;\
	if ( arg_list ) strcat ( big_str, yytext );\
	sli_end ();

/*** RETURN1 is for things that potentially start  ***/
/***   new sections of the .sl file		***/
#define RETURN1(x) \
	if (! ignore && ! flush && ! arg_list) return x;\
	if (! ignore && ! arg_list && flush == 1 && flush_char == 0 )\
	  { flush = 0; return x;}\
	if ( arg_list ) strcat ( big_str, yytext );\
	sli_end ();
%}

%START ACTION_ENDIF
%%

[ \t\014]*	{
		  char_num += yyleng;
		  if ( arg_list ) strcat ( big_str, yytext );
		  sli_end ();
		}
\n		{
		  char_num = 0;
		  ++ line_num;
		  if ( arg_list ) strcat ( big_str, yytext );
		  sli_end ();
		}
"*/"		{
		  if ( ! ignore ) REJECT;
		  char_num += yyleng;
		  ignore = 0;
		  if ( arg_list ) strcat ( big_str, yytext );
		  sli_end ();
		}
"/*"		{
		  if ( ignore ) REJECT;
		  char_num += yyleng;
		  ignore = 1;
		  if ( arg_list ) strcat ( big_str, yytext );
		}
\"[^"]*		{
		  input ();
		  yytext [ yyleng ++ ] = '"';
		  yytext [ yyleng ] = 0;
		  char_num += yyleng;
		  strip_returns();
		  _debug_lex(fprintf(stderr," STRING %s, %d\n",yytext,yyleng);)
		  if (! ignore && ! flush && ! arg_list)
		    {
		      yylval.str = (char *) calloc ( 1, yyleng + 1 );
		      if ( ! yylval.str )
		        {
		          fprintf(stderr,
			    "slic: slil.l() -- No dynamic memory available 1\n\n");
		          exit(1);
		        }
		      strcpy ( yylval.str, yytext );
		    }
		  RETURN ( STRING )
		}
"("		{
		  char_num += yyleng;
		  if ( ! ignore )
		    {
		      if ( arg_list )
			{
			  ++ arg_list;
			  strcat ( big_str, yytext );
			}
		      else if ( ! flush )
			{
			  arg_list = 1;
			  strcpy ( big_str, yytext );
			  return yytext [0];
			}
		    }
		}
")"		{
		  char_num += yyleng;
		  if ( arg_list ) strcat ( big_str, yytext );
		  if ( ! ignore && ! flush )
		    {
		      if ( ! arg_list ) return yytext [0];
		      if ( -- arg_list == 0 ) return yytext [0];
		    }
		  sli_end ();
		}
"{"		{
		  char_num += yyleng;
		  if ( ! ignore )
		    {
		      if ( arg_list ) strcat ( big_str, yytext );
		      else if ( ! flush )
			{
			  flush = 1;
			  flush_char = yytext [0];
			  return yytext [0];
			}
		      else if ( flush_char == yytext [0] ) ++ flush;
		    }
		}
"}"		{
		  char_num += yyleng;
		  if ( ! ignore && ! arg_list )
		    {
		      if ( ! flush ) return yytext [0];
		      if ( flush_char == '{' )
			{
			  if ( -- flush <= 0 )
			    {
			      flush = 0;
			      flush_char = 0;
			      return yytext [0];
			    }
			}
		    }
		  if ( arg_list ) strcat ( big_str, yytext );
		  sli_end ();
		}
specification	{
		  char_num += yyleng;
		  yylval.i = SPECIFICATION;
		  RETURN1 ( SPECIFICATION )
		}
instance	{
		  char_num += yyleng;
		  yylval.i = INSTANCE;
		  RETURN1 ( INSTANCE )
		}
implementation	{
		  char_num += yyleng;
		  yylval.i = IMPLEMENTATION;
		  RETURN1 ( IMPLEMENTATION )
		}
state_table	{
		  char_num += yyleng;
		  yylval.i = STATE_TABLE;
		  RETURN1 ( STATE_TABLE );
		}
at		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," at\n");)
		  yylval.i = AT;
		  RETURN1 ( AT )
		}
state		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," state\n");)
		  yylval.i = STATE;
		  RETURN1 ( STATE )
		}
action		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," action\n");)
		  yylval.i = ACTION;
		  RETURN1 ( ACTION )
		}
^#[ \t]*ifdef/[ \t]+[A-Za-z@_][A-Za-z@_0-9]*[ \t\n]+action {
						/*** JAJ:01-22-89 ***/
			/* Only recognize this as an IFDEF if the   */
			/*   word "action" follows it		    */
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," #ifdef\n");)
		  yylval.i = IFDEF;
		  BEGIN ACTION_ENDIF;	/* now, recognize ENDIF by    */
					/*  enabling its "start cond" */
		  RETURN1 ( IFDEF );
		}
^#[ \t]*ifndef/[ \t]+[A-Za-z@_][A-Za-z@_0-9]*[ \t\n]+action {
						/*** JAJ:01-22-89 ***/
			/* Only recognize this as an IFNDEF if the  */
			/*   word "action" follows it		    */
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," #ifndef\n");)
		  yylval.i = IFNDEF;
		  BEGIN ACTION_ENDIF;	/* now, recognize ENDIF by    */
					/*  enabling its "start cond" */
		  RETURN1 ( IFNDEF );
		}
<ACTION_ENDIF>^#[ \t]*endif	{	/*** JAJ:01-22-89 ***/
			/* Only recognize ENDIF after an IFDEF */
			/*   or IFNDEF in the action section   */
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," #endif\n");)
		  yylval.i = ENDIF;
		  RETURN1 ( ENDIF );
		}
on		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," on\n");)
		  yylval.i = ON;
		  RETURN ( ON )
		}
or		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," or\n");)
		  yylval.i = OR;
		  RETURN ( OR )
		}
do		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," do\n");)
		  yylval.i = DO;
		  RETURN ( DO )
		}
=		{	/*** separated from "."-- JAJ:12-01-87 ***/
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," eq_op %s\n",yytext);)
		  yylval.i = EQ_OP;
		  RETURN ( EQ_OP )
		}
"."		{	/*** separated from "="-- JAJ:12-01-87 ***/
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," dot_op %s\n",yytext);)
		  yylval.i = DOT_OP;
		  RETURN ( DOT_OP )
		}
!=?		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," ne_op %s\n",yytext);)
		  yylval.i = NE_OP;
		  RETURN ( NE_OP )
		}
"<"		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," lt_op %s\n",yytext);)
		  yylval.i = LT_OP;
		  RETURN ( LT_OP )
		}
"<="		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," le_op %s\n",yytext);)
		  yylval.i = LE_OP;
		  RETURN ( LE_OP )
		}
">="		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," ge_op %s\n",yytext);)
		  yylval.i = GE_OP;
		  RETURN ( GE_OP )
		}
">"		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," gt_op %s\n",yytext);)
		  yylval.i = GT_OP;
		  RETURN ( GT_OP )
		}
[A-Za-z@_][A-Za-z@_0-9]*	{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," IDENT %s, %d\n",yytext,yyleng);)
		  if (! ignore && ! flush && ! arg_list)
		    {
		      yylval.str = (char*) calloc ( 1, yyleng + 1 );
		      if ( ! yylval.str )
		        {
		          fprintf(stderr,
			    "slic: slil.l() -- No dynamic memory available 2\n\n");
		          exit(1);
		        }
		      strcpy ( yylval.str, yytext );
		    }
		  RETURN ( IDENT )
		}
[0-9]+		{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," INT %s, %d\n",yytext,yyleng);)
		  if (! ignore && ! flush && ! arg_list)
		    {
		      yylval.str = (char*) calloc ( 1, yyleng + 1 );
		      if ( ! yylval.str )
		        {
		          fprintf(stderr,
			    "slic: slil.l() -- No dynamic memory available 3\n\n");
		          exit(1);
		        }
		      strcpy ( yylval.str, yytext );
		    }
		  RETURN ( INT )
		}
[0-9]+\.[0-9]*	{
		  char_num += yyleng;
		  _debug_lex(fprintf(stderr," REAL %s, %d\n",yytext,yyleng);)
		  if (! ignore && ! flush && ! arg_list)
		    {
		      yylval.str = (char*) calloc ( 1, yyleng + 1 );
		      if ( ! yylval.str )
		        {
		          fprintf(stderr,
			    "slic: slil.l() -- No dynamic memory available 4\n\n");
		          exit(1);
		        }
		      strcpy ( yylval.str, yytext );
		    }
		  RETURN ( REAL )
		}
.		{
		  char_num += yyleng;
		  /* catches anything else */
		  _debug_lex(
		      if ( yytext [0] > ' ' && yytext [0] <= '~' )
			fprintf( stderr, " ch %c\n", yytext [0]);
		      else
			fprintf( stderr, " ch %d\n", yytext [0]);)
		  if ( yytext [0] == EOF ) return 0;
		  RETURN ( yytext [0] )
		}

%%

strip_returns() /*** replaces all '\n' chars within "string"	***/
		/***   to single ' ' chars			***/
{
  int	ii;

  for ( ii = 0 ;  ii < yyleng ; ii++ )
    {
      if ( yytext[ii] == '\015' || yytext[ii] == '\012' )
	  yytext[ii] = ' ';
    }
}
