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


extern OMuword  OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id,
                OPP_EMSpartedge_class_id;

from EMSsubbs    import EMpartolbasis;
from EMSboundary import EMgetsurface_info, EMget_objid;
from EMSloopset  import EMget_loops, EMtreemod, EMnesting;
from EMSedge     import EMendpts, EMget_props;
from EMSloop     import EMnext_edge, EMget_props, EMget_loops,
                        EMgivenestinfo, EMnesting, EMtreemod, EMlpinit;
from EMSpartedge import EMpeinit;

extern IGRlong         EMmake_chanselect();


/*****************************************************************************/
/*             SUPPORT FUNCTIONS FOR OLD SELECTIVE BOOLEAN CODE              */
/*****************************************************************************/
/*
 ABSTRACT
          This file contains all of the functions used in sorting
	      intersections for a special boolean operation.

 HISTORY
            RC    07/22/89       Creation Date
	    SM    19-Feb-92	 Initialized all pointers to NULL in their
				 declaration itself.
*/

IGRboolean EFsgrlp_already_used (used_sgrlps_info, lp_id)
 struct EMSused_lps   *used_sgrlps_info;
 GRobjid              lp_id;
 
{
 IGRint      i;
 IGRboolean  sgrlp_already_used = FALSE;

 for (i = 0; i < used_sgrlps_info->num_lps && !sgrlp_already_used; i++)
  if (IF_EQ_OBJID (used_sgrlps_info->lp_ids[i], lp_id))
    sgrlp_already_used = TRUE;

 return (sgrlp_already_used);

} /* EFsgrlp_already_used */

/*
 * Given an edge with/without boundaries, the traversal involves the
 * following steps:
 *
 *  o Construct a face (i.e., a set of p_loop and its nested c-loops)
 *    using the portion of the input edge.
 *  o Add the loops of the face to the sort_info.
 *  o Propogate traversal through the edges (excluding new intersections).
 */

void  EFperform_traversal (EFmsg, start_bnd, start_face, 
                          start_element_type,sf_id, opix, unsort_set, 
                          csort_set, 
                          sort_info, cur_os, sf_tol_info, trsh_bnds_info,
                          trsh_lps_info, trsh_faces_info, 
                          used_sgrlps_info,
                          trsh_tp_objects)

 IGRlong                *EFmsg;
 struct EMSsortbnd_info *start_bnd;
 struct EMSsortfc_info  *start_face;
 IGRint                 start_element_type;
 GRobjid                sf_id;
 IGRint                 opix;
 struct EMSint_set      *unsort_set, *csort_set;
 struct EMSsort_info    *sort_info;
 GRspacenum             cur_os;
 struct EMSsf_tol_info  *sf_tol_info;
 struct EMSgen_info     *trsh_bnds_info, *trsh_lps_info, *trsh_faces_info;
 struct EMSused_lps     *used_sgrlps_info;
 struct EMStp_objects_info *trsh_tp_objects;

{
 struct EMSsortfc_info   *face_info = NULL;
 struct EMSsortlp_info   **lps_info = NULL, *clp_info = NULL;
 struct EMSsortbnd_info  *lbnd = NULL, *cbnd = NULL, *nbnd = NULL, 
			 *cm_bnd = NULL;
 struct EMSsortsf_info   *sf_info = NULL;

 IGRlong     rc;
 IGRint      lptyp, num_lps, lpix, cm_opix, sfix;
 IGRboolean  bnd_processed, cmbnd_exists, face_sf_exists, 
             process_face = TRUE;

 extern void EFis_bnd_already_processed(), EFbuild_face(),
             EFget_common_bnd();
 extern void EFmemory_allocation();

 /* ***************************************************************** */

 *EFmsg = EMS_S_Success;

 /*
  * If the start element is a boundary, 
  * Check if it has already been consumed or not.
  */

 if (start_element_type == EMSed_bnd)
 {
  EFis_bnd_already_processed (&rc, start_bnd, opix, sort_info, 
          cur_os, &bnd_processed, sf_tol_info, &sf_id);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  if (!bnd_processed)
  {
   EFbuild_face (&rc, start_bnd, opix, unsort_set, csort_set, sf_id,
                 cur_os, sf_tol_info, trsh_bnds_info, trsh_lps_info,
                 trsh_faces_info, used_sgrlps_info, trsh_tp_objects, 
                 &face_info, TRUE, TRUE);
   EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

  } /* if (!bnd_processed) */
  else
   process_face = FALSE;

 } /* if (start_element_type == EMSed_bnd) */
 else
  face_info = start_face;

 /*
  * Add the above face created to the sort_info.
  */

 if (process_face)
 {
  face_sf_exists = FALSE;

  for (sfix = 0; sfix < sort_info->num_sfs[opix]; sfix++)
   if (IF_EQ_OBJID(sf_id, sort_info->sfs_info[opix][sfix].sf_id))
   {
    face_sf_exists = TRUE;
    break;
   }

  if (!face_sf_exists)
  {
   if ((sort_info->num_sfs[opix]+1) > sort_info->sfs_arrsz[opix])
   {
    EFmemory_allocation (&rc, (IGRchar **) &sort_info->sfs_info[opix],
      sort_info->num_sfs[opix]+1, &sort_info->sfs_arrsz[opix],       
      sizeof(struct EMSsortsf_info), 10, 5);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

   } /* if ((sort_info->num_sfs[opix]+1) > sort_info->sfs_arrsz[opix]) */
   
   sfix = sort_info->num_sfs[opix];
   sf_info = &sort_info->sfs_info[opix][sfix];
   sf_info->sf_id = sf_id;
   sf_info->num_faces = sf_info->faces_arrsz = 0;
   sf_info->faces_info = NULL;
   sort_info->num_sfs[opix]++;

  } /* if (!face_sf_exists) */

  sf_info = &sort_info->sfs_info[opix][sfix];

  if ((sf_info->num_faces + 1) > sf_info->faces_arrsz)
  {
    EFmemory_allocation (&rc, (IGRchar ***) &sf_info->faces_info,
      sf_info->num_faces+1, &sf_info->faces_arrsz,       
      sizeof(struct EMSsortfc_info *), 10, 5);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  } /* if ((sf_info->num_faces + 1) > sf_info->faces_arrsz) */

  sf_info->faces_info[sf_info->num_faces++] = face_info;

  /*
   * If there are any unsorted groups left, go across the common 
   * intersections of the loop's boundaries and continue traversal.
   */

  for (lptyp = 0; lptyp < 2; lptyp++)
  {
   if (lptyp)
   { 
    lps_info = face_info->c_lps;
    num_lps = face_info->num_c_lps;
   }
   else
   {
    lps_info = &face_info->p_lp;
    num_lps = 1;
   }

   for (lpix = 0; lpix < num_lps; lpix++)
   {
    clp_info = lps_info[lpix];
    lbnd = cbnd = clp_info->bnd_info;
    nbnd = cbnd->next ? cbnd->next : cbnd;
    while (lbnd->next)
      lbnd = lbnd->next;

    while (cbnd)
    {
     if (cbnd->bnd_type != EMSsgr_bnd)
     {
       EFget_common_bnd (&rc, lbnd, cbnd, nbnd, NULL, csort_set,
             unsort_set, opix, cur_os, sf_id, sf_tol_info, trsh_bnds_info,
             &cm_bnd, &cm_opix, &cmbnd_exists);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       if (cmbnd_exists)
       {
         EFperform_traversal (&rc, cm_bnd, (struct EMSsortfc_info *)NULL, 
	   EMSed_bnd, NULL_OBJID,
           opix, unsort_set, csort_set, 
           sort_info, cur_os, sf_tol_info, trsh_bnds_info, 
           trsh_lps_info, trsh_faces_info, used_sgrlps_info,  
           trsh_tp_objects);
         EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

       } /* if (cmbnd_exists) */

     } /* if (cbnd->bnd_type != EMSsgr_bnd) */

     lbnd = cbnd;
     cbnd = cbnd->next;
     nbnd = cbnd ? (cbnd->next ? cbnd->next : clp_info->bnd_info) : NULL;

    } /* while (cbnd) */
    
   } /* for (lpix = 0; lpix < num_lps; lpix++) */

  } /* for (lptyp = 0; lptyp < 2; lptyp++) */

 } /* if (process_face)*/

wrapup:
if(*EFmsg != EMS_E_IntersectOrient)
 {
  EMWRAPUP (*EFmsg, *EFmsg, "EFperform_traversal");
 }
 return;

} /* void EFperform_traversal () */



