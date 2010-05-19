%{
/* $Id: sql.y,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdpocket/parser / sql.y
 *
 * Description:
 *	Query grammer and lexical analyzer
 *
 * Dependencies:
 *	VDQyerr.h	error codes and messages
 *	vdpardef.h	VD_cnt_qry_* definitions for operators 
 *
 * Revision History:
 *	$Log: sql.y,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *					imported from GRNUC/query/parser
 *
 *	09/../94	adz,yz		modified for VDquery
 *
 *	01/13/95	tlb 		Rewrite lexical analyzer
 *					Revise grammer, add error productions
 *					Clean-up usage
 *      05/23/96        yzhu            added nident to handle cases in body
 *                                      	"p-1-1" 
 *                                              "-p-1-"
 * -------------------------------------------------------------------*/


/******************************************************************
 * Parser: qy_parser
 *
 * Input
 *	The variable qy_ptr should be set to the query string, before
 *	calling the parser
 *
 * Return values
 *	1	query parsed, objects found
 *	0	query parsed, object not found
 *    < 0	syntax errors (defined in VDQyerr.h)
 *    The return value of a sequence of queries is the OR of all the
 *	queries, if no syntax errors are found.
 *
 * Error processing
 *	All syntax errors are reported.  However, some currently
 *	report multiple errors or return incorrect error messages.
 *	
 * Future Work 
 *	Fully integrate mutliple query processing into parser
 *	Currently class names are processed outside the parser on a
 *	query by query baisis. The class name data structure is converted
 *	into another external format.
 ******************************************************************/
#include "VDQYerr.h"			/* qy_parser error codes */

#define TRUE		1
#define FALSE		0


/*
 * Debugging conditional/flags
 */
/*#define LEXDEBUG	1		enable lexical analyzer debugging */
/*#define YYDEBUG	1		include parser debugging */
/*extern yydebug = 1; 			enable parser debugging */


/* Parser input */
char 		*qy_ptr; 	/* input query string */
static char 	*cur ; 		/* current position in the input */
static char 	*token_pos;	/* position of token found */
static char 	*cur_query ; 	/* start of current query */

%}
%union {
         char * pos;			/* token position */
	 struct tok {
         	int  	val;		/* value returned by query */
		char 	*pos;		/* token position */
		} q;
	 struct ident {
         	char   	id [IDENT_LEN+1];	/* identifier string */
		char 	*pos;			/* identifier position */
		} id;
       }

%token <id> IDENT
%token <pos> BIG_IDENT	/* error - identifier too long */
%token <pos> SELECT
%token <pos> WHERE
%token <pos> S_COLON
%token <pos> DASH
%token <pos> L_PAREN
%token <pos> R_PAREN

%type <q> init
%type <q> qy_list
%type <q> query
%type <q> select
%type <q> cl_list
%type <q> body
%type <q> cond
%type <q> expr
%type <id> nident

%left  <pos> OR 	/* lowest precedence */
%left  <pos> XOR
%left  <pos> AND
%left  <pos> NOT
%left  <q> OP 		/* highest precedence */

%%
init:			      {/* initialize parser */ 
				cur = qy_ptr; 
				cur_query = qy_ptr;
				VDQYlist_init (); }
	  qy_list 		
			      { /* return query value */
				return $2.val ; }
	;

qy_list:  
      	  query 	      { $$ = $1 ; } 
      	| query S_COLON       { $$ = $1 ; }

    	| qy_list S_COLON     { cur_query = cur; VDQYlist_init(); } 
	  query 		
			      { $$.val =  ($1.val < 0 ? $1.val : 
				    ($4.val < 0 ? $4.val : $1.val || $4.val)) ; 
			  	$$.pos = $1.pos;
			  	VDQYlist_init() ;}

	| error		      { /* general syntax error not caught by rules */
				$$.val = qy_error(QY_E_SYNTAX,token_pos ); }

	| query error	      { $$.val = qy_error(QY_E_EXTRA_SYMB,token_pos);}

	;

query:	  select body 	      { $$.val = $1.val < 0 ? $1.val : $2.val; 
				$$.pos = $1.pos; }
	| body error	      { $$.val = qy_error(QY_E_NO_SELECT,$1.pos);}
	| cl_list body error  { $$.val = qy_error (QY_E_NO_SELECT, $1.pos);}
	;

