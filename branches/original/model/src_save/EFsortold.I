/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include <stdio.h>
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "EMSsfintsort.h"
#include "msmacros.h"
#include "emsgeteddef.h"
#include "EMcp.h"
#include "emslpinitdef.h"

/*
 ABSTRACT
          The following function sorts the sf/sf intersections
	      as per user defined criterion. Currently, only user
	      defined points are allowed to be the sorting criteria.
	      The skin of the operand, on whose surface the point 
          is provided, is traversed and all of the new intersections
	      hit during this traversal are returned as good set of
          intersections.

 HISTORY
            RC    07/22/89       Creation Date
	    SM    19-Feb-92      Fixed uninitialized pointers.
*/


from EMSboundary import EMget_objid, EMget_edges;
from EMSloopset  import EMpt_location, EMnesting;
from EMSloop     import EMnext_edge, EMget_props, EMgivenestinfo, 
                        EMlpinit;
from EMSedge     import EMendpts;

void EFget_start_bnd_face_for_traversal (EFmsg, sortpt_info, 
                 unsort_set, csort_set, sf_tol_info, trsh_bnds_info, 
                 trsh_lps_info, trsh_faces_info, trsh_tp_objects, 
                 start_bnd, start_face, start_element_type)

 IGRlong                    *EFmsg;
 struct EMSsortpt_info      *sortpt_info;
 struct EMSint_set          *unsort_set, *csort_set;
 struct EMSsf_tol_info      *sf_tol_info;
 struct EMSgen_info         *trsh_bnds_info, *trsh_lps_info, 
                            *trsh_faces_info;
 struct EMStp_objects_info  *trsh_tp_objects;
 struct EMSsortbnd_info     **start_bnd;
 struct EMSsortfc_info      **start_face;
 IGRint                     *start_element_type;

