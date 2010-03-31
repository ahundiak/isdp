/*
  DESCRIPTION

    This function performs the rolling ball fillet blending of any three 
    edge vertex (all non-neutral) where all the three edges are rounded.
    There are no restrictions on the radii specified on the individual
    edges.

  ARGUMENTS

    fillet_patch	- Input/Output: Id of the composite surface to which
                           the blends/patches generated herein
                           will be appended to.

    fillet_inters	- Input/Output: The "intersections" between the
                           the fillets and the patches generated herein
                           are recorded in this list.

    model_inters	- Input/Output: The "intersections" between the
                           the fillets/patches and the model generated herein
                           are recorded in this list.

  HISTORY

    Inasu  :  Long ago   :  Creation
    SS     :  05/29/92   :  Re-write
    NP     :  05/27/93   :  Function "EMmkintlist" is now called by a new
                            name, "EMmakeintlist", due to addition of two new
                            curve type parameters.
                            NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                                  CALL (CURRENTLY SET TO NULL).
    Sudha     06/23/93      Modified for BSprototype ansification
*/

class implementation EMSsfrndbool;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSprop.h"
#include "REgencompsf.h"
#include "emssfintdef.h"
#include "mabcendpts.h"
#include "bssfkttol2.h"
#include "bsrev_cv.h"
#include "bspartofcv.h"
#include "bsparameters.h"
#include "bsmdistptcv.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"
#include "bssfeval.h"
#include "bsmdistcvcv.h"
#include "bsdotp.h"

#define  U 0
#define  V 1

#define  U0    0
#define  V1    1
#define  U1    2
#define  V0    3

#define CONST_U  1
#define CONST_V  2

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3

#define START  0
#define STOP   1

#define DEGEN      0
#define NON_DEGEN  1

#define FILLET_BLEND  0
#define FILLET_MODEL  1

#define  LIMITING_INC_ANG  PI/180.0*10.0

from EMSsubbs import EMget_edges;
from EMSloopset import EMlsparttrim;
from EMSedge import EMget_props, EMget_bcxyz_geom;

%safe
static IGRboolean chkatend();
%endsafe

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRlong EM3edge_rolling_ball (msg, options, const_list, vtx_rnd_info,
                              fillet_patch, fillet_inters, model_inters)
IGRlong *msg;
IGRushort options;
struct GRvg_construct *const_list;
struct EMSvtx_rnd_info *vtx_rnd_info;
struct GRid *fillet_patch;
struct EMSinters **fillet_inters, **model_inters;
{
  IGRboolean homogenous, pair, fbsf1, fbsf2;
  IGRboolean general_fillet_blend;
  IGRboolean on_end[2], tst_plan, onsrf, found, in_error, has_seam_edge,
             continue_on_error;
  IGRushort fill_blend_props, fbsf1_props, fbsf2_props, loc_opts, *propsptr,
            trim_opts;
  IGRushort props, ed_props;
  IGRshort num_intvls, num_pars, isodir;
  IGRint i, j, k, count, inx, roll_inx, min_inx, pair_inx, non_homog_inx, 
         edge_inx, other_inx, edge_prev, edge_next, num_vtx_edges;
  IGRint deg_side, non_deg_side, four=4;
  IGRint fbsf1_inx1, fbsf1_inx2, fbsf2_inx1, fbsf2_inx2;
  IGRlong msg_loc, stat_OM;
  IGRdouble radius, radii[3], pair_radius, min_radius, non_homog_radius;
  IGRdouble uvtol, chttol, mindist, startpar, stoppar, temppar, *pars, *intvls;
  IGRdouble u, v, *pts, inc_sfpars[3][2], inc_fillpars[3][2][2];
  IGRpoint inc_pt[3], endpt[2], uvendpt[2], startpt, stoppt;
  GRobjid *objptr, inc_sfobjs[3], fill_blend_obj, sfobj, fbsf1_obj, fbsf2_obj;
  GRspacenum os;
  struct GRid *idptr, ids[2], natids[4], tmpid, sfid1, sfid2;
  struct IGRbsp_curve *cv, *pcv, *fbsf1_v_isocv[2], *fbsf2_v_isocv[2], ed_geom;
  struct IGRbsp_surface *srf, *sf1, *sf2, *fbsf1_sf, *fbsf2_sf;
  struct IGRbsp_surface *inc_sfs[3], **srfptr, *srfptr_mem[1], *fill_blend_sf;
  struct IGRbsp_curve *inc_isocvs[3][2];
  struct IGRpolyline *py;
  struct EMSpypoint *py_bdry;
  struct EMSedge_rnd_info **edge_infos;
  struct EMSdataselect xyzdata, uvdata[2], *fbsf1_v_mapdata;
  struct EMSsfintedpar *bdry_parms[2];
  struct EMSpartolbasis partolbasis;
  struct EMSinters *loc_fillet_inters, *loc_model_inters;
  enum EMSedge_config edge_config, *edge_configs;
  OM_S_CHANSELECT chan_to_loopset;
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern struct EMSintobj *EMmakeintlist();

  IGRint num_int_pts;
  IGRdouble *int_pts_par1, *int_pts_par2, min_dist;
  IGRpoint *int_pts1, *int_pts2;
  struct GRmd_env *md_env;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  os = const_list->env_info->md_id.osnum;
  md_env = const_list->env_info;
  for (i=FIRST; i<=THIRD; i++)
    for (j=FIRST; j<=SECOND; j++)
      inc_isocvs[i][j] = NULL;
  fbsf1_v_isocv[FIRST] = fbsf1_v_isocv[SECOND] = NULL;
  fbsf2_v_isocv[FIRST] = fbsf2_v_isocv[SECOND] = NULL;
  bdry_parms[FIRST] = bdry_parms[SECOND] = NULL;
  pars = intvls = NULL;
  cv = pcv = NULL;
  fbsf1_obj = fbsf2_obj = NULL_OBJID;
  loc_fillet_inters = loc_model_inters = NULL;
  py_bdry = NULL;

  ed_geom.poles = NULL;
  ed_geom.knots = NULL;
  ed_geom.weights = NULL;

  /*
   * This should be a vertex with three edges and all should be being
   * rounded.
   */

