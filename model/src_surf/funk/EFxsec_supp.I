/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "gocmacros.h"
#include "EMSopt.h"
#include "emsedgedef.h"
#include "emslpinitdef.h"
#include "bsptsoldtnw.h"
#include "bsptsnwtold.h"
#include "bsplptnorrg.h"
#include "bslocalcord.h"
#include "bsdistptpt.h"
#include "bsbx2.h"

#define EDGE_U0            0
#define EDGE_U1            2
#define BUF_SIZE           20


/*
  DESCRIPTION

      This file contains all of the functions used in creating/updating
      a cross section.

  HISTORY

      RC      09/14/88      Creation Date
      NP      08/27/92      Modified for ANSI compliance.
      NP      05/27/93      Function "EMmkintlist" is now called by a new
                            name, "EMmakeintlist", due to addition of two new
                            curve type parameters.
                            NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                                  CALL (CURRENTLY SET TO NULL).
      Sudha   07/06/93      Modified for BSprototypes ansification

*/

from EMSedge     import EMget_bcxyz_geom, EMendpts, EMgetrange, 
                        EMptproject, EMptatpr, EMget_props_type;
from EMSnatedge  import EMmake_natural_edge;
from EMSpartedge import EMpeinit;
from EMSloop     import EMtoggle_type, EMreverse, EMset_props, 
                        EMget_props, EMlpinit, EMgivenestinfo, EMtreemod;

from EMSloopset  import EMnesting, EMtreemod;

extern OMuword   OPP_EMSnatedge_class_id, OPP_EMSpartedge_class_id,
                 OPP_EMSloopset_class_id;

/*
 * Given the trace information, the following function
 * o Creates loops.
 * o Nest the nelwy created loops into the loopset.
 */

