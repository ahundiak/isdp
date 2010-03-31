class implementation EMSsffeature;

#include <stdio.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "bsdistptpts.h"
#include "nddef.h"
#include "AS_status.h"
#include "exmacros.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "OMmacros.h"
#include "dp.h"
#include "go.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMStypedef.h"
#include "OMprimitives.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsedgedef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSasfeatdef.h" 
#include "emsfeaopts.h" 
#include "emscvexten.h"  /* options for extension of profile */

/* math prototypes */
#include "bsnorvec.h" 
#include "bscvkttol2.h"
#include "bspartofcv.h"
#include "bscveval.h"

from GRcurve import EMcrvslfint;

extern OMuword OPP_EMSgencompsf_class_id;

extern IGRlong  EFcreate_rib_surfaces(), EFextend_curve_by_option();
extern IGRlong  EFcreate_inters(), EFmark_trace_intobjs();
extern IGRlong  EMintersect_surfaces();
extern IGRlong  EFdelete_selected_intobjs(), EFtrace_and_modify_groups();
extern IGRint   EMgetendpts_xyz();
extern void     EMdelintobj_selective();
extern IGRlong  EFcnvt_to_object();
extern IGRlong  EMboolean_surfaces_w_intersectio();
extern IGRlong  EFconvert_intobjs_to_objects();
extern void     EMcmpinters(), EMsfinttrace(), EMsfinttrace_free();
extern void     EMinters_data_free(), EMinters_free();
extern void     EMsfintedpar_free();
extern void     EFget_components(), EFget_lowest_components();
extern IGRlong  EFfix_self_intersection();

%safe
static void EFvalidate_data();
%endsafe



/* NOTE:
 *  1.   ALL objects created in this file will be created in the module env.
 *       of the construct list for consistency (eg. copy of input profile etc.).
 *
 *  2.   Order of parents for the rib is:
         - Profile  (EMSgrid)
         - Thickness (EMSscalar)
         - Flip thk side  (EMSscalar, boolean)  (ONLY IF NON_SYMMETRIC)
         - Flip proj side (EMSscalar, boolean)
         - Projection distance (EMSscalar, boolean). (ONLY IF FINITE)
         - Base solid/surface (EMSgrid)

    3.  It is assumed that the module environment of the base_solid is same
        as that in the construct list. (IMPT. ASSUMPTION).

  HISTORY:

  NP  : ??????   :  Creation.
  NP  : 10/19/93 :  EFmodify_profile renamed to EFextend_curve_by_option()
                    due to total re-write.
  NP  : 11/18/93 :  Modified to support "delete feature" functionality. All
                    the resulting rib surfaces are connected to a single 
                    composite surface which is the only one stored in the SSI 
                    instead of the individual rib surfaces.
  NP  : 12/14/93 :  Instead of calling EMsfinttrace for the intersctions on the
                    base solid, I now call EMintersect_surfaces, using it to do
                    trace AND refinement. This way, any intobj on the base solid
                    ending on a boundary but have a gap because of tolerance
                    problems while splitting, are corrected. Also gaps between 
                    subgroups are also fixed.
  NP :  01/04/94 :  Added call to "EFfix_self_intersections" to remove any self
                    intersections in extended profile.
  Sanjay: 12/13/94: An additional argument in EFextend_curve_by_option necessi-
                    ated the change in call.
  Aditya: 7/17/95:  Added a static fn. process_duplicates() that marks
                    oppositely oriented coincident intobjs as 
                    EMSintobj_nonoriented. One of these is flipped to make them
                    similarly oriented and they will get cleaned up during
                    duplicates processing after pre-processing. This was
                    prompted by a great number of problems caused by coincident
                    plane processing. This is an anticipatory fix. 
  Aditya: 9/7/95:   Removed call to process_duplicates() as the problem of
                    correctly setting fwd/bwd has been corrected at the
                    intersections creation level.
 */


/* indices of new surfaces created for rib */
#define TOP    0
#define LEFT   1
#define RIGHT  2
#define BOTTOM 3

#define BASE   0
#define FEASFS 1

#define MAX_STATUS_STRING 80
#define MAX_NUM_SAMPLEPTS 30
#define FIRST  0
#define SECOND 1

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

/***
#define DEBUG 1
***/

#argsused 
IGRlong EMmake_associative_rib_feature(EMmsg,
                           construct_list,
                           num_parents,
                           parent_types,
                           parents,
                           feature_recomp_data,
                           feature_id)
IGRlong                *EMmsg;
struct GRvg_construct  *construct_list;
IGRint                  num_parents;
IGRuint                *parent_types;
union  EMSparent_info  *parents;
struct EMSfeature_data *feature_recomp_data;
struct GRid            *feature_id;
{

IGRlong                 save_sts, sts_loc, sts, msg_loc;
IGRlong                 ext_options;
IGRchar                 status_str[MAX_STATUS_STRING];
IGRchar                 side[MAX_STATUS_STRING], depth[MAX_STATUS_STRING];
IGRchar                 extension[MAX_STATUS_STRING];
IGRint                  i, j, num_feasfs, parent_num, buf_size=0, num_edges=0; 
BSrc                    rc;
struct GRid		profile, cp_profile, mod_cp_profile, base_solid;
struct GRid		moved_cp_profile, moved_mod_cp_profile;
struct GRid		*feasfs=NULL, *edges, rib_compsf;
struct GRid		top_seg1, top_seg2, bottom_seg1, bottom_seg2;
struct GRmd_env		profile_env, solid_env, const_md_env;
IGRdouble               *mat, rib_thk, proj_dist, cht;
IGRdouble               dist;
IGRshort                mat_type;
IGRushort               inters_opts, undo_option, dpr_props;
GRspacenum              const_os;
IGRboolean              symmetric_rib, finite_rib, self_intersection, type2_rib;
IGRboolean              error_in_boolean, extend_profile;
IGRboolean              tracedata_alloced[2];
IGRboolean              flip_thk_side, flip_proj_side, offset_right, translate;
IGRboolean              thickness_right, redraw_this_sf, keep_this_surface;
IGRboolean              delete_cp_profile, closed_profile, status, is_composite;
struct IGRplane         profile_plane;
struct EMSintobj        *intobj_loc;
struct EMSinters        *base_inters=NULL, *feasfs_inters=NULL, *inters_loc;
struct EMSsftracedata   *tracedata, *feasfs_tracedata, base_tracedata;
IGRpoint                profile_plane_pt;
IGRpoint                left_offset_endpts_top[2], right_offset_endpts_top[2];
IGRpoint                left_offset_endpts_bottom[2];
IGRpoint                right_offset_endpts_bottom[2];
IGRpoint                top_seg1_pts[2],top_seg2_pts[2];
IGRpoint                bottom_seg1_pts[2],bottom_seg2_pts[2];
IGRvector               profile_plane_normal, rev_profile_plane_normal;
struct GRprops          props;
OM_S_CHANSELECT         to_components;
GRobjid                 *dispsfs=NULL;
enum GRdpmode           dpmode;
struct GRmd_env         dp_env, nret;
IGRint                  num_caps=0, dpenv_size,index;
IGRint                  num_dispsfs, num_ribsfs, num_comps; 
GRobjid                 *ribsfs=NULL, *comps=NULL;
IGRboolean              save_pathway_trim, save_pathway_orient;

