/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines the nesting of a point inside a looptree.
    It returns the innermost loop inside which the point was(if it was not
    on vertex or on edge).
Assumption
	The method operates on a valid looptree in which there are no
    intersecting loops.
History
	SM	03/10/87	Creation date
        NP      05/25/92        Added function calls to time this method.
*/

class implementation EMSloop;

#include "EMS.h"

#include "emsmacros.h"
#include "timerdef.h"

extern IGRboolean _use_timers;

static void EMtransfer(fromloc, toloc)
struct EMSptloc_info *fromloc, *toloc;
{
 toloc->location = fromloc->location;
 toloc->loop_id = fromloc->loop_id;
 toloc->num_located_edges = fromloc->num_located_edges;
 if(fromloc->edge[0].nst_pt.dist < toloc->edge[0].nst_pt.dist)
  toloc->edge[0] = fromloc->edge[0];
}

method EMptnesting(IGRlong *EMmsg;IGRdouble *pt;struct EMSptloc_info *info;
		    struct EMSpartolbasis *partolbasis)
{
  IGRlong sts;
  struct EMSptloc_info local_info;

  /* start timer for EMptnesting */
  if (_use_timers)
    start_timer (T_EMPTNESTING);

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  /*
   * Find the location with respect to this loop.
   */
  local_info.location = EMS_L_UNKNWN;
  local_info.options = info->options;
  local_info.num_located_edges = 0;

  /* start timer for pt location */
  if (_use_timers)
    start_timer (T37_PT_LOCATION);

/* Determine the location of the point wrt me.
*/
  sts = om$send(msg = message EMSloop.EMpt_location
				(EMmsg,pt,&local_info,partolbasis),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

  /* stop timer for pt location */
  if (_use_timers)
    stop_timer (T37_PT_LOCATION, FALSE, "");


  switch(local_info.location)
  {
    case EMS_L_ONVRTX: case EMS_L_ONEDGE:
      /*
       * The exact location is known.
       */
      *info = local_info;
      sts = OM_I_STOP_SENDING;
      break;

    case EMS_L_INSIDE:
      /*
       * Pass the message to the inner loops.
       */
      {
	OM_S_CHANSELECT inner_channel;

	if(info->options & EMS_PTLOC_CLOSEST_EDGE)
	 EMtransfer(&local_info, info);
	else
	 *info = local_info;
	
        inner_channel.type = OM_e_addr;
        inner_channel.u_sel.addr = &ME.EMSloop->to_inner;
        sts = om$send(msg = message EMSloop.EMptnesting
				(EMmsg,pt,info,partolbasis),
		      p_chanselect = &inner_channel);
   	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	sts = OM_I_STOP_SENDING;
	if( (info->location != EMS_L_INSIDE) &&
	    (info->location != EMS_L_ONEDGE) &&
	    (info->location != EMS_L_ONVRTX))
	 {
	  if(info->options & EMS_PTLOC_CLOSEST_EDGE)
	   EMtransfer(&local_info, info);
	  else *info = local_info;
	 }
	
      }
      break;

    case EMS_L_OUTSIDE:
	if(info->options & EMS_PTLOC_CLOSEST_EDGE)
	 EMtransfer(&local_info, info);
	else
	 *info = local_info;
	
	info->location = EMS_L_UNKNWN;
      break;

    case EMS_L_UNKNWN:
      break;

    default:
      break;
  }

wrapup:

  /* stop timer for EMptnesting */
  if (_use_timers)
    stop_timer (T_EMPTNESTING, FALSE, "");

  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMptnesting")
  return(sts);
}
end implementation EMSloop;