{
 OM_S_CHANSELECT            sf_ls_chan;
 OM_S_OBJECT_LINKAGE        sf_ls_list;
 struct EMSnest_info        nest_info;
 struct EMSpartolbasis      partolbasis;
 struct EMSused_lps         used_sgrlps_info;
 struct EMSptloc_info       *ptloc_info, pt_location;
 struct EMSsorted_info      *ed_info;
 struct EMSsftracedata      *unsort_trace;
 struct EMSsfintloopsdata   *unsort_sflps;
 struct EMSsfintedpar       *lelem_intedpar;
 struct GRid                *oface_eds = NULL;
 struct EMSsortbnd_info     *face_bnd, *lp_bnd;
 struct EMSsortsgr_info     *sgr_info;
 struct EMSsortfc_info      *face_info;
 struct EMSsortlp_info      **lps_info;

 IGRdouble   pt_uv[2], par_tol, ed_parm, best_parm_so_far, lelem_ed_parm;
 IGRlong     rc, mthd_stat, OM_stat;
 IGRint      pt_oprnd, grix, sgrix, edix, lptyp, num_lps, lpix,
             oface_eds_arrsz = 0, num_oface_eds = 0, stat, count;
 GRobjid     pt_sf_id, ed_id; 
 IGRboolean  ed_parm_ascending, lp_found, stfc_found = FALSE,
             new_intersection_found = FALSE;
 GRspacenum  cur_os;

 extern IGRint  EMsend_loops();
 extern IGRboolean EFsgrlp_already_used();
 extern IGRlong EMmake_chanselect();
 extern void    EFtrash_lp_info_object(), EFget_sf_par_tol(),
                EFadd_group_to_set(), EFbuild_face(),
                EFmemory_allocation(), EFconstruct_face_info();

  /* **************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  used_sgrlps_info.num_lps = used_sgrlps_info.lps_arrsz = 0;
  used_sgrlps_info.lp_ids = NULL;

  cur_os = sortpt_info->md_env.md_id.osnum;
  ptloc_info = &sortpt_info->ptloc_info;
  
  OM_BLOCK_MOVE (ptloc_info->edge[0].nst_pt.proj_pt, pt_uv, 
                 sizeof(IGRdouble)*2);
  pt_oprnd = sortpt_info->ed_oprnd;
  pt_sf_id = sortpt_info->sf_id;

  EFget_sf_par_tol (&rc, sf_tol_info, pt_sf_id, cur_os, &par_tol);
  EMerr_hndlr(!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
  switch (ptloc_info->location)
  {

   case EMS_L_ONEDGE:
   case EMS_L_ONVRTX:

    EFget_sortbnd (trsh_bnds_info, (*start_bnd));

    ed_id = ptloc_info->edge[0].edge_id;
    ed_parm = ptloc_info->edge[0].nst_pt.param.span_inx + 
              ptloc_info->edge[0].nst_pt.param.param;

    /*
     * o if the ed_pt is within par_tol from the begin point of the edge, 
     *   the start edge starts from begin point.
     * o if the ed_pt is within par_tol from the end point of the edge,
     *   the starting edge is the next edge in the loop with begin
     *   point as the start point.
     * o Else find, the closest boundary on the edge from the ed_pt and
     *   between the begin point and the ed_pt.
     */

    (*start_bnd)->bnd_type = EMSed_bnd_wopen_end;
    ed_info = &(*start_bnd)->bnd_data.ed_info;
    ed_info->ed_id = ed_id;

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        ed_info->ed_pts, &ed_info->ed_pts[2], 
                        ed_info->ed_bounds, &ed_info->ed_bounds[1], NULL),
                       senderid = NULL_OBJID, targetid = ed_id,
                       targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    if (EM2ddistptpt ( pt_uv, ed_info->ed_pts) > par_tol)
    {
     if (EM2ddistptpt (pt_uv, &ed_info->ed_pts[2]) <= par_tol)
     {
       stat = EMsend_loops (&rc, message EMSloop.EMnext_edge (&mthd_stat,
               EMGetEd_Next, ed_id, &ed_info->ed_id), ed_id, NULL, 
               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
       EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);
     
       OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                           ed_info->ed_pts, NULL, ed_info->ed_bounds, 
                           NULL, NULL),
                          senderid = NULL_OBJID,targetid = ed_info->ed_id,
                          targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     } /* if (EM2ddistptpt (pts_loc_info[ptix].uv_pt, &ed_info->ed_p */
     else
     {
      unsort_trace = &unsort_set->trace_data[pt_oprnd];
      unsort_sflps = &unsort_set->sflp_data[pt_oprnd];

      best_parm_so_far = ed_info->ed_bounds[0].span_inx + 
                         ed_info->ed_bounds[0].param;
      ed_parm_ascending = ed_parm > best_parm_so_far ? TRUE : FALSE;

      for (grix = 0; grix < unsort_trace->num_grps; grix++)
      {
       for (sgrix = 0; sgrix<unsort_trace->num_subgrps_grp[grix]; sgrix++)
       {
        if (!unsort_trace->subgrp_closed[grix][sgrix] &&
          IF_EQ_OBJID(unsort_sflps->loop_sf[grix][2*sgrix+1], pt_sf_id) &&
          !EFsgrlp_already_used (&used_sgrlps_info, 
                                 unsort_sflps->loop_sf[grix][2*sgrix]) &&
          IF_EQ_OBJID(unsort_sflps->intedpars[grix][2*sgrix+1]->edgeid,
                      ed_id) )
        {
         lelem_intedpar = unsort_sflps->intedpars[grix][2*sgrix+1];
         lelem_ed_parm = lelem_intedpar->edgepar.span_inx +
                          lelem_intedpar->edgepar.param;

         if (ed_parm_ascending ? (lelem_ed_parm >= best_parm_so_far &&
                                 lelem_ed_parm <= ed_parm) :
                                (lelem_ed_parm <= best_parm_so_far &&
                                 lelem_ed_parm >= ed_parm) )
         {
            best_parm_so_far = lelem_ed_parm;
            ed_info->ed_bounds[0] = lelem_intedpar->edgepar;
            OM_BLOCK_MOVE (lelem_intedpar->point, ed_info->ed_pts,
                           sizeof(IGRdouble)*2);
         }
          
        } /* if (!unsort_trace->subgrp_closed[grix][sgrix]) && */

       } /* for(sgrix=0;sgrix<unsort_trace->num_subgrps_grp[grix];sgri */

      } /* for (grix = 0; grix < unsort_trace->num_grps; grix++) */

     } /* else for if (EM2ddistptpt(pts_loc_info[ptix].uv_pt, &ed_info- */

    } /* if (EM2ddistptpt ( ed_pt, ed_info->ed_pts) > par_tol) */

    *start_element_type = EMSed_bnd;
    break;

   case EMS_L_INAREA:

    /*
     * o Get all of the edges of the face, the ptloc_info loop (p_lp)
     *   is part of.
     * o Sort through all of the intersections in unsort_set. Pick
     *   one of them which is incidenting on one the edges of the face.
     *   o Build the new face using this intersection curve.
     *   o Check if the input point still lies in this new face. If
     *     so, we have got the correct face for traversal. Else,
     *     continue building faces until the correct one is reached.
     * Else
     * o If the there is no new intersection incidenting on the edges
     *   of the original face. The original face itself is the start
     *   face.
     */ 

    OM_stat = om$send (msg = message EMSboundary.EMget_edges (&mthd_stat,
                        2, EMS_OPT_ALL, &oface_eds, &oface_eds_arrsz,
                        &num_oface_eds),
                       senderid = NULL_OBJID,
                       targetid = ptloc_info->loop_id,
                       targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

    unsort_trace = &unsort_set->trace_data[pt_oprnd];
    unsort_sflps = &unsort_set->sflp_data[pt_oprnd];

    partolbasis.tol = par_tol;
    partolbasis.is_valid = partolbasis.in_world = TRUE;
    partolbasis.mattyp = sf_tol_info->mattyp;
    partolbasis.mat = sf_tol_info->matrix;

   for (grix = 0; grix < unsort_trace->num_grps && !stfc_found; grix++)
   {
    for (sgrix = 0; sgrix<unsort_trace->num_subgrps_grp[grix] &&
                    !stfc_found; sgrix++)
    {
     for (edix = 0; edix < num_oface_eds && !stfc_found; edix++)
     {
      if ( IF_EQ_OBJID(unsort_sflps->loop_sf[grix][2*sgrix+1], 
                           pt_sf_id) &&
           !EFsgrlp_already_used (&used_sgrlps_info, 
                                 unsort_sflps->loop_sf[grix][2*sgrix]) )
      {
       if (unsort_trace->subgrp_closed[grix][sgrix])
       {
        OM_stat = om$send (msg = message EMSloop.EMgivenestinfo (
                            &mthd_stat, &nest_info),
                          senderid = NULL_OBJID,
                          targetid = unsort_sflps->loop_sf[grix][2*sgrix],
                          targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

        OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
        EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

        OM_stat = om$get_channel_objects (objid = pt_sf_id, 
                     osnum = cur_os, p_chanselect = &sf_ls_chan, 
                     list = &sf_ls_list, size = 1, count = &count);
        EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

        OM_stat = om$send (msg = message EMSloopset.EMnesting (
                            &mthd_stat, &nest_info, &partolbasis),
                           senderid = NULL_OBJID,
                           targetid = sf_ls_list.S_objid, 
                           targetos = cur_os);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);
  
        if (IF_EQ_OBJID(nest_info.parent, ptloc_info->loop_id))
            new_intersection_found = TRUE;
 
       }
       else if ( IF_EQ_OBJID(
                        unsort_sflps->intedpars[grix][2*sgrix+1]->edgeid,
                        oface_eds[edix].objid) )
          new_intersection_found = TRUE;
          
       if (new_intersection_found)
       {
           EFget_sortbnd (trsh_bnds_info, face_bnd);
           face_bnd->bnd_type = EMSsgr_bnd;
           sgr_info = &face_bnd->bnd_data.sgr_info;
           sgr_info->num_elems = 
                             unsort_trace->num_elems_subgrp[grix][sgrix];
           sgr_info->sgr_rev = unsort_trace->subgrp_rev[grix][sgrix];
           sgr_info->sgr_closed =unsort_trace->subgrp_closed[grix][sgrix];
           sgr_info->lp_id = unsort_sflps->loop_sf[grix][2*sgrix];
           sgr_info->sf_id = unsort_sflps->loop_sf[grix][2*sgrix+1];
           face_bnd->next = NULL;
       
          
           EFbuild_face (&rc, face_bnd, pt_oprnd, unsort_set, csort_set,
                         pt_sf_id, cur_os, sf_tol_info, trsh_bnds_info,
                         trsh_lps_info,trsh_faces_info, &used_sgrlps_info,
                         trsh_tp_objects, &face_info, FALSE, FALSE);
           EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

           OM_stat = om$send (msg = message EMSloopset.EMpt_location (
                              &mthd_stat, pt_uv, &pt_location,
                              &partolbasis),
                             senderid = NULL_OBJID,
                             targetid = trsh_tp_objects->ls_id,
                             targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

          switch (pt_location.location)
          {
           case EMS_L_ONEDGE:
           case EMS_L_ONVRTX:
           case EMS_L_INAREA:

            /*
             * o Trash the loop objects corresponding to the p_lp
             *   and c_lps of the face.
             * o If any of the bnds of the face is using a subgroup,
             *   add the corresponding group to the csort_set.
             */

            for (lptyp = 0; lptyp < 2; lptyp++)
            {
             lps_info = lptyp ? face_info->c_lps : &face_info->p_lp;
             num_lps = lptyp ? face_info->num_c_lps : 1;

             for (lpix = 0; lpix < num_lps; lpix++)
             {
              EFtrash_lp_info_object (&rc, lps_info[lpix], cur_os, 
                                      trsh_tp_objects);
              EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

              lp_bnd = lps_info[lpix]->bnd_info;
              while (lp_bnd)
              {
               lp_found = FALSE;
               for (grix = 0; grix < unsort_trace->num_grps && !lp_found;
                    grix++)
               {
                for (sgrix = 0;sgrix < unsort_trace->num_subgrps_grp[grix]
                               && !lp_found; sgrix++)
                {
                 if (IF_EQ_OBJID(unsort_sflps->loop_sf[grix][2*sgrix],
                                 lp_bnd->bnd_data.sgr_info.lp_id))
                 {
                  lp_found = TRUE;
                  EFadd_group_to_set (&rc, csort_set, unsort_set, grix, 
                                      pt_oprnd, cur_os);
                  EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

                 }
                }
               }
               lp_bnd = lp_bnd->next;

              } /* while (lp_bnd) */
              
             } /* for (lpix = 0; lpix < num_lps; lpix++) */
             
            } /* for (lptyp = 0; lptyp < 2; lptyp++) */

            (*start_face) = face_info;
            *start_element_type = EMSface_bnd;
            stfc_found = TRUE;
            break;

           default:

            /*
             * Point does not lie in area region of the newly 
             * construct face including its boundary. 
             * o Trash its lps
             * o Trash face
             */
            
            for (lptyp = 0; lptyp < 2; lptyp++)
            {
             lps_info = lptyp ? face_info->c_lps : &face_info->p_lp;
             num_lps = lptyp ? face_info->num_c_lps : 1;

             for (lpix = 0; lpix < num_lps; lpix++)
             {
              lp_bnd = lps_info[lpix]->bnd_info;

              while (lp_bnd)
              {
               EFappend_gen_info (trsh_bnds_info, lp_bnd);
               lp_bnd = lp_bnd->next;
              }

              EFtrash_lp_info_object (&rc, lps_info[lpix], cur_os, 
                                      trsh_tp_objects);
              EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

              EFappend_gen_info (trsh_lps_info, lps_info[lpix]);

             } /* for (lpix = 0; lpix < num_lps; lpix++) */
             
            } /* for (lptyp = 0; lptyp < 2; lptyp++) */


          }  /* switch (pt_loc_info.location) */

          } /* if (new_intersection_found) */

         } /* if (!unsort_trace->subgrp_closed[grix][sgrix]) && */

        } /* for (edix = 0; edix < num_face_eds && !stfc_found; edix++) */

       } /* for(sgrix=0;sgrix<unsort_trace->num_subgrps_grp[grix];sgri */

    } /* for (grix = 0; grix < unsort_trace->num_grps && !stfc_found */

    /*
     * If the starting face is not found, there are two possibilities.
     * Either their are no new intersection on this original face or
     * the input point does not lie within in the area regions of the
     * new faces. If there are no new intersections, return the original
     * face as the start face. Otherwise, the input point is not a valid
     * point
     */

    if (!stfc_found )
    {
      if (!new_intersection_found)
      {
       EFconstruct_face_info (&rc, ptloc_info->loop_id, EMSlp_bnd, cur_os,
              trsh_bnds_info, trsh_lps_info, trsh_faces_info, start_face);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       *start_element_type = EMSface_bnd;
      }
      else
       *start_element_type = EMSno_bnd;

    } /* if (!stfc_found ) */

    break;

   default:
    *EFmsg = EMS_E_Fail;
   
  } /* switch (ptloc_info->location) */

 wrapup:
  if (used_sgrlps_info.lp_ids) om$dealloc (ptr = used_sgrlps_info.lp_ids);
  if (oface_eds) om$dealloc (ptr = oface_eds);
  EMWRAPUP (*EFmsg, OM_stat, "EFget_start_bnd_face_for_traversal");

  return;
} 