  has_seam_edge = FALSE;
  edge_infos = vtx_rnd_info->edge_infos;
  edge_configs = vtx_rnd_info->edge_configs;
  num_vtx_edges = vtx_rnd_info->num_edges;
  if ( vtx_rnd_info->num_edges == 4 )
    {
    for (i=FIRST; i<vtx_rnd_info->num_edges; i++)
      {
      if (!edge_infos[i])
        {
        edge_inx = i;
        break;
        }
      }
    stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, &ed_props),
                             senderid = NULL_OBJID,
                             targetos = os,
                             targetid = vtx_rnd_info->edge_ids[edge_inx]);
    EMerr_hndlr( !( 1 & stat_OM & msg_loc ), *msg, EMS_E_EdgeError, ret_end );
    stat_OM = om$send( msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                                     &md_env->md_env, NULL, NULL, ( IGRint ) 0,
                                     MAXINT, FALSE, NULL, &ed_geom ),
                         senderid = NULL_OBJID,
                         targetos = os,
                         targetid = vtx_rnd_info->edge_ids[edge_inx] );
    EMerr_hndlr( !( msg_loc & stat_OM & 1 ), *msg, msg_loc, ret_end );

  
    if (ed_props & EMED_SEAM)
      has_seam_edge = TRUE;
    if (!has_seam_edge)
      EMerr_hndlr (vtx_rnd_info->num_edges != 3, *msg, EMS_E_InvalidArg,
                   ret_end);
    if (!has_seam_edge)
      for (i=FIRST; i<=THIRD; i++)
        EMerr_hndlr (!edge_infos[i], *msg, EMS_E_InvalidArg, ret_end);
  
    if (has_seam_edge)
      {
      homogenous = FALSE;
      edge_prev = (edge_inx == 0) ? (num_vtx_edges - 1) : (edge_inx - 1);
      edge_next = (edge_inx == (num_vtx_edges - 1)) ? 0 : (edge_inx + 1);
      other_inx = (edge_next == (num_vtx_edges - 1)) ? 0 : (edge_next + 1);
  
      radii[edge_next] = edge_infos[edge_next]->radius;
      radii[other_inx] = edge_infos[other_inx]->radius;
      radii[edge_prev] = edge_infos[edge_prev]->radius;
      if ((edge_configs[edge_prev] != edge_configs[edge_next]) &&
          (radii[edge_prev] != radii[edge_next]))
        {
        *msg = EMS_E_InvalidArg; 
        goto ret_end;
        }
      non_homog_inx = other_inx;
      non_homog_radius = radii[other_inx];
      pair = TRUE;
      pair_inx = edge_prev;
      pair_radius = radii[edge_prev];
      if ((non_homog_radius > radii[edge_next]) ||
                              (non_homog_radius > radii[edge_prev]))
        {
        *msg = EMS_E_InvalidArg; 
        goto ret_end;
        }
      goto included_data;
      }
    }
  else
    {
    EMerr_hndlr (vtx_rnd_info->num_edges != 3, *msg, EMS_E_InvalidArg, ret_end);
    for (i=FIRST; i<=THIRD; i++)
      EMerr_hndlr (!edge_infos[i], *msg, EMS_E_InvalidArg, ret_end);
    }
    
  /*
   * Get relevant information about the kind of vertex and the radii
   * being used to round the edges. Figure out whether the vertex is
   * homogenous or not. Obtain the minimum radii of the three and the
   * edge index where it occurs. Also, determine if there is a pair 
   * of radii that are the same. If so, retain the index of the first
   * edge (out of the pair) that belongs to the pair. (If all the radii
   * are the same, this is an error condition for this case).
   */

  edge_config = edge_configs[FIRST];
  EMerr_hndlr (edge_config != EMSedge_convex && edge_config != EMSedge_concave,
               *msg, EMS_E_InvalidArg, ret_end);
  radii[FIRST] = edge_infos[FIRST]->radius;
  homogenous = TRUE;
  for (i=SECOND; i<=THIRD; i++)
    {
    EMerr_hndlr (edge_configs[i] != EMSedge_convex && 
     edge_configs[i] != EMSedge_concave, *msg, EMS_E_InvalidArg, ret_end);

    radii[i] = edge_infos[i]->radius;    
    if (edge_config != edge_configs[i])
      homogenous = FALSE;
    }

  if (!homogenous)
    {
    if (edge_configs[SECOND] == edge_configs[THIRD])
      {
      non_homog_inx = FIRST;
      non_homog_radius = radii[FIRST];
      }
    for (i=SECOND; i<=THIRD; i++)
      {
      if (edge_configs[(i+1)%3] == edge_configs[(i+2)%3])
        {
        non_homog_inx = i;
        non_homog_radius = radii[i];
        }
      }
    }

  min_inx = FIRST;
  min_radius = radii[FIRST];
  pair = FALSE;
  if (radii[FIRST] == radii[SECOND])
    {
    pair = TRUE;
    pair_inx = FIRST;
    pair_radius = radii[FIRST];
    }
  for (i=SECOND; i<=THIRD; i++)
    {
    if (radii[i] < min_radius)
      {
      min_inx = i;
      min_radius = radii[i];
      }
    if (radii[i] == radii[(i+1)%3])
      {
      pair = TRUE;
      pair_inx = i;
      pair_radius = radii[i];
      }
    }
  if (pair && (radii[(pair_inx+2)%3] == radii[pair_inx]))
    {
    if (!homogenous)
      {
      pair_inx = (non_homog_inx+1)%3;
      pair_radius = radii[pair_inx];
      }
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }

  /*
   * Obtain the information about the surfaces contained between the
   * edges. Also obtain the intersection points of the iso-curves of
   * of the corresponding fillets on these surfaces. Also obtain the
   * iso-curves of the fillets that lie on these included surfaces.
   */

