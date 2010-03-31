/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

/*
   History

         Sudha 06/04/93          modified to include BSprototype header files
*/

#include "bserr.h"
#include "bsparameters.h"
#include "emsoffptdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "bssfeval.h"

%safe
static void EMsnap();
%endsafe

#ifndef DEBUG
#define DEBUG 0
#endif

#define U 0
#define V 1

#if DEBUG
#define BUF_INC 2
#else
#define BUF_INC	20
#endif

extern GRclassid OPP_EMSsubbs_class_id;

from GRvg import GRgenabsg;
from EMSsubbs import EMpratmpt;
from EMSloopset import EMpt_location;

method EMoffpoint (IGRlong *EMmsg; struct EMSedgebound *edpar; 
                   IGRdouble *edpt, *tangent, offdist;
		   GRobjid *sfobjid;
		   struct IGRbsp_surface *sfgeom;
		   struct GRmdenv_info *env;
                   struct EMSpartolbasis *partolb;
		   IGRint *numedges_visited, *edbufsize;
		   GRobjid **edges_visited;
		   IGRushort options;
		   IGRdouble *off_edptuv, *off_edptxyz;
		   GRobjid *off_edptsf)
{
  IGRboolean 			onbdry;
  IGRlong			sts, rc;
  OMuint                        count = 0;
  IGRdouble			*uvpt, uvpt_mem[2], *uvtan = NULL, uvnor[2], 
				offpt_loc[2], *commuvtan = NULL;
  struct EMSproj_info 		proj_info;
  struct IGRbsp_surface 	*srf = NULL, *commsrf = NULL;
  extern IGRboolean 		EMwithin_sf_bounds();
  IGRint			locnumedges_visited = 0, 
				loc_edbufsize = 0, uvptsize;
  GRobjid			*locedges_visited = NULL, 
				*travel_edge1, sfid, commsfid, *travel_edge2, 
				*travel_edge;
  extern IGRint			EMgetvggeom();
  IGRboolean			ptfound = FALSE, outofuv = FALSE, 
				onright = FALSE, coolscene = TRUE, 
				ptloc_tried = FALSE, 
				travelfound = FALSE;
				
  struct EMSptloc_info		ptloc;
  OM_S_CHANSELECT		to_ls, to_common;
  IGRshort			*loc;
  extern IGRlong		EFsspbtol_by_geom();
  OM_S_OBJECT_LINKAGE		comm;
  IGRint			i, j;
  IGRdouble			*travel_pt, junkxyz[3], *comm_edpt, 
				junkuv[2], junkdist, junkbase[3], offdist_uv, 
				commoffdist_uv, commpartol, mypartol, xyztol;
  struct EMSpartolbasis		commpartolb;
  /*static void			EMsnap();*/
  IGRushort		edprops = NULL;
  IGRint			temp = 0;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  sfid = NULL_OBJID;
  ptloc.location = EMS_L_UNKNWN;
  loc = &ptloc.location;
  travel_edge1 = &ptloc.edge[0].edge_id;
  travel_edge2 = &ptloc.edge[1].edge_id;
  travel_pt = ptloc.edge[0].nst_pt.proj_pt;
  *travel_edge1 = NULL_OBJID;
  *travel_edge2 = NULL_OBJID;
  EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
  if(!numedges_visited) numedges_visited = &locnumedges_visited;
  if(!edbufsize) edbufsize = &loc_edbufsize;
  if(!edges_visited) edges_visited = &locedges_visited;

  uvptsize = 2 * sizeof(IGRdouble);
  if(sfobjid) sfid = *sfobjid;

  if( (!(options & EMSoffpt_NoTravel) && IF_NULL_OBJID(sfid)) ||
      (!sfgeom && IF_NULL_OBJID(sfid)))
   {
    sts = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
             &sfid, NULL), targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

  /* Obtain surface geometry.
  */
  if(sfgeom)
   srf = sfgeom;
  else if(!IF_NULL_OBJID(sfid))
   {
    struct GRid junkGRid;

    enum EMSdatatype dattyp = EMSdata_null;

    junkGRid.objid = sfid;
    junkGRid.osnum = OM_Gw_current_OS;
    sts = EMgetvggeom(EMmsg, &env->matrix_type, env->matrix, &junkGRid, &srf, 
		      &dattyp);
    EMerr_hndlr(!(1&*EMmsg&sts) || (dattyp != EMSdata_surface), *EMmsg, 
     		EMS_E_Fail, wrapup);
   }
  else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
	
  EMerr_hndlr(!srf, *EMmsg, EMS_E_Fail, wrapup);

  if(!partolb->is_valid)
   {
    sts = EFsspbtol_by_geom(EMmsg, srf, &partolb->tol);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

  /*
   * Obtain the point on the edge at which the offset needs to be
   * computed, if it has not already been passed in.
   */

  if (!edpt)
    {
    sts = om$send (msg = message EMSedge.EMptatpr (EMmsg, 1, edpar, 
               NULL, uvpt_mem), targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
    uvpt = uvpt_mem;
    }
  else
    uvpt = edpt;

  
  /*
   * Obtain the unit "natural" tangent to this edge at this point.
   */
  if(!tangent)
   {
    proj_info.location = EMScvint_unknown;
    sts = om$send (msg = message EMSedge.EMptproject (EMmsg, uvpt,
             1, &proj_info, NULL, partolb), targetid = my_id);
    EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

    /* If the location returned in the projection info is EMScvint_collapsed, 
       it signals degenerate edge geometry and thus consequently having no
       fixed tangent. If the caller has not supplied a tangent, this edge
       is basically useless.
    */
    EMerr_hndlr( (proj_info.location == EMScvint_collapsed) ||
		 (proj_info.location == EMScvint_unknown), *EMmsg, 
		 EMS_I_Degenerate, wrapup);
    uvtan = proj_info.tangent;
   }
  else uvtan = tangent;

  /*
   * Obtain the inward pointing normal by crossing the tangent with the
   * vector [0,0,1].
   */

  uvnor[U] = uvtan[V];
  uvnor[V] = -uvtan[U];
  BSEXTRACTPAR(&rc, BSTOLLENVEC, xyztol);
  sts = EFextract_par(BSTOLLENVEC, partolb->tol, &mypartol, &rc);

  if(options & EMSoffpt_OffDistUv)
   offdist_uv = offdist;
  else
   offdist_uv = offdist * mypartol/xyztol;

  /* Find a point on the appropriate side of the edge at a given distance
  */
  if( (options & EMSoffpt_Right) || (options & EMSoffpt_Scalar))
   {
    offpt_loc[U] = uvpt[U] + offdist_uv * uvnor[U];
    offpt_loc[V] = uvpt[V] + offdist_uv * uvnor[V];
    onright = TRUE;
    EMsnap(srf, partolb->tol, offpt_loc);
   }
  else
   {
    offpt_loc[U] = uvpt[U] - offdist_uv * uvnor[U];
    offpt_loc[V] = uvpt[V] - offdist_uv * uvnor[V];
    onright = FALSE;
    EMsnap(srf, partolb->tol, offpt_loc);
   }

  /* If the point is outside uv space it is not acceptable.
  */

  if (!EMwithin_sf_bounds (offpt_loc, srf, &onbdry))
   {
    if(options & EMSoffpt_Scalar)
     {
      /* Try the other side
      */
      offpt_loc[U] = uvpt[U] - offdist_uv * uvnor[U];
      offpt_loc[V] = uvpt[V] - offdist_uv * uvnor[V];
      onright = FALSE;
      EMsnap(srf, partolb->tol, offpt_loc);
      if(!EMwithin_sf_bounds (offpt_loc, srf, &onbdry)) outofuv = TRUE;
     }
    else outofuv = TRUE;
   }

  /* If the caller does not wish a point in the hole do a check.
  */
  if((options & EMSoffpt_NoHole) && !outofuv && !IF_NULL_OBJID(sfid))
   {
    ptloc.options = EMS_PTLOC_LS_INFINITE | EMS_PTLOC_CLOSEST_EDGE;

    /* If the point under consideration lies in hole and the caller does
       not care about right or left, and the right side point has not been
       already ruled out, try it.
    */
    for(i=0; i<2; i++)		/* right and left if possible */
     {
      ptloc_tried = TRUE;
      sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg, offpt_loc, 
			&ptloc, partolb), senderid = sfid, 
			p_chanselect = &to_ls);
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

      if(*loc == EMS_L_INAREA) {ptfound = TRUE; break;}
      else if( ((*loc == EMS_L_ONEDGE) || (*loc == EMS_L_ONVRTX)) &&
	       (options & EMSoffpt_NoBdry)) {ptfound = TRUE; break;}
      else if( (options & EMSoffpt_Scalar) && onright)
       {
        offpt_loc[U] = uvpt[U] - offdist_uv * uvnor[U];
        offpt_loc[V] = uvpt[V] - offdist_uv * uvnor[V];
        onright = FALSE;
        EMsnap(srf, partolb->tol, offpt_loc);
        if(!EMwithin_sf_bounds (offpt_loc, srf, &onbdry)) 
         {outofuv = TRUE; break;}
       }
      else break;

     } /* for(i=0; i<2; i++) */

   } /* if((options & EMSoffpt_NoHole) && !outofuv) */

  else if(!outofuv) ptfound = TRUE;

  if(ptfound) goto wrapup;
  
  /* At this juncture the point has not been found due to one of the
     following  reasons-

  .. The caller specified a direction and the point went outside uv space 
     along that direction.
  .. The caller did not specify a direction but the point went outside uv
     space along both directions.
  .. The caller does not want a point in hole and the point was in hole
     along the direction specified.
  .. The caller does not want a point in hole and did not specify a direction
     but the point was in hole along both directions.

     If the caller wishes to travel over common edges and try to find the
     point on the adjoining surface, do so. Else there is nothing we can
     do about the situation so return.
  */
  EMerr_hndlr(options & EMSoffpt_NoTravel, *EMmsg, EMS_I_NoCommonEdge, wrapup);

  
  /* We now need to use the nearest edge to the off point and travel
     across its common edge to the adjoining surface to get the point. 
     If the nearest point in the loopset happens to be a vertex then we have
     an option to choose between 2 edges meeting at that vertex, as potential
     candidates for the travel. We ignore the travel edge if -
     a) It has no common edge.
     b) Its common edge has already been visited during the persuit of
	the point.
     If a point location test has not already been done, do it now. This
     test is going to give us the nearest edge to the offset point.

     When the need to go across common edge onto the adjacent surface arises
     the ideal stepping distance on that surface should be computed
     taking into account the distance already covered on this surface.
     But for now the step distance is being used on the other surface.
     This will result in the point being farther away from the edge in model
     space than desired.
  */

  if(IF_NULL_OBJID(*travel_edge1) && IF_NULL_OBJID(*travel_edge2) && 
     !ptloc_tried && !IF_NULL_OBJID(sfid))
   {
    ptloc.options = EMS_PTLOC_LS_INFINITE | EMS_PTLOC_CLOSEST_EDGE;
    sts = om$send(msg = message EMSloopset.EMpt_location(EMmsg, offpt_loc, 
			&ptloc, partolb), senderid = sfid, 
			p_chanselect = &to_ls);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
   }

  /* If no edge exists for travel, return.
  */
  EMerr_hndlr(IF_NULL_OBJID(*travel_edge1) && IF_NULL_OBJID(*travel_edge2), 
	      *EMmsg, EMS_I_NoCommonEdge, wrapup);

  EMmake_chanselect(EMSedge_to_common_edge, &to_common);

  /* Select travel edge out of the possible two candidates.
  */
  for(i=0; i<2 && !travelfound; i++)
   {
    travelfound = FALSE;
    travel_edge = i ? travel_edge2 : travel_edge1;
    if(IF_NULL_OBJID(*travel_edge)) continue;
    sts = om$get_channel_objects(objid = *travel_edge, 
				 p_chanselect = &to_common,
				list = &comm, size = 1, count = &count);
    if(!(1&sts) || !count) continue;

    /* Has the common edge already been visited ?
    */
    travelfound = TRUE;
    for(j=0; j<*numedges_visited; j++)
     if(IF_EQ_OBJID(comm.S_objid, (*edges_visited)[j]))
      {
       travelfound = FALSE;
       break;
      }
   }

  /* If no adjacent surface is available, exit.
  */
  EMerr_hndlr(!travelfound, *EMmsg, EMS_I_NoCommonEdge, wrapup);

  /* Update the record of all the edges that have been visited.
     Here we add the following edges to the list -
     a) The intersection edge.
     b) The travel edge 
  */

  if(*edbufsize < 2)
   {
    if(*edges_visited)
   *edges_visited = (GRobjid *)om$realloc(ptr = (IGRchar *)*edges_visited, size
    = sizeof(GRobjid)*(*numedges_visited + BUF_INC));
   else *edges_visited = (GRobjid *)om$malloc(size = sizeof(GRobjid) * BUF_INC);
    *edbufsize = BUF_INC;
   }
  (*edges_visited)[(*numedges_visited)++] = *travel_edge;
  (*edges_visited)[(*numedges_visited)++] = my_id;
  (*edbufsize) -= 2;
  commpartolb = *partolb;
  commpartolb.is_valid = FALSE;
  commsfid = NULL_OBJID;

  /* If the travel edge is a seam edge we can optimise as follows -

     a) The parametric tolerance, surface id and surface geom of the common
	edge is already known.
     b) Assuming that the seam edges are always natural edges (part or full)
        the uv point on the common edge to be used as the stepping point
	can be trivially calculated.
     c) The offset distance remains same for the common edge.
  */
  sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
			targetid = *travel_edge);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  comm_edpt = proj_info.proj_pt;

  if(edprops & EMED_SEAM)
   {
    IGRshort natloc;

    commsfid = sfid;
    commpartolb = *partolb;
    commsrf = srf;
    
    OM_BLOCK_MOVE(edpt, comm_edpt, uvptsize);
    sts = om$send(msg = message EMSedge.EMget_location(EMmsg, &natloc), 
			targetid = *travel_edge);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
    if(natloc == 0) comm_edpt[0] = 1.0;
    else if(natloc == 1) comm_edpt[1] = 0.0;
    else if(natloc == 2) comm_edpt[0] = 0.0;
    else if(natloc == 3) comm_edpt[1] = 1.0;
    commoffdist_uv = offdist_uv;
   }
  else
   {
    sts = om$send(msg = message EMSboundary.EMgetsurface_info
		(EMmsg, &commsfid, &commpartolb), 
		targetid = comm.S_objid);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
    EMerr_hndlr(IF_NULL_OBJID(commsfid), *EMmsg, EMS_I_NoCommonEdge, wrapup);

    /* We need to get the uv point on the common edge which is to be
       visited.
    */
    BSsfeval(srf, travel_pt[0], travel_pt[1], temp, (IGRpoint *)junkxyz, &rc);
    EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

    sts = om$send(msg = message EMSsubbs.EMpratmpt(EMmsg, &env->matrix_type,
                    env->matrix, 1, junkxyz, junkuv, &junkdist, junkbase),
                    targetid = commsfid);
    EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_SurfaceError, wrapup);

    sts = om$send (msg = message EMSedge.EMptproject (EMmsg, junkuv,
              1, &proj_info, NULL, &commpartolb), targetid = comm.S_objid);
    EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

    /* If the location returned in the projection info is EMScvint_collapsed, 
       it signals degenerate edge geometry and thus consequently having no
       fixed tangent. Ignore such edges.
    */
    EMerr_hndlr( (proj_info.location == EMScvint_collapsed) ||
		 (proj_info.location == EMScvint_unknown), *EMmsg, 
		 EMS_I_Degenerate, wrapup);
    commuvtan = proj_info.tangent;

    /* Map the offset distance provided in this uv space into the uv space
       of the common edge.
    */
    sts = EFextract_par(BSTOLLENVEC, commpartolb.tol, &commpartol, &rc);
    if(mypartol == commpartol) commoffdist_uv = offdist_uv;
    else commoffdist_uv = offdist_uv * commpartol/mypartol;
   }

  /* When we cross over the common edge onto the other surface, we need to
     always step towards the right side of the common edge because the common
     edge is oriented with the area region to its right.
  */
  sts = om$send(msg = message EMSedge.EMoffpoint(EMmsg, 
		NULL, comm_edpt, commuvtan, commoffdist_uv, 
		&commsfid, commsrf, env, &commpartolb, numedges_visited, 
		edbufsize, edges_visited, 
		options | EMSoffpt_OffDistUv | EMSoffpt_Right, 
		off_edptuv, off_edptxyz, off_edptsf), targetid = comm.S_objid);
