/*

Name
  exp_invop.C

Description
  This file has routines to perform arihtmetic
  operations to symolicaly invert arithmetic operations.

Notes


 */

#include "igrtypedef.h"
#include "expression.h"
#include "expy.h"
#include "exp_bcksol.h"
#include "stdio.h"
#include <malloc.h>


/* Imports from expy.y */

/* Value of the LHS or RHS of equational constraint which has been computed */

extern struct data_struct Computed_value;


/*

Name
  Inv_op

Abstract

 * Inv_op() - Perform inverse arithmetic operation for each operator node
 * in the parse tree

Synopsis

int op;                   IN the arithmetic operation to be inverted
IGRboolean first_operand; IN is the known operand the first operand
struct data_struct operand; IN the known operand

Description

Return Value

Notes

Index

Keywords
  equation,parsing

History
  03/04/93 : Kapil Singh : created

 */
int Inv_op(op, first_operand, operand)
int op;
IGRboolean first_operand;
struct data_struct operand;
{
  struct data_struct result1;        /* intermediate result */
  struct data_struct result2;        /* intermediate result */


  switch(op)
  {
  case '+' : 
    numeric_eval(&Computed_value, Computed_value, operand, '-');
    break;

  case '-' :
    if (first_operand)
      numeric_eval(&Computed_value, Computed_value, operand, '+');
    else
      numeric_eval(&Computed_value, operand, Computed_value, '-');    
    break;

  case '*' : 
    numeric_eval(&Computed_value, Computed_value, operand, '/');
    break;

  case '/' : 
    if (first_operand)
      numeric_eval(&Computed_value, Computed_value, operand, '*');
    else
      numeric_eval(&Computed_value, operand, Computed_value, '/');    
    break;

  case '^' : 

    if (! first_operand)                   /*  a^x = rhs   */
    {

      un_function_eval(LOG, Computed_value, &result1);      
      un_function_eval(LOG, operand, &result2);      
      numeric_eval(&Computed_value, result1, result2, '/');           
    }
    else                            	  /*  x^a = rhs   */
    {
      result1.data.real = 1.0;
      numeric_eval(&result2, result1, operand, '/');
      bin_function_eval(POW, Computed_value, result2, &Computed_value);
    }
    break;


  default : 
  printf ( "Unknown Operation\n" );
  }
  return (EXP_SUCCESS);
}
/*

Name
  Inv_funct

Abstract

 * Inv_funct() - Perform inverse operation for each function node
 * in the parse tree

Synopsis
int funct_code;     IN  function code 
int num_args;       IN  number of arguments which are present
int unknown_arg;    IN  which argument is the unknown argument
struct data_struct arg_value; IN  value of known arg 

Description

Return Value

Notes

Index

Keywords
  equation,parsing

History
  03/04/93 : Kapil Singh : created

 */
int Inv_funct(funct_code, num_args, unknown_arg, arg_value)
int funct_code;     /* function code */
int num_args;       /* number of arguments which are present*/
int unknown_arg;    /* which argument is the unknown argument*/
struct data_struct arg_value;   /* value of known arg */
{
  struct data_struct result1;        /* intermediate result */
  struct data_struct result2;        /* intermediate result */

  if (num_args == 1)
  {
    switch (funct_code)
    {
  
      case SIN : 
        un_function_eval(ASIN, Computed_value, &Computed_value); 
        break;
    
      case COS : 
        un_function_eval(ACOS, Computed_value, &Computed_value); 
        break;
    
      case ABS : 
        break;
    
      case ACOS : 
        un_function_eval(COS, Computed_value, &Computed_value); 
        break;

      case ASIN : 
        un_function_eval(SIN, Computed_value, &Computed_value); 
        break;
    
      case ATAN : 
        un_function_eval(TAN, Computed_value, &Computed_value); 
        break;
    
      case EXP : 
        un_function_eval(LOG, Computed_value, &Computed_value);      
        break;
    
      case LOG : 
        un_function_eval(EXP, Computed_value, &Computed_value);            
        break;
     
      case SQRT : 
        numeric_eval(&Computed_value, Computed_value, Computed_value, '*');      
        break;
    
      case TAN : 
        un_function_eval(ATAN, Computed_value, &Computed_value); 
        break;
     
      case INT : 
        break;
      
      default :  printf ( "Invert : unknown unary function identifier\n" );
        break;
    }
  }
  else if (num_args == 2)
  {
    switch (funct_code)
    {
      case POW : 
	if (unknown_arg == 1)   /* val = pow(a,x) */
	{
	   un_function_eval(LOG, Computed_value, &result1);      
      	   un_function_eval(LOG, arg_value, &result2);      
      	   numeric_eval(&Computed_value, result1, result2, '/');           
	}
	else if (unknown_arg ==0) /* val = pow(x,b) */
	{
	   result1.data.real = 1.0;
	   numeric_eval(&result2, result1, arg_value, '/');
	   bin_function_eval(POW, Computed_value, result2, &Computed_value);
	}
        break;
    
      case MAX : 
        break;
    
      case MIN : 
        break;
    
      case ATAN2 : 

        un_function_eval(TAN, Computed_value, &result1); 

	if (unknown_arg == 1)		/* val = atan2(a, x) */
	{
	   numeric_eval(&Computed_value, arg_value, result1, '/');		
	}
	else if (unknown_arg ==0)	/* val = atan2(x, b) */
	{
	   numeric_eval(&Computed_value, arg_value, result1, '*');
	}
        break;
    
      default :  printf ( "Inverse : unknown binary function identifier\n" );
    }
  }
  return(EXP_SUCCESS);
}