included_data:
  continue_on_error = FALSE;
  for (i=FIRST; i<=THIRD; i++)
    {
    k = i;
    if (has_seam_edge)
      if (i == edge_inx)
        i = edge_next;
    if (has_seam_edge)
      j = (k+1)%4;
    else
      j = (k+1)%3;
    if (has_seam_edge)
      {
      if (!edge_infos[j])
        {
        j = edge_next;
        continue_on_error = TRUE;
        }
      }
    EMget_rnd_included_data (&msg_loc, edge_infos[i], edge_infos[j],
     vtx_rnd_info->vtx_pt, &inc_sfobjs[k], &inc_sfs[k],
     inc_sfpars[k], inc_fillpars[k], inc_isocvs[k], inc_pt[k]);
    if (!continue_on_error)
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    if (!has_seam_edge)
      trim_opts = EMS_TRIM_AGAINST_NATBDRY;
    else
      trim_opts = NULL;

  /*
   * Obtain the blend-fillets that fill up the vertex. These blend-fillets
   * are generated between the fillets and the model-surfaces and
   * are later, appropriately trimmed away to define the vertex. 
   *
   * In the homogenous vertex case, three cases arise:
   *   1) (r1 = r2) < r3,
   *   2) (r1 = r2) > r3 and
   *   3) r1 > r2 > r3.
   * Case (1) is treated specially. The ball that rolls thus defining the
   * fillet-blend is the one with radius = r1, r2. The others fall into the
   * category of the most general solution, wherein the ball that rolls
   * is the one with radius = r3. Note that (r1 = r2 = r3) is not a case
   * for a rolling ball solution but the spherical blend.
   *
   * In the non-homogenous case - two convex (r1, r2) and one concave (r3) -
   * the following cases arise:
   *   1) r1 = r2 = r3,
   *   2) (r1 = r2) > r3,
   *   3) (r1 = r2) < r3,
   *   4) (r1 = r3) < r2,
   *   5) (r1 = r3) > r2 and
   *   6) r1 > r2 > r3.
   * Cases (1, 2) are treated specially. The ball that rolls thus defining
   * the fillet-blend is the one with radius = r1, r2. The others fall into
   * the category of the most general solution, wherein the ball that rolls
   * is the one with radius = r3.
   */

  fbsf1 = FALSE;
  fbsf2 = FALSE;

  if ((homogenous && pair && min_radius == pair_radius) ||
      (!homogenous && pair && (pair_inx == (non_homog_inx+1)%3) && 
       non_homog_radius <= min_radius) || has_seam_edge)
    {
    /* 
     * Here the ball defining one of the fillets belonging to the "pair"
     * rolls to the other of the pair, along the fillet that does not
     * belong to the pair. It is supported throughout by the model-surface
     * contained between the edges that correspond to the fillets of the pair.
     */

    if (has_seam_edge)
      {
      fbsf1_inx1 = other_inx;
      fbsf1_inx2 = pair_inx;
      roll_inx = pair_inx;
      }
    else
      {
      roll_inx = pair_inx;
      fbsf1_inx1 = (roll_inx + 2) % 3;
      fbsf1_inx2 = roll_inx;
      }

    sfid1.objid = edge_infos[fbsf1_inx1]->fill_id;
    sfid1.osnum = OM_Gw_current_OS;
    sf1 = edge_infos[fbsf1_inx1]->fill_surf;

    sfid2.objid = inc_sfobjs[fbsf1_inx2];
    sfid2.osnum = OM_Gw_current_OS;
    sf2 = inc_sfs[fbsf1_inx2];
 
    general_fillet_blend = FALSE;
    }
  else 
    {
    /* 
     * In general, the rolling ball of the fillet which will define the
     * fillet-blends hits one of the other fillets as it is coming into
     * the vertex. It then rolls between this fillet and the "other 
     * surface". This continues until it hits the other-other fillet.
     * After that point it rolls between the two other fillets until
     * it's locus degenerates to a point on the model-surface included
     * between the to "other" fillets. Sometimes, the rolling ball,
     * on approach to the vertex will hit the two other fillets 
     * simultaneously. In this case, the ball immediately begins to roll
     * between the two fillets. In order to detect this latter case,
     * produce these fillet-blends in the backward order. That is,
     * produce the fillet-blend between the two other fillets first (w/o
     * extension). If the non-degenerate V-iso-boundary curve spans
     * from the U-iso-boundary of one of the other fillets to the 
     * U-iso-boundary of the other of the other fillets, then this
     * simultaneous situation has occurred. In this case do not produce
     * the other fillet-blend.
     */

    if (homogenous)
      roll_inx = min_inx;
    else
      roll_inx = non_homog_inx;
    fbsf2_inx1 = (roll_inx + 1) % 3;
    fbsf2_inx2 = (roll_inx + 2) % 3;

    sfid1.objid = edge_infos[fbsf2_inx1]->fill_id;
    sfid1.osnum = OM_Gw_current_OS;
    sf1 = edge_infos[fbsf2_inx1]->fill_surf;

    sfid2.objid = edge_infos[fbsf2_inx2]->fill_id;
    sfid2.osnum = OM_Gw_current_OS;
    sf2 = edge_infos[fbsf2_inx2]->fill_surf;
 
    general_fillet_blend = TRUE;
    }

  radius = radii[roll_inx];
  loc_opts = EMS_FIL_BOUND_SURF | EMS_FIL_SURF_ORIENTED |
             EMS_FIL_SINGLE_FILLET | EMS_FIL_DEFAULT_RHO;
  if (edge_configs[roll_inx] == EMSedge_convex)
    {
    loc_opts |= sf1->pos_orient ? EMS_FIL_NATURAL_NORMAL1 : NULL;
    loc_opts |= sf2->pos_orient ? EMS_FIL_NATURAL_NORMAL2 : NULL;
    }
  else
    {
    loc_opts |= sf1->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL1;
    loc_opts |= sf2->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL2;
    }
  objptr = &fill_blend_obj;
  srfptr = srfptr_mem;
  propsptr = &fill_blend_props;

  stat_OM = EMcreate_fillet_surf1_to_surf2_const_rad (&msg_loc, loc_opts,
             const_list, &sfid1, sf1, &sfid2, sf2, radius, 0.0,
             TRUE, NULL, NULL, NULL, NULL, NULL, NULL,
             vtx_rnd_info->vtx_pt, FALSE, 0.0, 
             NULL, &objptr, &srfptr, NULL, &propsptr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  fill_blend_sf = srfptr[FIRST];

  inx = MAXINT;
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
             fillet_patch, (IGRlong *)&inx), targetid = fill_blend_obj,
             targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * If this is a general rolling ball case, check to see if this is the
   * case where a second fillet-blend surface needs to be created (between
   * an other fillet and the opposite model-surface). If so, create the
   * second fillet-blend. In any case, obtain all the fillet-blend info
   * into local variables.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);

  if (general_fillet_blend)
    {
    fbsf2 = TRUE;
    fbsf2_sf = fill_blend_sf;
    fbsf2_obj = fill_blend_obj;
    fbsf2_props = fill_blend_props;

    /*
     * One of the V-sides of the fillet just generated should taper to
     * a point. If not, force the characteristics into the one with the
     * smaller side.
     */

    tmpid.objid = fbsf2_obj;
    tmpid.osnum = os;
    EMforce_v_degeneracy (&msg_loc, fbsf2_sf, &tmpid, &fbsf2_props,
     &fbsf2_v_isocv[DEGEN], &fbsf2_v_isocv[NON_DEGEN]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Atleast one end-point of the non-degenerate iso-curve should coincide
     * with the fillet-iso-curves on the respective included surfaces. If
     * only one matches, another fillet will have to be generated to fill
     * the gap. We already know that fbsf2 has the U=0 on the fillet occuring
     * right after the one with the rolling ball (sequence in which the
     * surfaces were fed to the create-fillet function). This means that
     * we already know onto which iso-curves the respective end-points
     * may potentially fall.
     */

    MAbcendpts (&msg_loc, fbsf2_v_isocv[NON_DEGEN], endpt[START], endpt[STOP]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

    for (i=START; i<=STOP; i++)
      {
      if (i == START)
        cv = inc_isocvs[roll_inx][SECOND];
      else
        cv = inc_isocvs[(roll_inx+2)%3][FIRST];

      BSmdistptcv (cv, endpt[i], &num_intvls, &num_pars, &pars, &mindist,
       &intvls, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (mindist <= chttol)
        on_end[i] = TRUE;
      else
        on_end[i] = FALSE;

      if (pars)
        om$dealloc (ptr = pars);
      if (intvls)
        om$dealloc (ptr = intvls);
      pars = intvls = NULL;
      }
 
    EMerr_hndlr (!on_end[START] && !on_end[STOP], *msg, EMS_E_Fail, ret_end);
    if (on_end[START] ^ on_end[STOP])
      {
      if (on_end[START])
        {
        fbsf1_inx1 = (roll_inx + 2) % 3;
        fbsf1_inx2 = roll_inx;
        }
      else
        {
        fbsf1_inx1 = (roll_inx + 1) % 3;
        fbsf1_inx2 = (roll_inx + 2) % 3;
        }

      sfid1.objid = edge_infos[fbsf1_inx1]->fill_id;
      sfid1.osnum = OM_Gw_current_OS;
      sf1 = edge_infos[fbsf1_inx1]->fill_surf;

      sfid2.objid = inc_sfobjs[fbsf1_inx2];
      sfid2.osnum = OM_Gw_current_OS;
      sf2 = inc_sfs[fbsf1_inx2];
 
      radius = radii[roll_inx];
      loc_opts &= ~(EMS_RND_SF1_NATSIDE | EMS_RND_SF2_NATSIDE);
      if (edge_configs[roll_inx] == EMSedge_convex)
        {
        loc_opts |= sf1->pos_orient ? EMS_FIL_NATURAL_NORMAL1 : NULL;
        loc_opts |= sf2->pos_orient ? EMS_FIL_NATURAL_NORMAL2 : NULL;
        }
      else
        {
        loc_opts |= sf1->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL1;
        loc_opts |= sf2->pos_orient ? NULL : EMS_FIL_NATURAL_NORMAL2;
        }
      objptr = &fill_blend_obj;
      srfptr = srfptr_mem;
      propsptr = &fill_blend_props;

      stat_OM = EMcreate_fillet_surf1_to_surf2_const_rad (&msg_loc, loc_opts,
                 const_list, &sfid1, sf1, &sfid2, sf2, radius, 0.0,
                 FALSE, NULL, NULL, NULL, NULL, NULL, NULL,
                 vtx_rnd_info->vtx_pt, FALSE, 0.0, 
                 NULL, &objptr, &srfptr, NULL, &propsptr);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      fill_blend_sf = srfptr[FIRST];

      inx = MAXINT;
      stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                 fillet_patch, (IGRlong *)&inx), targetid = fill_blend_obj,
             targetos = os, senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      fbsf1 = TRUE;
      fbsf1_sf = fill_blend_sf;
      fbsf1_obj = fill_blend_obj;
      fbsf1_props = fill_blend_props;
      }
    }
  else
    {
    fbsf1 = TRUE;
    fbsf1_sf = fill_blend_sf;
    fbsf1_obj = fill_blend_obj;
    fbsf1_props = fill_blend_props;
    }

  /*
   * Process the fillet-blend surfaces. That is, add the appropriate iso-curves
   * to the intersection list and also generate the counterparts on
   * the corresponding fillet/model surfaces, adding these to the
   * intersection lists too.
   */

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

  /*
   * Process the second fillet-blend surface, if it 
   * exists.
   */

  if (fbsf2)
    {
    /*
     * Obtain the natural-edges making up the topology
     * for this fillet-blend surface.
     */

    idptr = natids;
    count = 0;
    stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc, MAXINT,
               EMS_OPT_NATURAL, const_list->env_info, &idptr, &four, &count),
               targetid = fbsf2_obj, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM) || count != 4, *msg,
     EMS_E_Fail, ret_end);

    /*
     * Process the degenerate end of this fillet-blend surface.
     * The degenerate curve in xyz, is already available from a previous
     * step.
     */

    xyzdata.datatype = EMSdata_curve3d;
    xyzdata.data.curve = fbsf2_v_isocv[DEGEN];
    fbsf2_v_isocv[DEGEN] = NULL;

    /*
     * The correspoding uv-data is the degenerate edge object. It's
     * incident information is not required as no splitting will
     * be done here.
     */

    deg_side = fbsf2_props & EMSfillet_v0_is_degenerate ? V0 : V1;
    uvdata[FIRST].datatype = EMSdata_object;
    idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
    EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
    *idptr = natids[deg_side];
    uvdata[FIRST].data.object = idptr;

    bdry_parms[FIRST] = EMsfintedpar_malloc (&msg_loc, 2);
    EMerr_hndlr (!bdry_parms[FIRST], *msg, EMS_E_NoDynamicMemory, ret_end);

    /*
     * The intersection node is created. Because of the degeneracy, no
     * counterpart is required on the model.
     */

    props = EMSintobj_marked | EMSintobj_xyzdegenerate;
    ids[FILLET_BLEND].objid = fbsf2_obj;
    ids[FILLET_BLEND].osnum = OM_Gw_current_OS;
    EMmakeintlist (&msg_loc, &loc_fillet_inters, NULL,
     &ids[FILLET_BLEND], NULL, NULL, NULL, NULL, NULL,
     &xyzdata, &uvdata[FIRST], NULL,
     FALSE, FALSE,
     bdry_parms[FIRST], NULL,
     props, NULL, NULL, NULL, TRUE, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    bdry_parms[FIRST] = NULL;

    /* 
     * Process the U sides of this fillet-blend.
     */

    for (i=0, j=U0; i<2; i++, j=U1)
      {
      /*
       * Obtain the xyz-data for the U-side
       */

      BSalloccv (fbsf2_sf->v_order, fbsf2_sf->v_num_poles, fbsf2_sf->rational, 
       0, &cv, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
      u = (IGRdouble) i;
      tst_plan = TRUE;
      isodir = CONST_U;
      BSconstprcv (&msg_loc, fbsf2_sf, &isodir, &u, &tst_plan, cv);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      xyzdata.datatype = EMSdata_curve3d;
      if (j == U1)
        BSrev_cv (&msg_loc, cv);
      xyzdata.data.curve = cv;
      cv = NULL;

      /*
       * Obtain the uv-data for the U-side of the fillet-blend. This
       * will be the natural edge itself. Also obtain the more-info
       * consisting of the two EMSsfintedpars set to NULL.
       */

      uvdata[FILLET_BLEND].datatype = EMSdata_object;
      idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
      EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
      *idptr = natids[j];
      uvdata[FILLET_BLEND].data.object = idptr;

      bdry_parms[FILLET_BLEND] = EMsfintedpar_malloc (&msg_loc, 2);
      EMerr_hndlr (!bdry_parms[FILLET_BLEND], *msg, EMS_E_NoDynamicMemory,
       ret_end);

      /*
       * Obtain the corresponding uv-data on the fillet on which the
       * ball has rolled. Also, obtain the bdry-parameters for the
       * fillet-model intersections (the info on where they intersect the
       * topology).
       */

      if (j == U0)
        inx = fbsf2_inx1;
      else
        inx = fbsf2_inx2;

      srf = edge_infos[inx]->fill_surf;
      uvtol = edge_infos[inx]->fill_surf_tol;
      tst_plan = EMS_O_Unknown;
      EMmapcvxyz_to_uv (&msg_loc, trim_opts, srf, &xyzdata,
       chttol, uvtol,
       &tst_plan, &uvdata[FILLET_MODEL], &onsrf);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      partolbasis.is_valid = TRUE;
      partolbasis.tol = uvtol;
      count = 0;
      stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                 &uvdata[FILLET_MODEL], &partolbasis, NULL, &count, NULL,
                 &bdry_parms[FILLET_MODEL]),
                 p_chanselect = &chan_to_loopset,
                 senderid = edge_infos[inx]->fill_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (count > 1, *msg, EMS_E_NotSupported, ret_end);

      /*
       * Add to the intersection lists
       */

      ids[FILLET_BLEND].objid = fbsf2_obj;
      ids[FILLET_BLEND].osnum = OM_Gw_current_OS;

      ids[FILLET_MODEL].objid = edge_infos[inx]->fill_id;
      ids[FILLET_MODEL].osnum = OM_Gw_current_OS;

      EMmakeintlist (&msg_loc, &loc_fillet_inters, &loc_fillet_inters,
       &ids[FILLET_BLEND], &ids[FILLET_MODEL], NULL, NULL, NULL, NULL,
       &xyzdata, &uvdata[FILLET_BLEND], &uvdata[FILLET_MODEL],
       FALSE, !(fbsf2_sf->pos_orient ^ srf->pos_orient),
       bdry_parms[FILLET_BLEND], bdry_parms[FILLET_MODEL],
       EMSintobj_marked | EMSintobj_isocurve | EMSintobj_tangent, 
       EMSintobj_tangent,
       NULL, NULL, TRUE, FALSE);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      bdry_parms[FILLET_BLEND] = NULL;
      bdry_parms[FILLET_MODEL] = NULL;
      }

    /* 
     * Process the non-degenerate V side of the fillet-blend. 
     * First, get the xyz-curve-data.
     */
      
    xyzdata.datatype = EMSdata_curve3d;
    non_deg_side = fbsf2_props & EMSfillet_v0_is_degenerate ? V1 : V0;
    if (non_deg_side == V0)
      BSrev_cv (&msg_loc, fbsf2_v_isocv[NON_DEGEN]);
    xyzdata.data.curve = fbsf2_v_isocv[NON_DEGEN];
    fbsf2_v_isocv[NON_DEGEN] = NULL;

    /*
     * Obtain the uv-data for the V-side of the fillet-blend. This
     * will be the natural edge itself. Also obtain the more-info
     * consisting of the two EMSsfintedpars set to NULL.
     */

    uvdata[FILLET_BLEND].datatype = EMSdata_object;
    idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
    EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
    *idptr = natids[non_deg_side];
    uvdata[FILLET_BLEND].data.object = idptr;

    bdry_parms[FILLET_BLEND] = EMsfintedpar_malloc (&msg_loc, 2);
    EMerr_hndlr (!bdry_parms[FILLET_BLEND], *msg, EMS_E_NoDynamicMemory,
     ret_end);

    /*
     * Obtain the corresponding uv-data on the primary/first fillet-blend
     * (if any) or on the fillet-model which corresponds to the "rolling
     * edge". Also, obtain the bdry-parameters for the fillet-model
     * intersections (the info on where they intersect the model topology).
     * If the projection is onto the primary fillet-blend, then NULL
     * boundaries would suffice.
     */

    if (fbsf1)
      {
      srf = fbsf1_sf;
      BSsfkttol2 (srf->u_order, srf->v_order, srf->u_knots, srf->v_knots,
       srf->u_num_poles, srf->v_num_poles, srf->poles, srf->weights,
       &uvtol, &msg_loc);
      }
    else
      {
      srf = edge_infos[roll_inx]->fill_surf;
      uvtol = edge_infos[roll_inx]->fill_surf_tol;
      }
    tst_plan = EMS_O_Unknown;
    EMmapcvxyz_to_uv (&msg_loc, trim_opts, srf, &xyzdata,
     chttol, uvtol,
     &tst_plan, &uvdata[FILLET_MODEL], &onsrf);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
    if (fbsf1)
      {
      bdry_parms[FILLET_MODEL] = EMsfintedpar_malloc (&msg_loc, 2);
      EMerr_hndlr (!bdry_parms[FILLET_MODEL], *msg, EMS_E_NoDynamicMemory,
       ret_end);

      fbsf1_v_mapdata = &uvdata[FILLET_MODEL];
      }
    else
      {
      partolbasis.is_valid = TRUE;
      partolbasis.tol = uvtol;
      count = 0;
      stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                 &uvdata[FILLET_MODEL], &partolbasis, NULL, &count, NULL,
                 &bdry_parms[FILLET_MODEL]),
                 p_chanselect = &chan_to_loopset,
                 senderid = edge_infos[roll_inx]->fill_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (count > 1, *msg, EMS_E_NotSupported, ret_end);
      }

    /*
     * Add to the intersection lists
     */

    ids[FILLET_BLEND].objid = fbsf2_obj;
    ids[FILLET_BLEND].osnum = OM_Gw_current_OS;

    if (fbsf1)
      {
      ids[FILLET_MODEL].objid = fbsf1_obj;
      ids[FILLET_MODEL].osnum = OM_Gw_current_OS;
      }
    else
      {
      ids[FILLET_MODEL].objid = edge_infos[roll_inx]->fill_id;
      ids[FILLET_MODEL].osnum = OM_Gw_current_OS;
      }

    EMmakeintlist (&msg_loc, &loc_fillet_inters, &loc_fillet_inters,
     &ids[FILLET_BLEND], &ids[FILLET_MODEL], NULL, NULL, NULL, NULL,
     &xyzdata, &uvdata[FILLET_BLEND], &uvdata[FILLET_MODEL],
     FALSE, !(fbsf2_sf->pos_orient ^ srf->pos_orient),
     bdry_parms[FILLET_BLEND], bdry_parms[FILLET_MODEL],
     EMSintobj_marked | EMSintobj_isocurve | EMSintobj_tangent, 
     EMSintobj_tangent,
     NULL, NULL, TRUE, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    bdry_parms[FILLET_BLEND] = NULL;
    bdry_parms[FILLET_MODEL] = NULL;
    }

  /*
   * Process the first fillet-blend surface, if it 
   * exists.
   */

  if (fbsf1)
    {
    /*
     * Obtain the natural-edges making up the topology
     * for this fillet-blend surface.
     */

    idptr = natids;
    count = 0;
    stat_OM = om$send (msg = message EMSsubbs.EMget_edges (&msg_loc, MAXINT,
               EMS_OPT_NATURAL, const_list->env_info, &idptr, &four, &count),
               targetid = fbsf1_obj, targetos = os, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM) || count != 4, *msg,
     EMS_E_Fail, ret_end);

    /*
     * Determine which V-end lies on the rolling-ball fillet. Any useful
     * information, example - the iso-curves generated for this purpose - 
     * are stored away for later use.  The start point of one of the V
     * isocurves must lie at the included-intersection point as indicated
     * in the code below.
     */

    found = FALSE;
    for (i=START, j=V0; i<=STOP; i++, j=V1)
      {
      BSalloccv (fbsf1_sf->u_order, fbsf1_sf->u_num_poles, fbsf1_sf->rational,
       0, &cv, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
      v = (IGRdouble) i;
      tst_plan = TRUE;
      isodir = CONST_V;
      BSconstprcv (&msg_loc, fbsf1_sf, &isodir, &v, &tst_plan, cv);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      MAbcendpts (&msg_loc, cv, startpt, stoppt);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

      inx = (fbsf1_inx1+1)%3 == roll_inx ? fbsf1_inx1 : roll_inx; 
      if (BSdistptpt (&msg_loc, startpt, inc_pt[inx]) <= chttol)
        {
        EMerr_hndlr (found, *msg, EMS_E_Fail, ret_end);
        found = TRUE;
        fbsf1_props |= i == START ? EMSfillet_v0_closeto_start_end : NULL;
        fbsf1_v_isocv[START] = cv;
        }
      else
        fbsf1_v_isocv[STOP] = cv;

      if (j == V0)
        BSrev_cv (&msg_loc, cv);

      cv = NULL;
      }
    EMerr_hndlr (!found, *msg, EMS_E_Fail, ret_end);

    /* 
     * Obtain the iso-boundary curves corresponding to the U sides of 
     * this fillet-blend surface. These are entered into the "fillet"
     * intersection list. If the general situation (with two fillet-blends
     * is taking place, the U-iso curve may have to be truncated since
     * only a part of this fillet will be used).
     */

    if (fbsf2)
      {
      EMgetendpts_uv (&msg_loc, fbsf1_v_mapdata, 
       (fbsf1_inx1 != fbsf2_inx1) ^ (non_deg_side == V0),
       1, uvendpt[START], uvendpt[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    for (i=START, j=U0; i<=STOP; i++, j=U1)
      {
      /*
       * Obtain the xyz-curve-data for the particular edge of the
       * fillet-blend surface.
       */
      
      BSalloccv (fbsf1_sf->v_order, fbsf1_sf->v_num_poles, fbsf1_sf->rational, 
       0, &cv, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  
      u = (IGRdouble) i;
      tst_plan = TRUE;
      isodir = CONST_U;
      BSconstprcv (&msg_loc, fbsf1_sf, &isodir, &u, &tst_plan, cv);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (fbsf2)
        {
        if (fbsf1_props & EMSfillet_v0_closeto_start_end)
          {
          startpar = 0.0;
          stoppar = uvendpt[i][V];
          }
        else
          {
          startpar = uvendpt[i][V];
          stoppar = 1.0;
          }
  
        BSalloccv (cv->order, cv->num_poles + 2*cv->order-1, cv->rational,
         0, &pcv, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        BSpartofcv (&msg_loc, cv, startpar, (startpar+stoppar)/2, stoppar,
         pcv);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 
        BSfreecv (&msg_loc, cv);
        cv = pcv;
        pcv = NULL;
        }

      if (j == U1 && !has_seam_edge)
        {
        BSrev_cv (&msg_loc, cv);
        temppar = startpar;
        startpar = stoppar;
        stoppar = temppar;
        }

      if (j == U0)
        {
        srf = edge_infos[fbsf1_inx1]->fill_surf;
        uvtol = edge_infos[fbsf1_inx1]->fill_surf_tol;
        sfobj = edge_infos[fbsf1_inx1]->fill_id;
        }
      else
        {
        srf = inc_sfs[fbsf1_inx2];
        BSsfkttol2 (srf->u_order, srf->v_order, srf->u_knots, srf->v_knots,
         srf->u_num_poles, srf->v_num_poles, srf->poles, srf->weights,
         &uvtol, &msg_loc);
        sfobj = inc_sfobjs[fbsf1_inx2];
        }

      if (has_seam_edge && (j == U1))
        {
        BSmdistcvcv (&ed_geom, cv, &num_int_pts, &int_pts_par1, &int_pts_par2,
                     &int_pts1, &int_pts2, &min_dist, &msg_loc );
        EMerr_hndlr( msg_loc != BSSUCC || num_int_pts == 0
                      || min_dist > 2*chttol, *msg, EMS_E_BSerror, ret_end );
        for (k = FIRST; k <=SECOND; k++)
          {
          if ( k == FIRST )
            {
            startpar = 0.0;
            stoppar = int_pts_par2[0];
            }
          else
            {
            startpar = int_pts_par2[0];
            stoppar = 1.0;
            }
          BSalloccv (cv->order, cv->num_poles + 2*cv->order-1, cv->rational,
                     0, &pcv, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          BSpartofcv (&msg_loc, cv, startpar, (startpar+stoppar)/2, stoppar,
                      pcv);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
          BSrev_cv (&msg_loc, pcv);
          xyzdata.datatype = EMSdata_curve3d;
          xyzdata.data.curve = pcv;
          pcv = NULL;

          uvdata[FILLET_BLEND].datatype = EMSdata_poly2d;
          py = (struct IGRpolyline *) om$malloc (size = 
                sizeof (struct IGRpolyline));
          pts = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
          EMerr_hndlr (!py || !pts, *msg, EMS_E_NoDynamicMemory, ret_end);
          py->num_points = 2;
          py->points = pts;
          pts[0] = pts[2] = u;
          pts[1] = stoppar; pts[3] = startpar;
          uvdata[FILLET_BLEND].data.poly = py;

          bdry_parms[FILLET_BLEND] = EMsfintedpar_malloc (&msg_loc, 2);
          EMerr_hndlr (!bdry_parms[FILLET_BLEND], *msg, EMS_E_NoDynamicMemory,
                       ret_end);

          tst_plan = EMS_O_Unknown;
          EMmapcvxyz_to_uv (&msg_loc, trim_opts, srf, &xyzdata,
           chttol, uvtol,
           &tst_plan, &uvdata[FILLET_MODEL], &onsrf);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    
          partolbasis.is_valid = TRUE;
          partolbasis.tol = uvtol;
          count = 0;
          stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                                           &uvdata[FILLET_MODEL], &partolbasis,
                                           NULL, &count, &py_bdry,
                                           &bdry_parms[FILLET_MODEL]),
                                   p_chanselect = &chan_to_loopset,
                                   senderid = sfobj);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
          ids[FILLET_BLEND].objid = fbsf1_obj;
          ids[FILLET_BLEND].osnum = OM_Gw_current_OS;
    
          ids[FILLET_MODEL].objid = sfobj;
          ids[FILLET_MODEL].osnum = OM_Gw_current_OS;
    
          EMmakeintlist (&msg_loc, 
           &loc_fillet_inters, &loc_model_inters,
           &ids[FILLET_BLEND], &ids[FILLET_MODEL], NULL, NULL, NULL, NULL,
           &xyzdata, &uvdata[FILLET_BLEND], &uvdata[FILLET_MODEL],
           FALSE, !(fbsf1_sf->pos_orient ^ srf->pos_orient), 
           bdry_parms[FILLET_BLEND], bdry_parms[FILLET_MODEL],
           EMSintobj_marked | EMSintobj_isocurve | EMSintobj_tangent, 
           EMSintobj_tangent,
           NULL, NULL, TRUE, FALSE);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          bdry_parms[FILLET_BLEND] = NULL;
          bdry_parms[FILLET_MODEL] = NULL;
          }
        }
      else
        {
        xyzdata.datatype = EMSdata_curve3d;
        xyzdata.data.curve = cv;
        cv = NULL;
  
        /*
         * Obtain the uv-data for this fillet blend surface. This will
         * be the natural edge if the surface is not truncated (second
         * fillet is being used) or it will be a polyline segment.
         */
  
        if (fbsf2)
          {
          uvdata[FILLET_BLEND].datatype = EMSdata_poly2d;
          py = (struct IGRpolyline *) om$malloc (size = 
                sizeof (struct IGRpolyline));
          pts = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
          EMerr_hndlr (!py || !pts, *msg, EMS_E_NoDynamicMemory, ret_end);
          py->num_points = 2;
          py->points = pts;
          pts[0] = pts[2] = u;
          pts[1] = startpar; pts[3] = stoppar;
          uvdata[FILLET_BLEND].data.poly = py;
          }
        else
          {
          uvdata[FILLET_BLEND].datatype = EMSdata_object;
          idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
          EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
          *idptr = natids[j];
          uvdata[FILLET_BLEND].data.object = idptr;
          }

        bdry_parms[FILLET_BLEND] = EMsfintedpar_malloc (&msg_loc, 2);
        EMerr_hndlr (!bdry_parms[FILLET_BLEND], *msg, EMS_E_NoDynamicMemory,
                     ret_end);

        /*
         * Obtain the uv-data for the surface on which the U-edge in question
         * lies. It could be a fillet of an edge (U0) or a surface of the
         * model (U1).
         */

        tst_plan = EMS_O_Unknown;
        EMmapcvxyz_to_uv (&msg_loc, trim_opts, srf, &xyzdata,
         chttol, uvtol,
         &tst_plan, &uvdata[FILLET_MODEL], &onsrf);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  
        partolbasis.is_valid = TRUE;
        partolbasis.tol = uvtol;
        count = 0;
        stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                   &uvdata[FILLET_MODEL], &partolbasis, NULL, &count, &py_bdry,
                   &bdry_parms[FILLET_MODEL]),
                   p_chanselect = &chan_to_loopset,
                   senderid = sfobj);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
        /*
         * We have to look for error conditions where the side of the fillet
         * to be imposed on the model interferes badly with the existing 
         * boundaries.
         */
  
        if (j == U1)
          {
          if (general_fillet_blend || homogenous)
            {
            /*
             * The boundary must not be interfered with except at the
             * ends of the uv-data.
             */
  
            in_error = count > 1 || !chkatend (&xyzdata, py_bdry, srf);
            }
          else
            {
            /*
             * If this is a not a general fillet blend (2-fillet) solution, and
             * we have a non-homogenous vertex,the ball rolls from one fillet to
             * the other along the middle third one. In this condition, it is
             * possible that the edge of the fillet on the model may cross over
             * a hole region around the vertex, and thus yield two boundaries
             * from part-trim. But we can foresee that this "error" condition
             * will be corrected when all the boundaries on this particular
             * model-surface are in and we are "closing" the new boundary, much
             * later in the processing. So in this specific case keep going.
             */
            in_error = count > 1;
            if (count > 1)
              {
              IGRint ii, rnded_inx[2];
              IGRvector tan_vecs[2];
              IGRdouble ref_dotp, dotp;

              for (ii = 0; ii < num_vtx_edges; ii++)
                {
                rnded_inx[0] = ii;
                rnded_inx[1] = (ii+1)%num_vtx_edges;
                stat_OM = EMget_edge_tangents_at_rnd_vtx (&msg_loc, md_env, 
                            vtx_rnd_info, rnded_inx, tan_vecs);
                EMerr_hndlr (!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, 
                             ret_end);
                ref_dotp = cos(LIMITING_INC_ANG);
                dotp = BSdotp( &msg_loc, tan_vecs[FIRST], tan_vecs[SECOND]);
                EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
                if (fabs(dotp) > ref_dotp)
                  {
                  in_error = FALSE;
                  break;
                  }
                }
              }
            }
          EMerr_hndlr (in_error, *msg, EMS_E_NotSupported, ret_end);
          }

        /*
         * Add to the intersection lists
         */
        ids[FILLET_BLEND].objid = fbsf1_obj;
        ids[FILLET_BLEND].osnum = OM_Gw_current_OS;
  
        ids[FILLET_MODEL].objid = sfobj;
        ids[FILLET_MODEL].osnum = OM_Gw_current_OS;
  
        EMmakeintlist (&msg_loc, 
         &loc_fillet_inters, j == U0 ? &loc_fillet_inters : &loc_model_inters,
         &ids[FILLET_BLEND], &ids[FILLET_MODEL], NULL, NULL, NULL, NULL,
         &xyzdata, &uvdata[FILLET_BLEND], &uvdata[FILLET_MODEL],
         FALSE, !(fbsf1_sf->pos_orient ^ srf->pos_orient), 
         bdry_parms[FILLET_BLEND], bdry_parms[FILLET_MODEL],
         EMSintobj_marked | EMSintobj_isocurve | EMSintobj_tangent, 
         EMSintobj_tangent,
         NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        bdry_parms[FILLET_BLEND] = NULL;
        bdry_parms[FILLET_MODEL] = NULL;
        }
      }
    /* 
     * Obtain the iso-boundary curves corresponding to the 
     * V sides of the fillet-blend. 
     */
      
    for (i=START; i<=STOP; i++)
      {
      /* 
       * If the second fillet-blend had been created, then the STOP V-iso curve
       * has already been taken care of while processing the non-deg
       * edge of the second fillet-blend. In this case, continue.
       */

      if (fbsf2 && i == STOP)
        continue;

      /*
       * Get the xyz-curve-data. These curves were already obtained
       * earlier.
       */

      xyzdata.datatype = EMSdata_curve3d;
      xyzdata.data.curve = fbsf1_v_isocv[i];
      fbsf1_v_isocv[i] = NULL;

      /*
       * Obtain the uv-data for the V-side of the fillet-blend. This
       * will be the natural edge itself. Also obtain the more-info
       * consisting of the two EMSsfintedpars set to NULL. 
       */

      if (i == START)
        j = fbsf1_props & EMSfillet_v0_closeto_start_end ? V0 : V1;
      else
        j = fbsf1_props & EMSfillet_v0_closeto_start_end ? V1 : V0;
      uvdata[FILLET_BLEND].datatype = EMSdata_object;
      idptr = (struct GRid *) om$malloc (size = sizeof (struct GRid));
      EMerr_hndlr (!idptr, *msg, EMS_E_NoDynamicMemory, ret_end);
      *idptr = natids[j];
      uvdata[FILLET_BLEND].data.object = idptr;

      bdry_parms[FILLET_BLEND] = EMsfintedpar_malloc (&msg_loc, 2);
      EMerr_hndlr (!bdry_parms[FILLET_BLEND], *msg, EMS_E_NoDynamicMemory,
       ret_end);

      /*
       * Obtain the corresponding uv-data on the fillet-model which
       * corresponds to the "rolling edge" (START) or the other of the
       * pair (STOP). Also, obtain the bdry-parameters for
       * the fillet-model intersections (the info on where they intersect the
       * fillet topology).
       */

      if (i == START)
        {
        srf = edge_infos[roll_inx]->fill_surf;
        uvtol = edge_infos[roll_inx]->fill_surf_tol;
        sfobj = edge_infos[roll_inx]->fill_id;
        }
      else
        {
        inx = (pair_inx+1)%3;
        if (has_seam_edge)
          if (!edge_infos[inx])
            inx = edge_next;
        srf = edge_infos[inx]->fill_surf;
        uvtol = edge_infos[inx]->fill_surf_tol;
        sfobj = edge_infos[inx]->fill_id;
        }

      partolbasis.is_valid = TRUE;
      partolbasis.tol = uvtol;
      tst_plan = EMS_O_Unknown;
      EMmapcvxyz_to_uv (&msg_loc, trim_opts, srf, &xyzdata,
       chttol, uvtol,
       &tst_plan, &uvdata[FILLET_MODEL], &onsrf);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      count = 0;
      stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                 &uvdata[FILLET_MODEL], &partolbasis, NULL, &count, NULL,
                 &bdry_parms[FILLET_MODEL]),
                 p_chanselect = &chan_to_loopset,
                 senderid = sfobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (count > 1, *msg, EMS_E_NotSupported, ret_end);

      /*
       * Add to the intersection lists
       */

      ids[FILLET_BLEND].objid = fbsf1_obj;
      ids[FILLET_BLEND].osnum = OM_Gw_current_OS;
  
      ids[FILLET_MODEL].objid = sfobj;
      ids[FILLET_MODEL].osnum = OM_Gw_current_OS;
  
      EMmakeintlist (&msg_loc, &loc_fillet_inters, &loc_fillet_inters,
       &ids[FILLET_BLEND], &ids[FILLET_MODEL], NULL, NULL, NULL, NULL,
       &xyzdata, &uvdata[FILLET_BLEND], &uvdata[FILLET_MODEL],
       FALSE, !(fbsf1_sf->pos_orient ^ srf->pos_orient),
       bdry_parms[FILLET_BLEND], bdry_parms[FILLET_MODEL],
       EMSintobj_marked | EMSintobj_isocurve | EMSintobj_tangent, 
       EMSintobj_tangent,
       NULL, NULL, TRUE, FALSE);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      bdry_parms[FILLET_BLEND] = NULL;
      bdry_parms[FILLET_MODEL] = NULL;
      }
    }  

  /*
   * The input inters list can now be affected by the information generated
   * here.
   */

  EMmergeinters (&msg_loc, fillet_inters, loc_fillet_inters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
  loc_fillet_inters = NULL;

  EMmergeinters (&msg_loc, model_inters, loc_model_inters);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
  loc_model_inters = NULL;

ret_end:
  for (i=FIRST; i<=SECOND; i++)
    {
    if (fbsf1_v_isocv[i])
      BSfreecv (&msg_loc, fbsf1_v_isocv[i]);
    if (fbsf2_v_isocv[i])
      BSfreecv (&msg_loc, fbsf2_v_isocv[i]);
    if (bdry_parms[i])
      EMsfintedpar_free (bdry_parms[i], MAXINT);
    }
 
  if (pars)
    om$dealloc (ptr = pars); 
  if (intvls)
    om$dealloc (ptr = intvls); 

  if( ed_geom.poles ) om$dealloc( ptr = ed_geom.poles );
  if( ed_geom.knots ) om$dealloc( ptr = ed_geom.knots );
  if( ed_geom.weights ) om$dealloc( ptr = ed_geom.weights );

  if (cv)
    BSfreecv (&msg_loc, cv);
  if (pcv)
    BSfreecv (&msg_loc, pcv);

  EMinters_free (loc_fillet_inters, MAXINT);
  EMinters_free (loc_model_inters, MAXINT);

  EMpypoint_free (py_bdry, 0);

  if (EMSerror (stat_OM & *msg))
    {
    if (!IF_NULL_OBJID (fbsf1_obj))
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
       const_list->env_info), targetid = fbsf1_obj, targetos = os,
       senderid = NULL_OBJID);

    if (!IF_NULL_OBJID (fbsf2_obj))
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, 
       const_list->env_info), targetid = fbsf2_obj, targetos = os,
       senderid = NULL_OBJID);
    }

  /*
   * If a general error has occurred in this function, and the intersection
   * lists have been left untouched we can try to get the answer via a general
   * blend solution. 
   */

  if (EMSerror (stat_OM & *msg))
    stat_OM = EMget_n_sided_blend (msg, options, const_list,
               vtx_rnd_info, fillet_patch, fillet_inters, model_inters);

  EMWRAPUP (*msg, stat_OM, "EM3edge_rolling_ball");
  return (stat_OM);
}