void EFconstruct_lp_info (EFmsg, lp_id, trsh_bnds_info, trsh_lps_info, 
                          lp_info, cur_os)
  IGRlong                    *EFmsg;
  GRobjid                    lp_id;
  struct EMSgen_info         *trsh_bnds_info, *trsh_lps_info; 
  struct EMSsortlp_info      **lp_info;
  GRspacenum                 cur_os;
{
  OM_S_CHANSELECT        to_comps;
  struct EMSsorted_info  *ed_info;
  struct EMSsortbnd_info **lp_bnd_ptr;
  IGRlong                OM_stat, mthd_stat;
  IGRint                 num_eds, eix;
  GRspacenum             dum_os;

  extern IGRlong  EMmake_chanselect();

  /* ************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  EFget_sortlp (trsh_lps_info, *lp_info);
  OM_stat = om$get_channel_count (osnum = cur_os, objid = lp_id,
                   p_chanselect = &to_comps, count = &num_eds);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  lp_bnd_ptr = &(*lp_info)->bnd_info;

  for (eix = 0; eix < num_eds; eix++)
  {
    EFget_sortbnd (trsh_bnds_info, *lp_bnd_ptr);

    (*lp_bnd_ptr)->bnd_type = EMSed_bnd_wfixed_end;
    ed_info = &(*lp_bnd_ptr)->bnd_data.ed_info;   

    OM_stat = om$get_objid_at_index (osnum = cur_os, objid = lp_id,
                 p_chanselect = &to_comps, index = eix, 
                 objidaddr = &ed_info->ed_id, osnumaddr = &dum_os);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        ed_info->ed_pts, &ed_info->ed_pts[2],
                        ed_info->ed_bounds, &ed_info->ed_bounds[1], NULL),
                       senderid = NULL_OBJID,
                       targetid = ed_info->ed_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError, wrapup);

    (*lp_bnd_ptr)->next = NULL;
    lp_bnd_ptr = &(*lp_bnd_ptr)->next;

  } /* for (eix = 0; eix < num_eds; eix++) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFconstruct_lp_info");
  return;

} /* EFconstruct_lp_info () */


void EFconstruct_face_info (EFmsg, inbnd_id, inbnd_type, cur_os, 
                trsh_bnds_info, trsh_lps_info, trsh_faces_info, face_info)

 IGRlong                 *EFmsg;
 GRobjid                 inbnd_id;
 IGRint                  inbnd_type;
 GRspacenum              cur_os;
 struct EMSgen_info      *trsh_bnds_info, *trsh_lps_info, 
                         *trsh_faces_info;
 struct EMSsortfc_info   **face_info; 
{

 OM_S_CHANSELECT   to_inner, to_outter;
 IGRlong           OM_stat, rc, mthd_stat;
 IGRint            stat, num_c_lps, lpix;
 IGRushort lp_props;
 GRobjid           lp_id, p_lp, c_lp;
 GRspacenum        dum_os;

 extern IGRint   EMsend_loops();

 extern void     EFconstruct_lp_info(), EFmemory_allocation();
 extern IGRlong  EMmake_chanselect();

 /* ******************************************************************* */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
 EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

 OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
 EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

 /*
  * Input boundary may an edge or a loop. If an edge, get its loop id.
  * Get the loop_type. Get the p_loop of the face this loop is a part
  * of. Construct the lp_info of the p_lp and its c_lps.
  */

 if (inbnd_type == EMSed_bnd)
 {
   stat = EMsend_loops (&rc, message EMSboundary.EMget_objid (&mthd_stat,
                       &lp_id), inbnd_id, NULL, OM_K_MAXINT, EMLP_ACTIVE, 
                       NULL, NULL);
   EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);
 } 
 else
  lp_id = inbnd_id;

 OM_stat = om$send (msg = message EMSloop.EMget_props (&mthd_stat,
                     &lp_props),
                    senderid = NULL_OBJID, targetid = lp_id,
                    targetos = cur_os);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError,wrapup);
 
 if (lp_props & EMLP_PLOOP)
  p_lp = lp_id;
 else
 {
  OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                      &p_lp), 
                     senderid = NULL_OBJID, targetid = lp_id,
                     targetos = &to_outter);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);

 } /* else for if (lp_props & EMLP_PLOOP) */

 EFget_sortface (trsh_faces_info, *face_info);
 
 EFconstruct_lp_info (&rc, p_lp, trsh_bnds_info, trsh_lps_info, 
                      &(*face_info)->p_lp, cur_os);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 OM_stat = om$get_channel_count (objid = p_lp, osnum = cur_os, 
              p_chanselect = &to_inner, count = &num_c_lps);
 EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

 if ((*face_info)->c_lps_arrsz < num_c_lps)
 {
  EFmemory_allocation (&rc, (IGRchar ***) &(*face_info)->c_lps,
           num_c_lps, &(*face_info)->c_lps_arrsz, 
           sizeof(struct EMSsortlp_info *), 10, 5);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

 } /* if ((*face_info)->c_lps_arrsz < num_c_lps) */
 
 for (lpix = 0; lpix < num_c_lps; lpix++)
 {
  OM_stat = om$get_objid_at_index (osnum = cur_os, objid = p_lp,
               p_chanselect = &to_inner, index = lpix, 
               objidaddr = &c_lp, osnumaddr = &dum_os);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  EFconstruct_lp_info (&rc, c_lp, trsh_bnds_info, trsh_lps_info, 
                       &(*face_info)->c_lps[lpix], cur_os);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
 } /* for (lpix = 0; lpix < num_c_lps; lpix++) */

 wrapup:

  EMWRAPUP (*EFmsg, OM_stat, "EFconstruct_face_info");
  return;

} /* EFconstruct_face_info () */