void EFget_common_bnd (EFmsg, lbnd, cbnd, nbnd, sgr_elem_inx, cset, 
                       unsort_set, opix, cur_os, sf_id, sf_tol_info, 
                       trsh_bnds_info, cm_bnd, cm_opix, cmbnd_exists)

 IGRlong                  *EFmsg;
 struct EMSsortbnd_info   *lbnd, *cbnd, *nbnd;
 IGRint                   sgr_elem_inx;
 struct EMSint_set        *cset, *unsort_set;
 IGRint                   opix;
 GRspacenum               cur_os;
 GRobjid                  sf_id;
 struct EMSsf_tol_info    *sf_tol_info;
 struct EMSgen_info       *trsh_bnds_info;
 struct EMSsortbnd_info   **cm_bnd;
 IGRint                   *cm_opix;
 IGRboolean               *cmbnd_exists;
 {

  OM_S_CHANSELECT             cm_ed_chan, to_comps;
  OM_S_OBJECT_LINKAGE         cmed_list;
  struct EMSsorted_info       *ed_info = NULL, *cmed_info = NULL;
  struct EMSsortsgr_info      *sgr_info = NULL;
  struct EMSsfintedpar        *nelem_intedpar = NULL, *lelem_intedpar = NULL;
  struct EMSsftracedata       *test_trace = NULL, *cset_trace = NULL;
  struct EMSsfintloopsdata    *test_sflps = NULL, *cset_sflps = NULL;

  IGRdouble                   ed_beg_pt[2], ed_end_pt[2], par_tol;
  IGRlong                     OM_stat, mthd_stat, rc;
  IGRint                      i, grix, sgrix, num_cmed, lsgrix, 
                              nsgrix, stat;
  GRobjid                     ed_id, sgrlp_ed, sgrlp_ed_cm_ed, cmlp_id,
                              lbnd_sgrlp, nbnd_sgrlp;
  GRspacenum                  dum_os;
  IGRboolean                  rev_con;
  IGRushort           ed_props;
  IGRboolean                  gr_found;

  extern void EFget_sf_par_tol();
  extern IGRint EMsend_loops();

  /* **************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 *cmbnd_exists = FALSE;

 EFget_sf_par_tol (&rc, sf_tol_info, sf_id, cur_os, &par_tol);
 EMerr_hndlr(!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 if (cbnd->bnd_type == EMSsgr_bnd)
 {
   /*
    * o Get the ed_id of the ith element of the sf_lp.
    * o Get its common edge.
    * o Get the loop_id of the common edge.
    * o Build the bnd_info with this loop_id.
    */

   OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   sgr_info = &cbnd->bnd_data.sgr_info;
   OM_stat = om$get_objid_at_index (osnum = cur_os, 
                objid = sgr_info->lp_id, p_chanselect = &to_comps,
                index = sgr_elem_inx, objidaddr = &sgrlp_ed, 
                osnumaddr = &dum_os);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
   
   OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                       &sgrlp_ed_cm_ed),
                      senderid = NULL_OBJID,
                      targetid = sgrlp_ed, targetos = cur_os);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_EdgeError, wrapup);

   stat = EMsend_loops (&rc, message EMSboundary.EMget_objid (
                              &mthd_stat, &cmlp_id),
                       sgrlp_ed_cm_ed, NULL, OM_K_MAXINT, EMLP_ACTIVE, 
                       NULL, NULL);
   EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);

   *cm_opix = opix == EMSoprnd_A ? EMSoprnd_B : EMSoprnd_A;
   EFget_sortbnd (trsh_bnds_info, *cm_bnd);
   (*cm_bnd)->bnd_type = EMSsgr_bnd;
   sgr_info = &(*cm_bnd)->bnd_data.sgr_info; 

   for (i = 0; i < 2 && !(*cmbnd_exists); i ++)
   {
    if (i)
    {
     test_trace = &cset->trace_data[*cm_opix];
     test_sflps = &cset->sflp_data[*cm_opix];
    }
    else
    {
     test_trace = &unsort_set->trace_data[*cm_opix];
     test_sflps = &unsort_set->sflp_data[*cm_opix];
    }

    for (grix = 0; grix < test_trace->num_grps && !(*cmbnd_exists);grix++)
    {
     for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] && 
                          !(*cmbnd_exists); sgrix++)
     {
       if (IF_EQ_OBJID (test_sflps->loop_sf[grix][2*sgrix], cmlp_id))
       { 
        (*cmbnd_exists) = TRUE;
        sgr_info->num_elems = 
                         test_trace->num_elems_subgrp[grix][sgrix];
        sgr_info->sgr_rev = test_trace->subgrp_rev[grix][sgrix];
        sgr_info->sgr_closed = 
                             test_trace->subgrp_closed[grix][sgrix];
        (*cm_bnd)->next = NULL;

       } /* if (IF_EQ_OBJID (test_sflps->loop_sf[grix][2*sgrix],cm_lp)) */

     } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp */

    } /* for (grix = 0; grix < test_trace->num_grps &&  */

   } /* for (i = 0; i < 2 && !(*cmbnd_exists); i ++) */

 } /* if (cbnd->bnd_type == EMSsgr_bnd) */
 else
 {
   /*
    * o Get the common edge.
    * o If it has a common edge,
    *    o Get the end points of the edge.
    *    o Check if the end points are within par_tol its new bnd_pts.
    *    o If not, get lbnd_elem and find the group whose sgrp
    *      matches with it. Find the next sgr of that grp. The begin pt
    *      incident edge of this sgrp will be the common edge. Get the
    *      boundary condition of this edge will be that of common bnd.
    */

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   ed_id = cbnd->bnd_data.ed_info.ed_id;
   ed_info = &cbnd->bnd_data.ed_info;
   OM_stat = om$get_channel_objects (objid = ed_id,
                osnum = cur_os, p_chanselect = &cm_ed_chan,
                list = &cmed_list, size = 1, count = (OMuint *)&num_cmed);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

   if (num_cmed)
   {
    *cmbnd_exists = TRUE;
    EFget_sortbnd (trsh_bnds_info, (*cm_bnd));
    (*cm_bnd)->bnd_type = EMSed_bnd_wfixed_end;
    cmed_info = &(*cm_bnd)->bnd_data.ed_info;
    cmed_info->ed_id = cmed_list.S_objid;
    *cm_opix = opix;

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        ed_beg_pt, ed_end_pt, NULL, NULL, NULL),
                       senderid = NULL_OBJID, 
                       targetid = ed_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                        &ed_props),
                       senderid = NULL_OBJID,
                       targetid = ed_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError, wrapup);

    rev_con = ed_props & EMED_REVERSE_CONNECT;

    if (EM2ddistptpt (ed_beg_pt, ed_info->ed_pts) <= par_tol)
    {
      OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                      rev_con ? NULL : cmed_info->ed_pts, 
                      rev_con ? &cmed_info->ed_pts[2] : NULL,
                      rev_con ? NULL : cmed_info->ed_bounds,
                      rev_con ? &cmed_info->ed_bounds[1] : NULL, NULL),
                     senderid = NULL_OBJID, 
                     targetid = cmed_list.S_objid, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    } /* if (EM2ddistptpt (ed_beg_pt, ed_info->ed_pts) <= par_tol) */
    else
    {
     gr_found = FALSE;
     lbnd_sgrlp = lbnd->bnd_data.sgr_info.lp_id;
     cset_trace = &cset->trace_data[opix];
     cset_sflps = &cset->sflp_data[opix];

     for (grix = 0; grix < cset_trace->num_grps && !gr_found; grix++)
     {
      for (sgrix =0; sgrix < cset_trace->num_subgrps_grp[grix] && 
                     !gr_found; sgrix++)
      {
        if (IF_EQ_OBJID(lbnd_sgrlp, cset_sflps->loop_sf[grix][2*sgrix]))
        {
         gr_found = TRUE;
         nsgrix = cset_trace->subgrp_rev[grix][sgrix] ?
                  (sgrix == 0 ? (cset_trace->num_subgrps_grp[grix] - 1) :
                                (sgrix-1))  :
                  (sgrix == (cset_trace->num_subgrps_grp[grix] - 1) 
                            ? 0 : (sgrix+1));
    
         nelem_intedpar = cset_sflps->intedpars[grix][2*nsgrix + 
                   ( (cset_trace->subgrp_rev[grix][nsgrix] ^
                      cset_trace->subgrp_rev[grix][sgrix]) ? 1 : 0)];

         if (rev_con)
         {
          cmed_info->ed_bounds[1] = nelem_intedpar->edgepar;
          OM_BLOCK_MOVE (nelem_intedpar->point, &cmed_info->ed_pts[2], 
                         sizeof(IGRdouble) * 2);

         } /* if (ed_props & EMED_REVERSE_CONNECT) */
         else
         {
          cmed_info->ed_bounds[0] = nelem_intedpar->edgepar;
          OM_BLOCK_MOVE (nelem_intedpar->point, cmed_info->ed_pts, 
                         sizeof(IGRdouble) * 2);

         }

        } /* if (lbnd_elem == cset_trace->elems[grix][sgrix] ) */
 
       } /* for (sgrix=0; sgrix<cset_trace->num_subgrps_grp[grix] */

      } /* for (grix=0; grix<cset_trace->num_grps && !gr_found;grix++) */

    } /* if (else for EM2ddistptpt(ed_beg_pt,ed_info->ed_pts)<=par_tol) */

    if (EM2ddistptpt (ed_end_pt, &ed_info->ed_pts[2]) <= par_tol)
    {
      OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                      rev_con ? cmed_info->ed_pts : NULL,
                      rev_con ? NULL : &cmed_info->ed_pts[2],
                      rev_con ? cmed_info->ed_bounds : NULL,
                      rev_con ? NULL : &cmed_info->ed_bounds[1], NULL),
                     senderid = NULL_OBJID, 
                     targetid = cmed_list.S_objid, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    } /* if (EM2ddistptpt (ed_beg_pt, ed_info->ed_pts) <= par_tol) */
    else
    {
      gr_found = FALSE;
      cset_trace = &cset->trace_data[opix];
      cset_sflps = &cset->sflp_data[opix];
      nbnd_sgrlp = nbnd->bnd_data.sgr_info.lp_id;

      for (grix = 0; grix < cset_trace->num_grps && !gr_found; grix++)
      {
       for (sgrix =0; sgrix < cset_trace->num_subgrps_grp[grix] && 
                      !gr_found; sgrix++)
       {
        if (IF_EQ_OBJID(nbnd_sgrlp, cset_sflps->loop_sf[grix][2*sgrix]))
        {
         gr_found = TRUE;
         lsgrix = cset_trace->subgrp_rev[grix][sgrix] ? 
                  (sgrix == (cset_trace->num_subgrps_grp[grix] - 1) ?
                            0 : (sgrix+1))  :
                  (sgrix == 0 ? (cset_trace->num_subgrps_grp[grix] - 1) 
                             : (sgrix - 1));

         lelem_intedpar = cset_sflps->intedpars[grix][2*lsgrix + 
                   ( (cset_trace->subgrp_rev[grix][lsgrix] ^
                      cset_trace->subgrp_rev[grix][sgrix]) ? 0 : 1)];

         if (rev_con)
         {
          cmed_info->ed_bounds[0] = lelem_intedpar->edgepar;
          OM_BLOCK_MOVE (lelem_intedpar->point, cmed_info->ed_pts, 
                         sizeof(IGRdouble) * 2);

         } /* if (rev_con) */
         else
         {
          cmed_info->ed_bounds[1] = lelem_intedpar->edgepar;
          OM_BLOCK_MOVE (lelem_intedpar->point, &cmed_info->ed_pts[2], 
                         sizeof(IGRdouble) * 2);

         }

        } /* if (nbnd_elem == cset_trace->elems[grix][sgrix] ) */

       } /* for (sgrix=0; sgrix<cset_trace->num_subgrps_grp[grix] */

      } /* for (grix=0; grix<cset_trace->num_grps && !gr_found;grix++) */

    } /* else for if (EM2ddistptpt (ed_end_pt, &cbnd->ed_pts[2]) */

   } /* if (num_cmed) */

 } /* else for if (cbnd->bnd_type == EMSsgr_bnd) */

wrapup:

 EMWRAPUP (*EFmsg, OM_stat, "EFget_common_bnd");

 return;

} /* void EFget_common_bnd () */


/*
 * Given an boundary and sort_info (topology which has already been
 * traversed), check if the incoming boundary has been processed as
 * yet or not.
 */

void  EFis_bnd_already_processed (EFmsg, inbnd, opix, sort_info, 
                                  cur_os, bnd_processed,  
                                  sf_tol_info, sf_id)
 IGRlong                *EFmsg;
 struct EMSsortbnd_info *inbnd;
 IGRint                 opix;
 struct EMSsort_info    *sort_info;
 GRspacenum             cur_os;
 IGRboolean             *bnd_processed;
 struct EMSsf_tol_info  *sf_tol_info;
 GRobjid                *sf_id;

{
 struct EMSsortsf_info    *sf_info = NULL;
 struct EMSsortfc_info    *fc_info = NULL;
 struct EMSsortlp_info    **lps_info = NULL;
 struct EMSsortbnd_info   *bnd_info = NULL; 

 IGRdouble                par_tol;

 IGRlong                  mthd_stat, OM_stat, rc;
 IGRint                   sfix, fcix, lptyp, num_lps, lpix;

 extern void              EFget_sf_par_tol();

 /* ************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 *bnd_processed = FALSE;

 if (inbnd->bnd_type == EMSsgr_bnd)
  *sf_id = inbnd->bnd_data.sgr_info.sf_id;
 else
 {
   OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                       &mthd_stat, sf_id, NULL),
               senderid = NULL_OBJID,
               targetid = inbnd->bnd_data.ed_info.ed_id,
               targetos = cur_os);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

 } /* if (inbnd_info->bnd_type == EMSsgr_bnd) */

 for (sfix = 0; sfix < sort_info->num_sfs[opix] && !(*bnd_processed);
      sfix++)
 {
  sf_info = &sort_info->sfs_info[opix][sfix];

  if (IF_EQ_OBJID(sf_info->sf_id, *sf_id))
  {
   for (fcix = 0; fcix < sf_info->num_faces && !(*bnd_processed); fcix++)
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
     
     for (lpix = 0; lpix < num_lps && !(*bnd_processed); lpix++)
     {
      bnd_info = lps_info[lpix]->bnd_info;

      while (bnd_info && !(*bnd_processed) )
      {
       if (bnd_info->bnd_type == inbnd->bnd_type)
       {
        if (inbnd->bnd_type == EMSsgr_bnd)
        {
          if (IF_EQ_OBJID(inbnd->bnd_data.sgr_info.lp_id,
              bnd_info->bnd_data.sgr_info.lp_id)) *bnd_processed =TRUE;
        }
        else
        {
         if ( IF_EQ_OBJID(inbnd->bnd_data.ed_info.ed_id, 
                         bnd_info->bnd_data.ed_info.ed_id))
         {
           EFget_sf_par_tol (&rc, sf_tol_info, *sf_id, cur_os, &par_tol);
           EMerr_hndlr(!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

           if (EM2ddistptpt(inbnd->bnd_data.ed_info.ed_pts, 
                bnd_info->bnd_data.ed_info.ed_pts) <= par_tol   &&
              EM2ddistptpt(&inbnd->bnd_data.ed_info.ed_pts[2],
                &bnd_info->bnd_data.ed_info.ed_pts[2]) <= par_tol)
           *bnd_processed = TRUE;
          }

        } /* else for if (inbnd->bnd_type == EMSsgr_bnd) */

       } /* if (bnd_info->bnd_type == inbnd->bnd_type) */

       bnd_info = bnd_info->next;

      } /* while (bnd_info && !(*bnd_processed) ) */

     } /* for (lpix=0; lp_inx<sf_info->num_lps && !(*bnd_processed); */

    } /* for (lptyp = 0; lptyp < 2; lptyp++) */

   } /* for (fcix = 0; fcix < sf_info->num_faces && !(*bnd_processed); */

  } /* if (IF_EQ_OBJID(sort_info->sf_info[sfix].sf_id, sf_id) */

 } /* for (sfix=0; sfix<sort_info->num_sfs && !(*bnd_processed); */
 
wrapup:
 EMWRAPUP (*EFmsg, OM_stat, "EFis_bnd_already_processed");
 return;

} /* void  EFis_bnd_already_processed () */

/*
 * Given a start boundary and a set of trimmed intersections, 
 * construct a face i.e., a p-loop and its nested c-loops that
 * will be the result of trimming and closing the existing 
 * face the incoming boundary is a part of.
 */

void EFbuild_face (EFmsg, start_bnd, opix, unsort_set, csort_set, sf_id, 
                   cur_os, sf_tol_info, trsh_bnds_info, trsh_lps_info,
                   trsh_faces_info, used_sgrlps_info, trsh_tp_objects, 
                   out_face, update_csort_set, remove_face_lp_objects)

 IGRlong                   *EFmsg;
 struct EMSsortbnd_info    *start_bnd; 
 IGRint                    opix;
 struct EMSint_set         *unsort_set, *csort_set;
 GRobjid                   sf_id;
 GRspacenum                cur_os;
 struct EMSsf_tol_info     *sf_tol_info;
 struct EMSgen_info        *trsh_bnds_info, *trsh_faces_info, 
                           *trsh_lps_info;
 struct EMSused_lps        *used_sgrlps_info;
 struct EMStp_objects_info *trsh_tp_objects;
 struct EMSsortfc_info     **out_face;
 IGRboolean                update_csort_set, remove_face_lp_objects;