  sts    = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_Fail, wrapup);


  /* get the env of the profile (FIRST parent)*/
  OM_BLOCK_MOVE(&(parents[0].grobj.env), &profile_env, 
                           sizeof(struct GRmd_env));

  /* get the env of the base solid (LAST parent)*/
  OM_BLOCK_MOVE(&(parents[num_parents-1].grobj.env), &solid_env, 
                           sizeof(struct GRmd_env));

  /* store the env of the construct list, for new objects */
  OM_BLOCK_MOVE(construct_list->env_info, &const_md_env, 
                           sizeof(struct GRmd_env));

  mat      = const_md_env.md_env.matrix;
  mat_type = const_md_env.md_env.matrix_type;
  const_os = const_md_env.md_id.osnum;

   finite_rib     = feature_recomp_data->attributes & EMSfeature_finite;
   symmetric_rib  = feature_recomp_data->attributes & EMSfeature_symmetric;
   type2_rib      = feature_recomp_data->attributes & 
                            EMSfeature_thickness_in_profile_plane;
   extend_profile = feature_recomp_data->attributes &
                            EMSfeature_profile_extend;
   closed_profile = FALSE; /*assume at start*/ 


   /* INITIALIZE - IMPORTANT - CHECKED AT WRAPUP */

   tracedata_alloced[BASE]    = FALSE;
   tracedata_alloced[FEASFS]  = FALSE;
   rib_compsf.objid           = NULL_OBJID;
   rib_compsf.osnum           = const_os;
   cp_profile.objid           = NULL_OBJID; 
   cp_profile.osnum           = const_os;
   delete_cp_profile          = TRUE;
   moved_cp_profile.objid     = NULL_OBJID; 
   moved_cp_profile.osnum     = const_os; 
   mod_cp_profile.objid       = NULL_OBJID; 
   mod_cp_profile.osnum       = const_os;
   moved_mod_cp_profile.objid = NULL_OBJID; 
   moved_mod_cp_profile.osnum = const_os; 
   top_seg1.objid             = NULL_OBJID;
   top_seg1.osnum             = const_os;
   bottom_seg1.objid          = NULL_OBJID;
   bottom_seg1.osnum          = const_os;
   top_seg2.objid             = NULL_OBJID;
   top_seg2.osnum             = const_os;
   bottom_seg2.objid          = NULL_OBJID;
   bottom_seg2.osnum          = const_os;

   feasfs                     = NULL;
   feasfs_inters              = NULL;
   base_inters                = NULL;
   num_feasfs                 = 0;
   num_edges                  = 0;
   edges                      = NULL;
   num_caps                   = 0; /* IMPT */
   ribsfs                     = NULL;
   num_ribsfs                 = 0;
   dispsfs                    = NULL;
   comps                      = NULL;
   num_comps                  = 0;

   /* Get teh display info for display of surfaces later */
   dpenv_size = sizeof(struct GRmd_env);

   gr$get_display_env(msg = &msg_loc,
                        sizbuf = &dpenv_size,
                        buffer = &dp_env,
                        nret = &nret);
   EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /* GET ALL THE PARENTS */
   parent_num = 0;

   OM_BLOCK_MOVE(&(parents[parent_num++].grobj.grid), &profile, 
              sizeof(struct GRid));

   rib_thk = parents[parent_num++].value;

   if (!symmetric_rib)
   {  flip_thk_side = (parents[parent_num++].value == 0.0? FALSE : TRUE);
      ex$message (buff = side, msgnumb = EMS_S_OneSided);
   }
   else
   {  ex$message (buff = side, msgnumb = EMS_S_Symmetric);
      flip_thk_side = FALSE; 
   }

   flip_proj_side = (parents[parent_num++].value == 0.0? FALSE:TRUE);

   if (finite_rib)
   { proj_dist = parents[parent_num++].value;
     ex$message (buff = depth, msgnumb = EMS_S_Finite);
   }
   else
   { ex$message (buff = depth, msgnumb = EMS_S_ToNext);
   }

   OM_BLOCK_MOVE(&(parents[parent_num++].grobj.grid), &base_solid,
              sizeof(struct GRid));

   /* They better be the same */
   EMerr_hndlr (parent_num != num_parents, *EMmsg, EMS_E_InvalidArg, wrapup); 


  /* get the current chord height tolerance (used for tracing)*/
  BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht); 

  

  /* DO SOME SANITY CHECKS HERE */


  /* allocate stack memory for plane point and normal */
  profile_plane.point = (IGRdouble *)profile_plane_pt;
  profile_plane.normal= (IGRdouble *)profile_plane_normal;

  /* get the profile/curve plane normal using GRdetplane. The whole feature code
   * is based upon the fact that there is a CONSISTENT (non-flipping) normal
   * to the profile plane. This can be guaranteed ONLY if features are created
   * from profiles. If features are created using non-profile curves, then the
   * normal of the curve plane has an equal chance of going on either side
   * of the plane during recompute.
   */
  sts = om$send (msg = message GRvg.GRdetplane (
                              &msg_loc,
                              &(profile_env.md_env.matrix_type),
                              profile_env.md_env.matrix,
                              &profile_plane),
                 senderid = NULL_OBJID,
                 targetid = profile.objid,
                 targetos = profile.osnum);
    EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *EMmsg, EMS_E_Fail, wrapup);

  /*normalize the plane normal*/
  status = BSnorvec(&rc,(IGRdouble *)profile_plane_normal);
  EMerr_hndlr (!status || (rc != BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);

  /* send GRgeomprops message to the profile to find out if it is 
   * CLOSED or OPEN. Extension (even if asked for, will be done ONLY on OPEN
   * profiles).
   */

  sts = om$send (msg = message GRvg.GRgeomprops(&msg_loc, 
                                          &mat_type, mat, &props),
                senderid = NULL_OBJID, 
                targetid = profile.objid, 
                targetos = profile.osnum); 
  EMerr_hndlr (!(1&sts) || (msg_loc!=MSSUCC), *EMmsg, EMS_E_Fail, wrapup);

  closed_profile = props.phy_closed;  /* closed profiles won't be extended */

  /* make a copy of the profile, which will be used henceforth */
  cp_profile.osnum = const_os;
  sts = om$send (msg = message GRgraphics.GRcopy(
                                           &msg_loc,
                                           &profile_env,
                                           &const_md_env,
                                           &(cp_profile.objid)),
                 senderid = NULL_OBJID,
                 targetid = profile.objid,
                 targetos = profile.osnum);
                              
  EMerr_hndlr (!(1&sts) || (msg_loc!=MSSUCC), *EMmsg, EMS_E_Fail, wrapup);

  if (extend_profile && !closed_profile)
  {
    ex$message (buff = extension, msgnumb = EMS_S_Extend);
    /* extend linear segments to bounding box and arcs polynomially (not 
     * necessarily to bounding box) by a fixed distance/angle.
     */
    ext_options   = EMS_EXT_TO_BOUNDING_BOX | EMS_EXT_POLYNOMIAL;
    self_intersection=FALSE;
  
    /* modify (extend) the copy of the original profile */
    sts = EFextend_curve_by_option(&msg_loc, &cp_profile, &const_md_env, 
                           ext_options, FALSE, NULL, NULL, NULL,
                           &base_solid, &solid_env, &self_intersection, 
                           construct_list, &mod_cp_profile);
    EMerr_hndlr(!(1&sts&msg_loc),*EMmsg,EMS_E_Fail,wrapup);

    if (self_intersection)
    {
       
       EFfix_self_intersection (&msg_loc, &mod_cp_profile, &const_md_env, 
                                 &base_solid, construct_list);
       EMerr_hndlr(!(1&sts&msg_loc),*EMmsg,EMS_E_Fail,wrapup);

    }

  }/*if*/
 else   /* NO extend || closed_profile */
 {
    ex$message (buff = extension, msgnumb = EMS_S_NoExtend);
    mod_cp_profile.objid = cp_profile.objid;
    mod_cp_profile.osnum = cp_profile.osnum;
    /* ideally we should set "cp_profile.objid" to NULL_OBJID here, since it
     * being "consumed" by "mod_cp_profile". However, we need to use it ONE more
     * time, in marking the trace intobjs. Therefore, we set a boolean flag,
     * instead.
     */
     delete_cp_profile = FALSE;
 }
  


  /* Display message about type of rib being placed */
  ex$message(buff = status_str, msgnumb = EMS_S_PlacingRib, type = "%s%s%s", 
             var = `side, depth, extension`);
  strcat (status_str, " ");
  UI_status (status_str);

 /* create the rib surfaces */

 if (!type2_rib)
 {   
     sts = EFcreate_type1_rib_surfaces(
               &msg_loc,
               NULL,
               construct_list,
               &mod_cp_profile, /* id of comp.cv.(extended profile) of rib */
               &const_md_env,
               profile_plane_normal, /* normal to plane of profile */
               symmetric_rib, 
               extend_profile, 
               flip_thk_side,
               flip_proj_side,
               rib_thk, /* i.e. thickness of rib */
               finite_rib ? &proj_dist : NULL, /* projection dist */
               &base_solid, /* id of base solid */
               &num_feasfs,
               &feasfs); 

     EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
     sts = EFcreate_type2_rib_surfaces(
               &msg_loc,
               NULL,
               construct_list,
               &mod_cp_profile, /* id of comp.cv.(extended prof.) */
               &const_md_env, /* modenv of comp.cv(extended prof.)*/
               profile_plane_normal, /* normal to plane of curve */
               symmetric_rib,
               extend_profile,
               closed_profile,
               flip_thk_side,
               flip_proj_side, 
               rib_thk, /* i.e. thickness of web */
               finite_rib ? &proj_dist : NULL, /* for finite rib*/
               &base_solid, /* id of parent solid */
               &num_feasfs,
               &feasfs,
               &num_caps); 
     EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 }

  strcat (status_str, ".");
  UI_status(status_str);
 

 /* create the inters lists between surfaces and base solid. */

  /* If "num_caps" is non-zero, it means that we have a case of a type 2
   * no-extend rib. In this case, we have a SINGLE composite surface for the 
   * rib. If this is not the case, error out. The caps will be unlinked inside
   * the "EFcreate_inters" function, IMMEDIATELY AFTER performing intersections
   *  with the base solid. Then, the remaining composite and the end cap(s) will
   * be intersected with one another and from that point onwards, we pretend as
   * if there had never been any caps. This whole effort is aimed at retaining 
   * intersections on the CORRECT rib surface in coplanar adjacency cases, which
   * REQUIRES that common-edges exist between rib surfaces so that intersections
   * can be pushed across to the correct surfaces wherever necessary.
   */

  /* status string is updated INSIDE this function */ 
  sts =  EFcreate_inters(&msg_loc, &base_solid, &solid_env, &feasfs, 
                         &num_feasfs, num_caps, construct_list, NULL, 
                         &base_inters, &feasfs_inters, status_str); 
  EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


 /* At this point, check if the "base_inters" list is NULL and the option is
  * "no-extend profile. This means that the secondary surfaces are totally 
  * disjoint from the base solid. There is no way out but to wrapup!!!!.
  */
  EMerr_hndlr (!extend_profile && !base_inters, *EMmsg, EMS_E_Fail, wrapup);

  /* Identify those pieces of the modified profile that lie OUTSIDE the base 
   * solid. Look for those OUT pieces that overlap the ORIGINAL profile. This
   * is important, because the modified profile is extended to the bounding box,
   * and there will be OUT pieces that we are NOT interested in. Those intobjs 
   * on the feature surfaces that exactly match the final OUT pieces, will need
   * to be specially marked, so that they may start the trace on the side and 
   * top surfaces (to ensure closure of trace groups). We do this twice, so that
   * intobjs on the left and right side surfaces (basically either side of 
   * thickness of the rib) and their corresponding "other intobjs" on the may
   * get marked accordingly. If this is a finite depth rib, then we also handle
   * the marking of the bottom intobjs.
   */


  /* calc. the vector opposite to profile plane normal */
  for (i=0; i<3; i++)
    rev_profile_plane_normal[i] = -profile_plane_normal[i];

  /* We translate (rib type 1) or offset (rib type 2) the profile (and its 
   * extended copy) to its right and left. The offset/translated extended 
   * profiles are then intersected with the base solid, and in conjunction with
   * the offset/translated (unextended) profile we determine the segments that
   * are OUT of the base solid. Those intobjs on the side surfaces whose 
   * XYZ geometries match with the OUT segments get marked as "EMSintobj_marked"
   * and will act as start intobjs for tracing on these surfaces to enable us 
   * to get closed groups.
   */
 
  /* this tells us which side the thickness is from the profile. */
  thickness_right = !flip_thk_side;

  /* i==0 is for LEFT offset and i==1 for RIGHT . "LEFT" side for type 1 rib
   * is side OPPOSITE to profile plane normal, and "LEFT" side for type 2 rib
   * is side OPPOSITE to TxN.
   */
  for (i=0; i<2; i++)
  {

     dist         = symmetric_rib ? (rib_thk/2.0) : 
                                    (i==0 ? (thickness_right? 0.0 : rib_thk) : 
                                            (thickness_right? rib_thk : 0.0));
     offset_right = (i==0?FALSE:TRUE);
     translate    = type2_rib ? FALSE : TRUE;
 
     sts = EFmark_trace_intobjs (
              &msg_loc, construct_list, feasfs_inters, &const_md_env, 
              EMSintobj_tmpmarked, NULL, EMSintobj_marked, NULL, 
              &cp_profile, &const_md_env, 
                 finite_rib? &moved_cp_profile:NULL, 
                 extend_profile? NULL : 
                     (i==0?left_offset_endpts_top:right_offset_endpts_top), 
              &mod_cp_profile, &const_md_env, 
                 finite_rib? &moved_mod_cp_profile : NULL, 
              NULL, /*dont need endpts of offset of extended profile*/
              type2_rib?profile_plane_normal :
                      (i==0? rev_profile_plane_normal: profile_plane_normal),
              &dist,
              &translate, 
              type2_rib ? &offset_right : NULL, 
              &base_solid, &solid_env);
     EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     /* if the rib is finite, then the profiles have to be translated/offset
      * to the bottom surface too, so that overlapping intobjs may be marked.
      * ("type_1" ribs have to be offset and "type_2" ribs translated).
      */
     if (finite_rib)
     {
        offset_right = !flip_proj_side;
        translate    = type2_rib ? TRUE : FALSE;

        sts = EFmark_trace_intobjs (&msg_loc, construct_list, feasfs_inters, 
                 &const_md_env, EMSintobj_tmpmarked, NULL, 
                 EMSintobj_marked, NULL, &moved_cp_profile, 
                 &const_md_env, NULL, 
                 extend_profile? NULL :
                    (i==0?left_offset_endpts_bottom:right_offset_endpts_bottom),
                 &moved_mod_cp_profile, 
                 &const_md_env, NULL, 
                 NULL, /*dont need endpts of offset of extended profile*/
                 (type2_rib? (flip_proj_side?
                               rev_profile_plane_normal:profile_plane_normal)
                           : profile_plane_normal),
                 &proj_dist, 
                 &translate,
                 type2_rib ? NULL : &offset_right,
                 &base_solid, &solid_env);
        EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        /* delete the two moved profiles. */
        sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,&const_md_env),
                 senderid = NULL_OBJID,
                 targetid = moved_cp_profile.objid,
                 targetos = moved_cp_profile.osnum);
        EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   
        moved_cp_profile.objid = NULL_OBJID;
   
        sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,&const_md_env),
                 senderid = NULL_OBJID,
                 targetid = moved_mod_cp_profile.objid,
                 targetos = moved_mod_cp_profile.osnum);
        EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   
        moved_mod_cp_profile.objid = NULL_OBJID;
     }
  }/*for*/


  /* if this is a no-extend non-closed profile, then we have (for type 2 ribs) 
   * a closed composite surface of projection or (for type 1 ribs) two extra 
   * end-planes. The marking above has taken care of marking intobjs on surface
   * to the LEFT and RIGHT of the profile, but NOT on the END surfaces which 
   * exist (as part of the single composite side surface for type 2 ribs, or as 
   * the two extra end planes for type 1 ribs) for no-extend type ribs. 
   * Therefore, we repeat the above for loop, this time just for marking 
   * intobjs on the END surfaces.
   *     Again, as noted above, this is to be done only for non-closed no-extend
   * profiles. If the profile is closed (as for a type 2 rib), then by 
   * offsetting the closed profile, we have already marked all intobjs that need
   * marking. But in the case of non-closed profiles, we have marked intobjs 
   * above only by offsetting the open profiles and the intobjs on the ends 
   * are stillto be marked.
   */

  /* NOTE: We support the no-extend case in a very limied fashion for 
   * ----  type1_ribs, i.e. those profiles whose both endpts already lie on 
   *       edges of the solid such that closed intersection groups will be 
   *       formed with the solid. This is limited because we do not know in
   *       what direction the material addition (or projection)vector is and
   *       therefore are at a loss to extend the profile internally in order to
   *       create closed intersections. If the profile endpts already lie on the
   *       surface, there is a good chance that such closed groups will be
   *       formed. The "if" block below assumes that there are END surfaces on
   *       which "markable" intobjs exist. But, in our limited support case for
   *       type 1 ribs, we do not create END surfaces, and therfore, bypass 
   *       the "if" block.

  /* ONLY for type2 rib */
  if (!extend_profile && !closed_profile && type2_rib)
  { 

    /* create the two end-segments using end-pt info generated from the
     * previous for loop.
     */ 

     /* seg 1 */
     OM_BLOCK_MOVE(left_offset_endpts_top[0],top_seg1_pts[0],sizeof(IGRpoint));
     OM_BLOCK_MOVE(right_offset_endpts_top[0],top_seg1_pts[1],sizeof(IGRpoint));
     GRcreate_curve_by_option(&msg_loc, &const_md_env, 0, NULL, 2,
          (IGRdouble *)top_seg1_pts, NULL, NULL, 2, FALSE, NULL, NULL, 
           &top_seg1, NULL, 0);
     EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     /* seg 2 */
     OM_BLOCK_MOVE(left_offset_endpts_top[1],top_seg2_pts[0],sizeof(IGRpoint));
     OM_BLOCK_MOVE(right_offset_endpts_top[1],top_seg2_pts[1],sizeof(IGRpoint));
     GRcreate_curve_by_option(&msg_loc, &const_md_env, 0, NULL, 2,
          (IGRdouble *)top_seg2_pts, NULL, NULL, 2, FALSE, NULL, NULL, 
           &top_seg2, NULL, 0);
     EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


     if (finite_rib)
     { 
       /* seg 1 */
       OM_BLOCK_MOVE(left_offset_endpts_bottom[0],bottom_seg1_pts[0],
                     sizeof(IGRpoint));
       OM_BLOCK_MOVE(right_offset_endpts_bottom[0],bottom_seg1_pts[1],
                     sizeof(IGRpoint));
       GRcreate_curve_by_option(&msg_loc, &const_md_env, 0, NULL, 2,
            (IGRdouble *)bottom_seg1_pts, NULL, NULL, 2, FALSE, NULL, NULL, 
             &bottom_seg1, NULL, 0);
       EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  
       /* seg 2 */
       OM_BLOCK_MOVE(left_offset_endpts_bottom[1],bottom_seg2_pts[0],
                     sizeof(IGRpoint));
       OM_BLOCK_MOVE(right_offset_endpts_bottom[1],bottom_seg2_pts[1],
                     sizeof(IGRpoint));
       GRcreate_curve_by_option(&msg_loc, &const_md_env, 0, NULL, 2,
            (IGRdouble *)bottom_seg2_pts, NULL, NULL, 2, FALSE, NULL, NULL, 
             &bottom_seg2, NULL, 0);
       EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  
    }
 
    for (i=0; i<2; i++)
    {
  
       /* mark intobjs that correspond to OUT segments (w.r.t. base solid) of
        * "top_seg1, top_seg2, bottom_seg1, bottom_seg2".
        */
       sts = EFmark_trace_intobjs (
                &msg_loc, construct_list, feasfs_inters, &const_md_env, 
                EMSintobj_tmpmarked, NULL, EMSintobj_marked, NULL, 
                NULL, NULL, NULL, NULL, 
                (i==0?&top_seg1:&top_seg2), &const_md_env, NULL, NULL,
                NULL, NULL, NULL, NULL, &base_solid, &solid_env);
       EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  
       if (finite_rib)
       {
          sts = EFmark_trace_intobjs (
                   &msg_loc, construct_list, feasfs_inters, &const_md_env, 
                   EMSintobj_tmpmarked, NULL, EMSintobj_marked, NULL, 
                   NULL, NULL, NULL, NULL,
                   (i==0?&bottom_seg1:&bottom_seg2), &const_md_env, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   &base_solid, &solid_env);
          EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  
       }
    }/*for*/

     /* the "top_seg1, top_seg2, bottom_seg1 & bottom_seg2" objects are deleted
      * at wrapup.
      */
  }

  /* Marking of trace intobjs is now complete */
   strcat(status_str, ".");
   UI_status (status_str);
  
  /* Delete unneeded intobjs. At this point, those intobjs that HAVE the
   * "EMSintobj_tmpmarked" bit set and DO NOT HAVE the "EMSintobj_marked" bit
   * set, can be safely deleted.  i.e. we are saying that THOSE intersections
   * on THIS feature surface that came from ANOTHER feature surface, BUT, do
   * NOT match with any OUT segment (of the extended profile) that we are
   * intersested in, can be DELETED.
   *
   * In case we have coplanar intersections between a rib surface and a surface
   * of the base solid, it is likely that some of the deleteble intobjs above
   * MAY have a duplicate which is due to a surface of the base solid (which 
   * means it [the duplicate] will have neither the "marked" or "tmpmarked" 
   * bits set). We make an attempt to delete such duplicates too.
   */

  sts =  EMfixsfintout (&msg_loc, &feasfs_inters, &const_md_env, NULL, NULL,
                       NULL, 3, EMSintobj_tmpmarked, EMSintobj_marked,
                       NULL, EMSintobj_marked|EMSintobj_tmpmarked,
                       chk_dupsamesurf, 
                       EMSfixsfint_act_delmarked | EMSfixsfint_act_delunmarked,
                       NULL, NULL);
  EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


   /* If a rib surf exists that doesn't have any intobj generated
    * from another rib surface it will not exist in the final model
    * and can be deleted.
    */
 {
   IGRboolean deletable_surf = TRUE;
   struct EMSinters *prev_inter;

   prev_inter = inters_loc = feasfs_inters;
   while (inters_loc && prev_inter)
   { 
     deletable_surf = TRUE;
     intobj_loc = inters_loc->cvs;
     while (intobj_loc)
     {
       if(intobj_loc->props&EMSintobj_tmpmarked ||
          intobj_loc->props&EMSintobj_marked)
       {
          deletable_surf = FALSE;
          if(prev_inter != inters_loc)/** If this is the 1st inters node **/
                prev_inter = prev_inter->next;
          break;
       }
       intobj_loc = intobj_loc->next;
     }

     if(deletable_surf)
     {
       if(prev_inter == inters_loc) /** If this is the 1st inters node **/
           feasfs_inters = inters_loc->next;
       else
       {
           prev_inter->next = inters_loc->next;
           inters_loc->next = NULL;
       }
       EMdelintobj_selective(&msg_loc, NULL, inters_loc, NULL, NULL);
       inters_loc = prev_inter->next;
       EMcmpinters(&msg_loc, inters_loc);
     }
     else inters_loc = inters_loc->next;
   }
 }

  /* If a deletable intobj did NOT have duplicates, it did not get deleted
   * above. So make sure it gets deleted by making the next call.
   */

  EMdelintobj_selective(&msg_loc, NULL, feasfs_inters, EMSintobj_tmpmarked, 
                        EMSintobj_marked);
  EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /* Next step is to clean up the intersection list so that we may keep only
   * the needed intobjs. 
   * 
   * 1. Trace the secondary surfaces (all newly created surfaces) one by one,
   *    separately. This way, we prevent trace from jumping between the 
   *    TOP, LEFT, RIGHT surfaces etc. This is necessary, because we have 
   *    intobjs that will BECOME edges between the TOP & LEFT, TOP & RIGHT 
   *    surfaces etc, but are right now "other_intobjs" of each other in the
   *    inters lists.
   * 2. Keep only the closed groups and delete all open groups.
   * 3. Do a selective intersection deletion, based on the same philosophy
   *    as the selective boolean, except, we use marked intobjs and not 
   *    sort points in identifying trace groups to be retained.
   * 4. Compress the inters list, as due to the deletion of intobjs, we may be
   *    left with empty inters nodes.
   * 5. Trace the intersections on the base solid with the remaining 
   *    intersections.
   */

  /* Do a trace on TOP, LEFT, RIGHT and BOTTOM (composite) surfaces separately,
   * so that closed groups on EACH are obtained. Those closed groups that
   * have intobjs marked as needed (EMSintobj_marked) will be reatined, along
   * with those groups that they enclose topologically. 
   */

  tracedata_alloced[FEASFS] = FALSE;
  feasfs_tracedata  = NULL; /* IMPORTANT */

  sts = EFtrace_and_modify_groups(&msg_loc, num_feasfs, feasfs, &feasfs_inters, 
          &solid_env, construct_list, EMSintobj_marked, NULL, NULL, NULL, 
          &feasfs_tracedata); 
  EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /* if there is an error in above function, then "feasfs_tracedata" has 
   * already been freed inside the function. Else we need to free it later.
   */
  tracedata_alloced[FEASFS] = TRUE;


  /*Compress both inters lists if necessary. This should have NO effect on the
   * traced data above, for the feature surfaces.
   */
  for (i=0; i<2; i++)
  {
    EMcmpinters (&msg_loc, (i==BASE? &base_inters : &feasfs_inters));

    /* make sure the inters list does not get completely wiped out */
    EMerr_hndlr (!(1&msg_loc) || (i==BASE?!base_inters:!feasfs_inters), 
                   *EMmsg, EMS_E_Fail, wrapup);
  }


  /* Sometimes, the fwd/bwd pointers are completely incorrect, pointing at wrong
   * intobjs and also, fwd/bwd properties are wrong. This might be due to the
   * fact that we do intersecting in stages with the rib surfaces.  Since trace
   * WILL do the correct thing if the fwd/bwd pointers are not present, but
   * CAN go wrong if they are present (it believes the pointers), we choose to
   * take the most stable path and unset all such pointers here, for the bae
   * inters list.
   */

   inters_loc = base_inters;
   while (inters_loc)
   { intobj_loc = inters_loc->cvs;
     while (intobj_loc)
     { intobj_loc->props &= ~(EMSintobj_fwd_noconnectuv |
                              EMSintobj_bwd_noconnectuv |
                              EMSintobj_fwd_connectuv   |
                              EMSintobj_bwd_connectuv);
       intobj_loc->fwd = NULL;
       intobj_loc->bwd = NULL;
       intobj_loc = intobj_loc->next;
     }
     inters_loc = inters_loc->next;
   }

  /* Trace the intersections on the base solid. The intersections on the feature
   * surfaces have already been traced above. Even more important, refinement
   * on the traced data is to be done. Both can be accomplished by a single call
   * to "EMintersect_surfaces". When intersections are split on the feature 
   * surfaces, we make sure that the four endptoints of the split intobjs meet 
   * at the SAME uv value, by modifying ends as necessary. However, for a pair
   * of intobj being split on the rib surface, their "other" intobjs are on 
   * DIFFERENT surfaces of the base solid. Therefore, if there are two intobjs
   * crossing each other on the base solid, they are split by DIFFERENT calls to
   * the "split_intobj" function. Therefore, at no time is it known that these
   * four split points on the base solid are supposed to be the SAME (unless we
   * keep huge arrays of corresponding intobjs etc, which becomes a nightmare).
   * To remedy this situation, we call refinement after the trace, which will 
   * extend intobj ends (that lie on the boundary) as necessary and avoid 
   * contiguous intobjs being put into separate subgroups due to tolerance 
   * problems. Also, due to the inherent tolerance problems associated with 
   * splitting intobjs, it will be safer to use chord height tolerance for 
   * tracing, which option we also set below.
   */
   tracedata_alloced[BASE] = FALSE;

   save_pathway_trim = _pathway_trim;
   save_pathway_orient = _pathway_orient;
   _pathway_trim = 0;
   _pathway_orient = 0;
   
   inters_opts = EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING | 
                 EMS_SFINT_MUSTCLOSE | EMS_SFINT_MUSTORIENT |
                 EMS_SFINT_CHTTRACETOL;
   sts = EMintersect_surfaces (&msg_loc, NULL, &(solid_env.md_env), 0, NULL,
                   NULL,
                   inters_opts,
                   NULL, /*world_opt needed only if !EMS_SFINT_SKIPSFINT*/
                   NULL, /*param_opt needed only if !EMS_SFINT_SKIPSFINT*/
                   NULL, /*trim_opt not needed also */
                   construct_list, NULL, &base_inters, NULL,
                   &base_tracedata, NULL, NULL, NULL, status_str);

    _pathway_trim = save_pathway_trim;
    _pathway_orient = save_pathway_orient;

    EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, msg_loc, wrapup);

    tracedata_alloced[BASE] = TRUE;