/*
 * Given the traced intersection data and one or more points
 * representing the portions to be saved, sort the traced data
 * into sets representing corresponding points.
 */

void EFsort_intersections (EFmsg, inters, unsort_set, sort_sets, 
              num_sort_sets, num_pts, sortpts_info, md_env, cur_os,
              num_bad_pts, bad_pts_info)

IGRlong                    *EFmsg;
struct EMSinters           *inters[2];
struct EMSint_set          *unsort_set, **sort_sets;
IGRint                     *num_sort_sets;
IGRint                     num_pts;
struct EMSsortpt_info      *sortpts_info;
struct GRmd_env            *md_env;
GRspacenum                 cur_os;
IGRint                     *num_bad_pts;
struct EMSsortpt_info      **bad_pts_info;
{
 struct EMSgen_info        trsh_bnds_info, trsh_lps_info, trsh_faces_info;
 struct EMStp_objects_info trsh_tp_objects;
 struct EMSsf_tol_info     sf_tol_info;
 struct EMSsortsf_info     *sf_info = NULL;
 struct EMSsftracedata     *sort_trace = NULL, *unsort_trace = NULL;
 struct EMSsfintloopsdata  *sort_sflps = NULL, *unsort_sflps = NULL;
 struct EMSsort_info       sort_info; 
 struct EMSsortbnd_info    *start_bnd = NULL;
 struct EMSsortfc_info     *start_face = NULL, *fc_info =NULL;
 struct EMSsortlp_info     **lps_info = NULL, *clp = NULL;
 struct EMSsortbnd_info    *lp_bnd = NULL, *lp_nxt_bnd = NULL, 
			   *bnd_info = NULL;
 struct EMSused_lps        used_sgrlps_info;
 struct EMSpartolbasis     partolbasis;

