/*
  expression.h
  sf oct-07-87
*/

#ifndef expression_include

#define expression_include


/*--------------------------------------------------------------------------*/
/* type used for the parser stack and exp_Parse argument 
/*--------------------------------------------------------------------------*/
/*
 *  There is a status field for pruning of parse trees.
 */
struct data_struct
{
  int status; /* status for pruning of the parse tree  */
  int type /* wich type of data for the union */;
  union data_union
  {
    double real;
    int    integer;
    char   string [80];
    char   boolean;
  }data;
  int	unit_type; /* used to do type analysis */
};


#define EPSILON		1e-20
#define EXP_LIM		38

/*
  The defined constants below identify the different possible 
  status of the nodes in the uncomputed parse tree.
*/

#define COMPUTED_NODE 			1
#define UNCOMPUTED_LEAF_NODE		2
#define UNCOMPUTED_INTERMEDIATE_NODE	3


/*
 * The defined constant below is the maximum number of
 * equations that are traversed to find a matching
 * for a new equation.
 */

#define MAX_VISIT_EQN	500

/*
 *  The constant below is the limit on the number of variables 
 *  that can occur in an equation.
 */

#define MAX_NUM_EQN_VAR	100

/*--------------------------------------------------------------------------*/
/*   Type used for expressions( all the expressions are necessarily of
/* one of this type). The type is defined at creation and can be changed
/*--------------------------------------------------------------------------*/

#define	EXP_DOUBLE	0
#define EXP_TEXT	4

#define EXP_WORKING	0
#define EXP_DEFAULT	1

/*---------------------------------------------------------------------------*\
 | Constants used in Expression.I and The EXP_...'s are return codes.        |
 | Their meaning is explained in expression.S                                |
\*---------------------------------------------------------------------------*/

	#define WARN 0
	#define SUCC 1
	#define ERRO 2
	#define INFO 3
	#define SEVE 4

	#define EXP_S_SUCCESS 		1
	#define EXP_SUCCESS   		1

	#define EXP_E_ABORT    		(ERRO | 0x210)
      	#define EXP_E_NOT_FOUND 	(ERRO | 0x220)
	#define EXP_NOT_FOUND  		(ERRO | 0x220)
	#define EXP_E_INV_INPUT 	(ERRO | 0x230)
	#define EXP_INV_INPUT   	(ERRO | 0x230)
	#define EXP_E_TOO_LONG		(ERRO | 0x240)
	#define EXP_TOO_LONG    	(ERRO | 0x240)
	#define EXP_E_MEM_FAIL		(ERRO | 0x250)
	#define EXP_MEM_FAIL		(ERRO | 0x250)
	#define EXP_E_INV_NAME		(ERRO | 0x260)
	#define EXP_INV_NAME		(ERRO | 0x260)
	#define EXP_E_SYNTAX_ERROR   	(ERRO | 0x270)
	#define EXP_SYNTAX_ERROR   	(ERRO | 0x270)
	#define EXP_E_RECUR_DEF      	(ERRO | 0x280)
	#define EXP_RECUR_DEF      	(ERRO | 0x280)
	#define EXP_E_UNDEF_RHS      	(ERRO | 0x290)
	#define EXP_UNDEF_RHS      	(ERRO | 0x290)
	#define EXP_E_ALREADY_EXISTS 	(ERRO | 0x2A0)
	#define EXP_ALREADY_EXISTS 	(ERRO | 0x2A0)
	#define EXP_E_DEL_IMPOSSIBLE 	(ERRO | 0x2B0)
	#define EXP_DEL_IMPOSSIBLE 	(ERRO | 0x2B0)
 	#define EXP_E_INV_CHAR    	(ERRO | 0x2C0) 
 	#define EXP_INV_CHAR   		(ERRO | 0x2C0)  

  	#define EXP_EVAL_ERROR  	(ERRO | 0x2D0) 

		#define EXP_SQRT_DOM_ERR (ERRO | 0x2E0)
		#define EXP_POW_DOM_ERR  (ERRO | 0x2F0)
		#define EXP_POW_RNG_ERR  (ERRO | 0x300)
		#define EXP_ASIN_DOM_ERR (ERRO | 0x310)
		#define EXP_ACOS_DOM_ERR (ERRO | 0x320)
		#define EXP_ATAN2_DOM_ERR (ERRO | 0x330)
		#define EXP_LOG_DOM_ERR  (ERRO | 0x340)
		#define EXP_EXP_RNG_ERR  (ERRO | 0x350)
		#define EXP_COS_RNG_ERR  (ERRO | 0x360)
		#define EXP_SIN_RNG_ERR  (ERRO | 0x370)
		#define EXP_TAN_RNG_ERR  (ERRO | 0x380)
		#define EXP_ARG_NUM_ERR  (ERRO | 0x390)
		#define EXP_ZERO_DIVIDE  (ERRO | 0x3A0)
		#define EXP_OVERFLOW     (ERRO | 0x3B0)
		#define EXP_UNDERFLOW    (ERRO | 0x3C0)
		#define EXP_CONV_ERR     (ERRO | 0x3D0)
		#define EXP_CALC_ERR     (ERRO | 0x3E0)
          	#define EXP_E_LOOP       (ERRO | 0x3F0)
          	#define EXP_INV_REF_FILE (ERRO | 0x500)
		#define EDOM                33
		#define ERANGE              34


	#define EXP_W_NAME_NOT_FOUND 	(WARN | 0x400)
	#define EXP_W_EXP_NOT_FOUND  	(WARN | 0x410)
	#define EXP_W_NOT_IMPL       	(WARN | 0x420)

	#define EXP_I_     		(INFO | 0x4300)