{
 OM_S_CHANSELECT         to_outter, ls_lp_chan, sf_ls_chan;
 OM_S_OBJECT_LINKAGE     owner_list, sf_ls_list;

 struct EMSnest_info     nest_info;
 struct EMSpartolbasis   partolbasis;
 struct EMSgen_info      temp_lps_info;
 struct EMSused_lps      face_used_lps;
 struct EMSsortlp_info   *start_bndlp_info = NULL, *sgr_lp_info = NULL, 
			 *lp_info = NULL;
 struct EMSsftracedata   *test_trace = NULL;
 struct EMSsfintloopsdata *test_sflps = NULL;
 struct EMSintobj        *felem = NULL; 
 struct EMSsortbnd_info  *sgr_bnd = NULL, *lp_bnd = NULL;
 struct EMSsortsgr_info  *sgr_info = NULL;

 IGRdouble   par_tol;

 IGRlong     rc, mthd_stat, OM_stat;

 IGRint      num_owners = 0, count = 0, num_oface_c_lps = 0, tree_depth, 
             oface_c_lps_bufsize = 0,
             num_nface_lps = 0, i, j, blk_size, num_temp_lps_so_far, lpix,
             nface_lps_bufsize = 0, ls_lps_bufsize = 0, num_ls_lps = 0, 
             settyp, grix, sgrix, stat, num_c_lps = 0;

 GRobjid     start_bnd_olp, oface_p_lp, *oface_c_lps = NULL, ls_id, sgr_sf, 
             *nface_lps = NULL, *ls_lps = NULL, nface_p_lp, stbnd_ed;

 IGRushort lp_props, start_bndlp_props;

 IGRboolean     is_nface_lp, c_lp_already_used, lp_found, stbnd_ed_found;

 extern void    EFget_sf_par_tol(), EFbuild_loop(), 
                EFconstruct_loop_object(), EFadd_group_to_set(),
                EFcreate_trimmed_lps(), 
                EFnest_lp(), EFtrash_lp_info();
 extern void    EFmemory_allocation();
 extern IGRboolean EFsgrlp_already_used();
 extern IGRint  EMsend_loops();

 /* **************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 oface_c_lps = NULL;
 nface_lps = NULL;
 ls_lps = NULL;
 (*out_face) = NULL;

 face_used_lps.num_lps = face_used_lps.lps_arrsz = 0;
 face_used_lps.lp_ids = NULL;

 temp_lps_info.num_elems = temp_lps_info.arrsz = 0;
 temp_lps_info.elems = NULL;

 OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
 EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

 OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
 EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

 EFget_sf_par_tol (&rc, sf_tol_info, sf_id, cur_os, &par_tol);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 partolbasis.tol = par_tol;
 partolbasis.is_valid = partolbasis.in_world = TRUE;
 partolbasis.mattyp = sf_tol_info->mattyp;
 partolbasis.mat = sf_tol_info->matrix;

 /*
  * o Build a loop using the start boundary.
  * o Get the lp_type of the new loop.
  * o Nest any unsed closed subgrs of surface w.r.t new loop.
  * o If the type of new loop is p_loop, get the inner loop at
  *   level 1 and it will be the c-loop. Else, get the outer loop
  *   at level 1 and it will be the p-loop.
  * o Get the c-loops of the original face which have not been 
  *   used in building loop in step 1.
  * o Check their nesting w.r.t new face.
  * o If still nested, trimm and closed them w.r.t new intersections,
  *   if needed.
  * o these new c-loops will additional c-loops of the new face.
  *  
  */

 /*
  * Get the p_loop and c_loops of the old face the start bnd is a
  * part of.
  */

 if (start_bnd->bnd_type == EMSsgr_bnd && 
     start_bnd->bnd_data.sgr_info.sgr_closed)
 {
  OM_stat = om$send (msg = message EMSloop.EMgivenestinfo (&mthd_stat,
                      &nest_info),
                     senderid = NULL_OBJID,
                     targetid = start_bnd->bnd_data.sgr_info.lp_id,
                     targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_LoopError,wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$get_channel_objects (objid = sf_id, osnum = cur_os,
               p_chanselect = &sf_ls_chan, list = &sf_ls_list,
               size = 1, count = (OMuint *)&count);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message EMSloopset.EMnesting (&mthd_stat,
                       &nest_info, &partolbasis),
                     senderid = NULL_OBJID,
                     targetid = sf_ls_list.S_objid, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);
  
  oface_p_lp = nest_info.parent;

 } /* if (start_bnd->bnd_type == EMSsgr_bnd && 
          start_bnd->bnd_data.sgr_info.sgr_closed) */
 else
 {
  if (start_bnd->bnd_type == EMSsgr_bnd)
  {
   stbnd_ed_found = FALSE;
   for (settyp = 0; settyp < 2 && !stbnd_ed_found; settyp++)
   {
    test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                               &csort_set->trace_data[opix];
    test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                               &csort_set->sflp_data[opix];
 
    for (grix = 0; grix < test_trace->num_grps && !stbnd_ed_found; grix++)
    {
     for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] &&
                     !stbnd_ed_found; sgrix++)
     {
      if (IF_EQ_OBJID(test_sflps->loop_sf[grix][2*sgrix], 
                      start_bnd->bnd_data.sgr_info.lp_id))
      {
       stbnd_ed = test_sflps->intedpars[grix][2*sgrix+1]->edgeid;
       stbnd_ed_found = TRUE;      
      }
     } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] */

    } /* for (grix = 0; grix < test_trace->num_grps && !ed_found; */
 
   } /* for (settyp = 0; settyp < 2 && !ed_found; settyp++) */

  } /* if (start_bnd->bnd_type == EMSsgr_bnd) */
  else
   stbnd_ed = start_bnd->bnd_data.ed_info.ed_id;

  stat = EMsend_loops (&rc, message EMSboundary.EMget_objid (
                             &mthd_stat, &start_bnd_olp),
                       stbnd_ed, NULL, OM_K_MAXINT, EMLP_ACTIVE, 
                       NULL, NULL);
  EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);

  OM_stat = om$send (msg = message EMSloop.EMget_props (&mthd_stat,
                      &lp_props), 
                     senderid = NULL_OBJID,
                     targetid = start_bnd_olp, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

  if (lp_props & EMLP_PLOOP)
   oface_p_lp = start_bnd_olp;
  else
  {
   OM_stat = om$get_channel_objects (osnum = cur_os, objid =start_bnd_olp,
               p_chanselect = &to_outter, list = &owner_list, size = 1,
               count = (OMuint *)&num_owners);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   oface_p_lp = owner_list.S_objid;
  }

 } /* else for if (start_bnd->bnd_type == EMSsgr_bnd && 
                   start_bnd->bnd_data.sgr_info.sgr_closed) */

 tree_depth = 2;
 OM_stat = om$send (msg = message EMSloop.EMget_loops (&mthd_stat,
                      EMS_OPT_ALL, &tree_depth, &oface_c_lps, NULL,
                      &oface_c_lps_bufsize, &num_oface_c_lps),
                     senderid = NULL_OBJID,
                     targetid = oface_p_lp, targetos = cur_os);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

 for (i = 0; i < num_oface_c_lps; i++)
 {
  if (IF_EQ_OBJID(oface_c_lps[i], oface_p_lp))
  {
   blk_size = (num_oface_c_lps - 1 - i) * sizeof(GRobjid);
   if (blk_size) 
     OM_BLOCK_MOVE (&oface_c_lps[i+1], &oface_c_lps[i], blk_size);
   num_oface_c_lps--;
   break;
  }
 } /* for (i = 0; i < num_oface_c_lps; i++) */

 /*
  * Construct a loop using the start boundary
  */

 EFbuild_loop (&rc, start_bnd, opix, unsort_set, csort_set, 
               sf_id, cur_os, sf_tol_info, trsh_bnds_info, 
               trsh_lps_info, used_sgrlps_info, &face_used_lps, 
               &start_bndlp_info);
 EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

 EFconstruct_loop_object (&rc, start_bndlp_info, trsh_tp_objects, sf_id, 
             cur_os, sf_tol_info);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 EFappend_gen_info (&temp_lps_info, (IGRchar *)start_bndlp_info);
 
 /*
  * Now the loop corresponding to the start boundary has been constructed.
  * Next step is to nest any available unused closed subgroups into
  * loopset owning the start boundary loop.
  */

 if (IF_NULL_OBJID(trsh_tp_objects->ls_id))
 {
  OM_stat = om$construct (classid = OPP_EMSloopset_class_id, 
                           osnum = cur_os, p_objid = &ls_id);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  trsh_tp_objects->ls_id = ls_id;

 } /* if (IF_NULL_OBJID(trsh_tp_objects->ls_id) */
 else
  ls_id = trsh_tp_objects->ls_id;

 EFnest_lp (&rc, start_bndlp_info->lp_id, ls_id, cur_os, &partolbasis);
 EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

 for (settyp = 0; settyp < 2; settyp++)
 {
  test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                             &csort_set->trace_data[opix];
  test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                             &csort_set->sflp_data[opix];

  for (grix = 0; grix < test_trace->num_grps; grix++)
  {
   for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix]; sgrix++)
   {
    felem = test_trace->elems[grix][sgrix];
    sgr_sf = felem->this_obj_node->this_obj.objid;
           
    if ( IF_EQ_OBJID(test_sflps->loop_sf[grix][2*sgrix+1], sf_id) && 
         test_trace->subgrp_closed[grix][sgrix] &&
         !EFsgrlp_already_used(used_sgrlps_info, 
                               test_sflps->loop_sf[grix][2*sgrix]) )
    {
      EFget_sortlp (trsh_lps_info, sgr_lp_info);

      EFappend_gen_info (&temp_lps_info, (IGRchar *)sgr_lp_info);

      EFget_sortbnd (trsh_bnds_info, sgr_bnd);
     
      sgr_lp_info->bnd_info = sgr_bnd;
      sgr_bnd->bnd_type = EMSsgr_bnd;
      sgr_bnd->next = NULL;
      sgr_info = &sgr_bnd->bnd_data.sgr_info;
      sgr_info->num_elems = test_trace->num_elems_subgrp[grix][sgrix];
      sgr_info->sgr_rev = test_trace->subgrp_rev[grix][sgrix];
      sgr_info->sgr_closed = test_trace->subgrp_closed[grix][sgrix];
      sgr_info->lp_id = test_sflps->loop_sf[grix][2*sgrix];
      sgr_info->sf_id = test_sflps->loop_sf[grix][2*sgrix+1];
     
      sgr_lp_info->lp_id = sgr_info->lp_id;
      EFnest_lp (&rc, sgr_lp_info->lp_id, ls_id, cur_os, &partolbasis);
      EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

    } /* if ( IF_EQ_OBJID(sgr_sf, sf_id) && */

   } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] && */

  } /* for (grix = 0; grix < test_trace->num_grps && cntinue;grix++) */

 } /* for (settyp = 0; settyp < 2 && cntinue; settyp++) */

 /*
  * Now we have a loopset with the loop corresponding to the start_bnd
  * and loops corresponding to the unused subgrps, if any.
  * Next step is get the lp_type of start_bnd loop. Depending upon
  * the type of start_bnd loop, pick its outter or inner loop.
  */

 OM_stat = om$send (msg = message EMSloop.EMget_props (&mthd_stat,
                     &start_bndlp_props),
                   senderid = NULL_OBJID,
                   targetid = start_bndlp_info->lp_id, targetos = cur_os);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

 if (start_bndlp_props & EMLP_PLOOP)
  nface_p_lp = start_bndlp_info->lp_id;
 else
 {
  OM_stat = om$send (msg = message EMSloop.EMgivenestinfo (&mthd_stat,
                      &nest_info),
                     senderid = NULL_OBJID,
                     targetid = oface_p_lp, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_LoopError,wrapup);

  OM_stat = om$send (msg = message EMSloopset.EMnesting (&mthd_stat,
                       &nest_info, &partolbasis),
                     senderid = NULL_OBJID,
                     targetid = ls_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);
  
  OM_stat = om$get_channel_objects (osnum = cur_os, 
               objid = start_bndlp_info->lp_id, p_chanselect = &to_outter,
               list = &owner_list, size = 1, count = (OMuint *)&num_owners);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  if (IF_EQ_OBJID(owner_list.S_objid, nest_info.parent))
  {
   num_temp_lps_so_far = temp_lps_info.num_elems;

   EFcreate_trimmed_lps (&rc, oface_p_lp, opix, unsort_set, csort_set, 
            sf_id, cur_os, sf_tol_info, trsh_bnds_info, trsh_lps_info,
            used_sgrlps_info, &face_used_lps, &temp_lps_info);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    for (lpix =num_temp_lps_so_far;lpix < temp_lps_info.num_elems;lpix++)
    {
     lp_info = (struct EMSsortlp_info *)temp_lps_info.elems[lpix];

     EFconstruct_loop_object (&rc, lp_info, trsh_tp_objects, sf_id, 
                               cur_os, sf_tol_info);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

     EFnest_lp (&rc, lp_info->lp_id, ls_id, cur_os, &partolbasis);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

    } /* for (lpix = 0; lpix < trm_lps_info->num_elems; lpix++) */

    OM_stat = om$get_channel_objects (osnum = cur_os, 
               objid = start_bndlp_info->lp_id, p_chanselect = &to_outter,
               list = &owner_list, size = 1, count = (OMuint *)&num_owners);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   } /* if (IF_EQ_OBJID(owner_list.S_objid, nest_info.parent)) */

   nface_p_lp = owner_list.S_objid;

  } /* else for if (start_bndlp_props & EMLP_PLOOP) */

  tree_depth = 2;
  num_nface_lps = 0;
  OM_stat = om$send (msg = message EMSloop.EMget_loops (&mthd_stat,
                      EMS_OPT_ALL, &tree_depth, &nface_lps, NULL,
                      &nface_lps_bufsize, &num_nface_lps),
                    senderid = NULL_OBJID,
                    targetid = nface_p_lp, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

  tree_depth = MAXINT;
  num_ls_lps = 0;
  OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                      EMS_OPT_ALL, &tree_depth, &ls_lps, NULL, 
                      &ls_lps_bufsize, &num_ls_lps),
                     senderid = NULL_OBJID,
                     targetid = ls_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  for (lpix = 0; lpix < num_ls_lps; lpix++)
  {
    is_nface_lp = FALSE;

    for (j = 0; j < num_nface_lps && !is_nface_lp; j++)
     if (IF_EQ_OBJID(ls_lps[lpix], nface_lps[j])) is_nface_lp = TRUE;

    if (!is_nface_lp)
    {
     EFtrash_lp_info (&rc, &temp_lps_info, ls_lps[lpix], cur_os, 
             used_sgrlps_info,
             trsh_bnds_info, trsh_lps_info, trsh_tp_objects, TRUE, TRUE);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    } /* if (!is_nface_lp) */

  } /* for (lpix = 0; lpix < num_ls_lps; lpix++) */

  /*
   * Now we have a face with good p_lp and one or more c_loops.
   * The c-loops corresponding to the closed sgrs may not be good
   * if any original face's c-loops is enclosing it.
   * Also, some of the original face's c-loops or their trim versions 
   * may still be valid  for the new face. Detect these c-loops and
   * add them into the new face. Similarly, invalid sgrs c-loops
   * should be taken out.
   */

  for (lpix = 0; lpix < num_oface_c_lps; lpix++)
  {
   c_lp_already_used = FALSE;

   for (i = 0; i < face_used_lps.num_lps && !c_lp_already_used; i++)
    if (IF_EQ_OBJID(oface_c_lps[lpix], face_used_lps.lp_ids[i]))
      c_lp_already_used = TRUE;

   if (!c_lp_already_used)
   {
     num_temp_lps_so_far = temp_lps_info.num_elems;

     EFcreate_trimmed_lps (&rc, oface_c_lps[lpix], opix, unsort_set,
              csort_set, sf_id, cur_os, sf_tol_info, trsh_bnds_info,
              trsh_lps_info,
              used_sgrlps_info, &face_used_lps, &temp_lps_info);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    for (i = num_temp_lps_so_far; i < temp_lps_info.num_elems; i++)
    {
     lp_info = (struct EMSsortlp_info *)temp_lps_info.elems[i];

     EFconstruct_loop_object (&rc, lp_info, trsh_tp_objects, sf_id, 
                               cur_os, sf_tol_info);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

     EFnest_lp (&rc, lp_info->lp_id, ls_id, cur_os, &partolbasis);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

    } /* for (i = 0; i < trm_lps_info->num_elems; i++) */

   } /* if (!c_lp_already_used) */

  } /* for (lpix = 0; lpix < num_oface_c_lps; lpix++) */

  /*
   * Some of the c_loops are not valid, trash such c_loops.
   * Trash the loop objects of the rest of the loops.
   * Fill output face info.
   */

  tree_depth = 2;
  num_nface_lps = 0;
  OM_stat = om$send (msg = message EMSloop.EMget_loops (&mthd_stat,
                      EMS_OPT_ALL, &tree_depth, &nface_lps, NULL,
                      &nface_lps_bufsize, &num_nface_lps),
                    senderid = NULL_OBJID,
                    targetid = nface_p_lp, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

  tree_depth = MAXINT;
  num_ls_lps = 0;
  OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                      EMS_OPT_ALL, &tree_depth, &ls_lps, NULL, 
                      &ls_lps_bufsize, &num_ls_lps),
                     senderid = NULL_OBJID,
                     targetid = ls_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  for (lpix = 0; lpix < num_ls_lps; lpix++)
  {
    is_nface_lp = FALSE;

    for (j = 0; j < num_nface_lps && !is_nface_lp; j++)
     if (IF_EQ_OBJID(ls_lps[lpix], nface_lps[j])) is_nface_lp = TRUE;

    if (!is_nface_lp)
    {
     EFtrash_lp_info (&rc, &temp_lps_info, ls_lps[lpix], cur_os, 
       used_sgrlps_info,
       trsh_bnds_info, trsh_lps_info, trsh_tp_objects, TRUE, TRUE);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    } /* if (!is_nface_lp) */

  } /* for (lpix = 0; lpix < num_ls_lps; lpix++) */

  EFget_sortface (trsh_faces_info, *out_face);

  num_c_lps = temp_lps_info.num_elems - 1;
  if ((*out_face)->c_lps_arrsz < num_c_lps)
  {
   (*out_face)->c_lps = (struct EMSsortlp_info **) om$malloc (
         size = num_c_lps * sizeof(struct EMSsortlp_info *));
   (*out_face)->c_lps_arrsz = num_c_lps;

  }

  while(temp_lps_info.num_elems)
  {
   lp_info = (struct EMSsortlp_info *) temp_lps_info.elems[0];
   
   /*
    * If any of the bnds of the new face is using a subgroup
    * add the corresponding group in the sort_set provided caller
    * has requested so.
    */

   if (update_csort_set)
   {
    lp_bnd = lp_info->bnd_info;

    while (lp_bnd)
    {
     if (lp_bnd->bnd_type == EMSsgr_bnd)
     {
      lp_found = FALSE;
      test_trace = &unsort_set->trace_data[opix];
      test_sflps = &unsort_set->sflp_data[opix];

      for (grix = 0; grix < test_trace->num_grps & !lp_found; grix++)
      {
       for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] && 
                      !lp_found; sgrix++)
       {
        if ( IF_EQ_OBJID( test_sflps->loop_sf[grix][2*sgrix], 
                         lp_bnd->bnd_data.sgr_info.lp_id) )
        {
         lp_found = TRUE;
         EFadd_group_to_set (&rc, csort_set, unsort_set, grix, opix, 
                             cur_os);
         EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

        } /* if ( IF_EQ_OBJID( test_sflps->loop_sf[grix][2*sgrix], */

       } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] */

      } /* for (grix = 0; grix < test_trace->num_grps & !lp_found; */

     } /* if (lp_bnd->bnd_typ == EMSsgr_bnd) */

     lp_bnd = lp_bnd->next;

    } /* while (lp_bnd) */

   } /* if (update_csort_set) */

   if (IF_EQ_OBJID (lp_info->lp_id, nface_p_lp))
    (*out_face)->p_lp = lp_info;
   else
    (*out_face)->c_lps[(*out_face)->num_c_lps++] = lp_info;

   EFtrash_lp_info (&rc, &temp_lps_info, lp_info->lp_id, cur_os, 
                    used_sgrlps_info,
                    trsh_bnds_info, trsh_lps_info, trsh_tp_objects, 
                    remove_face_lp_objects, FALSE);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  } /* while(temp_lps_info.num_elems) */