void EFmk_xsec_lps ( EFmsg, cs_env, cur_os, num_grps, num_sgrps_grp, 
                      num_elems_sgrp, elems, sgrp_rev, elem_rev, 
                      grp_clsd, sgrp_clsd, partolbasis, ls_id,  sf_id,
                      num_lps_added, lp_added_ids)

     IGRlong                 *EFmsg;
     struct        GRmd_env  *cs_env;
     GRspacenum              cur_os;
     IGRint                  num_grps, *num_sgrps_grp, **num_elems_sgrp;
     struct        EMSintobj ***elems;
     IGRboolean              **sgrp_rev, ***elem_rev, *grp_clsd, 
                             **sgrp_clsd;
     struct EMSpartolbasis   *partolbasis;
     GRobjid                 *ls_id, sf_id;
     IGRint                  *num_lps_added;
     GRobjid                 **lp_added_ids;
 {      
   OM_S_CHANSELECT               ls_sf_chan, sf_ls_chan, ls_lp_chan;
   struct          EMSintobj     *intobj_loc;
   struct          EMSsfintedpar ***intparms;
   struct          EMSnest_info  nesting;
   IGRdouble                     **par_tol;
   IGRlong                       rc, mthd_stat, OM_stat;
   IGRint                        i, j, k, lp_inx, stat;
   IGRuint                       num_cmpnts;
   extern IGRint                 EMsfintloops();
   GRspacenum                    dum_os;
   GRobjid                       **lp_sf, **endedges, lp_id;
   IGRushort             props;
   extern void                   EMsfintloops_free();

   /* ************************************************************ */

   lp_sf = NULL;
   endedges = NULL;
   intparms = NULL;
   par_tol = NULL;
   *num_lps_added = 0;
   *lp_added_ids = NULL;

   *EFmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   
   /*
    * If there is no loopset attached to the surface, make one.
    */

   if (IF_NULL_OBJID(*ls_id))
   {
    OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
    EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
        
    OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
    EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$construct(classid = OPP_EMSloopset_class_id,
                           osnum = cur_os, p_objid = ls_id);
    EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$send(msg = message Root.connect(ls_sf_chan, NULL, sf_id,
                       cur_os, sf_ls_chan, NULL),
                      senderid = NULL_OBJID, targetid = *ls_id,
                      targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

   } /* if (IF_NULL_OBJID(*ls_id)) */
 
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

      (*num_lps_added)++;

    } /* for (j = 0; j < num_sgrps_grp[i]; j++) */

  } /* for (i = 0; i < num_grps; i++) */

  /* 
   * Create the loops out of the intersections.
   */

  stat = EMsfintloops(&rc, &cs_env->md_env.matrix_type, 
                     cs_env->md_env.matrix, cur_os, NULL, 
	                 num_grps, num_sgrps_grp, num_elems_sgrp,
                     elems, sgrp_rev, elem_rev, grp_clsd,
                     sgrp_clsd, FALSE, FALSE, &lp_sf, &endedges,
                     &intparms, &par_tol);
  EMerr_hndlr(!(1&rc&stat), *EFmsg, EMS_E_Fail, wrapup);

  *lp_added_ids = (GRobjid *) om$malloc(size = *num_lps_added * 
                                   sizeof(GRobjid));
  EMerr_hndlr(!(*lp_added_ids), *EFmsg, EMS_E_NoDynamicMemory, wrapup);
                
  for(i = 0, lp_inx = 0; i < num_grps; i++)
    for(j = 0, k = 0; j< 2 * num_sgrps_grp[i]; j+=2, k++)
       (*lp_added_ids)[lp_inx++] = lp_sf[i][j];

  /* 
   * Nest all the intersection loops into the planes loopset
   */

  for(i = 0; i < *num_lps_added; i++)
  {
    OM_stat = om$send(msg = message EMSloop.EMset_props (&mthd_stat, 
                       EMLP_NEW | EMLP_SPLIT, EMS_O_OFF), 
                      senderid = NULL_OBJID,
                      targetid = (*lp_added_ids)[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);

/*
    OM_stat = om$send(msg = message EMSloop.EMget_props(&mthd_stat, 
                       &props), 
                      senderid = NULL_OBJID,
                      targetid = (*lp_added_ids)[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);
*/        
    OM_stat = om$send(msg = message EMSloop.EMlpinit (&mthd_stat,
                       NULL, partolbasis, 
                       EMLpInit_IgnoreInProps | EMLpInit_NoRange | 
                       EMLpInit_NoClosureTest ),
                      senderid = NULL_OBJID,
                      targetid = (*lp_added_ids)[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);
        
    OM_stat = om$send(msg = message EMSloop.EMgivenestinfo (&mthd_stat,
                       &nesting),
                      senderid = NULL_OBJID,
                      targetid = (*lp_added_ids)[i], targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_NestError, wrapup);

    OM_stat = om$send(msg = message EMSloopset.EMnesting (&mthd_stat,
                       &nesting, partolbasis),
                      senderid = NULL_OBJID,
                      targetid = *ls_id, targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_NestError, wrapup);
     
    if( IF_EQ_OBJID(nesting.parent,*ls_id) )
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
     
  } /* for(i = 0; i < *num_lps_added; i++) */


  /* 
   * Make all the external loops in the loopset, P_loops and 
   * toggle types of all other loops under them.
   */

  OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
  EMerr_hndlr(!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (objid = *ls_id, osnum = cur_os,
               p_chanselect = &ls_lp_chan, count = &num_cmpnts);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  
  for (i = 0; i < num_cmpnts; i++)
  {
    OM_stat = om$get_objid_at_index (osnum = cur_os, objid = *ls_id,
                 p_chanselect = &ls_lp_chan, index = i, 
                 objidaddr = &lp_id, osnumaddr = &dum_os);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$send(msg = message EMSloop.EMtoggle_type (&mthd_stat, 
                       TRUE, FALSE, *ls_id, EMTogType_SendInner, NULL,
                       NULL, NULL, NULL, NULL, NULL),
                      senderid = NULL_OBJID, targetid = lp_id, 
                      targetos = cur_os);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError,wrapup);

  } /* for (i = 0; i < num_cmpnts; i++) */

wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFmk_xsec_lps");
  if (lp_sf) EMsfintloops_free (lp_sf, endedges, intparms, par_tol);

  return;

} /* void EFmk_xsec_lps () */

void   EFsave_xs_assoc_info (EFmsg, xs_assoc_info, new_sf_id, 
                             new_ed_ids, num_eds)

 IGRlong                     *EFmsg;
 struct  EMSxs_assoc_info    *xs_assoc_info;
 GRobjid                     new_sf_id, *new_ed_ids;
 IGRint                      num_eds;

{
  IGRlong       rc;
  IGRint        cur_sf = 0, arrsz, num_bytes, fr_inx = 0, i,
                INITIAL_SIZE , BUF_INC;

  IGRboolean    sf_exists = FALSE;
  extern void   EFmemory_allocation();

  *EFmsg = EMS_S_Success;
  while (cur_sf < xs_assoc_info->num_sfs && !sf_exists)
  {
    if (IF_EQ_OBJID (new_sf_id, xs_assoc_info->sf_list[cur_sf]) )
      sf_exists = TRUE;
    else cur_sf++;
  }

  INITIAL_SIZE = 10; BUF_INC = 2;
  if (!sf_exists)
  {
    arrsz = xs_assoc_info->sf_list_arrsz;
    EFmemory_allocation (&rc, (IGRchar **) &xs_assoc_info->sf_list, 
                         xs_assoc_info->num_sfs + 1,
                         &arrsz, sizeof(GRobjid), INITIAL_SIZE,
                         BUF_INC);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

    EFmemory_allocation (&rc, (IGRchar **) &xs_assoc_info->num_eds_sf, 
                         xs_assoc_info->num_sfs + 1,
                         &xs_assoc_info->sf_list_arrsz, sizeof(IGRint), 
                         INITIAL_SIZE, BUF_INC);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  } /* if (!sf_exists) */

  INITIAL_SIZE = 10; BUF_INC = 5;
  EFmemory_allocation (&rc, (IGRchar **) &xs_assoc_info->ed_list, 
                       xs_assoc_info->num_eds + num_eds,
                       &xs_assoc_info->ed_list_arrsz, sizeof(GRobjid),
                       INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  if (sf_exists)
  {
    num_bytes = 0;
    for (i = cur_sf+1; i < xs_assoc_info->num_sfs; i++)
     num_bytes += xs_assoc_info->num_eds_sf[i];

    if (num_bytes)
    {
      num_bytes *= sizeof(GRobjid);
      for (i = 0; i < cur_sf+1; i++)
        fr_inx += xs_assoc_info->num_eds_sf[i];
      OM_BLOCK_MOVE (&xs_assoc_info->ed_list[fr_inx], 
                    &xs_assoc_info->ed_list[fr_inx+num_eds], num_bytes);

    } /* if (num_bytes) */
    else fr_inx = xs_assoc_info->num_eds;

    for (i = 0; i < num_eds; i++)
      xs_assoc_info->ed_list[fr_inx+i] = new_ed_ids[i];
    xs_assoc_info->num_eds_sf[cur_sf] += num_eds;
    xs_assoc_info->num_eds += num_eds;

  } /* if (sf_exists) */
  else
  {
    xs_assoc_info->sf_list[cur_sf] = new_sf_id;
    xs_assoc_info->num_sfs++;
    for (i = 0; i < num_eds; i++)
      xs_assoc_info->ed_list[xs_assoc_info->num_eds + i] = new_ed_ids[i];
    xs_assoc_info->num_eds += num_eds;
    xs_assoc_info->num_eds_sf[cur_sf] = num_eds;

  } /* else for if (sf_exists) */

 wrapup:
  return; 

} /* void   EFsave_xs_assoc_info () */


void EFadd_ed_to_trace_list (EFmsg, ed_id, xp_GRid, xp_gm, xs_env, 
                             xp_inters)

     IGRlong                    *EFmsg;
     GRobjid                    ed_id;
     struct     GRid            *xp_GRid;
     struct     IGRbsp_surface  *xp_gm;
     struct     GRmd_env        *xs_env;
     struct     EMSinters       **xp_inters;

{
  struct EMSdataselect    ed_xyz_data, ed_uv_data;
  struct IGRbsp_curve     *ed_xyz_gm = NULL;
  struct GRid             *ed_GRid = NULL;
  IGRlong                 OM_stat, mthd_stat, rc;

  extern struct EMSintobj *EMmakeintlist();

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ed_xyz_gm = (struct IGRbsp_curve *) om$malloc (
                                      size = sizeof(struct IGRbsp_curve));
  EMerr_hndlr (!ed_xyz_gm, *EFmsg, EMS_E_NoDynamicMemory,wrapup);

  ed_xyz_gm->poles = ed_xyz_gm->knots = ed_xyz_gm->weights = NULL;
  OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                      &mthd_stat, &xs_env->md_env, xp_GRid,
                      xp_gm, NULL, MAXINT, FALSE, NULL, ed_xyz_gm),
                     senderid = NULL_OBJID,
                     targetid = ed_id, targetos = xp_GRid->osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_EdgeError, wrapup);

  ed_xyz_data.datatype = EMSdata_curve3d;
  ed_xyz_data.data.curve = ed_xyz_gm;

  ed_GRid = (struct GRid *) om$malloc (size = sizeof(struct GRid));
  EMerr_hndlr (!ed_GRid, *EFmsg, EMS_E_NoDynamicMemory,wrapup);

  ed_GRid->objid = ed_id;
  ed_GRid->osnum = xp_GRid->osnum;
  ed_uv_data.datatype = EMSdata_object;
  ed_uv_data.data.object = ed_GRid;

  EMmakeintlist (&rc, xp_inters, NULL, xp_GRid, NULL, 
               (IGRchar *)xp_gm, NULL, NULL,NULL,&ed_xyz_data,
               &ed_uv_data, NULL, FALSE, FALSE, NULL, NULL, NULL,
               NULL, NULL, NULL, TRUE, FALSE);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFadd_ed_to_trace_list");
   return;

} /* void EFadd_ed_to_trace_list () */


