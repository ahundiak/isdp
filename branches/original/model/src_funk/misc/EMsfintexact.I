/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This function computes the exact intersection point using the
approximate intersection points and modifies the relevant data. The method
used to compute the exact intersection is either 'three surface iteration'
or 'curve surface iteration' depending upon what kind of edge the intersection
piece is incedent on. The data modified includes the following -

	1) The uv intersection data on surface 1
	2) The uv intersection that is contiguous with (1) in model space.
	3) The model space intersection data on surface 1.
	4) The contiguous piece of intersection data in model space on next
	   surface (common edge concept).
	5) The uv intersection data on surface 3.
	
This function in the process of improving the intersection data also
does the following - 
	1) Pushes the intersection pieces to appropriate vertices if they
	   are incedent in the middle of on non common edges. This is
	   done to avoid a subsequent edge-split using this data (and in
	   turn avoid mismatched topology).
	2) If one of the intersection pieces is dangling (not incedent
	   on any edge) it uses the other piece to compute exact intersection
	   point. From there it modifies the first dangling piece with its
	   corresponding uv.
	
Arguments

History
	SM	01-Apr-88	Creation.
	SM	13-Sep-88	When xyz curve data is extended upate the
				pointer in
				intobj->other_intobj_node->this_xyzintobj.data.
				
    	SM	04-Oct-88	If split points are on the same edge and at the
			 	same point, do not consider it as mismatched
				topology.
	SM	25-Oct-88	When modifying mismatched topology
				intersections, modify them only if they are
				incedent at the middle and modify them such
				that they now end at the closest
				endpoint. Do not get the common vertex etc.
	SM	01-Dec-88	After correcting the mismatched topology
				condition, set the fwd/bwd pointers to
				store the connectivity information.
	SM	21-Feb-89	If the next intobj is dangling make 
				sure that it is indeed on incedent edge1's
				common surface. If not ignore it.
	SM	05-Mar-89	Explicitly check for EMS_I_NoCommonEdge from
				EMSedge.EMrefine_points message. If set
				ignore refine_intobj_next. 
	SM	20-Mar-92	Supress the mismatched topology processing at
				the end if both the incedent edges do not
				have a common edge.
	SM	26-Mar-92       Ignore errors in extending the xyz intersection
				data and keep going. The xyz intersection data 
				is topologically inconsequential, so an error
				modifying it does not warrant an abort.
        NP      15-Sep-92	Added an argument to this function. The 
                                existing
                                argument "approx_uv3" pertains to 
                                "other_intobj"
                                of "refine_intobj". Therefore, when this 
                                function was recursively called after switching
                                "refine_ intobj" and "refine_intobj_next", 
				"approx_uv3" was no more valid. Therefore I 
				have
				added argument "approx_uv3_next", which 
				pertains
                                to "other_intobj"  of "refine_intobj_next" and
                                can be used in the recursive call. All 
                                recursive
				calls to "EMsfint_exact" have been accordingly
				modified.(The other option was to map the
				"approx_uv3" to model space and then map it to
				the UV space of "other_intobj" of 
                                "refine_intobj_next", in this fuction itself, 
				for the recursive call. That was considered 
				less accurate.)
       SM      16-Feb-93        Honor the intobj property EMSintobj_not_in_area
                                and prevent the check made to see if the
                                intobj is completely in a hole after
                                refinement. Trivial checks to prevent this
                                processing when the property is not set, needs
                                more thought. It would be a good optimisation.
      SM     22-Feb-93          Added checks in EMget_correct_ends to
                                a) Return the same pair back if both intobjs
                                are incedent at ends of existing edges
                                and b) Return the same pair back if both
                                intobjs are non-degenerate.
     Sudha     09-jul-93        Modified for BSprototypes anisfication
      SM	21-Juk-93	Added checks to prevent any data modification
				on an intersection which is already marked
				exact at the appropriate end.
      NP        23-Dec-93       If the dataselect which is being refined is an
                                EMSedge, set location to UNKNOWN, so that the 
                                function EMrefine_data may figure it out. Due to
                                the edge reverse bit not being considered while
                                passing in the extend point location, there was
                                some corruption, as refined point was being 
                                inserted at the wrong end. This fix MIGHT 
                                override the fix on 21-Juk-93, for dataselects
                                of type EMSedge. 
*/

class implementation Root;

#ifndef DEBUG
#define DEBUG	0
#endif

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif

#include "OMerrordef.h" /* OM message codes */

%safe
#include <math.h>
%endsafe

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h" 
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "emsinterdef.h"
#include "bsmdistptsf.h"


from EMSedge import EMrefine_points, EMget_props, EMptproject, 
		    EMextend_geom, EMget_bottom_edge, EMendpts, 
		    EMgetsurface_info, EMfind_commvtx;
		
from EMSboundary import EMget_objid;
from EMSedge import EMtrimyourself;
from EMSsubbs import EMparttrim;

extern OMuword	OPP_EMSlinedge_class_id, OPP_EMSnatedge_class_id, 
		OPP_EMSbsedge_class_id, OPP_EMSpartedge_class_id;
%safe
static IGRboolean	EMget_correct_ends();
static IGRint 		EMrefine_data(), EMsm_check_in_hole();
static IGRlong          EFtoggle_extnd_loc();
%endsafe