 IGRlong    OM_stat, rc, mthd_stat;

 IGRint     i, ptix, opix, grix, sgrix, sfix, fcix, lpix, lptyp, num_lps,
            bndix, peix, start_element_type;

 IGRushort lpinit_options;

 extern void   EFperform_traversal(),EFget_start_bnd_face_for_traversal(),
               EFmemory_allocation(), EFget_sf_par_tol();

 /* ****************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 *sort_sets = NULL;
 *num_sort_sets = 0;
 *num_bad_pts = 0;

 trsh_bnds_info.num_elems = trsh_bnds_info.arrsz = 0;
 trsh_bnds_info.elems = NULL;

 trsh_lps_info.num_elems = trsh_lps_info.arrsz = 0;
 trsh_lps_info.elems = NULL;

 trsh_faces_info.num_elems = trsh_faces_info.arrsz = 0;
 trsh_faces_info.elems = NULL;

 used_sgrlps_info.num_lps = used_sgrlps_info.lps_arrsz = 0;
 used_sgrlps_info.lp_ids = NULL;
 
 trsh_tp_objects.ls_id = NULL_OBJID;
 trsh_tp_objects.lp_ids = NULL;
 trsh_tp_objects.num_lps = trsh_tp_objects.lps_arrsz = 0;
 trsh_tp_objects.ped_ids = NULL;
 trsh_tp_objects.num_peds = trsh_tp_objects.peds_arrsz = 0;

 sf_tol_info.sf_ids = NULL;
 sf_tol_info.par_tols = NULL;
 sf_tol_info.num_sfs = sf_tol_info.sfs_arrsz = 0;
 sf_tol_info.mattyp = &md_env->md_env.matrix_type;
 sf_tol_info.matrix = md_env->md_env.matrix;
 
 /*
  * The maximum number of sets that can be created is the number of
  * points supplied by the user.
  */