/* Before the boolean is finally completed, make SURE that there will be NO
 * stitchable edges left after the operation. This may happen if the intobjs 
 * were incorrectly connected during split, or if intobjs are incorrectly 
 * oriented on the surface.
 */

 EFvalidate_data(&msg_loc, &const_md_env, base_inters,   &base_tracedata, 
                    feasfs_inters);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EFvalidate_data(&msg_loc, &const_md_env, feasfs_inters, feasfs_tracedata, 
                    base_inters);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);



/* Make a composite surface out of all the feature surfaces. The boolean DPR
 * state should have only TWO objects connected on the components channel. 
 * Therefore the rib surfaces are all joined to form a new composite surface.
 * We can even send in an array of rib surfaces and the boolean will still work
 * fine, but if we then want to pick all the feature surfaces simultaneously 
 * (such as when we want to do a delete feature) we will NOT be able to do that
 * UNLESS all the secondary rib surfaces are connected to a single composite 
 * surface.
 */

 construct_list->geometry = NULL;
 sts = om$construct (classid = OPP_EMSgencompsf_class_id,
             p_objid = &rib_compsf.objid,
             msg = message GRgraphics.GRconstruct (construct_list));
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 rib_compsf.osnum = const_os;

 /* Now we have to be very careful while creating the composite. We need to 
  * connect to it ONLY those surfaces that have intersections. The "feasfs" 
  * array contains logical surfaces (top, left, right, bottom etc.).  We check
  * to see if any of these are completely devoid of intersections. If so, we do
  * NOT connect it to the composite. It does not matter if SOME surfaces in a 
  * composite do not have intersections. It is the case of ALL surfaces in a 
  * composite NOT having intersections that is important to trap. What will 
  * happen if we DO send such a surface in, you may ask. And I would answer as
  * follows: Let us assume that the "bottom" surface in the rib (obviously a 
  * finite rib) was completely inside the volume of the base solid and hence had
  * all its intersections removed. Let us assume we nonetheless connect it to 
  * the rib composite surface. Now, within the boolean, there is a "cleanup" 
  * algorithm that removes those surfaces from the incoming composite that have
  * no intersctions. It does this by starting with surfaces that HAVE 
  * intersections and then propagating across the edges that are removed from 
  * those surfaces. Obviously, there is NO way to get to this "bottom" surface,
  * since it is NOT common-edge connected to ANY of the other logical surfaces
  * of the rib. Hence it remains as part of the new rib feature, even though it
  * is completely IN volume, and hence creates an invalid solid.  On the other 
  * hand, even if it had ONE intersection on ANY of its component surfaces, the
  * cleanup code could propogate to the OTHER surfaces that had to be removed 
  * and do the right thing. Kind of a long winded answer, but I hope it answers
  * your question.
  */

  for (i=0; i<2; i++)
  {
    EMcmpinters (&msg_loc, (i==BASE? &base_inters : &feasfs_inters));
    EMerr_hndlr (!(1&msg_loc) || (i==BASE?!base_inters:!feasfs_inters), 
                   *EMmsg, EMS_E_Fail, wrapup);
  }

 index=0;  /* used as channel index for rigid connect */
 for (i=0; i<num_feasfs; i++)
 {

   /* Check if this (possibly composite) surface has any intersections. To do
    * that we would have to get ALL its lowermost components, if it is a 
    * composite surface.
    */
    comps = NULL;
    num_comps = 0;
    (void) EFget_lowest_components(&msg_loc, &(feasfs[i]), &num_comps, &comps,
                                &is_composite, NULL, NULL);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
    /* Since we have compressed the inters node once again above, there should 
     * be NO nodes with zero intobjs. Therefore, presence of an inters node for
     * a surface is a guarantee that there ARE intersections on that surface.
     */

    keep_this_surface = FALSE;
    inters_loc = feasfs_inters;
    while (inters_loc && !keep_this_surface)
    {
      for (j=0; j<num_comps; j++)
      {
        if (inters_loc->this_obj.objid == comps[j])
        {  keep_this_surface = TRUE;
           break; 
        } 
      }
      inters_loc = inters_loc->next; 
    }

    if (keep_this_surface)
    {
      sts = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                 &rib_compsf, ( IGRlong * ) (&index)),
                 senderid = NULL_OBJID,
                 targetos = feasfs[i].osnum,
                 targetid = feasfs[i].objid);
      EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup);
      index++;
    }
    else
    {

      sts = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                                                &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = feasfs[i].objid,
                    targetos = feasfs[i].osnum);
      EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, wrapup);
    }

    if (comps)
      {om$dealloc(ptr=comps); comps = NULL;}
 }

  /* Tracing on base and rib surfaces is done and rib composite created */
  strcat(status_str, ".");
  UI_status (status_str);

 /*
  * Perform boolean operation between the base solid and the newly created 
  * rib composite surface. Do the erase of affected surfaces, but dont do the 
  * redraw, because if there is an error in the function call, the rib surfaces
  * stay unecessarily displayed, until the user clears the screen.
  */

 num_dispsfs=0;
 dispsfs=NULL;
 sts = EMboolean_surfaces_w_intersection (&msg_loc, feature_id, EMSbool_union,
             &const_md_env, base_solid.objid, 1, &(rib_compsf.objid),
             base_inters, feasfs_inters,
             &base_tracedata, feasfs_tracedata,
             NULL, NULL, EMSsfbool_opt_display|EMSsfbool_opt_noredraw, 
             &num_dispsfs, &dispsfs, NULL);

  error_in_boolean = (!(1&sts&msg_loc)) ? TRUE : FALSE;

  if ( error_in_boolean)
     save_sts = sts;

  /* Boolean is complete (but may still need to be undone,in case of 
   * stitchable edges)
   */
  strcat(status_str, ".");
  UI_status (status_str);

 if (!error_in_boolean)
 {  /* Make sure NO corruption has occurred by checking for stitchable edges.*/

    buf_size=0;
    num_edges=0;
    edges=NULL;
    sts = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
                           EMS_OPT_CONNECTABLE, &edges, &buf_size, &num_edges,
                           NULL, NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = feature_id->objid,
                        targetos = feature_id->osnum);
    EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   
    if (num_edges)
    {
       #ifdef DEBUG
       printf("\nERROR:  %d stitchable edges...\n", num_edges);
       #endif
   
       error_in_boolean = TRUE;
       save_sts = OM_E_ERROR;
       *EMmsg = EMS_E_Fail; /* Set failure code */
   
   
      undo_option = EMS_UNDO_DELETE | EMS_UNDO_DONTDELME | EMS_DONT_REDRAW;
   
      sts = om$send(msg = message EMSdpr.EMget_dpr_props(&msg_loc,
                               &dpr_props),
                         senderid = NULL_OBJID,
                         targetid = feature_id->objid,
                         targetos = feature_id->osnum);
      EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   
      if (dpr_props & EMS_UNEVAL_STATE)  /*check if recompute*/
         undo_option |= (EMS_UNDO_DONTCLEANOWN | EMS_UNDO_DONTDISCONCOMPS);

      sts = om$send (msg = message EMSdpr.EMundo (&msg_loc, &undo_option,
                     &const_md_env, NULL, NULL, NULL, NULL, NULL, NULL),
                 targetid = feature_id->objid,
                 targetos = feature_id->osnum,
                 senderid = NULL_OBJID);
      EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  
    }

  }
  else
  {   save_sts = sts;
      *EMmsg = EMS_E_Fail;
  } 

 /* If the boolean succeeded, then redraw ALL the affected surfaces, else redraw
  * only the surfaces from the base solid. First step is to get all the lower-
  * most surface ids (i.e. non-composite surfaces) in the rib composite.
  */

 (void) EFget_lowest_components(&msg_loc, &rib_compsf, &num_ribsfs, &ribsfs, 
                                NULL, NULL, NULL);
  EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
 dpmode = GRbd;

 for (i=0; i<num_dispsfs; i++)
 { /* since we have a mix of surfaces bewteen the base solid and rib, we seek
    * out and redraw only the base surfaces on error, else redraw all.
    */
    redraw_this_sf = TRUE; /*assume*/

    if (error_in_boolean)
    { for (j=0; j<num_ribsfs; j++)
      { if (dispsfs[i] == ribsfs[j])
         { redraw_this_sf = FALSE;
           break;
         }
      }
    }
    if (dispsfs && redraw_this_sf)
    {  sts = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                &(const_md_env.md_env.matrix_type),
                const_md_env.md_env.matrix,
                &dpmode, &dp_env.md_id),
                   senderid = NULL_OBJID,
                   targetid = dispsfs[i],
                   targetos = const_os);
    }
 }

 /* Error check */
 if (error_in_boolean)
 { sts = save_sts;
   EMerr_hndlr(TRUE, *EMmsg, EMS_E_Fail, wrapup);
 }




