/*
/* state language syntax for yacc
*/

%{
#include "sli.h"
#include "ode_export.h"
#define _debug_sliy(x)

extern char * find_msg();
extern char * strchr();

char * ifdef_name;	 /* "#ifdef  <name>" before action defs */
char * ifndef_name;	 /* "#ifndef <name>" before action defs */
char   endif_flag;	 /* 1-> "#endif"     after  action def  */
symbol * action_cur_sym; /* ptr to action def	       		*/

%}

%union
  {
    int	  	  i;
    char	* str;
  }

%token SPECIFICATION INSTANCE IMPLEMENTATION STATE_TABLE
%token STATE ACTION ON DO AT OR
%token EQ_OP NE_OP LT_OP LE_OP GE_OP GT_OP DOT_OP
%token <str> IDENT STRING INT REAL IFDEF IFNDEF ENDIF
/* must be last */
%token KEYWORD

%start sli_file
%%

sli_file : /* empty */
	| cmd_decls
		{
		  if ( sli_mandatory() )
		    /*** something necessary wasn't in the .sl file ***/
		    {
			YYABORT;
		    }
		}
	  si_decls sli_decls
	;
cmd_decls : cmd_dec
	| cmd_decls cmd_dec
	;
cmd_dec	: any any
		{
		  sli_find_word ( $<str>1 );
		  sli_declare ( $<str>2, word_val );
		}
	  modify
	;
any	: STRING
	| IDENT
	| INT
	| REAL
	;
modify	: /* empty */
	| modify ',' any
		{
		  sli_modifier ( $<str>3 );
		}
	;
si_decls : /* empty */
	| si_decls si_decl
	;
si_decl	: specify
	| instance
	| implement 
	| state_table
	;
specify	: SPECIFICATION
		{
		  sli_declare ( "specfication", $<i>1 );
		  sli_begin ();
		  flush = 1;
		}
	;
implement : IMPLEMENTATION
		{
		  sli_declare ( "implementation", $<i>1 );
		  sli_begin ();
		  flush = 1;
		}
	;
state_table : STATE_TABLE
		{
		  sli_declare ( "state_table", $<i>1 );
		  sli_begin ();
		  flush = 1;
		}
	;
instance : INSTANCE
		{
		  sli_declare ( "instance", $<i>1 );
		}
	  '{'
		{
		  sli_begin ();
		}
	  '}'
		{
		  sli_end ();
		  cur_sym = NULL;
		}
	;
sli_decls : sli_dec
	| sli_decls sli_dec
	;
sli_dec	: at_iws
	| state
	| action_decl
	;
at_iws	: AT
		{
		  if ( need_actions ) get_actions ();
		  cur_sym = NULL;
		}
	  IDENT
		{
		  if ( !strcmp ( $<str>3, "init" ))
		    sli_declare ( "at init", STATE );
		  else if ( !strcmp ( $<str>3, "wakeup" ))
		    sli_declare ( "at wakeup", STATE );
		  else if ( !strcmp ( $<str>3, "sleep" ))
		    sli_declare ( "at sleep", STATE );
		  else if ( !strcmp ( $<str>3, "delete" ))
		    sli_declare ( "at delete", STATE );
		  else
		    {
		      yyerror ( find_msg ( "msg_unk_at" ) );
		      sli_declare ( "at error", STATE );
		    }
		}
	  do_at_action
	;
state	: state_head state_acts
	;
state_head : STATE
		{
		  if ( need_actions ) get_actions ();
		  cur_sym = NULL;
		}
	  state_name
		{
		  sli_declare ( $<str>3, STATE );
		}
	;
state_name : any
	| '*'
		{
		  $<str>$ = "all states";
		}
	;
state_acts : state_dec
	| state_acts state_dec
	;
state_dec : any any
		{
		  sli_do_var ( $<str>1, $<str>2 );
		}
	| any any '(' ')'
		{
		  sli_do_act ( $<str>1, $<str>2 );
		  sli_do_args ();
		}
	| any any DOT_OP any
		{
		  sli_do_class ( $<str>1, $<str>2, $<str>4 );
		}
	| any any DOT_OP any '(' ')'
		{
		  sli_do_class ( $<str>1, $<str>2, $<str>4 );
		  sli_do_args ();
		}
	| trans
	;
trans_list : trans
	| trans_list trans
	;
trans	: ON response_list
		{
		  trans_or_flag = 0;
		}
	  do_next
	| ON response_list
		{
		  trans_or_flag = 0;
		}
	  trans_list do_next
	;
response_list	: response
	| response_list OR
		{
		  trans_or_flag = 1;
		}
	  response
	;