select:   SELECT cl_list      { $$.val = $2.val < 0 ? $2.val : TRUE ;  
				$$.pos = $1; }

	| SELECT SELECT error { $$.val = qy_error (QY_E_EXTRA_SELECT,$2);}
	| SELECT body error   { $$.val = qy_error (QY_E_NO_CLASS,$2.pos-1);}
	| SELECT DASH IDENT error 
			      { $$.val = qy_error (QY_E_NO_CLASS, $2-1); }
	;

cl_list:  IDENT 	      { $$.val = TRUE; $$.pos = $1.pos; 
					VDQYadd_class ( $1.id ); }
	| cl_list DASH IDENT  { $$ = $1; 
					VDQYadd_class ( $3.id ); }

	| DASH DASH IDENT error 
			      { $$.val = qy_error (QY_E_NO_CLASS, $1+1); }

	| BIG_IDENT error     { $$.val = qy_error (QY_E_IDENT_LEN, $1); }
	| cl_list DASH BIG_IDENT error	
			      { $$.val = qy_error (QY_E_IDENT_LEN, $3); }
	;

body :    /* empty */ 	      { $$.val = TRUE ; $$.pos = token_pos; }

	| cond 		      { $$ = $1 ; }

	| WHERE cond 	      { $$.val = $2.val; $$.pos = $1; }
	| WHERE error	      { $$.val = qy_error (QY_E_NO_EXPR,token_pos);}
	| WHERE WHERE error   { $$.val = qy_error (QY_E_EXTRA_WHERE,$2);}

	| body R_PAREN error  { $$.val = qy_error (QY_E_NO_L_PAREN,$1.pos);}
	;

