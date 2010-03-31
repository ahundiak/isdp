/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method gets the loop ids and properties of this loop (and
invokes this method on its children, if the "depth" specified is , so
warrants). The caller can specify what kinds of loops are being
sought. The options can be one of the following - 
	EMS_OPT_ALL
	EMS_OPT_OPEN
	EMS_OPT_CLOSED
	EMS_OPT_SPLIT
	EMS_OPT_UNSPLIT
	EMS_OPT_PLOOP
	EMS_OPT_CLOOP
	
Assumption
	The method operates on a valid looptree in which all the channel
 connections between a parent loop and its children are in place.

History
	SM	03/31/87	Creation Date.
	SM	07-Dec-87	Ignore following options-
				EMS_OPT_ALL_WITH_FEATURES
				EMS_OPT_FEATURES.
				Also modified such that memory allocations
				for output are done if a loop is valid.
				
Algorithm
	Check buffer size and reallocate if necessary.
	If this loop satisfies the criterion specified by the input option
	 then put its id and props in the buffers.
	Send the message down to the children(if there are any).
*/


class implementation EMSloop;

#include "EMS.h"
#include "EMSopt.h"

#define LOOP_INC 10

method EMget_loops(IGRlong *EMmsg;IGRlong option;IGRint *depth;
                       GRobjid **loop_ids;
			IGRushort **props;
                       IGRint *buf_size,*count)
{
  IGRlong 		sts;
  OMuint		loops;
  OM_S_CHANSELECT 	to_inner;
  IGRboolean		valid = FALSE, unconditionally_descend;
  IGRint		i;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  EMerr_hndlr (*depth <= 0, *EMmsg, EMS_E_InvalidArg, wrapup);

/* If this loop is split and the option does not indicate that a split
   loop is asked for, I must ignore myself and proceed to my children.
*/  
  if ((ME.EMSloop->lp_props & EMLP_SPLIT) && 
      (option != EMS_OPT_ALL && option != EMS_OPT_SPLIT))
    unconditionally_descend = TRUE;
  else
   {
    unconditionally_descend = FALSE;

   switch(option)
    {
    case EMS_OPT_ALL:
	valid = TRUE;
      break;

    case EMS_OPT_OPEN:
      if(ME.EMSloop->lp_props & EMLP_OPEN) valid = TRUE;
      break;

    case EMS_OPT_CLOSED:
      if(! (ME.EMSloop->lp_props & EMLP_OPEN)) valid = TRUE;
      break;

    case EMS_OPT_SPLIT:
	if(ME.EMSloop->lp_props & EMLP_SPLIT) valid = TRUE;
      break;

    case EMS_OPT_UNSPLIT:
	if(!(ME.EMSloop->lp_props&EMLP_SPLIT)) valid = TRUE;
      break;

    case EMS_OPT_CLOOP:
	if(!(ME.EMSloop->lp_props&EMLP_PLOOP)) valid = TRUE;
      break;

    case EMS_OPT_PLOOP:
	if(ME.EMSloop->lp_props&EMLP_PLOOP) valid = TRUE;
      break;

    case EMS_OPT_ALL_WITH_FEATURES:
    case EMS_OPT_FEATURES:
      break;

    case EMS_OPT_ACTIVE:
	if(ME.EMSloop->lp_props & EMLP_ACTIVE) valid = TRUE;
      break;
        
    default:
      *EMmsg = EMS_E_InvalidArg;
      break;

    } /* switch(option) */

  if(valid)
   {
	
     if(buf_size && (!(*buf_size)))
      {
       if(*count)
        {
	  if(loop_ids)
            *loop_ids = (GRobjid *) om$realloc(ptr=(char *)*loop_ids,size=
				(*count+LOOP_INC)*sizeof(GRobjid));
	  if(props)
	    *props = (IGRushort *) om$realloc(ptr=(char *)*props,size=
			(*count+LOOP_INC)*sizeof(IGRushort));
        }
       else
        {
	  if(loop_ids)
            *loop_ids = (GRobjid *) om$malloc(size=LOOP_INC*sizeof(GRobjid));
          if(props)
	    *props = (IGRushort *) om$malloc(size=LOOP_INC*sizeof
				(IGRushort));
        }
       if(loop_ids)
         EMerr_hndlr((!*loop_ids),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       if(props)
         EMerr_hndlr(!*props,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       *buf_size = LOOP_INC;

     } /* if(buf_size && !(*buf_size)) */

    if(loop_ids)  (*loop_ids)[*count]= my_id;
    if(props)     (*props)[*count] = ME.EMSloop->lp_props;
    (*count)++;
    if(buf_size) (*buf_size)--;

   } /* if(valid) */

  } /* else 'unconditionlly_descend = FALSE' */

  if (!unconditionally_descend)
    (*depth)--;
  if (unconditionally_descend || *depth > 0)
    {
    IGRint loc_depth;

    to_inner.type = OM_e_addr;
    to_inner.u_sel.addr = &ME.EMSloop->to_inner;
   
    sts = om$get_channel_count(object=me,p_chanselect=&to_inner,
                                   count = &loops);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  
    for (i=0; i<loops; i++)
      {
      loc_depth = *depth;
      sts = om$send(msg = message EMSloop.EMget_loops
                        (EMmsg,option,&loc_depth,loop_ids,props,buf_size,
                        count),
                      p_chanselect = &to_inner, from = i, to = i);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
      }
    }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMget_loops")
  return(sts);

}

end implementation EMSloop;
