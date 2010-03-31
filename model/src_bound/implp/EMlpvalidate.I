/*
	RV	Long ago.	Creation.
	SM	13-July-88	Added check for natural bit of the loop.
	SM	20-Nov-88	Call EMcheck_props for natural property of
				the loop.
	SM	05-Feb-89	Converted the squared distance checks to
				real distance checks for better
				accuracy and to be consistent with closure
				tests performed at loop/edge creation time.
				Also the gap between consecutive edges is
				pardoned if xyz points are within
				tolerance. 
	SM	10-Feb-89	Added check for the reversed property of
				the loop. The detection of this defect
				is not absolute since the criterion used
				is affected by edge reversal (which itself
				could be wrong).
	SM	24-Feb-89	Check for non natural P loop having gradata.
	SM	21-Jun-89	For gradata purposes, consider a non natural
				loop with all edges natural (even partedges)
				as being a natural loop.
        Tapadia 07-Jul-92	Loop reversal bit wasn't being checked & 
				corrected (found this while looking at TR 
				92n4119)

        Sudha   06/04/93        modified to include BSprototype header files
*/

class implementation EMSloop;

#include <stdio.h>
%safe
#include <math.h>
%endsafe
#include <ctype.h>
#include "emsdef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "EMSlmdef.h"
#include "bssfeval.h"
#include "bsdistptpt.h"

#ifndef DEBUG
#define DEBUG	0
#endif

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSedge import EMendpts, EMget_props, EMreverse, EMdisplay, EMgetrange;
from EMSloopset import EMset_props;
from EMSsubbs import EMmake_frt;

