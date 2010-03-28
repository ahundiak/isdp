%{ 

#include "codebug.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "OMDB.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "codef.h"
#include "griomacros.h"
#include "griopriv.h"
#include "igrmacros.h"

#define YYSTYPE              struct COexpr_stacktype
                
#define IS_SCALAR            ( strncmp( COexpr_info.p_unit_type,            \
                                GRIO_SCALAR,                                \
                                GRIO_MAX_ALIAS_SIZE ) == 0 )

extern IGRboolean  call_func();
extern IGRlong     evaluate_expr();

extern IGRchar COexpr_ident[GRIO_MAX_ALIAS_SIZE+2]; /* unit name length + 2  */
extern struct COpriv_expr_info COexpr_info;         /* global info structure */

%}

%token  GRIO_INTEGER       /* integer values                                  */
%token  GRIO_DPFP          /* double precision floating point format          */
%token  GRIO_IDENTIFIER    /* qualifier for dpfp number (e.g. FEET, DEGREES)  */
%token  GRIO_EOL           /* end of line character                           */
%token  GRIO_ERROR         /* indicates semantic error in lexical analyzer;   */
                           /* ( since no rules include GRIO_ERROR, it will    */
                           /* always cause 'list error GRIO_EOL' to succeed ) */

%left   '+' '-'            /* addition/subtraction have lower  precedence     */
%left   '*' '/'            /* multiplication/division have higher precedence  */
%left   GRIO_UNARY_MINUS   /* negation operator                               */
%left   GRIO_UNARY_PLUS    /* has no real effect since it is implied anyway   */
%left   '^'                /* power ( or exponentiation ) operator            */
%%

/*
 *  6/30/93 : Shelley Heard : replaced all OM style macros with direct 
 *                            function calls so that the code could compile
 *                            on SOLARIS.  Arrrrghhh!
 */
list:    /* Nothing */

         | list GRIO_EOL
              { 
                 _m_debug_str( "COparse: list --> list GRIO_EOL" ); 
                 COexpr_info.msg = GRw_no_value;
              }

         | list expr GRIO_EOL
              {
                 IGRlong     status = MSSUCC,
			     msg    = MSSUCC;

                 _m_debug_str( "COparse: list --> list expr GRIO_EOL" ); 

                 if ( IS_SCALAR )
                 {
                    if ( $2.type == EXPR_SCALAR ) 
                    {
                       COexpr_info.result = $2.value;
                       COexpr_info.msg = MSSUCC;
                    }
                 }
                 else /* unit value */
                 {
                    if ( $2.type == EXPR_SCALAR ) 
                    {
                       /* then it needs to be convted to working units */
                       IGRdouble   result;

                       status = GRcvt_imp_to_wrk (&msg,
						   COexpr_info.p_unit_type,
						   COexpr_info.osnum,
						   $2.value,
						   0.0,
						   0.0,
						  &result );
                       _m_check2p( status, msg,
                          "COparse: GRcvt_imp_to_wrk FAILED:" );

                       if ( (status & msg & 1 ) ) /* successful convertion */
                       {
                          COexpr_info.result = result;
                          COexpr_info.msg = MSSUCC;
                       }
                    }
                    else /* should be already converted */
                    {
                       COexpr_info.result = $2.value;
                       COexpr_info.msg = MSSUCC;
                    }
                 }

		 if ( ! ( status & msg & 1 ) )
                 {
                       COexpr_info.msg = CO_e_syntax;
                       COexpr_info.result = 0.0;
                       YYERROR;
                 }

                 _m_debug(printf("COparse: result = %f\n",COexpr_info.result));
              }

         | list error GRIO_EOL
              {
                 _m_debug_str( "COparse: list --> list error GRIO_EOL" ); 
                 COexpr_info.msg = CO_e_syntax;
              }

         ;


