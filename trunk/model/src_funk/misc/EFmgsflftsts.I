/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation EMSlift;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"

/*

 ABSTRACT
    This function is used by a single surface lift operation.
    In a single surface lift process, the new surfaces are
    constructed to fill the gaps among the old and new geometries
    of the edges. This is accomplished by creating a EMSsldlift
    state over the surface or surface state tree that owns the surface
    and its copy. The surface and its copy have their edges connected 
    across the common edge channel. Finally the surface is modified 
    using one of lift operations.
    In the process of lifting the surface, a new EMSsl_lift/EMSsldlift
    node is created. The objective of this method is to merge these
    two lift nodes such that the user gets the impression as
    if the surface is conevrted into a solid in the lift process
    and behaves like that in undo and redo operations. Also, it will
    maintain the surface state tree if there is one before the lift
    process started.

    History
              RC    05/24/88    Creation date
*/

from   EMSsubbs    import    EMget_edges, EMgetbsdef;
from   EMSsolid    import    EMorient_yourself;

void EFmerge_single_sf_lift_states (
     EFmsg,
     delete_st_GRid,
     keep_st_GRid,
     lft_sf_GRid,
     md_env)
  
   IGRlong           *EFmsg;
   struct  GRid      delete_st_GRid, keep_st_GRid, lft_sf_GRid;
   struct  GRmd_env  *md_env;

{
   struct EMSlftssi_table  *kst_info;
   union  EMSssi_table        *ssi;
   OM_S_CHANSELECT            to_cmpnts, to_owners;
   struct GRid                *cmpnt_sf_GRids, lft_sf_owner;
   struct IGRbsp_surface      lft_sf_def;
   IGRlong                    OM_stat, mthd_stat, 
                              owner_index = OM_K_MAXINT;
   IGRint                     i, num_cmpnt_sf;
   OMuint 		      num_owners;
   IGRushort                  mask;
   IGRboolean                 action;
   void                       EFgetobjids ();