IGRint EMsfint_exact(EMmsg, mattyp, mat, other_mattyp, other_mat, 
	      const_list, num_grps, 
	      num_subgrps_grp, num_elems_subgrp, elems, refine_intobj, 
	      refine_intobj_next, begin1, begin2, approx_uv3, approx_uv3_next, 
              approx_xyz, retrim)
 IGRlong		*EMmsg;
 IGRshort		*mattyp;
 IGRmatrix		mat;
 IGRshort		*other_mattyp;
 IGRmatrix		other_mat;
 struct GRvg_construct	*const_list;
 IGRint			*num_grps, **num_subgrps_grp, ***num_elems_subgrp;
 struct EMSintobj	****elems, *refine_intobj, *refine_intobj_next;
 IGRboolean		begin1, begin2;
 IGRdouble		*approx_uv3, *approx_uv3_next, *approx_xyz;
 IGRboolean		*retrim;
{
  IGRlong		msg_loc, sts, rc;
  struct EMSdataselect	surf[3], *surf_ptrs[3];
  struct EMSpartolbasis	partol[3], *tol_ptrs[3];
  struct GRmdenv_info	env[3], *env_ptrs[3];
  IGRdouble		*approx_uv_ptrs[3];
  IGRdouble		exact_uv[3][2], *exact_uv_ptrs[3], xyz_exact[3];
  GRobjid		refined_edgeid, refined_commid, 
			bot_edge, sfid1, sfid2;
  struct EMSsfintedpar	*edpar1, *edpar2, temp_edpar1, temp_edpar2, 
			*save_edpar2 = NULL;
  IGRdouble		xyz_tol, junk_exact[3];
  IGRint		i, j, k, l;
  struct EMSintobj	*this_elem, *save_refine_intobj_next = NULL;
  IGRboolean		retrace = FALSE, mismatched_topology = FALSE, 
			refined_edge = FALSE, 
			refined_comm = FALSE, 
			at_begin1 = FALSE, at_begin2 = FALSE, 
			replace_endpt = FALSE, 
			skip1 = FALSE, skip2 = FALSE, 
			coinc1 = FALSE, coinc2 = FALSE, 
			exact1 = FALSE, exact2 = FALSE, exact3 = FALSE,  
			project_on_comm_surf = FALSE, 
			begin1_other = FALSE;
  OM_S_CHANSELECT	to_common_edge;
  IGRint		extnd_loc1, extnd_loc2, extnd_loc3;
  IGRint		extnd_loc_uv1, extnd_loc_uv2, extnd_loc_uv3;
  struct EMSproj_info   proj_info;
  struct EMSsfintedpar	*edpar;
  OMuword		ed_classid;
  GRspacenum		sfos;
  struct IGRbsp_surface *srf_geom1, *srf_geom2, *srf_geom3;
  struct EMSintobj 	*junk1;
  extern IGRint		EMextend_poly(), EMextend_curve(), EMextend_object();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  retrim[0] = retrim[1] = FALSE;
  srf_geom1 = NULL;
  srf_geom2 = NULL;
  srf_geom3 = NULL;

  if(!refine_intobj)
   {
    *EMmsg = EMS_I_NoSolution;
    goto wrapup;
   }

  /*
   * If either of the intobjs to be refined are uv-degenerate, exit from
   * this function. This function does some funky things to the ends
   * of such intersections.
   */

  if ((refine_intobj ?
       refine_intobj->props & EMSintobj_uvdegenerate : FALSE) ||
      (refine_intobj_next ? 
       refine_intobj_next->props & EMSintobj_uvdegenerate : FALSE))
   {
    *EMmsg = EMS_I_NoSolution;
    goto wrapup;
   }

  /* If either of the intersections has been produced by coincident
     plane intersection, then we have no solution.
  */
  skip1 = refine_intobj->props & EMSintobj_delrefine;
  coinc1 = refine_intobj->props & EMSintobj_coincident;
  skip2 = refine_intobj_next ? refine_intobj_next->props & EMSintobj_delrefine
			     : FALSE;
  coinc2 = refine_intobj_next ? 
	   refine_intobj_next->props & EMSintobj_coincident : FALSE;
  if(skip1 || skip2) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
	
  sfos = refine_intobj->this_obj_node->this_obj.osnum;
  sfid1 = refine_intobj->this_obj_node->this_obj.objid;
  sfid2 = refine_intobj_next ? 
		refine_intobj_next->this_obj_node->this_obj.objid : NULL_OBJID;

  edpar1 = (struct EMSsfintedpar *) (refine_intobj->more_info);
  edpar2 = (struct EMSsfintedpar *) (refine_intobj_next ? 
				refine_intobj_next->more_info : NULL);
  if(!edpar1) {*EMmsg = EMS_I_NoSolution; goto wrapup;}
	
  if(begin1 && refine_intobj->reversed)
    edpar1 = edpar1->next;
  else if(!begin1 && !refine_intobj->reversed)
    edpar1 =  edpar1->next;

  if(edpar2 && begin2 && refine_intobj_next->reversed)
    edpar2 = edpar2->next;
  else if(edpar2 && !begin2 && !refine_intobj_next->reversed)
    edpar2 = edpar2->next;

  save_refine_intobj_next = refine_intobj_next;
  save_edpar2 = edpar2;

  /* If both the intersections are dangling, then exit. If one of the 
   *  intersections is dangling then use the one which is not dangling.
   * 
  */
  if(IF_NULL_OBJID(edpar1->edgeid) && edpar2 && IF_NULL_OBJID(edpar2->edgeid))
   {
    *EMmsg = EMS_I_Open;
    goto wrapup;
   }

   if( (edpar1->intloc != EMScvint_middle) && 
       (edpar1->intloc != EMScvint_unknown) &&
       !IF_NULL_OBJID(edpar1->edgeid))
    {
     refine_intobj->props |= begin1 ? EMSintobj_exact_atstart :
				     EMSintobj_exact_atstop;
     exact1 = TRUE;
    }

   if(edpar2 && (edpar2->intloc != EMScvint_middle) &&
		(edpar2->intloc != EMScvint_unknown) &&
		!IF_NULL_OBJID(edpar2->edgeid))
    {
     refine_intobj_next->props |= begin2 ? EMSintobj_exact_atstart :
				     EMSintobj_exact_atstop;
     exact2 = TRUE;
    }


 sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
				
 if(edpar2)
  {
   /* If the two incedent edges are same, then it is not the 'The case of a 
      mismatched topology' (in the sense that we do not know how to fix
      it). 
   */
   if(IF_EQ_OBJID(edpar1->edgeid, edpar2->edgeid))
    sts = OM_S_SUCCESS;
   else
    sts = om$is_objid_on_channel(objid_c = edpar1->edgeid, 
			p_chanselect = &to_common_edge, osnum_c = sfos, 
			osnum2 = sfos, 
			objid = edpar2->edgeid);
			
   /* If the two edges involved are not on common edge then the trace tolerance
      is most probably too big and hence it has linked up some wrong
      pieces. So ignore the common edge information supplied and treat it
      as if one intobj was supplied. Recursively call the same function for
      refine_intobj_next. If two edges are common to each other then see
      if edpar2 has a natural/bs edge. If it does then give priority to edpar2
      such that it will do curve surface iteration. One of the intobjs can be
      dangling, thus having NULL_OBJID in edpar. In such a case use the edgeid
      available. When an dangling end is encountered for the 'next' intobj
      make sure that that intersection is indeed on the surface belonging
      to the common edge of the refine_intobj's incedent edge.
   */
   if(sts != OM_S_SUCCESS)
    {
     IGRdouble endpt1[2], xyzendpt[3], dumpt[3], *loc_approx_uv3;
     IGRboolean at_stop, loc_retrim[2];
     struct EMSintobj	*intobj1;

     if(IF_NULL_OBJID(edpar1->edgeid))
      {
       IGRboolean	temp_retrim[2];

       sts = EMsfint_exact(EMmsg, mattyp, mat, other_mattyp, other_mat, 
			const_list, num_grps, num_subgrps_grp, 
			num_elems_subgrp, elems, refine_intobj_next, 
			refine_intobj, begin2, begin1, approx_uv3_next, 
                        approx_uv3, approx_xyz, temp_retrim);
       refine_intobj = NULL;
       edpar1 = NULL;
       retrim[0] = temp_retrim[1];
       retrim[1] = temp_retrim[0];
       goto wrapup;
      }
     else if(IF_NULL_OBJID(edpar2->edgeid))
      {
	OM_S_OBJECT_LINKAGE	commedge;
	GRobjid			commsurf = NULL_OBJID;
	IGRint			comcount = 0;

        sts = om$get_channel_objects(objid = edpar1->edgeid, 
			p_chanselect = &to_common_edge, osnum = sfos, 
			list = &commedge, size = 1,count =(OMuint *)&comcount);
        if(!(1&*EMmsg&sts)) goto wrapup;
	if(comcount)
	 {
	  sts = om$send(msg = message EMSedge.EMgetsurface_info
				(EMmsg, &commsurf, NULL), 
		senderid = edpar1->edgeid, targetid = commedge.S_objid, 
		targetos = sfos);
          if(!(1&*EMmsg&sts)) goto wrapup;	  
	 }
	
	/* If the linked up intobj is on a surface other than common surface
	   ignore it. If it is indeed on the common surface, it will get
	   handled as a dangling intersection and be fixed.
	*/
	if(!IF_EQ_OBJID(commsurf, sfid2))
	 {
          sts = EMsfint_exact(EMmsg, mattyp, mat, other_mattyp, other_mat, 
			const_list, num_grps, num_subgrps_grp, 
			num_elems_subgrp, elems, refine_intobj, 
			(struct EMSintobj *)NULL, begin1, begin2, approx_uv3, 
                        (IGRdouble *)NULL, approx_xyz, 
			retrim);
	  refine_intobj_next = NULL;
	  save_refine_intobj_next = NULL;
	  edpar2 = NULL;
	  goto wrapup;
	 }
	
      } /* else if(IF_NULL_OBJID(edpar2->edgeid)) */

     /* At this point following is the situation - 
	
	o There are two intobjs linked in model space.
	o Both of them end on edges (they are not dangling).
	o Their incedent edges are not common edges. 
	
	Corrective action for this situation is making shure that
	both intobjs are incedent at end points of their respective
	edges. This is to ensure that no topological splits will occur
	if the caller decides to use this info for topology modification
	later on. Since the incedent edges are not common edges, splitting
	either/both of them will result into mismatched topology.
	However, if one of the intersections is degenerate, then trace
	might have picked up its wrong end, while the other end might lend
	topological continuity. If this indeed is the situation, then look
	at the correct end of the degenerate piece.
     */
     else if(!EMget_correct_ends(EMmsg, refine_intobj, &edpar1, 
			     refine_intobj_next, &edpar2, &begin1, &begin2,
			     approx_xyz, approx_uv3, 
			     &to_common_edge, sfos, mattyp, mat))
      {
       at_stop = !begin2;
       intobj1 = (struct EMSintobj *) refine_intobj_next;
       if(intobj1->other_intobj_node)
        {
          sts = EMgetendpts_uv (EMmsg, 
		 &intobj1->other_intobj_node->this_uvintobj,
                 intobj1->reversed, 1, at_stop ? dumpt : endpt1, 
                 at_stop ? endpt1 : dumpt);
          if(!(1&*EMmsg&sts)) goto wrapup;
        }
       sts = EMgetendpts_xyz (EMmsg, mattyp, mat, 
				 &intobj1->this_xyzintobj,
                 	intobj1->reversed, 1, at_stop ? dumpt : xyzendpt, 
                 	at_stop ? xyzendpt : dumpt);
       if(!(1&*EMmsg&sts)) goto wrapup;
       loc_approx_uv3 = (IGRdouble *) intobj1->other_intobj_node ? endpt1 : 
								 NULL;
       loc_retrim[0] = loc_retrim[1] = FALSE;
       sts = EMsfint_exact(EMmsg, mattyp, mat, other_mattyp, other_mat, 
			   const_list, num_grps, num_subgrps_grp, 
			   num_elems_subgrp, elems, intobj1, 
                           (struct EMSintobj *)NULL, begin2, 
                           (IGRboolean)NULL, loc_approx_uv3, 
                           (IGRdouble *)NULL, xyzendpt, loc_retrim);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(*EMmsg == EMS_S_Success) retrace = TRUE;
       if(loc_retrim[0]) retrim[1] = TRUE;
       mismatched_topology = TRUE;
       save_refine_intobj_next = refine_intobj_next;
       save_edpar2 = edpar2;
       refine_intobj_next = NULL;
       edpar2 = NULL; 

      } 
     else
      {
       save_refine_intobj_next = refine_intobj_next;
       save_edpar2 = edpar2;
      }

    } /* if(sts != OM_S_SUCCESS) */

   else 
    {
     GRobjid		junkid;

     /* At this point we know that -
	There are two intobjs 
	They are incedent on common edges.
	So if both of them are exact, we can exit at this point.
     */

     if(exact1 && exact2)
      {
       *EMmsg = EMS_I_Degenerate;
       goto wrapup;
      }

     if(IF_EQ_OBJID(sfid1, sfid2))
      {
	*EMmsg = EMS_I_NoSolution;
	goto wrapup;
      }

     sts = om$send(msg = message EMSedge.EMget_bottom_edge(EMmsg, &junkid), 
				targetid = edpar1->edgeid,
				targetos = sfos, 
				senderid = edpar1->edgeid);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     sts = om$get_classid(osnum = sfos, objid = junkid, 
			 p_classid = &ed_classid);
     if( (ed_classid != OPP_EMSnatedge_class_id) &&
	 (ed_classid != OPP_EMSbsedge_class_id))
      {
       sts = om$send(msg = message EMSedge.EMget_bottom_edge(EMmsg, &junkid), 
				targetid = edpar2->edgeid,
				targetos = sfos, 
				senderid = edpar2->edgeid);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
       sts = om$get_classid(osnum = sfos, objid = junkid, 
			 p_classid = &ed_classid);
       if( (ed_classid == OPP_EMSnatedge_class_id) ||
	 (ed_classid == OPP_EMSbsedge_class_id))
        {
	  IGRboolean	temp_retrim[2];
	  sts = EMsfint_exact(EMmsg, mattyp, mat, other_mattyp, other_mat, 
			const_list, num_grps, num_subgrps_grp, 
			num_elems_subgrp, elems, refine_intobj_next, 
			refine_intobj, begin2, begin1, approx_uv3_next, 
                        approx_uv3, approx_xyz, temp_retrim);
	  retrim[0] = temp_retrim[1];
	  retrim[1] = temp_retrim[0];
	  goto wrapup;
        }
      }

    } /* if(sts == OM_S_SUCCESS) */

  } /* if(edpar2) */

 else if(exact1) goto wrapup;


  for(i=0; i<3; i++)
   {
    IGRshort	*loc_mattyp;
    IGRdouble	*loc_mat;

    loc_mattyp = (i == 2) ? other_mattyp : mattyp;
    loc_mat =  (i == 2) ? other_mat : mat;

    partol[i].mattyp = loc_mattyp;
    partol[i].mat = loc_mat;
    partol[i].is_valid = FALSE;
    if(loc_mattyp) env[i].matrix_type = *loc_mattyp;
    OM_BLOCK_MOVE(loc_mat, env[i].matrix, sizeof(IGRmatrix));
    surf[i].datatype = EMSdata_object;
    tol_ptrs[i] = (struct EMSpartolbasis *) &partol[i];
    surf_ptrs[i] = (struct EMSdataselect *) &surf[i];
    env_ptrs[i] = (struct GRmdenv_info *) &env[i];
    exact_uv_ptrs[i] = (IGRdouble *) exact_uv[i];
   }

  srf_geom1 = (struct IGRbsp_surface *)
              (refine_intobj->this_obj_node->more_info);

  if(save_refine_intobj_next)
   srf_geom2 = (struct IGRbsp_surface *)
                   (save_refine_intobj_next->this_obj_node->more_info);
  else
   {
    surf_ptrs[1] = NULL;
    exact_uv_ptrs[1] = NULL;
    srf_geom2 = NULL;
   }

  if(refine_intobj->other_intobj_node)
   srf_geom3 = (struct IGRbsp_surface *) 
                  (refine_intobj->other_intobj_node->this_obj_node->more_info);
  else
   {
    surf_ptrs[2] = NULL;
    exact_uv_ptrs[2] = NULL;
    srf_geom3 = NULL;
   }

  if(srf_geom1)
   {
     surf[0].datatype = EMSdata_surface;
     sts = EFsspbtol_by_geom(EMmsg, srf_geom1, &partol[0].tol);
     if(!(1&*EMmsg&sts)) goto wrapup;
     partol[0].is_valid = TRUE;
   }
  if(srf_geom2)
   {
    surf[1].datatype = EMSdata_surface;
    sts = EFsspbtol_by_geom(EMmsg, srf_geom2, &partol[1].tol);
    if(!(1&*EMmsg&sts)) goto wrapup;
    partol[1].is_valid = TRUE;
   }
  if(srf_geom3)
   {
    surf[2].datatype = EMSdata_surface;
    sts = EFsspbtol_by_geom(EMmsg, srf_geom3, &partol[2].tol);
    if(!(1&*EMmsg&sts)) goto wrapup;
    partol[2].is_valid = TRUE;
   }

  /* Prepare data for the three surfaces.
  */
  if(surf[0].datatype == EMSdata_object)
    surf[0].data.object = (struct GRid *) 
			 &refine_intobj->this_obj_node->this_obj;
  else surf[0].data.surface = srf_geom1;

  if(save_refine_intobj_next && surf[1].datatype == EMSdata_object)
    surf[1].data.object = (struct GRid *) 
			&save_refine_intobj_next->this_obj_node->this_obj;
  else surf[1].data.surface = srf_geom2;

  if(refine_intobj->other_intobj_node && surf[2].datatype == EMSdata_object)
    surf[2].data.object = (struct GRid *) 
		    &refine_intobj->other_intobj_node->this_obj_node->this_obj;
  else surf[2].data.surface = srf_geom3;

  approx_uv_ptrs[0] = IF_NULL_OBJID(edpar1->edgeid) ? NULL : edpar1->point;
  approx_uv_ptrs[1] = edpar2 ? 
		      (IF_NULL_OBJID(edpar2->edgeid) ? NULL : edpar2->point)
		      : NULL;
  approx_uv_ptrs[2] = approx_uv3;

  /* When the exact intersection is computed the linear edge concerned
     can immediately refine itself and the common edge (if the info is
     available for the common edge).
  */
  refined_edge = refined_comm = FALSE;
  BSEXTRACTPAR(&rc, BSTOLLENVEC, xyz_tol);

  at_begin1 = TRUE;
  if(begin1 && refine_intobj->reversed) at_begin1 = FALSE;
  else if(!begin1 && !refine_intobj->reversed) at_begin1 = FALSE;

  if(refine_intobj_next)
   {
    at_begin2 = TRUE;
    if(begin2 && refine_intobj_next->reversed) at_begin2 = FALSE;
    else if(!begin2 && !refine_intobj_next->reversed) at_begin2 = FALSE;
   }

  /* IMPORTANT: The code below tries to refine the relevant endpts of the three
   * ---------  different intobjs that tke part in the triple surface iteration.
   * There is an assumtions made in this code that:
   *    LOGICAL flow of the "this_uvintobj" dataselect and the "this_xyzintobj"
   *    dataselect is ALWAYS matched. This integrity is maintained throughout 
   *    the boolean code.
   * Now, the incoming parameters "begin1" and "begin2" refer to the LOGICAL 
   * directions of the incoming "refine_intobj" and "refine_intobj_next". It is
   * explained through an example below, how to translate this information into
   * which ACTUAL ends (in the NATURAL geometry of the UV and XYZ dataselects)
   * need to be modified with the exact point.
   *
   * - "begin1" and "begin2" refer to the LOGICAL direction of INTOBJ.
   * - "at_begin1" and "at_begin2" refer to the NATURAL direction of intobj's
   *         "this_xyzintobj" dataselect.
   * - "extnd_loc1/2" is essentially same as "at_begin1/2".
   * - "extnd_loc_uv1/2/3" refer to  NATURAL direction of intobj's 
   *           "this_uvintobj" dataselect.
   *
   * Say begin1 is TRUE. This implies that the point we want to refine is at the
   * LOGICAL begin of "refine_intobj". Assume that intobj has reverse bit set.
   * Since the logical direction of intobj is obtained after applying the 
   * intobj reversed bit to the logical direction of the uv or xyz dataselect,
   * we use that flag to determine the ends of the natural geometry of the xyz
   * dataselect that needs to be modified. For the UV dataselect, however, ONLY 
   * in case it is an EMSedge object, we have to contend with ANOTHER reversal
   * bit, which is the edge reversal bit. Therefore, we apply the edge reversal
   * to the flag calculated for the xyz natural end to now obtain the natural
   * end of the uv dataselect that needs to be modified. In case the uv 
   * dataselect is NOT an EMSedge object, the flag is the SAME for the uv and 
   * xyz dataselects.
   * Since we are assuming intobj is reversed, at_begin1 is FALSE ==>we have to 
   * modify the STOPPT of the natural geomerty of the XYZ dataselect. If the 
   * UV data was an EMSedge and was REVERSED, that would mean that we have to
   * modify the STARTPT of the natural geomety of the edge. Therefore, 
   * extnd_loc1 would be END and extnd_loc_uv1 would be START. Hope this helps
   * to explain the code below.
   * (NP 12/23/93)
   */ 
  extnd_loc1 = at_begin1 ? BEGIN : END;
  extnd_loc2 = at_begin2 ? BEGIN : END;
  replace_endpt = FALSE;

  if(coinc1 || coinc2) *EMmsg = EMS_I_NoSolution;
  else
   {
    sts = om$send(msg = message EMSedge.EMrefine_points(EMmsg, surf_ptrs, 
	       env_ptrs, tol_ptrs, approx_uv_ptrs, approx_xyz, exact_uv_ptrs,
	       xyz_exact, edpar1, edpar2, &refined_edge, 
	       &refined_comm, &retrim[0], &retrim[1], NULL), 
			senderid = NULL_OBJID, targetid = edpar1->edgeid, 
			targetos = sfos);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }

  if(*EMmsg != EMS_I_NoSolution)
   {
    if(*EMmsg == EMS_I_ParOutOfBounds) project_on_comm_surf = TRUE;
    if(*EMmsg == EMS_I_NoCommonEdge)
     {
      refine_intobj_next = NULL;
      edpar2 = NULL;
      refined_comm = FALSE;
     }

    if(refined_edge && retrim[0])
     {
      sts = EMsm_check_in_hole(EMmsg, refine_intobj, &partol[0], mattyp, mat);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(*EMmsg == EMS_I_IntersectTrim) retrim[0] = FALSE;
     }

    if(refined_comm && retrim[1] && refine_intobj_next)
     {
      sts = EMsm_check_in_hole(EMmsg, refine_intobj_next, &partol[1], mattyp, 
				mat);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(*EMmsg == EMS_I_IntersectTrim) retrim[1] = FALSE;
     }

   /* Now that the exact intersections are known, the data needs to be
      changed. It is possible that the exact intersection UV may be within
      parametric tolerance from the approximate UV, while the model space
      point is not within tolerance. The exact intersection point is introduced
      if it is outside tolerance in the appropriate space.

      Refinement of the existing linear edges, by way of introduction of exact
      points, has already been accomplished. We now need to do the
      following -
     1) Introduce the exact intersection in the model space intersection
        obtained through refine_intobj.this_xyzintobj
     2) introduce exact_uv[0] into the parametric intersection edge obtained
	through refine_intobj.this_uvintobj
     3) introduce exact_uv[2] into the parametric intersection edge obtained 
	through refine_intobj.other_intobj_node.this_uvintobj
     4) Update all the intersection points, incedent on the edges that were
	modified.
   */
   /*
     SM 7/21/93
     If an intersection is marked as being exact at the end we are looking
     at, do not modify any of its data.
   */
    exact1 = exact2 = exact3 = FALSE;

    exact1 = begin1 ? (refine_intobj->props & EMSintobj_exact_atstart) :
                      (refine_intobj->props & EMSintobj_exact_atstop);

    if(refine_intobj_next)
     exact2 = begin2 ? (refine_intobj_next->props & EMSintobj_exact_atstart) :
                        (refine_intobj_next->props & EMSintobj_exact_atstop);
	
    /*
      exact3 is determined further down, when correct end of the other intobj
      is known.
    */    

    if( (refine_intobj->this_xyzintobj.datatype == EMSdata_poly3d) &&
	!retrim[0] && !exact1)
     {
      sts = EMextend_poly(EMmsg, 3, refine_intobj->this_xyzintobj.data.poly, 
			NULL, xyz_exact, &extnd_loc1, replace_endpt, NULL, 
			NULL, xyz_tol, TRUE);
      /*if(!(1&*EMmsg&sts)) goto wrapup;*/
      if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
     }
    else if( (refine_intobj->this_xyzintobj.datatype == EMSdata_curve3d) &&
	!retrim[0] && !exact1)
     {
      /* When a curve is extended, new memory is allocated. Since two intobj
	 nodes share the same xyz data, update the pointer in the 
	 'other_intobj_node' also.
      */
      sts = EMextend_curve(EMmsg, &refine_intobj->this_xyzintobj.data.curve, 
			NULL, xyz_exact, &extnd_loc1, xyz_tol, 3, TRUE);
      if(refine_intobj->other_intobj_node)
	refine_intobj->other_intobj_node->this_xyzintobj.data.curve = 
			refine_intobj->this_xyzintobj.data.curve;
			
      /*if(!(1&*EMmsg&sts)) goto wrapup;*/
      if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
     }
    else if( (refine_intobj->this_xyzintobj.datatype == EMSdata_object) &&
	!retrim[0] && !exact1)
     {
      sts = EMextend_object(EMmsg, refine_intobj->this_xyzintobj.data.object, 
			xyz_exact, &extnd_loc1, xyz_tol, const_list->env_info, 
			TRUE);
      /*if(!(1&*EMmsg&sts)) goto wrapup;*/
      if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
     }
    sts = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    if(project_on_comm_surf && refine_intobj_next && !exact2)
     {
      IGRboolean	bssts;
      IGRdouble		dist, junk_uv[2];
    
      if(srf_geom2)
       {
       bssts = BSmdistptsf(&rc, srf_geom2, xyz_exact, &junk_uv[0], &junk_uv[1],
			  junk_exact, &dist);
       if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
       }
      else OM_BLOCK_MOVE(xyz_exact, junk_exact, 3 * sizeof(IGRdouble));
     }

    if(refine_intobj_next && 
     (refine_intobj_next->this_xyzintobj.datatype == EMSdata_poly3d) &&
     !retrim[1] && !exact2)
    {
     sts = EMextend_poly(EMmsg, 3, 
			refine_intobj_next->this_xyzintobj.data.poly, 
			NULL, project_on_comm_surf ? junk_exact : xyz_exact, 
			&extnd_loc2, replace_endpt, NULL, 
			NULL, xyz_tol, TRUE);
     /*if(!(1&*EMmsg&sts)) goto wrapup;*/
     if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
    }
   else if(refine_intobj_next && 
     (refine_intobj_next->this_xyzintobj.datatype == EMSdata_curve3d) &&
     !retrim[1] && !exact2)
    {
     sts = EMextend_curve(EMmsg,
			&refine_intobj_next->this_xyzintobj.data.curve, 
			NULL, project_on_comm_surf ? junk_exact : xyz_exact, 
			&extnd_loc2, xyz_tol, 3, TRUE);
     if(refine_intobj_next->other_intobj_node)
	refine_intobj_next->other_intobj_node->this_xyzintobj.data.curve = 
			refine_intobj_next->this_xyzintobj.data.curve;
			
    /*if(!(1&*EMmsg&sts)) goto wrapup;*/
    if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
    }
   else if(refine_intobj_next && 
     (refine_intobj_next->this_xyzintobj.datatype == EMSdata_object) &&
     !retrim[1] && !exact2)
    {
     sts = EMextend_object(EMmsg,  
			refine_intobj_next->this_xyzintobj.data.object, 
			project_on_comm_surf ? junk_exact : xyz_exact, 
			&extnd_loc2, xyz_tol, const_list->env_info, TRUE);
     /*if(!(1&*EMmsg&sts)) goto wrapup;*/
     if(*EMmsg != EMS_I_Degenerate) retrace = TRUE;
    }
   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

    extnd_loc3 = UNKNOWN;

  /* Try to determine extnd_loc3 through reversal flags. Else this will be
     determined later by a geometrical check.
  */

   if(refine_intobj && !retrim[0] && (junk1 =refine_intobj->other_intobj_node))
    {
     IGRushort flag1, flag2;

     flag1 = refine_intobj->reversed ? 0x1 : 0x0;
     flag2 = junk1->reversed ? 0x1 : 0x0;
     begin1_other = flag1 ^ flag2 ? !begin1 : begin1;
     flag1 = begin1_other ? 0x1 : 0x0;
     begin1_other = flag1 ^ flag2 ? TRUE : FALSE;
     extnd_loc3 = begin1_other ? BEGIN : END;

     /* IS this call needed here? */
     sts = EFtoggle_extnd_loc(&msg_loc, 
                     &(refine_intobj->other_intobj_node->this_uvintobj),
                     extnd_loc3, &extnd_loc_uv3);         
     EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup); 

     /* Is this intersection already exact at the end we are looking at?
     */
     if(extnd_loc3 == BEGIN)
      exact3 = junk1->reversed ? (junk1->props & EMSintobj_exact_atstop)
                               : (junk1->props & EMSintobj_exact_atstart);
     else if(extnd_loc3 == END)
      exact3 = junk1->reversed ? (junk1->props & EMSintobj_exact_atstart)
                               : (junk1->props & EMSintobj_exact_atstop);
    }


  /* Introduce the exact_uv[0] point.
  */
   if(!retrim[0] && !exact1)
    {
     extnd_loc1 = at_begin1 ? BEGIN : END;

     sts = EFtoggle_extnd_loc(&msg_loc, 
                  &(refine_intobj->this_uvintobj), extnd_loc1, &extnd_loc_uv1); 
     EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup); 

     sts = EMrefine_data(EMmsg, exact_uv_ptrs[0], &extnd_loc_uv1, replace_endpt,
		      &partol[0], refine_intobj, &retrace,
                      &surf[0], mat, mattyp);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* Introduce exact_uv[1]
   */
   if(refine_intobj_next && !retrim[1] && !exact2)
    {
     extnd_loc2 = at_begin2 ? BEGIN : END;

     sts = EFtoggle_extnd_loc(&msg_loc, 
               &(refine_intobj_next->this_uvintobj),extnd_loc2,&extnd_loc_uv2); 
     EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup); 

     sts = EMrefine_data(EMmsg, exact_uv_ptrs[1], &extnd_loc_uv2, replace_endpt,
			&partol[1], refine_intobj_next, &retrace, 
			&surf[1], mat, mattyp);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* Introduce the exact_uv[2] point. extnd_loc3 has been possibly determined
    * while linking the two intobj (through their fwd bwd pointers) on the
    * other surface(s). If it has remained unknown then geometrical
    * determination will be done by the function.
   */
   if(refine_intobj->other_intobj_node && !exact3)
    {
     sts = EMrefine_data(EMmsg, exact_uv_ptrs[2], &extnd_loc_uv3, replace_endpt,
		      &partol[2], refine_intobj->other_intobj_node, &retrace,
		      &surf[2], other_mat, other_mattyp);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   /* If a point was introduced, the trim boundaries concerning this edge
      need to be updated. We have the id of the edge which was actually
      refined (full edge). In the trim list we may have a partedge. So
      to be sure, always check the bottom most edge ids.
   */

   refined_edgeid = refined_commid = NULL_OBJID;

   if(refined_edge)
     sts = om$send(msg = message EMSedge.EMget_bottom_edge
				(EMmsg, &refined_edgeid), 
			senderid = NULL_OBJID, targetid = edpar1->edgeid, 
			targetos = sfos);
   if(refined_comm)
        sts = om$send(msg = message EMSedge.EMget_bottom_edge
			(EMmsg, &refined_commid), senderid = NULL_OBJID, 
		targetid = edpar2->edgeid, targetos = sfos);

   if(refined_edge || refined_comm)
   {
    temp_edpar1 = *edpar1;
    if(edpar2) temp_edpar2 = *edpar2;

    for(i=0; i<*num_grps; i++)
     {
      for(j=0; j<(*num_subgrps_grp)[i]; j++)
       {
	this_elem = (struct EMSintobj *) (*elems)[i][j];
	for(k=0; (k<(*num_elems_subgrp)[i][j]) && this_elem; k++)
	 {
	   edpar = (struct EMSsfintedpar *) this_elem->more_info;
	   for(l=0; (l<2) && edpar; l++)
	    {
	     if(IF_NULL_OBJID(edpar->edgeid))
	      {
	       if(edpar) edpar = edpar->next;
	       continue;
	      }
	
             bot_edge = NULL_OBJID;
	     sts = om$send(msg = message EMSedge.EMget_bottom_edge
					(EMmsg, &bot_edge), 
				senderid = NULL_OBJID, 
				targetos = sfos, 
				targetid = edpar->edgeid);
	     if(!IF_NULL_OBJID(refined_edgeid) &&
		 IF_EQ_OBJID(bot_edge, refined_edgeid))
	      {
                 sts = om$send(msg = message EMSedge.EMptproject
				(EMmsg, edpar->point, 1, &proj_info, 
				 NULL, &partol[0]), targetos = sfos, 
			senderid = NULL_OBJID, targetid = edpar->edgeid);
	         if(!(1&*EMmsg&sts)) goto wrapup;
	         OM_BLOCK_MOVE(&proj_info.param, &edpar->edgepar, 
					sizeof(struct EMSedgebound));
		 if(proj_info.location != EMScvint_unknown)
		    edpar->intloc = proj_info.location;
	      }
	     if(!IF_NULL_OBJID(refined_commid) &&
		 IF_EQ_OBJID(bot_edge, refined_commid))
	      {
                 sts = om$send(msg = message EMSedge.EMptproject
				(EMmsg, edpar->point, 1, &proj_info, 
				 NULL, &partol[1]), targetos = sfos, 
			senderid = NULL_OBJID, targetid = edpar->edgeid);
	         if(!(1&*EMmsg&sts)) goto wrapup;
	         OM_BLOCK_MOVE(&proj_info.param, &edpar->edgepar, 
					sizeof(struct EMSedgebound));
		 if(proj_info.location != EMScvint_unknown)
		     edpar->intloc = proj_info.location;
	      }
	
	     if(edpar) edpar = edpar->next;
	
	    } /* for(l=0; l<2; l++) */
	
	  if(this_elem) this_elem = this_elem->next;
	
	 } /* for(k=0; k<(*num_elems_subgrp)[i][j]; k++) */
	
       } /* for(j=0; j<(*num_subgrps_grp)[i]; j++) */

     } /* for(i=0; i<*num_grps; i++) */

   } /* if(refined_edge || refined_comm) */

 } /* if(*EMmsg != EMS_I_NoSolution) */

/* If we had mismatched topology then the intobjs should be incedent at the
   ends of their respective edges. If refinement has not achieved this then
   the intobj(s) need to be modified. If the common edges matched for both
   the intobjs then the split locations for both should be middle or
   ends. If the split locations are not consistent then the offending intobj
   needs to be pushed.
*/
 if(mismatched_topology ||
    (!IF_NULL_OBJID(edpar1->edgeid) && (edpar1->intloc != EMScvint_middle) 
     && save_edpar2 && !IF_NULL_OBJID(save_edpar2->edgeid) &&
    (save_edpar2->intloc == EMScvint_middle)) ||
    (!IF_NULL_OBJID(edpar1->edgeid) && (edpar1->intloc == EMScvint_middle) 
     && save_edpar2 && !IF_NULL_OBJID(save_edpar2->edgeid) &&
    (save_edpar2->intloc != EMScvint_middle)))
  {
   IGRdouble		junkpt[2][2], *pt, lentol, dist1, dist2;
   IGRint		uvsize, i;
   struct EMSedgebound  junkpar[2], *par;
   enum	EMScvinttype	loc;
   struct EMSsfintedpar	*edpar[2];
   struct EMSintobj	*intobj[2];
   IGRboolean		begin[2], nocommedges = TRUE;

   if(IF_NULL_OBJID(edpar1->edgeid) || IF_NULL_OBJID(save_edpar2->edgeid))
    goto wrapup;

   uvsize = 2 * sizeof(IGRdouble);
   edpar[0] = (struct EMSsfintedpar *) edpar1;
   edpar[1] = (struct EMSsfintedpar *) save_edpar2;
   intobj[0] = (struct EMSintobj *) refine_intobj;
   intobj[1] = (struct EMSintobj *) save_refine_intobj_next;

   at_begin1 = TRUE;
   if(begin1 && refine_intobj->reversed) at_begin1 = FALSE;
   else if(!begin1 && !refine_intobj->reversed) at_begin1 = FALSE;

   at_begin2 = TRUE;
   if(begin2 && save_refine_intobj_next->reversed) at_begin2 = FALSE;
   else if(!begin2 && !save_refine_intobj_next->reversed) at_begin2 = FALSE;

   begin[0] = at_begin1;
   begin[1] = at_begin2;
   
   /* SM 03/20/92 - If both the incedent edges have no common edges, 
      then do not process.
   */
   nocommedges = TRUE;
   for(i=0; i<2; i++)
    {
     IGRint		commed, locsts;

     commed = 0;
     locsts = om$get_channel_count(objid = edpar[i]->edgeid, 
	      osnum = sfos, p_chanselect = &to_common_edge, 
	      count = (OMuint *)&commed);
     if(commed)
      {
       nocommedges = FALSE;
       break;
      }
    }
   if(nocommedges) goto wrapup;


   for(i=0; i<2; i++)
    {
     if( (edpar[i]->intloc == EMScvint_middle) && 
	  !IF_NULL_OBJID(edpar[i]->edgeid))
      {
	IGRushort edprops = NULL;

       /* If the incedent edge is degenerate do not mess with it.
       */     
       sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
		targetos = sfos, 
		targetid = edpar[i]->edgeid, senderid = edpar[i]->edgeid);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(edprops & EMED_DEGENERATE)
	{
	  IGRint		commed = 0;
	  OM_S_OBJECT_LINKAGE	junk;
	
	  sts = om$get_channel_objects(objid = edpar[i]->edgeid, 
			osnum = sfos, p_chanselect = &to_common_edge, 
			list = &junk, size = 1, count = (OMuint *)&commed);
          if(!commed) continue;
	}

       sts = om$send(msg = message EMSedge.EMendpts(EMmsg, junkpt[0], 
		junkpt[1], junkpar, &junkpar[1], NULL), targetos = sfos, 
		targetid = edpar[i]->edgeid, senderid = edpar[i]->edgeid);
       if(!(1&*EMmsg&sts)) goto wrapup;
       sts = EFextract_par(BSTOLLENVEC, partol[i].tol, &lentol, &rc);

       /* Move towards the closest endpoint of the edge.
       */
       if( (dist1 = EM2ddistptpt(edpar[i]->point, junkpt[0])) <
	   (dist2 = EM2ddistptpt(edpar[i]->point, junkpt[1])))
        {
	 pt = (IGRdouble *) junkpt[0];
	 par = (struct EMSedgebound *) junkpar;
	 loc = EMScvint_lfend;
        }
       else
        {
	 pt = (IGRdouble *) junkpt[1];
	 par = (struct EMSedgebound *) &junkpar[1];
	 loc = EMScvint_rtend;
        }
       extnd_loc1 = begin[i] ? BEGIN : END;

       sts = EFtoggle_extnd_loc(&msg_loc, 
                     &(intobj[i]->this_uvintobj),extnd_loc1,&extnd_loc_uv1); 
       EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup); 

       sts = EMrefine_data(EMmsg, pt, &extnd_loc_uv1, replace_endpt, 
		      &partol[i], intobj[i], &retrace, &surf[i], mat, mattyp);
       if(!(1&*EMmsg&sts)) goto wrapup;

#if DEBUG
       if(*EMmsg == EMS_S_Success);
        fprintf(stderr, "Mismatched Topology - Geom Modified\n");
#endif
       edpar[i]->intloc = loc;
       OM_BLOCK_MOVE(pt, edpar[i]->point, uvsize);
       edpar[i]->edgepar = *par;

      } /* if(edpar[i]->intloc == EMScvint_middle) */

    } /* for(i=0; i<2; i++) */

  }/* if(mismatched_topology) */

