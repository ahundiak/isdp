/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>			/* FILE 	*/
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsinter.h"
#include "emssfint.h"
#include "bscveval.h"
#include "bsbxint.h"
#include "bsbx2.h"

#define SELF	0
#define OTHR	1
#define BGN     0
#define END	1

#define EDGEU0 0
#define EDGEV1 1
#define EDGEU1 2
#define EDGEV0 3

#define TPED_BUF_SIZE	16

from GRvg   import GRgetsize, GRgetgeom;
from EMSloop import EMset_props;
from EMSloopset import EMset_props;
from EMSsubbs import EMpratmpt, EMgetactiveid, EMgetbsdef;
from EMSsurface import EMmovesurfs, EMrevorient;

extern OMuword OPP_EMSlinedge_class_id, OPP_EMSpartedge_class_id;

method 	EMstitch(IGRlong *EMmsg;
		   struct EMSstitch_info *pair;
		   struct GRmd_env *mod_info;
		   struct GRid *prim_obj;
		   IGRint sample_size;
		   IGRdouble match_tol;
		   struct EX_button *button;
		   FILE *fileptr)

/*
Description

  This method performs the "stitching" operation with a partner-to-be
  edge. If the edges share an overlap in model space, they are split
  at their overlap boundaries (if required) and appropriate pieces are
  connected.

Return Values

  EMS_S_Success - if the "stitching" is successful, i.e. there is at
		  at least one overlap, which is successfully stitched.

  EMS_I_Fail    - if the "stitching" is unsuccessful. This would imply
		  that either there was no overlap, or that the overlap
  		  did not survive the validation test (gap in the 
		  overlap).

Notes


History

  RV	09/01/87	Creation
  SM	14-May-88	Made modifications forced by argument changes in
			EMSedge.EMsplityourself
  SM	13-Oct-88	Fixed a bug where the method use to error out
			with EMS_E_InvalidArg if num partedges were greater
			than TPED_BUF_SIZE. It also used to cause memory
			overwrite (insufficient static memory being passed
			to EMget_top_part_edges). 
  SM	07-Aug-89	Support option to ignore gap. The matching is still
			performed under this option to determine whether
			splitting needs to be done, but the gaps are ignored
			and the edges are assumed to match (fully or partially)
			Also modified to call EMget_stitchtol().
  SM	11-Sep-89	For natural edge, compute uv point from overlap param
			directly (without evaluating the xyz point, and
			mapping it to uv). This will also solve the problem
			of landing on opposite seam if the natural edges
			are seam edges (example stitching v=1 and v=0
			edges of an helical surface).
  Sudha 06/04/93        modified to include BSprototype header files

*/