wrapup:

  /* use "sts_loc" to check OM error status in wrapup, so that any error return
   * status from the code above is not overwritten to make it success.
   */

  /* on error, delete any surfaces created in this function. Dont bother to 
   * check and see if it exists or not.
   */

  if (!(1&sts&*EMmsg))
  {
     if (rib_compsf.objid != NULL_OBJID)
     {
         om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = rib_compsf.objid,
                    targetos = const_os);
     }
     /* Delete individually. Some might already have been deleted. This is done
      * in case the rib failed while the composite was being created. In such 
      * case, all the created surfaces will not have been deleted above.
      */
     for (i=0; i<num_feasfs; i++) 
     {
         if (om$is_objid_valid (objid=feasfs[i].objid, osnum=feasfs[i].osnum) ==
             OM_S_SUCCESS)
         {  
                 om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                             &const_md_env),
                 senderid = NULL_OBJID,
                 targetid = feasfs[i].objid,
                 targetos = feasfs[i].osnum);
         }
     }
  }

  /* free the array holding the surface ids.*/
  if (feasfs)
  {  om$dealloc(ptr=feasfs);
  }

  /* delete copies of profiles made in this function */

  if (delete_cp_profile && (cp_profile.objid!=NULL_OBJID))
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                         &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = cp_profile.objid,
                    targetos = cp_profile.osnum);
  }

  if (moved_cp_profile.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                         &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = moved_cp_profile.objid,
                    targetos = moved_cp_profile.osnum);
  }

  if (mod_cp_profile.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = mod_cp_profile.objid,
                    targetos = mod_cp_profile.osnum);
  }

  if (moved_mod_cp_profile.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = moved_mod_cp_profile.objid,
                    targetos = moved_mod_cp_profile.osnum);
  }

  if (top_seg1.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = top_seg1.objid,
                    targetos = top_seg1.osnum);
  }
  if (bottom_seg1.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = bottom_seg1.objid,
                    targetos = bottom_seg1.osnum);
  }

  if (top_seg2.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = top_seg2.objid,
                    targetos = top_seg2.osnum);
  }

  if (bottom_seg2.objid != NULL_OBJID)
  {  sts_loc = om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
                                                             &const_md_env),
                    senderid = NULL_OBJID,
                    targetid = bottom_seg2.objid,
                    targetos = bottom_seg2.osnum);
  }

  /*free inters and trace data */
  for (i=0; i<2; i++)
  {
    if (i==BASE?base_inters:feasfs_inters) /* if inters list exists */
    {  EMinters_data_free (&msg_loc, i?base_inters:feasfs_inters, MAXINT, 
               NULL, EMsfintedpar_free);
       EMinters_free (i?base_inters:feasfs_inters, MAXINT);
    }

    tracedata = (i==BASE? &base_tracedata : feasfs_tracedata);

    if ( tracedata_alloced[i] )
    {
      EMsfinttrace_free (&msg_loc, 
                 tracedata->num_grps,
                 tracedata->num_subgrps_grp,
                 tracedata->num_elems_subgrp,
                 tracedata->elems,
                 tracedata->subgrp_rev,
                 tracedata->elem_rev,
                 tracedata->grp_closed,
                 tracedata->subgrp_closed);
    }
  } 


  /* free memory allocated above */
  if (edges)
  { om$dealloc(ptr=edges);}

 if (dispsfs)
   {om$dealloc(ptr=dispsfs);}

 if (ribsfs)
   {om$dealloc(ptr=ribsfs);}

 if (comps)
   {om$dealloc(ptr=comps);}

 /* set return code. Overwrite ONLY if sts does not already have error code*/
 if(!(1&sts_loc) && (1&sts))
   sts = sts_loc;
  
 EMWRAPUP (*EMmsg, sts, "In EMmake_asociative_rib_feature");
 return (sts);
} 

