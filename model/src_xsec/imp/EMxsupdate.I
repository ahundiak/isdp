/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsection;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"
#include "EMSobjmgrdef.h"
#include "EMSobjmgr.h"
#include "OMmacros.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

from EMSsfdpr     import EMadd;
from EMSsurface   import EMgetactiveid, EMget_mdsfs_info, 
                         EMmake_active_state;
from GRgraphics   import GRgetrang;
from EMSdpr       import EMputSSI;
from GRconnector  import GRdisconn, GRrigidconn;

/*
  HISTORY

         RC     11/21/89     Make myself as the active state before
                             updating my information.
         RC     09/02/88     Creation Date
*/

extern OMuword OPP_EMSxsec_st_class_id, OPP_EMSxsplane_class_id;

method EMupdate (
 IGRlong               *EMmsg;
 struct   GRmd_env     *xs_env;
 struct   GRvg_construct *construct_list)

{
 OM_S_CHANSELECT           xs_mdl_chan, notify_chan;
 struct    GRid            mdl_GRid, act_st_GRid, my_GRid, xsec_st_GRid,
                           *active_state = NULL;
 struct  GRmd_env          *mdl_env;
 struct  EMSsfs_md_info    sfs_md_info;
 struct  EMSxs_assoc_info  xs_assoc_info;
 struct  EMSxsreg_md_info  reg_md_info;
 union   EMSssi_table      ssi;
 struct  EMSxsssi_table    *my_info;
 struct  EMSfnmgr_info     fnmgr_info;

 GRrange                   mdl_range;

 IGRlong                   OM_stat, mthd_stat, rc, 
                           owner_inx = OM_K_MAXINT;
 IGRint                    i, num_added_sfs = 0, num_rmvd_sfs = 0, 
                           added_sf_arrsz = 0, rmvd_sf_arrsz = 0, stat,
                           num = 0, buf_size = 0, display_count = 0, 
                           invoke_count = 0;

 extern IGRint             EMdpb_get();
 IGRushort         add_options, act_options;
 IGRshort                  options;

 GRobjid                   *added_sf_ids = NULL, *rmvd_sf_ids = NULL,
                           *display_ids = NULL;
 OMuword                   my_classid;
 IGRboolean                world = TRUE, is_sf_active;

 IGRuchar          dpb_props;
 extern void               EFfnmgr_manipulation();

 /* ********************************************************** */

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /*
  * Check if update cross section flag is on. If not,
  * return with success.
  */

 stat = EMdpb_get (&rc, EMSdpb_props, &dpb_props);
 EMerr_hndlr (!(1&stat&rc), *EMmsg, EMS_E_Fail, wrapup);

 if (!(dpb_props & EMDPB_UPDATE_XSECTION)) return(OM_S_SUCCESS);

 /*
  * It may be possible I am the not active state in the tree. In
  * such cases make my self an active state.
  */

 act_options = EMS_DO_DISPLAY;

