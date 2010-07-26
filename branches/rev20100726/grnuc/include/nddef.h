/*

Name
  nddef.h

Description
  constant for NDnode and graph manager
  
Notes


 */

#ifndef nddef_include
#define nddef_include

#include "GMdef.h"

/*
ABSTRACT

     constant for NDnode and graph manager

DEPENDENCIES

     GMdef.h

HISTORY

     jla - dp dec  87 design date
     jla -    june 88 changes in constant name
	      ND_NG, ND_NL .... --> ND_
     dp  - modifications to use GM software
 */



/*****************************************************************************

  CONSTANT USED FOR NDnode MESSAGE CALL

*****************************************************************************/

/*
 * Returned object on a NDget_objects message
 */


/* ND_ROOT is defined later in this file as GM_ROOT, which has been defined   */
/* as 0x0001, and is thus equivalent. I am removing this one after	      */
/* consultation with H. Bequet.      					      */
/* #define ND_ROOT     1  return roots of the element                         */

#define ND_CHILDREN 2  /* return children of the element 	              */
#define ND_IN_BUF   4  /* objects are returned using a buffer provived by     */
		       /* NDget_object message 			              */


/*
 *  connection of an object to its parents : NDconnect message
 */

#define ND_NEW       0 /* first connection of the element  		      */
#define ND_FULL      1 /* full redefinition of connection  		      */
#define ND_ADD       2 /* add connection to existing ones  		      */


/*
 * possible return code of the NDupdate message
 */

#define ND_COMP_SUCC     MSSUCC /* successfull completion 		      */
#define ND_COMP_SAME        0X5 /* successfull completion. The element has    */
			        /* not changed geometry or value              */
#define ND_COMP_FAIL        0X2 /* error when recomputing element or one of   */
				/* parent of the element is in error          */
#define ND_COMP_OUT_OF_DATE 0x4 /* element is out of date (because the user   */
				/* has pressed the stop button or because one */
				/* of the parent is out of date 	      */
#define ND_COMP_REST  0x9       /* compute of the dependent graph must be     */
				/* restarted */
			  


/*
 *  possible state of an element of the graph
 *  (NDchg_state and NDget_state message)
 */

#define ND_DEFAULT   0x00 /* default state				    */
#define ND_DEGRADED  0x01 /* degraded element 			            */
#define ND_DONT_MVRT 0x02 /* This element will delete itself when one of its*/
			  /* parent is deleted				    */
#define ND_DEL_NO_CH 0x10 /* The element will deleted itselfafter           */
			  /* disconection of its last children              */
#define ND_SUP_ONLY  0x12 /* The element is support only : it must be deleted */
                          /* if one of its root or all its dependents are     */
                          /* deleted. Thus it unions                          */
                          /* ND_DEL_NO_CH and ND_DONT_MVRT                    */
/*
 * The following states (flags) have been defined for supporting
 * equational constraints. (KS)
 */
#define ND_VISITED  0x40 	/* The node has been visited during */ 
                                /* traversal for matching  */
#define ND_COMPUTE_OVER	0x20

/* Following states will be removed ASAP */

#define ND_WAIT_DEL  0x20 /* removed in 2.0 translator --> can be reused      */
                          /*
                           * Now this flag is being reused as ND_COMPUTE_OVER 
                           */
/*
 * ***************************************************************************
 */
#define ND_ERA_DEL   0x40 /* removed in 2.0 translator --> can be reused 
                          /* PLEASE NOTE PLEASE NOTE ++++++++++++++++++++     */
                          /* The ND_ERA_DEL is being reused as ND_VISITED     */
/*
 * *************************************************************************
 */                          

#define ND_INST_OVER 0x80
#define ND_OUT_OF_RT 0x04 /* State used by before 1.3.2 macros to know which  */
                          /* elements were constructions. Will be reused when */
                          /* we will get rid of this kind of macros           */
#define ND_DIS_BY_CH 0x08 /* the element is displayed by one of its	    */
                          /*  (children) partial delete		            */



/*
 *  argument cp_type in NDcopy_graph, NDcopy, NDcopy_to_root
 *  to inform object if copy is  to macro definition or from macro definition
 *
 */

#define  ND_TO_MACRO   0x1 /* object is copied  to macro definition           */
#define  ND_FROM_MACRO 0x2 /* object is copied from macro definition          */
			   /* NB when copying a macro definition from a macro */
			   /* to another cp_type = NB_FROM_MACRO|ND_TO_MACRO  */
#define  ND_INSIDE_MACRO 0x4 /* object is copied from a macro definition to   */			   /* another          				      */

/* 
 * additional info for NDcopy_to_Groot
 *
 */

#define ND_TO_DEF_TEMP 0X10 /* object is copied to Groot to become  default   */
			    /* template of the macro			      */
 
				

/*
 *  argument cn_type ND(s)_compute_node, NDupdate message
 *
 */

#define ND_COMP_TYPE  0Xff /* this part of cn_type defines the type of        */
			   /* compute 					      */

#define ND_COMP_XF    0x1      /* The element receiving the compute node has  */
			       /* receveived a GRxform	 		      */
#define ND_COMP       0x2      /* This element notify change in position and  */
			       /* need to be recomputed 		      */
#define ND_COMP_FROM_MACRO 0x3 /* This is the first compute of the element    */
			       /* after placement of a macro in expand        */
			       /* mode 				              */
#define ND_COMP_STOPPED 0X4    /* The user has pressed the stop button. The   */
			       /* element should not recompute and should     */
			       /* return msg = ND_COMP_OUT_OF_DATE            */
#define ND_COMP_IN_LIB  0X5    /* The element is computed in a macro library  */


#define ND_COMP_ADD_INFO  0Xff00  /* this part of cn_type is for additional */
				  /* info like display or rtree */