   OM_stat = OM_S_SUCCESS;
   *EFmsg = EMS_S_Success;
   ssi = NULL;
   cmpnt_sf_GRids = NULL;

   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnts);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   /*
    * Get the save state information of the state to keep.
    */

   OM_stat = om$send (msg = message EMSdpr.EMgetSSI (&mthd_stat,
                       &ssi), 
                      senderid = NULL_OBJID,
                      targetid = keep_st_GRid.objid,
                      targetos = keep_st_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);       

   kst_info = &ssi->lft_info;

   /*
    * Get the surfaces owned by keep_st except the surface
    * being lifted. Disconnect this surface from delete_state
    * and connect to keep_st. 
    * Check if the surface being lifted has a owner or not.
    * If so, disconnect the lifted surface from its owner and
    * connect it to keep_st.
    */

   EFgetobjids (&mthd_stat, &delete_st_GRid, &to_cmpnts, 
                &cmpnt_sf_GRids, &num_cmpnt_sf, OPP_EMSsubbs_class_id, 
                &lft_sf_GRid, 1);
   EMerr_hndlr (!(1&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

   OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                       &delete_st_GRid),
                      senderid = NULL_OBJID,
                      targetid = cmpnt_sf_GRids[0].objid,
                      targetos = cmpnt_sf_GRids[0].osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

   OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                         &keep_st_GRid, &owner_index),
                        senderid = NULL_OBJID,
                        targetid = cmpnt_sf_GRids[0].objid,
                        targetos = cmpnt_sf_GRids[0].osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

   OM_stat = om$get_channel_count (objid = lft_sf_GRid.objid,
                osnum = lft_sf_GRid.osnum, p_chanselect = &to_owners,
                count = &num_owners);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   if (num_owners)
   {
     OM_stat = om$get_objid_at_index (objid = lft_sf_GRid.objid,
                  osnum = lft_sf_GRid.osnum,
                  p_chanselect = &to_owners, index = 0, 
                  objidaddr = &lft_sf_owner.objid, 
                  osnumaddr = &lft_sf_owner.osnum);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

     OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                         &lft_sf_owner),
                      senderid = NULL_OBJID,
                      targetid = lft_sf_GRid.objid,
                      targetos = lft_sf_GRid.osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

     OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                         &keep_st_GRid, &owner_index),
                        senderid = NULL_OBJID,
                        targetid = lft_sf_GRid.objid,
                        targetos = lft_sf_GRid.osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  
   } /* if (num_owners) */

   /*
    * delete the delete-state.
    */

   OM_stat = om$send (msg = message GRgraphics.GRdelete ( &mthd_stat,
                       md_env),
                      senderid = NULL_OBJID,
                      targetid = delete_st_GRid.objid,
                      targetos = delete_st_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

   /*
    * For the keep-state-id,
    *
    * o In case of lift-w-draft, the surface being drafted is taken
    *   out and is replaced by its offset surface. In such a case,
    *   composite_ids will be delete_state_id. Replace it by NULL_OBJID
    *   such that after undo, the sf is by itself.
    * 
    * o If there are any edges with their common edges modified,
    *   which will be the case in all of the lift operations except in 
    *   lift-w-draft, update num_eds_wcm_md to 0.
    *
    * o The edges for which the lifted surfaces were constructed
    *   will have the common edges after the two states are merged.
    *   The edge ids and their common edges are currently stored in 
    *   kst_info->ed_mcm_ed_ids with ed1 and ed3 as edge id and the
    *   new common edge ids. Compress this array to edge id and 
    *   common edge ids without ed2 and ed4 and move this array to
    *   ed_cm-ed_ids.
    */

    if (kst_info->num_composites)
    {
      for (i = 0; i < kst_info->num_composites; i++)
        kst_info->composite_ids[i] = NULL_OBJID;
  
    } /* if (kst_info->num_composites) */

    if (kst_info->num_eds_wcm_md)
    {
      for (i = 0; i < kst_info->num_eds_wcm_md; i++)
      {
        if (kst_info->ed_mcm_ed_ids[4*i+2] != NULL_OBJID)
        {
          kst_info->ed_mcm_ed_ids[2*i] = kst_info->ed_mcm_ed_ids[4*i];
          kst_info->ed_mcm_ed_ids[2*i+1] = kst_info->ed_mcm_ed_ids[4*i+2];
          kst_info->num_eds_wcm_eds++;
        } /* if (kst_info->ed_mcm_ed_ids[4*i+2] != NULL_OBJID) */

      } /* for (i = 0; i < kst_info->num_eds_wcm_md; i++) */

    } /* if (kst_info->num_eds_wcm_md) */

    kst_info->ed_cm_ed_ids = kst_info->ed_mcm_ed_ids;
    kst_info->num_eds_wcm_md = 0;
    kst_info->ed_mcm_ed_ids = NULL;

    /*
     * post owner state's ssi.
     */

    OM_stat = om$send (msg = message EMSdpr.EMputSSI (&mthd_stat, 
                        ssi),
                       senderid = NULL_OBJID,
                       targetid = keep_st_GRid.objid,
                       targetos = keep_st_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

    /*
     * set dpr properties EMSIS_ACTIVE_PATH and EMSIS_ACTIVE_STATE
     * of the keep_state_id to true.
     */

    mask = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;
    action = TRUE;

    OM_stat = om$send (msg = message EMSdpr.EMsetprops (&mthd_stat,
                        &action, &mask),
                       senderid = NULL_OBJID,
                       targetid = keep_st_GRid.objid, 
                       targetos = keep_st_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

    /*
     * If the lifted surface is non-planar, the normal orientation
     * mechanism used in EFprp_sflft() may fail. Therefore, as a 
     * precaution, orient the normals again.
     */

    OM_stat = om$send (msg = message EMSsubbs.EMgetbsdef (&mthd_stat,
                        &lft_sf_def),
                       senderid = NULL_OBJID,
                       targetid = lft_sf_GRid.objid, 
                       targetos = lft_sf_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

    if (!lft_sf_def.planar)
    {
      OM_stat = om$send (msg = message EMSsolid.EMorient_yourself (
                          &mthd_stat, NULL, md_env),
                         senderid = NULL_OBJID,
                         targetid = keep_st_GRid.objid,
                         targetos = keep_st_GRid.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

    } /* if (!lft_sf_def.planar) */

wrapup:
   EMWRAPUP (*EFmsg, OM_stat,"In EFmerge_single_sf_lift_states");
   if (ssi) om$dealloc (ptr = ssi);
   if (cmpnt_sf_GRids) om$dealloc (ptr = cmpnt_sf_GRids);
   return;

}
end implementation EMSlift;