{
 IGRlong             		OM_stat;
 struct IGRbsp_curve 		*edge_geom[2], edge_buff[2];
 struct IGRbsp_surface  	*surf_geom[2];
 IGRpoint 			min[2], max[2];
 BSrc  				rc;
 IGRshort 			edg_ix, ovl_ix, end_ix;
 IGRint				num_ovlap;
 IGRdouble			bsovlap[2][4];
 IGRint				ovlap_type[2][4], i;
 struct EMSpartolbasis 		partolbasis[2];
 GRobjid 			edge[2], surf[2],
				connecting_edge[2], remaining_edge[2],
				result_edge[2];
 IGRushort		common_props = 0, props[2];
 IGRdouble			valdiff[2];
 IGRboolean			made_non_nat[2], one_closed, rev_connect,
           			one_rev_oriented = FALSE, toggle_norm = FALSE;
 OM_S_CHANSELECT		to_loop, to_loopset;
 IGRpoint			xyz_point, base_pt;
 IGRdouble 			uv_point[2], dist;
 struct EMSproj_info		proj_info;
 struct GRid         		active_id[2];
 struct EMSstitch_info		local_pair;
 IGRushort		props_0, props_1;
 struct IGRbsp_surface		def_0, def_1;
 IGRdouble			cht_tol, sti_tol;
 IGRint				num_hits, num_misses;
 GRobjid             		*pedges0 = NULL, *pedges1 = NULL;
extern void EMget_stitchtol() ;
 struct EMSsfintedpar		split_info, *split_info_ptr[2];
 extern IGRint			EMgetvggeom();

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 for(i=0; i<2; i++) 
  {
   edge_buff[i].poles = NULL;
   edge_buff[i].knots = NULL;
   edge_buff[i].weights = NULL;
   edge_buff[i].bdrys = NULL;
   edge_buff[i].rational = FALSE;
   surf_geom[i] = NULL;
   edge_geom[i] = NULL;
  }

 split_info_ptr[0] = &split_info;
 split_info_ptr[1] = NULL;
 split_info.info = NULL;
 split_info.next = NULL;
 
 if (! (pair->option & EMSstitch_TopEdge))
 {
  IGRint              pe0_idx, pe1_idx;
  OMuint              count;
  IGRint              num_pe0, num_pe1, buf_size0 = 0, buf_size1 = 0,
                      num_matches;
  OM_S_CHANSELECT     cm_ed_chan;

  pedges0 = NULL;
  pedges1 = NULL;
  num_pe0 = num_pe1 = num_matches = 0;
  OM_stat = om$send(msg = message EMSedge.EMget_top_part_edges(EMmsg,
	    &pedges0, &num_pe0, &buf_size0), targetid = pair->edge0);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);       
  OM_stat = om$send(msg = message EMSedge.EMget_top_part_edges(EMmsg,
	    &pedges1, &num_pe1, &buf_size1), targetid = pair->edge1);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);       

  local_pair.surf0 = pair->surf0;
  local_pair.surf1 = pair->surf1;
  local_pair.option = pair->option | EMSstitch_TopEdge;
  local_pair.surf_geom0 = pair->surf_geom0;
  local_pair.surf_geom1 = pair->surf_geom1;
  local_pair.edge_geom0 = pair->edge_geom0;
  local_pair.edge_geom1 = pair->edge_geom1;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  for (pe0_idx=0;pe0_idx<num_pe0;pe0_idx++)
   {
    OM_stat = om$get_channel_count(objid = pedges0[pe0_idx], 
              p_chanselect = &cm_ed_chan, count = &count);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
    if (count) continue;

    for (pe1_idx=0;pe1_idx<num_pe1;pe1_idx++)
     {
      OM_stat = om$get_channel_count(objid = pedges1[pe1_idx], 
                p_chanselect = &cm_ed_chan, count = &count);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
      if (count) continue;

      local_pair.edge0 = pedges0[pe0_idx];
      local_pair.edge1 = pedges1[pe1_idx];
      if (pedges0[pe0_idx] != pair->edge0) local_pair.edge_geom0 = NULL; 
      if (pedges1[pe1_idx] != pair->edge1) local_pair.edge_geom1 = NULL;

      OM_stat = om$send(msg = message EMSedge.EMstitch(EMmsg, &local_pair,
                mod_info, prim_obj, sample_size, match_tol, button, fileptr),
                targetid = pedges0[pe0_idx]);
      EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
      if (*EMmsg == EMS_I_Fail)  *EMmsg = EMS_S_Success;
      else num_matches++;
     } 
   }
  if (num_matches) *EMmsg = EMS_S_Success; else *EMmsg = EMS_I_Fail;
  goto wrapup;
 }

 edge[SELF] = my_id;
 edge[OTHR] = pair->edge1;
 surf[SELF] = pair->surf0;
 surf[OTHR] = pair->surf1;

 surf_geom[SELF] = pair->surf_geom0;
 surf_geom[OTHR] = pair->surf_geom1;
 edge_geom[SELF] = pair->edge_geom0;
 edge_geom[OTHR] = pair->edge_geom1;

 props[SELF] = ME.EMSedge->ed_props;
 OM_stat = om$send(msg =  message EMSedge.EMget_props(EMmsg, &props[OTHR]),
		   targetid = edge[OTHR]);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

 if ((props[SELF] & EMED_DEGENERATE) || (props[OTHR] & EMED_DEGENERATE))
 	{*EMmsg = EMS_I_Fail;goto wrapup;}

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
 
 sti_tol = 0;
 if(pair->option & EMSstitch_MatchTolerance)
  sti_tol = match_tol;
 else
  {
   EMget_stitchtol(EMmsg, edge[0], edge[1], &sti_tol);
   EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
  }

 for(edg_ix=0;edg_ix<2;edg_ix++)
 {
  connecting_edge[edg_ix] = remaining_edge[edg_ix] = edge[edg_ix];
  made_non_nat[edg_ix] = FALSE;

  if (! surf_geom[edg_ix])
   {
    struct GRid dummy;

    dummy.osnum = OM_Gw_current_OS;
    dummy.objid = surf[edg_ix];
    OM_stat = EMgetvggeom(EMmsg, &mod_info->md_env.matrix_type,
	       mod_info->md_env.matrix, &dummy, &surf_geom[edg_ix], NULL);
    EMerr_hndlr(!(1&*EMmsg&OM_stat), *EMmsg, EMS_E_SurfaceError,wrapup);
   }

  if (! edge_geom[edg_ix])
   {
    edge_geom[edg_ix] = (struct IGRbsp_curve *) &edge_buff[edg_ix];
    edge_geom[edg_ix]->poles = NULL;
    edge_geom[edg_ix]->knots = NULL;
    edge_geom[edg_ix]->weights = NULL;
    edge_geom[edg_ix]->bdrys = NULL;

    OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (EMmsg,
	      NULL, NULL, surf_geom[edg_ix], 0, OM_K_MAXINT,
	      (props[edg_ix] & EMED_REVERSED ? TRUE : FALSE), NULL, 
	      edge_geom[edg_ix]), targetid = edge[edg_ix]);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);
    if (*EMmsg == EMS_I_DegenerateEdge)
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (
                EMmsg, EMED_DEGENERATE, EMS_O_ON), targetid = edge[edg_ix]);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      *EMmsg = EMS_I_Fail; goto wrapup;
     }
   }
  if(! (pair->option & EMSstitch_NoRangeCheck))
   {
    BSbx2(&rc, &edge_geom[edg_ix]->num_poles, (IGRpoint *)edge_geom[edg_ix]->poles,
	       edge_geom[edg_ix]->weights, min[edg_ix], max[edg_ix]);
    EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
    min[edg_ix][0] -= sti_tol; max[edg_ix][0] += sti_tol;
    min[edg_ix][1] -= sti_tol; max[edg_ix][1] += sti_tol;
    min[edg_ix][2] -= sti_tol; max[edg_ix][2] += sti_tol;
   }
 }

 if (pair->option & EMSstitch_InvestigateMatch)
 {
  bsovlap[SELF][0] = bsovlap[OTHR][0] = 0.0;
  bsovlap[SELF][1] = bsovlap[OTHR][1] = 1.0;
  OM_stat = EMvalcv_ovlap(EMmsg, edge_geom[SELF], edge_geom[OTHR],
	    &bsovlap[SELF][0], &bsovlap[OTHR][0], sample_size, &num_hits, 
	    &num_misses, sti_tol, EMSvalovlap_WriteSamples | 
	    EMSvalovlap_DisplayMisses | EMSvalovlap_TextMisses, button, 
	    fileptr);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  goto wrapup;
 }

 if (!(pair->option & EMSstitch_IgnoreGap) &&
     !(pair->option & EMSstitch_NoRangeCheck) &&
     !(pair->option & EMSstitch_InternalValidation) &&
     !BSbxint(&rc, min[SELF], max[SELF], min[OTHR], max[OTHR]))
 	{*EMmsg = EMS_I_Fail;goto wrapup;}

 if (edge_geom[SELF]->phy_closed || edge_geom[OTHR]->phy_closed)
      one_closed = TRUE;
 else one_closed = FALSE;

 OM_stat = EMgetcv_ovlap(EMmsg, edge_geom[0], edge_geom[1], &num_ovlap,
		        &bsovlap[0][0], &bsovlap[1][0], sti_tol,
		        &ovlap_type[0][0], &ovlap_type[1][0], pair->option);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 if (pair->option & EMSstitch_InternalValidation)
 {
  if(!num_ovlap)
   {
    bsovlap[SELF][0] = bsovlap[OTHR][0] = 0.0;
    bsovlap[SELF][1] = bsovlap[OTHR][1] = 1.0;
    num_ovlap = 1;
   }
   for (ovl_ix=0; ovl_ix<num_ovlap; ovl_ix++)
   {
      OM_stat = EMvalcv_ovlap(EMmsg, edge_geom[SELF], edge_geom[OTHR],
			 &bsovlap[SELF][(ovl_ix == 0 ? 0 : 2)],
			 &bsovlap[OTHR][(ovl_ix == 0 ? 0 : 2)],
			 sample_size, &num_hits, &num_misses, 
			 sti_tol,
			 EMSvalovlap_WriteSamples | 
			 EMSvalovlap_DisplayMisses |
			 EMSvalovlap_TextMisses,
			 button, fileptr);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
   }
  goto wrapup;
 }
 else if (!num_ovlap) {*EMmsg = EMS_I_Fail; goto wrapup;}
 else if (*EMmsg == EMS_I_DegenerateEdge)
 {
   OM_stat = om$send (msg = message EMSedge.EMset_props (EMmsg,
					EMED_DEGENERATE, EMS_O_ON),
		targetid = (ovlap_type[SELF][0] == ovlap_type[SELF][1] ?
			    edge[OTHR] : edge[SELF]));
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);
   *EMmsg = EMS_I_Fail; goto wrapup;
 }

 
 for(edg_ix=0;edg_ix<2;edg_ix++)
 {
   valdiff[edg_ix] = bsovlap[edg_ix][1] - bsovlap[edg_ix][0];
   if (props[edg_ix] & EMED_REVERSED) valdiff[edg_ix] = -valdiff[edg_ix];

   partolbasis[edg_ix].mattyp = &mod_info->md_env.matrix_type;
   partolbasis[edg_ix].mat = mod_info->md_env.matrix;
   partolbasis[edg_ix].in_world = TRUE;
   partolbasis[edg_ix].is_valid = FALSE;
 
   OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,NULL,
						&partolbasis[edg_ix]),
			targetid = edge[edg_ix]);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
 }
 if ( (valdiff[SELF] < 0 && valdiff[OTHR] < 0) ||
      (valdiff[SELF] > 0 && valdiff[OTHR] > 0)) rev_connect = FALSE;
 else rev_connect = TRUE;

 for(ovl_ix=0;ovl_ix<num_ovlap;ovl_ix++)
 {
	for(edg_ix=0;edg_ix<2;edg_ix++)
	{
	  for(end_ix=ovl_ix*2;end_ix<ovl_ix*2+2;end_ix++)
	  {
		if (ovlap_type[edg_ix][end_ix] == EMS_O_middle)
		{
		 IGRshort	natloc;
		 OMuword	clid;
		 IGRboolean	ispe = FALSE;
		 IGRdouble	junk = 0.0;
		
		OM_stat = om$send(msg = message EMSedge.EMget_location
				(EMmsg, &natloc),
			   targetid = edge[edg_ix]);
	  	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);
	
	        /* If part natural edge we need to convert the overlap param
		 *  wrt full edge.
		*/
	        if( (natloc == EDGEU0) || (natloc == EDGEV1) || 
		    (natloc == EDGEU1) || (natloc == EDGEV0))
		 {
		  OM_stat = om$get_classid(objid = edge[edg_ix], 
					   p_classid = &clid);
	  	  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
		  if( (clid == OPP_EMSpartedge_class_id) || 
		      ( (OM_stat = om$is_ancestry_valid(subclassid = clid, 
				superclassid = OPP_EMSpartedge_class_id))
				== OM_S_SUCCESS)) ispe = TRUE;
		  if(ispe)
		   {
		    struct EMSedgebound		bnd[2], cnvt, tmp;
		
		    tmp.span_inx = 0;
		    tmp.param = bsovlap[edg_ix][end_ix];
		    OM_stat = om$send(msg = message EMSedge.EMgetbounds(EMmsg, 
					bnd), targetid = edge[edg_ix]);
	  	    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
	            EMcnvtedpar(EMmsg, &bnd[0], &bnd[1], &tmp, &cnvt);
      		    EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
		    junk = cnvt.param;		    
		   }
		
		 }
		
                if(natloc == EDGEU0)
	         {
		  uv_point[0] = 0.0;
		  uv_point[1] = ispe ? junk : bsovlap[edg_ix][end_ix];
	         }
	        else if(natloc == EDGEV1)
	         {
		  uv_point[0] = ispe ? junk : bsovlap[edg_ix][end_ix];
		  uv_point[1] = 1.0;
	         }
	        else if(natloc == EDGEU1)
	         {
		  uv_point[0] = 1.0;
		  uv_point[1] = 1.0 - (ispe ? junk : bsovlap[edg_ix][end_ix]);
	         }
	        else if(natloc == EDGEV0)
	         {
		  uv_point[0] = 1.0 - (ispe ? junk : bsovlap[edg_ix][end_ix]);
		  uv_point[1] = 0.0;
	         }
	        else
	         {
	  	  BScveval(edge_geom[edg_ix], bsovlap[edg_ix][end_ix],
					 0, (IGRpoint *)xyz_point, &rc);
          	  EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

	  	  OM_stat = om$send(msg = message EMSsubbs.EMpratmpt(EMmsg,
					&mod_info->md_env.matrix_type,
					mod_info->md_env.matrix, 1,
					xyz_point,
					uv_point,
					&dist,
					base_pt),
			   targetid = surf[edg_ix]);
	  	  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
		 }
		
 	  	OM_stat = om$send(msg = message EMSedge.EMptproject(EMmsg,
                                   	uv_point,
					1,
				   	&proj_info, 
					NULL, 
					&partolbasis[edg_ix]),
			   targetid = edge[edg_ix]);
	  	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);
	
		split_info.edgeid = remaining_edge[edg_ix];
		split_info.edgepar = proj_info.param;
		split_info.intloc = EMScvint_middle;
		OM_BLOCK_MOVE(proj_info.proj_pt, split_info.point, 
						2*sizeof(IGRdouble));
		OM_stat = om$send(msg = message EMSedge.EMsplityourself(EMmsg,
				split_info_ptr, NULL, NULL, result_edge,
					NULL, NULL, NULL,
					&partolbasis[edg_ix], mod_info, 
					NULL, NULL, NULL),
			   	  targetid = remaining_edge[edg_ix]);
		EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		if (result_edge[0] == NULL_OBJID)
			connecting_edge[edg_ix] = remaining_edge[edg_ix];
		else
		{
                if ((props[edg_ix] & EMED_NATURAL) && !made_non_nat[edg_ix])
		{
		  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
		  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_loop);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
		  
		  OM_stat = om$send(msg = message EMSloop.EMset_props(EMmsg,
						EMLP_NATURAL,
						EMS_O_OFF),
					p_chanselect = &to_loop,
					senderid = result_edge[0]);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  OM_stat = om$send(msg = message EMSloopset.EMset_props(EMmsg,
						EMLS_NATURAL,
						EMS_O_OFF),
					p_chanselect = &to_loopset,
					senderid = surf[edg_ix]);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
		  
		  made_non_nat[edg_ix] = TRUE;
		}
		if ((end_ix == ovl_ix*2   && valdiff[edg_ix] > 0) ||
                    (end_ix == ovl_ix*2+1 && valdiff[edg_ix] < 0))
		     connecting_edge[edg_ix] = result_edge[END];
		else connecting_edge[edg_ix] = result_edge[BGN];
		if (valdiff[edg_ix] > 0) 
		     remaining_edge[edg_ix] = result_edge[END];
		else remaining_edge[edg_ix] = result_edge[BGN];
		} /* successful split */
		} /* attempted split */
		else connecting_edge[edg_ix] = remaining_edge[edg_ix];
	  } /* endpt */
	}  /* edge */
	
	/* if (surf[SELF] == surf[OTHR]) common_props |= EMED_SEAM;*/
	
	/* Determination of seamness was modified to make it safer. Seam
	   peoperty will now be set only if edge is natural AND surface
	   is closed in that direction.
	
	   SM 11-Sep-89.
	*/
	if (surf[SELF] == surf[OTHR])
	 {
	  IGRshort	natloc;
	  IGRboolean	isseam = FALSE;
	
  	  OM_stat = om$send(msg = message EMSedge.EMget_location
				(EMmsg, &natloc),
			   targetid = connecting_edge[SELF]);
	  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_EdgeError,wrapup);

	  if(  ((natloc == EDGEU0) || (natloc == EDGEU1)) &&
	       surf_geom[SELF]->u_phy_closed) isseam = TRUE;
	  else if(  ((natloc == EDGEV0) || (natloc == EDGEV1)) &&
	       surf_geom[SELF]->v_phy_closed) isseam = TRUE;

	  if(isseam) common_props |= EMED_SEAM;
	  else common_props &= ~EMED_SEAM;
	
	 }
	else common_props &= ~EMED_SEAM;
	
	if (rev_connect && !one_closed) common_props |= EMED_REVERSE_CONNECT;

	OM_stat = om$send(msg = message EMSedge.EMconnect_edges(EMmsg,
				common_props,
				(one_closed ? TRUE : FALSE),
				connecting_edge[OTHR],
				surf[SELF],
				surf[OTHR],
				&mod_info->md_env),
			  targetid = connecting_edge[SELF]);
	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

	OM_stat = om$send(msg = message EMSedge.EMset_props(EMmsg,
						EMED_COMPATIBLE,
						EMS_O_OFF),
				targetid = connecting_edge[SELF]);
	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
	OM_stat = om$send(msg = message EMSedge.EMset_props(EMmsg,
						EMED_COMPATIBLE,
						EMS_O_OFF),
				targetid = connecting_edge[OTHR]);
	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 } 	/* ovlap interval */

 if (one_closed)
 {
	  OM_stat = om$send(msg =  message EMSedge.EMget_props(EMmsg,
						&common_props),
			   targetid = connecting_edge[SELF]);
          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

	  if (common_props & EMED_REVERSE_CONNECT) rev_connect = TRUE;
	  else rev_connect = FALSE;
 }

 OM_stat = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, &def_0),
				targetid = surf[0]);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 OM_stat = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, &def_1),
				targetid = surf[1]);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 props_0 = def_0.pos_orient ? 0x1 : 0x0;
 props_1 = def_1.pos_orient ? 0x1 : 0x0;

 if (rev_connect)
 {
   if (props_0 ^ props_1)
   	toggle_norm = TRUE;
   else toggle_norm = FALSE;
 }
 else
 {
   if (props_0 ^ props_1)
   	toggle_norm = FALSE;
   else toggle_norm = TRUE;
 }

 one_rev_oriented = FALSE;
 for (edg_ix=0;edg_ix<2;edg_ix++)
 {
  IGRboolean ignore_orient = FALSE;

  if(pair->option & EMSstitch_IgnoreOrientError) ignore_orient = TRUE;

    OM_stat = om$send(msg = message EMSsubbs.EMgetactiveid(EMmsg,
                                              &active_id[edg_ix],NULL),
                      targetid = surf[edg_ix]);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    if (!prim_obj || (active_id[edg_ix].objid != prim_obj->objid) 
        || ignore_orient)
    {
       if (toggle_norm && !one_rev_oriented && 
	   !(pair->option & EMSstitch_NoOrientSurfs))
       {
           OM_stat = om$send(msg = message EMSsurface.EMrevorient(EMmsg),
                     targetid = ignore_orient ? surf[edg_ix] 
                                              : active_id[edg_ix].objid);
           EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
           one_rev_oriented = TRUE;
       }
       if (!(pair->option & EMSstitch_NoMoveSurfs) && prim_obj)
       {
         OM_stat = om$send(msg = message EMSsurface.EMmovesurfs(EMmsg,
                                                prim_obj, mod_info),
                                  targetid = active_id[edg_ix].objid);
         EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
       }
    }
 }

 if (!pair->surf_geom0 && surf_geom[SELF]) om$dealloc(ptr = surf_geom[SELF]);
 if (!pair->surf_geom1 && surf_geom[OTHR]) om$dealloc(ptr = surf_geom[OTHR]);

 for(i=0; i<2; i++)
  {
   if(edge_buff[i].poles) om$dealloc(ptr = edge_buff[i].poles);
   if(edge_buff[i].knots) om$dealloc(ptr = edge_buff[i].knots);
   if(edge_buff[i].weights) om$dealloc(ptr = edge_buff[i].weights);
  }

 wrapup:

  /* If stitching succeeded but required inconsistent orientation to be set
     on the surfaces, return appropriate error.
  */
  if((1&*EMmsg&OM_stat) && (*EMmsg != EMS_I_Fail) && toggle_norm && 
     !one_rev_oriented && (!(pair->option & EMSstitch_NoOrientSurfs)) &&
     (!(pair->option & EMSstitch_IgnoreOrientError)))
   *EMmsg = EMS_E_IntersectOrient;

  if(pedges0) om$dealloc(ptr = pedges0);
  if(pedges1) om$dealloc(ptr = pedges1);

  EMWRAPUP(*EMmsg, OM_stat, "In EMSedge.EMstitch")
  return(OM_stat);
}

end implementation EMSedge;