cond:	  expr		      { $$ = $1; }

	| L_PAREN cond R_PAREN
			      { $$.val = $2.val; $$.pos = $1;}
	| L_PAREN cond error  { $$.val = qy_error (QY_E_NO_R_PAREN, 
								token_pos);}


	| cond AND cond	      { $$.val =  ($1.val < 0 ? $1.val :
					($3.val < 0 ? $3.val :
						($1.val && $3.val))); 
				$$.pos = $1.pos; }

	| cond OR cond	      { $$.val =  ($1.val < 0 ? $1.val :
					($3.val < 0 ? $3.val :
						($1.val || $3.val))); 
				$$.pos = $1.pos; }

	| NOT cond	      { $$.val = $2.val < 0 ? $2.val : !$2.val ; 
				$$.pos = $1; }

	| cond XOR cond	      { $$.val =  ($1.val < 0 ? $1.val :
					($3.val < 0 ? $3.val :
					(($1.val || $3.val) && 
						!($1.val && $3.val)))); 
				$$.pos = $1.pos; }

	| AND cond error      { $$.val = qy_error (QY_E_NO_EXPR, $1-1); }
	| OR cond error	      { $$.val = qy_error (QY_E_NO_EXPR, $1-1); }
	| XOR cond error      { $$.val = qy_error (QY_E_NO_EXPR, $1-1); }
	| L_PAREN R_PAREN error	
			      { $$.val = qy_error (QY_E_NO_EXPR, $1+1); }
	| L_PAREN OP error    { $$.val = qy_error (QY_E_NO_OPER1, $2.pos-1); }
	| OP R_PAREN error    { $$.val = qy_error (QY_E_NO_OPER2, $2-1); }

	| cond AND AND error  { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond AND OR error   { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond AND XOR error  { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}

	| cond OR AND error   { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond OR OR error    { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond OR XOR error   { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}

	| cond XOR AND error  { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond XOR OR error   { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}
	| cond XOR XOR error  { $$.val = qy_error (QY_E_EXTRA_LOG_OP,$3);}

	;

expr:	 nident OP nident   { $$.val = VDquery ($1.id, $2.val, $3.id); 
				$$.pos = $1.pos; }
	| nident OP OP error   { $$.val = qy_error (QY_E_EXTRA_REL_OP,$3);}
	| nident OP error      { $$.val = qy_error (QY_E_NO_OPER2,token_pos);}
	| OP nident error      { $$.val = qy_error (QY_E_NO_OPER1,$1.pos-1);}
	| BIG_IDENT OP error  { $$.val = qy_error (QY_E_IDENT_LEN, $1); }
	| nident OP BIG_IDENT error 
			      { $$.val = qy_error (QY_E_IDENT_LEN, $3); }

        ;

nident:	  IDENT                  { strcpy( $$.id, $1.id ); $$.pos = $1.pos;}
	 | nident DASH nident  { char temp[128];
               			  temp[0] = '\0';                  
				  strcpy( temp, $1.id );
				  strcat( temp, "-" );
				  strcat( temp, $3.id );
				  strcpy( $$.id, temp );
				  $$.pos =$1.pos; }
	 | DASH nident  	{ char temp[128];
               			  temp[0] = '\0';                  
				  strcpy( temp, "-");
				  strcat( temp, $2.id );
				  strcpy( $$.id, temp );
				  $$.pos =$1; }
	 | nident DASH 		{ char temp[128];
               			  temp[0] = '\0';                  
				  strcpy( temp, $1.id);
				  strcat( temp, "-");
				  strcpy( $$.id, temp );
				  $$.pos =$1.pos; }

%%
		/********   END  OF  GRAMMAR ********/
/******************************************************************
 * Lexical Analyzer
 *
 *   reserved characters:
 *	end of input:		'\0' or EOF
 *	white space:		space, tab, return, line feed
 *	punctuation: 		"( ) ; -"
 * 	relational operators:	"> >= < >= = !="
 *	logical operators	" ! & | @"
 *   words:
 *	keywords:		"where" "select"
 *	identifiers:		any other string which 
 *					does not contain the above chareacters 
 *					and is not a keyword
 ******************************************************************/
#include <ctype.h>
#include "vdpardef.h"		/* VD_cnt_qry_* defs */
#include <stdio.h>

/* token types
 * 	used for debugging printf's
 */
#define PUNCT 	1
#define REL_OP	2
#define LOG_OP	3


/* current token value */
static int	token;


/* lexical analyzer
 */
yylex ()
{
	int	i;

	/* skip white space, line extension */
  	while (isspace(*cur) || *cur == '\\')
		cur++;

	/* initialize */
	token = 0;		/* reset token to end of file */
	token_pos = cur;	/* set new token position */	

	/* Tokens, keywords
 	 * 	increment cur, skip char
	 */
	/* printf ("  switch: %c\n", *cur); */
	switch (*cur) {

	    /* ---- End of input ------ */
	    case '\0'  : return (0);
	    case  EOF  : return (0);

	    /* ---- Punctuation ------ */
	    case '('  : set_token (PUNCT, L_PAREN, 1); break;
	    case ')'  : set_token (PUNCT, R_PAREN, 1); break;
	    case '-'  : set_token (PUNCT, DASH,    1); break;
	    case ';'  : set_token (PUNCT, S_COLON, 1); break;

	    /* ---- Relational Operators ------ */
	    case '>'  : if ( *(cur+1) == '=' )
				rel_op (VD_cnt_qry_G_EQUAL, 2) ;
			else
				rel_op (VD_cnt_qry_G_THAN,  1) ;
			break;

	    case '<'  : if ( *(cur+1) == '=' )
				rel_op (VD_cnt_qry_L_EQUAL, 2) ;
			else
				rel_op (VD_cnt_qry_L_THAN,  1) ;
			break;

	    case '!'  : if (*(cur+1) == '=' )
				rel_op(VD_cnt_qry_N_EQUAL, 2) ;
			else
				set_token (LOG_OP, NOT, 1) ;
			break;

	    case '='  : rel_op (VD_cnt_qry_EQUAL, 1) ;
			break;

	    /* ---- Logical Operators ------ */
	    case '|'  : set_token (LOG_OP, OR,  1) ;  break;
	    case '&'  : set_token (LOG_OP, AND, 1) ; break;
	    case '@'  : set_token (LOG_OP, XOR, 1) ; break;
	}

	/* ---- Identifiers and Keywords------
	 * 	all other chars up to white space or reserved char
         */
	if (!token ) {
	  	for (i=0; !isspace(*cur) && !is_reserved(*cur) ; i++)
	       		yylval.id.id [i] = *cur++;
		yylval.id.id[i] = '\0';
		yylval.id.pos = token_pos;
	
		/* identifier too long */
		if ( i >= IDENT_LEN ) 
			set_token (BIG_IDENT, BIG_IDENT, 0);

		/* keywords */
		else if (!strcmp (yylval.id.id, "select"))
			set_token (SELECT, SELECT, 0);
		else if (!strcmp (yylval.id.id, "where")) 
			set_token (WHERE, WHERE, 0);
	
		/* identifier */
		else set_token (IDENT, IDENT, 0);
		}
	return (token);
}

/* function to set up relational operator tokens
 */
rel_op (value, len)
	int	value;		/* operator value returned */
	int	len;		/* length in chars */
{
	set_token (REL_OP, OP, len) ;
#ifdef LEXDEBUG
	printf ("\top value: %d\n", value);
#endif
	yylval.q.pos = token_pos;
	yylval.q.val = value;
	cur += len;
}

/* function to set up token for reserved characters 
 *	sets variable token
 */
set_token (type, tok_val, len)
	int 	type; 		/* token type */
	int	tok_val;	/* token returned */
	int	len;		/* length in chars */
{
#ifdef LEXDEBUG
	switch (type) {
		case PUNCT:
			printf ("\t\t%c\n", *cur);
			break;
		case REL_OP:
			printf ("\t\t%c%c", *cur, 
						(len == 2) ? *(cur+1) : ' ');
			break;
		case LOG_OP:
			printf ("\t\t%c\n", *cur);
			break;
		case SELECT:
			printf ("\tSELECT\n");
			break;
		case WHERE:
			printf ("\tWHERE\n");
			break;
		case BIG_IDENT:
			printf("\tBIG_IDENT \"%s\"\n", yylval.id.id);
			break;
		case IDENT:
			printf("\tIDENT \"%s\"\n", yylval.id.id);
			break;
	}
#endif
	token = tok_val;

	if (type != IDENT && type != REL_OP) {
		yylval.pos = token_pos;
		cur += len;
		}
}


/* function to check for characters used by:
 *	 punctuation, relational operators, logical operators, 
 *	null, EOF
 */
is_reserved (c)
	char 	c;	/* char to test */
{
	switch (c) {

	    /* ---- End of string ------ */
	    case '\0'  : return (TRUE);
	    case  EOF  : return (TRUE);

	    /* ---- Punctuation ------ */
	    case '('  : return(TRUE);
	    case ')'  : return(TRUE);
	    case '-'  : return(TRUE);
	    case ';'  : return(TRUE);

	    /* ---- Relational Operators ------ */
	    case '>'  : return(TRUE);
	    case '<'  : return(TRUE);
	    case '!'  : return(TRUE);
	    case '='  : return(TRUE);

	    /* ---- Logical Operators ------ */
	    case '|'  : return(TRUE);
	    case '&'  : return(TRUE);
	    case '@'  : return(TRUE);
	    }
	return FALSE;
}
/*****************************************************************r
 * Error handling routines
 ******************************************************************/

/* Redefine yyrestart to prevent restarting after errors */
yyrestart() 		{ /* printf("yyrestart\n"); */ }


/* Redefine yyerror keep from printing */
yyerror ( s ) char *s; 	{ }



/* return error message */
char *
qy_emsg (int err)
{
	switch (err) {
		case QY_E_SYNTAX : 	return QY_EMSG_SYNTAX	 ;
		case QY_E_IDENT_LEN : 	return QY_EMSG_IDENT_LEN ;
		case QY_E_NO_SELECT : 	return QY_EMSG_NO_SELECT ;
		case QY_E_NO_CLASS : 	return QY_EMSG_NO_CLASS	 ;
		case QY_E_NO_EXPR : 	return QY_EMSG_NO_EXPR	 ;
		case QY_E_NO_OPER1 : 	return QY_EMSG_NO_OPER1 ;
		case QY_E_NO_OPER2 : 	return QY_EMSG_NO_OPER2 ;
		case QY_E_NO_REL_OP: 	return QY_EMSG_NO_REL_OP ;
		case QY_E_NO_LOG_OP : 	return QY_EMSG_NO_LOG_OP;
		case QY_E_NO_R_PAREN : 	return QY_EMSG_NO_R_PAREN ;
		case QY_E_NO_L_PAREN : 	return QY_EMSG_NO_L_PAREN ;
		case QY_E_EXTRA_SELECT: return QY_EMSG_EXTRA_SELECT ;
		case QY_E_EXTRA_WHERE : return QY_EMSG_EXTRA_WHERE ;
		case QY_E_EXTRA_LOG_OP: return QY_EMSG_EXTRA_LOG_OP ;
		case QY_E_EXTRA_REL_OP: return QY_EMSG_EXTRA_REL_OP ;
		case QY_E_EXTRA_SYMB : 	return QY_EMSG_EXTRA_SYMB ;
	}
}

/* Error processing routine */
qy_error ( err, pos)
	int	err;
	char * 	pos;	/* position of token to highlight */
{
	int	i;
	char	buf[81];
	char *  start; 		/* start of line displayed */
	char *  end; 		/* end of query string */

	/* set yacc error flag, skip rest of input */
	yyerrflag = TRUE; 
	cur = qy_ptr + strlen(qy_ptr);
	yyclearin;

	printf ("\nVDQuery syntax error (%d): %s\n", err, qy_emsg(err));
	start = qy_ptr;

	/* print full lines without error */
	while (pos - start > 72) {
		strncpy (buf, start, 72);
		buf[72] = '\0';
		printf ("\t%s\n", buf);
		start += 72;
		}

	/* print line with error */
	strncpy (buf, start, 72);
	buf[72] = '\0';
	printf ("\t%s\n", buf);
	for (i=0; i < pos - start + 8 ; i++)
		putchar (' ');
	puts ("^");
	start += 72;

	/* print remaining full lines */
	end = qy_ptr + strlen (qy_ptr);
	while (end - start > 72) {
		strncpy (buf, start, 72);
		buf[72] = '\0';
		printf ("\t%s\n", buf);
		start += 72;
		}
	/* print last unfull line */
	if (end > start ) {
		strncpy (buf, start, 72);
		buf[72] = '\0';
		printf ("\t%s\n", buf);
		}

	return (err);
}


/******************************************************************
 * Class List Managment
 *
 *
 *  	FUTURE - change storage from simple buffer to an array of
 *		 pointers to strings as used in actual implementation
 *
 *****************************************************************/

static char cl_buffer[1024] = { 0 };
static int  buf_size = NULL, buf_index ;
static int	init = TRUE;		/* initialization flag */

VDQYlist_init ()
{
	/*
	 *  Increment init, so that the next call to VDQYadd_class will :
	 *  	re-initialize the list of classes AND
	 *	VDQYis_in_class_list will always succeed,
	 *		even if VDQYadd_class has not been not called,
	 */
	init = TRUE;
}


VDQYadd_class ( class_name )
	char *class_name	/* the name to be added			IN  */;
{
	int	dup, i;

    	/* initialize the class list	*/
  	if (init ) {
    		init = -1;
    		buf_index = NULL;
		init = FALSE;
  		}

	/* check for duplicates */
  	for (i = 0, dup = FALSE; !dup && i < buf_index; ) {
		dup = !strcmp (class_name, &(cl_buffer[i]));
      		i += strlen ( &cl_buffer [i] ) + 1;
		}

	/* add to list */
	if (!dup) {
  		strcpy ( &cl_buffer [buf_index], class_name );
  		buf_index += strlen ( class_name ) + 1;
		}

  	return TRUE;
}


VDQYis_in_class_list ( class_name )
{
 int i;
	/* printf("VDQYis_in_class_list\n");  */

  	if (init) return TRUE;

  	for (i = 0; i < buf_index; ) {
    		if(VDQYis_subclas(class_name,&cl_buffer [i]) )
      			return TRUE;
    		else
      			i += strlen ( &cl_buffer [i] ) + 1;
  		}
  	return FALSE;
}

VDQYgive_class_list ( int * size , char ** classes  )
{
  	if (init)  {
  		*size = 0 ;
  		*classes = NULL ;
		}
	else {
  		*size = buf_index ;
  		*classes = cl_buffer ;
		}
  	return TRUE;
}

