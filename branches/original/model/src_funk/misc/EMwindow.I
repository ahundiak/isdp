/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSsplitdef.h"
#include "emsedgedef.h"

extern OMuword OPP_EMSloop_class_id, OPP_EMSlinedge_class_id;

from EMSlinedge import EMleinit;
from EMSloop import EMlpinit, EMgivenestinfo, EMset_props;

IGRint EMmake_window_loop(EMmsg, min, max, loop, partolbasis)
   IGRlong 		*EMmsg;
   IGRdouble		min[], max[];
   GRobjid		*loop;
   struct EMSpartolbasis *partolbasis;
{
	struct IGRpolyline	poly;
	OM_S_CHANSELECT		to_edges, to_owner;
	IGRdouble		pts[4];
	IGRint			size, sts;
	IGRushort	ed_props;
	GRobjid			edge;


  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
  sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$construct(classid = OPP_EMSloop_class_id, 
			p_objid = loop);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  poly.num_points = 2;
  poly.points = pts;
  ed_props = NULL;
  ed_props = EMED_OPEN;
  size = 2 * sizeof(IGRdouble);

  OM_BLOCK_MOVE(min, pts, size);
  pts[2] = min[0];
  pts[3] = max[1];
  sts = om$construct(classid = OPP_EMSlinedge_class_id, 
			p_objid = &edge, 
			msg = message EMSlinedge.EMleinit
			(EMmsg, ed_props, EMlinestring, &poly, partolbasis,
			 NULL, NULL_OBJID));
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  sts = om$send(msg = message Root.connect(to_owner, MAXINT, *loop, 
				OM_Gw_current_OS, to_edges, MAXINT), 
			senderid = *loop, targetid = edge);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  OM_BLOCK_MOVE(&pts[2], pts, size);
  pts[2] = max[0];
  sts = om$construct(classid = OPP_EMSlinedge_class_id, 
			p_objid = &edge, 
			msg = message EMSlinedge.EMleinit
			(EMmsg, ed_props, EMlinestring, &poly, partolbasis,
			 NULL, NULL_OBJID));
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  sts = om$send(msg = message Root.connect(to_owner, MAXINT, *loop, 
				OM_Gw_current_OS, to_edges, MAXINT), 
			senderid = *loop, targetid = edge);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  OM_BLOCK_MOVE(&pts[2], pts, size);
  pts[3] = min[1];
  sts = om$construct(classid = OPP_EMSlinedge_class_id, 
			p_objid = &edge, 
			msg = message EMSlinedge.EMleinit
			(EMmsg, ed_props, EMlinestring, &poly, partolbasis,
			 NULL, NULL_OBJID));
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  sts = om$send(msg = message Root.connect(to_owner, MAXINT, *loop, 
				OM_Gw_current_OS, to_edges, MAXINT), 
			senderid = *loop, targetid = edge);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  OM_BLOCK_MOVE(&pts[2], pts, size);
  pts[2] = min[0];
  sts = om$construct(classid = OPP_EMSlinedge_class_id, 
			p_objid = &edge, 
			msg = message EMSlinedge.EMleinit
			(EMmsg, ed_props, EMlinestring, &poly, partolbasis,
			 NULL, NULL_OBJID));
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  sts = om$send(msg = message Root.connect(to_owner, MAXINT, *loop, 
				OM_Gw_current_OS, to_edges, MAXINT), 
			senderid = *loop, targetid = edge);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$send(msg=message EMSloop.EMlpinit
			(EMmsg, EMLP_ACTIVE, partolbasis, NULL),
				senderid = *loop, targetid = *loop);
  if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMmake_window_loop");
	return(sts);
}




IGRint EMget_window(EMmsg, inpar1, inpar2, split_dir, window)
   IGRlong	*EMmsg;
   IGRdouble	*inpar1, *inpar2;
   IGRint	split_dir;
   IGRdouble	*window;
{

   IGRdouble	pts[4], *par1, *par2;
   IGRint	size, sts;
   void		EM2dbx();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  switch(split_dir)
  {
    case SPLIT_U:
	if(inpar2[0] < inpar1[0])
	  {
	    par1 = inpar2;
	    par2 = inpar1;
	  }
	else
	  {
	    par1 = inpar1;
	    par2 = inpar2;
	  }
	OM_BLOCK_MOVE(par1, window, sizeof(IGRdouble));
	window[1] = 0.0;
	OM_BLOCK_MOVE(par2, &window[2], sizeof(IGRdouble));
	window[3] = 1.0;
    break;

    case SPLIT_V:
	if(inpar2[1] < inpar1[1])
	  {
	    par1 = inpar2;
	    par2 = inpar1;
	  }
	else
	  {
	    par1 = inpar1;
	    par2 = inpar2;
	  }
	window[0] = 0.0;
	OM_BLOCK_MOVE(&par1[1], &window[1], sizeof(IGRdouble));
	window[2] = 1.0;
	OM_BLOCK_MOVE(&par2[1], &window[3], sizeof(IGRdouble));
    break;

    case SPLIT_BOTH:
	size = 2 * sizeof(IGRdouble);
	OM_BLOCK_MOVE(inpar1, pts, size);
	OM_BLOCK_MOVE(inpar2, &pts[2], size);
	EM2dbx(2, pts, window);
    break;

    default:
	*EMmsg = EMS_E_InvalidArg;
    break;
  }


wrapup:
     EMWRAPUP(*EMmsg, sts, "In EMmake_window");
     return(sts);
}


