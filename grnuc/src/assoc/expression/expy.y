/*

Name
  expy.y

Description
   This file is the parser source for the parametric expressions.
Notes


 */

/*
  ---------------------------------------------------------------------------
   H.BEQUET : 12/03/1986 ( revised : 12/10/1986 )                      expy.y
   S.F.     : March-09-87 inclusion in IGE( revised : Oct-08-87 )
   This file is the parser source for the parametric expressions.
   See expression.doc for a full documentation.
   SRH      : 7/1/93 comverted to .C format for SOLARIS build.
  --------------------------------------------------------------------------
*/

%{

#ifndef clipper 
#define clipper 1
#endif

#include <errno.h>
#include "stdio.h"
#include "alloca.h"
#include "math.h"
#include "ctype.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "expression.h"
#include "expmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "msdef.h"
#include "griodef.h"
#include "griomacros.h"
#include "AS_status.h"
#include "exmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "madef.h"
#include "igrtypedef.h"
#include "exp_bcksol.h"
#include "drawparam.h"
#include "parametric.h"

#define AS_DEBUG

char		G_parse_type;	/* tell if it is the first parse or 	*/
				/* a compute parse with the internal format */

int 		NO_more_eval;	/* an evaluation has failed no use to go on */
short	int 	G_id_count; 	/* number of identifier found or given */
char		**G_id_list;	/* list of identifier   */ 
struct GRid	*G_objid_list;	/* list of parent objid */
char		G_type_found;   /* type of the expression found by */
				/* type analysis */

/* Value of the LHS or RHS of equational constraint which has been computed */

struct data_struct Computed_value;

/* Trimmed parse tree for the side of the expression which has not been computed */

UNCOMPUTED_PARSE_TREE Uncomputed_tree;

IGRboolean in_cycle;

struct GRid solve_var_grid;

IGRboolean seen_solve_var;


extern  short 	int Compress_ArgList();
extern  char 	**Add_String ();
extern	char 	*input_stream; /* keyboard line simulation */
extern	int 	input_index;   /* keyboard line simulation */

#define YYSTYPE struct data_struct
     
%}

%start 	stat

%token 	CHARACTER STRING BOOLEAN INTEGER REAL 
       	SIN COS ABS ACOS ASIN ATAN ATAN2 EXP LOG MAX MIN POW
	SQRT TAN IFINF IFSUP IF THEN ELSE
       	NUM_IDENT STR_IDENT BOOL_IDENT
       	LESS MORE LESS_OR_EQUAL MORE_OR_EQUAL EQUAL NOT_EQUAL
	ASSIGN ASSIF
       	OR AND 
	INT

%left 	LESS MORE LESS_OR_EQUAL MORE_OR_EQUAL EQUAL NOT_EQUAL
%left 	'+' '-'
%left 	'*' '/'
%left   UMINUS
%right  '^'
%nonassoc '?' ':'
%left 	OR
%left 	AND
%nonassoc '!'

%%

stat 	: NUM_IDENT
          {
            struct GRid 	exp_id;
	    int			rc;

	    if (G_parse_type != FIRST_PARSE)
	    {
      	      rc=id_present($1, &$$, &exp_id);
              if(rc==EXP_NOT_FOUND)
              { /* */
                Error_Text(EXP_UNDEF_RHS, (int *)$1.data.string);
      	        /* no use to try to evaluate anything now */
      	        NO_more_eval |= EXP_NOT_FOUND;
      	      }
      	      else
              {
                if(rc==EXP_EVAL_ERROR)
      	        { /* that means this id is degraded */
      	          Error_Text(EXP_UNDEF_RHS, (int *)$1.data.string);
      		  /* no use to try to evaluate anything now */
      		  NO_more_eval |= EXP_EVAL_ERROR;
                }
              }
            }
	    else  
	    {   
	      G_id_list = Add_String( G_id_list, G_id_count+1, 
				 (strlen($1.data.string )+1) );
	      strcpy(*(G_id_list + G_id_count), $1.data.string);
	      G_id_count++;
	    }
          } 
          ifstat
          {
	    if (G_parse_type != FIRST_PARSE)
	    {
              if (! in_cycle)
              {
                 if ($3.status == COMPUTED_NODE)
                   Computed_value = $3;
                 else 
                 {
                   Error_Text ( EXP_INV_INPUT);
                   NO_more_eval |= EXP_INV_INPUT; 
                   return(EXP_EVAL_ERROR);
                 }
                 if ($1.status == COMPUTED_NODE)
                 {
                   Error_Text ( EXP_INV_INPUT);
                   NO_more_eval |= EXP_INV_INPUT; 
                   return(EXP_EVAL_ERROR);
                 }

              }
              else /* called from NR solver */
              {
                Computed_value.type = REAL;
                Computed_value.unit_type = $1.unit_type;
                Computed_value.data.real = $1.data.real - $3.data.real;
              }
	    }
          }
        | num_exp ASSIGN num_exp
          {
            int status;

	    if (G_parse_type != FIRST_PARSE)
	    {
              if (! in_cycle)
              {
                 if ($1.status == COMPUTED_NODE)
                 {
                   Computed_value = $1;
                   if ($3.status == UNCOMPUTED_INTERMEDIATE_NODE)
                     status = Backsolve_eqn_constr();
                   else if ($3.status == COMPUTED_NODE)
                   {
                     Error_Text ( EXP_INV_INPUT);
                     NO_more_eval |= EXP_INV_INPUT; 
                     return(EXP_EVAL_ERROR);
                   }
                 }
                 else if ($3.status == COMPUTED_NODE)
                 {
                   Computed_value = $3;
                   if ($1.status == UNCOMPUTED_INTERMEDIATE_NODE)
                     status = Backsolve_eqn_constr();
                   else if ($1.status == COMPUTED_NODE)
                   {
                     Error_Text ( EXP_INV_INPUT);
                     NO_more_eval |= EXP_INV_INPUT; 
                     return(EXP_EVAL_ERROR);
                   }
                 }
              }
              else /* called from NR solver */
              {
                Computed_value.type = REAL;
                Computed_value.unit_type = $1.unit_type;
                Computed_value.data.real = $1.data.real - $3.data.real;
              }
	    }
          }
     	;