/******************************************************************************/

static void EFvalidate_data(EFmsg, modenv, inters, tracedata, other_inters)
IGRlong *EFmsg;
struct EMSinters *inters, *other_inters;
struct EMSsftracedata *tracedata;
struct GRmd_env *modenv;
{

 IGRlong sts, msg_loc;
 IGRint  i, j, k, index;
 IGRshort mattyp;
 struct EMSinters *inters_loc, *other_inters_loc;
 struct EMSintobj *intobj_loc, *other_intobj_loc;
 IGRdouble *mat, xyztol, xyztol_sq;
 IGRboolean found_other_intobj;

 sts = OM_S_SUCCESS;
 *EFmsg = EMS_S_Success;

 mat = modenv->md_env.matrix;
 mattyp = modenv->md_env.matrix_type;

 BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
 xyztol_sq = xyztol * xyztol;

 inters_loc = inters;

 while (inters_loc)
 {
   intobj_loc = inters_loc->cvs;
   while (intobj_loc)
   {  
      found_other_intobj = FALSE;

      /* check BOTH inters lists for the other intobj */
      for (i=0; (i<2) && !found_other_intobj; i++)
      {
        other_inters_loc = (i==0? inters : other_inters);
  
        while (other_inters_loc && !found_other_intobj)
        { other_intobj_loc = other_inters_loc->cvs;
          while (other_intobj_loc && !found_other_intobj)
          {
            if (intobj_loc->other_intobj_node == other_intobj_loc)
            {
               found_other_intobj = TRUE; 
               break; 
            }
            other_intobj_loc = other_intobj_loc->next;
          }
          other_inters_loc = other_inters_loc->next;
        }
  
      }/*for*/

     /* if still no "other_intobj", error out */
     EMerr_hndlr (!found_other_intobj, *EFmsg, EMS_E_NotFound, wrapup);

     intobj_loc = intobj_loc->next;
   }
   inters_loc = inters_loc->next;  
 }


