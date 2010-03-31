/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

     This method is used as a Range Reducer after compress tree. If the
     loopset range area is less than or equal the CUT_OFF_AREA(0.85), it
     extracts partial surface and transforms the boundaries to this new
     UV. Seam edges if any are deleted and the loops are merged.

  NOTES

        After extraction of the partial surface the surface changes it's id.
        All channel connections are moved to this new surface and the old
        surface deleted.

  HISTORY

    SAM : 05-Mar-88 : Creation
    SAM : 07-Apr-88 : Modified such as seam edges are deleted and
                                           corresponding loops are merged.
    RC  : 11/03/88  : Rewrote the portion to merge the loops.
    SM  : 07-Dec-88 : Argument change for EMSloop.EMtoggle_type.
    RC  02/02/89    : If the loopset range degenerates to a line,
                      increment it by partol. This is done such that
                      partial surface extraction does not fail.
    RC  03/23/89    : Replaced EFsspbtol_by_geom () by BSsfkttol2() as
                      it adjusts the partol if exceeds a defined constant.
    DLB 10/29/89    : Added water_mark parameter. If water_mark == 0 then
                      take original default of .85.
    SM  01-Mar-92   : Parametric tolerance for the NEW surface should be
		      passed in the EMuv_transform message send because this
		      tolerance is used in decisions such as whether an old
		      linear edge now becomes a natural edge after
		      transformation. If the range reduction is significant,
		      the tolerance for the old surface can be extremely fine
		      resulting in linear edges matching natural edges
		      geometrically on the new surface but not being of that
		      class, because the fine tolerance is unnecessarily used
		      for the new surface.
		      Also replaced GRgetabsg for the old surface geom with
		      EMgetvggeom since I had to send EMpartolbasis to the
		      new surface (which uses a GRgetabsg too).
    NP  26-Aug-92     Modified for ANSI compliance.
    Jack 25-Sep-92    Reacted to EMchangeSurface moving from EMSgradata to
                      EMShelper.
    Jack 15-Nov-92    ANSI stuff, removed 5 var declarations that weren't used and
                      initialized two pointers to NULL.

*/

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
%safe
#include <math.h>
%endsafe
/* includes for GRgetabsg macro */
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef gocmacros_include
# include "gocmacros.h"
# endif

/* end of GRgetabsg includes    */

#include "emsmacros.h"
#include "bsparameters.h" /* BSEXTRACTPAR macro */
#include "bserr.h"        /* BS return codes */

#include "dpdef.h"
#include "dpmacros.h"
#include "dp.h"
#include "EMSsplitdef.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "emslpinitdef.h"
#include "OMerrordef.h"

#define U_SPLIT         0
#define V_SPLIT         1
#define NO_WINDOW_LOOPSET               0
#define NO_STATUS_MESSAGES_WANTED       0
#define CUT_OFF_AREA                    0.85
#define U_TRANS_DIR                 0x1
#define V_TRANS_DIR                 0x2

struct LOOP_INFO { IGRshort   trans_dir; IGRboolean merge;};


from EMSloopset  import EMgetrange, EMnesting, EMtreemod;
from EMSloopset  import EMget_loops;
from EMSloopset  import EMbounded_uv_range, EMget_props;
from EMShelper   import EMchangeSurface;
from EMSboundary import EMuv_transform, EMget_objid;
from EMSloop     import EMset_props, EMmergeloop, EMget_edges,
                        EMmodify_edge, EMget_props, EMlpinit,
                        EMgivenestinfo, EMtreemod, EMtoggle_type;
from EMSedge     import EMget_location;

