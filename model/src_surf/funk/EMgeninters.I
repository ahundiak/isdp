/*
 DESCRIPTION
  This function takes in a curve(simple or composite) and surface(can be
  composite) and maps the curve onto the surface to give the mapped data
  in the form of inters list.
 Algorithm
  1) Find all the surfaces through which the given curve is spanning
     through.
  2) For each surface
      {
      o Map all the component of the curve onto this surface.
      o Convert the mapped data into dataselect format. The output
        is in the form of loops (uv data) and curves (xyz data)
      o Call EMmkintlist for each element of the loop i.e edge(s)
        to create the inters list
      }
     return(inters_list_header);

 NOTE: This functionality assumes that the input curve is lying on the
       surface however it may go beyond its bounds and its end may be
       in the overhang state.
 HISTORY

   Rustagi : ???? : 	Creation 
   Sudha   :07/06/93    Modified for BSprototypes ansification
   NP      :07/30/93    Changed "EMmkintlist" to its NEW name "EMmakeintlist"
                        and made the two new parameters NULL.
*/

class implementation Root;

#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "emsmapdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#define NUM_SAMPLE_PTS 3

%safe
#include <math.h>
%endsafe

#include "bssfeval.h"
#include "bsdistptpt.h"

/* imports */

from GRvg  import GRgetsize, GRgetgeom, GRgetsymb, EMptatpr;
from GRgraphics import GRptproject;
from EMSsubbs import EMpartolbasis, EMget_edges;
from GRowner import GRget_number_components, GRget_components;
from EMSedge import EMinternalpt, EMget_bcxyz_geom, EMptatpr;
 
/* externs */

extern void EMgetincinfo();
extern IGRint EMget_mapped_data();
extern struct EMSsfintedpar *EMsfintedpar_malloc();
extern struct EMSintobj *EMmakeintlist();
extern struct GRid *EMoutput_spanned_surfaces();
extern void EMmergeinters();
/* static */

%safe
static IGRlong EMget_tangential_feature_surfaces();
static IGRlong EMget_edge_tomap();
static IGRlong EMset_the_orientation();
%endsafe


IGRlong  EMgen_inters_node(msg,
                          ingeom,
                          curve,
                          modenv_cv,
                          const_args,
                          options,
                          spannedsf,
                          spancount,
                          modenv_sf,
                          inters)
IGRlong *msg;
struct IGRbsp_curve *ingeom;
struct GRid *curve;
struct GRmd_env *modenv_cv;
struct GRvg_construct *const_args;
IGRushort options;
struct GRid *spannedsf;
IGRint spancount;
struct GRmd_env *modenv_sf;
struct EMSinters **inters;
/*
 msg           : message code returned.
 ingeom        : curve buffer. It should be NULL if the curve id is passed in.  
 curve         : SHOULD be NULL if the geometry is passed in.
               : NOTE:-> I preassume that both these arguments are mutually
                         exclusive as it does make some difference if the
                         output exactly in the form of sf-sf intersection
                         is required. The difference my crept in incase of
                         composite curva. If  its geometry is passed, you
                         may get single intersection curve after mapping but
                         if instead id is passed in, it may result in as
                         many intersections as there are components in the
                         composite curve.
 modenv_cv,modenv_sf: Module environment.
 const_args : Construct list.
 options  : Not in use currently.
 spannedsf : id's of the surfaces through which this curve is spanning.
 spancount : count for these surfaces.
 inters : EMSinters list.
*/
{
 IGRlong sts, msg_loc, num_bytes;
 IGRboolean  world;
 struct EMSintobj *intobj=NULL;
 OM_S_CHANSELECT sf_to_ls, compcv_to_cv_chan, to_comps_chan;
 OM_S_OBJECT_LINKAGE ls_list, *ed_list=NULL;
 struct GRlc_info *cv_obj_info=NULL;
 OMuint count, ed_count, num_edges;
 IGRint i, j, k, num_curves;
 struct GRid clip_ls, *cv_grids=NULL, xyz_cv_grid, edge_grid;
 GRobjid *cv_ids=NULL;
 IGRdouble xyztol;
 struct EMSpartolbasis sfpartol;
 struct IGRbsp_surface **sfgeom;
 struct IGRbsp_curve *loc_cvgeom=NULL;
 GRspacenum thisos;
 struct EMSdataselect edge_dataselect, xyz_cv_dataselect;
 struct EMSgetlp_output out_loops, out_cvs;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 world = TRUE;
 num_bytes = 0;
 sfgeom = NULL;
 /*
  * Twice XYZ chord height tol is used for calculating end-info of
  * edges on surface.
  */
 BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
 xyztol *= 2.0;
 if(ingeom && curve)
 {
 *msg = EMS_E_InvalidArg;
 sts = EMS_S_Fail;
 goto ret_end;
 }
 sts = EMmake_chanselect(EMSsubbs_to_loopset, &sf_to_ls);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);

 sts = EMmake_chanselect(EMSbd_owner_to_comps, &to_comps_chan);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);

 sts = EMmake_chanselect (GRcmpowner_to_components, &compcv_to_cv_chan);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);