wrapup:

 if(*EFmsg != EMS_E_IntersectOrient)
  {
   EMWRAPUP (*EFmsg, OM_stat, "EFbuild_face");
  }
 if (oface_c_lps) om$dealloc (ptr = oface_c_lps);
 if (nface_lps) om$dealloc (ptr = nface_lps);
 if (ls_lps) om$dealloc (ptr = ls_lps);

 if (face_used_lps.lp_ids) om$dealloc (ptr = face_used_lps.lp_ids);
 if (temp_lps_info.elems) om$dealloc (ptr = temp_lps_info.elems);
 return;

} /* void EFbuild_face () */


/*
 * Given a lp_info and the loopset tree, the following function,
 * nests the lp in the looptree.
 */

void EFnest_lp (EFmsg, lp_id, ls_id, cur_os, partolbasis)
  IGRlong                 *EFmsg;
  GRobjid                 lp_id;
  GRobjid                 ls_id;
  GRspacenum              cur_os;
  struct EMSpartolbasis   *partolbasis;
{
 struct EMSnest_info nest_info;
 IGRlong             OM_stat, mthd_stat;
 
 /* ************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = om$send (msg = message EMSloop.EMgivenestinfo (&mthd_stat,
                      &nest_info),
                     senderid = NULL_OBJID,
                     targetid = lp_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_LoopError,wrapup);

  OM_stat = om$send (msg = message EMSloopset.EMnesting (&mthd_stat,
                      &nest_info, partolbasis),
                     senderid = NULL_OBJID,
                     targetid = ls_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  if (IF_EQ_OBJID (nest_info.parent, ls_id))
  {
    OM_stat = om$send (msg = message EMSloopset.EMtreemod (&mthd_stat,
                        &nest_info, ADD_CHILD, partolbasis),
                       senderid = NULL_OBJID,
                       targetid = ls_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  } /* if (IF_EQ_OBJID (nest_info.parent, ls_id)) */
  else
  {
    OM_stat = om$send (msg = message EMSloop.EMtreemod (&mthd_stat,
                        &nest_info, ADD_CHILD, partolbasis),
                       senderid = NULL_OBJID,
                       targetid = nest_info.parent, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

  } /* else for if (IF_EQ_OBJID (nest_info.parent, ls_id)) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFnest_lp");
  return;
 
} /* EFnest_lp() */


void EFcreate_trimmed_lps (EFmsg, inlp_id, opix, unsort_set, csort_set, 
                           sf_id, cur_os, sf_tol_info, trsh_bnds_info,
                           trsh_lps_info,
                           used_sgrlps_info, face_used_lps, 
                           outlps_info)
  IGRlong                *EFmsg;
  GRobjid                inlp_id;
  IGRint                 opix;
  struct EMSint_set      *unsort_set, *csort_set;
  GRobjid                sf_id;
  GRspacenum             cur_os;
  struct EMSsf_tol_info  *sf_tol_info;
  struct EMSgen_info     *trsh_bnds_info, *trsh_lps_info;
  struct EMSused_lps     *face_used_lps, *used_sgrlps_info;
  struct EMSgen_info     *outlps_info;
 
{
  OM_S_CHANSELECT  to_comps;
  
  struct EMSsftracedata   *test_trace = NULL;
  struct EMSsfintloopsdata *test_sflps = NULL;
  struct EMSsfintedpar    *lelem_intedpar = NULL;
  struct EMSsortbnd_info  *ed_bnd = NULL;
  struct EMSsorted_info   *ed_info = NULL;
  struct EMSsortlp_info   *trim_lp_info = NULL;
  
  IGRlong     OM_stat, rc, mthd_stat;
  IGRint      num_eds, edix, settyp, grix, sgrix,
              org_outlps_num_elems;
  GRobjid     ed_id, sgr_sf, sgr_lp;
  GRspacenum  dum_os;
  IGRboolean  cntinue;
  
  extern IGRboolean EFsgrlp_already_used();
  extern void       EFbuild_loop();
  extern void EFmemory_allocation();

  /* ***************************************************************** */
 
  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  org_outlps_num_elems = outlps_info->num_elems;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$get_channel_count (osnum = cur_os, objid = inlp_id,
                p_chanselect = &to_comps, count = (OMuint *)&num_eds);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  for (edix = 0; edix < num_eds; edix++)
  {
   OM_stat = om$get_objid_at_index (osnum = cur_os, objid = inlp_id,
                 p_chanselect = &to_comps, index = edix, 
                 objidaddr = &ed_id, osnumaddr = &dum_os);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
   
   cntinue = TRUE;

   while (cntinue)
   {
    cntinue = FALSE;

    for (settyp = 0; settyp < 2; settyp++)
    {
     test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                               &csort_set->trace_data[opix];
     test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                               &csort_set->sflp_data[opix];

     for (grix = 0; grix < test_trace->num_grps; grix++)
     {
      for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix]; sgrix++)
      {
       sgr_lp = test_sflps->loop_sf[grix][2*sgrix]; 
       sgr_sf = test_sflps->loop_sf[grix][2*sgrix+1];

       if ( IF_EQ_OBJID(sgr_sf, sf_id) && 
            !test_trace->subgrp_closed[grix][sgrix] &&
            !EFsgrlp_already_used(used_sgrlps_info, sgr_lp) )
       {
        lelem_intedpar = test_sflps->intedpars[grix][2*sgrix+1];
    
        if (IF_EQ_OBJID(ed_id, lelem_intedpar->edgeid))
        {
         cntinue = TRUE;
         EFget_sortbnd (trsh_bnds_info, ed_bnd);
         ed_bnd->bnd_type = EMSed_bnd_wopen_end;
         ed_bnd->next = NULL;
         ed_info = &ed_bnd->bnd_data.ed_info;
         ed_info->ed_id = ed_id;
         OM_BLOCK_MOVE (lelem_intedpar->point, ed_info->ed_pts,
                       sizeof(IGRdouble)*2);
         ed_info->ed_bounds[0] = lelem_intedpar->edgepar;

         EFbuild_loop (&rc, ed_bnd, opix, unsort_set, csort_set, 
                      sf_id, cur_os, sf_tol_info, trsh_bnds_info, 
                      trsh_lps_info, 
                      used_sgrlps_info, face_used_lps, &trim_lp_info);
         EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

         EFappend_gen_info (outlps_info, (IGRchar *)trim_lp_info);

        } /* if (IF_EQ_OBJID(ed_id, lelem_intedpar->edgeid)) */

       } /* if ( IF_EQ_OBJID(sgr_sf, sf_id) &&  */

      } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] */

     } /* for (grix = 0; grix < test_trace->num_grps && !ed_found; */

    } /* for (settyp = 0; settyp < 2 && !ed_found; settyp++) */

   } /* while (cntinue) */

  } /* for (edix = 0; edix < num_eds; edix++) */

  if (org_outlps_num_elems == outlps_info->num_elems)
  {
   EFget_sortbnd (trsh_bnds_info, ed_bnd);
   ed_bnd->bnd_type = EMSed_bnd_wopen_end;
   ed_bnd->next = NULL;
   ed_info = &ed_bnd->bnd_data.ed_info;
   ed_info->ed_id = ed_id;
   OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                       ed_info->ed_pts, NULL, ed_info->ed_bounds, NULL,
                       NULL),
                      senderid = NULL_OBJID,
                      targetid = ed_id, targetos = cur_os);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

   EFbuild_loop (&rc, ed_bnd, opix, unsort_set, csort_set, 
                  sf_id, cur_os, sf_tol_info, trsh_bnds_info, 
                  trsh_lps_info, 
                  used_sgrlps_info, face_used_lps, &trim_lp_info);
   EMerr_hndlr (!(1&rc), *EFmsg, rc, wrapup);

   EFappend_gen_info (outlps_info, (IGRchar *)trim_lp_info);

  } /* if (org_outlps_num_elems == outlps_info->num_elems) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFcreate_trimmed_lps");
  return;

} /* void EFcreate_trimmed_lps () */