response : any
		{
		  sli_response ( $<str>1, _ceo_noop );
		}
	| any cmp_op any
		{
		  int strip_quotes_flag = 1;	/*** JAJ:08-07-89 ***/

		  if ( ! strcmp ( $<str>1, "EX_STRING" )	||
		       ! strcmp ( $<str>1, "STRING" )		|| 
		       ! strcmp ( $<str>1, "TEXT_VALUE" )	)
		    {
		      strip_quotes_flag = 0;
		    }

		  sli_sub_response ( $<str>3, strip_quotes_flag );
		  sli_response ( $<str>1, $<i>2 );
		}
	;
cmp_op	: EQ_OP
		{
		  $<i>$ = _ceo_eq;
		}
	| NE_OP
		{
		  $<i>$ = _ceo_ne;
		}
	| LT_OP
		{
		  $<i>$ = _ceo_lt;
		}
	| LE_OP
		{
		  $<i>$ = _ceo_le;
		}
	| GE_OP
		{
		  $<i>$ = _ceo_ge;
		}
	| GT_OP
		{
		  $<i>$ = _ceo_gt;
		}
	| DOT_OP
		{
		  $<i>$ = _ceo_subtype;
		}
	;
do_next	: do_action next_state
	| next_state
	;
next_state : STATE any
		{
		  sli_next_state ( $<str>2 );
		}
	| STATE DOT_OP
		{
		  sli_next_state ( "." );
		}
	| STATE '-'
		{
		  sli_next_state ( "-" );
		}
	;
do_at_action : DO act_call
	| do_at_action DO act_call
	;
do_action : DO action
	| do_action DO action
	;
action	: act_call
	| act_call trans_list
	;
act_call : act_name
	| act_name '(' ')'
		{
		  sli_do_args ();
		}
	| any any
		{
		  sli_do_var ( $<str>1, $<str>2 );
		}
	;
act_name : any
		{
		  sli_do_act ( NULL, $<str>1 );
		}
	| any DOT_OP any
		{
		  sli_do_class ( NULL, $<str>1, $<str>3 );
		}
	;
maybe_ifdef :	/* nothing */
		 {
		   ifdef_name = NULL;
		   ifndef_name = NULL;
		   _debug_sliy(fprintf ( stderr, "NO IFDEFs\n" );)
		 }
		|
		IFDEF IDENT
		 {
		    ifdef_name = $<str>2;
		    ifndef_name = NULL;
		    _debug_sliy(fprintf ( stderr, "IFDEF '%s'\n", \
							 ifdef_name ); )
		 }
		|
		IFNDEF IDENT
		 {
		    ifdef_name = NULL;
		    ifndef_name = $<str>2;
		    _debug_sliy(fprintf ( stderr, "IFNDEF '%s'\n", \
							ifndef_name ); )
		 };
maybe_endif :	/* nothing */
		 {
		   endif_flag = 0;
		   _debug_sliy(fprintf ( stderr, "NO ENDIF\n" );)
		 }
		|
		ENDIF
		 {
		   endif_flag = 1;
		   _debug_sliy(fprintf ( stderr, "ENDIF\n" );)
		 };
action_decl : maybe_ifdef ACTION
		{
		  if ( need_actions ) get_actions ();
		  cur_sym = NULL;
		}
	  any
		{
		  sli_declare ( $<str>4, $<i>2 );

		  cur_sym->ifdef_name  = ifdef_name; /* JAJ:01-22-89 **/
		  cur_sym->ifndef_name = ifndef_name;
		  action_cur_sym       = cur_sym;
		  _debug_sliy(fprintf ( stderr, "ifdef cur_sym = 0x%x\n", \
							 cur_sym ); )
		}
	  action_args action_body
	  maybe_endif
		{
		  _debug_sliy(fprintf ( stderr, \
		    "endif action_cur_sym = 0x%x\n", action_cur_sym ); )
		  action_cur_sym->endif_flag = endif_flag;
		  _debug_sliy(fprintf ( stderr, "endif_flag = %hd\n", \
					 action_cur_sym->endif_flag ); )
		}
	  ;
action_args : /* empty */
	| '(' ')'
		{
		  sli_args_declare ();
		}
	;
action_body : '{'
		{
		  sli_begin ();
		}
	  '}'
		{
		  sli_end ();
		  cur_sym = NULL;
		}
	| IDENT
		{
		  sli_find_word ( $<str>1 );
		  if ( word_val != _extern_word )
		    yyerror ( find_msg ( "msg_inv_extern" ) );
		}
	;
