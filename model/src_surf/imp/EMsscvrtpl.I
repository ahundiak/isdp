class implementation EMSsubbs;

#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSfrtdef.h"
#include "EMSdpr.h"
#include "EMStpmacros.h"
#include "EMSpromacros.h"
#include "EMSutlmacros.h"

#include "madetplan.h"
#include "bsunwght_p.h"
#include "bsplptnorrg.h"
#include "bsmergarrcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"

/*
History

    AIC     06/04/93    Use closed curve to orient plane (unless this is
                        a pre-2.4 object).
    Sudha   07/07/93    Modified for BSprototypes ansification
    AIC     18 Oct 93   Modified merge curve logic to allow for cases
                        where a the boundaries represent more than one
                        closed curve in model space. Problem case: a
                        line revolved about at axis to produce a planar
                        disk. If this method were used on a surface with
                        more than one loop, the same problem would have
                        resulted prior to this fix.
    AIC     10 Nov 93   Reverse the merged curve because the direction
                        of a Ploop is oposite the sense that is needed
                        for EMorient_plane. (Note: Because I did not
                        have access to RCS, the previous modification
                        (18 Oct) was not checked into source code
                        management, but a similar fix was made to the
                        file. That fix had problems, so I am modifying
                        my version of the file instead of the RCS
                        version.
    AIC     16 Nov 93   Separate merge curve logic out into a function
                        so that it can be shared with EMedcappl.I.
    AIC     03 Dec 93   EFmerge_and_orient: Restore the reversed curve
                        in case the caller passes in a closed curve that
                        he will later use.
*/

#define StaticBuf 10

extern OMuword OPP_EMSloopset_class_id, OPP_EMSassoc_class_id,
               OPP_EMSplane_class_id, OPP_EMAplane_class_id;

extern IGRboolean   WANT_POST220_BEHAVIOR;

from EMSedge import EMget_bcxyz_geom, EMget_props_type, EMget_props,
                    EMset_props, EMconnect_edges;
from EMSloop import EMgivenestinfo, EMtreemod, EMtoggle_type;
from EMSloopset import EMnesting, EMtreemod, EMget_props, EMmakeFRT;
from EMSboundary import EMget_objid;

extern IGRboolean _sm_convert_into_plane;

method EMconvert_into_plane(IGRlong *EMmsg; IGRushort options;
                            GRobjid **origedges, **newedges, *oldls;
                            IGRint *numedges;
                            struct GRmd_env *env)
{
 IGRlong                        sts = OM_S_SUCCESS, rc, locsts;
 struct IGRbsp_surface          *mygeom = NULL, plane;
 IGRshort                       *mxtyp;
 struct GRid                    my_GRid, *myedges = NULL, clip_ls;
 GRrange                        myrange;
 IGRboolean                     world_range = TRUE, inrange, corrupt = FALSE;
 IGRpoint                       plane_poles[4], locplpt, *plpts = NULL,
                                plptsbuf[StaticBuf];
 IGRdouble                      plane_u_knots[4], plane_v_knots[4],
                                scale_factor = 1.1, chtol, partol, *mx,
                                junkpt[6], dotp;
 struct IGRplane                locplane;
 IGRvector                      locplnormal, mynatn, plnatn;
 IGRint                         edbufsize = 0, numed = 0, i,
                                *nummapedges = NULL, j, totaled = 0;
 IGRlong                        num_pnts;
 struct IGRbsp_curve            *edgeomptr = NULL, edgeomptrbuf[StaticBuf],
                                **edgeomptrptr = NULL,
                                *edgeomptrptrbuf[StaticBuf];
 struct EMSgetlp_planar_info    planar_info;
 struct EMSgetlp_output         outlp;
 IGRuchar                       *edge_types = NULL, edge_typesbuf[StaticBuf];
 GRobjid                        planels = NULL_OBJID, newid, **cvinfo = NULL,
                                *cvinfobuf[StaticBuf], *fromed, existls,
                                newed, oldcomed;
 struct EMSnest_info            nesting;
 struct EMSpartolbasis          partolstr;
 OM_S_CHANSELECT                to_ls, to_sf, to_lp, to_comed, to_ed, ed_to_lp;
 struct GRpost_info             post_info;
 struct EMSgetlp_edgeinfo       **mapedges = NULL;
 IGRushort                      newed_props = NULL, existls_props = NULL;
 enum GRdpmode                  dpmode;