/*
 * Given the information about a loop in the form of EMSsortbnd_info
 * linked list, convert into a object format.
 */

void  EFconstruct_loop_object (EFmsg, lp_info, trsh_tp_objects, sf_id, 
                               cur_os, sf_tol_info)

 IGRlong                      *EFmsg;
 struct EMSsortlp_info        *lp_info;
 struct EMStp_objects_info    *trsh_tp_objects;
 GRobjid                      sf_id;
 GRspacenum                   cur_os;
 struct EMSsf_tol_info        *sf_tol_info;
{
 OM_S_CHANSELECT          to_comps_chan, to_owner_chan;
 struct EMSpartolbasis    partolbasis;
 struct EMSsorted_info    *ed_info = NULL;
 struct EMSsortbnd_info   *lp_bnd = NULL;
 struct EMSsortsgr_info   *sgr_info = NULL; 
 struct EMSedgebound      beg_bound, end_bound;
 
 IGRdouble                par_tol, beg_pt[2], end_pt[2];
 IGRlong                  OM_stat, mthd_stat, rc;
 IGRint                   i;
 GRobjid                  ed_id;
 IGRushort        ed_props;
 GRspacenum               dum_os;
 extern void              EFget_sf_par_tol();

 /* ***************************************************************** */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 /*
  * If the lp_Info has only one sgr which is closed, use its loop
  * as lp_info->lp_id.
  */

 if (lp_info->bnd_info->bnd_type == EMSsgr_bnd &&
     lp_info->bnd_info->bnd_data.sgr_info.sgr_closed)
  lp_info->lp_id = lp_info->bnd_info->bnd_data.sgr_info.lp_id;
 else
 {
  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owner_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  EFget_sf_par_tol (&rc, sf_tol_info, sf_id, cur_os, &par_tol);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  if (trsh_tp_objects->num_lps)
   lp_info->lp_id = trsh_tp_objects->lp_ids[--trsh_tp_objects->num_lps];
  else
  {
   OM_stat = om$construct (classid = OPP_EMSloop_class_id,
                osnum = cur_os, p_objid = &lp_info->lp_id);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
  }
 
  lp_bnd = lp_info->bnd_info;

  while (lp_bnd)
  {
   if (lp_bnd->bnd_type == EMSsgr_bnd)
   {
    sgr_info = &lp_bnd->bnd_data.sgr_info;
    for (i = 0; i < sgr_info->num_elems; i++)
    {
     OM_stat = om$get_objid_at_index (objid = sgr_info->lp_id,
                  osnum = cur_os, p_chanselect = &to_comps_chan,
                  index = i, objidaddr = &ed_id, osnumaddr = &dum_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

     OM_stat = om$send (msg = message Root.connect (to_comps_chan,
                        OM_K_MAXINT, ed_id, cur_os, to_owner_chan, 
                        OM_K_MAXINT),
                       senderid = NULL_OBJID,
                       targetid = lp_info->lp_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    } /* for (i = 0; i < lp_bnd->bnd_data.sgr_info.num_elems; i++) */

   } /* if (lp_bnd->bnd_type == EMSsgr_bnd) */
   else
   {
    ed_info = &lp_bnd->bnd_data.ed_info;
    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                       beg_pt, end_pt, &beg_bound, &end_bound, NULL),
                      senderid = NULL_OBJID,
                      targetid = ed_info->ed_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_EdgeError, wrapup);

    if ( EM2ddistptpt (ed_info->ed_pts, beg_pt) <= par_tol    &&
         EM2ddistptpt (&ed_info->ed_pts[2], end_pt) <= par_tol)
     ed_id  = ed_info->ed_id;
    else
    {
     if (trsh_tp_objects->num_peds)
      ed_id = trsh_tp_objects->ped_ids[--trsh_tp_objects->num_peds];
     else
     {
      OM_stat = om$construct (classid = OPP_EMSpartedge_class_id,
                   osnum = cur_os, p_objid = &ed_id); 
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

     }
      OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                          &ed_props),
                         senderid = NULL_OBJID,
                         targetid = ed_info->ed_id, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      ed_props &= ~(EMED_MSCEXISTS | EMED_REVERSE_CONNECT 
                    | EMED_XYZ_CLOSED | EMED_SUBORDINATE | 
                    EMED_COMPATIBLE);
      ed_props |= EMED_OPEN;

      OM_stat = om$send (msg = message EMSpartedge.EMpeinit (&mthd_stat,
                          ed_props, ed_info->ed_bounds, NULL),
                         senderid = NULL_OBJID,
                         targetid = ed_id, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send (msg = message Root.connect (to_owner_chan,
                         OM_K_MAXINT, ed_id, cur_os, to_comps_chan, 
                         OM_K_MAXINT),
                        senderid = NULL_OBJID,
                        targetid = ed_info->ed_id, targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    } /* if ( EM2ddistptpt (ed_info->ed_pts, beg_pt) <= par_tol    */

    OM_stat = om$send (msg = message Root.connect (to_comps_chan, 
                       OM_K_MAXINT, ed_id, cur_os, to_owner_chan, 
                       OM_K_MAXINT),
                      senderid = NULL_OBJID,
                      targetid = lp_info->lp_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
                       
   } /* else for if (lp_bnd->bnd_type == EMSsgr_bnd) */

   lp_bnd = lp_bnd->next;
 
  } /* while (lp_bnd) */

  /*
   * Now the loop object has been constructed. Initialize it such that
   * it is made active and its type is correctly set.
   */

  partolbasis.is_valid = partolbasis.in_world = TRUE;
  partolbasis.tol = par_tol;
 
  OM_stat = om$send (msg = message EMSloop.EMlpinit (&mthd_stat, 
                      EMLP_ACTIVE, &partolbasis, NULL),
                     senderid = NULL_OBJID,
                     targetid = lp_info->lp_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_LoopError, wrapup);

 } /* else for if (lp_info->bnd_info->bnd_type == EMSsgr_bnd && */

wrapup:
 EMWRAPUP (*EFmsg, OM_stat, "EFconstruct_loop_object");
 return;

} /* void EFconstruct_loop_object () */

/*
 * Given a starting boundary, build a loop following
 * its logical direction. In case the starting boundary is an edge,
 * it will have its begin point correctly marked and its end point
 * may/not be correctly marked. On the other hand, if it is a subgroup,
 * its begin and its end points are always correctly marked.
 */


void EFbuild_loop (EFmsg, inbnd, opix, unsort_set, csort_set, 
                   sf_id, cur_os, sf_tol_info, trsh_bnds_info, 
                   trsh_lps_info,
                   used_sgrlps_info, face_used_lps, outlp_info)
 IGRlong                *EFmsg;
 struct EMSsortbnd_info *inbnd;
 IGRint                 opix;
 struct EMSint_set      *unsort_set, *csort_set;
 GRobjid                sf_id;
 GRspacenum             cur_os;
 struct EMSsf_tol_info  *sf_tol_info;
 struct EMSgen_info     *trsh_bnds_info, *trsh_lps_info;
 struct EMSused_lps     *face_used_lps, *used_sgrlps_info;
 struct EMSsortlp_info  **outlp_info;

{

 struct EMSsortbnd_info  *cur_bnd = NULL, *next_bnd = NULL;

 IGRdouble  par_tol, lp_beg_pt[2], lp_end_pt[2];
 IGRlong    rc, mthd_stat;
 IGRint     stat;
 IGRboolean lp_is_closed, act_lp_exists, i;
 GRobjid    act_lp_id;

 extern void EFget_sf_par_tol(), EFget_bnd_end_pt(), EFgetlp_next_bnd();
 extern void EFmemory_allocation();
 extern IGRint EMsend_loops();

 /* ************************************************************* */
 
 *EFmsg = EMS_S_Success;

 EFget_sf_par_tol (&rc, sf_tol_info, sf_id, cur_os, &par_tol);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 /*
  * The inbnd may be one following types:
  *  o A subgroup 
  *  o An existing edge
  *  o Part of an existing edge
  *
  * If it is a subgroup, it may be closed. If it is closed, it will
  * be the only component of the loop. On the other hand, Get the edge
  * on which the end point of this subgroup is incident on. Now,
  * search the cset as well as unsorted groups to find if any of its
  * subgroups are starting between the begin(build loop's last bnd's
  * end point) and its begin point.
  */

 EFget_sortlp (trsh_lps_info, *outlp_info);
 (*outlp_info)->lp_id = NULL_OBJID;
 (*outlp_info)->bnd_info = inbnd;  
 inbnd->next = NULL;
 
 /*
  * If the incoming start boundary is a subgroup and is closed, it
  * will be only component of this loop.
  */

 if (inbnd->bnd_type == EMSsgr_bnd && inbnd->bnd_data.sgr_info.sgr_closed)
 {
   if ( (used_sgrlps_info->num_lps+1) > used_sgrlps_info->lps_arrsz)
   {
     EFmemory_allocation (&rc, (IGRchar **) &used_sgrlps_info->lp_ids,
        used_sgrlps_info->num_lps+1, &used_sgrlps_info->lps_arrsz, 
           sizeof(GRobjid), 5, 5);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory,wrapup);
   }
   used_sgrlps_info->lp_ids[used_sgrlps_info->num_lps++] =
                          inbnd->bnd_data.sgr_info.lp_id;
 }
 else
 {
  /*
   * Get the begin point of the loop to be constructed
   */

   EFget_bnd_end_pt (&rc, inbnd, csort_set, unsort_set, opix,
                     cur_os, lp_beg_pt, NULL);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  /*
   * Now we have put the first boundary in the loop. Try to find 
   * rest of the boundaries and close the loop.
   */

  lp_is_closed = FALSE;
  cur_bnd = inbnd;
  EFget_sortbnd (trsh_bnds_info, next_bnd);

  while (!lp_is_closed)
  {
    /*
     * If the current boundary is a sgrp, add this sgrp to the
     * used sgrs info.
     * On the other hand, if the current boundary is an edge,
     * put its loop in the face_used_lps.
     */

    if (cur_bnd->bnd_type == EMSsgr_bnd)
    {
     if ( (used_sgrlps_info->num_lps+1) > used_sgrlps_info->lps_arrsz)
     {
       EFmemory_allocation (&rc, (IGRchar **) &used_sgrlps_info->lp_ids,
           used_sgrlps_info->num_lps+1, &used_sgrlps_info->lps_arrsz, 
           sizeof(GRobjid), 5, 5);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory,wrapup);
     }
     used_sgrlps_info->lp_ids[used_sgrlps_info->num_lps++] =
                          cur_bnd->bnd_data.sgr_info.lp_id;
    }
    else
    {
     stat = EMsend_loops (&rc, message EMSboundary.EMget_objid (
                                &mthd_stat, &act_lp_id),
                          cur_bnd->bnd_data.ed_info.ed_id, NULL, 
                          OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);

     act_lp_exists = FALSE;
     for (i = 0; i < face_used_lps->num_lps && !act_lp_exists; i++)
      if (IF_EQ_OBJID(face_used_lps->lp_ids[i], act_lp_id))
         act_lp_exists = TRUE;
    
     if (!act_lp_exists)
     {
      if ((face_used_lps->num_lps + 1 ) > face_used_lps->lps_arrsz)
      {
       EFmemory_allocation (&rc, (IGRchar **) &face_used_lps->lp_ids,
          face_used_lps->num_lps+1, &face_used_lps->lps_arrsz, 
          sizeof(GRobjid), 10, 5);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

      } /* if ((face_used_lps.num_lps + 1 ) > face_used_lps.arrsz) */

      face_used_lps->lp_ids[face_used_lps->num_lps++] = act_lp_id;

     } /* if (!act_lp_exists) */

    } /* if (cur_bnd->bnd_type == EMSsgr_bnd) */

    EFgetlp_next_bnd (&rc, sf_id, cur_bnd, opix, csort_set,
             unsort_set, sf_tol_info, cur_os, used_sgrlps_info, next_bnd);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);


    /*
     * Check if the end point of the cur_bnd is within tolerance
     * from the begin point of the loop. If so, loop is closed.
     */

    EFget_bnd_end_pt (&rc, cur_bnd, csort_set, unsort_set, 
                      opix, cur_os, NULL, lp_end_pt);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    if (EM2ddistptpt (lp_beg_pt, lp_end_pt) <= par_tol) 
    {
     lp_is_closed = TRUE;
     EFappend_gen_info (trsh_bnds_info, (IGRchar *)next_bnd);
    }
    else
    {
     /**** SM Feb 18, 1992.
      In case of an orientation problem (for whatever reason), there is a
      chance that the loop will never be closed. So I have put in a check
      to see whether the next boundary picked up for closure has already
      been visited. If so, error out.
     **********/

      {
       struct EMSsortbnd_info *this_bnd = NULL;
       struct EMSsorted_info *edbnd;
       struct EMSsortsgr_info *sgrbnd;

       this_bnd = inbnd;
       while(this_bnd)
        {
	 if(this_bnd->bnd_type != next_bnd->bnd_type)
	  {
	   this_bnd = this_bnd->next;
	   continue;
	  }
	
	 if(next_bnd->bnd_type == EMSsgr_bnd)
	  {
           if( (next_bnd->bnd_data.sgr_info.lp_id == 
                this_bnd->bnd_data.sgr_info.lp_id) &&
               (next_bnd->bnd_data.sgr_info.sf_id ==
	        this_bnd->bnd_data.sgr_info.sf_id))
	    {
	     *EFmsg = EMS_E_IntersectOrient;
	     cur_bnd->next = NULL;
	     goto wrapup;
	    }
	  }
	 else if(next_bnd->bnd_type == EMSed_bnd)
	  {
	   if(next_bnd->bnd_data.ed_info.ed_id ==
	      this_bnd->bnd_data.ed_info.ed_id)
	    {
	     *EFmsg = EMS_E_IntersectOrient;
	     cur_bnd->next = NULL;
	     goto wrapup;
	    }
	  }
	 else
	  {
	    *EFmsg = EMS_E_Fail;
	    cur_bnd->next = NULL;
	    goto wrapup;
	  }
	 this_bnd = this_bnd->next;
        }
      }

     /****** End SM Feb 18, 1992. *********/

     cur_bnd->next = next_bnd;
     cur_bnd = next_bnd;
     EFget_sortbnd (trsh_bnds_info, next_bnd);
      
    }

  } /* while (!lp_is_closed) */

 } /* if (inbnd->bnd_type == EMSsgr_bnd && 
          inbnd->bnd_data.sgr_info.sgr_closed) */
   
 wrapup:
 if(*EFmsg != EMS_E_IntersectOrient)
  {
   EMWRAPUP (*EFmsg, *EFmsg, "EFbuild_loop");
  }
 return; 
} /* void EFbuild_loop () */