extern OMuword OPP_EMSloop_class_id, OPP_EMSloopset_class_id;

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info;
		  IGRchar *surf_geom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)
{
  IGRint sts;
  OMuint   numouter = 0, numinner = 0, numedges = 0;
  IGRint ix;
  IGRlong rc;
  OM_S_CHANSELECT chan_to_outter, chan_to_inner, chan_to_comps, to_helpers;
  OM_S_OBJECT_LINKAGE	oblist;
  IGRchar obj_info[256], defect_info[256];
  IGRushort lp_props;
  struct GRid my_GRid;
  IGRboolean continu = TRUE, correct;
  OMuword owner;
  struct EMSpartolbasis partolbasis;
  IGRdouble bgn_pt[2], end_pt[2], save_end[2], dist, dist1, partollen, lentol, 
	    chttol, factor, plentol, areatol, lparea, xyzmatchtol;
  IGRdouble last_edge_endpts[2][2], first_edge_endpts[2][2];
  GRobjid		srfid = NULL_OBJID;
  IGRboolean	defective = FALSE, degen = FALSE;
  struct GRid	save_edid, edid;
  extern IGRint		EMextend_intdata();
  IGRboolean	xyzmatch = FALSE;
  IGRdouble 	xyz1[3], xyz2[3];
  struct EMSdataselect edge1, edge2, srf;
  IGRboolean at_stop1, at_stop2;
  IGRboolean correctable = FALSE;
  struct GRid sfid;
  IGRshort edDispOpt = EMS_WHL_EDGE;
  extern IGRboolean	IGEstop();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  if(!(continu = !(IGEstop()))) goto wrapup;

  partolbasis.mattyp = &mod_info->md_env.matrix_type;
  partolbasis.mat = mod_info->md_env.matrix;
  partolbasis.in_world = TRUE;
  partolbasis.is_valid = FALSE;
	 
  sts = om$send(msg = message EMSloop.EMgetsurface_info(EMmsg, &srfid, 
						&partolbasis),
			targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_LoopError,wrapup);

  if(!objinfo)
   {
    /* Keep the following sprintf statements as they are.
    */
    if(IF_NULL_OBJID(srfid))
     sprintf(obj_info, "Loop (id=%d) (props=0x%x)\n             No path to surface", my_id, ME.EMSloop->lp_props);
    else
     sprintf(obj_info, "Loop (id=%d) (props=0x%x)\n             On surface = %d osnum %d", my_id, ME.EMSloop->lp_props, srfid, my_GRid.osnum);
   }
  else
   strcpy(obj_info, objinfo);

  chan_to_outter.type = OM_e_addr;
  chan_to_outter.u_sel.addr = &ME.EMSloop->to_outter;

  chan_to_inner.type = OM_e_addr;
  chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;

  to_helpers.type = OM_e_addr;
  to_helpers.u_sel.addr = &ME.EMSrequester->to_helpers;
  
  BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&rc, BSTOLCHRDHT, chttol);
  xyzmatchtol = 2 * chttol;

  if(IF_NULL_OBJID(srfid))
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"No path to surface", NULL,
		&continu, &correct, NULL, option, ioptr, &edDispOpt);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
    defective = TRUE;
    if (!continu) goto wrapup;
   }
  else if(!(ME.EMSloop->lp_props & EMLP_ACTIVE))
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Inactive loop on the surface",
		  "Make the loop active", &continu, &correct, NULL, 
		  option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
 	ME.EMSloop->lp_props |= EMLP_ACTIVE;
      else defective = TRUE;
      if (!continu) goto wrapup;
   }

  if(ME.EMSloop->lp_props & EMLP_SPLIT)
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Marked split",
		  "Turn the split bit off", &continu, &correct, NULL, 
		  option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
 	ME.EMSloop->lp_props &= ~EMLP_SPLIT;
      else defective = TRUE;
      if (!continu) goto wrapup;
   }

  if(ME.EMSloop->lp_props & EMLP_NEW)
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Marked NEW",
		  "Turn the New bit off", &continu, &correct, NULL, 
		  option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
 	ME.EMSloop->lp_props &= ~EMLP_NEW;
      else defective = TRUE;
      if (!continu) goto wrapup;
   }

  sts = om$get_channel_objects(object = me,
				p_chanselect = &chan_to_outter,
				list = &oblist,
				size = 1,
				count = &numouter);
  EMomerr_exit (sts, wrapup);

  sts = om$get_classid(objid = oblist.S_objid, p_classid = &owner);
  EMomerr_exit (sts, wrapup);

  if((ME.EMSloop->lp_props & EMLP_EXTERNAL)&&(owner == OPP_EMSloop_class_id))
  {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect external bit",
		  "Turn the external-bit off", &continu, &correct, NULL, 
		option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
      {
        sts = om$send(msg = message EMSloop.EMset_props(EMmsg, 
					EMLP_EXTERNAL, EMS_O_OFF),
			  targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
  }

  if (ME.EMSloop->lp_props & EMLP_OPEN)
  {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Flagged open", "Turn the open-bit off", &continu, &correct, 
		NULL, option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
      {
        sts = om$send(msg = message EMSloop.EMset_props(EMmsg, 
					EMLP_OPEN, EMS_O_OFF),
			  targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
  }

  if (ME.EMSloop->lp_props & EMLP_NATURAL)
  {
    IGRboolean  bad_prop = FALSE;
    IGRushort lpprops = EMLP_NATURAL, lsprops = NULL, edprops = NULL;

    sts = om$send(msg = message EMSloop.EMcheck_props 
				(EMmsg, &lsprops, &lpprops, &edprops), 
		targetid = my_id);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

    /* If EMcheck_props has turned my natural bit off, then it means the
       my property was wrong to begin with. So turn it on again and ask the
       user for action to be taken.
    */
    if( !(ME.EMSloop->lp_props & EMLP_NATURAL))
     {
      ME.EMSloop->lp_props |= EMLP_NATURAL;
      bad_prop = TRUE;
     }     
    if(bad_prop)
     {
       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect natural flag", 
		"Turn the natural-bit off", 
		 &continu, &correct, NULL, option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
      {
        sts = om$send(msg = message EMSloop.EMset_props(EMmsg, 
					EMLP_NATURAL, EMS_O_OFF),
			  targetid = my_id);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
        if(owner == OPP_EMSloopset_class_id)
           sts = om$send(msg = message EMSloopset.EMset_props(EMmsg, 
					EMLS_NATURAL, EMS_O_OFF),
			  p_chanselect = &chan_to_outter);
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
     }
  }

  sts = EFextract_par(BSTOLLENVEC,partolbasis.tol,
				&partollen,&rc);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_BSerror,wrapup);

  factor = chttol / lentol;
  plentol = EMS_HIGH_UVLENTOL;
  areatol = 4 * plentol * factor;
  lparea = 0.0;

  sts = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_comps, count = &numedges);
  EMomerr_exit (sts, wrapup);
  if (! numedges)
   {
    sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
	  "Empty", "Delete the loop", &continu, &correct, 
	  NULL, option, ioptr, &edDispOpt);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

    /* Senderid must be a owner so that the loop will delete itself.
    */
    if(correct)
      sts = om$send(msg = message Root.delete(TRUE), senderid = oblist.S_objid,
			targetid = my_id);
    else defective = TRUE;
    if (!continu) goto wrapup;
   }
  else
   {
    IGRdouble edrng[4], myrng[4], noise;
    IGRint i, j;
    IGRboolean bad_range = FALSE;

    sts = om$send (msg = message EMSboundary.EMarea (EMmsg, &lparea), 
			targetid = my_id);
    EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
    if(fabs(lparea) <= areatol) degen = TRUE;

    /* Check the range stored in the instance data.
    */
    OM_BLOCK_MOVE(ME.EMSloop->range, myrng, 4*sizeof(IGRdouble));
    noise = partollen/10.0;

    for(i=0; i<numedges; i++)
     {
      if(bad_range) break;   /* Has been checked already. */

      sts = om$send(msg = message EMSedge.EMgetrange(EMmsg, edrng, NULL), 
            p_chanselect = &chan_to_comps, from = i, to = i);
      EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
      for(j=0; j<4; j++)
	if( ( (j < 2) && (myrng[j] - edrng[j] > noise)) ||
	    ( (j >=2) && (edrng[j] - myrng[j]> noise)))
	 {
	  bad_range = TRUE;
          sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
	        "Incorrect loop range", "Regenerate loop range", &continu, 
	        &correct, NULL, option, ioptr, &edDispOpt);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
          if(correct)
            sts = om$send(msg = message EMSloop.EMsetrange(EMmsg), 
			targetid = my_id);
          else defective = TRUE;
          if (!continu) goto wrapup;
          break;
        }
     }
   }

  sts = om$get_channel_count (objid = my_id, p_chanselect =
             &chan_to_inner, count = &numinner);
  EMomerr_exit (sts, wrapup);

  if (numinner && !degen)
  {
    for (ix=0; ix<numinner; ix++)
    {
      sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lp_props),
			p_chanselect = &chan_to_inner, from = ix, 
			to = ix);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

      if (((lp_props & EMLP_PLOOP) && (ME.EMSloop->lp_props & EMLP_PLOOP))
				  ||
          (!(lp_props & EMLP_PLOOP) && !(ME.EMSloop->lp_props & EMLP_PLOOP)))
      {
	/* Check if the offending loop is degenerate. If so ignore its
	   type.
	*/
	lparea = 0.0;
        sts = om$send (msg = message EMSboundary.EMarea (EMmsg, &lparea), 
	      p_chanselect = &chan_to_inner, from = ix, to = ix);
        EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
        if(fabs(lparea) > areatol)
         {
          sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Illegal nesting", NULL, &continu, &correct, NULL, option, 
		 ioptr, &edDispOpt);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
          defective = TRUE;
	  if (!continu) goto wrapup;
	 }
      }
    }

  } /* I have inner loop(s)	*/


  if(numedges > 1)
   {
    /* Check the reversed property of the loop.
       if loop is reversed, 
         end of first edge and begin of last edge should match.
       else 
	 begin of first edge and end of last edge should match.
	   
       Instead of actually checking the match, relative distance comparison
       is done with the other pair of points to avoid tolerance
       problems.
       The defect is reported only if the loop is non degenerate. 
    */
    if(numedges > 2)
     {
      IGRboolean	first_beg_last_end = FALSE, 
			first_beg_last_beg =FALSE,
			first_end_last_end = FALSE, 
			first_end_last_beg = FALSE, coinc = FALSE;
      IGRdouble		dist1, dist2, dist3, dist4;

      sts = om$send(msg = message EMSedge.EMendpts(EMmsg,
			first_edge_endpts[0], first_edge_endpts[1],
			NULL, NULL, NULL),
			p_chanselect = &chan_to_comps, from = 0, 
			  to = 0);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      sts = om$send(msg = message EMSedge.EMendpts(EMmsg,
			last_edge_endpts[0], last_edge_endpts[1],
			NULL, NULL, NULL),
			p_chanselect = &chan_to_comps, from = numedges-1, 
			  to = numedges - 1);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      if( (dist1 = EM2ddistptpt(first_edge_endpts[0], last_edge_endpts[1]))
		< partollen) first_beg_last_end = TRUE;
      if( (dist2 = EM2ddistptpt(first_edge_endpts[0], last_edge_endpts[0]))
		< partollen) first_beg_last_beg = TRUE;
      if( (dist3 = EM2ddistptpt(first_edge_endpts[1], last_edge_endpts[1]))
		< partollen) first_end_last_end = TRUE;
      if( (dist4 = EM2ddistptpt(first_edge_endpts[1], last_edge_endpts[0]))
		< partollen) first_end_last_beg = TRUE;
		
      /* If the first and last edge are coincedent, both their endpoints
	 will match. In such a case loop reversal becomes ambiguous. So we
	 skip the check.
      */
      if( (first_end_last_beg && first_beg_last_end) ||
	  (first_end_last_end && first_beg_last_beg)) coinc = TRUE;

      if(!coinc && (ME.EMSloop->lp_props & EMLP_REVERSED) && (dist1 < dist4))
       {
        if(!degen)
         {
          sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect reversed flag", 
		"Turn the reversed bit off", &continu, &correct, 
		NULL, option, ioptr, &edDispOpt);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
         }
        else correct = TRUE;

        if (correct) ME.EMSloop->lp_props &= ~EMLP_REVERSED;
        else defective = TRUE;
        if (!continu) goto wrapup;
       }
      else if(!coinc && !(ME.EMSloop->lp_props & EMLP_REVERSED) &&
		(dist4 < dist1))
       {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect reversed flag", 
		"Turn the reversed bit on", &continu, &correct, NULL, 
		option, ioptr, &edDispOpt);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct) ME.EMSloop->lp_props |= EMLP_REVERSED;
        if (!continu) goto wrapup;
       }

     }/* if(numedges > 2) */

    edid.osnum = save_edid.osnum = OM_Gw_current_OS;

    ix = ME.EMSloop->lp_props & EMLP_REVERSED ? 0 : numedges - 1;
    sts = om$send(msg = message EMSboundary.EMget_objid
			(EMmsg, &save_edid.objid), 
		p_chanselect = &chan_to_comps, from = ix, to = ix);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

    sts = om$send(msg = message EMSedge.EMendpts(EMmsg, bgn_pt, save_end,
					NULL, NULL, NULL),
			  targetid = save_edid.objid);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

    edge1.datatype = EMSdata_object;
    edge2.datatype = EMSdata_object;
    edge1.data.object = (struct GRid *) &edid;
    edge2.data.object = (struct GRid *) &save_edid;
    at_stop1 = FALSE;
    at_stop2 = TRUE;
    correctable = surf_geom || (!IF_NULL_OBJID(srfid));
    if(surf_geom)
     {
      srf.datatype = EMSdata_surface;
      srf.data.surface = (struct IGRbsp_surface *)surf_geom;
     }
    else
     {
      sfid.objid = srfid;
      sfid.osnum = OM_Gw_current_OS;
      srf.datatype = EMSdata_object;
      srf.data.object = &sfid;
     }

    /* Look for end point continuity between edges. Ignore UV gap if the
       endpoints are within 2*cht in model space.
    */
    for (ix=ME.EMSloop->lp_props & EMLP_REVERSED ? numedges-1 : 0;
	     ME.EMSloop->lp_props & EMLP_REVERSED ? ix>=0 : ix<numedges;
	     ix = ME.EMSloop->lp_props & EMLP_REVERSED ? ix-1 : ix+1)
     {
      xyzmatch = FALSE;
      sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &edid.objid), 
			  p_chanselect = &chan_to_comps, from = ix, to = ix);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      sts = om$send(msg = message EMSedge.EMendpts(EMmsg, bgn_pt, end_pt,
					NULL, NULL, NULL),
			  targetid = edid.objid);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      dist = EM2ddistptpt(bgn_pt, save_end);
      if(dist < partollen) xyzmatch = TRUE;
      else if(surf_geom)
       {
	BSsfeval((struct IGRbsp_surface *)surf_geom, bgn_pt[0],
		bgn_pt[1], 0, (IGRpoint *)xyz1, &rc);
	if(rc == BSSUCC)
	 BSsfeval((struct IGRbsp_surface *)surf_geom, save_end[0],
		save_end[1], 0, (IGRpoint *)xyz2, &rc);
	if(rc == BSSUCC) dist = BSdistptpt(&rc, xyz1, xyz2);
        if((rc == BSSUCC) && (dist < xyzmatchtol)) xyzmatch = TRUE;
       }

      if (!xyzmatch)
       {
        dist1 = EM2ddistptpt(end_pt, save_end);
	if (dist1 <= partollen)
	 {
	  sprintf(defect_info, "Incorrect direction of edge %d", edid.objid);
          sts = EMvalidate_io(EMmsg, mod_info, &edid, obj_info, 
		defect_info, "Reverse the edge",
			 &continu, &correct, NULL, option, ioptr, &edDispOpt);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
	  if(correct)
	   {
	    IGRdouble temp[2];
	
	    sts = om$send(msg = message EMSedge.EMreverse(EMmsg), 
		targetid = edid.objid);
	    if(!(1&*EMmsg&sts)) goto wrapup;
	
	    OM_BLOCK_MOVE(end_pt, temp, 2 * sizeof(IGRdouble));
	    OM_BLOCK_MOVE(bgn_pt, end_pt, 2 * sizeof(IGRdouble));
	    OM_BLOCK_MOVE(temp, bgn_pt, 2 * sizeof(IGRdouble));	     
	   }
	  else defective = TRUE;
          if (!continu) goto wrapup;
	 }
	else
	 {
	   IGRshort eddisp = EMS_EDGE_BEG_PT;
	
	  sprintf(defect_info, "Gap between edges %d and %d", edid.objid, 
	          save_edid.objid);
          sts = EMvalidate_io(EMmsg, mod_info, &edid, obj_info, 
			defect_info, 
		correctable ? "Extend edges" : NULL, 
			 &continu, &correct, NULL, option, ioptr, &eddisp);
	  EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
	  if(correct)
	   {
	    sts = EMextend_intdata(EMmsg, &edge1, &edge2, at_stop1, at_stop2,
		     &partolbasis, NULL, &srf, &mod_info->md_env.matrix_type, 
			mod_info->md_env.matrix);
	    if(!(1&*EMmsg&sts))
	     {defective = TRUE; *EMmsg = EMS_S_Success; sts = OM_S_SUCCESS;}
	   }
	  else defective = TRUE;

          if (!continu) goto wrapup;
	 }
	
       } /* if (!xyzmatch) */
	
       save_end[0] = end_pt[0];
       save_end[1] = end_pt[1];
       save_edid = edid;

      } /* for loop for edges */

   } /* if ((numedges > 1) && !degen) */

  /* A non natural, P loop must have a gradata.
  */
  if( (ME.EMSloop->lp_props & EMLP_PLOOP) && 
     !(ME.EMSloop->lp_props & EMLP_NATURAL) && numedges && !degen)
   {
    OMuint numgradata=0;
    IGRint	i;
    IGRboolean  nonnat = FALSE;

    /* I have to double check edge properties because for rest of the system
       a loop having part natural edges is a non natural loop. But for a
       gradata we can still consider it to be a natural loop.
    */
    for(i=0; i<numedges; i++)
     {
      IGRushort edprops = NULL;
      sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
			p_chanselect = &chan_to_comps, from = i, to = i);
      EMerr_hndlr (!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      if(!(edprops & EMED_NATURAL)) {nonnat = TRUE; break;}
     }
   
    sts = om$get_channel_count(object = me, p_chanselect = &to_helpers, 
				   count = &numgradata);
    EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
    if(!numgradata && nonnat)
     {
/************
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"No graphics data", 
		IF_NULL_OBJID(srfid) ? NULL : "Create graphics data", 
		&continu, &correct, NULL, option, ioptr, &edDispOpt);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
*************/
      correct = TRUE;
      if (correct)
       {
        sts = om$send(msg = message EMSsubbs.EMmake_frt(EMmsg,
                                my_id), targetid = srfid);
        /*EMerr_hndlr(!(1&*EMmsg&sts),sts,OM_E_ABORT,wrapup);*/

       }  
      else defective = TRUE;
      if (!continu) goto wrapup;

     }/* if(!numgradata && nonnat) */

   } /* if non natural p loop */

  if(numedges)
   {
    sts = om$send(msg = message GRgraphics.EMvalidate(EMmsg, mod_info,
					 surf_geom, cancer,
					 option, objinfo, ioptr), 
			p_chanselect = &chan_to_comps);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
    if(sts == OM_I_STOP_SENDING) {continu = FALSE; goto wrapup;}
   }

  if(numinner)
   {
    sts = om$send(msg = message GRgraphics.EMvalidate(EMmsg, mod_info,
					 surf_geom, cancer,
					 option, objinfo, ioptr), 
			p_chanselect = &chan_to_inner);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
    if(sts == OM_I_STOP_SENDING) {continu = FALSE; goto wrapup;}
   }

wrapup :
 if(defective)
  {
   *cancer = my_id;
   *EMmsg = EMS_I_LoopError;
  }

  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt)) 
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (sts);
}

end implementation EMSloop;
