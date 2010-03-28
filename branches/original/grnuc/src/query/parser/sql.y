%{
#define PATH_MAX 256
#define YYDEBUG 1

  

extern QYstatus;
%}
%union {
         char   s [PATH_MAX];
         double d;
         int i;
         struct query
         {
           char op1 [PATH_MAX];
           int  oper;
           char op2 [PATH_MAX];
           int  v;
           int  done;
         } q;
       }

%token <s> NUMBER
%token <s> IDENT
%token <s> SELECT
%token <s> WHERE

%type <q> cond
%type <s> expr
%type <s> select
/*
%type <i> function
*/
%type <s> cl_list
%type <i> phrase
%type <i> stmnt

%left  <i> OR
%left  <i> AND
%left  <i> GT GE LT LE EQ NE
%left  <i> NOT

%token <i> EXIST

%%
phrase:	  stmnt { QYlist_done (); }
	;

stmnt:	  cond {
                 $$ = $1.done ? $1.v : query ( $1.op1, $1.oper, $1.op2 );
                 QYstatus = $$;
               }
	| select { $$ = QYstatus = 1; }
	| select cond {
                        $$ = $2.done ? $2.v : query ( $2.op1, $2.oper, $2.op2 );
                        QYstatus = $$;
                      }
	| select WHERE cond {
                              $$ = $3.done ? $3.v : query ( $3.op1, $3.oper, $3.op2 );
                              QYstatus = $$;
                            }
	;

select:   SELECT cl_list;
	;

cl_list:  IDENT { QYadd_class ( $1 ); }
	| cl_list ',' IDENT { QYadd_class ( $3 ); }
	; 

cond:	  '(' cond ')'	{ $$ = $2; }
       	| expr GT expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| expr GE expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| expr LT expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| expr LE expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| expr EQ expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| expr NE expr	{
                           strcpy ( $$.op1, $1 );
                           $$.oper = $2;
                           strcpy ( $$.op2, $3 );
                           $$.done = NULL;
                        }
	| cond AND cond	{
                          $$.v = ($1.done ? $1.v : query ( $1.op1, $1.oper, $1.op2 )) &&
                                 ($3.done ? $3.v : query ( $3.op1, $3.oper, $3.op2 ));
                          $$.done = 1;
                        }
	| cond OR cond	{
                          $$.v = ($1.done ? $1.v : query ( $1.op1, $1.oper, $1.op2 )) ||
                                 ($3.done ? $3.v : query ( $3.op1, $3.oper, $3.op2 ));
                          $$.done = 1;
                        }
	| NOT cond	{
                          $$.v = !($2.done ? $2.v : query ( $2.op1, $2.oper, $2.op2 ));
                          $$.done = 1;
                        }
	/*| function '(' expr ')' {
                                  strcpy ( $$.op1, $3 );
                                  $$.oper = $1;
                                  *$$.op2 = '\0';
                                  $$.done = NULL;
                                }*/
	;
/*
function: EXIST { $$ = $1; }
	;
	*/

expr:	  IDENT  { strcpy ( $$, $1 ); }
	| NUMBER { strcpy ( $$, $1 ); }
	;
%%
		/********   END  OF  GRAMMAR ********/


#include <stdio.h>
#include <ctype.h>

static char buffer [1024] = { NULL }, *ptr = buffer;

set_buffer ( buf )
             char *buf;
{
  strcpy ( buffer, buf );
  ptr = buffer;
}


yylex ()
{
  if (!*ptr)
    return -1;

  while (*ptr == ' ' || *ptr == '\t') ptr++;
  if (!*ptr) return 0;

  if (*ptr == '.' || isdigit(*ptr))
  {
    int i = 0;

    do
      yylval.s [i++] = *ptr++;
    while (*ptr != ' ' && *ptr && *ptr != '\t' && isdigit ( *ptr ));
    yylval.s [i++] = '\0';

    return NUMBER;
  }

  if (*ptr == '"')
  {
    int i;

    /* skip the "       */
    for (i = 0, ptr++;;)
      if (*ptr == '\\')
      {
        yylval.s [i++] = *++ptr;
        ptr++;
      }
      else
        if (*ptr == '"')
        {
          ptr++;
          break;
        }
        else
          yylval.s [i++] = *ptr++;

    return IDENT;
  }

  if (isalpha ( *ptr )) 
  {
    int i = 0;

    do
      yylval.s [i++] = *ptr++;
    while (isalpha ( *ptr ) || isdigit ( *ptr ));
    yylval.s [i++] = '\0';
    return !strcmp ( yylval.s, "select" ) ? SELECT :
           !strcmp ( yylval.s, "where" ) ? WHERE :
           !strcmp ( yylval.s, "exist" ) ? yylval.i = EXIST : IDENT;
  }

  switch (*ptr++)
  {
    case '>'  : yylval.i = *ptr == '=' ? ptr++, GE : GT;
                break;
    case '<'  : yylval.i = *ptr == '=' ? ptr++, LE : LT;
                break;
    case '='  : yylval.i = EQ;
                break;
    case '!'  : yylval.i = *ptr == '=' ? ptr++, NE : NOT;
                break;
    case '|'  : yylval.i = OR;
                break;
    case '&'  : yylval.i = AND;
                break;
    default   : yylval.i = *(ptr - 1);
  }

  return yylval.i;
}


yyrestart()
{
}


yyerror ( s )			/* report compile time error		*/
          char *s;
{
  yyrestart ();
}



static char *cl_buffer = NULL;
static int  buf_size = NULL, buf_index, init = 1;

QYlist_done ()
/*
   Increment init, so that the next call to QYadd_class will re-initialize
   the list of classes AND if QYadd_class is not called, QYis_in_class_list
   will always succeed.
*/
{
  init++;
}


QYadd_class ( class_name )
              char *class_name	/* the name to be added			IN  */;
{
  if (init >= 0)
  {
    /* initialize the class list	*/
    init = -1;
    buf_index = NULL;
    if (cl_buffer)
      cl_buffer = (char *) realloc ( cl_buffer, buf_size = 1024 );
    else
      cl_buffer = (char *) malloc ( buf_size = 1024 );
  }

  if ((buf_index + strlen ( class_name ) + 1) >= buf_size)
    cl_buffer = (char *) realloc ( cl_buffer, buf_size += 1024 );

  strcpy ( &cl_buffer [buf_index], class_name );
  buf_index += strlen ( class_name ) + 1;

  return 1;
}


QYis_in_class_list ( class_name )
{
  int i;

  if (init) return 1;
    
  for (i = 0; i < buf_index; )
    if (!strcmp ( class_name, &cl_buffer [i] ))
      return 1;
    else
      i += strlen ( &cl_buffer [i] ) + 1;

  return NULL;
}