void EFcreate_eds_to_cls_grps (EFmsg, num_grps, grp_clsd, num_sgrps_grp,
                               num_elems_sgrp, elems, 
                               xs_assoc_info, xp_GRid, xp_gm, par_tol, 
                               xs_env, 
                               xp_inters, update_assoc_info)

   IGRlong                         *EFmsg;
   IGRint                          num_grps, *num_sgrps_grp, 
                                   **num_elems_sgrp;

   IGRboolean                      *grp_clsd;
   struct      EMSintobj           ***elems;
   struct      EMSxs_assoc_info    *xs_assoc_info;
   struct      GRid                *xp_GRid;
   struct      IGRbsp_surface      *xp_gm;
   IGRdouble                       par_tol;
   struct      GRmd_env            *xs_env;
   struct      EMSinters           **xp_inters;
   IGRboolean                      update_assoc_info;
{

  OM_S_CHANSELECT         to_comps, to_owners;
  struct    EMSedgebound  ed_bnd[2];
  IGRdouble               *ed_u0_pts = NULL, *ed_u1_pts = NULL, 
                          *ed_pts;
  extern IGRdouble        fabs();
  IGRlong                 OM_stat, mthd_stat, rc;
  IGRint                  i, j, num_ed_pts, num_ed_u1_pts = 0,
                          num_ed_u0_pts = 0, pt_inx;
  IGRushort       ped_props;
  GRspacenum              cur_os;
  GRobjid                 ned_id, ped_id;
  
  IGRuchar        ed_cv_type = EMlinesegment;
  IGRuchar        ed_loc;

  extern void             EFsave_xs_assoc_info (), 
                          EFadd_ed_to_trace_list (),
                          EFget_grp_end_pts_matching_w_ed_U0_U1 ();
  /* *************************************************************** */


  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  cur_os = xp_GRid->osnum;

  /*
   * o Get the end points of the open groups. There will be
   *   only one subgroup/group. Therefore, end point of a group
   *   is the same as that of its subgroup.
   * o sort these end points on u=0 and u=1 edge.
   * o Create part of natural edges for each pair of sorted list
   *   of end points. The end points should be sorted in increasing
   *   value of v for u=0 and in decreasing value of v for u = 1.
   * o Trace the intersections again.
   */
 
  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owners);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  EFget_grp_end_pts_matching_w_ed_U0_U1 ( &rc, num_grps, grp_clsd,
                   num_sgrps_grp, num_elems_sgrp, elems, par_tol, 
                   &ed_u0_pts,
                   &ed_u1_pts, &num_ed_u0_pts, &num_ed_u1_pts);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  for (i = 0; i < 2; i++)
  {
    ed_loc = i ? EDGE_U1 : EDGE_U0;
    num_ed_pts = i ? num_ed_u1_pts : num_ed_u0_pts;
    ed_pts = i ? ed_u1_pts : ed_u0_pts;
  
    if (num_ed_pts)
    {
      /*
       * o Construct a natural edge.
       * o Construct a part of natural edge for each pair.
       */

      OM_stat = om$construct (classid = OPP_EMSnatedge_class_id,
                     osnum = cur_os, p_objid = &ned_id,
                     msg = message EMSnatedge.EMmake_natural_edge (
                     &mthd_stat, ed_loc, &ed_cv_type, NULL));
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

      ed_bnd[0].span_inx = ed_bnd[1].span_inx = 0;
      ped_props = EMED_NATURAL | EMED_OPEN;

      for (pt_inx = 0; pt_inx < num_ed_pts; pt_inx += 2)
      {
        if (num_ed_pts == 2 && 
            ( i ? fabs(ed_pts[1] - 1) <= par_tol :
                  fabs(ed_pts[1] - 0) <= par_tol ) &&
            ( i ? fabs(ed_pts[3] - 0) <= par_tol :
                  fabs(ed_pts[3] - 1) <= par_tol) )
          ped_id = ned_id;
        else
        {
          ed_bnd[0].param = i ? (1 - ed_pts[2*pt_inx+1]) :
                                ed_pts[2*pt_inx+1];
          ed_bnd[1].param = i ? (1 - ed_pts[2*pt_inx+3]) :
                                ed_pts[2*pt_inx+3];

          OM_stat = om$construct (classid = OPP_EMSpartedge_class_id,
                       osnum = cur_os, p_objid = &ped_id,
                       msg = message EMSpartedge.EMpeinit (
                        &mthd_stat, ped_props, ed_bnd, ed_cv_type)); 
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

          OM_stat = om$send (msg = message Root.connect (to_comps,
                              OM_K_MAXINT, ned_id, cur_os, 
                              to_owners, NULL),
                             senderid = NULL_OBJID,
                             targetid = ped_id, targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

        } /* if (num_ed_pts == 2 && (ed_pts[1] == i ? 1. : 0.) &&
                 (ed_pts[3] == i ? 0. : 1.) ) */

        if (update_assoc_info)
        {
          EFsave_xs_assoc_info (&rc, xs_assoc_info, xp_GRid->objid,
                                &ped_id, 1);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
        }

        EFadd_ed_to_trace_list (&rc, ped_id, xp_GRid, xp_gm, xs_env, 
                                xp_inters);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

      } /* for (pt_inx = 0; pt_inx < num_ed_pts; pt_inx += 2) */

    } /* if (num_ed_pts) */

  } /* for (i = 0; i < 2; i++) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFcreate_eds_to_cls_grps");
  if (ed_u0_pts) om$dealloc (ptr = ed_u0_pts);
  if (ed_u1_pts) om$dealloc (ptr = ed_u1_pts);
  return;

} /* void EFcreate_eds_to_cls_grps () */

void EFsort_gr_end_pts (EFmsg, end_pt, pts_array, num_pts,
                        ascending_sort)
     
     IGRlong             *EFmsg;
     IGRdouble           *end_pt;
     IGRdouble           *pts_array;
     IGRint              *num_pts;
     IGRboolean          ascending_sort;
{
  IGRint pt_inx, num_bytes;

  *EFmsg = EMS_S_Success;

  if (end_pt[1] < 0. || end_pt[1] > 1.0 )
  {
    *EFmsg = EMS_E_InvalidArg; return;
  } 

  for (pt_inx = 0; pt_inx < *num_pts; pt_inx++)
  {
    if (end_pt[1] == pts_array[pt_inx*2+1]) return;
    else if (ascending_sort ? (end_pt[1] < pts_array[pt_inx*2+1]) :
             (end_pt[1] > pts_array[pt_inx*2+1]))  break;

  } /* for (pt_inx = 0; pt_inx < *num_pts; pt_inx++) */

  num_bytes = (*num_pts - pt_inx) * sizeof(IGRdouble) * 2;
  if (num_bytes)
   OM_BLOCK_MOVE (&pts_array[pt_inx*2], &pts_array[(pt_inx+1)*2], 
                  num_bytes);

  OM_BLOCK_MOVE (end_pt, &pts_array[pt_inx*2], sizeof(IGRdouble)*2);
  (*num_pts)++;

} /* void EFsort_gr_end_pts () */

void EFconstruct_xs_plane (
     EFmsg,
     mdl_range,
     seg_pts,
     pl_nrml,
     win_zvec,
     scale,
     pl_gm,
     pl_mdl_int)

    IGRlong                   *EFmsg;
    GRrange                   mdl_range;
    IGRdouble                 *seg_pts;
    IGRdouble                 *pl_nrml;
    IGRdouble                 *win_zvec;
    IGRdouble                 scale;
    struct    IGRbsp_surface  *pl_gm;
    IGRboolean                *pl_mdl_int;
{
  IGRdouble          temp_pt[3], tmat[3][3], seg_len;
  GRrange            pl_range;
  IGRlong            rc, num_pts;
  IGRint             i;
  IGRboolean         status, right_hand = 1;

 *EFmsg = rc = EMS_S_Success;

 /*
  * Construct a plane defined by a point and plane normal and encompassing
  * model range.
  */

 BSplptnorrg ( mdl_range, &mdl_range[3], seg_pts, pl_nrml, scale,
               pl_mdl_int, pl_gm, &rc);
 EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

 if (*pl_mdl_int)
 { 
  /*
   * o Transform the plane such that 
   *   o the plane segment becomes x_axis. 
   *   o win_zvec becomes y_axis.
   *   o plane normal becomes z_axis.
   * o Get min/max y_corrdinate of the plane.
   * o Get the min/max x_coordinate of the segment.
   * o Modify the plane geomtery to have shape of the the above
   *   range box.
   * o Transform the modified plane back. This is the xs_plane to
   *   be used.
   */

   for (i = 0; i < 3; i++)
     temp_pt[i] = seg_pts[i] + win_zvec[i];

   status = BSlocalcord (&rc, seg_pts, &seg_pts[3], temp_pt, 
                         &right_hand, tmat);
   EMerr_hndlr(!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

   BSptsoldtnw (seg_pts, tmat, 1.0, 4, FALSE, (IGRpoint *)pl_gm->poles, NULL, 
                (IGRpoint *)pl_gm->poles, &rc);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   num_pts = 4;
   status = BSbx2 (&rc, &num_pts, (IGRpoint *)pl_gm->poles, NULL, pl_range,
                   &pl_range[3]);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   seg_len = BSdistptpt (&rc, seg_pts, &seg_pts[3]);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   if ( (pl_range[0] <= 0. && pl_range[3] <= 0.) ||
        (pl_range[0] >= seg_len && pl_range[3] >= seg_len) )
   {
     *pl_mdl_int = TRUE;
   }
   else
   {
    pl_gm->poles[0] = pl_gm->poles[6] = 0.;
    pl_gm->poles[3] = pl_gm->poles[9] = seg_len;

    pl_gm->poles[1] = pl_gm->poles[4] = pl_range[1];
    pl_gm->poles[7] = pl_gm->poles[10] = pl_range[4];

    BSptsnwtold (seg_pts, tmat, 1.0, 4, FALSE, (IGRpoint *)pl_gm->poles, NULL, 
                 (IGRpoint *)pl_gm->poles, &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   } /* else for if ( (pl_range[0] <= 0. && pl_range[3] <= 0.) ...... */

 } /* if (*pl_mdl_int) */

 wrapup:
  EMWRAPUP (*EFmsg, *EFmsg, "In EFconstruct_xs_plane")
  return;
   
} /* void EFconstruct_xs_plane () */

void EFperform_old_new_int_correlation ( EFmsg, cur_os, new_int, old_int,
       sfs_md_info, partolbasis, ed_match_info)

 IGRlong                    *EFmsg;
 GRspacenum                 cur_os;
 struct EMSxs_assoc_info    *new_int, *old_int;
 struct EMSsfs_md_info      *sfs_md_info;
 struct EMSpartolbasis      *partolbasis;
 struct EMSxs_ed_match_info *ed_match_info;
{
 IGRlong              rc;
 IGRint               oeds_inx, sf_inx, num_sf_oeds, i, 
                      neds_inx, num_sf_neds;
 IGRboolean           is_sf_tp_md, new_int_exist;
 GRobjid              sf_id, *sf_oeds, *sf_neds;
 extern void          EFperform_tp_correlation();

 *EFmsg = EMS_S_Success;
 
 oeds_inx = 0;
 for (sf_inx = 0; sf_inx < old_int->num_sfs; sf_inx++)
 {
   sf_id = old_int->sf_list[sf_inx];
   num_sf_oeds = old_int->num_eds_sf[sf_inx];
   sf_oeds = &old_int->ed_list[oeds_inx];

   neds_inx = 0;
   new_int_exist = FALSE;
   for (i = 0; i < new_int->num_sfs; neds_inx += new_int->num_eds_sf[i],
        i++)
   {
     if (sf_id == new_int->sf_list[i])
     {
       num_sf_neds = new_int->num_eds_sf[i];
       sf_neds = &new_int->ed_list[neds_inx];
       new_int_exist = TRUE;
       break;
     }
   } /* for (i = 0; i < new_int->num_sfs; 
             neds_inx += new_int->num_eds_sf[i], i++) */

   if (new_int_exist)
   {
     is_sf_tp_md = TRUE;
     for (i = 0; i < sfs_md_info->num_sfs_gm_md; i++)
       if (sf_id == sfs_md_info->sfs_gm_md[i].objid)
       {
         is_sf_tp_md = FALSE;
         break;
       }

     if (is_sf_tp_md)
     {
       EFperform_tp_correlation (&rc, sf_id, cur_os, num_sf_oeds, sf_oeds,
               num_sf_neds, sf_neds, partolbasis, ed_match_info);
       EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     } /* if (is_sf_tp_md) */

   } /* if (new_int_exist) */

   oeds_inx += old_int->num_eds_sf[sf_inx];   

 } /* for (sf_inx = 0; sf_inx < old_int->num_sfs; sf_inx++) */


 wrapup:
  EMWRAPUP (*EFmsg, *EFmsg, "In EFperform_old_new_int_correlation");
  return;
} /* void EFperform_old_new_int_correlation () */


void EFperform_tp_correlation (EFmsg, sf_id, cur_os, num_oeds, oed_ids,
               num_neds, ned_ids, partolbasis, ed_match_info)
  
  IGRlong                      *EFmsg;
  GRobjid                      sf_id;
  GRspacenum                   cur_os;
  IGRint                       num_oeds;
  GRobjid                      *oed_ids;
  IGRint                       num_neds;
  GRobjid                      *ned_ids;
  struct EMSpartolbasis        *partolbasis;
  struct EMSxs_ed_match_info   *ed_match_info;
{
 struct EMSedgebound       ned_mbnd;
 struct EMSxs_ed_info      *oed_info, oed_info_buf[BUF_SIZE],
                           *ned_info, ned_info_buf[BUF_SIZE],
                           *ed_info;
 struct EMSproj_info       proj_info;

 IGRdouble                 mid_pt;
 IGRlong                   OM_stat, mthd_stat, rc;

 IGRint                    INITIAL_SIZE, BUF_INC, i, num_eds, ed_inx, 
                           num_overlaps = 0, ned_inx, oed_inx, arrsz;

 GRobjid                   *ed_ids;

 IGRboolean                beg_pt_match, end_pt_match;

 extern void               EFmemory_allocation();
 
 /* **************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 oed_info = ned_info = NULL;

 /*
  * For each of old and new ed,
  * o Get its range box.
  * o Get its end pts.
  */

 if (num_oeds > BUF_SIZE)
 {
   INITIAL_SIZE = num_oeds;
   BUF_INC = arrsz = 0;
   EFmemory_allocation (&rc, (IGRchar **) &oed_info, num_oeds,
                        &arrsz, sizeof(struct EMSxs_ed_info),
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
   
 }
 else
  oed_info = oed_info_buf;

 if (num_neds > BUF_SIZE)
 {
   INITIAL_SIZE = num_neds;
   BUF_INC = arrsz = 0;
   EFmemory_allocation (&rc, (IGRchar **) &ned_info, num_neds,
                        &arrsz, sizeof(struct EMSxs_ed_info),
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
   
 }
 else
  ned_info = ned_info_buf;

 for (i = 0; i < 2; i++)
 {
   num_eds = i ? num_neds : num_oeds;
   ed_info = i ? ned_info : oed_info;
   ed_ids = i ? ned_ids : oed_ids;

   for (ed_inx = 0; ed_inx < num_eds; ed_inx++)
   {
     ed_info[ed_inx].objid = ed_ids[ed_inx];
     OM_stat = om$send (msg = message EMSedge.EMgetrange (&mthd_stat,
                         ed_info[ed_inx].range, NULL),
                        senderid = NULL_OBJID, 
                        targetid = ed_info[ed_inx].objid,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                         ed_info[ed_inx].end_pts, 
                         &ed_info[ed_inx].end_pts[2], 
                         ed_info[ed_inx].bnd, &ed_info[ed_inx].bnd[1],
                         NULL),
                        senderid = NULL_OBJID, 
                        targetid = ed_info[ed_inx].objid,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     ed_info[ed_inx].processed = FALSE;
     ed_info[ed_inx].overlap = EMSXS_NO_MATCH;

     /*
      * Increase the old edges' box by tolerance.
      */

     if (!i)
      EM2dbxinc (ed_info[ed_inx].range, partolbasis->tol);

    } /* for (ed_inx = 0; ed_inx < num_eds; ed_inx++) */

 } /* for (i = 0; i < 2; i++) */

 for (ned_inx = 0; ned_inx < num_neds; ned_inx++)
 {
   mid_pt = 0;
   for (i = 0; i < 2; i++)
    mid_pt += (ned_info[ned_inx].bnd[i].span_inx + 
               ned_info[ned_inx].bnd[i].param);
   mid_pt /= 2.;
   ned_mbnd.span_inx = mid_pt;
   ned_mbnd.param = mid_pt - ned_mbnd.span_inx;

   OM_stat = om$send (msg = message EMSedge.EMptatpr (&mthd_stat,
                       1, &ned_mbnd, NULL, ned_info[ned_inx].mid_pt),
                      senderid = NULL_OBJID,
                      targetid = ned_info[ned_inx].objid,
                      targetos = cur_os);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

   for (oed_inx = 0; oed_inx < num_oeds; oed_inx++)
   {
     if (!oed_info[oed_inx].processed)
     {
      if (EM2dbxbxint (ned_info[ned_inx].range, 
                        oed_info[oed_inx].range))
      {
        beg_pt_match = end_pt_match = FALSE;
        for (i = 0; i < 2; i++)
        {
          ned_info[ned_inx].end_pts_match[i] = FALSE;

          if (EM2ddistptpt (&ned_info[ned_inx].end_pts[2*i],
              &oed_info[oed_inx].end_pts[2*i]) <= partolbasis->tol)
          {
            if (!i) beg_pt_match = TRUE;
            else end_pt_match = TRUE;

            OM_BLOCK_MOVE (&oed_info[oed_inx].bnd[i],
               &ned_info[ned_inx].bnd[i], sizeof(struct EMSedgebound));
            ned_info[ned_inx].end_pts_match[i] = TRUE;
          }

          else
          {
            OM_stat = om$send (msg = message EMSedge.EMptproject (
                         &mthd_stat, &ned_info[ned_inx].end_pts[2*i],
                         1, &proj_info, NULL, partolbasis),
                        senderid = NULL_OBJID,
                        targetid = oed_info[oed_inx].objid,
                        targetos = cur_os);
            EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
            if (proj_info.dist <= partolbasis->tol)
            {
              if (!i) beg_pt_match = TRUE;
              else end_pt_match = TRUE;

              OM_BLOCK_MOVE (&proj_info.param,
               &ned_info[ned_inx].bnd[i], sizeof(struct EMSedgebound));

            } /* if (proj_info.dist <= partolbasis->tol) */
            else break;

          } /* else if(EM2ddistptpt(&ned_info[ned_inx].end_pts[2*i],
                   &oed_info[oed_inx].end_pts[2*i]) <= par_bastol) */

        } /* for (i = 0; i < 2; i++) */

        if (beg_pt_match && end_pt_match)
        {
          OM_stat = om$send (msg = message EMSedge.EMptproject (
                              &mthd_stat, ned_info[ned_inx].mid_pt,
                              1, &proj_info, NULL, partolbasis),
                             senderid = NULL_OBJID,
                             targetid = oed_info[oed_inx].objid,
                             targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

          if (proj_info.dist <= partolbasis->tol)
          {
           if (ned_info[ned_inx].end_pts_match[0] &&
               ned_info[ned_inx].end_pts_match[1])
           {
             ned_info[ned_inx].overlap = EMSXS_OLD_NEW_ED_MATCH_FULLY;
             oed_info[oed_inx].processed = TRUE;
           }
           else
             ned_info[ned_inx].overlap = EMSXS_NEW_ED_PART_OF_OLD_ED;

           ned_info[ned_inx].oed_id = oed_info[oed_inx].objid;
           num_overlaps++;
           break;

          } /* if (proj_info.dist < partolbasis->tol) */

        } /* if (beg_pt_match && end_pt_match) */

      } /* if (EM2dbxbxint (ned_info[ned_inx].range, 
                        oed_info[oed_inx].range) */
      
     } /* if (!oed_info[oed_inx].processed) */

   } /* for (oed_inx = 0; oed_inx < num_oeds; oed_inx++) */

 } /* for (ned_inx = 0; ned_inx < num_neds; ned_inx++) */

 if (num_overlaps)
 {
  num_eds = ed_match_info->num_eds;
  for (ned_inx = 0; ned_inx < num_neds; ned_inx++)
  {
   if (ned_info[ned_inx].overlap == EMSXS_NEW_ED_PART_OF_OLD_ED ||
       ned_info[ned_inx].overlap == EMSXS_OLD_NEW_ED_MATCH_FULLY)
   {
     ed_match_info->old_ed_ids[num_eds] = ned_info[ned_inx].oed_id;
     ed_match_info->new_ed_ids[num_eds] = ned_info[ned_inx].objid;
     ed_match_info->match_type[num_eds] = ned_info[ned_inx].overlap;
     OM_BLOCK_MOVE (ned_info[ned_inx].bnd, 
                    &ed_match_info->ed_bnds[2 * num_eds], 
                    sizeof(struct EMSedgebound) * 2);
     num_eds++;

   } /* if (ned_info[ned_inx].overlap == EMSXS_NEW_ED_PART_OF_OLD_ED ||
            ned_info[ned_inx].overlap == EMSXS_OLD_NEW_ED_MATCH_FULLY) */

  } /* for (ned_inx = 0; ned_inx < num_neds; ned_inx++) */
   
  ed_match_info->num_eds = num_eds;

 } /* if (num_overlaps) */
 
 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFperform_tp_correaltion");

  if (num_neds > BUF_SIZE) om$dealloc (ptr = ned_info);
  if (num_oeds > BUF_SIZE) om$dealloc (ptr = oed_info);

  return;

} /* void EFperform_tp_correlation () */

void EFupdate_assoc_inters (EFmsg, xp_inters, xs_assoc_info, 
                       delete_inters_entry, delete_assoc_entry,
                       ed_id, rpl_ed_id, sf_id, cur_os)

  IGRlong                  *EFmsg;
  struct  EMSinters        *xp_inters;
  struct  EMSxs_assoc_info *xs_assoc_info;
  IGRboolean               delete_inters_entry, delete_assoc_entry;
  GRobjid                  ed_id, rpl_ed_id, sf_id;
  GRspacenum               cur_os;
{
  struct    EMSintobj  *intobj_ptr, **next_intobj_loc;
  IGRlong              mthd_stat, OM_stat, rc;
  IGRint               ed_inx = 0, sf_inx, i, num_bytes;
  extern void          EMintobj_data_free(), EMintobj_free(), 
                       EMsfintedpar_free();


  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * Update xs_assoc_info 
   */

  for (sf_inx = 0; sf_inx < xs_assoc_info->num_sfs; sf_inx++)
  {
   if ( xs_assoc_info->sf_list[sf_inx] == sf_id )
   {
     for (i = 0; i < xs_assoc_info->num_eds_sf[sf_inx]; i++)
     {
       if ( ed_id == xs_assoc_info->ed_list[ed_inx + i] )
       {
         if ( delete_assoc_entry )
         {
           num_bytes = (xs_assoc_info->num_eds - ed_inx - i - 1) * 
                       sizeof(GRobjid);

           if (num_bytes)

             OM_BLOCK_MOVE (&xs_assoc_info->ed_list[ ed_inx + i + 1 ],
                            &xs_assoc_info->ed_list[ed_inx+i], num_bytes);

           xs_assoc_info->num_eds_sf[sf_inx]--;
           xs_assoc_info->num_eds--;

           if ( !xs_assoc_info->num_eds_sf[sf_inx] )
           {
             num_bytes = (xs_assoc_info->num_sfs - sf_inx - 1) * 
                         sizeof(GRobjid);

             if (num_bytes)
             {
               OM_BLOCK_MOVE (&xs_assoc_info->sf_list[sf_inx+1], 
                              &xs_assoc_info->sf_list[sf_inx], num_bytes);

               num_bytes = (xs_assoc_info->num_sfs - sf_inx - 1) * 
                           sizeof(IGRint);
               OM_BLOCK_MOVE (&xs_assoc_info->num_eds_sf[sf_inx+1], 
                          &xs_assoc_info->num_eds_sf[sf_inx], num_bytes);

             } /* if (num_bytes) */

             xs_assoc_info->num_sfs--;

           } /* if ( !xs_assoc_info->num_eds_sf[sf_inx] ) */

         } /* if ( delete_assoc_entry ) */
         else
         {
           xs_assoc_info->ed_list[ed_inx + i] = rpl_ed_id;

         } /* else for if ( delete_assoc_entry ) */

         break;

       } /* if ( ed_id == xs_assoc_info->ed_list[ed_inx + i] ) */

     } /* for (i = 0; i < xs_assoc_info->num_eds_sf[sf_inx]; i++) */
     break;

   } /* if ( xs_assoc_info->sf_list[sf_inx] == sf_id ) */

   ed_inx += xs_assoc_info->num_eds_sf[sf_inx];

  } /* for (sf_inx = 0; sf_inx < xs_assoc_info->num_sfs; sf_inx++) */

  /*
   * Update xp_inters.
   */

  intobj_ptr = xp_inters->cvs;
  next_intobj_loc = &xp_inters->cvs;
  for (i = 0; i < xp_inters->num_cvs; i++)
  {
    if (intobj_ptr->this_uvintobj.data.object->objid == ed_id) break;
    else
    {
     next_intobj_loc = &intobj_ptr->next;
     intobj_ptr = intobj_ptr->next;
    }

  } /* for (i = 0; i < xp_inters->num_cvs; i++) */

  if (delete_inters_entry)
  {
    *next_intobj_loc = intobj_ptr->next;
    EMintobj_data_free (&rc, intobj_ptr, 1, EMsfintedpar_free);
    EMintobj_free (intobj_ptr, 1);
    xp_inters->num_cvs--;
 
  } /* if (delete_inters_entry) */
  else
  {
     intobj_ptr->this_uvintobj.data.object->objid = rpl_ed_id;

     OM_stat = om$send (msg = message Root.delete (1),
                        senderid = NULL_OBJID, targetid = ed_id,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  } /* else for if (delete_inters_entry) */

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFupdate_assoc_inters");
   return;

} /* void EFupdate_assoc_inters () */


void EFupdate_new_int ( EFmsg, old_ed_id, new_ed_id, match_type, ed_bnds,
                        xp_inters, xs_assoc_info, sf_id, cur_os, old_eds,
                        num_old_eds)

  IGRlong                    *EFmsg;
  GRobjid                    old_ed_id, new_ed_id;
  IGRshort                   match_type;
  struct   EMSedgebound      *ed_bnds;
  struct   EMSinters         *xp_inters;
  struct   EMSxs_assoc_info  *xs_assoc_info;
  GRobjid                    sf_id;
  GRspacenum                 cur_os;
  GRobjid                    *old_eds;
  IGRint                     *num_old_eds;
{

  OM_S_CHANSELECT    to_owners_chan, to_comps_chan;  
  IGRlong            OM_stat, mthd_stat, rc;
  IGRushort  ed_props;
  GRobjid            rpl_ed;
  IGRuchar   ed_cv_type;
  extern   void     EFupdate_assoc_inters();

  /* ******************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owners_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  switch (match_type)
  {

    case EMSXS_OLD_NEW_ED_MATCH_FULLY:
           
     /*
      * Take out the new_ed from the my_assoc_info as it is 
      * replaced by a old edge. Also replace the new_ed with
      * the old_ed in xp_inters.
      */
 
     EFupdate_assoc_inters (&rc, xp_inters, xs_assoc_info, FALSE,
                            TRUE, new_ed_id, old_ed_id, sf_id, cur_os);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
     
     break;

    case EMSXS_NEW_ED_PART_OF_OLD_ED:

     OM_stat = om$send (msg = message EMSedge.EMget_props_type (
                         &mthd_stat, &ed_props, &ed_cv_type),
                        senderid = NULL_OBJID, 
                        targetid = new_ed_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_EdgeError,wrapup);

     OM_stat = om$construct (classid = OPP_EMSpartedge_class_id,
                             osnum = cur_os, p_objid = &rpl_ed,
                             msg = message EMSpartedge.EMpeinit ( 
                              &mthd_stat, ed_props, ed_bnds, ed_cv_type));
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_OMerror, wrapup);

     OM_stat = om$send (msg = message Root.connect (to_comps_chan,
                         OM_K_MAXINT, old_ed_id, cur_os, to_owners_chan, 
                         NULL),
                        senderid = NULL_OBJID,
                        targetid = rpl_ed, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  
     /*
      * Replace the new edge by the above constructed partial edge
      * in xp_inters and my_assoc_info.
      */

     EFupdate_assoc_inters (&rc, xp_inters, xs_assoc_info, FALSE,
                             FALSE, new_ed_id, rpl_ed, sf_id, cur_os);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
     
     old_eds[(*num_old_eds)++] = rpl_ed;
     break;

    case EMSXS_OLD_ED_PART_OF_NEW_ED:
    default:
      fprintf (stderr, "match_type is wrong\n");
      EMerr_hndlr (FALSE, *EFmsg, EMS_E_Fail, wrapup);

  } /* switch (match_type) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFupdate_new_int");
  return;

} /* void EFupdate_new_int ( ) */

void EFget_grp_end_pts_matching_w_ed_U0_U1 ( EFmsg, num_grps, grp_clsd,
                   num_sgrps_grp, num_elems_sgrp, elems, par_tol, 
                   ed_u0_pts, ed_u1_pts, num_ed_u0_pts, num_ed_u1_pts)

   IGRlong                  *EFmsg;
   IGRint                   num_grps, *num_sgrps_grp, **num_elems_sgrp;
   IGRboolean               *grp_clsd;
   struct      EMSintobj    ***elems;
   IGRdouble                par_tol, **ed_u0_pts, **ed_u1_pts;
   IGRint                   *num_ed_u0_pts, *num_ed_u1_pts;  

 {
  IGRdouble           ed_end_pts[4];
  extern  IGRdouble   fabs();
  struct  EMSintobj   *grp_first_elem, *grp_last_elem;
  struct  GRid        *ed_GRid;
  IGRlong             OM_stat, mthd_stat, rc;
  IGRint              grp_inx, i, j;
  extern void         EFsort_gr_end_pts();  

  /* ******************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * The maximum number of points of group that can 
   * end on edges U0 and/or edge U1 is 2.
   */

  *ed_u0_pts = (IGRdouble *) om$malloc (
                             size = num_grps * 4 * sizeof(IGRdouble));
  EMerr_hndlr (!(*ed_u0_pts), *EFmsg, EMS_E_NoDynamicMemory,wrapup);

  *ed_u1_pts = (IGRdouble *) om$malloc (
                             size = num_grps * 4 * sizeof(IGRdouble));
  EMerr_hndlr (!(*ed_u1_pts), *EFmsg, EMS_E_NoDynamicMemory,wrapup);

  for (grp_inx = 0; grp_inx < num_grps; grp_inx++)
  {
   if (!grp_clsd[grp_inx])
   {
    grp_first_elem = elems[grp_inx][0];       
    grp_last_elem = elems[grp_inx][num_sgrps_grp[grp_inx]-1];

    for (i = 1;i < num_elems_sgrp[grp_inx][num_sgrps_grp[grp_inx]-1]; i++)
     grp_last_elem = grp_last_elem->next;
       
    for (i = 0; i < 2; i++)
    {
      ed_GRid = i ? grp_last_elem->this_uvintobj.data.object :
                    grp_first_elem->this_uvintobj.data.object;

      OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                          ed_end_pts, &ed_end_pts[2], NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = ed_GRid->objid, 
                      targetos = ed_GRid->osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup); 
       
      for (j = 0; j < 2; j++)
      {  
        if ( fabs(ed_end_pts[2*j] - 0.) <= par_tol )
           EFsort_gr_end_pts (&rc, &ed_end_pts[2*j], *ed_u0_pts, 
                              num_ed_u0_pts, TRUE);

        else if ( fabs (ed_end_pts[2*j] - 1.0) <= par_tol )
           EFsort_gr_end_pts (&rc, &ed_end_pts[2*j], *ed_u1_pts, 
                              num_ed_u1_pts, FALSE);
      } /* for (j = 0; j < 2; j++) */
 
    } /* for (i = 0; i < 2; i++) */

   } /* if (!grp_clsd[grp_inx]) */

  } /* for (grp_inx = 0; grp_inx < num_grps; grp_inx++) */

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFget_grp_end_pts_matching_w_ed_U0_U1");
   return;

 } /* void EFget_grp_end_pts_matching_w_ed_U0_U1 () */

 void EFget_xhatch_tr_mat (EFmsg, hatch_angle, sf_ogm, sf_ngm, matrix)
      IGRlong                  *EFmsg;
      IGRdouble                hatch_angle;
      struct  IGRbsp_surface   *sf_ogm, *sf_ngm;
      IGRdouble                matrix[16];
{
  struct  IGRbsp_surface     xsf_ogm, xsf_ngm;
  IGRdouble                  u_knots[8], v_knots[8], poles[24];
  IGRlong                    OM_stat, rc;
  IGRboolean                 status;
  extern IGRboolean          EFget_xh_sf_geom(), EFsrf1uv_to_srf2uv();

  *EFmsg = EMS_S_Success;

  xsf_ogm.u_knots = u_knots;
  xsf_ogm.v_knots = v_knots;
  xsf_ogm.poles = poles;
  xsf_ngm.u_knots = &u_knots[4];
  xsf_ngm.v_knots = &v_knots[4];
  xsf_ngm.poles = &poles[12];
  
  status = EFget_xh_sf_geom (&rc, hatch_angle, NULL, NULL, sf_ogm,
                             &xsf_ogm);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
  status = EFget_xh_sf_geom (&rc, hatch_angle, NULL, NULL, sf_ngm,
                             &xsf_ngm);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
  status = EFsrf1uv_to_srf2uv (&xsf_ogm, &xsf_ngm, matrix, &rc);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  wrapup:
   EMWRAPUP (*EFmsg, *EFmsg, "In EFget_xhatch_tr_mat");
  return;
}

end implementation EMSxsplane;