num_exp : forced_type
     	| '(' num_exp ')'
       	  {
            $$ = $2;
       	  }
     	| '-' num_exp %prec UMINUS
          {
             int status;
	     OPERATOR_NODE *pop_node;
	     struct data_struct dummy_operand;

	    if (G_parse_type != FIRST_PARSE)
	    {
  
               if ($2.status == COMPUTED_NODE)
               {
                  $$.type = REAL;
                
                  if ($2.data.real == MAXDOUBLE)
                    $$.data.real = MAXDOUBLE;
                  else
                    $$.data.real = - $2.data.real;

                  $$.unit_type = $2.unit_type;
                  $$.status = COMPUTED_NODE;
               }
               else
               {
                  pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
                  dummy_operand.data.real = 0.0;
                  dummy_operand.type = REAL;
                  status = Add_op_node(pop_node,'-', FALSE, dummy_operand);
                  if (status != EXP_SUCCESS) return(status);
                  $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
               }
            }
    	  }
     	| '+' num_exp %prec '*'
       	  {
            $$ = $2;
       	  }
     	| num_exp '+' num_exp
       	  {
            int status;
	    OPERATOR_NODE *pop_node;

	    if (G_parse_type != FIRST_PARSE)
	    {

              /* check if both the operands have been computed */
              if (($1.status == COMPUTED_NODE) && ($3.status == COMPUTED_NODE))
              {
                numeric_eval ( &$$, $1, $3, '+' );
                $$.status = COMPUTED_NODE;
              }
              else /* one of the operands depends on the unknown var */
              {
                pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
    
                if ($1.status == COMPUTED_NODE)
                {
                   status = Add_op_node(pop_node,'+', FALSE, $1);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_op_node(pop_node,'+', TRUE, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }
     	| num_exp '-' num_exp
       	  {
            int status;
            OPERATOR_NODE *pop_node; 

	    if (G_parse_type != FIRST_PARSE)
	    {

              /* check if both the operands have been computed */
              if (($1.status == COMPUTED_NODE) && ($3.status == COMPUTED_NODE))
              {
                numeric_eval ( &$$, $1, $3, '-' );
                $$.status = COMPUTED_NODE;
              }
              else /* one of the operands depends on the unknown var */
              {
                pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
    
                if ($1.status == COMPUTED_NODE)
                {
                   status = Add_op_node(pop_node,'-', FALSE, $1);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_op_node(pop_node,'-', TRUE, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }
     	| num_exp '*' num_exp
       	  {
            int status;
            OPERATOR_NODE *pop_node; 

	    if (G_parse_type != FIRST_PARSE)
	    {
  
              /* check if both the operands have been computed */
              if (($1.status == COMPUTED_NODE) && ($3.status == COMPUTED_NODE))
              {
                numeric_eval ( &$$, $1, $3, '*' );
                $$.status = COMPUTED_NODE;
              }
              else /* one of the operands depends on the unknown var */
              {
                pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
    
                if ($1.status == COMPUTED_NODE)
                {
                   status = Add_op_node(pop_node,'*', FALSE, $1);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_op_node(pop_node,'*', TRUE, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }

     	| num_exp '/' num_exp
       	  {
            int status;
            OPERATOR_NODE *pop_node; 

	    if (G_parse_type != FIRST_PARSE)
	    {
  
              /* check if both the operands have been computed */
              if (($1.status == COMPUTED_NODE) && ($3.status == COMPUTED_NODE))
              {
                numeric_eval ( &$$, $1, $3, '/' );
                $$.status = COMPUTED_NODE;
              }
              else /* one of the operands depends on the unknown var */
              {
                pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
    
                if ($1.status == COMPUTED_NODE)
                {
                   status = Add_op_node(pop_node,'/', FALSE, $1);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_op_node(pop_node,'/', TRUE, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }


     	| num_exp '^' num_exp
       	  {
            int status;
            OPERATOR_NODE *pop_node; 

	    if (G_parse_type != FIRST_PARSE)
	    {
  
              /* check if both the operands have been computed */
              if (($1.status == COMPUTED_NODE) && ($3.status == COMPUTED_NODE))
              {
                numeric_eval ( &$$, $1, $3, '^' );
                $$.status = COMPUTED_NODE;
              }
              else /* one of the operands depends on the unknown var */
              {
                pop_node = (OPERATOR_NODE *)alloca(sizeof(OPERATOR_NODE));
    
                if ($1.status == COMPUTED_NODE)
                {
                   status = Add_op_node(pop_node,'^', FALSE, $1);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_op_node(pop_node,'^', TRUE, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }

     	| un_function '(' num_exp ')'
          {
             int status;
	     FUNCTION_NODE *pfunct_node;
	     struct data_struct dummy_operand;

	    if (G_parse_type != FIRST_PARSE)
	    {
  
               if ($3.status == COMPUTED_NODE)
               {
                  un_function_eval($1.type, $3, &$$);
		  $$.status = COMPUTED_NODE;
               }
               else
               {
                  pfunct_node = (FUNCTION_NODE *)alloca(sizeof(FUNCTION_NODE));

                  status = Add_funct_node(pfunct_node,$1.type, 1, 0, dummy_operand);
                  if (status != EXP_SUCCESS) return(status);
                  $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
               }
            }
       	  }
     	| bin_function '(' num_exp ',' num_exp ')'

       	  {
            int status;
	    FUNCTION_NODE *pfunct_node;

	    if (G_parse_type != FIRST_PARSE)
	    {
  
              /* check if both the arguments have been computed */
              if (($3.status == COMPUTED_NODE) && ($5.status == COMPUTED_NODE))
              {
                bin_function_eval($1.type, $3, $5, &$$);
                $$.status = COMPUTED_NODE;
              }
              else /* one of the arguments depends on the unknown var */
              {
                pfunct_node = (FUNCTION_NODE *)alloca(sizeof(FUNCTION_NODE));
    
                if ($3.status == COMPUTED_NODE)
                {
                   status = Add_funct_node(pfunct_node,$1.type, 2, 1, $3);
                   if (status != EXP_SUCCESS) return(status);
                }
                else
                {
                   status = Add_funct_node(pfunct_node,$1.type, 2, 0, $5);
                   if (status != EXP_SUCCESS) return(status);
                }
                $$.status = UNCOMPUTED_INTERMEDIATE_NODE;
              }
            }
          }

     	| ifcomp_function '(' num_exp ',' num_exp  ',' num_exp  ',' num_exp ')'
       	  {

  	    if (G_parse_type != FIRST_PARSE)
            {
               /* check if all the arguments have been computed */
              if (($3.status != COMPUTED_NODE) || ($5.status != COMPUTED_NODE) ||
                  ($7.status != COMPUTED_NODE) || ($9.status != COMPUTED_NODE))
              {
                 Error_Text ( EXP_INV_INPUT);
                 NO_more_eval |= EXP_INV_INPUT; 
                 return(EXP_EVAL_ERROR);
              }

              ifcomp_function_eval($1.type, $3, $5, $7, $9, &$$);
              $$.status = COMPUTED_NODE;
            }

	  }
     	| '(' bool_exp ')' '?' '(' num_exp ')' ':' '(' num_exp ')'
       	  {

  	    if (G_parse_type != FIRST_PARSE)
            {
              /* check if all the arguments have been computed */
              if (($2.status != COMPUTED_NODE) || ($6.status != COMPUTED_NODE) ||
                  ($10.status != COMPUTED_NODE))
              {
                 Error_Text ( EXP_INV_INPUT);
                 NO_more_eval |= EXP_INV_INPUT; 
                 return(EXP_EVAL_ERROR);
              }
            
              if ((($2.data.real == MAXDOUBLE) && ($2.type == REAL)) ||
                   ($6.data.real == MAXDOUBLE) || ($10.data.real == MAXDOUBLE))
              {
                $$.type = REAL;
                $$.data.real = MAXDOUBLE;
              }
              else if ($2.data.boolean) 
                 $$ = $6;
              else
                 $$ = $10;
              $$.status = COMPUTED_NODE;
            }

          }
     	| NUM_IDENT
       	  {
            struct GRid 	exp_id;
	    int			rc;

	    if (G_parse_type != FIRST_PARSE)
	    {
      
      	      rc=id_present($1, &$$, &exp_id);


              if(rc==EXP_NOT_FOUND)
              { /* */
                Error_Text(EXP_UNDEF_RHS, (int *)$1.data.string);
      	        /* no use to try to evaluate anything now */
      	        NO_more_eval |= EXP_NOT_FOUND;
      	      }
      	      else
              {
                if(rc==EXP_EVAL_ERROR)
      	        { /* that means this id is degraded */
      	          Error_Text(EXP_UNDEF_RHS, (int *)$1.data.string);
      		  /* no use to try to evaluate anything now */
      		  NO_more_eval |= EXP_EVAL_ERROR;
                }
              }
            }
	    else  
	    {   
	      G_id_list = Add_String( G_id_list, G_id_count+1, 
				 (strlen($1.data.string )+1) );
	      strcpy(*(G_id_list + G_id_count), $1.data.string);
	      G_id_count++;
	    }
       	  }
     	| number
	  {
            $$ = $1;
          }
  	

ifstat	: ASSIF '(' bool_exp ')' THEN num_exp ELSE num_exp
       	  {

  	    if (G_parse_type != FIRST_PARSE)
            {
              /* check if all the arguments have been computed */
              if (($3.status != COMPUTED_NODE) || ($6.status != COMPUTED_NODE) ||
                  ($8.status != COMPUTED_NODE))
              {
                 Error_Text ( EXP_INV_INPUT);
                 NO_more_eval |= EXP_INV_INPUT; 
                 return(EXP_EVAL_ERROR);
              }
            
              if ((($3.data.real == MAXDOUBLE) && ($3.type == REAL)) ||
                   ($6.data.real == MAXDOUBLE) || ($8.data.real == MAXDOUBLE))
              {
                $$.type = REAL;
                $$.data.real = MAXDOUBLE;
              }
              else if ($3.data.boolean) 
                 $$ = $6;
              else
                 $$ = $8;
              $$.status = COMPUTED_NODE;
            }

          } 
	| ASSIF '(' bool_exp ')' '{' num_exp '}' ELSE '{' num_exp '}'
       	  {
  	    if (G_parse_type != FIRST_PARSE)
            {
              /* check if all the arguments have been computed */
              if (($3.status != COMPUTED_NODE) || ($6.status != COMPUTED_NODE) ||
                  ($10.status != COMPUTED_NODE))
              {
                 Error_Text ( EXP_INV_INPUT);
                 NO_more_eval |= EXP_INV_INPUT; 
                 return(EXP_EVAL_ERROR);
              }
            
              if ((($3.data.real == MAXDOUBLE) && ($3.type == REAL)) ||
                   ($6.data.real == MAXDOUBLE) || ($10.data.real == MAXDOUBLE))
              {
                $$.type = REAL;
                $$.data.real = MAXDOUBLE;
              }
              else if ($3.data.boolean) 
                 $$ = $6;
              else
                 $$ = $10;
              $$.status = COMPUTED_NODE;
            }
          } 

bool_exp : num_exp rel_op num_exp
          {

  	    if (G_parse_type != FIRST_PARSE)
            {
              /* check if all the arguments have been computed */
              if (($1.status != COMPUTED_NODE) || ($3.status != COMPUTED_NODE))
              {
                 Error_Text ( EXP_INV_INPUT);
                 NO_more_eval |= EXP_INV_INPUT; 
                 return(EXP_EVAL_ERROR);
              }
              boolean_eval ( &$$, $1, $3, $2.type );
              $$.status = COMPUTED_NODE;
            }


          }
        ;

rel_op : LESS 
       	| MORE
       	| EQUAL
       	| NOT_EQUAL
       	| LESS_OR_EQUAL
       	| MORE_OR_EQUAL
       	;

forced_type : '(' number NUM_IDENT ')'
       	  { 
	    double 	WKU_value;
	    IGRlong	msg, status;

	    printf("type : %s\n", $3.data.string );
            
	    status = co$cvt_exp_to_wrk(msg = &msg,
   	             	unit_type = "UOM_DISTANCE",
	             	units = $2.data.real,
			alias = $3.data.string,
	             	result = &WKU_value);
	    if(msg!=MSSUCC)
	    {
	      status = co$cvt_exp_to_wrk(msg = &msg,
   	             	unit_type = "UOM_ANGLE",
	             	units = $2.data.real,
			alias = $3.data.string,
	             	result = &WKU_value);
	    }
	    
	    if((status!=OM_S_SUCCESS)||(msg!=MSSUCC))
	    {
	      /*| unable to parse the forced type */
	      /*" status %d msg %d\n", status, msg */
	      return(1); /* it is a syntax error */
	    }

	    /*" status %d msg %d\n", status, msg */
	    /*"WKU : %lf\n", WKU_value */

            $$.type = REAL;
            $$.data.real = WKU_value;
            $$.unit_type = 1; /* it is a distance */
       	  }
	|  '(' NUM_IDENT NUM_IDENT ')'
       	  { 
            struct GRid exp_id;
	    int		rc;
	    double 	WKU_value;
	    IGRlong	msg;
	    char	str_to_cvt[80];

	    rc=id_present($2, &$$, &exp_id);

            if(rc==EXP_NOT_FOUND)
	    { /* */
	      Error_Text(EXP_UNDEF_RHS, (int *)$2.data.string);
	      /* no use to try to evaluate anything now */
	      NO_more_eval |= EXP_NOT_FOUND;
	      return(1);
  	    }
	    else
              if(rc==EXP_EVAL_ERROR)
	      { /* that means this id is degraded */
	        Error_Text(EXP_UNDEF_RHS, (int *)$2.data.string);
		/* no use to try to evaluate anything now */
		NO_more_eval |= EXP_EVAL_ERROR; 
              }

	    sprintf(str_to_cvt, "%lf ", $$.data.real);
	    strcat(str_to_cvt, $3.data.string);

	    printf("type : %s\n", $3.data.string );
	    /*"forced type : %s\n", str_to_cvt */

	    if( co$expreval(msg = &msg,
   	             	unit_type = GRIO_DISTANCE,
	             	expression = str_to_cvt,
	             	result = &WKU_value)  != MSSUCC)
	      if( co$expreval(msg = &msg,
   	             	unit_type = GRIO_ANGLE,
	             	expression = str_to_cvt,
	             	result = &WKU_value)  != MSSUCC)
		{
		  /*| unable to parse the forced type */
		  return(1); /* it is a syntax error */
		}

	    /*"WKU : %lf\n", WKU_value */

            $$.type = REAL;
            $$.data.real = WKU_value;
       	  }
	;
un_function : 
	  SIN   { $$.type = SIN; }
        | COS   { $$.type = COS; }
        | ABS   { $$.type = ABS; }
        | ACOS  { $$.type = ACOS; }
        | ASIN  { $$.type = ASIN; }
        | ATAN  { $$.type = ATAN; }
        | EXP   { $$.type = EXP; }
        | LOG   { $$.type = LOG; }
        | SQRT  { $$.type = SQRT; }
        | TAN   { $$.type = TAN; }
        | INT   { $$.type = INT; }
        ;
bin_function : 
	  MIN 	{ $$.type = MIN; }
	| MAX 	{ $$.type = MAX; }
	| ATAN2 { $$.type = ATAN2; }
        | POW   { $$.type = POW; }
        ;

ifcomp_function : 
	  IFINF	{ $$.type = IFINF; }
	| IFSUP	{ $$.type = IFSUP; }
        ;

number 	: REAL
          {
            $$ = $1;
            $$.status = COMPUTED_NODE;
            $$.unit_type = 0; /* it is a scalar */
          }
       	;
%%

/*-------------------------------------------------------------------------*/

yyerror(s)
char *s;
{
  yywrap();
  UI_status(s);
  return(1);
}

/* -------------------------------------------------------------------
/*
/* identifier : is either a directory name
/*		or an index on the channel
/*
/* id_present : this routine try to find the expression in the current
/*		directory 					
/*
/*    Returns : EXP_NOT_FOUND	
/*		EXP_INV_INPUT if exist but is not an expression
/*		EXP_SUCCESS					
/*		EXP_EVAL_ERROR if degraded value 
/* -------------------------------------------------------------------*/
int id_present ( identifier, p_value, p_expr_id)
                 	struct data_struct identifier, *p_value;
  			struct GRid 	*p_expr_id;
/*.id_present */
{ 
  int     RC;
  IGRint  status;
  IGRlong msg;
  struct ret_struct  rst;
  struct GRmd_env md_env;
  int expr_index;

  /* Just to make expression that are virual feet of macro hapy */
  md_env.md_id.objid = NULL_OBJID;
  md_env.md_id.osnum = solve_var_grid.osnum;
  md_env.md_env.matrix_type = MAIDMX;
  MAidmx(&msg,md_env.md_env.matrix);

  p_value->type=  REAL;
  p_value->status =  COMPUTED_NODE;
  p_value->data.real = 0.;

  if(G_parse_type == COMPUTE_PARSE)
  {
    if(identifier.data.string[0] != '\\')
      return(EXP_INV_INPUT);

    if (identifier.data.string[1] == '-')
      if (identifier.data.string[2] == '1')
        *p_expr_id = solve_var_grid;
      else 
        return(EXP_INV_INPUT);
    else
    {
      sscanf(&identifier.data.string[1], "%d", &expr_index);

      if(expr_index > G_id_count) return(EXP_INV_INPUT);

      *p_expr_id = G_objid_list[expr_index];
    }

    if(om$is_objid_valid( objid = p_expr_id->objid, 
			    osnum = p_expr_id->osnum ) != OM_S_SUCCESS)
        						  return(EXP_NOT_FOUND);
    RC = EXP_S_SUCCESS;
  }
  else 
    RC=exp$translate( exp_name = identifier.data.string, 
                      p_exp_id = &(p_expr_id->objid), 
		      p_osnum  = &(p_expr_id->osnum) );

  switch( RC )
  { 
  case EXP_SUCCESS   :

    if ((in_cycle) || (p_expr_id->osnum != solve_var_grid.osnum)  || 
                      (p_expr_id->objid != solve_var_grid.objid))
    {
      extern int NDgive_struct();
      
      status = NDgive_struct( &msg, p_expr_id, &rst, &md_env );
      as$status(action = RET_STATUS);

      if (rst.type != double_type) return(EXP_INV_INPUT);
      p_value->data.real = rst.var.root_pm_st.value;
      p_value->status = COMPUTED_NODE;
    }
    else if ((p_expr_id->osnum == solve_var_grid.osnum) &&
             (p_expr_id->objid == solve_var_grid.objid))
             
    {
      p_value->status = UNCOMPUTED_LEAF_NODE;
      strcpy(p_value->data.string, identifier.data.string);
    }
    return(EXP_SUCCESS);

  case EXP_NOT_FOUND :
    return(EXP_NOT_FOUND);
  }
  return ( EXP_NOT_FOUND);
}

/*-----------------------------------------------------------------*/
/*   This procedure is used to evaluate numeric operations between
/*   integer and reals. 							
/*-----------------------------------------------------------------*/
int numeric_eval ( result, value1, value2, operator )
               struct data_struct *result, value1, value2;
               int operator;
{
  int		m;
  double 	val1, val2;

  result->type = REAL ;
  result->data.real = 0.;
  if(NO_more_eval)  return(EXP_EVAL_ERROR);
 
  val1 = value1.data.real;
  val2 = value2.data.real;

  if ((val1 == MAXDOUBLE) || (val2 == MAXDOUBLE))
  {
    result->data.real = MAXDOUBLE;
    return( EXP_EVAL_ERROR ); 
  }

  switch ( operator )
  {
  case '+' : 
    result->data.real = val1 + val2;
    break;

  case '*' : 
    m = ( val1 == 0 || val2 == 0 ) ? 0 : log10( fabs( val1 ) ) + log10( fabs( val2));
    if( m >= EXP_LIM )
    {
      Error_Text( EXP_OVERFLOW, &m ) ;
      return( EXP_EVAL_ERROR ); 
    } 
    else if( m <= -EXP_LIM )
    { 
      Error_Text( EXP_UNDERFLOW, &m ) ;
      return( EXP_EVAL_ERROR ); 
    } 
    result->data.real = val1 * val2;
    break;

  case '-' : 
    result->data.real = val1 - val2;
    break;

  case '/' : 
    if( fabs( val2 ) <= EPSILON ) 
    { 
      Error_Text( EXP_ZERO_DIVIDE ) ;
      return( EXP_EVAL_ERROR ); 
    }
    m = ( val1 == 0 ) ? 0 : log10( fabs( val1 ) ) - log10( fabs( val2 ) ) ;
    if( m >= EXP_LIM )
    { 
      Error_Text( EXP_OVERFLOW, &m ) ;
      return( EXP_EVAL_ERROR ); 
    } 
    else if( m <= -EXP_LIM )
    { 
      Error_Text( EXP_UNDERFLOW, &m ) ;
      return( EXP_EVAL_ERROR ); 
    } 
    result->data.real = val1 / val2;
    break;

  case '^' : 
    result->data.real = pow( val1, val2 ) ;
    switch( errno ) 
    { 
    case EDOM   : 
      Error_Text( EXP_POW_DOM_ERR, (int *) &val1 );
      return( EXP_EVAL_ERROR );

    case ERANGE : Error_Text( EXP_POW_RNG_ERR, (int *) &val1 );
      return( EXP_EVAL_ERROR );

    default     : ;
    }
    break;

  default : 
    printf ( "Unknown Operation\n" );
  }
  return(EXP_SUCCESS);
}

/*--------------------------------------------------------------------
   This procedure is used to evaluate relationnal operations between
   integer and reals and between strings.
  --------------------------------------------------------------------*/
int boolean_eval ( result, value1, value2, operator )
               struct data_struct *result, value1, value2;
               int operator;
{
  double dval1, dval2;

  result->type = BOOLEAN;
  result->data.boolean = 0 ; /* default value */ 
  if(NO_more_eval)  return(EXP_EVAL_ERROR);

  dval1 = value1.data.real;
  dval2 = value2.data.real;


  if ((dval1 == MAXDOUBLE) || (dval2 == MAXDOUBLE))
  {
    result->type = REAL;
    result->data.real = MAXDOUBLE;
    return( EXP_EVAL_ERROR ); 
  }

  switch ( operator )
  {
     case MORE : result->data.boolean = dval1 > dval2;
                 break;
     case LESS : result->data.boolean = dval1 < dval2;
                 break;
     case EQUAL : result->data.boolean = fabs (dval1 - dval2) < 1e-20;
                  break;
     case NOT_EQUAL : result->data.boolean = fabs (dval1 - dval2) >= 1e-20;
                      break;
     case MORE_OR_EQUAL : result->data.boolean = dval1 >= dval2;
                          break;
     case LESS_OR_EQUAL : result->data.boolean = dval1 <= dval2;
                          break;
     default : return (EXP_EVAL_ERROR);
  }
  return ( EXP_SUCCESS );
}

/*----------------------------------------------------
/*   This procedure is used to evaluate function calls
/*----------------------------------------------------*/
int un_function_eval(f_type, f_arg, result)
int 	f_type;
struct 	data_struct f_arg, *result;
{
  extern double sin (), cos (), log (), tan (), fabs(), acos(),
		asin(), atan(), exp(), log(), sqrt();

  result->type = REAL ;
  result->data.real = 0. ;
  if(NO_more_eval)  return(EXP_EVAL_ERROR);

  if(f_arg.type != REAL)
  {
    /* no use to try to evaluate anything now */
    NO_more_eval |= EXP_INV_INPUT; 
    return(EXP_EVAL_ERROR);
  }

  if (f_arg.data.real == MAXDOUBLE)
  {
    result->data.real = MAXDOUBLE;
    return( EXP_EVAL_ERROR ); 
  }


  switch (f_type)
  {

  case SIN : 
    result->data.real = sin(f_arg.data.real);
    if( errno == ERANGE ) 
    { 
      yyerror("SIN range error");
      return(EXP_EVAL_ERROR);
    }
    break;

  case COS : 
    result->data.real = cos ( f_arg.data.real );
    if( errno == ERANGE ) 
    { 
      yyerror( "COS range error");
      return( EXP_EVAL_ERROR);
    }
    break;

  case ABS : 
    result->data.real = fabs( f_arg.data.real ) ;
    break;

  case ACOS : 
    result->data.real = acos ( f_arg.data.real );
    if( errno == EDOM ) 
    { 
      Error_Text( EXP_ACOS_DOM_ERR, (int *) &f_arg.data.real ) ;
      return( EXP_EVAL_ERROR );
    }
    break;


  case ASIN : 
    result->data.real = asin ( f_arg.data.real );
    if( errno == EDOM ) 
    { 
      Error_Text( EXP_ASIN_DOM_ERR, (int *) &f_arg.data.real ) ;
      return( EXP_EVAL_ERROR );
    }
    break;

  case ATAN : 
    result->data.real = atan ( f_arg.data.real );
    break;

  case EXP : 
    result->data.real = exp ( f_arg.data.real );
    if( errno == ERANGE ) 
    { 
      Error_Text( EXP_EXP_RNG_ERR, (int *) &f_arg.data.real );
      return( EXP_EVAL_ERROR );
    }
    break;

  case LOG : 
    result->data.real = log ( f_arg.data.real );
    if( errno == EDOM ) 
    { 
      Error_Text( EXP_LOG_DOM_ERR, (int *) &f_arg.data.real );
      return( EXP_EVAL_ERROR );
    }
    break;
 
  case SQRT : 
    result->data.real = sqrt ( f_arg.data.real );
    if( errno == EDOM ) 
    { 
      Error_Text( EXP_SQRT_DOM_ERR, (int *) &f_arg.data.real);
      return( EXP_EVAL_ERROR );
    }
    break;

  case TAN : 
    result->data.real = tan ( f_arg.data.real );
    if( errno == ERANGE ) 
    { 
      Error_Text( EXP_TAN_RNG_ERR, (int *) &f_arg.data.real ) ;
      return( EXP_EVAL_ERROR );
    }
    break;
 
  case INT : 
    result->data.real = (int) f_arg.data.real;
    break;
  
  default :  printf ( "yacc : unknown function identifier\n" );
    break;

  }
  return(EXP_SUCCESS);
}

/*--------------------------------------------------------------------------*/
/*   This procedure is used to evaluate binary function calls
/*--------------------------------------------------------------------------*/
int bin_function_eval(f_type, f_arg1, f_arg2 , result)
int 	f_type;
struct 	data_struct f_arg1, f_arg2, *result;
{
  extern double pow(), atan2();

  result->type = REAL ;
  result->data.real = 0. ;
  if(NO_more_eval)  return(EXP_EVAL_ERROR);

  if((f_arg1.type != REAL) || (f_arg2.type != REAL))
  {
    /* no use to try to evaluate anything now */
    NO_more_eval |= EXP_INV_INPUT;  
    return(EXP_EVAL_ERROR);
  }

  if((f_arg1.data.real == MAXDOUBLE) || (f_arg2.data.real == MAXDOUBLE))
  {
    result->data.real = MAXDOUBLE;
    return( EXP_EVAL_ERROR ); 
  }

  switch (f_type)
  {
  case POW : 
    result->data.real = pow( f_arg1.data.real, f_arg2.data.real ) ;
    switch( errno ) 
    { 
    case EDOM   : 
      Error_Text( EXP_POW_DOM_ERR, (int *) &f_arg1.data.real );
      return( EXP_EVAL_ERROR );

    case ERANGE : Error_Text( EXP_POW_RNG_ERR, (int *) &f_arg1.data.real );
      return( EXP_EVAL_ERROR );

    default     : ;
    }
    break;

  case MAX : 
    result->data.real = ( f_arg2.data.real >= f_arg1.data.real ) ? f_arg2.data.real : f_arg1.data.real ;
    break;

  case MIN : 
    result->data.real = ( f_arg2.data.real <= f_arg1.data.real ) ? f_arg2.data.real : f_arg1.data.real ;
    break;

  case ATAN2 : 
    result->data.real = atan2( f_arg1.data.real, f_arg2.data.real ) ; 
    if( errno == EDOM ) 
    { 
      /* Won't compile (APOGEE)
         Error_Text( EXP_ATAN2_DOM_ERR, (int *) f_arg1.data.real );*/
      return( EXP_EVAL_ERROR );
    }
    break;

  default :  printf ( "yacc : unknown function identifier\n" );
  }
  return(EXP_SUCCESS);
}

/*--------------------------------------------------------------------------*/
/*   This procedure is used to evaluate ifinf and ifsup expressions
/*--------------------------------------------------------------------------*/
int ifcomp_function_eval(f_type, f_arg1, f_arg2, f_arg3, f_arg4, result)
int 	f_type;
struct 	data_struct f_arg1, f_arg2,f_arg3, f_arg4, *result;
{
  extern double pow(), atan2();

  result->type = REAL ;
  result->data.real = 0. ;
  if(NO_more_eval)  return(EXP_EVAL_ERROR);

  if( 	(f_arg1.type != REAL) || (f_arg2.type != REAL) || 
	(f_arg3.type != REAL) || (f_arg4.type != REAL)    )
  {
    /* no use to try to evaluate anything now */
    NO_more_eval |= EXP_INV_INPUT;  
    return(EXP_EVAL_ERROR);
  }


  if ((f_arg1.data.real == MAXDOUBLE) || (f_arg2.data.real == MAXDOUBLE) ||
      (f_arg3.data.real == MAXDOUBLE) || (f_arg4.data.real == MAXDOUBLE))
  {
    result->data.real = MAXDOUBLE;
    return( EXP_EVAL_ERROR ); 
  }

  switch (f_type)
  {
  case IFINF : 
    if(f_arg1.data.real<f_arg2.data.real)
      result->data.real = f_arg3.data.real;
    else
      result->data.real = f_arg4.data.real;
    break;

  case IFSUP : 
    if(f_arg1.data.real>f_arg2.data.real)
      result->data.real = f_arg3.data.real;
    else
      result->data.real = f_arg4.data.real;
    break;

  default :  printf ( "yacc : unknown function identifier\n" );
  }

  return(EXP_SUCCESS);
}
  
/* ------------------------------------------------------------------------
/*
/*     This function will parse a new expression and Return the result in
/*   *result.  
/*
/*     If an input string is given then it is parsed else input is
/*   requested from the keyboard.
/*
/*   Returns :
/*	 EXP_SUCCESS if the expression syntax is valid 
/*	
/*	 if not in this case 
/* 	 *result is quite irrelevant, but initialized).
/*
/*       id_list : the list of identifier appearing in the
/*	   expression(this space allocatted.
/*
/*	 num_id : the number of id in id_list_buffer
/*
/*       type_request,
/*       *type_obtained : has one of the value
/*			EXP_DISTANCE, EXP_ANGLE, EXP_SCALAR
/*							
/* -------------------------------------------------------------------------*/
#argsused
int new_exp_Parse ( syntax, result, id_list, id_count, 
 		    type_request, type_obtained)
  char 		*syntax;
  struct 	data_struct *result;
  char		***id_list;
  short	int	*id_count;
  char    	type_request, *type_obtained;
/*.new_exp_Parse */
{
  G_parse_type = FIRST_PARSE;
  NO_more_eval = 0; 		/* we start with good intentions */
  G_id_count = 0;		/* going to be determined	*/
  G_id_list = (char **)malloc(sizeof(char *));

  if(G_id_list == NULL)
  {
    Error_Text ( EXP_MEM_FAIL, (int *)"in parsing");
    return(EXP_MEM_FAIL);
  }

  if (syntax)
    input_stream = syntax;
  else
  {
    /*| syntax NULL pointer*/
    result->data.real = 0;
    return(EXP_SYNTAX_ERROR);
  }
  input_index=0;

  /* Init global static variables */

     Uncomputed_tree.num_nodes = 0;


     seen_solve_var = FALSE;


  /* call yacc and Returns its result */

  if(yyparse ())
/* JLA  28-nov-90 
/* change to what follow because when the syntax "." is parsed, 
/* yacc fails to evaluate the following syntax for a reason I don't know */
 
/*  if(   (syntax[0] == '.' && syntax[1] == '\0') 
/*     || yyparse ())
/***/
  {
    result->data.real = 0;
    return(EXP_SYNTAX_ERROR);
  }
  /*| yyparse worked */
  *result = Computed_value;

  if(Compress_ArgList( G_id_list, &G_id_count)!=EXP_S_SUCCESS)
  {
    /*| Compress_ArgList EXP_SYNTAX_ERROR */
    return(EXP_SYNTAX_ERROR);
  }
  *id_count = G_id_count;
  *id_list = G_id_list ;

  if(NO_more_eval & EXP_EVAL_ERROR)
  {
    /*| expression with good syntax but impossible to evaluate */
    /*| exp_Parse EXP_EVAL_ERROR */
    return(EXP_EVAL_ERROR);
  }
 
 if((NO_more_eval & EXP_NOT_FOUND) || (NO_more_eval & EXP_INV_INPUT))
  {
    /*| expression with good syntax but some ident not found  */
    /*| exp_Parse EXP_SYNTAX_ERROR */
    return( EXP_SYNTAX_ERROR);
  }
 
  /*" exp_Parse id_count< set: %d\n", *id_count */
  /*| exp_Parse Return EXP_SUCESS */


  /* expression is scalar and can be depending upon others  */

  *type_obtained = G_type_found;
  
  return(EXP_S_SUCCESS);
}

/* -------------------------------------------------------------------------*/

int compute_Parse ( count, parents_list, syntax, result )
	int		count;
	struct GRid	*parents_list;
        char 		*syntax;
        struct 		data_struct *result;
/*.compute_Parse */
{

  G_objid_list = parents_list;
  G_id_count = count;
  G_parse_type = COMPUTE_PARSE;

  NO_more_eval = 0; 	

  if (syntax)
    input_stream = syntax;
  else
  {
    result->data.real = 0;
    return(EXP_SYNTAX_ERROR);
  }
  input_index = 0;

  /* Init global static variables */

   Uncomputed_tree.num_nodes = 0;

   seen_solve_var = FALSE;


  /* call yacc and Returns its result */
  if(yyparse ()) 
  {
    /*| yyparse not SUCCESS*/
    result->data.real = 0;
    return(EXP_SYNTAX_ERROR);
  }
  *result = Computed_value;

  if(NO_more_eval & EXP_EVAL_ERROR)
  {
    /* expression with good syntax but impossible to evaluate */
    /*| exp_Parse EXP_EVAL_ERROR */
    return(EXP_EVAL_ERROR);
  }
 
  if((NO_more_eval & EXP_NOT_FOUND) || (NO_more_eval & EXP_INV_INPUT))
  {
    /* expression with good syntax but some ident not found  */
    /*| exp_Parse EXP_SYNTAX_ERROR */
    return( EXP_SYNTAX_ERROR);
  }
  return ( EXP_SUCCESS );
}

/* -------------------------------------------------------------------------*/

int EXP_evaluate(char *syntax, double *pvalue)
{
  int 		rc;
  struct 	data_struct result;
  char		**id_list;
  short	int	id_count;
  char    	type_request, type_obtained;

  type_request = 'X';
  in_cycle = FALSE;
  rc = new_exp_Parse ( syntax, &result, &id_list, &id_count, 
 		    type_request, &type_obtained);
  if (rc == EXP_S_SUCCESS)
    *pvalue = result.data.real;
  return(rc);
}

