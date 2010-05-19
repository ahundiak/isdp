/* $Id: EMssredrange.I,v 1.1 2001/01/14 19:14:25 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/model / EMssredrange.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMssredrange.I,v $
 *	Revision 1.1  2001/01/14 19:14:25  hans
 *	SP16 modifications
 *	
# Revision 1.1  2000/11/09  23:39:02  pinnacle
# Created: vds/emsfixes/model/EMssredrange.I by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *
 *	11/09/2000	HF	No TR/CR
 *                              Occasionally GRgraphics.GRdelete() fails for unknown reasons
 *                              (GRrtree problem ???), so, after checking channel_counts,
 *                              performs a Root.delete()...
 *                              Removed the functions EFmerge_lps_across_seam() & EFupdate_lps()
 *                              from this file, because they were left untouched...
 *
 * -------------------------------------------------------------------*/

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

#define	VD_DEBUG
#include	<VDdebug.h>

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

  __enterMethod ( name = "EMreduce_range", argfmt = "grmd_env->md_id = [%d,%d]",
                  args = `grmd_env->md_id.osnum, grmd_env->md_id.objid` );

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
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< EMSsubbs.EMpartsf() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

  if (across_seam)
  {
    EFmerge_lps_across_seam (&rc, &my_GRid, surf_old, grmd_env,
                             &partolbasis, num_lps, lp_ranges, lp_ids,
                             ls_range, across_seam);
    if ( ! (OM_stat & 1 & *EMmsg) )
      __printf("<<<<< EFmerge_lps_across_seam() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
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
      if ( ! (OM_stat & 1 & *EMmsg) )
        __printf("<<<<< EMSloopset.EMgetrange() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
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
    if ( ! (OM_stat & 1 & *EMmsg) )
      __printf("<<<<< EMSsubbs.EMpartolbasis() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
    EMerr_hndlr(!(1&*EMmsg&OM_stat), *EMmsg, EMS_E_LoopsetError,wrapup);

    OM_stat = om$send(msg = message EMSloopset.EMuv_transform( &mthd_stat,
                                                               tr_mat,
                                                               &newpartol,
                                                               NULL,
                                                               (IGRchar *)surf_old,
                                                               NULL),
                      p_chanselect = &sf_ls_chan);
    if ( ! (OM_stat & 1 & *EMmsg) )
      __printf("<<<<< EMSloopset.EMuv_transform() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
    EMerr_hndlr(!(1&*EMmsg&OM_stat), *EMmsg, EMS_E_LoopsetError,wrapup);

  }  /* Loopset Scaled */

  OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &chan_sel);
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< EMmake_chanselect(EMSrequester_to_helpers) sts = %d, msg = %#x", `OM_stat, *EMmsg`);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  to_helpers = chan_sel;

  OM_stat = om$send(msg          = message EMShelper.EMchangeSurface( EMmsg, *new_objectid),
                    p_chanselect = &chan_sel, from = MAXINT, to = 0);
  if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< EMShelper.EMchangeSurface() sts = %d, msg = %#x", `OM_stat, *EMmsg`);
  EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

  OM_stat = EMmake_chanselect (GRconnector_to_owners, &chan_sel);
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< EMmake_chanselect(GRconnector_to_owners) sts = %d, msg = %#x", `OM_stat, *EMmsg`);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  to_owners = chan_sel;

  OM_stat = om$send(msg      = message Root.move_chan( chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);

  OM_stat = EMmake_chanselect (GRnotify_notification, &chan_sel);
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< EMmake_chanselect(GRnotify_notification) sts = %d, msg = %#x", `OM_stat, *EMmsg`);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send(msg      = message Root.move_chan( chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &chan_sel);
  to_loopset = chan_sel;

  OM_stat = om$send(msg      = message Root.move_chan(chan_sel, my_id, OM_Gw_current_OS, chan_sel),
                    targetid = *new_objectid);
  if ( ! (OM_stat & 1 & *EMmsg) )
    __printf("<<<<< Root.move_chan(EMSsubbs_to_loopset) sts = %d, msg = %#x", `OM_stat, *EMmsg`);
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

//      if (cnt_helpers)
//      {
//        OM_stat = om$send(msg      = message Root.move_chan( to_helpers, my_id, OM_Gw_current_OS, to_helpers),
//                          targetid = *new_objectid);
//        om$get_channel_count(object = me, p_chanselect = &to_helpers, count = &cnt_helpers);
//      }
//      if (cnt_owners)
//      {
//        OM_stat = om$send(msg      = message Root.move_chan( to_owners, my_id, OM_Gw_current_OS, to_owners),
//                          targetid = *new_objectid);
//        om$get_channel_count(object = me, p_chanselect = &to_owners, count = &cnt_owners);
//      }
//      if (cnt_loopset)
//      {
//        OM_stat = om$send(msg      = message Root.move_chan( to_loopset, my_id, OM_Gw_current_OS, to_loopset),
//                          targetid = *new_objectid);
//        om$get_channel_count(object = me, p_chanselect = &to_loopset, count = &cnt_loopset);
//      }

    __printf("<<<<< GRgraphics.GRdelete() 1 sts = %d, msg = %#x, cnt_helpers = %d, cnt_owners = %d, cnt_loopset = %d",
             `OM_stat, *EMmsg, cnt_helpers, cnt_owners, cnt_loopset`);

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
      if ( ! (OM_stat & 1 & *EMmsg) )
        __printf("<<<<< Root.delete()         2 sts = %d, msg = %#x", `OM_stat, *EMmsg`);
    }
    else
    {
      __printf("<<<<< Do NOT Root.delete() cnt_helpers = %d, cnt_owners = %d, cnt_loopset = %d",
               `cnt_helpers, cnt_owners, cnt_loopset`);
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

  __exitMethod ( name = "EMreduce_range", argfmt = "sts = %d, msg = %#x, new_objectid = %d",
                 args = `OM_stat, *EMmsg, *new_objectid` );

  return (OM_stat);
}

end implementation EMSsubbs;