wrapup:
  if(!(1&*EMmsg&sts)) {*EMmsg = EMS_I_NoSolution; sts = OM_S_SUCCESS;}
	
  /* If there was any kind of problem, mark the intobjs as being exact so
     that the caller may choose not to reprocess them. This is cheating, 
     but justifiable for lack of bits. The property should actually be 
     something like EMSintobj_problem_atstart and EMSintobj_problem_atstop.
  */
  if(*EMmsg == EMS_I_NoSolution)
   {
    if(refine_intobj)
      refine_intobj->props |= begin1 ? EMSintobj_exact_atstart :
				     EMSintobj_exact_atstop;
    if(save_refine_intobj_next)
      save_refine_intobj_next->props |= begin2 ? EMSintobj_exact_atstart :
				     EMSintobj_exact_atstop;
   }

  /* Regardless of any problem, connect the two intobjs through their fwd/bwd
     pointers so that subsequent tracing becomes independent of the
     tolerance. If due to orientation or incorrect link up problems, the
     pointers are already set and are conflicting with the new pointers, 
     then break all pointer connections made in this run.
  */
  if(refine_intobj && save_refine_intobj_next)
   {
    IGRboolean ok = FALSE;
    extern IGRboolean EMrecord_pointers();

    ok = EMrecord_pointers(EMmsg, begin1, begin2, refine_intobj, 
				save_refine_intobj_next);
    if(ok) retrace = TRUE;
   }