method EMreduce_range(IGRlong         *EMmsg;
                      struct GRmd_env *grmd_env;
                      GRobjid         *new_objectid;
                      IGRdouble        water_mark)
{
  struct IGResbs        esbs;
  struct IGRbsp_surface *surf_old = NULL;
  struct GRvg_construct construct_list;
  struct GRsymbology    symb;
  struct EMSpartolbasis partolbasis, newpartol;
  IGRboolean	        world = TRUE;
  struct GRid           my_GRid;
  OM_S_CHANSELECT       sf_ls_chan, chan_sel, to_helpers, to_owners, to_loopset;

  IGRdouble             ls_range[4], *lp_ranges = NULL, mid_uv[2],
                        ls_uv_area, tr_mat[16], cut_off_area, knot_tol;

  IGRlong               OM_stat, mthd_stat, rc, num_lps;
  IGRuint	        count, cnt_helpers = 0, cnt_owners = 0, cnt_loopset = 0;

  IGRint                UV_SPLIT;

  IGRshort              across_seam;
  IGRushort             ls_props;
  GRobjid               *lp_ids = NULL;
  IGRchar               *es;
  struct GRmd_env       temp_env;
  extern IGRboolean     GRabsg_del();
  extern void           EFmerge_lps_across_seam(), BSsfkttol2();

  OM_stat = OM_S_SUCCESS;
  *EMmsg  = EMS_S_Success;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  memcpy( &temp_env, grmd_env, sizeof(struct GRmd_env) );
  /* across_seam = NOT_ACROSS_SEAM; */

  /*Modified by DLB on 10/29/89*/
  cut_off_area = (water_mark == 0 ? CUT_OFF_AREA : water_mark);

  *new_objectid = my_id;

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count(object = me, p_chanselect = &sf_ls_chan,
                                 count = &count);
  if(!count) goto wrapup;

  OM_stat =
    om$send(msg          = message EMSloopset.EMget_props(EMmsg, &ls_props),
            p_chanselect = &sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopsetError, wrapup);

  if(ls_props & EMLS_NATURAL) goto wrapup;

  OM_stat =
    om$send(msg          = message EMSloopset.EMbounded_uv_range( EMmsg,
                                                                  ls_range,
                                                                  &ls_uv_area,
                                                                  &across_seam,
                                                                  &UV_SPLIT,
                                                                  &mid_uv[0],
                                                                  &num_lps,
                                                                  &lp_ids,
                                                                  &lp_ranges),
            p_chanselect = &sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopsetError, wrapup);

  if (ls_uv_area > cut_off_area) goto wrapup;

  /*
   * In cases the loopset degenerates to a line parrallel to either
   * u or v axis, the ls_range points will be within knot tolerance.
   * In such cases, extraction of partial surface will fail. Therefore,
   * increase the range by knot tolerance. -- RC 02/02/89
   */
  /************* Replaced by EMgetvggeom because of EMpartolbasis send to
                 another surface.
  GRgetabsg(&mthd_stat, &(grmd_env->md_env.matrix_type),
            grmd_env->md_env.matrix, &surf_old, our_dumdum);
  ***************/

  OM_stat = EMgetvggeom(&mthd_stat, &grmd_env->md_env.matrix_type,
                        grmd_env->md_env.matrix, &my_GRid, &surf_old, NULL);
  EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

  /*
   * Replaced EFsspbtol_by_geom by BSsfkttol2() as EFsspbtol_by_geom
   * adjusts the partol if it exceeds a defined limit. This adjustment
   * causes problems as math still uses unadjusted partol returned
   * by BSsfkttol2.  RC  03/23/89
   */

  BSsfkttol2 (surf_old->u_order, surf_old->v_order, surf_old->u_knots,
              surf_old->v_knots, surf_old->u_num_poles,
              surf_old->v_num_poles, surf_old->poles, surf_old->weights,
              &knot_tol, &rc);
  EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  partolbasis.tol      = knot_tol;
  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  partolbasis.mattyp   = &(grmd_env->md_env.matrix_type);
  partolbasis.mat      = grmd_env->md_env.matrix;

  knot_tol *= 1.1;

  if (ls_uv_area < knot_tol)
  {
    if (across_seam & ACROSS_SEAM_U)
    {
      if ( (ls_range[0] + knot_tol) <= surf_old->u_knots[surf_old->u_num_poles])
        ls_range[0] += knot_tol;

      if ( (ls_range[2] - knot_tol) >= surf_old->u_knots[surf_old->u_order - 1])
        ls_range[2] -= knot_tol;
    }
    else
    {
      if ( (ls_range[0] - knot_tol) >= surf_old->u_knots[surf_old->u_order -1 ])
        ls_range[0] -= knot_tol;

      if ( (ls_range[2] + knot_tol) <= surf_old->u_knots[surf_old->u_num_poles])
        ls_range[2] += knot_tol;
    }

    if (across_seam & ACROSS_SEAM_V)
    {
      if ( (ls_range[1] + knot_tol) <= surf_old->v_knots[surf_old->v_num_poles])
        ls_range[1] += knot_tol;

      if ( (ls_range[3] - knot_tol) >= surf_old->v_knots[surf_old->v_order - 1])
        ls_range[3] -= knot_tol;
    }
    else
    {
      if ( (ls_range[1] - knot_tol) >= surf_old->v_knots[surf_old->v_order -1 ])
        ls_range[1] -= knot_tol;

      if ( (ls_range[3] + knot_tol) <= surf_old->v_knots[surf_old->v_num_poles])
        ls_range[3] += knot_tol;
    }

    ls_uv_area = (ls_range[2] - ls_range[0]) * (ls_range[3] - ls_range[1]);

  } /* if (ls_uv_area < knot_tol) */

  OM_stat = om$send(msg = message GRvg.GRgetsymb( &mthd_stat, &symb),
                    targetid = my_id);
  EMerr_hndlr(!(1&mthd_stat&OM_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

  es = (IGRchar *) &esbs;
  OM_stat = om$send(msg = message GRvg.GRgetattr( &mthd_stat, es),
                    targetid = my_id);
  EMerr_hndlr(!(1&mthd_stat&OM_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

/* NOTE:
  ----
      Model space rule lines have to be preserved after extracting partial
      surface, I am keeping the number of rule lines same in the New
      surface as in the Old surface. If the above was to be done the
      surface would have non-uniform rule lines , Allen says this would
      be implemanted soon. In that case "esbs" for the new surface is
      not the same as the old surface (construct_list.class_attr)     */

  construct_list.msg        = EMmsg;
  construct_list.env_info   = grmd_env;
  construct_list.newflag    = FALSE;
  construct_list.geometry   = NULL;
  construct_list.class_attr = es; /* EMchgclass says this would change */
  construct_list.level      = symb.level;
  construct_list.properties = ME.GRgraphics->properties;
  construct_list.name       = NULL;
  construct_list.display    = &(symb.display_attr);

 /*
  if( (ls_range[0] == 0) && (ls_range[2] == 1.0) )
   UV_SPLIT = 1;

  if( (ls_range[1] == 0) && (ls_range[3] == 1.0) )
   UV_SPLIT = 0;
  */

  OM_stat =
    om$send(msg      = message EMSsubbs.EMpartsf( EMmsg,
                                                  &construct_list, ls_range, mid_uv, &ls_range[2],
                                                  UV_SPLIT, new_objectid, NULL, NO_WINDOW_LOOPSET,
                                                  NO_STATUS_MESSAGES_WANTED),
            targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

  if (across_seam)
  {
    EFmerge_lps_across_seam (&rc, &my_GRid, surf_old, grmd_env,
                             &partolbasis, num_lps, lp_ranges, lp_ids,
                             ls_range, across_seam);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  } /* if (across_seam) */

  /*
   * Scale the entire loopset into a space which goes from 0 to 1.
   * The old range for scaling is the window used for extraction.
   */

  {
    IGRdouble             old_range[4],new_range[4];
    extern IGRshort       EFget_uv_trans_mat();
    extern void           EM2dbx();

    new_range[0] = new_range[1] = 0.0;
    new_range[2] = new_range[3] = 1.0;

    if(across_seam)
    {
      OM_stat = om$send(msg          = message EMSloopset.EMgetrange(&mthd_stat, old_range),
                        p_chanselect = &sf_ls_chan);
      EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopsetError,wrapup);
    }
    else
    {
      EM2dbx(2, ls_range, old_range);
    }

    OM_stat = EFget_uv_trans_mat(EMmsg, old_range, new_range, tr_mat);

    newpartol = partolbasis;
    OM_stat = om$send(msg = message EMSsubbs.EMpartolbasis(&mthd_stat,
                                                           newpartol.mattyp,
                                                           newpartol.mat,
                                                           &world,
                                                           TRUE,
                                                           &newpartol.tol),
                      targetid = *new_objectid);
    EMerr_hndlr(!(1&*EMmsg&OM_stat), *EMmsg, EMS_E_LoopsetError,wrapup);

    OM_stat = om$send(msg = message EMSloopset.EMuv_transform( &mthd_stat,
                                                               tr_mat,
                                                               &newpartol,
                                                               NULL,
                                                               (IGRchar *)surf_old,
                                                               NULL),
                      p_chanselect = &sf_ls_chan);
    EMerr_hndlr(!(1&*EMmsg&OM_stat), *EMmsg, EMS_E_LoopsetError,wrapup);

  }  /* Loopset Scaled */

  OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &chan_sel);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  to_helpers = chan_sel;

  OM_stat = om$send(msg          = message EMShelper.EMchangeSurface( EMmsg, *new_objectid),
                    p_chanselect = &chan_sel, from = MAXINT, to = 0);
  if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

  OM_stat = EMmake_chanselect (GRconnector_to_owners, &chan_sel);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  to_owners = chan_sel;

  OM_stat = om$send(msg      = message Root.move_chan( chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);

  OM_stat = EMmake_chanselect (GRnotify_notification, &chan_sel);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send(msg      = message Root.move_chan( chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &chan_sel);
  to_loopset = chan_sel;

  OM_stat = om$send(msg      = message Root.move_chan(chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send(msg      = message GRgraphics.GRdelete(EMmsg, grmd_env),
                    senderid = my_id,
                    targetid = my_id);
  if ( ! (OM_stat & 1 & *EMmsg) )
  {
    cnt_helpers = 0, cnt_owners = 0, cnt_loopset = 0;

    om$get_channel_count(object = me, p_chanselect = &to_owners,  count = &cnt_owners);
    om$get_channel_count(object = me, p_chanselect = &to_loopset, count = &cnt_loopset);
    om$get_channel_count(object = me, p_chanselect = &to_helpers, count = &cnt_helpers);

    // HF: 11/09/2000 - Added for VDS/STRUCT etc...
    // Occasionally GRgraphics.GRdelete() fails for unknown reasons (GRrtree problem ???), so,
    // after checking channel_counts, performs a Root.delete()...
    if ( cnt_owners == 0 && cnt_loopset == 0 )
    {
      *EMmsg  = EMS_S_Success;
      OM_stat =
        om$send(mode     = OM_e_wrt_object,
                msg      = message Root.delete(NULL),
                senderid = my_id,
                targetid = my_id);
    }
    else
    {
    }
  }
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

wrapup:

  if (ls_uv_area <= cut_off_area)
  {
    /*Reduction occurred so clean up.*/
    /*******
    GRabsg_del(surf_old);
    *******/

  } /* if (ls_uv_area > cut_off_area) */

  /* fix for mlk  moved from inside the if above*/
  if(lp_ranges)  om$dealloc(ptr = lp_ranges);
  if(lp_ids)     om$dealloc(ptr = lp_ids);
  if(surf_old)   om$dealloc(ptr = surf_old);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMreduce_range");

  return (OM_stat);
}


/*
 * Given the trace information, the following function
 * o Creates loops.
 * o Nest the nelwy created loops into the loopset.
 */

void EFupdate_lps ( EFmsg, cs_env, cur_os, num_grps, num_sgrps_grp,
                      num_elems_sgrp, elems, sgrp_rev, elem_rev,
                      grp_clsd, sgrp_clsd, partolbasis, ls_id, org_lps,
                      org_lps_info, num_org_lps)

     IGRlong                 *EFmsg;
     struct        GRmd_env  *cs_env;
     GRspacenum              cur_os;
     IGRint                  num_grps, *num_sgrps_grp, **num_elems_sgrp;
     struct        EMSintobj ***elems;
     IGRboolean              **sgrp_rev, ***elem_rev, *grp_clsd,
                             **sgrp_clsd;
     struct EMSpartolbasis   *partolbasis;
     GRobjid                 ls_id, *org_lps;
     struct LOOP_INFO        *org_lps_info;
     IGRint                  num_org_lps;
 {
   OM_S_CHANSELECT               ls_lp_chan;
   struct          EMSsfintedpar ***intparms = NULL;
   struct          EMSnest_info  nesting;
   IGRdouble                     **par_tol = NULL;
   IGRlong                       rc, mthd_stat, OM_stat;
   IGRint                        i, j, k, lp_inx, sts, num_lps = 0;
   IGRuint			 num_cmpnts;
   extern IGRint                 EMsfintloops();
   GRspacenum                    dum_os;
   GRobjid                       **lp_sf = NULL, **endedges = NULL, lp_id,
                                 *lp_added_ids = NULL;
   extern void                   EMsfintloops_free();
   IGRushort             togtype_options = NULL;

   /* ************************************************************ */

   lp_sf = NULL;
   endedges = NULL;
   intparms = NULL;
   par_tol = NULL;

   *EFmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * Make sense out of the reversed flags set by trace.
    * Also check whether all the groups are closed or not.
    * If any of the groups is not closed
    * then it probably is intersection problem.
    */

   for (i = 0; i < num_grps; i++)
   {
    EMerr_hndlr (!grp_clsd[i], *EFmsg,EMS_E_IntersectClosure,wrapup);

    for (j = 0; j < num_sgrps_grp[i]; j++)
    {
      EMerr_hndlr(!sgrp_clsd[i][j],*EFmsg,EMS_E_IntersectClosure,wrapup);

      num_lps++;

    } /* for (j = 0; j < num_sgrps_grp[i]; j++) */

  } /* for (i = 0; i < num_grps; i++) */

  /*
   * Create the loops out of the intersections.
   */

  sts = EMsfintloops(&rc, &cs_env->md_env.matrix_type,
                     cs_env->md_env.matrix, cur_os, NULL,
                         num_grps, num_sgrps_grp, num_elems_sgrp,
                     elems, sgrp_rev, elem_rev, grp_clsd,
                     sgrp_clsd, FALSE, FALSE, &lp_sf, &endedges,
                     &intparms, &par_tol);
  EMerr_hndlr(!(1&rc&sts), *EFmsg, EMS_E_Fail, wrapup);

  lp_added_ids = (GRobjid *) om$malloc(size = num_lps *
                                   sizeof(GRobjid));
  EMerr_hndlr(!lp_added_ids, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  for(i = 0, lp_inx = 0; i < num_grps; i++)
    for(j = 0, k = 0; j< 2 * num_sgrps_grp[i]; j+=2, k++)
       lp_added_ids[lp_inx++] = lp_sf[i][j];

  /*
   * Delete the loops that have been merged.
   */

  for (i = 0; i < num_org_lps; i++)
  {
    if (org_lps_info[i].merge)
    {
     OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat,
                        &nesting, DELETE, NULL),
                       senderid = NULL_OBJID,
                       targetid = org_lps[i], targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

    } /* if (org_lps_info[i].merge) */

  } /* for (i = 0; i < num_org_lps; i++) */

  /*
   * Nest new loops
   */

  for(i = 0; i < num_lps; i++)
  {
    OM_stat = om$send(msg = message EMSloop.EMset_props (&mthd_stat,
                       EMLP_NEW | EMLP_SPLIT, EMS_O_OFF),
                      senderid = NULL_OBJID,
                      targetid = lp_added_ids[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);

/*
    OM_stat = om$send(msg = message EMSloop.EMget_props(&mthd_stat,
                       &props),
                      senderid = NULL_OBJID,
                      targetid = lp_added_ids[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);
*/

    OM_stat = om$send(msg = message EMSloop.EMlpinit (&mthd_stat,
                       NULL, partolbasis,
                       EMLpInit_IgnoreInProps | EMLpInit_NoRange |
                       EMLpInit_NoClosureTest ),
                      senderid = NULL_OBJID,
                      targetid = lp_added_ids[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);

    OM_stat = om$send(msg = message EMSloop.EMgivenestinfo (&mthd_stat,
                       &nesting),
                      senderid = NULL_OBJID,
                      targetid = lp_added_ids[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_NestError, wrapup);

    OM_stat = om$send(msg = message EMSloopset.EMnesting (&mthd_stat,
                       &nesting, partolbasis),
                      senderid = NULL_OBJID,
                      targetid = ls_id, targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_NestError, wrapup);

    if( IF_EQ_OBJID(nesting.parent,ls_id) )
      OM_stat = om$send(msg = message EMSloopset.EMtreemod (&mthd_stat,
                         &nesting, ADD_CHILD, partolbasis),
                        senderid = NULL_OBJID,
                        targetid = nesting.parent, targetos = cur_os);
    else
      OM_stat = om$send(msg = message EMSloop.EMtreemod (&mthd_stat,
                         &nesting, ADD_CHILD, partolbasis),
                        senderid = NULL_OBJID,
                        targetid = nesting.parent, targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_NestError, wrapup);

  } /* for(i = 0; i < num_lps; i++) */


  /*
   * Make all the external loops in the loopset, P_loops and
   * toggle types of all other loops under them.
   */

  OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
  EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (objid = ls_id, osnum = cur_os,
               p_chanselect = &ls_lp_chan, count = &num_cmpnts);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  togtype_options =  EMTogType_SendInner;

  for (i = 0; i < num_cmpnts; i++)
  {
    OM_stat = om$get_objid_at_index (osnum = cur_os, objid = ls_id,
                 p_chanselect = &ls_lp_chan, index = i,
                 objidaddr = &lp_id, osnumaddr = &dum_os);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$send(msg = message EMSloop.EMtoggle_type (&mthd_stat,
                       TRUE, FALSE, ls_id, togtype_options, NULL,
                       NULL, NULL, NULL, NULL, NULL),
                      senderid = NULL_OBJID, targetid = lp_id,
                      targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError,wrapup);

  } /* for (i = 0; i < num_cmpnts; i++) */

wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFupdate_lps");
  if (lp_sf) EMsfintloops_free (lp_sf, endedges, intparms, par_tol);
  if (lp_added_ids) om$dealloc (ptr = lp_added_ids);

  return;

} /* void EFupdate_lps () */


/*

Name
 EFmerge_lps_across_seam

Abstract

Synopsis
  The following function
   o merges the lps across seam.
   o Delete the merged lps.
   o Nest the lps created by merging.

Description

Return Value

Notes
  This function should be used whenever a surface is extracted across
  seam.

Index

Keywords
  function,modify,solid,surface

History
  Moghe ?-???-??    Created
  Jack  4-Mar-93    Modified EFmerge_lps_across_seam.  Initialized several
                    pointers to NULL, especially grp_clsd which was being
                    deallocated without being allocated.  This caused a crash
                    when Compress Tree was run on a torus that was split with a
                    plane.  Also, fixed another crash for the same testcase.
                    When removing seam edges, we don't want to remove pairs
                    where both edges are in the same loop.  I believe this
                    only happens with a torus.
  NP    05/27/93    Funtction "EMmkintlist" is now called by a new
                    name, "EMmakeintlist", due to addition of two new
                    curve type parameters.
                    NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                          CALL (CURRENTLY SET TO NULL).


 */

void EFmerge_lps_across_seam (EFmsg, sf_GRid, sf_ogm, md_env, partolbasis,
                              num_lps, lp_ranges, lp_ids, ls_range,
                              across_seam)

  IGRlong               *EFmsg;
  struct GRid           *sf_GRid;
  struct IGRbsp_surface *sf_ogm;
  struct GRmd_env       *md_env;
  struct EMSpartolbasis *partolbasis;
  IGRint                num_lps;
  IGRdouble             *lp_ranges;
  GRobjid               *lp_ids;
  IGRdouble             *ls_range;
  IGRshort              across_seam;

{
  struct LOOP_INFO       *lps_info = NULL;
  struct EMSintobj       *last_intobj = NULL, *lp_fintobj=NULL, *lp_lintobj=NULL,
                         *ed_intobj = NULL, *sm_ed_intobj = NULL, *sm_ed_cm_intobj = NULL,
                         ***elems = NULL, **next_sm_loc = NULL, **next_sm_cm_loc = NULL;
  struct GRid            *lp_eds = NULL, *ed_GRid = NULL;
  struct EMSdataselect   ed_uv_data;
  struct EMSinters       *sf_inters = NULL;
  struct EMSuvtrans_info rpl_info;

  OM_S_CHANSELECT        cm_ed_chan, to_bd_owners, sf_ls_chan;

  IGRdouble              tr_mat[16], start_u, start_v;
  extern IGRdouble       fabs();

  IGRlong                OM_stat, mthd_stat, rc;

  IGRint                 i, lp_inx, num_seam_eds, num_lp_eds,
                         eds_arrsz = 0, ed_inx, num_grps, *num_sgrps_grp = NULL,
                         **num_elems_sgrp = NULL, tmp_inx;

  IGRboolean             **sgrp_rev = NULL, ***elem_rev = NULL,
                         *grp_clsd = NULL, **sgrp_clsd = NULL,
                         comm_ed_in_same_loop = FALSE;

  GRobjid                sm_ed, sm_ed_cm_ed, ls_id;
  GRspacenum             cur_os;

  extern void            EMsfinttrace(), EMsfinttrace_free(),
                         EMintobj_data_free(), EMintobj_free(),
                         EFupdate_lps(), EMinters_data_free(), EMinters_free();
  extern struct EMSintobj *EMmakeintlist();

  /* ***************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  cur_os = sf_GRid->osnum;
  rpl_info.ed_ids = rpl_info.rpl_ed_ids = NULL;
  rpl_info.num_eds = rpl_info.eds_arrsz = 0;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_bd_owners);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  for (i = 0; i < 16; i++)  tr_mat[i] = 0;
  for (i = 0; i < 16; i += 5) tr_mat[i] = 1.0;

  lps_info = (struct LOOP_INFO *) om$malloc(size = num_lps *
                                            sizeof(struct LOOP_INFO));
  EMerr_hndlr(!lps_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  start_u = ls_range[0];
  start_v = ls_range[1];

  for (lp_inx =0; lp_inx < num_lps; lp_inx++)
  {
    num_seam_eds = 0;
    OM_stat = om$send (msg = message EMSboundary.EMget_edges (
                        &mthd_stat, 1, EMS_OPT_SEAM, &lp_eds,
                        &eds_arrsz, &num_seam_eds),
                       senderid = NULL_OBJID,
                       targetid = lp_ids[lp_inx], targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

    /*
     * Even if the loop has seam edges, it may be possible that
     * these seam edges do not have any common edge. This will be
     * true in some cases where the seam edge property was not
     * turned off.
     */

    lps_info[lp_inx].merge = FALSE;

    if (num_seam_eds)
    {
      for (i = 0; i < num_seam_eds; i++)
      {
       sm_ed_cm_ed = NULL_OBJID;
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &sm_ed_cm_ed),
                          senderid = lp_eds[i].objid,
                          p_chanselect = &cm_ed_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

       if (!IF_NULL_OBJID(sm_ed_cm_ed))
       {
         lps_info[lp_inx].merge = TRUE;          break;
       }

      } /* for (i = 0; i < num_seam_eds; i++) */

    } /* if (num_seam_eds) */

    lps_info[lp_inx].trans_dir = 0;

    if (across_seam & ACROSS_SEAM_U)
      if ( fabs (lp_ranges[4*lp_inx + 2] - partolbasis->tol) <= start_u)
        lps_info[lp_inx].trans_dir |= U_TRANS_DIR;

    if (across_seam & ACROSS_SEAM_V)
      if ( fabs (lp_ranges[4*lp_inx + 3] - partolbasis->tol) <= start_v)
       lps_info[lp_inx].trans_dir |= V_TRANS_DIR;

   } /*  for (lp_inx =0; lp_inx < num_lps; lp_inx++) */

   last_intobj = NULL;
   for (lp_inx = 0; lp_inx < num_lps; lp_inx++)
   {
    if (lps_info[lp_inx].merge)
    {
     num_lp_eds = 0;
     OM_stat = om$send (msg = message EMSboundary.EMget_edges (
                         &mthd_stat, 1, EMS_OPT_ALL, &lp_eds,
                         &eds_arrsz, &num_lp_eds),
                        senderid = NULL_OBJID,
                        targetid = lp_ids[lp_inx], targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     for (ed_inx = 0; ed_inx < num_lp_eds; ed_inx++)
     {
       ed_GRid = (struct GRid *) om$malloc (size = sizeof(struct GRid));
       EMerr_hndlr (!ed_GRid, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

       *ed_GRid = lp_eds[ed_inx];
       ed_uv_data.datatype = EMSdata_object;
       ed_uv_data.data.object = ed_GRid;

       EMmakeintlist (&rc, &sf_inters, NULL, sf_GRid, NULL, NULL, NULL,
                    NULL,NULL,NULL, &ed_uv_data, NULL, FALSE, FALSE,
                    NULL, NULL, NULL, NULL, NULL, NULL, TRUE, FALSE);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       last_intobj = last_intobj ? last_intobj->next : sf_inters->cvs;
       if (!ed_inx)
        lp_fintobj = last_intobj;
       else if (ed_inx == num_lp_eds - 1)
        lp_lintobj = last_intobj;

     } /* for (ed_inx = 0; ed_inx < num_lp_eds; ed_inx++) */

     ed_intobj = lp_fintobj;
     for (ed_inx = 0; ed_inx < num_lp_eds; ed_inx++)
     {
       ed_intobj->props |= EMSintobj_fwd_connectuv;
       ed_intobj->props |= EMSintobj_bwd_connectuv;

       if (ed_inx == num_lp_eds -1)
       {
         lp_lintobj->fwd = lp_fintobj;
         lp_fintobj->bwd = lp_lintobj;
       }
       else
       {
         ed_intobj->fwd = ed_intobj->next;
         ed_intobj->next->bwd = ed_intobj;
         ed_intobj = ed_intobj->next;
       }

     } /* for (ed_inx = 0; ed_inx < num_lp_eds; ed_inx++) */

    } /* if (lps_info[lp_inx].merge) */

   } /* for (lp_inx = 0; lp_inx < num_lps; lp_inx++) */

   for (lp_inx = 0; lp_inx < num_lps; lp_inx++)
   {
    if (lps_info[lp_inx].merge)
    {
     num_seam_eds = 0;
     OM_stat = om$send (msg = message EMSboundary.EMget_edges (
                         &mthd_stat, 1, EMS_OPT_SEAM, &lp_eds,
                         &eds_arrsz, &num_seam_eds),
                        senderid = NULL_OBJID,
                        targetid = lp_ids[lp_inx], targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     for (ed_inx = 0; ed_inx < num_seam_eds; ed_inx++)
     {
       sm_ed = lp_eds[ed_inx].objid;
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &sm_ed_cm_ed),
                          senderid = sm_ed,
                          p_chanselect = &cm_ed_chan);

       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

       comm_ed_in_same_loop = FALSE;
       for (tmp_inx = 0; tmp_inx < num_seam_eds; tmp_inx++)
        {
          if(lp_eds[tmp_inx].objid == sm_ed_cm_ed)
           {
             /*
              * if we find the common seam edge for the current seam edge in
              * the same loop, then we don't want to remove them.  this probably
              * will only happen with a torus.
              */
             comm_ed_in_same_loop = TRUE;
             break;
           }
        }

       if(comm_ed_in_same_loop)
          continue;

       sm_ed_intobj = sf_inters->cvs;
       next_sm_loc = &sf_inters->cvs;
       for (i = 0; i < sf_inters->num_cvs; i++)
       {
        if (sm_ed_intobj->this_uvintobj.data.object->objid == sm_ed)
         break;
        else
        {
         next_sm_loc = &sm_ed_intobj->next;
         sm_ed_intobj = sm_ed_intobj->next;

        }
       }

       sm_ed_cm_intobj = sf_inters->cvs;
       next_sm_cm_loc = &sf_inters->cvs;
       for (i = 0; i < sf_inters->num_cvs; i++)
       {
        if (sm_ed_cm_intobj->this_uvintobj.data.object->objid == sm_ed_cm_ed)
         break;
        else
        {
          next_sm_cm_loc = &sm_ed_cm_intobj->next;
          sm_ed_cm_intobj = sm_ed_cm_intobj->next;
        }

       }


       sm_ed_intobj->bwd->fwd = sm_ed_cm_intobj->fwd;
       sm_ed_intobj->fwd->bwd = sm_ed_cm_intobj->bwd;

       sm_ed_cm_intobj->bwd->fwd = sm_ed_intobj->fwd;
       sm_ed_cm_intobj->fwd->bwd = sm_ed_intobj->bwd;


       OM_stat = om$send (msg = message Root.wild_disconnect (
                           to_bd_owners),
                          senderid = NULL_OBJID,
                          targetid = sm_ed, targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$send (msg = message Root.wild_disconnect (
                           to_bd_owners),
                          senderid = NULL_OBJID,
                          targetid = sm_ed_cm_ed, targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

       *next_sm_loc = sm_ed_intobj->next;
       EMintobj_data_free (&rc, sm_ed_intobj, 1, NULL);
       EMintobj_free (sm_ed_intobj, 1);

       *next_sm_cm_loc = sm_ed_cm_intobj->next;
       EMintobj_data_free (&rc, sm_ed_cm_intobj, 1, NULL);
       EMintobj_free (sm_ed_cm_intobj, 1);

       sf_inters->num_cvs -= 2;

     } /* for (ed_inx = 0; ed_inx < num_seam_eds; ed_inx++) */

    } /* if (lps_info[lp_inx].merge) */

    if (lps_info[lp_inx].trans_dir)
    {
     tr_mat[3] = (lps_info[lp_inx].trans_dir & U_TRANS_DIR) ? 1.0 : 0.;
     tr_mat[7] = (lps_info[lp_inx].trans_dir & V_TRANS_DIR) ? 1.0 : 0.;

     rpl_info.num_eds = 0;
     OM_stat = om$send(msg = message EMSboundary.EMuv_transform(
                        &mthd_stat,tr_mat, partolbasis, NULL, (IGRchar *)sf_ogm,
                        (IGRchar *)&rpl_info),
                       senderid = NULL_OBJID,
                       targetid = lp_ids[lp_inx], targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     if (lps_info[lp_inx].merge && rpl_info.num_eds)
     {
      for (ed_inx = 0; ed_inx < rpl_info.num_eds; ed_inx++)
      {
       ed_intobj = sf_inters->cvs;
       for (i = 0; i < sf_inters->num_cvs; i++)
       {
         if (ed_intobj->this_uvintobj.data.object->objid ==
                                      rpl_info.ed_ids[ed_inx])
         {
           ed_intobj->this_uvintobj.data.object->objid =
                                         rpl_info.rpl_ed_ids[ed_inx];
           break;
         }
         else ed_intobj = ed_intobj->next;

       } /* for (i = 0; i < sf_inters->num_cvs; i++) */

      } /* for (ed_inx = 0; ed_inx < rpl_info.num_eds; ed_inx++) */

     } /* if (lps_info[lp_inx].merge && rpl_info.num_eds) */

    } /* if (lps_info[i].trans_dir) */


   } /* for (lp_inx = 0; lp_inx < num_lps; lp_inx++) */

   if (sf_inters)
   {
    EMsfinttrace (&rc, &md_env->md_env.matrix_type,
                 md_env->md_env.matrix, sf_inters, &partolbasis->tol,
                 NULL, &num_grps, &num_sgrps_grp, &num_elems_sgrp,
                 &elems, &sgrp_rev, &elem_rev, &grp_clsd, &sgrp_clsd);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                       &ls_id),
                      senderid = sf_GRid->objid,
                      p_chanselect = &sf_ls_chan, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

    EFupdate_lps (&rc, md_env, cur_os, num_grps, num_sgrps_grp,
             num_elems_sgrp, elems, sgrp_rev, elem_rev, grp_clsd,
             sgrp_clsd, partolbasis, ls_id, lp_ids, lps_info, num_lps);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

   } /* if (sf_inters) */

 wrapup:

  if (sf_inters)
  {
    EMsfinttrace_free (&rc, num_grps, num_sgrps_grp, num_elems_sgrp,
                    elems, sgrp_rev, elem_rev, grp_clsd,
                    sgrp_clsd);

    EMinters_data_free (&rc, sf_inters, NULL, NULL, NULL);
    EMinters_free (sf_inters, NULL);

  } /* if (sf_inters) */

  if(lps_info)   om$dealloc(ptr = lps_info);
  if (lp_eds)    om$dealloc (ptr = lp_eds);

  if (rpl_info.ed_ids) om$dealloc (ptr = rpl_info.ed_ids);
  if (rpl_info.rpl_ed_ids) om$dealloc (ptr = rpl_info.rpl_ed_ids);


  EMWRAPUP(*EFmsg, OM_stat, "In EFmerge_lps_across_seam");
  return;


} /* EFmerge_lps_across_seam() */

end implementation EMSsubbs;