/*
 * Allocating memory for the component curves. 
 */
 ed_list =(OM_S_OBJECT_LINKAGE *)om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE));
 EMerr_hndlr(!ed_list, *msg, EMS_E_NoDynamicMemory, ret_end);

 cv_grids = (struct GRid *) om$malloc (size = sizeof(struct GRid *)); 
 EMerr_hndlr(!cv_grids, *msg, EMS_E_NoDynamicMemory, ret_end);

 cv_ids = (GRobjid *) om$malloc (size = sizeof(GRobjid));
 EMerr_hndlr(!cv_ids, *msg, EMS_E_NoDynamicMemory, ret_end);

 if(curve)
 {
 cv_obj_info = (struct GRlc_info *) om$malloc (size = sizeof(struct GRlc_info));
 EMerr_hndlr(!cv_obj_info, *msg, EMS_E_NoDynamicMemory, ret_end);
 cv_obj_info[0].located_obj.objid = curve->objid;
 cv_obj_info[0].located_obj.osnum = curve->osnum;
 OM_BLOCK_MOVE(modenv_cv,&(cv_obj_info[0].module_info),sizeof(struct GRmd_env)); }
 else
 loc_cvgeom = (struct IGRbsp_curve *)ingeom;

 if(spancount)
 {
 sfgeom = (struct IGRbsp_surface **) om$malloc (size =  spancount * 
                                        sizeof(struct IGRbsp_surface *));
 EMerr_hndlr(!(sfgeom), *msg, EMS_E_NoDynamicMemory, ret_end);
 for(i=0; i<spancount; i++)
  {
  sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                &(modenv_sf->md_env.matrix_type),
                                modenv_sf->md_env.matrix, &num_bytes),
                   senderid = NULL_OBJID,
                   targetid = spannedsf[i].objid,
                   targetos = spannedsf[i].osnum);
  EMSmsgReport(sts, "EMgen_inter:GRvg.GRgetsize", FALSE);
  sfgeom[i] = NULL;
  sfgeom[i] = (struct IGRbsp_surface *) om$malloc (size = num_bytes);
  EMerr_hndlr(!sfgeom[i], *msg, EMS_E_NoDynamicMemory, ret_end);
  sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                               &(modenv_sf->md_env.matrix_type),
                               modenv_sf->md_env.matrix, (IGRchar *)sfgeom[i]),
                   senderid = NULL_OBJID,
                   targetid = spannedsf[i].objid,
                   targetos = spannedsf[i].osnum);
  EMSmsgReport(sts, "EMgen_inter:GRvg.GRgetgeom", FALSE);
  sfpartol.is_valid = FALSE;
  sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                         &(modenv_sf->md_env.matrix_type),
                         modenv_sf->md_env.matrix, &world, FALSE,
                         &(sfpartol.tol)),
               senderid = NULL_OBJID,
               targetid = spannedsf[i].objid,
               targetos = spannedsf[i].osnum);
  EMerr_hndlr(!(msg_loc&sts&1), *msg, msg_loc, ret_end);
  sfpartol.is_valid = TRUE;
 /*
  * Get the id of the loopset on surface so that the curves can be
  * clipped against it while mapping.
  */
  sts = om$get_channel_objects(objid = spannedsf[i].objid,
                               osnum = spannedsf[i].osnum,
                               p_chanselect = &sf_to_ls,
                               list = &ls_list,
                               size = 1,
                               count = &count);
  EMerr_hndlr(!(1&sts) || !count, *msg, EMS_E_OMerror, ret_end);
  clip_ls.objid = ls_list.S_objid;
  clip_ls.osnum = spannedsf[i].osnum;
  thisos = clip_ls.osnum;
 /*
  * Create edges by mapping the curves onto the surface. The option
  * "EMMapBnd_WantBadCurves" is needed because during mapping to special
  * places a scaling is done for the poles and this allow the poles to fall
  * outside the surface bounds.
  */
  out_loops.objs = NULL;
  out_cvs.objs = NULL;
  sts = EMget_mapped_data(
            1, /* no. of curves to be mapped */
            ingeom ? &loc_cvgeom : NULL,
            cv_obj_info,
            const_args,
            sfgeom[i],
            &(sfpartol.tol),
            modenv_sf,
            NULL,
            NULL,
            &out_loops, /* output : loops on the surface */
            &out_cvs, /* output : XYZ mapped curves */
            clip_ls,
            EMMapBnd_StrokeIfNeeded | EMMapBnd_RmvDegenCvs |
            EMMapBnd_WantBadCurves |EMMapBnd_NoValidate,
            NULL,
            &msg_loc);
  EMerr_hndlr(!(1&sts&msg_loc), *msg, msg_loc, ret_end);
 /*
  * At this time we have loops created on this surface. Each loop may have
  * any number of edges. We convert all edges into dataselects.
  */  
  for(j=0; j<(out_loops.num_objs); j++)
   { /* get all edges of the loop */
   sts = om$get_channel_count(objid = out_loops.objs[j],
                              osnum = thisos,
                              p_chanselect = &to_comps_chan,
                              count = &ed_count); 
   EMerr_hndlr(!(1&sts) || !ed_count, *msg, EMS_E_OMerror, ret_end);
   sts = om$get_channel_objects (objid = out_loops.objs[j],
                              osnum = thisos,
                              p_chanselect = &to_comps_chan,
                              list = ed_list,
                              size = ed_count,
                              count = &num_edges);
   EMerr_hndlr(!(1&sts) || !num_edges || (num_edges != ed_count), *msg,
                                         EMS_E_OMerror, ret_end);
 /* Get XYZ curve objects corresponding to the edges. Struct "out_cvs" is
  * very similar to the "out_loops" structs. i.e. every loop in "out_loops"
  * corresponds to a composite curve in "out_cvs". However, for loops with
  * only ONE edge, corresponding element is a curve and not a composite
  * curve. Example (L=loop, E=edge, CC=comp cv, C=curve) : Consider the
  * output of the following three loops:
  * L1 (E1 E2 E3) L2 (E4 E5) & L3 (E6).
  *      Corrresponding "out_cvs" entries are,
  * CC1 (C1 C2 C3) CC2 (C4 C5) & C6
  */
   if(num_edges > 1)
   {
    sts = om$send(msg = message GRowner.GRget_number_components(&msg_loc,
                                           &num_curves),
                            senderid = NULL_OBJID,
                            targetid = out_cvs.objs[j],
                            targetos = thisos);
    EMerr_hndlr (!(1&sts), *msg,EMS_E_OMerror, ret_end);
    EMerr_hndlr (num_curves!=num_edges, *msg, EMS_E_Fail, ret_end);
    sts = om$send(msg = message GRowner.GRget_components(&msg_loc, 
                                 modenv_cv, cv_grids, num_edges, 
                                 &num_curves, 0, num_edges-1),
                          targetid = out_cvs.objs[j],
                          targetos = thisos,
                          senderid = NULL_OBJID);
    EMerr_hndlr (!(1&sts), *msg,EMS_E_OMerror, ret_end);
    EMerr_hndlr (num_curves!=num_edges, *msg, EMS_E_Fail, ret_end);

    for(k=0; k<num_curves; k++)
      cv_ids[k] = cv_grids[k].objid;
   }
   else
      cv_ids[0] = out_cvs.objs[j];

   for(k=0; k<num_edges; k++)
    {
     edge_grid.objid = ed_list[k].S_objid;
     edge_grid.osnum = thisos;

     edge_dataselect.datatype = EMSdata_object;
     edge_dataselect.data.object = NULL;
     edge_dataselect.data.object = ( struct GRid *) om$malloc
                                    (size = sizeof (struct GRid));
     EMerr_hndlr (!(edge_dataselect.data.object), *msg,
                                               EMS_E_NoDynamicMemory, ret_end);
     edge_dataselect.data.object->objid     = edge_grid.objid;
     edge_dataselect.data.object->osnum     = edge_grid.osnum;
 
     xyz_cv_grid.objid              = cv_ids[k];
     xyz_cv_grid.osnum              = thisos;

     xyz_cv_dataselect.datatype     = EMSdata_object;
     xyz_cv_dataselect.data.object  = NULL;
     xyz_cv_dataselect.data.object  =
                    (struct GRid *) om$malloc (size = sizeof (struct GRid));
     EMerr_hndlr (!(xyz_cv_dataselect.data.object), *msg,
                                             EMS_E_NoDynamicMemory, ret_end);

     xyz_cv_dataselect.data.object->objid = xyz_cv_grid.objid;
     xyz_cv_dataselect.data.object->osnum = xyz_cv_grid.osnum;
    /*
     * Call EMmkintlist() to create an intobj node for this edge.
     */
     intobj = NULL;
     intobj = EMmakeintlist(&msg_loc,
                          inters, NULL,
                          &spannedsf[i], NULL,
                          NULL, NULL,
                          NULL, NULL,
                          &xyz_cv_dataselect,
                          &edge_dataselect, NULL,
                          NULL, NULL,
                          NULL, NULL,
                          NULL, NULL,
                          NULL, NULL,
                          TRUE, FALSE);
     if(k==0 || k==(num_edges-1))
      { /* This edge has one/both end(s) lying on a boundary. Update the
         * "more_info" in the "intobj" struct for the edge.
         */
        /* malloc memory for the EMSsfintedpar structure (2 nodes) */
         intobj->more_info = (IGRchar *)EMsfintedpar_malloc(&msg_loc, 2);
         EMerr_hndlr(!(1&msg_loc) || !(intobj->more_info), *msg, msg_loc,
                                                           ret_end);
        /* Get sfintedpar info about start point of edge */ 
         EMgetincinfo (&msg_loc, thisos, &edge_dataselect, FALSE, NULL,
                         &(modenv_cv->md_env.matrix_type),
                         modenv_cv->md_env.matrix,
                         spannedsf[i].objid, xyztol, sfpartol.tol,
                         (struct EMSsfintedpar *)(intobj->more_info));
         EMerr_hndlr (!(msg_loc&1), *msg, msg_loc, ret_end);

        /* get sfintedpar info about stop point of edge */
         EMgetincinfo (&msg_loc, thisos, &edge_dataselect, TRUE, NULL,
                         &(modenv_cv->md_env.matrix_type),
                         modenv_cv->md_env.matrix,
                         spannedsf[i].objid, xyztol, sfpartol.tol,
                        ((struct EMSsfintedpar *)(intobj->more_info))->next);
         EMerr_hndlr (!(msg_loc&1), *msg, msg_loc, ret_end);
      }
    }
    /* Delete the loop object after doing a wild disconnect on its
     * channels. This is so as to not delete the edges that are now part
     * of the inters list. Similarly we need to delete the composite
     * curve (its component curves are used in the inters list and hence
     * not deletable)
     */
     sts = om$send (msg = message Root.wild_disconnect(to_comps_chan),
                                targetid = out_loops.objs[j],
                                targetos = thisos,
                                senderid = NULL_OBJID);
     EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);

   /* now delete the loop (it is not connected to any loopset and neither
    * does it have any inner loops)
    */
     sts = om$send (msg = message Root.delete(1),
                         targetid = out_loops.objs[j],
                         targetos = thisos,
                         senderid = NULL_OBJID);
     EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end); 

   /* Do the same thing with the composite curve (composite curve is
    * produced ONLY if the number of curves is > 1).
    */
     if (num_edges > 1)
      {
       sts = om$send (msg = message Root.wild_disconnect(compcv_to_cv_chan),
                                targetid = out_cvs.objs[j],
                                targetos = thisos,
                                senderid = NULL_OBJID);
       EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);
       sts = om$send (msg = message Root.delete(1),
                         targetid = out_cvs.objs[j],
                         targetos = thisos,
                         senderid = NULL_OBJID);
       EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);
      }
   }
  }
 }