/* If the variable retrace is set, unconditionally return EMS_S_Success becuase
   some data was changed before problem arose and the situation warrants
   a retrace to accomodate change in the data. 
*/
  if(retrace) *EMmsg = EMS_S_Success;
  else if(*EMmsg != EMS_I_NoSolution) *EMmsg = EMS_I_Degenerate;
return(OM_S_SUCCESS);
}

/*
from EMSloop import EMsetrange;
*/

static IGRint EMrefine_data(EMmsg, exact_uv, extnd_loc, replace_endpt, 
			    partolbasis, refine_intobj, retrace, 
			    surf, mat, mattyp)
IGRlong			*EMmsg;
IGRdouble		*exact_uv;
IGRint			*extnd_loc;
IGRboolean		replace_endpt, *retrace;
struct EMSpartolbasis	*partolbasis;
struct EMSintobj	*refine_intobj;
struct EMSdataselect    *surf;
IGRmatrix		mat;
IGRshort		*mattyp;

{
 IGRlong 		sts, rc;
 struct EMSsfintedpar	*edpar;
 IGRint			uvsize = 2*sizeof(IGRdouble);
 IGRint			mod_extnd_loc=UNKNOWN;
 struct EMSproj_info	proj_info;
 enum EMSdatatype	type;
 IGRdouble		lentol;
 GRspacenum		sfos;
 extern IGRint		EMextend_poly(), EMextend_curve();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sfos = refine_intobj->this_obj_node->this_obj.osnum;
 type = refine_intobj->this_uvintobj.datatype;
 if(partolbasis->is_valid)
   sts = EFextract_par(BSTOLLENVEC, partolbasis->tol, &lentol, &rc);
 else lentol = 0.00000001;

 if(type == EMSdata_object)
  sts = om$send(msg = message EMSedge.EMextend_geom
	(EMmsg, exact_uv, extnd_loc, replace_endpt, NULL, NULL, 
	 NULL, partolbasis, NULL, 
	 surf->datatype == EMSdata_object ? surf->data.object : NULL,
	 surf->datatype == EMSdata_surface ? surf->data.surface : NULL,
         mat, mattyp), 
	 targetid = refine_intobj->this_uvintobj.data.object->objid, 
	 targetos = refine_intobj->this_uvintobj.data.object->osnum, 
	 senderid = NULL_OBJID);
 else if(type == EMSdata_poly2d)
  sts = EMextend_poly(EMmsg, 2, refine_intobj->this_uvintobj.data.poly, NULL, 
		     exact_uv, extnd_loc, replace_endpt, NULL, NULL, lentol, 
		     TRUE);
 else if(type == EMSdata_curve3d)
  sts = EMextend_curve(EMmsg, &refine_intobj->this_uvintobj.data.curve, NULL, 
			exact_uv, extnd_loc, lentol, 2, TRUE);
 else *EMmsg = EMS_E_InvalidArg; 
	
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(*EMmsg == EMS_I_InvalidArg) goto wrapup;

 /* Set the appropriate property in the intobj to indicate that it does not
    get any better than this.
    NP (12/23/93): The "extnd_loc" coming into this function takes the possible
   --------------  reversed bit of an EMSedge dataselect into account while 
                   deciding which end of the intobj uv dataselect's NATURAL 
                   geometry to modify. The more-info attached to the intobj node
                   is however with respect ot the LOGICAL diretion of the UV
                   dataselect. Therefore use "mod_extnd_loc", which indicates 
                   the correct logical end of the UV dataselect modified. The
                   function is really used to toggle the input extend_loc, if
                   the UV dataselect is an EMSedge and it is REVERSED.
*/

 if (extnd_loc)
 {
/****
    The logic makes sense, but this dosent seem to work. Needs some more 
    investigation.

    EFtoggle_extnd_loc(EMmsg, &(refine_intobj->this_uvintobj), *extnd_loc, 
                               &mod_extnd_loc);
    if(!(1&sts&*EMmsg)) goto wrapup;
*****/

    mod_extnd_loc = *extnd_loc;
 
    if(mod_extnd_loc == BEGIN)
     refine_intobj->props |= refine_intobj->reversed ? EMSintobj_exact_atstop
						     : EMSintobj_exact_atstart;
    else if(mod_extnd_loc == END)
     refine_intobj->props |= refine_intobj->reversed ? EMSintobj_exact_atstart 
						     : EMSintobj_exact_atstop;
 }


 if(*EMmsg == EMS_I_Degenerate) goto wrapup;

 *retrace = TRUE;
 edpar = (struct EMSsfintedpar *) refine_intobj->more_info;
 if(extnd_loc && (*extnd_loc != BEGIN) && edpar) edpar = edpar->next;
 if(!edpar) goto wrapup;
 OM_BLOCK_MOVE(exact_uv, edpar->point, uvsize);
 if(!IF_NULL_OBJID(edpar->edgeid))
  {
   sts = om$send(msg = message EMSedge.EMptproject
	    (EMmsg, edpar->point, 1, &proj_info, NULL, partolbasis), 
		senderid = NULL_OBJID, targetid = edpar->edgeid, 
		targetos = sfos);
   if(!(1&*EMmsg&sts)) goto wrapup;
   OM_BLOCK_MOVE(&proj_info.param, &edpar->edgepar, 
					sizeof(struct EMSedgebound));
   if(proj_info.location != EMScvint_unknown)
	edpar->intloc = proj_info.location;
  }


wrapup:
return(sts);
}