expr:      '-' expr %prec GRIO_UNARY_MINUS
              {
                 /*  rule checkin not required */

                 _m_debug_str( "COparse:  expr --> - expr" );
                 $$.value = -$2.value; 
                 $$.type = $2.type;
              }

         | '+' expr %prec GRIO_UNARY_PLUS
              {
                 /*  rule checkin not required */

                 _m_debug_str( "COparse:  expr --> + expr" );
                 $$ = $2;  /* both type and value remain same */
              }

         | expr '+' expr
              {
                 IGRshort   action;

                 _m_debug_str( "COparse:  expr --> expr + expr" );

                 if (rule_check( PLUS, $1.type, $3.type, &($$.type)))
                 {
                    evaluate_expr( PLUS,
                                   IS_SCALAR,
                                  &($1), 
                                  &($3), 
                                  &($$) );

                 }
                 else  
                 {
                    /* syntax error */
                    YYERROR;
                 }
              }


         | expr '-' expr
              {
                 IGRlong status = MSFAIL;

                 _m_debug_str( "COparse:  expr --> expr - expr" );
                 if (rule_check(MINUS, $1.type, $3.type, &($$.type)) )
                 {
                    status = evaluate_expr( MINUS,
                                            IS_SCALAR,
                                           &($1), 
                                           &($3), 
                                           &($$) );
                 }

                 if ( ! (status & 1) )
                 {
                    COexpr_info.msg = status;
                    YYERROR;
                 }
              }


         | expr '*' expr
              {
                 IGRlong status = MSFAIL;

                 _m_debug_str( "COparse:  expr --> expr * expr" );
                 if (rule_check( MUL, $1.type, $3.type, &($$.type) ))
                 {
                    status = evaluate_expr( MUL,
                                            IS_SCALAR,
                                           &($1), 
                                           &($3), 
                                           &($$) );
                 }

                 if ( ! (status & 1) )
                 {
                    COexpr_info.msg = status;
                    YYERROR;
                 }
              }


         | expr '/' expr
              {
                 IGRlong status = MSFAIL;

                 _m_debug_str( "COparse:  expr --> expr '/' expr" );
                 if (rule_check( DIV, $1.type, $3.type, &($$.type) ))
                 {
                    status = evaluate_expr( DIV,
                                            IS_SCALAR,
                                           &($1), 
                                           &($3), 
                                           &($$) );
                 }

                 if ( ! (status & 1) )
                 {
                    COexpr_info.msg = status;
                    YYERROR;
                 }
              }


         | expr '^' expr
              { 
                 IGRlong status = MSFAIL;

                 _m_debug_str( "COparse:  expr --> expr ^ expr" );

                 if (rule_check( POW, $1.type, $3.type, &($$.type) ))
                 {
                    status = evaluate_expr( POW,
                                            IS_SCALAR,
                                           &($1), 
                                           &($3), 
                                           &($$) );
                 }

                 if ( ! (status & 1) )
                 {
                    COexpr_info.msg = status;
                    YYERROR;
                 }
              }


         | GRIO_INTEGER GRIO_INTEGER number
              {
                 IGRshort          nbr_default,
				   flag = 0;
                 IGRlong           status = MSFAIL, 
				   msg    = MSFAIL;
                 GRIOalias_name    return_array[3];

                 _m_debug_str(
                    "COparse:  expr --> integer integer number" );

                 /*
                  *  check to see if there are 3 default units defined 
                  */
                 status = GRget_default_units ( &msg,
		                                 COexpr_info.p_unit_type,
		                                 COexpr_info.osnum,
		                                &flag,
		                                &nbr_default,
		                                 return_array );

                 _m_check2p( status, msg,
                    "COparse: GRget_default_units FAILED:" );

                 if ( ( status & msg & 1 ) && ( nbr_default >= 3 ) )
                 {
                    IGRdouble         result;

                    status = GRcvt_imp_to_wrk ( &msg,
		                                 COexpr_info.p_unit_type,
		                                 COexpr_info.osnum,
		                                 $1.value,
		                                 $2.value,
		                                 $3.value,
		                                &result );

                    _m_check2p( status, msg,
                       "COparse: GRcvt_imp_to_wrk FAILED:" );

                    if ( status & msg & 1 )
                    {
                       $$.value = result;
                       $$.type  = EXPR_IMPLICIT;
                    }
                 }

                 if ( ! ( status & msg & 1 ) || ( nbr_default < 3 ) )
                 {
                    COexpr_info.msg = msg;
                    YYERROR;
                 }
              }


         | GRIO_INTEGER number
              { 
                 IGRshort          nbr_default,
		                   flag = 0;
                 IGRlong           status = MSFAIL,
				   msg = MSFAIL;
                 GRIOalias_name    return_array[3];

                 _m_debug_str(
                  "COparse:  expr --> integer number");

                 /*
                  *  check to see if there are at least 2 default units defined 
                  */
                 status = GRget_default_units ( &msg,
		                                 COexpr_info.p_unit_type,
		                                 COexpr_info.osnum,
		                                &flag,
		                                &nbr_default,
		                                 return_array );

                 _m_check2p( status, msg,
                    "COparse: GRget_default_units FAILED:" );

                 if ( ( status & msg & 1 ) && ( nbr_default >= 2 ) )
                 {
                    IGRdouble result;

                    status = GRcvt_imp_to_wrk ( &msg,
		                                 COexpr_info.p_unit_type,
		                                 COexpr_info.osnum,
		                                 $1.value,
		                                 $2.value,
		                                 0.0,
		                                &result );

                    _m_check2p(status,msg,"COparse: GRcvt_imp_to_wrk FAILED:");

                    if ( status & msg & 1 ) /* successful convertion */
                    {
                       $$.value = result;
                       $$.type  = EXPR_IMPLICIT;
                    }
                 }

                 if (! ( status & msg & 1 ) || ( nbr_default < 2 ) )
                 {
                    COexpr_info.msg = msg;
                    $$.value = 0.0;
                    YYERROR;
                 }
              }
         

         | expr GRIO_IDENTIFIER
              {
                 IGRlong 
                    status = MSFAIL,
                    msg    = MSFAIL;

                 IGRdouble
                    result;

                 _m_debug_str("COparse:  expr --> expr identifier");

		 if ( $1.type == EXPR_SCALAR )
		 {

                    status = GRcvt_exp_to_wrk ( &msg,
		                                 COexpr_info.p_unit_type,
		                                 COexpr_info.osnum,
		                                 $1.value,
		                                 COexpr_ident,
		                                &result );
                    _m_check2p(status,msg,"COparse: GRcvt_exp_to_wrk FAILED:");

                    if ( status & msg & 1 ) /* successful convertion */
                    {
                       $$.value = result;
                       $$.type  = EXPR_EXPLICIT;
                    }
                 }

                 if (! (status & msg & 1 ) )
                 {
                    COexpr_info.msg = CO_e_syntax;
                    $$.value = 0.0;
                    YYERROR;
                 }
              }


         | number
              { 
                 _m_debug_str("COparse:  expr --> number");
                 $$ = $1;
              }

