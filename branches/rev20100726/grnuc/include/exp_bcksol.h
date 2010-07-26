/*

Name
  exp_bcksol.h

Description

 Typedefs for symbolic backsolving of equational constraints.
 Initial Revision: K. Singh

Notes


 */

/*
 * Typedefs for symbolic backsolving of equational constraints.
 * Initial Revision: K. Singh
 */



typedef struct
{
   short type;                 /* which type of NODE is it ? */
   IGRboolean first_operand;   /* is unknown operand the first operand? */
   int op;                     /* the operator code */
   struct data_struct operand; /* one of the two operands */
} OPERATOR_NODE;


typedef struct
{
   short type;         /* which type of NODE is it ?*/
   int funct_code;     /* function code */
   int num_args;       /* number of arguments which are present*/
   int unknown_arg;    /* which argument is the unknown argument*/
   struct data_struct arg_value;   /* value of known arg */
} FUNCTION_NODE;


#define MAX_NUM_NODES 256

typedef struct
{
   int  num_nodes;                 /* number of NODEs */
   char *node_ptr [MAX_NUM_NODES]; /* pointers to NODEs   */
} UNCOMPUTED_PARSE_TREE;


#define IS_OP_NODE    1
#define IS_FUNCT_NODE 2

#define NULL_OPERAND 100