/*
 * Given a boundary, get the next boundary following the logical 
 * direction of the incoming boundary. The incoming boundary can
 * be a subgrp, an existing edge or part of an existing edge.
 */ 

void EFgetlp_next_bnd (EFmsg, sf_id, cbnd, opix, csort_set, unsort_set, 
                       sf_tol_info, cur_os, used_sgrlps_info, nxtbnd)

 IGRlong                *EFmsg;
 GRobjid                sf_id;
 struct EMSsortbnd_info *cbnd;
 IGRint                 opix;
 struct EMSint_set      *csort_set, *unsort_set;
 struct EMSsf_tol_info  *sf_tol_info;
 GRspacenum             cur_os;
 struct EMSused_lps     *used_sgrlps_info;
 struct EMSsortbnd_info *nxtbnd;
{
 struct EMSsftracedata    *test_trace = NULL;
 struct EMSsfintloopsdata *test_sflps = NULL;
 struct EMSsortsgr_info   *sgr_info = NULL;
 struct EMSsfintedpar     *lelem_intedpar = NULL, *felem_intedpar = NULL;
 struct EMSsorted_info    *nxted_info = NULL, *ced_info = NULL;
 struct EMSedgebound      nxted_beg_bound, ced_end_bound, best_end_bound;

 IGRdouble  par_tol, felem_intedpar_parm, nxted_end_pt[2], 
            nxted_beg_pt[2], ced_end_pt[2],
            ced_beg_parm,  best_end_parm, best_end_pt[2];

 IGRlong    rc, OM_stat, mthd_stat;
 IGRint     best_settyp, best_grix, best_sgrix, stat, best_bnd_type, 
            settyp, grix, sgrix;

 GRobjid    nxted_id, ced_id, sgr_sf, sgr_lp;

 IGRboolean nxted_possible_candidate, cntinue, ed_parm_ascending;

 extern void  EFget_sf_par_tol(), EFsubgroup_already_processed();

 extern IGRint EMsend_loops();

 /* ************************************************************* */

 *EFmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 EFget_sf_par_tol (&rc, sf_tol_info, sf_id, cur_os, &par_tol);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

 if (cbnd->bnd_type == EMSsgr_bnd)
 {
   sgr_info = &cbnd->bnd_data.sgr_info;
   cntinue = TRUE;

   for (settyp = 0; settyp < 2 && cntinue; settyp++)
   {
    test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                               &csort_set->trace_data[opix];
    test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                               &csort_set->sflp_data[opix];

    for (grix = 0; grix < test_trace->num_grps && cntinue; grix++)
    {
     for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] &&
                     cntinue; sgrix++)
     {
      if (IF_EQ_OBJID(sgr_info->lp_id,test_sflps->loop_sf[grix][2*sgrix]))
      {
        cntinue = FALSE;
        lelem_intedpar = test_sflps->intedpars[grix][2*sgrix+1];       
      } 

     } 

    } /* for (grix = 0; grix < test_trace->num_grps && cntinue; grix++) */

   } /* for (settyp = 0; settyp < 2 && cntinue; settyp++) */

   /*
    * The subgroup may be intersecting the edge at one of three
    * locations:
    *  1) At begin point of the edge
    *  2) At end point of the edge
    *  3) At middle point of the edge
    *
    * In case intersection occured at the end point of the edge,
    * pick the edge following the edge under consideration
    * as the next edge.
    */

   nxtbnd->bnd_type = EMSed_bnd_wopen_end;
   nxted_info = &nxtbnd->bnd_data.ed_info;

   OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                       NULL, nxted_end_pt, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = lelem_intedpar->edgeid,
                     targetos = cur_os);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_EdgeError,wrapup);

   if (EM2ddistptpt (nxted_end_pt, lelem_intedpar->point) <= par_tol)
   {
     stat = EMsend_loops (&rc, message EMSloop.EMnext_edge (&mthd_stat,
               EMGetEd_Next, lelem_intedpar->edgeid, &nxted_id), 
               lelem_intedpar->edgeid, NULL, 
               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);

     OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        nxted_beg_pt, NULL, &nxted_beg_bound, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = nxted_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_EdgeError,wrapup);

     nxted_info->ed_id = nxted_id;
     OM_BLOCK_MOVE (&nxted_beg_bound, nxted_info->ed_bounds, 
                    sizeof(struct EMSedgebound));
     OM_BLOCK_MOVE (nxted_beg_pt,nxted_info->ed_pts, sizeof(IGRdouble)*2);

   } /* if (EM2ddistptpt (nxted_end_pt,lelem_intedpar->point)<=par_tol) */
   else 
   {
    nxted_info->ed_id = lelem_intedpar->edgeid;
    OM_BLOCK_MOVE (&lelem_intedpar->edgepar, nxted_info->ed_bounds,
                   sizeof(struct EMSedgebound));
    OM_BLOCK_MOVE (lelem_intedpar->point, nxted_info->ed_pts,
                       sizeof(IGRdouble)*2);

   } /* else for if(EM2ddistptpt(ed_end_pt,lelem_intedpar->point)<= par */

 } /* if (cbnd->bnd_type == EMSsgr_bnd) */

 else
 {
   /*
    * The current edge may/not have its end point fixed.
    *
    *  o If its end point is fixed,
    *    {
    *      o Search through all of the subgrps of the csort_set
    *        and unsort_set for a subgrp which belongs to the same
    *        surface, is not closed, has not been used and whose
    *        begin point matches with that of the end point of 
    *        current edge.
    *      o If such a subgrp is found, it will the next boundary of the 
    *        loop.
    *       o Else, if the end point matches with the begin point of 
    *         next edge (it will not match if its end point is trimmed),
    *         next edge will be next boundary of the loop.
    *        o Else, an error has occured.
    *     }
    *     else
    *     {
    *      o search for the subgrp with the same criterion except just
    *        subgrp may start anywhere between the begin and the 
    *        end point of current edge.
    *      o If such a subgrp is found, it will be the next boundary
    *        of the loop.
    *      o Else next_edge will be next boundary.
    *     }
    */

    ced_info = &cbnd->bnd_data.ed_info;
    ced_id = ced_info->ed_id;

    /*
     * Check if the next_ed is a possible candidate.
     */

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        NULL, ced_end_pt, NULL, &ced_end_bound, NULL),
                       senderid = NULL_OBJID, targetid = ced_id,
                       targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    nxted_possible_candidate = TRUE; 

    if (cbnd->bnd_type == EMSed_bnd_wfixed_end)
    {
     if ( EM2ddistptpt(&ced_info->ed_pts[2], ced_end_pt) > par_tol)
     {
       nxted_possible_candidate = FALSE;
       OM_BLOCK_MOVE (&ced_info->ed_pts[2], 
                      ced_end_pt, sizeof(IGRdouble)*2);
     }
    }
    else
    {
     ced_beg_parm = ced_info->ed_bounds[0].span_inx + 
                    ced_info->ed_bounds[0].param;
     best_end_parm = ced_end_bound.span_inx + ced_end_bound.param;
     best_end_bound = ced_end_bound;
     OM_BLOCK_MOVE (ced_end_pt, best_end_pt, sizeof(IGRdouble)*2);

     ed_parm_ascending = best_end_parm > ced_beg_parm ? 
                         TRUE : FALSE;

    } /* else for if (cbn->bnd_type == EMSed_bnd_wfixed_end) */

    if (nxted_possible_candidate)
    {
     stat = EMsend_loops (&rc, message EMSloop.EMnext_edge (&mthd_stat,
               EMGetEd_Next, ced_id, &nxted_id), ced_id, NULL, 
               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail, wrapup);

     best_bnd_type = EMSed_bnd_wopen_end;

    } /* if (nxted_possible_candidate) */
    else
    {
     nxted_id = NULL_OBJID;
     best_bnd_type = EMSno_bnd;
    }

    cntinue = TRUE;

    for (settyp = 0; settyp < 2 && cntinue; settyp++)
    {
     test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                                &csort_set->trace_data[opix];
     test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                                &csort_set->sflp_data[opix];

     for (grix = 0; grix < test_trace->num_grps && cntinue; grix++)
     {
      for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] && 
                                                     cntinue; sgrix++)
      {
       sgr_lp = test_sflps->loop_sf[grix][2*sgrix];
       sgr_sf = test_sflps->loop_sf[grix][2*sgrix+1];
       felem_intedpar = test_sflps->intedpars[grix][2*sgrix];

       if ( IF_EQ_OBJID(sgr_sf, sf_id) && 
            !test_trace->subgrp_closed[grix][sgrix] &&
/*
            !EFsgrlp_already_used(used_sgrlps_info, sgr_lp) &&
*/
            (IF_EQ_OBJID(felem_intedpar->edgeid, ced_id) ||
             IF_EQ_OBJID(felem_intedpar->edgeid, nxted_id) ) )
       {
         if ( cbnd->bnd_type == EMSed_bnd_wfixed_end)
         {
           if (EM2ddistptpt(felem_intedpar->point,ced_end_pt) <= par_tol )
           {
             best_bnd_type = EMSsgr_bnd;
             best_settyp = settyp;
             best_grix = grix;
             best_sgrix = sgrix;
             cntinue = FALSE;
            }

         } /* if ( cbnd->bnd_type == EMSed_bnd_wfixed_end) */
         else
         {
          felem_intedpar_parm = felem_intedpar->edgepar.span_inx +
                                felem_intedpar->edgepar.param;

          if ((EM2ddistptpt (ced_end_pt, best_end_pt) <= par_tol &&
               EM2ddistptpt(felem_intedpar->point, ced_end_pt) <= par_tol)
                                ||
                ( IF_EQ_OBJID(felem_intedpar->edgeid, ced_id)  &&
                  ( ed_parm_ascending ?
                     (felem_intedpar_parm > ced_beg_parm  && 
                      felem_intedpar_parm <= best_end_parm )   :
                     (felem_intedpar_parm < ced_beg_parm  && 
                      felem_intedpar_parm >= best_end_parm ) ) ) )
          {
            best_bnd_type = EMSsgr_bnd;
            best_settyp = settyp;
            best_grix = grix;
            best_sgrix = sgrix;
            best_end_parm = felem_intedpar_parm;
            best_end_bound = felem_intedpar->edgepar;
            OM_BLOCK_MOVE (felem_intedpar->point, best_end_pt,
                           sizeof(IGRdouble) * 2);

          } /* if (felem_intedpar_parm > ced_beg_parm &&  */

         } /* else for if ( cbnd->bnd_type == EMSed_bnd_wfixed_end) */

       } /* if ( IF_EQ_OBJID(sgr_sf, sf_id) && */

      } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] && */

     } /* for (grix = 0; grix < test_trace->num_grps && cntinue;grix++) */

   } /* for (settyp = 0; settyp < 2 && cntinue; settyp++) */

   /*
    * Fill in the next_boundary information.
    */
   
   switch (best_bnd_type)
   {
    case EMSsgr_bnd:

    nxtbnd->bnd_type = EMSsgr_bnd;
    sgr_info = &nxtbnd->bnd_data.sgr_info;

    test_trace = (best_settyp == 0) ? &unsort_set->trace_data[opix] : 
                                      &csort_set->trace_data[opix];

    test_sflps = (best_settyp == 0) ? &unsort_set->sflp_data[opix] : 
                                      &csort_set->sflp_data[opix];

    sgr_info->num_elems = 
             test_trace->num_elems_subgrp[best_grix][best_sgrix];
    sgr_info->sgr_rev = test_trace->subgrp_rev[best_grix][best_sgrix];
    sgr_info->sgr_closed = 
                     test_trace->subgrp_closed[best_grix][best_sgrix];
    sgr_info->lp_id = test_sflps->loop_sf[best_grix][2*best_sgrix];
    sgr_info->sf_id = test_sflps->loop_sf[best_grix][2*best_sgrix+1];

    break;

   case EMSed_bnd_wopen_end:

    nxtbnd->bnd_type = EMSed_bnd_wopen_end;
    nxted_info = &nxtbnd->bnd_data.ed_info;
    nxted_info->ed_id = nxted_id;

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                       nxted_info->ed_pts, NULL, nxted_info->ed_bounds,
                       NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = nxted_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    break;

   default:
     *EFmsg = EMS_E_IntersectClosure;
    
   } /* switch (best_bnd_type) */

   /*
    * If the end of the incoming boundary was open fill its end point
    * information.
    */

   if (cbnd->bnd_type == EMSed_bnd_wopen_end)
   {
    ced_info = &cbnd->bnd_data.ed_info;
    OM_BLOCK_MOVE (best_end_pt, &ced_info->ed_pts[2], 
                    sizeof(IGRdouble)*2);
    ced_info->ed_bounds[1] = best_end_bound;
    cbnd->bnd_type = EMSed_bnd_wfixed_end;

   } /* if (cbnd->bnd_type == EMSed_bnd_wopen_end) */

 } /* else for if (cbnd->bnd_type == EMSsgr_bnd) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFgetlp_next_bnd");
  return;

} /* void EFgetlp_next_bnd () */