 /* Now we check to see if any element is incorrectly oriented on the surface.
  * This is easily ascertained by checking if the "elem_rev" is TRUE for ANY
  * element in the inters list. If this is the case, we error out. If we do NOT
  * error out, we are in danger of creating a corrupt solid. This check below 
  * is borrowed from the "EMintersect_surfaces" function.
  */


 for (i=0; i<tracedata->num_grps; i++)
 {
   for (j=0; j<tracedata->num_subgrps_grp[i]; j++)
   {
     /*
      * If the element had to be reversed then exit with error.
      * But if the element is degenerate, the elem_rev setting
      * does not make sense. So turn it off.
      */
  
     for (k=0; k<tracedata->num_elems_subgrp[i][j]; k++)
     {
       if (tracedata->elem_rev[i][j][k])
       {
           /* get the pointer to the kth intobj */
           index=k;
           intobj_loc = tracedata->elems[i][j];
           while (index--)
             intobj_loc = intobj_loc->next;
  
           if (intobj_loc->props & EMSintobj_uvdegenerate)
              tracedata->elem_rev[i][j][k] = FALSE;
           else 
           {
             EMerr_hndlr (TRUE, *EFmsg, EMS_E_IntersectOrient, wrapup);
           }
       }
     }
   }
 }


 wrapup:

