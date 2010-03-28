/*

Name
  exp_bcksol.C

Description
  Routines to backsolve equational constraints,  
  called from yyparse()

Notes


 */


/******************************************************************************
 *
 *    exp_bcksol.C
 *    Routines to backsolve equational constraints,  called from yyparse()
 *
 *    Initial Revision: K. Singh
 * 
 *****************************************************************************/

#include "igrtypedef.h"
#include "expression.h"
#include "expy.h"
#include "exp_bcksol.h"
#include "stdio.h"
#include <malloc.h>
#include <alloca.h>


/* Imports from expy.y */

/* Value of the LHS or RHS of equational constraint which has been computed */

extern struct data_struct Computed_value;

/* Trimmed parse tree for the side of the expression which has not been computed */

extern UNCOMPUTED_PARSE_TREE Uncomputed_tree;

/*

Name
  Add_op_node

Abstract
  Add a operator node to the list of nodes 
  
Synopsis
  
  OPERATOR_NODE *pop_node;  IN  pointer to newly allocated op node 
  int op;                   IN the operator code 
  IGRboolean first_operand; IN Is the operand the first operand 
  struct data_struct operand; IN the value of one of the operands
  
Description

Return Value
  EXP_SUCCESS

Notes

Index

Keywords
  associative,equation

History
  03/03/93 : Kapil Singh : created

 */
int Add_op_node (pop_node, op, first_operand, operand)
OPERATOR_NODE *pop_node;  /* pointer to newly allocated op node */
int op;                   /* the operator code */
IGRboolean first_operand; /* Is the operand the first operand */
struct data_struct operand; /* the value of one of the operands */
{
   int num_nodes;

/* set the value of the fields in the newly allocated node */
   num_nodes = Uncomputed_tree.num_nodes;
   if (num_nodes >= (MAX_NUM_NODES - 1)) return(EXP_MEM_FAIL);
   Uncomputed_tree.node_ptr[num_nodes] = (char *)pop_node;
   pop_node->type = IS_OP_NODE;
   pop_node->op = op;
   pop_node->first_operand = first_operand;
   pop_node->operand = operand;
   ++Uncomputed_tree.num_nodes;
   return(EXP_SUCCESS);
}

/*

Name
  Add_funct_node

Abstract
  add a function node to the node list 
  
Synopsis
  
  int funct_code;   IN the function code 
  int num_args;     IN total number of arguments 
  int unknown_arg;  IN the position of the unknown arg 
  struct data_struct arg_value; IN arg value
  
Description

Return Value

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
int Add_funct_node(pfunct_node, funct_code, num_args, unknown_arg, arg_value)
FUNCTION_NODE *pfunct_node; /* pointer to the newly allocated function node*/
int funct_code;   /* the function code */
int num_args;     /* total number of arguments */
int unknown_arg;  /* the position of the unknown arg */
struct data_struct arg_value; /* arg value */
{
   int num_nodes;

/*  set the fields of the newly allocated function node */
   num_nodes = Uncomputed_tree.num_nodes;
   if (num_nodes >= (MAX_NUM_NODES - 1)) return(EXP_MEM_FAIL);
   Uncomputed_tree.node_ptr[num_nodes] = (char *)pfunct_node;
   pfunct_node->type = IS_FUNCT_NODE;
   pfunct_node->funct_code = funct_code;
   pfunct_node->num_args = num_args;
   pfunct_node->unknown_arg = unknown_arg;
   pfunct_node->arg_value = arg_value;

   ++Uncomputed_tree.num_nodes;
   return(EXP_SUCCESS);
}

/*

Name
  Backsolve_eqn_constr

Abstract
 Perform all the arithmetic operations to backsolve eqn 

Synopsis

Description

Return Value

  EXP_SUCCESS

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
int Backsolve_eqn_constr()
{
   int num_nodes;
   short *pnode;
   short node_type;
   OPERATOR_NODE *pop_node;
   FUNCTION_NODE *pfunct_node;
   struct data_struct operand;

   /* get the total number of nodes */
   num_nodes =  Uncomputed_tree.num_nodes;

   /* loop thru all the nodes in the reverse order and call the function */
   /* inversion routine or the operator inversion routine */
   while (num_nodes > 0)
   {
      --num_nodes;
      pnode = (short *) Uncomputed_tree.node_ptr[num_nodes];
      node_type = *pnode;
      if (node_type == IS_OP_NODE) /* is the node a op node */
      {
         pop_node = (OPERATOR_NODE *)pnode;
         /* invert the arithmetic operation */
         /* first, check for unary operations */
         if (pop_node->first_operand == NULL_OPERAND)
           operand.data.real = 0.;
         else
           operand = pop_node->operand;
         Inv_op(pop_node->op, pop_node->first_operand, operand);
      }
      else if (node_type == IS_FUNCT_NODE) /* is the node a function node */
      {
         pfunct_node = (FUNCTION_NODE *) pnode;
        /* invert the function */
         Inv_funct(pfunct_node->funct_code, pfunct_node->num_args,
              pfunct_node->unknown_arg, pfunct_node->arg_value);
      }

   }

   return(EXP_SUCCESS);
}