 OM_stat = om$send (msg = message EMSsurface.EMmake_active_state (
                     &mthd_stat, &act_options, xs_env, &active_state,
                     &num, &buf_size, &display_ids, &display_count,
                     &invoke_count),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

 /*
  * 1. Get the associated model GRid.
  * 2. Get the active state of the model.
  * 3. Get the modified surfaces between the current model GRid and 
  *    the active state GRid.
  * 4. Update the xsection.
  * 5. Save the state tree information.
  * 6. Save the association information.
  * 7. connect myself to the active state GRid.
  * 8. connect myself to the last state.
  */

 OM_stat = EMmake_chanselect (EMSxsection_to_model, &xs_mdl_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = om$get_objid_at_index (object = me, 
               p_chanselect = &xs_mdl_chan, index = 0,
               objidaddr = &mdl_GRid.objid, osnumaddr = &mdl_GRid.osnum);
 EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$send (msg = message EMSsurface.EMgetactiveid (&mthd_stat,
                     &act_st_GRid, NULL),
                    targetid = mdl_GRid.objid, targetos = mdl_GRid.osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

 /*
  * If the state of the model associated to me is the active state,
  * I am upto date and nothing needs to be done.
  */

 if (IF_EQ_OBJID(mdl_GRid.objid, act_st_GRid.objid))
 {
   ex$message(msgnumb = EMS_S_XsecUptodate);
   return (OM_S_SUCCESS);
 }

 ex$message(msgnumb = EMS_S_XsecUpdating);

 /*
  * Get the model md_env. For the time being, it is assumed
  * that model is in the same object space as that of the 
  * cross_section.
  */

 mdl_env = xs_env;

 /*
  * Get the surfaces' modification information about the model 
  * in reaching from the currently associated state to the
  * the active state of the model.
  */

 sfs_md_info.num_sfs_added = sfs_md_info.sfs_added_arrsz = 0;
 sfs_md_info.num_sfs_gm_md = sfs_md_info.sfs_gm_md_arrsz = 0;
 sfs_md_info.num_sfs_tp_md = sfs_md_info.sfs_tp_md_arrsz = 0;
 sfs_md_info.num_sfs_rmvd = sfs_md_info.sfs_rmvd_arrsz = 0;
 sfs_md_info.sfs_added = NULL;
 sfs_md_info.sfs_gm_md = NULL;
 sfs_md_info.sfs_tp_md = NULL;
 sfs_md_info.sfs_rmvd = NULL;

 options = NULL | EMS_O_NEW_SFS | EMS_O_GM_MD_SFS | EMS_O_TP_MD_SFS |
           EMS_O_RMVD_SFS;

 OM_stat = om$send (msg = message EMSsurface.EMget_mdsfs_info (&mthd_stat,
                     mdl_GRid, act_st_GRid, &sfs_md_info, mdl_env, 
                     options),
                    targetid = mdl_GRid.objid, 
                    targetos = mdl_GRid.osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

 /*
  * Perform the cross_section update.
  */

 xs_assoc_info.sf_list = xs_assoc_info.ed_list = NULL;
 xs_assoc_info.num_eds_sf = NULL;
 xs_assoc_info.sf_list_arrsz = xs_assoc_info.num_sfs = 0;
 xs_assoc_info.ed_list_arrsz = xs_assoc_info.num_eds = 0;

 reg_md_info.num_cmsf = reg_md_info.cmsf_arrsz = 0;
 reg_md_info.cmsf_ids = NULL;
 reg_md_info.num_sf_rmvd_cmsf = NULL;
 reg_md_info.num_rmvd_sfs = reg_md_info.rmvd_sf_arrsz = 0;
 reg_md_info.rmvd_sf_ids = NULL;
 reg_md_info.rmvd_sf_idx = NULL;
 reg_md_info.sf_ids = NULL;
 reg_md_info.num_reg_sf_in = reg_md_info.num_reg_sf_out = NULL;
 reg_md_info.reg_in_ids = reg_md_info.reg_out_ids = NULL;
 reg_md_info.num_sfs = reg_md_info.sf_arrsz = 0;
 reg_md_info.num_reg_in = reg_md_info.reg_in_arrsz = 0;
 reg_md_info.num_reg_out = reg_md_info.reg_out_arrsz = 0;

 /*
  * Get the model's range. This will be used to update the
  * cross_section plane's geometry if needed.
  */

 OM_stat = om$send (msg = message GRgraphics.GRgetrang (&mthd_stat,
                     &mdl_env->md_env.matrix_type, mdl_env->md_env.matrix,
                     &world, mdl_range),
                    targetid = act_st_GRid.objid,
                    targetos = act_st_GRid.osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 OM_stat = om$send (msg = message EMSxsection.EMperform_xsection_update (
                     &mthd_stat, construct_list, xs_env, mdl_env, 
                     &sfs_md_info, &reg_md_info, &xs_assoc_info, 
                     mdl_range, &my_GRid, &is_sf_active),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

 /*
  * 1. Construct a EMSxsec_st object. Associate it to model's active
  *    state and also connect it to me. If I am a EMSxsplane, it may
  *    be possible that I am no more active. In such a case, donot
  *    connect me the constructed EMSxsec_st object.
  * 2. Save the save state information.
  * 3. save cross_section association information.
  */

 OM_stat = om$construct (classid = OPP_EMSxsec_st_class_id,
                         p_objid = &xsec_st_GRid.objid);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 xsec_st_GRid.osnum = OM_Gw_current_OS;

 add_options = NULL;
 OM_stat = om$send (msg = message EMSsfdpr.EMadd (&mthd_stat,
                     &my_GRid, NULL, xs_env, &add_options), 
                    targetid = xsec_st_GRid.objid);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

 OM_stat = om$get_classid (object = me, p_classid = &my_classid);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 if (my_classid == OPP_EMSxsplane_class_id  && !is_sf_active)
 {
   OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                       &xsec_st_GRid),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

 } /* if (my_classid == OPP_EMSxsplane_class_id  && !is_sf_active) */

 /*
  * If I am of class EMSxsec_st, It may be possible that some of
  * xsection planes were made inactive. Need to perform intersections
  * among these inactive planes and modifications to the model.
  * And if there are any intersections, make these planes active and
  * add them to newly constructed EMSxsec_st object.
  */

 if (my_classid == OPP_EMSxsec_st_class_id)
 {
  OM_stat = om$send (msg = message EMSxsection.EMget_active_inactive_sfs
                      (&mthd_stat, &added_sf_ids, &num_added_sfs,
                       &added_sf_arrsz, &rmvd_sf_ids, &num_rmvd_sfs,
                       &rmvd_sf_arrsz),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  for (i = 0; i < num_rmvd_sfs; i++)
  {
    OM_stat = om$send (msg = message EMSxsection.EMperform_xsection_update
                        ( &mthd_stat, construct_list, xs_env, mdl_env, 
                          &sfs_md_info, &reg_md_info, &xs_assoc_info, 
                          mdl_range, &my_GRid, &is_sf_active),
                       targetid = rmvd_sf_ids[i]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    if (is_sf_active)
    {
     OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                         &xsec_st_GRid, &owner_inx),
                        targetid = rmvd_sf_ids[i]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    } /* if (is_sf_active) */
    
  } /* for (i = 0; i < num_rmvd_sfs; i++) */

 } /* if (my_classid == OPP_EMSxsec_st_class_id) */

 OM_stat = EMmake_chanselect (GRnotify_notification, &notify_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = om$send (msg = message Root.connect (xs_mdl_chan, OM_K_MAXINT,
                     act_st_GRid.objid, act_st_GRid.osnum, notify_chan,
                     OM_K_MAXINT), targetid = xsec_st_GRid.objid);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 /*
  * store save_state info.
  */

 my_info = &ssi.xs_info;

 my_info->num_composites = reg_md_info.num_cmsf;
 my_info->composite_ids = reg_md_info.cmsf_ids;  
 my_info->num_surfaces_out = reg_md_info.num_sf_rmvd_cmsf;   
 my_info->surface_out_ids = reg_md_info.rmvd_sf_ids;  
 my_info->composite_indices = reg_md_info.rmvd_sf_idx;  
 my_info->num_surfaces = reg_md_info.num_sfs;
 my_info->surface_ids = reg_md_info.sf_ids;
 my_info->num_regions_in = reg_md_info.num_reg_sf_in;
 my_info->region_in_ids = reg_md_info.reg_in_ids;
 my_info->num_regions_out = reg_md_info.num_reg_sf_out;
 my_info->region_out_ids = reg_md_info.reg_out_ids;
 

 OM_stat = om$send (msg = message EMSdpr.EMputSSI (&mthd_stat,
                     &ssi),
                    targetid = xsec_st_GRid.objid);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * save cross_section model_surface -> xs_edge association info.
  */

 fnmgr_info.fans = xs_assoc_info.sf_list;
 fnmgr_info.tips = xs_assoc_info.ed_list;
 fnmgr_info.tips_p_fan = xs_assoc_info.num_eds_sf;
 fnmgr_info.num_fans = xs_assoc_info.num_sfs;
 fnmgr_info.num_tips = xs_assoc_info.num_eds;
 fnmgr_info.fans_arrsz = xs_assoc_info.sf_list_arrsz;
 fnmgr_info.tips_arrsz = xs_assoc_info.ed_list_arrsz;
 fnmgr_info.tips_p_fan_arrsz = xs_assoc_info.sf_list_arrsz;

 EFfnmgr_manipulation (&rc, OM_Gw_current_OS, EMSlabel_xsection,
                       EMSFM_MANIP_PUT, EMSFM_KEY_FAN, &fnmgr_info, NULL);
 EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
                     
 /*
  * Update common edge connections.
  */

 OM_stat = om$send (msg = message EMSxsection.EMconnect_edges (&mthd_stat,
                     xs_env),
                    targetid = xsec_st_GRid.objid);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

 wrapup:

 if (sfs_md_info.sfs_added) om$dealloc (ptr = sfs_md_info.sfs_added);
 if (sfs_md_info.sfs_gm_md) om$dealloc (ptr = sfs_md_info.sfs_gm_md);
 if (sfs_md_info.sfs_tp_md) om$dealloc (ptr = sfs_md_info.sfs_tp_md);
 if (sfs_md_info.sfs_rmvd) om$dealloc (ptr = sfs_md_info.sfs_rmvd);
 
 if (xs_assoc_info.sf_list) om$dealloc (ptr = xs_assoc_info.sf_list);
 if (xs_assoc_info.ed_list) om$dealloc (ptr = xs_assoc_info.ed_list);
 if (xs_assoc_info.num_eds_sf) om$dealloc (ptr =xs_assoc_info.num_eds_sf);

 if (reg_md_info.sf_ids) om$dealloc (ptr = reg_md_info.sf_ids);
 if (reg_md_info.num_reg_sf_in) om$dealloc(ptr=reg_md_info.num_reg_sf_in);
 if (reg_md_info.num_reg_sf_out) 
     om$dealloc( ptr = reg_md_info.num_reg_sf_out);
 if (reg_md_info.reg_in_ids) om$dealloc (ptr = reg_md_info.num_reg_sf_out);
 if (reg_md_info.reg_out_ids) 
     om$dealloc (ptr = reg_md_info.num_reg_sf_out);

 if (added_sf_ids) om$dealloc (ptr = added_sf_ids);
 if (rmvd_sf_ids) om$dealloc (ptr = rmvd_sf_ids);

 EMWRAPUP (OM_stat, *EMmsg, "In EMSxsection.EMupdate");
 return (OM_stat);
}

end implementation EMSxsection;