 EMWRAPUP (*EFmsg, sts, "In EFvalidate_data");
}
    
/******************************************************************************/
/* DESCRIPTION:
 *
 * This function takes in an object id and returns the number and ids of each
 * of its components. If it is not a composite, that info is returned by the
 * boolean flag "composite" and the "comps" array contains nothing but the 
 * input objects id. Sometimes a composite could contain only ONE component. 
 * In that case, the "composite" flag will be true, but the "comps" array will
 * contain just one id, which is different from the input id. This is the reason
 * why we ALWAYS allocate memory for output so that SOME object is ALWAYS 
 * returned as output. Since memory for "comps" is always allocated no matter 
 * what it HAS to be freed by the caller. 
 */

void EFget_components(EFmsg, input_id, num_comps, comps, composite)
IGRlong *EFmsg;
IGRint *num_comps;
struct GRid *input_id;
GRobjid **comps;
IGRboolean *composite;
{
  IGRlong sts;
  IGRint i;
  OMuword  classid;
  OMuint count;
  OM_S_CHANSELECT to_components;
  OM_S_OBJECT_LINKAGE *comps_list;

  sts    = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;


  sts = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMerr_hndlr (!(1&sts), *EFmsg, sts, wrapup);

  sts = om$get_classid (osnum=input_id->osnum, objid=input_id->objid,
                        p_classid = &classid);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  sts = om$is_ancestry_valid (subclassid   = classid,
                              superclassid = OPP_EMScomposite_class_id);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  if (sts == OM_S_SUCCESS) /* if COMPOSITE */
  {
    /* get the number of components */
    sts = om$get_channel_count (osnum = input_id->osnum, 
                                objid = input_id->objid,
                                p_chanselect = &to_components,
                                count = (OMuint *)num_comps);
    EMerr_hndlr(!(1&sts),*EFmsg, EMS_E_OMerror, wrapup);

    comps_list = (OM_S_OBJECT_LINKAGE *) alloca ((*num_comps) *
                                   sizeof(OM_S_OBJECT_LINKAGE)) ;
    sts = om$get_channel_objects (osnum=input_id->osnum, objid=input_id->objid,
                                  p_chanselect = &to_components,
                                  list=comps_list, size=(*num_comps),
                                  count = &count);
    EMerr_hndlr(!(1&sts)||(count!=(*num_comps)),*EFmsg, EMS_E_OMerror, wrapup);

    *comps = (GRobjid *)om$malloc(size= (*num_comps) * sizeof(GRobjid));

    for (i=0; i<(*num_comps); i++)
      (*comps)[i] = comps_list[i].S_objid;

    if (composite)
        *composite = TRUE;
  }
  else /*NOT composite*/
  { *comps = (GRobjid *)om$malloc(size= sizeof(GRobjid));
    (*comps)[0] = input_id->objid;
    *num_comps=1;

    if (composite)
       *composite = FALSE;
  }

  wrapup:

  EMWRAPUP (*EFmsg, sts, "In EFget_components");
}  

end implementation EMSsffeature;