ret_end:
   for(i=0; i<spancount; i++)
    if(sfgeom[i]) om$dealloc (ptr = sfgeom[i]);
   if(sfgeom) om$dealloc (ptr = sfgeom);
   if(ed_list) om$dealloc (ptr = ed_list);
   if(cv_obj_info) om$dealloc (ptr = cv_obj_info);
   if(cv_grids) om$dealloc (ptr = cv_grids);
   if(cv_ids) om$dealloc (ptr = cv_ids);

   return(sts);
}


/*
 * A function which takes in a profile and the base solid. It return
 * ids of those components in the profile which are tangential and likely
 * coplanar to the surfaces of the base solid. Before you use this call
 * make it sure that the trace is originating from some point on the profile.
 * Not a severe constraint as the two can always be manipulated to satisfy
 * this criteria.
 *
 * PLEASE GO THROUGH IT ****** IF U ARE USING IT
 *
 * IMPORTANT :1) This function was written with use of profile in feature
 *             placement. In such a utility it can be easily infered that
 *             a profile segment can be tanential to the surface at its end
 *             points only if it a VALID PROFILE FOR A VALID FEATURE PLACEMENT.
 *             Not very difficult to visualise if you think for a minute. 
 *
 *           :2) Use of GRparm output argument is a bit overused/misused
 *               in this function so as to incoporate a case where the
 *               profile segment is tangential at its both ends. Since the
 *               idea of using the GRparm structure was to output the
 *               parametric value at which profile segment is tangent (Not
 *               again that incase of valid profile for valid feature placement
 *               tangency can be thought of at ends only ...... my thinking
 *               goes upto that limit only. IF you come across any case
 *               let me know about it.), such a situation is handled by using
 *               the "v" field of the GRparm structure.  
 */

IGRlong EMget_tancoplan_comps(msg,
                              profid,
                              trace,
                              modenvcv,
                              surfid,
                              modenvsf,
                              const_args,
                              tancomps,
                              numtancomps,
                              copl_comps,
                              numcoplcomps)