#define ND_COMP_NO_ERASE   0X100  /* should not be erase before recompute     */
#define ND_COMP_NO_REM_RT  0X200  /* should not be remove from RT before      */
				  /* recompute  			      */
#define ND_COMP_NO_ADD_RT  0X400  /* should not be add to RT after recompute  */
#define ND_COMP_NO_DISPLAY 0X800  /* should not be display after recompute    */

/*****************************************************************************

  CONSTANT USED FOR NDmacro MESSAGE CALL (ACbecome_macro)

*****************************************************************************/

#define ND_INVAL_MAC 0x0   /* This macro is not valid  */
#define ND_DROP_MAC  0x1   /* This macro can be placed in "drop mode"      */
#define ND_CONS_MAC  0x2   /* This macro can be placed in "construct mode" */
#define ND_SYMB_MAC  0x4   /* This macro can be placed in "symbol mode"    */


/*****************************************************************************

  CONSTANT USED FOR GRAPH MANAGER PRIMITIVES

******************************************************************************/

/*
 * Type of elements in a selected graph
 */

#define ND_INIT   GM_INIT /* Initial elements of the graph : the element is in*/
                          /* p_initial argument list of nd$get_graph or       */
                          /* nd$get_internal_graph                            */

#define ND_ROOT   GM_ROOT /* Root elements of the graph : the element is in   */
                          /* p_initial argument list of nd$get_graph or       */
                          /* nd$get_internal_graph and is a root of the graph */

#define ND_TIP    GM_TIP  /* Tip elements of the graph  : the element is in   */
                          /* p_tip list of the nd$get_graph call	      */

#define ND_BODY   GM_BODY /* Body elements of the graph : the element has     */
                          /* parents in the selected graph                    */

#define ND_LEAF   GM_LEAF /* Elements - not in the tip list of nd$get_graph   */
			  /*	      -  without children 		      */

#define ND_EXTERN GM_EXTERN/* Extern elements of the graph : elements which   */
                          /* are not in the tip list and which are parents    */
                          /* of body elements of the graph	              */


/*
Option for nd$copy_graph
*/

#define ND_CON_TIP_LIST  0x0001/* the parents of the tips of the copied graph */
			       /* are connected to the tip list specified in  */
			       /* the copy_graph macro  (default value)       */

#define ND_COPY_TIP      0x0002/* The list of target tips is not specified in */
                               /* the ND$graph_copy primitive. The from tips  */
                               /* are copied.                                 */

/*
Differents connections for the EXTERN elements
----------------------------------------------
*/

#define ND_CON_EXT_GRAPH 0x0004/* The copied graph is reconnected to the ori- */
                               /* -ginal externs of the graph (default value) */
                               
#define ND_CON_EXT_LIST  0x0008/* The copied graph is reconnected to the      */
                               /* externs passed in the nd$copy_graph         */
			       /*  arguments (NOT IMPLEMENTED)                */

#define ND_COPY_EXT      0x0010/* If there are extern elements in the selected*/
			       /* graph, these elements are copied to non     */
			       /* associative. The copied graph is connected  */
			       /* to the clones of the externs		      */

/* 
root compute argument for the macro nd$update_graph
---------------------------------------------------
*/

#define ND_UPT_ROOT       0x1
#define ND_DONT_UPT_ROOT  0x2
#define ND_VAR_UPT 	  0x4  

/*
  Additionnal information for broadcast_graph
  -------------------------------------------
*/

#define ND_ORDER   GM_ORDER  /* message is sent to root before children       */
			     /* ("up down")                                   */
#define ND_REVERSE GM_REVERSE/* message is sent to children before root       */
			     /* ("down up")				      */


/*
  Exec batch : what need to be erase before compute and displayed after 
  ---------------------------------------------------------------------
*/

#define ND_DISP_ROOT 0x1  /* the root elements 				  */
#define ND_DISP_BODY 0x2  /* the body elements				  */

/*
  for defer_flag of nd$exec_batch()
 */
#define  ND_CONDITIONAL      (0)  /* executes iff nd$mod_batch mode != ND_DEFER */
#define  ND_UNCONDITIONAL    (1)  /* executes regardless of nd$mod_batch mode   */


/*
  Batch mode set or inquire usin nd$batch_mode primitive
  ------------------------------------------------------
*/

#define ND_SET    0      /* set the batch mode to request mode             */
#define ND_INQ    1      /* return the batch mode in return mode           */


/*
  Batch mode type in  nd$batch_mode primitive 
  -------------------------------------------
*/

#define ND_TRANSACTION 0 /* update or copy is done at end of transacation  */
			 /* that means before each user input and not in   */
			 /* dynamics					   */
#define ND_IMMEDIATE   1 /* update or copy is immediate --> in dynamics    */
#define ND_DEFER       2 /* update or copy done when request by a          */
                         /* nd$batch_exec call                             */

/*
  Graph mode type in  nd$graph_mode primitive 
  -------------------------------------------
*/
#define  ND_BROAD_COP    0x1 /*elements depending upon copied elements are    */
			     /*also copied 				      */
#define  ND_NO_BROAD_COP 0x2 /*only selected elements are copied	      */

#define  ND_CONN_COP     0x4 /* roots of the copied graph are reconnected     */
			     /* to the parents of the corresponding original  */
			     /* element 				      */
#define  ND_NO_CONN_COP  0x8 /* roots of the copied graph are not reconnected */
			     /* and are moved to regular.		      */

#define  ND_BROAD_DEL    0x10/* elements depending upon deleted elements      */
			     /* are also deleted			      */
#define  ND_NO_BROAD_DEL 0x20/* only selected elements are deleetd. Their     */
			     /* children are moved to regular		      */
   
#endif