/* Following function checks whether a loop (representing a window) is
   completely within a hole.

Algorithm
   Check whether the loop has cutting intersection with the loopset.
   If there is an intersection, return FALSE.
   If there is no intersection, get the nesting of the loop.
   If the parent is C loop set return code to EMS_I_InHoleTrim and
     retun TRUE.
*/


#include "emsinterdef.h"	/* EMS_INTER_CUTTING */


IGRint EMwindow_in_hole(EMmsg, loopsetid, loopid, partolbasis, inters)
  IGRlong		*EMmsg;
  GRobjid		loopsetid, loopid;
  IGRboolean		*inters;
  struct EMSpartolbasis	*partolbasis;
{
   IGRlong			sts;
   struct EMSnest_info		nesting;
   IGRint			inter = 0;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

/* See if the loop has cutting intersection with the loopset.
*/
  sts = om$send(msg = message EMSloopset.EMobint
				(EMmsg, partolbasis, loopid, partolbasis, 
				 EMS_INTER_CUTTING, &inter, NULL, NULL), 
			senderid = loopsetid, targetid = loopsetid);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

  if(!inter)
   {
     *inters = FALSE;
     sts = om$send(msg = message EMSloop.EMgivenestinfo(EMmsg, &nesting), 
			targetid = loopid, senderid = loopsetid);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

     sts = om$send(msg = message EMSloopset.EMnesting
				(EMmsg, &nesting, partolbasis), 
			senderid = loopsetid, targetid = loopsetid);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

     if( (!IF_EQ_OBJID(nesting.parent, loopsetid)) &&
         (!(nesting.parent_props & EMLP_PLOOP)))
       *EMmsg = EMS_I_InHoleTrim;
   }
  else
    *inters = TRUE;

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMwindow_in_hole");
  if(*EMmsg == EMS_I_InHoleTrim)
    return(TRUE);
  else
    return(FALSE);

}



/* If the loopset has only one loop in it this function returns
   TRUE (with return code EMS_I_InAreaTrim).
   else it returns FALSE.
   If the loopset has no loops it returns FALSE and the return code is
   EMS_E_InvalidCase.
*/

IGRint EMwindow_in_area(EMmsg, loopsetid)
	IGRlong		*EMmsg;
	GRobjid		loopsetid;
{
   IGRlong		sts;
   OM_S_CHANSELECT	to_loops, to_inner;
   IGRint		num_loops;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

   sts = om$get_channel_count(objid = loopsetid, p_chanselect = &to_loops, 
			      count = (OMuint *)&num_loops);
   EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   EMerr_hndlr(!num_loops, *EMmsg, EMS_E_InvalidCase, wrapup);

   if(num_loops == 1)
    {
      GRobjid	extern_loop;
      
      sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &extern_loop),
			senderid = loopsetid, p_chanselect = &to_loops);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

      sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

      sts = om$get_channel_count(objid = extern_loop, p_chanselect = &to_inner,
				 count = (OMuint *)&num_loops);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      if(num_loops)
	*EMmsg = EMS_S_Success;
      else
        *EMmsg = EMS_I_InAreaTrim;

    } /* If num_loops == 1 */

   else
     *EMmsg = EMS_S_Success;

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMwindow_in_area");
  if(*EMmsg == EMS_I_InAreaTrim)
    return(TRUE);
  else
    return(FALSE);

}



void EMget_point_in_area(surf_closed, parm1, parm2, parm3, 
			   window, pt_in_area, split_ind, across_seam)
  IGRboolean	surf_closed;
  IGRdouble	*parm1, *parm2, *parm3, *window, *pt_in_area;
  IGRint	split_ind;
  IGRshort	*across_seam;
{
  IGRboolean	pt_decided = FALSE;
  IGRdouble	*start, *stop;


  if( surf_closed && parm2) 
   {
     if(parm1[split_ind] < parm3[split_ind])
      {
	start = parm1;
	stop = parm3;
      }
     else
      {
        start = parm3;
	stop = parm1;
      }

     if( (parm2[split_ind] < start[split_ind]) || 
	 (parm2[split_ind] > stop[split_ind]))
      {
	if(across_seam) *across_seam |= ( (split_ind == SPLIT_U) ? 
					  ACROSS_SEAM_U : ACROSS_SEAM_V);
	OM_BLOCK_MOVE(parm2, pt_in_area, 2*sizeof(IGRdouble));
	pt_decided = TRUE;
      }
    }

   if(!pt_decided)
    {
      pt_in_area[0] = (window[0] + window[2])/2;
      pt_in_area[1] = (window[1] + window[3])/2;
    }
}
end implementation EMSloopset;