IGRlong *msg;
struct GRid *profid, *trace;
struct GRmd_env *modenvcv;
struct GRid *surfid;
struct GRmd_env *modenvsf;
struct GRvg_construct *const_args;
struct GRparms **tancomps;
IGRint *numtancomps;
struct GRid **copl_comps;
IGRint *numcoplcomps;
/*
 ARGUMENTS:
 msg        : message code returned.
 profid, trace : self-explanatory.
 modenvcv, modenvsf : module environment for the curve and surfaces.
 surfid : id of the surface/solid on with which profile is associated with.
 const_args : construct list.
 tancomps :OUTPUT: tangential components of the profile. I have specially
          defined it in the form of GRparm structure. 
*/
{
 IGRboolean flag;
 IGRlong sts, msg_loc;
 IGRint temp_var_cpl, temp_var_tan, numprof, j, i, k, index;
 IGRboolean ray_on_surf[3];
 struct GRid outcrv;
 IGRdouble upts[3], range, bastol, value;
 IGRpoint startpt, proj_pt, xyzpts[3];
 struct GRparms *loc_tancomps=NULL, proj_parms;
 struct GRid *loccopl_comps=NULL, *compprof=NULL;
 BSrc rc;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 range = 0.0;
 *tancomps = NULL;
 temp_var_cpl = 0;
 temp_var_tan = 0;
 *copl_comps = NULL;
 sts = BSEXTRACTPAR (&rc, BSTOLBASIS, bastol);

 /* Get the three sample points on the curve and shoot the ray/trace
  * from each of these sample points. For each ray, get the number of
  * components. for each componet take three sample points say start, mid
  * and the end. Project these points on the base solid and thusly get
  * the id's of the surface returned. Get distance between the point and
  * projected point and check for the bastol. If atleast one out of these
  * three rays being shot have all sample points lying with in the bastol
  * range, this component of the profile (mind it that you are keeping
  * the track of every damn thing) is one of the candidate for tangency.
  * NOTE : If all the three rays satisfies the above criteria, then this
  * component of the profile is a valid candidate for COPLANNARITY and
  * something should be done to counter the coplanarity condition at this
  * stage it self to avoid the problems further down stream by modifying
  * the coplanar segment of the profile or whatsoever.
  */
   
 /* Since we have to get rays, make it sure that we get the right starting
  * point for the ray.
  */
  sts = EMget_the_right_point(&msg_loc, profid, trace, modenvcv, startpt);
  EMSmsgReport(sts, "EMget_tancoplanl_comps:EMget_the_right_point", FALSE); 
  sts = EMget_component_info(&msg_loc, profid, modenvcv, &numprof, &compprof,
                 &flag);
  EMSmsgReport(sts, "EMget_tancoplanl_comps:EMget_component_info", FALSE);
  for(i=0; i<numprof; i++)
  {
  upts[0] = 0.0; upts[1] = 0.5; upts[2] = 1.0;
  for(index=0; index<3; index++)
  {
  sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                                      &modenvcv->md_env.matrix_type,
                                      modenvcv->md_env.matrix, &upts[index], 1, 
                                      xyzpts[index]),
                        senderid = NULL_OBJID,
                        targetid = compprof[i].objid,
                        targetos = compprof[i].osnum);
  EMSmsgReport(sts, "EMget_tancoplanl_comps:GRvg.EMptatpr", FALSE);
  }
  for(j=0; j<3; j++)
   {
   struct GRid *compcv=NULL;
   IGRint numcrv;
   IGRdouble u[3];
   IGRpoint xyz[3];
   IGRboolean decision[3];

   sts = EMget_the_ray(&msg_loc, &xyzpts[j], NULL, range, trace, startpt, 
                  modenvcv, const_args, &outcrv);
   EMSmsgReport(sts, "EMget_tancoplanl_comps:EMget_the_ray", FALSE);
   sts = EMget_component_info(&msg_loc, &outcrv, modenvcv, &numcrv, &compcv,
                 &flag);
   EMSmsgReport(sts, "EMget_tancoplanl_comps:EMget_component_info", FALSE);
  /*
   * Let us consider the '0'th component as one component is enough
   * for deciding the coplanarity or tangency.
   */
   u[0] = 0.0; u[1] = 0.5; u[2] = 1.0;
   for(index=0; index<3; index ++)
   {
   sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                                      &modenvcv->md_env.matrix_type,
                                      modenvcv->md_env.matrix, &u[index], 1, 
                                      xyz[index]),
                        senderid = NULL_OBJID,
                        targetid = compcv[0].objid,
                        targetos = compcv[0].osnum);
   EMSmsgReport(sts, "EMget_tancoplanl_comps:GRvg.EMptatpr", FALSE);
   }
   for(k=0; k<3; k++)
    {
    sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc, 
                           &modenvsf->md_env.matrix_type,
                           modenvsf->md_env.matrix,
                           xyz[k], proj_pt, &proj_parms),
                     senderid = NULL_OBJID,
                     targetid = surfid->objid,
                     targetos = surfid->osnum);
     EMSmsgReport(sts, "EMget_tancoplanl_comps:GRgraphics.GRptproject",FALSE);
     value = BSdistptpt(&rc, xyz[k], proj_pt);
     if(value <= bastol)
      decision[k] = TRUE;
     else
      decision[k] = FALSE; 
    }
   if(decision[0] && decision[1] && decision[2])   
    ray_on_surf[j] = TRUE;
   else
    ray_on_surf[j] = FALSE;
    sts = om$send (msg = message Root.delete(1),
                         targetid = outcrv.objid,
                         targetos = outcrv.osnum,
                         senderid = NULL_OBJID);
    EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);
    if(compcv) om$dealloc (ptr = compcv);
   }
  /* Now there may be following cases..
   * 1) All three rays from this profile segment are lying on the surface.
   *    In this case it is the case of COPLANARITY.
   * 2) Non of the ray is lying on the surface. It is really a very-very
   *    nece segment of the profile.
   * 3) Now the remained cases are those for which either one or two of 
   *    them lying on the surface. For all these cases we examine the rays
   *    which are originating from the start and stop point. In all these
   *    cases, this particular segment of the profile is a valid candidate
   *    for the tangency condition.
   */ 
   if(!ray_on_surf[0] && !ray_on_surf[1] && !ray_on_surf[2])
    continue;
   else
   if(ray_on_surf[0] && ray_on_surf[1] && ray_on_surf[2])
    {
    temp_var_cpl ++;
    if(temp_var_cpl IS 1)
     {
     loccopl_comps = (struct GRid *)om$malloc(size = sizeof(struct GRid));
     EMerr_hndlr(!(loccopl_comps), *msg, EMS_E_NoDynamicMemory, ret_end);
     }
    else
     {
     loccopl_comps = (struct GRid *)om$realloc(ptr = (IGRchar *)loccopl_comps,
                                  size = temp_var_cpl * sizeof(struct GRid));
     EMerr_hndlr(!(loccopl_comps), *msg, EMS_E_NoDynamicMemory, ret_end);
     }
    loccopl_comps[temp_var_cpl - 1].objid = compprof[i].objid;
    loccopl_comps[temp_var_cpl - 1].osnum = compprof[i].osnum;
    }
   else
    {
    if(numprof IS 1 && (ray_on_surf[0] && ray_on_surf[2]))
     {
     temp_var_tan ++;
     loc_tancomps = (struct GRparms *)om$malloc(size = sizeof(struct GRparms));
     EMerr_hndlr(!(loc_tancomps), *msg, EMS_E_NoDynamicMemory, ret_end);
     loc_tancomps[0].leaf_id.objid = compprof[0].objid;
     loc_tancomps[0].leaf_id.osnum = compprof[0].osnum;
     loc_tancomps[0].u = 0.0;
     loc_tancomps[0].v = 1.0; 
     }
    if(ray_on_surf[0] || ray_on_surf[2]) 
    {
    temp_var_tan ++;
    if(temp_var_tan IS 1)
     {
     loc_tancomps = (struct GRparms *)om$malloc(size = sizeof(struct GRparms));
     EMerr_hndlr(!(loc_tancomps), *msg, EMS_E_NoDynamicMemory, ret_end);
     }
    else
     {
     loc_tancomps = (struct GRparms *)om$realloc(ptr=(IGRchar *)loc_tancomps,
                            size = temp_var_tan * sizeof(struct GRparms));
     EMerr_hndlr(!(loc_tancomps), *msg, EMS_E_NoDynamicMemory, ret_end); 
     }
    loc_tancomps[temp_var_tan - 1].leaf_id.objid = compprof[i].objid;
    loc_tancomps[temp_var_tan - 1].leaf_id.osnum = compprof[i].osnum;
    if(ray_on_surf[0])
     {
     loc_tancomps[temp_var_tan - 1].u = 0.0;
     loc_tancomps[temp_var_tan - 1].v = -1.0;
     }
    else
     {
     loc_tancomps[temp_var_tan - 1].u = 1.0; 
     loc_tancomps[temp_var_tan - 1].v = -1.0;
     }
    }
   }
  }
 if(numtancomps)
  *numtancomps = temp_var_tan; 
 if(numcoplcomps)
  *numcoplcomps = temp_var_cpl;
 if(tancomps) 
  *tancomps = loc_tancomps;
 if(copl_comps)
 *copl_comps = loccopl_comps; 
ret_end:
  if(compprof) om$dealloc (ptr = compprof);

 return(sts);
}

static IGRlong EMget_tangential_feature_surfaces(msg, profid, tancomps,
                          modenvcv, numtancomps, trace, feasfid, modenvsf,
                          const_args, surfout, numsfs)