 (*sort_sets) = (struct EMSint_set *) om$malloc (
              size = num_pts * sizeof(struct EMSint_set) );
 EMerr_hndlr (!(*sort_sets), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

 for (ptix = 0; ptix < num_pts; ptix++)
  for (opix = 0; opix < 2; opix++)
  {
   (*sort_sets)[ptix].trdata_arrsz[opix] = 0;
   sort_trace = &(*sort_sets)[ptix].trace_data[opix];
   sort_trace->num_grps = 0;
   sort_trace->num_subgrps_grp = NULL;
   sort_trace->num_elems_subgrp = NULL;
   sort_trace->elems = NULL;
   sort_trace->subgrp_rev = NULL;
   sort_trace->elem_rev = NULL;
   sort_trace->grp_closed = NULL;
   sort_trace->subgrp_closed = NULL;

   sort_sflps = &(*sort_sets)[ptix].sflp_data[opix];
   sort_sflps->loop_sf = NULL;
   sort_sflps->endedges = NULL;
   sort_sflps->intedpars = NULL;
   sort_sflps->sfpartolb = NULL;
   sort_sflps->sfintloops_alloced = FALSE;
   sort_sflps->numedsplit = 0;
   sort_sflps->commed_k_exists = TRUE;
   sort_sflps->nocommed_k_exists = FALSE;
  }

 /*
  * For each point provided by the user,
  * o Get the sf/ed on which the point is incident on.
  * o Using the above edge and the intersections on the 
  *   surface, build a loop.
  * o The loop on which the point is incident on, may be a p-loop
  *   or c-loop. And, after closing p-loop will always remain
  *   a p-loop whereas a c-loop may be a p-loop (if its owner p-loop
  *   is used in creating the new loop) or still be a c-loop.
  * o Get all of the unused closed sgrps corresponding to the surface,
  *   and try to nest them along with the new loop.
  * o If the new loop is a p-loop pick up the inner nest sgrp.
  *   On the other hand, if it is a c-loop, pick up immidiate outer loop.
  *   This will be new p-loop of the face.
  * o Now get all of the original unused c-loops of the face and check
  *   if any of them are still nested in the new face. If so, try to
  *   close them with new intersections if needed. The trimmed/untrimmed
  *   c-loops will be part of the new face.
  * o Now we have a new face. Continue trversal across the common edges
  *   of the face's loops. Since, we are not going onto the skin of the 
  *   other operand, we do not have to cross the new intersection 
  *   boundaries used in creating the face.
  */

 for (i = 0; i < 2; i++)
 {
  sort_info.num_sfs[i] = sort_info.sfs_arrsz[i] = 0;
  sort_info.sfs_info[i] = NULL;
 }

 /*
  * If a subgroup is closed and is a p_loop, its p_lp type is
  * not set. Since, the loop_type is used in creating the face,
  * set its loop_type.
  */

 partolbasis.is_valid = partolbasis.in_world = TRUE;
 partolbasis.mattyp = &md_env->md_env.matrix_type;
 partolbasis.mat = md_env->md_env.matrix;
 lpinit_options = EMLpInit_NoClosureTest | EMLpInit_NoRange |
                  EMLpInit_IgnoreInProps;

 for (opix = 0; opix < 2; opix++)
 {
  unsort_sflps = &unsort_set->sflp_data[opix];
  unsort_trace = &unsort_set->trace_data[opix];
 
  for (grix = 0; grix < unsort_trace->num_grps; grix++)
  {
   for (sgrix = 0; sgrix < unsort_trace->num_subgrps_grp[grix]; sgrix++)
   {
    if (unsort_trace->subgrp_closed[grix][sgrix])
    {
     EFget_sf_par_tol (&rc, &sf_tol_info,
         unsort_sflps->loop_sf[grix][2*sgrix+1], cur_os,&partolbasis.tol);
     EMerr_hndlr(!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
     OM_stat = om$send (msg = message EMSloop.EMlpinit (&mthd_stat, NULL,
                         &partolbasis, lpinit_options),
                        senderid = NULL_OBJID,
                        targetid = unsort_sflps->loop_sf[grix][2*sgrix],
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

    } /* if (unsort_trace->subgrp_closed[grix][sgrix]) */

   } /* for (sgrix = 0; sgrix < unsort_trace->num_subgrps_grp[grix]; */

  }/* for (grix = 0; grix < unsort_trace->num_grps; grix++) */

 } /* for (opix = 0; opix < 2; opix++) */


 /*
  * Start of sorting processes
  */

 for (ptix = 0; ptix < num_pts; ptix++)
 {
  /*
   * Either the user defined point lies on an edge or inside
   * an area region of the surface.
   *
   *  o If the input point lies on an existing edge, build a starting 
   *    boundary for traversal. The follwing steps are taken in building
   *    the starting boundary,
   *   {
   *    o Pick up the edge given the sortpts_info.
   *    o Get the new begin point of the edge/portion_of_the_edge,
   *      containing the user supplied point, that will be part of the
   *      resultant trimmed output. 
   *   }
   *   else
   *   {
   *    Point does not lie on an edge. In this case, trim the face
   *    containing the input point. Get the resultant faces and select
   *    the one which still contains the input point. This resultant face
   *    will be starting face.
   *   }
   */

  EFget_start_bnd_face_for_traversal (&rc, &sortpts_info[ptix], 
                 unsort_set, &(*sort_sets)[*num_sort_sets], &sf_tol_info, 
                 &trsh_bnds_info, &trsh_lps_info, &trsh_faces_info, 
                 &trsh_tp_objects, &start_bnd, &start_face, 
                 &start_element_type);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  /*
   * If the point does not lie in an area region, save it as a bad point.
   */

  if (start_element_type == EMSno_bnd)
  {
   /*
    * Save the bad points for the user.
    */
   
   if (!(*num_bad_pts))
   {
    *bad_pts_info = (struct EMSsortpt_info *) om$malloc (size = num_pts *
                         sizeof (struct EMSsortpt_info));
    EMerr_hndlr (!(*bad_pts_info),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
   }    

   OM_BLOCK_MOVE(&sortpts_info[ptix],&((*bad_pts_info)[(*num_bad_pts)++]),
                  sizeof(struct EMSsortpt_info));

  } /* if (start_element_type == EMSno_bnd) */
  else
  {
   /*
    * Now the starting edge with its trimmed begin point or 
    * the starting face is available for traversal. 
    * Next step is to start traversal. 
    */

   EFperform_traversal (&rc, start_bnd, start_face, start_element_type, 
     sortpts_info[ptix].sf_id, sortpts_info[ptix].ed_oprnd, unsort_set,
     &(*sort_sets)[*num_sort_sets], &sort_info, cur_os, &sf_tol_info, 
     &trsh_bnds_info, &trsh_lps_info, &trsh_faces_info, &used_sgrlps_info,
     &trsh_tp_objects);
   EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

   if ((*sort_sets)[*num_sort_sets].trace_data[sortpts_info[ptix].ed_oprnd].num_grps)
     (*num_sort_sets)++;

   /*
    * trash sort_info. Namely, face_info, lp_info and bnd_info.
    */

   for (opix = 0; opix < 2; opix++)
   {
    for (sfix = 0; sfix < sort_info.num_sfs[opix]; sfix++)
    {
     sf_info = &sort_info.sfs_info[opix][sfix];
     for (fcix = 0; fcix < sf_info->num_faces; fcix++)
     {
      fc_info = sf_info->faces_info[fcix];

      for (lptyp = 0; lptyp < 2; lptyp++)
      {
       if (lptyp)
       {
        num_lps = fc_info->num_c_lps;
        lps_info = fc_info->c_lps;
       }
       else
       {
        num_lps = 1;
        lps_info = &fc_info->p_lp;
       }

       for (lpix = 0; lpix < num_lps; lpix++)
       {
        lp_bnd = lps_info[lpix]->bnd_info;
        while (lp_bnd)
        {
         lp_nxt_bnd = lp_bnd->next;
         EFappend_gen_info (&trsh_bnds_info, lp_bnd);
         lp_bnd = lp_nxt_bnd;
        }

        EFappend_gen_info (&trsh_lps_info, lps_info[lpix]);
 
       } /* for (lpix = 0; lpix < num_lps; lpix++) */

      } /* for (lptyp = 0; lptyp < 2; lptyp++) */

      EFappend_gen_info (&trsh_faces_info, fc_info);

     } /* for (fcix = 0; fcix < sf_info->num_faces; fcix++) */

    } /* for (sfix = 0; sfix < sort_info.num_sfs[opix]; sfix++) */

    sort_info.num_sfs[opix] = 0;
   
   } /* for (opix = 0; opix < 2; opix++) */

  } /* else for if (start_element_type == EMSno_bnd) */

 } /* for (ptix = 0; ptix < num_pts; ptix++) */

wrapup:
 if(*EFmsg != EMS_E_IntersectOrient)
  {
   EMWRAPUP (*EFmsg, OM_stat, "EFsort_intersections");
  }

 /*
  * Free sort info 
  */

 for (opix = 0; opix < 2; opix++)
  if (sort_info.sfs_info[opix]) om$dealloc (ptr=sort_info.sfs_info[opix]);

 /*
  * Free trash faces info
  */

 if (trsh_faces_info.elems)
 {
  for (fcix = 0; fcix < trsh_faces_info.num_elems; fcix++)
  {
   fc_info = (struct EMSsortface_info *) trsh_faces_info.elems[fcix];
   if (fc_info->c_lps) om$dealloc (ptr = fc_info->c_lps);
   om$dealloc (ptr = fc_info);

  } /* for (fcix = 0; fcix < trsh_faces_info->num_elems; fcix++) */

  om$dealloc (ptr = trsh_faces_info.elems);

 } /* if (trsh_faces_info.elems) */
 
 /*
  * Free trash lps_info
  */

 if (trsh_lps_info.elems)
 {
  for (lpix = 0; lpix < trsh_lps_info.num_elems; lpix++)
  {
   clp = (struct EMSsortlp_info *) trsh_lps_info.elems[lpix];
   if (clp) om$dealloc (ptr = clp);

  } /* for (lpix = 0; lpix < trsh_lps_info.num_elems; lpix++) */
  
  om$dealloc (ptr = trsh_lps_info.elems);

 } /* if (trsh_lps_info.elems) */

 /*
  * Free the trash bnd_info
  */

 if (trsh_bnds_info.num_elems)
 {
   for (bndix = 0; bndix < trsh_bnds_info.num_elems; bndix++)
   {
    bnd_info = (struct EMSsortbnd_info *) trsh_bnds_info.elems[bndix];
    if (bnd_info) om$dealloc (ptr = bnd_info);
   }
   om$dealloc (ptr = trsh_bnds_info.elems);

 } /* if (trsh_bnds_info.num_elems) */

 /*
  * Free used_sgrlps_info
  */
 
 if (used_sgrlps_info.lp_ids) om$dealloc (ptr = used_sgrlps_info.lp_ids);

 /*
  * Delete trash topology objects and free the malloced space
  */

 if (!IF_NULL_OBJID(trsh_tp_objects.ls_id))
 {
  OM_stat = om$send (msg = message Root.delete (1),
                     senderid = NULL_OBJID,
                     targetid = trsh_tp_objects.ls_id, targetos = cur_os);
 }

 for (lpix = 0; lpix < trsh_tp_objects.num_lps; lpix++)
 {
  OM_stat = om$send (msg = message Root.delete (1),
                     senderid = NULL_OBJID,
                     targetid = trsh_tp_objects.lp_ids[lpix]);

 } /* for (lpix = 0; lpix < trsh_tp_objects.num_lps; lpix++) */

 if (trsh_tp_objects.lp_ids) om$dealloc (ptr = trsh_tp_objects.lp_ids);

 for (peix = 0; peix < trsh_tp_objects.num_peds; peix++)
 {
  OM_stat = om$send (msg = message Root.delete (1),
                     senderid = NULL_OBJID,
                     targetid = trsh_tp_objects.ped_ids[peix]);

 } /* for (peix = 0; peix < trsh_tp_objects.num_peds; peix++) */

 if (trsh_tp_objects.ped_ids) om$dealloc (ptr = trsh_tp_objects.ped_ids);

 /*
  * Free parametric tolerances
  */

 if (sf_tol_info.sf_ids) om$dealloc (ptr = sf_tol_info.sf_ids);
 if (sf_tol_info.par_tols) om$dealloc (ptr = sf_tol_info.par_tols);

 return;
   
} /* EFsort_intersections () */


end implementation EMSsfboolean;