#define EXP_MAX_LEN	128

/*----	flag telling yyparse if first parse or compute parse with the  */
/*----	internal format */

#define	FIRST_PARSE 	0
#define COMPUTE_PARSE	1

/*----	flag determining the action of EXP_universal_to_named -----------*/

#define REL_TO_GPTR_PREFIX  0
#define REL_TO_CREAT_DIR    1
#define REL_TO_CUR	    2

/*----- flag determining the action of EXP_substitute -------------------*/

#define EXP_SUBST  	    0
#define EXP_STRONG_SUBST    1

#define EXP_SUBST_ALL  	    0
#define EXP_SUBST_FIRST     1

/*----- type filled by ci before sending a place -------------------------*/

typedef struct { char name [EXP_MAX_LEN], syntax [EXP_MAX_LEN];
                   double value; } exp_data;

/* -----------------------------------------------------------------------*/

#define Error( stat, msg )\
            if( !(stat&1) )\
                        { fprintf( stdout, "%s\n", msg ) ;\
                          om$report_error( sts = stat )        ;\
                          return( OM_W_ABORT )           ;\
                        }
#define EXPR_VLAS GRTEXT_VLAS + 2

/*---------------------------------------------------------------------------
/* this macro will check if the current expression is the one
/* supposed to received the message
/*---------------------------------------------------------------------------*/
#define EXP_good_one(name, pobjid, prc, msgtodisp)\
{\
  OM_S_OBJID owner_id;\
  \
  if(name!=NULL)\
    if(strcmp(name, "") != 0)\
    {\
      EXP_find_exp( name, pobjid, &owner_id, prc);\
      if( *prc == EXP_NOT_FOUND )\
      {\
        *prc  = EXP_UNDEF_RHS;\
        Error_Text( EXP_UNDEF_RHS, (int *) name ) ;\
        return( OM_S_SUCCESS );\
      }\
      if (!IF_EQ_OBJID(my_id, *(pobjid)))\
      {\
	IGRlong status;\
        status = om$send(msg = msgtodisp, \
		       senderid = my_id,\
		       targetid = *(pobjid));\
        return ( OM_S_SUCCESS );\
      }\
    }\
}

#endif