/* --------------------------- function ---------------------------------- *
         | GRIO_IDENTIFIER '(' expr ')'  
              {
                 IGRboolean b_status;
                 IGRlong    status;

                 _m_debug_str( "COparse:  expr --> identifier ( expr )" );
                 b_status = call_func( &status, COexpr_ident, &($3), &($$) );
              }
 * ----------------------------------------------------------------------- */

         | '(' expr ')'  
              {
                 _m_debug_str( "COparse:  expr --> ( expr )" );
                 $$ = $2; /* inherits value and type */
              }

         ;

number:    GRIO_INTEGER
              {
                  _m_debug_str( "COparse:  number --> integer");
		  $$ = $1;
              }

         | GRIO_DPFP
              {
                  _m_debug_str( "COparse:  number --> float");
		  $$ = $1;
              }

         | GRIO_INTEGER GRIO_INTEGER '/' GRIO_INTEGER 
              {
                 _m_debug_str( "COparse:  number --> integer fraction");

                 if ( $4.value != 0.0 ) 
                 {
                    $$.value =  $1.value + ( $2.value / $4.value ); 
                    $$.type  = EXPR_SCALAR;
                 }
                 else 
                 {
                    _m_debug_str( "COparse: fraction denominator = 0.0" );
                    $$.value = 0.0;
                    COexpr_info.msg = CO_e_divide_by_zero;
                    YYERROR;
                 }
              }
         ;

%%

/*
 * -------------------------------------------------------------------------
 *    -------------------------  yacc functions  ------------------------
 * -------------------------------------------------------------------------
 */
IGRint yyerror(s)       /* called for yyac error processing */
   IGRchar *s;
{
   _m_debug( printf( "COparse:  yyerror -  %s\n", s ) );
   return (1);
}

IGRint yywrap()
{
   _m_debug_str( "COparse:  yywrap - wrapping up" );
   return (1);
}

