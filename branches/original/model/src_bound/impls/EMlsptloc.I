/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines the location of a 2D point with respect to a
   loopset. The location retured is one of the following - 
	EMS_L_ONEDGE	The point was on an edge
	EMS_L_ONVRTX	The point was on a vertex
	EMS_L_INAREA	The point was in area
	EMS_L_INHOLE	The point was in hole
	EMS_L_UNKNWN	The location was unknown.
	The unknown location is returned when the point is outside the
   outermost loop(s) and the option 
   EMS_PTLOC_LS_INFINITE is not specified. However, if this option is 
   specified then following is done if the point is outside the outermost
   loop(s) -

   1) If all the external loops are P loops then the point is in hole.
   2) If all the external loops are C loops then the point is in area.
   3) If the loopset has only feature loops in it and the LS_INFINITE
      option is ON then the point is considered to be in hole.

Assumption
	The method operates on a valid looptree which has no intersecting 
   loops.
	The area is enclosed by P loops and hole is enclosed by a C loop.
   The loop type is stored in the properties of the loop.

History
	SM	03/10/87	Creation date.
        SM	15-Dec-87	Support option EMS_PTLOC_LS_INFINITE, to
				classify a point outside the outermost
				loop(s), instead of always returning
				EMS_L_UNKNWN.
	SM	01-Aug-89	Support option EMS_PTLOC_CLOSEST_EDGE
	SM	27-Sep-89	If BOXCHECK and CLOSEST_EDGE are both on, 
				then set the BOXCHECK option off. This is
				because determination of closest edge needs
				distances which may not be generated with
				BOXCHECK.
*/
class implementation EMSloopset;

#include "EMS.h"
#include "emsmacros.h"

from EMSloop import EMptnesting, EMget_props;

method EMpt_location(IGRlong *EMmsg;IGRdouble *pt;
			struct EMSptloc_info *location;
			struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_loops;
  IGRushort	props;
  IGRint		i;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  location->location = EMS_L_UNKNWN;
  location->num_located_edges = 0;
  if(location->options & EMS_PTLOC_CLOSEST_EDGE)
   {
    location->options &= ~EMS_PTLOC_BOXCHECK;
    for(i=0; i<MAX_LOCATED_EDGES; i++) 
     location->edge[i].nst_pt.dist = MAXDOUBLE;
   }

/* Find the innermost loop inside which the point lies
*/
     sts = om$send(msg = message EMSloop.EMptnesting
			(EMmsg,pt,location,partolbasis),
                p_chanselect = &to_loops);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

     if(location->location == EMS_L_INSIDE)
      {
        sts = om$send(msg=message EMSloop.EMget_props(EMmsg,&props),
			targetid = location->loop_id);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
        if(props & EMLP_PLOOP)
	  location->location = EMS_L_INAREA;
        else
	  location->location = EMS_L_INHOLE;
      }
     else if( (location->location != EMS_L_ONEDGE) &&
	      (location->location != EMS_L_ONVRTX))
      {
	location->location=EMS_L_UNKNWN;
	
	/* if the caller wants to treat the loopset as being infinite then
	   a point outside the outermost loop also needs to be
	   classified. If all the loops under the loops are P loops then
	   the point which is outside all of them is considered to be
	   in_hole. On the other hand, if all the loops under the loopset
	   are C loops then a point which is outside all of them is 
	   considered to be in_area. A combination P and C loops under the
	   loopset is flagged as being invalid state of the loopset.
	   Feature loops (which neither represent area or hole) are ignored
	   for this processing.
	   If the loopset has only feature loops in it then the is considered
	   to be in_hole.
	*/
	
	if(location->options & EMS_PTLOC_LS_INFINITE)
	 {
	   IGRint	i;
           OMuint       count;
	   IGRboolean   was_ploop, is_ploop;
	
	   sts = om$get_channel_count(object = me, p_chanselect = &to_loops, 
				      count = &count);
	   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
	   was_ploop = TRUE;
	   for(i=0; i<count; i++)
	    {
	      sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &props), 
				p_chanselect = &to_loops, from=i, to=i);
	      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	   
	      if(props & EMLP_NOAREA_NOHOLE) continue;
	   
	      is_ploop = props & EMLP_PLOOP ? TRUE : FALSE;
	      EMerr_hndlr(i && (is_ploop != was_ploop), *EMmsg, 
					EMS_E_LoopsetError, wrapup);
	      was_ploop = is_ploop;
	
	    } /* for(i=0 i<count; i++) */
	   
	   if(was_ploop) location->location = EMS_L_INHOLE;
	   else location->location = EMS_L_INAREA;
	
	 } /* if(location->options & EMS_PTLOC_LS_INFINITE) */

      } /* if(!onedge && !onvertex) */

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMpt_location")
  if (sts == OM_I_STOP_SENDING)
    sts = OM_S_SUCCESS;
  return(sts);
}

end implementation EMSloopset;