IGRlong *msg;
struct GRid *profid;
struct GRparms *tancomps;
struct GRmd_env *modenvcv;
IGRint numtancomps;
struct GRid *trace, *feasfid, **surfout;
struct GRmd_env *modenvsf;
struct GRvg_construct *const_args;
IGRint *numsfs;
{
 IGRlong sts, msg_loc;
 IGRint i, numcrv, temp_var, j;
 IGRdouble u, range;
 IGRpoint xyzpts, startpt_trace, proj_pt;
 struct GRparms proj_parms;
 IGRboolean flag;
 struct GRid outcrv, *compcv=NULL, *loc_surf_out=NULL;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 u = 0.5;
 range = 0.0;
 temp_var = 0;
 
 sts = EMget_the_right_point(msg, profid, trace, modenvcv, startpt_trace);
 EMSmsgReport(sts, "EMget_tangential_feature_surfaces:EMget_the_right_point",
              FALSE); 
 for(i=0; i<numtancomps; i++)
 {
 sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                                      &modenvcv->md_env.matrix_type,
                                      modenvcv->md_env.matrix, &u, 1,
                                      xyzpts),
                        senderid = NULL_OBJID,
                        targetid = tancomps[i].leaf_id.objid,
                        targetos = tancomps[i].leaf_id.osnum);
 EMSmsgReport(sts, "EMget_tangential_feature_surfaces:GRvg.EMptatpr", FALSE);
 sts = EMget_the_ray(&msg_loc, &xyzpts, NULL, range, trace, startpt_trace,
                  modenvcv, const_args, &outcrv);
 EMSmsgReport(sts, "EMget_tangential_feature_surfaces:EMget_the_ray", FALSE);
 sts = EMget_component_info(&msg_loc, &outcrv, modenvcv, &numcrv, &compcv,
                 &flag);
 EMSmsgReport(sts, "EMget_tangential_feature_surfaces:EMget_component_info", FALSE);
 for(j=0; j<numcrv; j++)
 {
 temp_var ++;
 sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                                      &modenvcv->md_env.matrix_type,
                                      modenvcv->md_env.matrix, &u, 1,
                                      xyzpts),
                        senderid = NULL_OBJID,
                        targetid = compcv[j].objid,
                        targetos = compcv[j].osnum);
 EMSmsgReport(sts, "EMget_tancoplanl_comps:GRvg.EMptatpr", FALSE);
 sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                           &modenvsf->md_env.matrix_type,
                           modenvsf->md_env.matrix,
                           xyzpts, proj_pt, &proj_parms),
                   senderid = NULL_OBJID,
                   targetid = feasfid->objid,
                   targetos = feasfid->osnum);
 EMSmsgReport(sts, "EMget_tancoplanl_comps:GRgraphics.GRptproject",FALSE);
 if(temp_var IS 1)
  {
  loc_surf_out = (struct GRid *)om$malloc(size = sizeof(struct GRid));
  EMerr_hndlr(!(loc_surf_out), *msg, EMS_E_NoDynamicMemory, ret_end);
  }
  else
  {
  loc_surf_out = (struct GRid *)om$realloc(ptr=(IGRchar *)loc_surf_out,
                            size = temp_var * sizeof(struct GRid));
  EMerr_hndlr(!(loc_surf_out), *msg, EMS_E_NoDynamicMemory, ret_end);
  }
  loc_surf_out[temp_var - 1].objid = proj_parms.leaf_id.objid;
  loc_surf_out[temp_var - 1].osnum = proj_parms.leaf_id.osnum;
  } 
  sts = om$send (msg = message Root.delete(1),
                         targetid = outcrv.objid,
                         targetos = outcrv.osnum,
                         senderid = NULL_OBJID);
  EMerr_hndlr (!(1&sts) ,*msg, EMS_E_OMerror, ret_end);
 }
 *numsfs = temp_var;
 *surfout = loc_surf_out;
ret_end:
 return(sts);
}

/*
 * A function which takes in a simple surface i.e. non composite. It
 * considers all the boundaries of the surface, takes mid point of the edge,
 * project this point onto the base solid to decide what edges are there to
 * be mapped for finding the tangential intersections.
 */

static IGRlong EMget_edge_tomap(msg, surfid, solid_GRid, modenvsf, edge,
                                numofedges)
IGRlong *msg;
struct GRid *surfid;
struct GRid *solid_GRid;
struct GRmd_env *modenvsf;
struct GRid **edge;
IGRint *numofedges;
{
 IGRlong sts, msg_loc, num_bytes;
 struct GRid *edge_GRids=NULL, *loc_edgrid=NULL;
 struct IGRbsp_surface *sfgeom=NULL;
 IGRint num_edges, array_size, temp_var, i;
 IGRdouble upar, value, bastol, samplept[1][2];
 BSrc rc;
 IGRpoint point, proj_pt;
 struct GRparms proj_parms;
 
 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 array_size = 0;
 num_edges = 0;
 upar = 0.5;
 temp_var = 0;

 sts = BSEXTRACTPAR (&rc, BSTOLBASIS, bastol);
 /* Getting the size and geometry of the surface.
  */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                &(modenvsf->md_env.matrix_type),
                                modenvsf->md_env.matrix, &num_bytes),
                   senderid = NULL_OBJID,
                   targetid = surfid->objid,
                   targetos = surfid->osnum);
 EMSmsgReport(sts, "EMget_edge_tomap:GRvg.GRgetsize", FALSE);
 sfgeom = (struct IGRbsp_surface *) om$malloc (size = num_bytes);
 EMerr_hndlr(!sfgeom, *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                               &(modenvsf->md_env.matrix_type),
                               modenvsf->md_env.matrix, (IGRchar *)sfgeom),
                   senderid = NULL_OBJID,
                   targetid = surfid->objid,
                   targetos = surfid->osnum);
 EMSmsgReport(sts, "EMget_edge_tomap:GRvg.GRgetgeom", FALSE);

 sts = om$send(msg = message EMSsubbs.EMget_edges(&msg_loc,
                        MAXINT, EMS_OPT_ALL, modenvsf, &edge_GRids, &array_size,
                       &num_edges),
                      senderid = NULL_OBJID,
                      targetid = surfid->objid,
                      targetos = surfid->osnum);
 EMSmsgReport(sts, "EMget_edge_tomap:EMSsubbs.EMget_edges",FALSE);
 for(i=0; i<num_edges; i++)
  {
  sts = om$send(msg = message EMSedge.EMinternalpt(&msg_loc, 1, NULL,
                      (IGRdouble *)samplept, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = edge_GRids[i].objid,
                        targetos = edge_GRids[i].osnum);
 EMSmsgReport(sts, "EMget_edge_tomap:EMinternalpt",FALSE);
 /*
  * Get the xyz value of this uv point found above.
  */
 BSsfeval(sfgeom, samplept[0][0], samplept[0][1], (IGRint) 0, (IGRpoint *)point, &rc);
 EMerr_hndlr( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                           &modenvsf->md_env.matrix_type,
                           modenvsf->md_env.matrix,
                           point, proj_pt, &proj_parms),
                   senderid = NULL_OBJID,
                   targetid = solid_GRid->objid,
                   targetos = solid_GRid->osnum);
 EMSmsgReport(sts, "EMget_edge_tomap:GRgraphics.GRptproject",FALSE);
 value = BSdistptpt(&rc, point, proj_pt);
 if(value < bastol)
  {
  temp_var ++;
  if(temp_var IS 1)
   {
   loc_edgrid = (struct GRid *)om$malloc(size = sizeof(struct GRid));
   EMerr_hndlr(!(loc_edgrid), *msg, EMS_E_NoDynamicMemory, ret_end);
   }
  else
   {
   loc_edgrid = (struct GRid *)om$realloc(ptr = (IGRchar *)loc_edgrid,
                               size = temp_var * sizeof(struct GRid));
   EMerr_hndlr(!(loc_edgrid), *msg, EMS_E_NoDynamicMemory, ret_end); 
   }
  loc_edgrid[temp_var - 1].objid = edge_GRids[i].objid;
  loc_edgrid[temp_var - 1].osnum = edge_GRids[i].osnum;
  }
 }
 *numofedges = temp_var;
 *edge = loc_edgrid;