 *EMmsg = EMS_S_Success;
 outlp.num_objs = 0;
 outlp.objs = NULL;
 mxtyp = &env->md_env.matrix_type;
 mx = env->md_env.matrix;
 EMerr_hndlr(origedges && !oldls, *EMmsg, EMS_E_InvalidArg, wrapup);

 if(!(ME.GRgraphics->properties & GRIS_PLANAR))
  {
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 if(!_sm_convert_into_plane)
  {
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 if(EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, OPP_EMSplane_class_id,
                      FALSE))
  {
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chtol);

 sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, &env->md_env,
       NULL, &existls, NULL, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message EMSloopset.EMget_props(EMmsg, &existls_props),
       targetid = existls);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Get my geometry.
 */
/************************************************************************
 sts = EMgetvggeom(EMmsg, mxtyp, mx, &my_GRid, &mygeom, NULL);
************************************************************************/
 sts = ems$getvggeom (msg = EMmsg,
                      matrixtype = mxtyp,
                      matrix = mx,
                      object = &my_GRid,
                      geometry = (IGRchar **)&mygeom);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Get my range so that appropriate plane can be constructed.
 */
 sts = om$send(msg = message GRvg.GRgetrang(EMmsg, mxtyp, mx, &world_range,
       myrange), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Construct a plane encompassing the total range.
 */
 plane.poles = (IGRdouble *) plane_poles;
 plane.u_knots = plane_u_knots;
 plane.v_knots = plane_v_knots;
 scale_factor = 1.1;

 locplane.point = locplpt;
 locplane.normal = locplnormal;

 num_pnts = mygeom->u_num_poles * mygeom->v_num_poles;
 if(num_pnts > StaticBuf)
  plpts = (IGRpoint *) om$malloc(size = num_pnts * sizeof(IGRpoint));
 else
  plpts = plptsbuf;
 EMerr_hndlr(!plpts, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 if(mygeom->rational && mygeom->weights)
  {
   (void) BSunwght_p(&rc, mygeom->poles, mygeom->weights, &num_pnts,
                     (IGRdouble *)plpts);
   if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
  }
 else OM_BLOCK_MOVE(mygeom->poles, plpts, num_pnts * sizeof(IGRpoint));

 locsts = MAdetplane(EMmsg, (IGRdouble *)plpts, &num_pnts, &chtol, &locplane);
 if(!(1&*EMmsg&locsts)) goto wrapup;

 BSplptnorrg(myrange, &myrange[3], locplane.point, locplane.normal,
             scale_factor, &inrange, &plane, &rc);
 if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}

 /* Comparing my natural normal and that of the new plane, set its pos orient
    property appropriately.
 */
/**************************************************************************
 EMavgsfnorm(EMmsg, mygeom, 0.0, 0.0, junkpt, mynatn);
 if(!(1&*EMmsg)) goto wrapup;
 EMavgsfnorm(EMmsg, &plane, 0.0, 0.0, junkpt, plnatn);
 if(!(1&*EMmsg)) goto wrapup;
**************************************************************************/
 ems$avgsfnorm(
           msg = EMmsg,
          surface = mygeom,
          surfacept = junkpt,
          natnorm = mynatn);
 if(!(1&*EMmsg)) goto wrapup;
 ems$avgsfnorm(
           msg = EMmsg,
          surface = &plane,
          surfacept = junkpt,
          natnorm = plnatn);
 if(!(1&*EMmsg)) goto wrapup;

 dotp = BSdotp(&rc, mynatn, plnatn);
 if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}

 plane.pos_orient = mygeom->pos_orient;
 if(dotp < 0) plane.pos_orient = !plane.pos_orient;

 /* Get all the non-degenerate, non-seam edges connected to me. These will
    have to be mapped as boundaries on the new plane.
 */
 sts = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
       EMS_OPT_NONDEG_NONSEAM, &myedges, &edbufsize, &numed, NULL, NULL, NULL,
       NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(numed > StaticBuf)
  {
   edgeomptr = (struct IGRbsp_curve *) om$malloc(size = numed *
               sizeof(struct IGRbsp_curve));
   edgeomptrptr = (struct IGRbsp_curve **) om$malloc(size = numed *
               sizeof(struct IGRbsp_curve *));
   edge_types = (IGRuchar *) om$malloc(size = numed * sizeof(IGRuchar));
  }
 else
  {
   edgeomptr = edgeomptrbuf;
   edgeomptrptr = edgeomptrptrbuf;
   edge_types = edge_typesbuf;
  }
 EMerr_hndlr(!edgeomptr || !edgeomptrptr || !edge_types, *EMmsg,
             EMS_E_NoDynamicMemory, wrapup);