void EFadd_group_to_set (EFmsg, cset, unsort_set, grix, opix, cur_os)
 IGRlong            *EFmsg;
 struct EMSint_set  *cset, *unsort_set;
 IGRint             grix, opix;
 GRspacenum         cur_os; 
{
 OM_S_CHANSELECT        lp_ed_chan, ed_lp_chan, cm_ed_chan;
 OM_S_OBJECT_LINKAGE    cm_ed_list;
 struct EMSsftracedata  *unsort_trace = NULL, *cset_trace = NULL;
 struct EMSsfintloopsdata *unsort_sflps = NULL, *cset_sflps = NULL;

 IGRlong          rc, OM_stat;
 IGRint           initial_size, incr, arrsz, num_grps, blk_size, i,
                  j, trix[2], count;
 GRobjid          gr_lp, ed_id, cm_lp;
 IGRboolean       cm_gr_found;

 extern void            EFmemory_allocation();

 /* **************************************************************** */

 *EFmsg = EMS_S_Success;

/*
 * Since the group infomation of the two operands do not have
 * one_to_one correspondence as per the index, grix of the opix
 * may/may not correspond to grix of the compilemnt operand.
 */

OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

gr_lp = unsort_set->sflp_data[opix].loop_sf[grix][0];
OM_stat = om$get_objid_at_index (objid = gr_lp, osnum = cur_os,
             p_chanselect = &lp_ed_chan, index = 0, objidaddr = &ed_id,
             osnumaddr = &cur_os);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

OM_stat = om$get_channel_objects (objid = ed_id, osnum = cur_os,
             p_chanselect = &cm_ed_chan, list = &cm_ed_list, size = 1,
             count = (OMuint *)&count);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

OM_stat = om$get_objid_at_index(objid = cm_ed_list.S_objid, 
             osnum = cur_os, p_chanselect = &ed_lp_chan, index = 0, 
             objidaddr = &cm_lp, osnumaddr = &cur_os);
EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

unsort_trace = &unsort_set->trace_data[opix == 0 ? 1 : 0];
unsort_sflps = &unsort_set->sflp_data[opix == 0 ? 1 : 0];

cm_gr_found = FALSE;

for (i = 0; i < unsort_trace->num_grps && !cm_gr_found; i++)
{
 for (j = 0; j < unsort_trace->num_subgrps_grp[i] && !cm_gr_found; j++)
 {
  if (IF_EQ_OBJID(cm_lp, unsort_sflps->loop_sf[i][2*j]))
  {
   cm_gr_found = TRUE;
   trix[opix == 0 ? 1 : 0] = i;
  }
 } /* for (j = 0; j < test_trace->num_subgrps_grp[i] &&  */

} /* for (i = 0; i < test_trace->num_grps && !cm_gr_found; i++) */

trix[opix] = grix;

for (i = 0; i < 2; i++)
{
 unsort_trace = &unsort_set->trace_data[i];
 cset_trace = &cset->trace_data[i];
 unsort_sflps = &unsort_set->sflp_data[i];
 cset_sflps = &cset->sflp_data[i];

 if (cset->trdata_arrsz[i] < (cset_trace->num_grps + 1) )
 {
  initial_size =unsort_trace->num_grps > 10 ? 10 : unsort_trace->num_grps;
  incr = unsort_trace->num_grps > 5 ? 5 : unsort_trace->num_grps;

  /*
   * Allocate space for trace_data pointers
   */

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar **) &cset_trace->num_subgrps_grp, 
    cset_trace->num_grps+1, &arrsz, sizeof(IGRint), initial_size, 
    incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ***)&cset_trace->num_elems_subgrp,
    cset_trace->num_grps+1, &arrsz, sizeof(IGRint *), initial_size, 
    incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ****) &cset_trace->elems, 
    cset_trace->num_grps+1, &arrsz,
    sizeof(struct EMSintobj **), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ***) &cset_trace->subgrp_rev, 
    cset_trace->num_grps+1, &arrsz, sizeof(IGRboolean *), 
    initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ****) &cset_trace->elem_rev, 
    cset_trace->num_grps+1, &arrsz, sizeof(IGRboolean **), 
    initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar **) &cset_trace->grp_closed, 
    cset_trace->num_grps+1, &arrsz, sizeof(IGRboolean), initial_size,
    incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ***) &cset_trace->subgrp_closed, 
    cset_trace->num_grps+1, &arrsz, 
    sizeof(IGRboolean *), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  /*
   * Allocate space for sflp_data pointers.
   */

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ***) &cset_sflps->loop_sf, 
    cset_trace->num_grps+1, &arrsz, 
    sizeof(GRobjid *), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ***) &cset_sflps->endedges,
    cset_trace->num_grps+1, &arrsz, 
    sizeof(GRobjid *), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  arrsz = cset->trdata_arrsz[i];
  EFmemory_allocation (&rc, (IGRchar ****) &cset_sflps->intedpars,
    cset_trace->num_grps+1, &arrsz, 
    sizeof(struct EMSsfintedpar **), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  EFmemory_allocation (&rc, (IGRchar ***) &cset_sflps->sfpartolb,
    cset_trace->num_grps+1, &cset->trdata_arrsz[i], 
    sizeof(GRobjid *), initial_size, incr);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);
     
 } /* if (cset->trdata_arrsz[i] < (cset_trace->num_grps + 1) ) */
  
 num_grps = cset_trace->num_grps;
 
 /*
  * Add trace data info
  */

 cset_trace->num_subgrps_grp[num_grps] = 
                         unsort_trace->num_subgrps_grp[trix[i]];
 cset_trace->num_elems_subgrp[num_grps] = 
                               unsort_trace->num_elems_subgrp[trix[i]];
 cset_trace->elems[num_grps] = unsort_trace->elems[trix[i]];
 cset_trace->subgrp_rev[num_grps] = unsort_trace->subgrp_rev[trix[i]];
 cset_trace->elem_rev[num_grps] = unsort_trace->elem_rev[trix[i]];
 cset_trace->grp_closed[num_grps] = unsort_trace->grp_closed[trix[i]];
 cset_trace->subgrp_closed[num_grps] = unsort_trace->subgrp_closed[trix[i]];
 cset_trace->num_grps++;  

 /*
  * Add sflps data info
  */

 cset_sflps->loop_sf[num_grps] = unsort_sflps->loop_sf[trix[i]];
 cset_sflps->endedges[num_grps] = unsort_sflps->endedges[trix[i]];
 cset_sflps->intedpars[num_grps] = unsort_sflps->intedpars[trix[i]];
 cset_sflps->sfpartolb[num_grps] = unsort_sflps->sfpartolb[trix[i]];

 blk_size = unsort_trace->num_grps - 1 - trix[i];

 if (blk_size)
 {

  /*
   * Remove trace data from unsort set.
   */

  OM_BLOCK_MOVE (&unsort_trace->num_subgrps_grp[trix[i]+1], 
     &unsort_trace->num_subgrps_grp[trix[i]], sizeof(IGRint)* blk_size);

  OM_BLOCK_MOVE (&unsort_trace->num_elems_subgrp[trix[i]+1], 
   &unsort_trace->num_elems_subgrp[trix[i]], sizeof(IGRint *) * blk_size);

  OM_BLOCK_MOVE (&unsort_trace->elems[trix[i]+1], 
   &unsort_trace->elems[trix[i]],sizeof(struct EMSintobj **)*blk_size);

  OM_BLOCK_MOVE (&unsort_trace->subgrp_rev[trix[i]+1], 
   &unsort_trace->subgrp_rev[trix[i]], sizeof(IGRboolean *) * blk_size);

  OM_BLOCK_MOVE (&unsort_trace->elem_rev[trix[i]+1], 
   &unsort_trace->elem_rev[trix[i]], sizeof(IGRboolean **) * blk_size);

  OM_BLOCK_MOVE (&unsort_trace->grp_closed[trix[i]+1], 
   &unsort_trace->grp_closed[trix[i]], sizeof(IGRboolean) * blk_size);

  OM_BLOCK_MOVE (&unsort_trace->subgrp_closed[trix[i]+1], 
   &unsort_trace->subgrp_closed[trix[i]],sizeof(IGRboolean *) * blk_size);

  /*
   * Remove sflps data from unsort set.
   */

  OM_BLOCK_MOVE (&unsort_sflps->loop_sf[trix[i]+1], 
     &unsort_sflps->loop_sf[trix[i]], sizeof(IGRint)* blk_size);

  OM_BLOCK_MOVE (&unsort_sflps->endedges[trix[i]+1], 
     &unsort_sflps->endedges[trix[i]], sizeof(IGRint)* blk_size);

  OM_BLOCK_MOVE (&unsort_sflps->intedpars[trix[i]+1], 
     &unsort_sflps->intedpars[trix[i]], sizeof(IGRint)* blk_size);

  OM_BLOCK_MOVE (&unsort_sflps->sfpartolb[trix[i]+1], 
     &unsort_sflps->sfpartolb[trix[i]], sizeof(IGRint)* blk_size);

 } /* if (blk_size) */

 unsort_trace->num_grps--;

} /* for (i = 0; i < 2; i++) */

 wrapup:
  EMWRAPUP (*EFmsg, *EFmsg, "EFadd_group_to_set");
  return;

} /* void EFadd_group_to_set () */