static IGRboolean chkatend (xyzdata, py, srf)
struct EMSdataselect *xyzdata;
struct EMSpypoint *py;
struct IGRbsp_surface *srf;
{
  IGRboolean atend, found;
  IGRshort i, j;
  IGRlong msg_loc;
  IGRdouble chttol;
  IGRpoint sfpt, endpts[2];
  extern IGRint EMgetendpts_xyz();

  atend = TRUE;
  for (i=FIRST; i<=SECOND; i++)
    {
    if (!(py->props & (EMS_PYPT_ATSTART | EMS_PYPT_ATSTOP)))
      {
      BSsfeval (srf, py->point[U], py->point[V], 0, &sfpt, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, atend, FALSE, ret_end);

      EMgetendpts_xyz (&msg_loc, NULL, NULL, xyzdata, FALSE, 1, 
       endpts[START], endpts[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), atend, FALSE, ret_end);

      BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  
      found = FALSE;
      for (j=START; j<=STOP; j++)
        if (BSdistptpt (&msg_loc, sfpt, endpts[j]) <= chttol)
          {
          found = TRUE;
          break;
          }
      EMerr_hndlr (!found, atend, FALSE, ret_end);
      }
    py = py->next;
    }

ret_end:
  return (atend);
}

end implementation EMSsfrndbool;