 for(i=0; i<numed; i++)
  {
   edgeomptr[i].poles = NULL;
   edgeomptr[i].knots = NULL;
   edgeomptr[i].weights = NULL;
   edgeomptrptr[i] = &edgeomptr[i];
  }

 for(i=0; i<numed; i++)
  {
   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, &env->md_env,
         &my_GRid, mygeom, 0, MAXINT, FALSE, NULL, &edgeomptr[i]),
         targetid = myedges[i].objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
   sts = om$send(msg = message EMSedge.EMget_props_type(EMmsg, NULL,
         &edge_types[i]), targetid = myedges[i].objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

  /* Re-orient the plane so that the uv axes line up.
  */
  if(! WANT_POST220_BEHAVIOR)
  {
    sts = EMorient_plane(EMmsg, mygeom->poles, &plane, NULL);
    if(!(1&*EMmsg&sts)) goto wrapup;
  }
  else
  {
    /* Modified this logic to take each curve, merging in the next,
     * until a closed curve is formed. AIC 18 Oct 93
     */
    sts = EFmerge_and_orient(EMmsg, edgeomptrptr, numed, &plane);
    if(! (1 & sts & *EMmsg)) goto wrapup;

  }

 /* We now have the xyz geometry of all the boundaries (natural/non
    natural).
 */
 planar_info.edge_types = edge_types;

 if(numed > StaticBuf)
  cvinfo = (GRobjid **) om$malloc(size = numed * sizeof(GRobjid *));
 else
  cvinfo = cvinfobuf;
 EMerr_hndlr(!cvinfo, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 for(i=0; i<numed; i++)
  cvinfo[i] = &myedges[i].objid;
 planar_info.curve_info = (IGRchar **) cvinfo;

 planar_info.out_edges = &mapedges;
 planar_info.num_out_edges = &nummapedges;
/******************************************************************
 sts = EFsspbtol_by_geom(EMmsg, &plane, &partol);
******************************************************************/
 sts = ems$sspbtol_by_geom(
                     msg = EMmsg,
                   surface = &plane,
                  partolbasis = &partol);
 if(!(1&*EMmsg&sts)) goto wrapup;

 clip_ls.objid = NULL_OBJID;
 clip_ls.osnum = OM_Gw_current_OS;

 sts = EMget_mapped_data(numed, edgeomptrptr, NULL, NULL, &plane,
       &partol, env, NULL, NULL, &outlp, NULL, clip_ls,
       EMMapBnd_SurfIsPlane | EMMapBnd_WantBadCurves, &planar_info, EMmsg);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* We now have a set of loops for the plane. Each of these loops should
    be closed.
 */
 if(!outlp.num_objs)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

 /* Verification about the number of edges.
 */
 for(i=0; i<outlp.num_objs; i++)
  {
   if(!mapedges[i] || !nummapedges[i])
    {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
    }
   totaled += nummapedges[i];
  }
 EMerr_hndlr(numed != totaled, *EMmsg, EMS_E_Fail, wrapup);

 /* Create a nested loopset for the plane to be constructed.
 */
 sts = om$construct(classid = OPP_EMSloopset_class_id, p_objid = &planels);
 if(!(1&sts)) goto wrapup;

 partolstr.tol = partol;
 partolstr.is_valid = TRUE;

 /* Change my class to a plane, disconnect my loopset and connect the new
    loopset to me.
 */
/**************************************************************
 EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
 EMmake_chanselect(EMSloopset_to_surface, &to_sf);
**************************************************************/
 ems$make_chanselect(
              chan_label = EMSsubbs_to_loopset,
              chan_selector = &to_ls);
 ems$make_chanselect(
              chan_label = EMSloopset_to_surface,
              chan_selector = &to_sf);

 corrupt = TRUE;
 sts = om$send(msg = message Root.wild_disconnect(to_ls), targetid = my_id);
 if(!(1&sts)) goto wrapup;

 /* Erase the surface being replaced if so specified.
 */
 if(options & EMreplace_DO_DISPLAY)
  {
   dpmode = GRbe;
   sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, mxtyp, mx, &dpmode,
         &env->md_id), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Post the new geometry.
 */
 post_info.construct_flag = FALSE;
 sts = om$send(msg = message GRvg.GRpostabsg(EMmsg, env,
       &post_info, (IGRchar *) &plane, &newid), targetid = my_id);

 /* Delete abstract buffer.
 */
 (void) GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

 sts = om$send(msg = message Root.connect(to_sf, NULL, my_id, OM_Gw_current_OS,
       to_ls, NULL), targetid = planels);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<outlp.num_objs; i++)
  {
   sts = om$send(msg = message EMSloop.EMgivenestinfo(EMmsg, &nesting),
         targetid = outlp.objs[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(nesting.lp_props & EMLP_OPEN)
    {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
    }

   sts = om$send(msg = message EMSloopset.EMnesting(EMmsg, &nesting,
         &partolstr), targetid = planels);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(IF_EQ_OBJID(nesting.parent, planels))
    sts = om$send(msg = message EMSloopset.EMtreemod(EMmsg, &nesting,
          ADD_CHILD, &partolstr), targetid = planels);
   else
    sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting,
          ADD_CHILD, &partolstr), targetid = nesting.parent);
  }

 /* Make the outermost loop on the new plane a P loop and then toggle
    through.
 */
/***********************************************************************
 EMmake_chanselect(EMSloopset_to_loops, &to_lp);
***********************************************************************/
 ems$make_chanselect(
           chan_label = EMSloopset_to_loops,
           chan_selector = &to_lp);
 sts = om$send(msg = message EMSloop.EMtoggle_type(EMmsg, TRUE, FALSE,
       planels, EMTogType_SendInner | EMTogType_SendOuter, NULL, NULL, NULL,
       NULL, NULL, NULL), senderid = planels, p_chanselect = &to_lp);

 /* We now need to transfer the common edge connections from old edges
    to the corresponding new edges on the plane.
    Also output the old and new edges if requested.
 */
 if(origedges && !*origedges)
  {
   *origedges = (GRobjid *) om$malloc(size = numed * sizeof(GRobjid));
   EMerr_hndlr(!origedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(newedges && !*newedges)
  {
   *newedges = (GRobjid *) om$malloc(size = numed * sizeof(GRobjid));
   EMerr_hndlr(!newedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(numedges) *numedges = numed;
/***************************************************************
 EMmake_chanselect(EMSedge_to_common_edge, &to_comed);
***************************************************************/
 ems$make_chanselect(
          chan_label = EMSedge_to_common_edge,
          chan_selector = &to_comed);

 totaled = 0;
 for(i=0; i<outlp.num_objs; i++)
  {
   for(j=0; j<nummapedges[i]; j++)
    {
     newed = mapedges[i][j].edgeid;
     fromed = (GRobjid *) mapedges[i][j].info;
     if(origedges && *origedges) (*origedges)[totaled] = *fromed;
     if(newedges && *newedges) (*newedges)[totaled++] = newed;

     /* Transfer the old edge's common edge to the new edge.
     */
     oldcomed = NULL_OBJID;
     sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &oldcomed),
           senderid = *fromed, p_chanselect = &to_comed);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(IF_NULL_OBJID(oldcomed)) continue;

     sts = om$send(msg = message Root.wild_disconnect(to_comed),
           targetid = *fromed);
     if(!(1&sts)) goto wrapup;

     /* Clear the reverse connect and dominant properties on the old mates.
     */
     sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &newed_props),
           targetid = newed);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSedge.EMset_props(EMmsg,
           EMED_SUBORDINATE | EMED_REVERSE_CONNECT, EMS_O_OFF),
           targetid = *fromed);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$send(msg = message EMSedge.EMset_props(EMmsg,
           EMED_SUBORDINATE | EMED_REVERSE_CONNECT, EMS_O_OFF),
           targetid = oldcomed);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Connect up the new mates. (newed and oldcomed)
     */
     sts = om$send(msg = message EMSedge.EMconnect_edges(EMmsg, newed_props,
           TRUE, oldcomed, my_id, NULL_OBJID, &env->md_env),
           targetid = newed);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  }

 /* If the old loopset was natural and the new loopset contains only one
    loop, try to maintain the same loop->edge indices, to avoid topology
    mismatches. We should be able to do this since the old and new surfaces
    are similarly parametrized. A loop reversed/not reversed on the old
    surface should maintain the same property on the new surface.
    Due to the characteristics of the trace function (which was used via
    EMget_mapped_data), we are assured of the indices not being the same.
    Hence the post processing.
 */
 if((existls_props & EMLS_NATURAL) && (outlp.num_objs == 1) &&
    (nummapedges[0] == 4))
  {
   IGRboolean connected;
/***************************************************************
   EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
   EMmake_chanselect(EMSedge_to_owner, &ed_to_lp);
***************************************************************/
   ems$make_chanselect(
            chan_label = EMSbd_owner_to_comps,
            chan_selector = &to_ed);
   ems$make_chanselect(
            chan_label = EMSedge_to_owner,
            chan_selector = &ed_to_lp);

   /* Disconnect all the edges of the new loop.
   */
   sts = om$send(msg = message Root.wild_disconnect(to_ed),
         targetid = outlp.objs[0]);
   if(!(1&sts)) goto wrapup;

   /* Reconnect. 'myedges' array has the old edges arranged by the
      indices on the natural loop.
   */
   for(i=0; i<4; i++)
    {
     connected = FALSE;
     for(j=0; j<4; j++)
      {
       newed = mapedges[0][j].edgeid;
       fromed = (GRobjid *) mapedges[0][j].info;
       if(!IF_EQ_OBJID(*fromed, myedges[i].objid)) continue;

       sts = om$send(msg = message Root.connect(to_ed, NULL, newed,
             OM_Gw_current_OS, ed_to_lp, i), senderid = newed,
             targetid = outlp.objs[0]);
       if(!(1&sts)) goto wrapup;
       break;
      }
    }
  }

 if(oldls) *oldls = existls;
 else
  sts = om$send(msg = message Root.delete(TRUE), targetid = existls);

 /* Delete the old gradata and make a new one.
 */
 (void) om$send(msg = message EMSsubbs.EMssdelfrt(&rc), targetid = my_id);
 (void) om$send(msg = message EMSloopset.EMmakeFRT(&rc, my_id),
       targetid = planels);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Redraw the surface being replaced if so specified.
 */
 if( (options & EMreplace_DO_DISPLAY) &&
     (!(options & EMreplace_DONT_REDRAW)))
  {
   dpmode = GRbd;
   sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, mxtyp, mx,
           &dpmode, &env->md_id), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
if(plpts && (plpts != plptsbuf)) om$dealloc(ptr = plpts);
if(mygeom) om$dealloc(ptr = mygeom);
if(mapedges)
 {
  for(i=0; i<outlp.num_objs; i++)
   if(mapedges[i]) om$dealloc(ptr = mapedges[i]);
  om$dealloc(ptr = mapedges);
 }
if(nummapedges) om$dealloc(ptr = nummapedges);
if(outlp.objs) om$dealloc(ptr = outlp.objs);
if(edgeomptr)
 for(i=0; i<numed; i++)
  {
   if(edgeomptr[i].poles) om$dealloc(ptr = edgeomptr[i].poles);
   if(edgeomptr[i].knots) om$dealloc(ptr = edgeomptr[i].knots);
   if(edgeomptr[i].weights) om$dealloc(ptr = edgeomptr[i].weights);
  }

if(edgeomptr && (edgeomptr != edgeomptrbuf)) om$dealloc(ptr = edgeomptr);
if(edgeomptrptr && (edgeomptrptr != edgeomptrptrbuf))
  om$dealloc(ptr = edgeomptrptr);
if(edge_types && (edge_types != edge_typesbuf)) om$dealloc(ptr = edge_types);
if(cvinfo && (cvinfo != cvinfobuf)) om$dealloc(ptr = cvinfo);
/*fix for mlk */
if(myedges) om$dealloc(ptr = myedges);

if(!(1&*EMmsg&sts))
 {
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMconvert_into_plane");

  if(!IF_NULL_OBJID(planels))
   sts = om$send(msg = message Root.delete(TRUE), targetid = planels);

  sts = OM_S_SUCCESS;

  if(corrupt)
   *EMmsg = EMS_F_Fail;
  else
   *EMmsg = EMS_I_Fail;
 }
else if(*EMmsg != EMS_I_Fail) *EMmsg = EMS_S_Success;

return(sts);
}

int EFmerge_and_orient(EMmsg, in_cvptrs, numcv, plane)

IGRlong                 *EMmsg;
struct IGRbsp_curve     **in_cvptrs;    /* Array of pointers to curves */
IGRint                  numcv;          /* Number of curves */
struct IGRbsp_surface   *plane;         /* Plane geometry to be oriented */
{
  int                 ii, sts = OM_S_SUCCESS;
  struct IGRbsp_curve *cvptrs[2];
  struct IGRbsp_curve *mergedcv = NULL;
  BSrc                rc;