ret_end:
 return(sts);
}

/*
 * This function is mother of all function. It calls the different functions
 * written for the selective intersection functionality to achieve the
 * end result.
 */
IGRlong EMselective_intersection(msg,
                                 profid,
                                 trace,
                                 modenvcv,
                                 feasfid,
                                 solid_GRid,
                                 modenvsf,
                                 const_args,
                                 inters1,
                                 inters2)
IGRlong *msg;
struct GRid *profid, *trace, *feasfid, *solid_GRid;
struct GRmd_env *modenvcv, *modenvsf;
struct GRvg_construct *const_args;
struct EMSinters **inters1, **inters2;
{
 IGRlong msg_loc, sts;
 IGRint i, j;
 struct GRparms *tancomps=NULL;
 struct GRid *coplcomps=NULL, *spannedsf=NULL;
 struct GRid *surfout=NULL, *edge=NULL;
 IGRint numtancomps, numsfs, numofedges, numcoplcomps;
 struct EMSinters *inters=NULL, *tmp_inters=NULL, *loc_inters=NULL;
 struct EMSintobj *loc_intobj=NULL;
 IGRlong EMget_tancoplan_comps();
 struct EMSinters *EMgen_other_interslist();

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 inters = NULL;
/*
 * Get the tangential components of the profile.
 */
 sts = EMget_tancoplan_comps(&msg_loc, profid, trace, modenvcv, solid_GRid,
                           modenvsf, const_args, &tancomps, &numtancomps,
                           &coplcomps, &numcoplcomps);
 EMSmsgReport(sts, "EMselective_intersection:EMget_tancoplan_comps",FALSE);
 if(numtancomps)
 {
 sts = EMget_tangential_feature_surfaces(&msg_loc, profid, tancomps, modenvcv,
                     numtancomps, trace, feasfid, modenvsf, const_args,
                     &surfout, &numsfs);
 EMSmsgReport(sts, "EMselective_intersection:EMget_tangential_feature_surfaces",              FALSE);
 }
 if(numsfs)
 {
 for(i=0; i<numsfs; i++)
  {
  sts =  EMget_edge_tomap(&msg_loc, &surfout[i], solid_GRid, modenvsf, &edge, 
                          &numofedges);
  EMSmsgReport(sts, "EMselective_intersection:EMget_edge_tomap", FALSE);
  if(numofedges)
   {
   for(j=0; j<numofedges; j++)
    {
     IGRint spancount=0;
     struct IGRbsp_curve edge_geometry;

     spannedsf = NULL;
     edge_geometry.weights = NULL;
     edge_geometry.poles = NULL;
     edge_geometry.knots = NULL;
     edge_geometry.bdrys = NULL;

    /* Get the xyz geometry of the edge. */
    sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                           &modenvsf->md_env, &surfout[i], 
                           (struct IGRbsp_surface *)NULL, (IGRint) 0, MAXINT,
                           FALSE, NULL, &edge_geometry),
                        senderid = NULL_OBJID,
                        targetid = edge[j].objid,
                        targetos = edge[j].osnum);
    EMSmsgReport(sts, "EMselective_intersection:EMSedge.EMgetbcgeom", FALSE);
    spannedsf = EMoutput_spanned_surfaces(&msg_loc, &edge_geometry, NULL,
                             modenvcv, NULL, solid_GRid, modenvsf, &spancount);
    if(spancount)
    {
    sts = EMgen_inters_node(msg, &edge_geometry, (struct GRid *)NULL,
                  modenvcv, const_args, NULL, spannedsf, spancount, modenvsf, 
                  &inters);
    EMSmsgReport(sts, "EMselective_intersection:EMgen_inters_node", FALSE);
    }
    loc_inters = inters;
    while(loc_inters)
    {
    loc_intobj = loc_inters->cvs;
    while(loc_intobj)
     {
     if(!(loc_intobj->props & EMSintobj_tmpmarked))
      {
      tmp_inters = EMgen_other_interslist(&msg_loc, loc_intobj, &surfout[i],
                      const_args, modenvsf);
      loc_intobj->other_intobj_node = tmp_inters->cvs;
      tmp_inters->cvs->other_intobj_node = loc_intobj;

      /* Mark this intobj as EMSintobj_tmpmarked to have the track that
       * this intobj has already been processed.
       */
      loc_intobj->props |= EMSintobj_tmpmarked;
      if(*inters2 IS NULL)
       *inters2 = tmp_inters;
      else
       EMmergeinters(&msg_loc, inters2, tmp_inters);
      }
     loc_intobj = loc_intobj->next;
     }
     loc_inters = loc_inters->next;
    }
    if(spannedsf) om$dealloc (ptr = spannedsf);
    if(edge_geometry.weights)om$dealloc(ptr = edge_geometry.weights);
    if(edge_geometry.poles)om$dealloc(ptr = edge_geometry.poles);
    if(edge_geometry.knots)om$dealloc(ptr = edge_geometry.knots);
    if(edge_geometry.bdrys)om$dealloc(ptr = edge_geometry.bdrys);
   }
  }
  if(edge) om$dealloc (ptr = edge); edge = NULL;
 }
 }
 if(surfout) om$dealloc (ptr = surfout); 
 *inters1 = inters;
 sts = EMset_the_orientation(&msg_loc, inters1[0], inters2[0], modenvsf);
 return(sts);
}
                            


/*
 * This function takes in an inters list and generate the other inters
 * list given the arrays of the GRid's of the surfaces belonging to the
 * second operand. It should be assumed that  the function is written for
 * generating the intersections for surfaces where there happens to exist
 * the condition of tangency.
 */

struct EMSinters *EMgen_other_interslist(msg, 
                                       intobj,
                                       surfid,
                                       const_args,
                                       modenv)