void EFget_bnd_end_pt (EFmsg, bnd_info, csort_set, unsort_set,
                       opix, cur_os, beg_pt, end_pt)
 IGRlong                  *EFmsg;
 struct EMSsortbnd_info   *bnd_info;
 struct EMSint_set        *csort_set, *unsort_set;
 IGRint                   opix;
 GRspacenum               cur_os;
 IGRdouble                *beg_pt, *end_pt;
{
  struct EMSsortsgr_info  *sgr_info = NULL;
  struct EMSsftracedata   *test_trace = NULL;
  struct EMSsfintloopsdata *test_sflps = NULL; 
  struct EMSsfintedpar     *felem_intedpar = NULL, *lelem_intedpar = NULL;

  IGRlong             OM_stat;
  IGRint              settyp, grix, sgrix;
  IGRboolean          cntinue = TRUE;
  GRobjid             sgr_lp;
  
  /* **************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if (bnd_info->bnd_type == EMSsgr_bnd)
  {
    sgr_info = &bnd_info->bnd_data.sgr_info;

    for (settyp = 0; settyp < 2 && cntinue; settyp++)
    {
     test_trace = settyp == 0 ? &unsort_set->trace_data[opix] :
                                &csort_set->trace_data[opix];
     test_sflps = settyp == 0 ? &unsort_set->sflp_data[opix] :
                                &csort_set->sflp_data[opix];

     for (grix = 0; grix < test_trace->num_grps && cntinue; grix++)
     {
      for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix] 
                       && cntinue; sgrix++)
      {
       sgr_lp = test_sflps->loop_sf[grix][2*sgrix];
       if (IF_EQ_OBJID(sgr_lp, sgr_info->lp_id))
       {
         if (beg_pt)
         {
          felem_intedpar = test_sflps->intedpars[grix][2*sgrix];
          OM_BLOCK_MOVE (felem_intedpar->point, beg_pt, 
                         sizeof(IGRdouble)*2);
         }

         if (end_pt)
         {
          lelem_intedpar = test_sflps->intedpars[grix][2*sgrix+1];
          OM_BLOCK_MOVE (lelem_intedpar->point, end_pt, 
                         sizeof(IGRdouble)*2);
         }

         cntinue = FALSE;

       } /* if (IF_EQ_OBJID(sgr_lp, sgr_info->lp_id)) */

      } /* for (sgrix = 0; sgrix < test_trace->num_subgrps_grp[grix];  */

     } /* for (grix = 0; grix < test_trace->num_grps;grix++) */

   } /* for (settyp = 0; settyp < 2; settyp++) */

  } /* if (bnd_info->bnd_type == EMSsgr_bnd) */
  else
  {
   if (beg_pt)
    OM_BLOCK_MOVE (bnd_info->bnd_data.ed_info.ed_pts, 
                   beg_pt, sizeof(IGRdouble) * 2);
   if (end_pt)
    OM_BLOCK_MOVE (&bnd_info->bnd_data.ed_info.ed_pts[2], 
                   end_pt, sizeof(IGRdouble) * 2);

  } /* else for if (bnd_info->bnd_type == EMSsgr_bnd) */

wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFget_bnd_end_pt");
 return;

} /* void EFget_bnd_end_pt () */

void EFget_sf_par_tol (EFmsg, sf_tol_info, sf_id, cur_os, par_tol)
 IGRlong               *EFmsg;
 struct EMSsf_tol_info *sf_tol_info;
 GRobjid               sf_id;
 GRspacenum            cur_os;
 IGRdouble             *par_tol;
{
 IGRint         i, arrsz;
 IGRlong        rc, OM_stat, mthd_stat;
 IGRboolean     sf_tol_exists = FALSE, world_flag = TRUE;
 extern void    EFmemory_allocation();

 /* ***************************************************************** */

 *EFmsg = EMS_S_Success;

 sf_tol_exists = FALSE;
 for (i = 0; i < sf_tol_info->num_sfs && !sf_tol_exists; i++)
 {
   if (IF_EQ_OBJID (sf_id, sf_tol_info->sf_ids[i]))
   {
     sf_tol_exists = TRUE;
     *par_tol = sf_tol_info->par_tols[i];
   }
   
 } /* for (i = 0; i < sf_tol_info->num_sfs && !sf_tol_exists; i++) */

 if (!sf_tol_exists)
 {
  if ((sf_tol_info->num_sfs+1) > sf_tol_info->sfs_arrsz)
  {
   arrsz = sf_tol_info->sfs_arrsz;
   EFmemory_allocation (&rc, (IGRchar **) &sf_tol_info->sf_ids,
     sf_tol_info->num_sfs+1, &arrsz, sizeof(GRobjid), 10, 5);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

   EFmemory_allocation (&rc, (IGRchar **) &sf_tol_info->par_tols,
     sf_tol_info->num_sfs+1, &sf_tol_info->sfs_arrsz, 
     sizeof(IGRdouble), 10, 5);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);

  } /* if ((sf_tol_info->num_sfs+1) > sf_tol_info->sfs_arrsz) */

  world_flag = TRUE;
  OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis (&mthd_stat,
                      sf_tol_info->mattyp, sf_tol_info->matrix, 
                      &world_flag, FALSE, par_tol),
                     senderid = NULL_OBJID,
                     targetid = sf_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  sf_tol_info->sf_ids[sf_tol_info->num_sfs] = sf_id;
  sf_tol_info->par_tols[sf_tol_info->num_sfs++] = *par_tol;

 } /* if (!sf_tol_exists) */

wrapup:
  EMWRAPUP (*EFmsg, *EFmsg, "EFget_sf_par_tol");
  return;

} /* void EFget_sf_par_tol () */


void EFtrash_lp_info_object (EFmsg, lp_info, cur_os, trsh_tp_objects)

     IGRlong                     *EFmsg;
     struct  EMSsortlp_info      *lp_info;
     GRspacenum                  cur_os;
     struct  EMStp_objects_info  *trsh_tp_objects;

 {
  OM_S_CHANSELECT        to_inner, to_outter, to_comps;

  IGRlong                OM_stat, rc;
  IGRint                 num_eds, eix;
  GRobjid                ed_id, lp_id;
  GRspacenum             dum_os;
  OMuword                ed_classid;
  IGRboolean             trash_lp_object = TRUE;
  extern void            EFmemory_allocation();

  /* ***************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  
  lp_id = lp_info->lp_id;

  /*
   * Disconnect lp from its owner and childern loops.
   */

  OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$send (msg = message Root.wild_disconnect (to_inner),
                      senderid = NULL_OBJID,
                      targetid = lp_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.wild_disconnect (to_outter),
                      senderid = NULL_OBJID,
                      targetid = lp_id, targetos = cur_os);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  /*
   * If lp_info has only one sgr as boundary, it has to be
   * a closed sgr. Since, a new loop is not constucted for
   * a closed sgr, Donot trash this loop. 
   */

  if ( lp_info->bnd_info->bnd_type == EMSsgr_bnd &&
       IF_EQ_OBJID(lp_info->bnd_info->bnd_data.sgr_info.lp_id, 
                   lp_id) )
    trash_lp_object = FALSE;

  if (trash_lp_object)
  {

   OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

   /*
    * o Check if it has a partial edge. If so, disconnect the
    *   partail edge from its edge. Add the partial edge
    *   to trsh_tp_objects. Only partial edge is handled as it is
    *   only kind of edge that is created in closing process.
    * o Add the lp object to the trsh_tp_objects.
    */

   OM_stat = om$get_channel_count (objid = lp_id, osnum = cur_os,
                  p_chanselect = &to_comps, count = (OMuint *)&num_eds);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

   for (eix = 0; eix < num_eds; eix++)
   {
     OM_stat = om$get_objid_at_index (osnum = cur_os, 
                   objid = lp_id, p_chanselect = &to_comps, index = eix, 
                   objidaddr = &ed_id, osnumaddr = &dum_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

     OM_stat = om$get_classid (osnum = cur_os, objid = ed_id, 
                               p_classid = &ed_classid);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror,wrapup);

     OM_stat = om$is_ancestry_valid (subclassid = ed_classid,
                   superclassid = OPP_EMSpartedge_class_id);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

     if (OM_stat == OM_S_SUCCESS)
     {
       OM_stat = om$send (msg = message Root.wild_disconnect (to_comps),
                          senderid = NULL_OBJID,
                          targetid = ed_id, targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

       if ((trsh_tp_objects->num_peds+1) > trsh_tp_objects->peds_arrsz)
       {
        EFmemory_allocation (&rc, (IGRchar **) &trsh_tp_objects->ped_ids,
          trsh_tp_objects->num_peds + 1, &trsh_tp_objects->peds_arrsz,
          sizeof(GRobjid), 10, 5);
        EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_NoDynamicMemory, wrapup);
       }

       trsh_tp_objects->ped_ids[trsh_tp_objects->num_peds++] = ed_id;

     } /* if (OM_stat == OM_S_SUCCESS) */

    } /* for (eix = 0; eix < num_eds; eix++) */

    OM_stat = om$send (msg = message Root.wild_disconnect (to_comps),
                        senderid = NULL_OBJID,
                        targetid = lp_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    if ((trsh_tp_objects->num_lps+1) > trsh_tp_objects->lps_arrsz)
    {
       EFmemory_allocation (&rc, (IGRchar **) &trsh_tp_objects->lp_ids,
        trsh_tp_objects->num_lps+1, &trsh_tp_objects->lps_arrsz, 
        sizeof(GRobjid), 10, 5);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    }

    trsh_tp_objects->lp_ids[trsh_tp_objects->num_lps++] = lp_id;

  } /* if (trash_lp_object) */

  wrapup:

   EMWRAPUP (*EFmsg, OM_stat, "EFtrash_lp_info_object");

  return;
   
 } /* void EFtrash_lp_info_object () */

void EFtrash_lp_info (EFmsg, lps_info, lp_id, cur_os,
                      used_sgrlps_info, trsh_bnds_info,
                      trsh_lps_info, trsh_tp_objects, trash_lp_object,
                      trash_lp_bnds_info)

     IGRlong                     *EFmsg;
     struct  EMSgen_info         *lps_info;
     GRobjid                     lp_id;
     GRspacenum                  cur_os;
     struct  EMSused_lps         *used_sgrlps_info;
     struct  EMSgen_info         *trsh_bnds_info, *trsh_lps_info;
     struct  EMStp_objects_info  *trsh_tp_objects;
     IGRboolean                  trash_lp_object, trash_lp_bnds_info;
{
  struct EMSsortlp_info  *clp_info = NULL;
  struct EMSsortbnd_info *lp_bnd = NULL;
  struct EMSsortsgr_info *sgr_info = NULL;

  IGRlong     OM_stat, rc;
  IGRint      lpix, blk_size, i;
  IGRboolean  trash_clp_info;

  extern void     EFtrash_lp_info_object ();
  extern void     EFmemory_allocation();


  /* ***************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  
  for (lpix = 0; lpix < lps_info->num_elems; lpix++)
  {
   clp_info = (struct EMSsortlp_info *) lps_info->elems[lpix]; 

   if (IF_EQ_OBJID(clp_info->lp_id, lp_id))
   {
    trash_clp_info = trash_lp_object && trash_lp_bnds_info;

    if (trash_lp_object)
    {

     EFtrash_lp_info_object (&rc, clp_info, cur_os, trsh_tp_objects);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

    } /* if (trash_lp_object) */
   
    if (trash_lp_bnds_info)
    {
     lp_bnd = clp_info->bnd_info;
     
     /*
      * Trash loop bnds. If this bnd is a sgr, remove its entry from the 
      * used_sgrlps_info.
      */

     while (lp_bnd)
     {
      if (lp_bnd->bnd_type == EMSsgr_bnd)
      {      
       sgr_info = &lp_bnd->bnd_data.sgr_info;

       for (i = 0; i < used_sgrlps_info->num_lps; i++)
       {
        if (IF_EQ_OBJID(sgr_info->lp_id, used_sgrlps_info->lp_ids[i]))
        {
          blk_size = used_sgrlps_info->num_lps - 1 - i;
          if (blk_size)
           OM_BLOCK_MOVE (&used_sgrlps_info->lp_ids[i+1],
                 &used_sgrlps_info->lp_ids[i], blk_size*sizeof(GRobjid));
          used_sgrlps_info->num_lps--;
          break;
        }
       } /* for (i = 0; i < used_sgrlps_info->num_lps; i++) */

      } /* if (lp_bnd->bnd_type == EMSsgr_bnd) */

      EFappend_gen_info (trsh_bnds_info, (IGRchar *)lp_bnd);
      lp_bnd = lp_bnd->next;

     } /* while (lp_bnd) */

    } /* if (trash_lp_bnds_info) */

    if (trash_clp_info)
      EFappend_gen_info (trsh_lps_info, (IGRchar *)clp_info);

     blk_size = (lps_info->num_elems - 1 - lpix) * sizeof(IGRchar *);
     if (blk_size)
      OM_BLOCK_MOVE (&lps_info->elems[lpix+1], &lps_info->elems[lpix],
                     blk_size);
     lps_info->num_elems--;
     break;

   } /* if (IF_EQ_OBJID(clp_info->lp_id, lp_id)) */

  } /* for (lpix = 0; lpix < lps_info->num_elems; lpix++) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFtrash_lp_info");
  return;

} /* void EFtrash_lp_info () */


end implementation EMSsfboolean;