wrapup:

  if((1&*EMmsg&sts) && ptfound)
   {
    IGRlong rc;

    if(off_edptuv) OM_BLOCK_MOVE(offpt_loc, off_edptuv, uvptsize);
    if(off_edptxyz)
     {
      BSsfeval(srf, offpt_loc[0], offpt_loc[1], temp, (IGRpoint *)off_edptxyz, &rc);
      if(rc!=BSSUCC) {*EMmsg = EMS_E_Fail; coolscene = FALSE;}
     }

    if(off_edptsf && coolscene) *off_edptsf = sfid;
    *EMmsg = EMS_S_Success;

   } /* if((1&*EMmsg&sts) && ptfound) */

  else if( (1&*EMmsg&sts) && (*EMmsg != EMS_S_Success) && 
	   (*EMmsg != EMS_I_Degenerate))
   *EMmsg = EMS_I_NotFound;

  if(srf && (srf != sfgeom)) om$dealloc(ptr = srf);
  if(locedges_visited) om$dealloc(ptr = locedges_visited);
  EMWRAPUP (*EMmsg, sts, "EMSedge.EMoffpoint");
  return (sts);
}

%safe
#include <math.h>
%endsafe

static void EMsnap(srf, tol, pt)
struct IGRbsp_surface *srf;
IGRdouble tol, *pt;
{
  IGRdouble u_lb, v_lb, u_ub, v_ub;
  IGRint    i;

  u_lb = srf->u_knots[srf->u_order-1];
  v_lb = srf->v_knots[srf->v_order-1];
  u_ub = srf->u_knots[srf->u_num_poles];
  v_ub = srf->v_knots[srf->v_num_poles];
  
 for(i=0; i< 2; i++)
 {
  if(fabs(pt[i] - u_lb) <= tol) pt[i] = u_lb;
  else if(fabs(pt[i] - v_lb) <= tol) pt[i] = v_lb;
  else if(fabs(pt[i] - u_ub) <= tol) pt[i] = u_ub;
  else if(fabs(pt[i] - v_ub) <= tol) pt[i] = v_ub;
 }

}
end implementation EMSedge;