IGRlong *msg;
struct EMSintobj *intobj;
struct GRid *surfid;
struct GRvg_construct *const_args;
struct GRmd_env *modenv;
{
IGRlong msg_loc, sts, num_bytes;
struct IGRbsp_curve *edge_geom=NULL;
struct EMSinters *inters=NULL;
IGRlong EMgen_inters_node();

sts = OM_S_SUCCESS;
*msg = EMS_S_Success;

if(!intobj)
 {
 *msg = EMS_E_InvalidArg;
 sts = EMS_S_Fail;
 goto ret_end;
 }
/*
 * Get the geometry.
 */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         &num_bytes),
                       senderid = NULL_OBJID,
                       targetid = intobj->this_xyzintobj.data.object->objid,
                       targetos = intobj->this_xyzintobj.data.object->osnum);
 EMSmsgReport(msg_loc, "EMgen_other_interslist:GRvg.GRgetsize", FALSE);
 edge_geom = (struct IGRbsp_curve *) om$malloc (size = num_bytes);
 EMerr_hndlr(!(edge_geom), *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         (IGRchar *)edge_geom),
                       senderid = NULL_OBJID,
                       targetid = intobj->this_xyzintobj.data.object->objid,
                       targetos = intobj->this_xyzintobj.data.object->osnum);
 EMSmsgReport(msg_loc, "EMgen_other_interslist:GRvg.GRgetgeom", FALSE);
 sts = EMgen_inters_node(&msg_loc,
                          edge_geom,
                          NULL,                    
                          modenv,
                          const_args,
                          NULL,
                          surfid,
                          1,
                          modenv,
                          &inters);
  EMSmsgReport(sts, "EMgen_other_interslist:EMgen_inters_node", FALSE);
ret_end:
 return(inters);
}

/*
 * This function takes in an inters list. This inters list should have
 * all its intersections i.e. intobjs MUST NECESSIRILY be lying on the 
 * boundaries  of the surface. It may look odd to even think about
 * imposing such a non-sense restriction, but thats what when we talk
 * about the business on tangential intersections and the concept of
 * orienting them. I can think of these intersections lying only
 * on the boundaries of atleast one of the operand incase there happens
 * to be tangency. Ofcourse I am leaving apart the non-manifold
 * situations. Every thing  will go ???$$## if this assumption is not O.K.
 * I am writing this function to basically orient the intersectioons lying
 * on the other surface. These intersections on the "other surface" will
 * NOT be on the boundary if the profile ends are NOT on the boundary. Of
 * course it also depends on the location of the trace curve.
 */

static IGRlong EMset_the_orientation(msg, inters1, inters2, modenv)
IGRlong *msg;
struct EMSinters *inters1, *inters2;
struct GRmd_env *modenv;
{
 IGRlong msg_loc, sts, num_bytes;
 IGRboolean pos_orient1, pos_orient2;
 struct EMSinters *loc_inters=NULL, *loc_inters_next=NULL;
 struct EMSintobj *loc_intobj=NULL, *other_obj=NULL, *loc_intobj_next=NULL;
 struct GRid *loc_GRid=NULL;
 struct IGRbsp_surface *sfgeom;
 IGRint i;


 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 sfgeom = NULL;

 for(i=0; i<2; i++)
 {
 loc_GRid = i ? &inters2->this_obj : &inters1->this_obj;
 loc_inters = i ? inters2 : inters1;
 while(loc_inters)
  {
  loc_inters->more_info = NULL;
  sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         &num_bytes),
                       senderid = NULL_OBJID,
                       targetid = loc_GRid->objid,
                       targetos = loc_GRid->osnum);
  EMSmsgReport(msg_loc, "EMset_objs_orientation:GRvg.GRgetsize", FALSE);
  loc_inters->more_info = (IGRchar *) om$malloc (size = num_bytes);
  EMerr_hndlr(!(loc_inters->more_info),msg_loc,EMS_E_NoDynamicMemory, ret_end);
  sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         loc_inters->more_info),
                       senderid = NULL_OBJID,
                       targetid = loc_GRid->objid,
                       targetos = loc_GRid->osnum); 
  EMSmsgReport(msg_loc, "EMset_objs_orientation:GRvg.GRgetgeom", FALSE);
  loc_inters = loc_inters->next;
  } 
 } 
 loc_inters = inters1;
 while(loc_inters)
 {
 loc_inters_next = loc_inters->next;
 loc_intobj = loc_inters->cvs;
 while(loc_intobj)
  {
  loc_intobj_next = loc_intobj->next;
  other_obj = loc_intobj->other_intobj_node;
  sfgeom = (struct IGRbsp_surface *)loc_intobj->this_obj_node->more_info;
  pos_orient1 = sfgeom->pos_orient;
  sfgeom = (struct IGRbsp_surface *)other_obj->this_obj_node->more_info;
  pos_orient2 = sfgeom->pos_orient;
  if(!(pos_orient1 ^ pos_orient2))
   other_obj->reversed = ~loc_intobj->reversed; 
  loc_intobj = loc_intobj_next;
  }
  loc_inters = loc_inters_next;
 }
ret_end:
 return(sts);
}

/*
 * This function takes in  inters lists and an intobj. It makes search for
 * intersection in the inters list for a possible replacement. In case a
 * possible replacement is detected, replacement is done else this intersection
 * is appended in the inters list at the proper place.
 * IDEA:
 *   Since this whole concept revolves around the tangential intersections
 * it is quite possible that math has failed to return any intersection
 * because of tangency OR they are not "good" intersections. This replacement
 * provides an alternative means for the process to cross the EMS_S_Success
 * line.
 *
 * MODES OF SEARCHING AND REPLACEMENT
 *
 * 1) Search of the inters node. If it does not exist simply append the
 *    inters node to it. 
 * 2) To make a search for the intobjs. For this take some sample points
 *    on both the intobjs. It is better to take these sample points at
 *    the same parametric values. Since for a possible "duplicate" (match
 *    is the better term) the projected point and the sample points 
 *    should match.
 */

IGRlong EMupdate_inters_list(msg, inters1, inters2, modenv)
IGRlong *msg;
struct EMSinters *inters1, *inters2;
struct GRmd_env *modenv;
{
 IGRlong msg_loc, sts;
 struct GRid *surf;
 IGRdouble *sampt2d, xyz_chd_ht, mindist[NUM_SAMPLE_PTS];
 struct EMSinters *inters_loc;
 struct EMSintobj *intobj_loc, *intobj_loc_next;
 struct EMSpypoint projpts[NUM_SAMPLE_PTS];
 BSrc rc;
 IGRboolean possible_match;
 IGRint count, j;
 IGRlong EMget_uv_samplepts();
 IGRpoint *sampt3d;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 sampt2d = NULL;
 sampt3d = NULL;
 inters_loc = NULL;
 intobj_loc_next = NULL;

 BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyz_chd_ht);