static IGRint EMsm_check_in_hole(EMmsg, intobj, partol, mattyp, mat)
IGRlong		*EMmsg;
struct EMSintobj *intobj;
struct EMSpartolbasis *partol;
IGRshort	*mattyp;
IGRmatrix	mat;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count, num_bdrys = 0;
 OM_S_CHANSELECT	to_loopset;
 OM_S_OBJECT_LINKAGE	loopset;
 IGRushort	trim_options = NULL;
 struct GRid		sfid;

 *EMmsg = EMS_S_Success;

 /* If this intobj is already known to be in a hole, do not check, as the
    intent is not known.
 */
 if( intobj->props & EMSintobj_not_in_area )
  {
   *EMmsg = EMS_I_IntersectTrim;
   goto wrapup;
  }

 sfid = intobj->this_obj_node->this_obj;
 if(intobj->this_uvintobj.datatype == EMSdata_object)
  {
   struct GRid edgeid;
   edgeid = *(intobj->this_uvintobj.data.object);

   sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
   sfid = intobj->this_obj_node->this_obj;
   sts = om$get_channel_objects(objid = sfid.objid, osnum = sfid.osnum, 
			      p_chanselect = &to_loopset, list = &loopset, 
			      size = 1, count = (OMuint *)&count);
   if(!(1&sts)) goto wrapup;
   if(!count) goto wrapup;

   sts = om$send(msg = message EMSedge.EMtrimyourself(EMmsg, &loopset.S_objid, 
			trim_options, NULL, NULL, &num_bdrys, NULL, partol), 
			targetid = edgeid.objid, targetos = edgeid.osnum, 
			senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   sts = om$send(msg = message EMSsubbs.EMparttrim
			(EMmsg, mattyp, mat, &intobj->this_uvintobj, 
			 trim_options, &num_bdrys, NULL, NULL), 
		targetid = sfid.objid, targetos = sfid.osnum, 
		senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
	
 if(num_bdrys) *EMmsg = EMS_I_IntersectTrim; 

wrapup:
return(sts);

}




/* Given two intobjs this function will find the incedent edge pair that
   is common edge connected with each other. If found it will return
   TRUE else FALSE. When found it will alter the input incedent information
   to reflect the topologically continuous information.
*/
static IGRboolean EMget_correct_ends(EMmsg, intobj1, edpar1, 
			     	     intobj2, edpar2, begin1, begin2, 
				     approx_xyz, approx_uv3, to_comm, 
				     sfos, mattyp, mat)
IGRlong			*EMmsg;
struct EMSintobj	*intobj1, *intobj2;
struct EMSsfintedpar	**edpar1, **edpar2;
IGRboolean		*begin1, *begin2;
IGRdouble		*approx_xyz, *approx_uv3;
OM_S_CHANSELECT		*to_comm;
GRspacenum		sfos;
IGRshort		*mattyp;
IGRmatrix		mat;
{
 IGRlong		sts;
 struct EMSsfintedpar	*good1 = NULL, *good2 = NULL, *ptr1, *ptr2, *altptr;
 IGRint			i;
 GRobjid		vtxeds[2];
 extern void		EMbreak_connection();
 IGRboolean		deg1 = FALSE, deg2 = FALSE;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 ptr2 = (struct EMSsfintedpar *) intobj1->more_info;
 if(ptr2 == (*edpar1)) ptr2 = ptr2->next;

 altptr = (*edpar2)->next;
 if (!altptr)
  altptr = (struct EMSsfintedpar *)(intobj2->more_info);

 if ((*edpar1)->intloc != EMScvint_middle && 
     (*edpar2)->intloc != EMScvint_middle)
  {
   good1 = *edpar1;
   good2 = *edpar2;
   goto wrapup;
  }

 if(intobj1->props & EMSintobj_uvdegenerate)
  deg1 = TRUE;
 else
  deg1 = EMdegenerate_data(&intobj1->this_uvintobj, FALSE, NULL);

 if(intobj2->props & EMSintobj_uvdegenerate)
  deg2 = TRUE;
 else
  deg2 = EMdegenerate_data(&intobj2->this_uvintobj, FALSE, NULL);

 if(!deg1 && !deg2)
  {
   good1 = *edpar1;
   good2 = *edpar2;
   goto wrapup;
  }

 for(i=0; i<2; i++)
  {
   ptr1 = i ? ptr2 : *edpar1;
   if(!ptr1) break;

   if (ptr1->intloc != EMScvint_middle && (*edpar2)->intloc == EMScvint_middle)
    {
     sts = om$send (msg = message EMSedge.EMfind_commvtx (EMmsg,
            ptr1->edgeid, ptr1->intloc == EMScvint_rtend ? TRUE : FALSE,
            TRUE, vtxeds), targetid = (*edpar2)->edgeid, targetos = sfos,
            senderid = NULL_OBJID);
     if (*EMmsg == EMS_S_Success) sts = OM_S_SUCCESS;
     else sts = OM_E_ABORT;
    }
   else if ((*edpar2)->intloc != EMScvint_middle && ptr1->intloc ==
						    EMScvint_middle)
    {
     sts = om$send (msg = message EMSedge.EMfind_commvtx (EMmsg, 
	    (*edpar2)->edgeid, 
	    (*edpar2)->intloc == EMScvint_rtend ? TRUE : FALSE,
            TRUE, vtxeds), targetid = ptr1->edgeid, targetos = sfos,
            senderid = NULL_OBJID);
     if (*EMmsg == EMS_S_Success) sts = OM_S_SUCCESS;
     else sts = OM_E_ABORT;
    }
   else
     sts = om$is_objid_on_channel(objid_c = ptr1->edgeid, osnum_c = sfos, 
				p_chanselect = to_comm, 
				objid = (*edpar2)->edgeid);

   if(sts == OM_S_SUCCESS)
    {
     good1 = ptr1;
     good2 = (*edpar2);
     break;
    }
   else if (altptr)
    {
     if (ptr1->intloc != EMScvint_middle && altptr->intloc == EMScvint_middle)
      {
       sts = om$send (msg = message EMSedge.EMfind_commvtx (EMmsg,
            ptr1->edgeid, ptr1->intloc == EMScvint_rtend ? TRUE : FALSE,
            TRUE, vtxeds), targetid = altptr->edgeid, targetos = sfos,
            senderid = NULL_OBJID);
       if (*EMmsg == EMS_S_Success) sts = OM_S_SUCCESS;
       else sts = OM_E_ABORT;
      }
     else if (altptr->intloc != EMScvint_middle && ptr1->intloc ==
						   EMScvint_middle)
      {
       sts = om$send (msg = message EMSedge.EMfind_commvtx (EMmsg,
            altptr->edgeid, altptr->intloc == EMScvint_rtend ? TRUE : FALSE,
            TRUE, vtxeds), targetid = ptr1->edgeid, targetos = sfos,
            senderid = NULL_OBJID);
       if (*EMmsg == EMS_S_Success) sts = OM_S_SUCCESS;
       else sts = OM_E_ABORT;
      }
     else
      sts = om$is_objid_on_channel(objid_c = ptr1->edgeid, osnum_c = sfos, 
				p_chanselect = to_comm, 
				objid = altptr->edgeid);
     if(sts == OM_S_SUCCESS)
      {
       good1 = ptr1;
       good2 = altptr;
       break;
      }
    }

  } /* for(i=0; i<2; i++) */

wrapup:

if(good1 && (good1 != *edpar1))  
 {
  IGRdouble	junk[3];

  *edpar1 = good1;
  EMbreak_connection(intobj1);

  (*begin1) = !(*begin1);
  if(approx_xyz)
   {
    sts = EMgetendpts_xyz (EMmsg, mattyp, mat, 
				         &intobj1->this_xyzintobj,
                 	intobj1->reversed, 1, 
			!(*begin1) ? junk : approx_xyz, 
                 	!(*begin1) ? approx_xyz : junk);
    if(!(1&*EMmsg&sts)) return(FALSE);
   }

  if(approx_uv3 && intobj1->other_intobj_node)
   {
    sts = EMgetendpts_uv (EMmsg,
			&intobj1->other_intobj_node->this_uvintobj,
                 	intobj1->reversed, 1, 
			!(*begin1) ? junk : approx_uv3, 
			!(*begin1) ? approx_uv3 : junk);
    if(!(1&*EMmsg&sts)) return(FALSE);
   }
 }

if(good2 && (good2 != *edpar2))  
 {
  *edpar2 = good2;
  EMbreak_connection(intobj2);
  (*begin2) = !(*begin2);
 }

if(good1 || good2)
 {
  /* If an  end is flipped, check whether topology matches. If it still
     does not, we just have found a common vertex, and not common edge.
  */
  sts = om$is_objid_on_channel(objid_c = (*edpar1)->edgeid, osnum_c = sfos, 
				p_chanselect = to_comm, 
				objid = (*edpar2)->edgeid);
  if(sts == OM_S_SUCCESS) return(TRUE);
  else return(FALSE);
 }
else return(FALSE);

}

static IGRlong EFtoggle_extnd_loc(EFmsg, uvdata, in_extnd_loc, out_extnd_loc)
IGRlong *EFmsg;
IGRint in_extnd_loc, *out_extnd_loc;
struct EMSdataselect *uvdata;
{
  IGRlong sts, msg_loc;
 
  /**********************************************
  IGRushort edprops;
  GRclassid classid;
  IGRboolean ed_reversed=FALSE, is_partedge=FALSE;
  struct EMSedgebound start_param, end_param;
  **********************************************/

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  if (!uvdata || !out_extnd_loc)
  {
    if (out_extnd_loc)
       *out_extnd_loc = UNKNOWN;
    goto wrapup;
  }

  /* Initialize at start */
  if (out_extnd_loc)
       *out_extnd_loc = UNKNOWN;

  switch (uvdata->datatype)
  {
    case EMSdata_poly2d:
    case EMSdata_curve3d:
      if (out_extnd_loc)
         *out_extnd_loc = in_extnd_loc;
      break;
    case EMSdata_object:

      *out_extnd_loc = UNKNOWN;

      /**********************************************************************

      There is some problem with this stuff. I am not sure what. I am going to
      comment it out for now. It may not be just this call, but how the return 
      values from here are used to set "exact_at_star" and "exact_at_stop", 
      seems to be the problem. If I set out_extnd_loc to UNKNOWN, ribs dont 
      seem to be corrupting anymore, so I am leaving it that way.

      sts = om$get_classid (objid = uvdata->data.object->objid, 
                      osnum = uvdata->data.object->osnum,
                      p_classid = &classid);
      EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup); 

      if (om$is_ancestry_valid (subclassid = classid,
                         superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
      {
          if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
                is_partedge = TRUE;
          else
                is_partedge = FALSE;
      }
      else
        {EMerr_hndlr(TRUE, *EFmsg, EMS_I_InvalidArg, wrapup);}

       * Although for both part-edges and regular edges, we need to check for 
       * just the reverse bit, we choose to check bounds for part edges, since
       * its reverse bit is kind of redundant, and someday, somebody might NOT
       * set it, even though bounds were reversed.
       * 
      ed_reversed=FALSE;
      if (is_partedge)
      {
         sts = om$send (msg = message EMSedge.EMendpts (&msg_loc,
                                    NULL, NULL, &start_param, &end_param, NULL),
                        targetos = uvdata->data.object->osnum,
                        targetid = uvdata->data.object->objid, 
                        senderid = NULL_OBJID);
          EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup); 
    
          if ((start_param.param + (IGRdouble)(start_param.span_inx)) > 
              (end_param.param + (IGRdouble)(end_param.span_inx)))
              ed_reversed=TRUE;
      }
      else
      {
          sts = om$send(msg = message EMSedge.EMget_props(&msg_loc, &edprops),
                        targetos = uvdata->data.object->osnum,
                        targetid = uvdata->data.object->objid, 
                        senderid = NULL_OBJID);
          EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup); 
          if (edprops & EMED_REVERSED)
            ed_reversed=TRUE;
      } 

      if (out_extnd_loc)
         *out_extnd_loc = ed_reversed ? !in_extnd_loc : in_extnd_loc;
      ************************************************************************/

      break;
    default:
      EMerr_hndlr (TRUE, *EFmsg, EMS_I_InvalidArg, wrapup); 
  } 

 wrapup:

 EMWRAPUP(*EFmsg, sts, "In EFtoggle_extnd_loc");
 return (sts);
}
			
end implementation Root;
