%{
/*

   -------------------------------------------------------------------------
   H.BEQUET : 12/03/1986 ( revised : 12/10/1986 )                  expl.l
   S.F : March-09-87 (install in IGE)

   This file is the lexical analyzer source for the parametric expressions.
   See expression.doc for a full documentation.
   ------------------------------------------------------------------------
*/
/*

Name
  expl.l

Description
   This file is the lexical analyzer source for the parametric expressions.
Notes


 */


#include "expression.h"
#include "expy.h"

/* extern 	int	NO_more_eval;
/* extern 	short	int	G_id_count;
/* extern 	char    **G_id_list;
/*  */
extern 	struct 	data_struct yyval,yylval;

/* a private version of input is needed */

char 	*input_stream /* keyboard line simulation */;
int  	input_index = -1;

/*===== to replace the getc ================================================*/
char 	my_getc ( yyin )
FILE *yyin;
{
  if ((input_index < 0) || (input_index == strlen ( input_stream )))
    return ( -1 );
  else
    return ( input_stream [input_index++] );
}
/*==========================================================================*/
#undef input
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr)\
                                         :my_getc(yyin))==10\
                                             ?(yylineno++,yytchar)\
                                             :yytchar)==EOF?0:yytchar)
/*==========================================================================*/
%}

DOTTED_NUMBER ((([0-9]+\.[0-9]+)|([0-9]+\.))|(\.[0-9]+))
EXP           ([eE][-+]?[0-9]+)
IDENTIF	      ([a-zA-Z_\.][a-zA-Z0-9_\']*)
IDENTIF2      ([\.a-zA-Z0-9!~_\'\/]*)
AIF           (=[ ]*if/[ \(])

%%
\[.*\]  ; /* considered as comment */
[\n] 	return ( 0 )          /* no return within an expression */;
[ \t]                         /* ignore tabs and white spaces */  ;
"<"     return ( yylval.type = LESS );
">"     return ( yylval.type = MORE );
"=="    return ( yylval.type = EQUAL );
"!="    return ( yylval.type = NOT_EQUAL );
"<="    return ( yylval.type = LESS_OR_EQUAL );
">="    return ( yylval.type = MORE_OR_EQUAL );
"="     return ( yylval.type = ASSIGN );

{AIF}   return ( yylval.type = ASSIF );

"|"     return ( yylval.type = OR );
"&"     return ( yylval.type = AND );

sin     return ( SIN );
cos     return ( COS );
abs	return ( ABS );
asin   	return ( ASIN );
acos   	return ( ACOS );
atan	return ( ATAN );
atan2	return ( ATAN2 );
exp	return ( EXP );
log	return ( LOG );
max	return ( MAX );
min	return ( MIN );
pow	return ( POW );
sqrt	return ( SQRT );
tan	return ( TAN );
ifinf	return ( IFINF );
ifsup	return ( IFSUP );
if	return ( IF );
then	return ( THEN );
else	return ( ELSE );
int	return ( INT );


\"[^\"\n]* 
	{
          if (yytext [yyleng - 1] == '\\')
          {
            char c1, c2;
  
            if (((c1 = input ()) == '\n') || ((c2 = input ()) == '\n'))
              printf ( "lex : line feed not allowed in strings\n" );
            else
            {
              if (c2 == '"')
              {
                char yy_text [80];
                strcpy ( yy_text, yytext );
                strcat ( yy_text, "\"" );
                assign ( yy_text, STRING, &yylval );
                return ( STRING );
              }
              else
              {
                unput ( c2 );
                unput ( c1 );
                yymore ();
              }
            }
          }
          else
          {
            /* take the '"' */
            if (input () == '"')
            {
              assign ( yytext, STRING, &yylval );
              return ( STRING );
            }
            else
              printf ( "lex : line feed not allowed in strings" );
          }
        }

[0-9]+ 	{ 
          assign ( yytext, REAL, &yylval );
          return ( REAL );
        }

[0-9]+{EXP} |
{DOTTED_NUMBER}{EXP}? 
	{ 
          assign ( yytext, REAL, &yylval );
          return ( REAL );
        }


(\:{IDENTIF2})*(\:{IDENTIF}) | 
{IDENTIF} | 
(\\[0-9]+) |
(\\-[0-9]+) | 
(\${IDENTIF2}(\:{IDENTIF2})*(\:{IDENTIF}))   
	{
            yylval.type = STRING;
            strcpy(yylval.data.string, yytext);
            return ( NUM_IDENT );
	}

.	return ( *yytext ); 


%%
yywrap()
{

/*|jla 29/11/90 */

/* In certain case (example xx = .) when the evaluation of an expression fails,
   the evaluataion of the following expression fails also
*/ 
  yysptr = yysbuf;
  return(1);
}

/*------------------------------------------------------------------
   the next procedure is used to assign a value into the union 
 -------------------------------------------------------------------*/
int assign ( text, type, dat )
         char *text;
         int type;
         struct data_struct *dat;
{
  switch ( type )
  {
  case REAL : 
    dat->type = REAL;
    sscanf ( text, "%lf", &(dat->data.real) );
    break;

  case STRING : 
    {
      int i, j;

      dat->type = STRING;
      for (i = 1, j = 0; i < strlen ( text ); i++)
        if (text [i] != '\\')
          /* normal character */
          dat->data.string [j++] = text [i];
        else
          /* escape character */
          switch (text [i + 1])
          {
          case '"': 
            dat->data.string [j++] = text [++i];
            break;
          default : 
            dat->data.string [j++] = ' ';
            i++;
          }
      dat->data.string [j] = '\0';
      break;
    }
  default : 
    printf ( "illegal data type\n" );
  }

  return ( 1 );
}

/* -------------------------------------------------------------------------*/
display ( dat )
          struct data_struct dat;
/* this procedure is used to display a data structure according to its type */
{
  switch (dat.type)
  {
  case REAL : 
    printf ( "%lf\n", dat.data.real );
    break;
  case BOOLEAN : 
    printf ( "%d\n", dat.data.boolean );
    break;
  case STRING : 
    printf ( "%s\n", dat.data.string );
    break;
  default :
     printf ( "display : unknown data type\n" );
  }

  return ( 1 );
}