  cvptrs[0] = in_cvptrs[0];
  for(ii = 1; ii < numcv && (! cvptrs[0][0].phy_closed); ii ++)
  {
    cvptrs[1] = in_cvptrs[ii];

    BSmergarrcv(2, cvptrs, &mergedcv, &rc);
    if(rc != BSSUCC) { *EMmsg = EMS_E_BSerror; goto wrapup; }

    if(cvptrs[0] != in_cvptrs[0])
    {
      BSfreecv(&rc, cvptrs[0]);
      if(rc != BSSUCC) { *EMmsg = EMS_E_BSerror; goto wrapup; }
    }
    cvptrs[0] = mergedcv;
  }

  /*
   * Reverse the curve because the flow of the edges in a Ploop is
   * opposite the sense that gives the results we want.
   */
  BSrev_cv(&rc,cvptrs[0]);
  if(rc != BSSUCC) { *EMmsg = EMS_E_BSerror; goto wrapup; }

  /*
   * Re-orient the plane so that the uv axes line up.
   */
  sts = EMorient_plane(EMmsg, NULL, plane, cvptrs[0]);
  if(!(1&*EMmsg&sts)) goto wrapup;

  if(cvptrs[0] == in_cvptrs[0])
  {
    /*
     * Restore the curve because it is the input curve.
     */
    BSrev_cv(&rc,cvptrs[0]);
    if(rc != BSSUCC) { *EMmsg = EMS_E_BSerror; goto wrapup; }
  }

wrapup:
  if(cvptrs[0] != in_cvptrs[0])
  {
    BSfreecv(&rc, cvptrs[0]);
  }
  if(! (1 & *EMmsg)) sts = OM_E_ABORT;
  return sts;
}

#include "REplane.h"

extern OMuword OPP_GRowner_class_id;

from GRowner import GRget_number_components, GRget_components;
from EMSassoc import EMget_info, EMput_info;

IGRint EMconvert_into_plane(EMmsg, options, num_sfs, sfs, origedges, newedges,
                            numedges, oldls, env, chgobjid, chgosnum)
IGRlong *EMmsg;
IGRushort options;
IGRint *num_sfs;
GRobjid **sfs, ***origedges, ***newedges, **oldls;
IGRint **numedges;
struct GRmd_env *env;
GRobjid chgobjid;
GRspacenum chgosnum;
{
 IGRlong                 sts = OM_S_SUCCESS;
 IGRint                  num_comps = 0, junk, locnumsfs = 0, i;
 struct GRid            *comps = NULL, compsbuf[StaticBuf];
 struct EMSconverted_plane *new_recomp_info = NULL, *tmp = NULL;
 IGRchar                 *old_recomp_info = NULL;
 IGRuint                 info_size;

 *EMmsg = EMS_S_Success;
 if(num_sfs) *num_sfs = 0;

 if(EFisAncestryValid(EMmsg, chgobjid, chgosnum, OPP_GRowner_class_id, TRUE))
  {
   sts = om$send(msg = message GRowner.GRget_number_components
         (EMmsg, &junk), targetid = chgobjid, targetos = chgosnum,
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(junk > StaticBuf)
    comps = (struct GRid *) om$malloc(size = junk * sizeof(struct GRid));
   else comps = compsbuf;
   EMerr_hndlr(!comps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   sts = om$send(msg = message GRowner.GRget_components(EMmsg, env, comps,
         junk, &num_comps, 0, MAXINT), targetid = chgobjid,
         targetos = chgosnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   comps = compsbuf;
   comps->objid = chgobjid;
   comps->osnum = chgosnum;
   num_comps = 1;
  }


 if(sfs && !*sfs)
  {
   *sfs = (GRobjid *) om$malloc(size = num_comps * sizeof(GRobjid));
   EMerr_hndlr(!*sfs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(origedges && !*origedges)
  {
   *origedges = (GRobjid **) om$malloc(size = num_comps * sizeof(GRobjid *));
   EMerr_hndlr(!*origedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(newedges && !*newedges)
  {
   *newedges = (GRobjid **) om$malloc(size = num_comps * sizeof(GRobjid *));
   EMerr_hndlr(!*newedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 if(oldls && !*oldls)
  {
   *oldls = (GRobjid *) om$malloc(size = num_comps * sizeof(GRobjid));
   EMerr_hndlr(!*oldls, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }

 if(numedges && !*numedges)
  {
   *numedges = (IGRint *) om$malloc(size = num_comps * sizeof(IGRint));
   EMerr_hndlr(!*numedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }

 for(i=0; i<num_comps; i++)
  {
   if(EFisAncestryValid(EMmsg, comps[i].objid, comps[i].osnum,
                        OPP_EMSplane_class_id, TRUE)) continue;

   if(numedges) (*numedges)[locnumsfs] = 0;
   if(origedges) (*origedges)[locnumsfs] = NULL;
   if(newedges) (*newedges)[locnumsfs] = NULL;
   if(oldls) (*oldls)[locnumsfs] = NULL_OBJID;

   sts = om$send(msg = message EMSsubbs.EMconvert_into_plane(EMmsg, options,
         origedges ? &(*origedges)[locnumsfs] : NULL,
         newedges  ? &(*newedges)[locnumsfs] : NULL,
         oldls ? &(*oldls)[locnumsfs] : NULL,
         numedges ? &(*numedges)[locnumsfs] : NULL, env), senderid = chgobjid,
         targetid = comps[i].objid, targetos = comps[i].osnum);

   if( (1&*EMmsg&sts) && (*EMmsg == EMS_S_Success))
    {
     /* If converting an assoc surf, store EMS_ASplane_converted_plane
        as the new type. Store the original genbs type and its recomp info
        (struct EMSconverted_plane) as the recomp info of the new plane.
     */
     if(EFisAncestryValid(EMmsg, comps[i].objid, comps[i].osnum,
        OPP_EMSassoc_class_id, FALSE))
      {
       IGRuint orig_size = 0;

       if(new_recomp_info) om$dealloc(ptr = new_recomp_info);
       new_recomp_info = NULL;

       sts = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, NULL,
               &orig_size, NULL), targetid = comps[i].objid,
               targetos = comps[i].osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;

       info_size = orig_size + sizeof(struct EMSconverted_plane);
       new_recomp_info = (struct EMSconverted_plane *)
                         om$malloc(size = info_size);
       EMerr_hndlr(!new_recomp_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       tmp = new_recomp_info;
       tmp++;
       old_recomp_info = (IGRchar *) tmp;
       new_recomp_info->orig_info = old_recomp_info;
       new_recomp_info->orig_info_size = orig_size;

       sts = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL,
             &new_recomp_info->orig_type, NULL,
             &new_recomp_info->orig_info), targetid = comps[i].objid,
             targetos = comps[i].osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       sts = om$get_classname(osnum = comps[i].osnum, objid = comps[i].objid,
             classname = new_recomp_info->orig_classname);
       if(!(1&*EMmsg&sts)) goto wrapup;

       sts = om$change_class(objid = comps[i].objid, osnum = comps[i].osnum,
             classname = "EMAplane",
             sd_override = OM_K_change_class_sd_override);
       if(!(1&*EMmsg&sts)) goto wrapup;

       sts = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL,
             EMS_ASplane_converted_plane, info_size,
             (IGRchar *)new_recomp_info),
             targetid = comps[i].objid,
             targetos = comps[i].osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;

      }
     else
      sts = om$change_class(objid = comps[i].objid, osnum = comps[i].osnum,
            classname = "EMSplane",
            sd_override = OM_K_change_class_sd_override);

     /* Delete abstract buffer after changing the class.
     */
     (void) GRabsg_del_by_objid(&comps[i].objid, &comps[i].osnum);
     if(sfs) (*sfs)[locnumsfs] = comps[i].objid;
     locnumsfs++;
    }
  }

 if(num_sfs) *num_sfs = locnumsfs;

wrapup:
if(new_recomp_info) om$dealloc(ptr = new_recomp_info);
if(comps && (comps != compsbuf)) om$dealloc(ptr = comps);
return(sts);
}
end implementation EMSsubbs;