/*
 * All the intobjs in the second inters list are being marked. 
 */
 inters_loc = inters2;
 while(inters_loc)
 {
 intobj_loc = inters_loc->cvs;
 while(intobj_loc)
  {

  if(!(intobj_loc->props & EMSintobj_mapped_data))
   intobj_loc->props |=EMSintobj_mapped_data;
  intobj_loc = intobj_loc->next;
  }
 inters_loc = inters_loc->next;
 }
 EMmergeinters(&msg_loc, &inters1, inters2);
 EMSmsgReport(msg_loc, "EMmergeinters: EMupdate_inters_list", FALSE);
 /*
  * since EMmergeinters ensures that the content of the second inters list
  * is appended at the end (in respective inters node if exists) we 
  * ckeck for the match and replace the first appeared intobj with its
  * mattched appearence.
  */
 inters_loc = inters1;
 while(inters_loc)
 {
 surf = &inters_loc->this_obj;
 intobj_loc = inters_loc->cvs;
 while(intobj_loc)
  {
  count = 0;
  intobj_loc_next = intobj_loc->next;
  while(intobj_loc_next)
   {
   if(!(intobj_loc->props & EMSintobj_mapped_data) && 
      (intobj_loc_next->props & EMSintobj_mapped_data))
    {
    sts = EMget_uv_samplepts(&msg_loc, &intobj_loc_next->this_uvintobj,
                          surf, modenv, NUM_SAMPLE_PTS, &sampt2d, &sampt3d);
    if (EMSerror (sts & msg_loc)) goto ret_end;
    sts = EMprojectpt(&msg_loc, &modenv->md_env.matrix_type,
                   modenv->md_env.matrix, &intobj_loc->this_xyzintobj,
                   NUM_SAMPLE_PTS, (IGRdouble *)sampt3d, xyz_chd_ht,
                   projpts, mindist);
    EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
    for (j=0; j<NUM_SAMPLE_PTS; j++)
    {
    if (BSdistptpt(&rc, sampt3d[j], projpts[j].point) > xyz_chd_ht)
     {
     possible_match = FALSE;
     break;
     }
    else
     {
     possible_match = TRUE;
     intobj_loc->props |= EMSintobj_dupthissurf;
     count ++;
     }
    }
   }
   intobj_loc_next = intobj_loc_next->next; 
  }
 /*
  * When an intobj is checked against other intobjs on the surface
  * for a possible match, There should not be more than one match if
  * the original inters list was already processed for duplicate intersections.
  * The following check is ensure that things are O.K.
  */ 
 if(count > 1)
  {
   sts = EMS_E_Fail;
   goto ret_end;
  }
  intobj_loc = intobj_loc->next;
  }
 inters_loc = inters_loc->next;
 }
 /*
  * Now traverse this inters list and all those intobjs which are 
  * being marked as "EMSintobj_dupthissurf" are deleted unconditionally.
  */
 inters_loc = inters1;
 while(inters_loc)
 {
 intobj_loc = inters_loc->cvs;
 while(intobj_loc)
  {
  if(intobj_loc->props & EMSintobj_dupthissurf)
   {
   EMdelintobj(&msg_loc, intobj_loc);
   EMSmsgReport(msg_loc, "EMdelintobj: EMupdate_inters_list", FALSE);
   }
  intobj_loc = intobj_loc->next;
  }
 inters_loc = inters_loc->next;
 }
ret_end:
 return(sts);
}
 
/*
 * This function takes in a dataselect and returns the number of internal
 * points requested. It returns the uv and xyz values of these internal
 * points.
 */                         
 
IGRlong EMget_uv_samplepts(msg,
                           data,
                           surf_GRid,
                           modenv,
                           numpt,
                           sampt2d,
                           sampt3d)
IGRlong *msg;
struct EMSdataselect *data;
struct GRid *surf_GRid;
struct GRmd_env *modenv;
IGRint numpt;
IGRdouble **sampt2d, **sampt3d;
{
 IGRlong msg_loc, sts, num_bytes;
 struct EMSpartolbasis partolb;
 IGRboolean in_world;
 BSrc rc;
 GRspacenum sfos;
 IGRint i;
 struct IGRbsp_surface *sfgeom;
 IGRdouble xyzpt[6];

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 in_world = TRUE;
 sfos = surf_GRid->osnum;
 sfgeom = NULL;
 sampt2d = NULL;
 sampt3d = NULL;

 sampt2d = (IGRdouble **) om$malloc (size = numpt * sizeof(IGRdouble *));
 EMerr_hndlr(!(sampt2d), *msg, EMS_E_NoDynamicMemory, ret_end);
 sampt3d = (IGRdouble **) om$malloc (size = numpt * sizeof(IGRdouble *));
 EMerr_hndlr(!(sampt2d), *msg, EMS_E_NoDynamicMemory, ret_end);
 for(i=0; i<numpt; i++)
 {
 sampt2d[i] = NULL;
 sampt2d[i] = (IGRdouble *) om$malloc (size = 2 * sizeof(IGRdouble *));
 EMerr_hndlr(!(sampt2d[i]), *msg, EMS_E_NoDynamicMemory, ret_end);
 sampt3d[i] = NULL;
 sampt3d[i] = (IGRdouble *) om$malloc (size = 3 * sizeof(IGRdouble *));
 EMerr_hndlr(!(sampt3d[i]), *msg, EMS_E_NoDynamicMemory, ret_end);
 }
/*
 * Get the basis tolerance for the surface.
 */
 partolb.in_world = TRUE;
 partolb.is_valid = FALSE;
 sts = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                            &modenv->md_env.matrix_type,
                            modenv->md_env.matrix,
                            &in_world, FALSE, &partolb.tol),
                  targetid = surf_GRid->objid,
                  targetos = sfos,
                  senderid = NULL_OBJID);
 if (EMSerror (sts & msg_loc)) goto ret_end;
 partolb.is_valid = TRUE;

 if(data->datatype == EMSdata_object)
  sts = om$send(msg = message EMSedge.EMinternalpt(&msg_loc,
                        numpt, NULL,
                        (IGRdouble *)sampt2d, NULL, &partolb),
                   targetid = data->data.object->objid,
                   targetos = sfos, senderid = NULL_OBJID);
 else if (data->datatype == EMSdata_poly2d)
  sts = EMinternalpt(&msg_loc, &modenv->md_env.matrix_type,
                     modenv->md_env.matrix, 
                     data, EMScvint_middle, numpt, (IGRdouble *)sampt2d);
 else if (data->datatype == EMSdata_curve3d)
 {
  sts = EMinternalpt (&msg_loc, &modenv->md_env.matrix_type,
                      modenv->md_env.matrix,
                      data, EMScvint_middle, numpt, (IGRdouble *)sampt3d);
  for(i=0;i<3;i++)
   OM_BLOCK_MOVE(sampt3d[i], sampt2d[i], 2 * sizeof(IGRdouble));
 }
 else
 {
  sts = OM_E_ABORT;
  goto ret_end;
 }
/*
 * Getting the surface geometry.
 */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         &num_bytes),
                       senderid = NULL_OBJID,
                       targetid = surf_GRid->objid,
                       targetos = surf_GRid->osnum);
 EMSmsgReport(msg_loc, "EMget_uv_samplepts:GRvg.GRgetsize", FALSE);
 sfgeom = (struct IGRbsp_surface *) om$malloc (size = num_bytes);
 EMerr_hndlr(!(sfgeom), *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &modenv->md_env.matrix_type,
                         modenv->md_env.matrix,
                         (IGRchar *)sfgeom),
                       senderid = NULL_OBJID,
                       targetid = surf_GRid->objid,
                       targetos = surf_GRid->osnum);
 EMSmsgReport(msg_loc, "EMget_uv_samplepts:GRvg.GRgetgeom", FALSE);
 for(i=0; i<numpt; i++)
 {
 BSsfeval(sfgeom, sampt2d[i][0], sampt2d[i][1], 0, (IGRpoint *)xyzpt, &rc);
 EMerr_hndlr(rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 OM_BLOCK_MOVE(&xyzpt[0], sampt3d[i], 3 * sizeof(IGRdouble));
 }
ret_end:
 return(sts);
}
end implementation Root;

