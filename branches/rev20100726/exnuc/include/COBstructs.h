




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                          < 1986, 1987, 1988 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* COBstructs.h */
#ifndef _COB_structs_dot_h
#define _COB_structs_dot_h

#include "COBlist_tool.h"

/*** a "state" structure ***/
struct COBstate
{
  int			state_id;
  long			mask;

  _COB_list ( struct COBstate, list );	/* next & prev state ptrs	  */
  struct COBact_trans * act_trans;	/* ptr to state's actions & trans */
};


/*** an "action" structure ***/
struct COBaction
{
  char	    class_name[13]; /* class name of method		*/
  short	    num_args;	    /* # of arguments to message	*/
  char	  * message_name;   /* method name to send  		*/

  char   ** args;	  /* individual arg strings      	*/
  short   * args_index;	  /* indiv. arg's indices into values[] */
  short   * is_const;	  /* 1 => individual arg value is const */
  char	  * values;	  /* individual argument values         */
};

/*** a "transition" structure ***/
struct COBtrans
{
  short	     next_state_id;	/* state # of next state */

  short	     num_pods;		/* # of ( pred, op, data ) triples */
  int	   * predicate;		/* predicate code ( EX_DATA, etc ) */
  int	   * operator;		/* operator code ( =, >, etc )	   */
  data_val * data;		/* data value	 ( 13, "yes", etc )*/

  struct COBact_trans * act_trans;
};

struct COBact_trans
{
  union
    {
      struct COBaction	action;
      struct COBtrans   trans;
    } at;
  char	is_trans;		/* 0 => action; 1 => transition */

  _COB_list ( struct COBact_trans, list );
};

#endif
