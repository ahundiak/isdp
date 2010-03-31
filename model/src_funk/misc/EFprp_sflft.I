/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*

  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "EMSconstruct.h"
#include "EMSopt.h"
#include "bssfarrevn.h"
#include "bsdotp.h"

from   GRowner       import GRget_number_components;
from   EMSboundary   import EMtpcopy;
from   EMSloopset    import EMmakeFRT;
from   EMSdpr        import EMputSSI;

extern OMuword OPP_EMSsldlift_class_id;

void  EFprepare_single_sf_lift (
   EFmsg,
   sf_GRid,
   md_env,
   construct_list,
   active_state_GRid,
   lift_vec)

 IGRlong                *EFmsg;
 struct  GRid           sf_GRid, *active_state_GRid;
 struct  GRmd_env       *md_env;
 struct  GRvg_construct *construct_list;
 IGRvector              lift_vec;
 
 {
  struct   GRsymbology         symbology;
  struct   GRid                sl_GRid;
  struct   IGRbsp_surface      *sf_geom;
  union    EMSssi_table        ssi_table;
  struct   EMSlftssi_table  *my_info;
  OM_S_CHANSELECT              sf_ls_chan, ls_sf_chan;
  OM_S_OBJECT_LINKAGE          ls_list;
  enum       GRdpmode          DisplayMode;
  IGRdouble	               u, v, dot_p;
  IGRvector	               sf_nrml;
  IGRpoint	               sf_pt;
  IGRlong                      OM_stat, mthd_stat, owner_index = 0, rc;
  IGRint                       count;
  GRobjid                      cp_sf_id, cp_ls_id;
  IGRshort                     pos_orient, flag, props;

OM_stat = OM_S_SUCCESS;
*EFmsg = EMS_S_Success;
sf_geom = NULL;

  /*
   * If it is a single sf lift,
   * o Copy the surface without its loopset.
   * o Copy sf's loopset with connecting the edges to their
   *   copies along common edge channel.
   * o Make a FRT for the copied sf.
   * o Construct EMSgensolid object and connect the active_state_state
   *   and the copied sf to it.
   * o Orient the normals such that after lifting the sf,
   *   the sfs normals are aligned.
   */

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  /*
   * Align the normal of the surface.  This logic works
   * well for planes but will not work in the general case.
   */

  OM_stat = om$send( msg = message GRvg.GRgenabsg( &mthd_stat,
                      &md_env->md_env.matrix_type,
                      md_env->md_env.matrix, (IGRchar **) &sf_geom),
                     senderid = NULL_OBJID,
                     targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  u = 0.48;		/* Try and avoid a knot line */
  v = 0.37;		/* Try and avoid a knot line */
  
  BSsfarrevn(&rc, sf_geom, 1, &u, 1, &v, sf_pt, sf_nrml);
  EMerr_hndlr(rc != 0,*EFmsg,EMS_E_BSerror,wrapup);

  dot_p = BSdotp(&rc, sf_nrml, lift_vec);
  
  if (dot_p >= 0.0) pos_orient = FALSE;
  else pos_orient = TRUE;

  OM_stat = om$send( msg = message EMSsubbs.EMalgnnrml( &mthd_stat,
                      EMS_SET_POS_ORIENT, &pos_orient, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  OM_stat = om$send( mode = OM_e_wrt_message,
                      msg = message GRgraphics.GRcopy ( &mthd_stat,
                       md_env, md_env, &cp_sf_id),
                     senderid = NULL_OBJID,
                     targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  /*
   * Change the symbology of the copied surface to current symb.
   */

  symbology.level = construct_list->level;
  symbology.display_attr = *(construct_list->display);

  OM_stat = om$send( msg = message GRvg.GRputsymb( &mthd_stat,
                      &symbology),
                     senderid = NULL_OBJID,
                     targetid = cp_sf_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  /*
   * Copy the topology of the surface with the option to connect 
   * its edges to the corresponding edges of the copied surface.
   */

  OM_stat = om$get_channel_objects (osnum = sf_GRid.osnum,
               objid = sf_GRid.objid, p_chanselect = &sf_ls_chan,
               list = &ls_list, size = 1, count = (OMuint *)&count);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send( msg = message EMSboundary.EMtpcopy (&mthd_stat,
                      NULL, sf_GRid.osnum, sf_GRid.osnum, 
                      EMS_COPY_ONCOMMON, &cp_ls_id),
                     senderid = NULL_OBJID,
                     targetid = ls_list.S_objid, targetos =ls_list.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  /*
   * Align the normal of the copied surface to be the
   * opposite of the original surface
   */

  OM_stat = om$send( msg = message EMSsubbs.EMrevorient( &mthd_stat),
                     senderid = NULL_OBJID, 
                     targetid = cp_sf_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  /*
   * Connect the newly created loopset to the copied surface
   */

  OM_stat = om$send( msg = message Root.connect( sf_ls_chan, NULL,
                      cp_ls_id, sf_GRid.osnum, ls_sf_chan, NULL),
                     senderid = NULL_OBJID,
                     targetid = cp_sf_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  /*
   * Make sure the copied surface has it's FRT fixed
   */

  OM_stat = om$send( msg = message EMSloopset.EMmakeFRT( &mthd_stat,
                      cp_sf_id),
                     senderid = NULL_OBJID,
                     targetid = cp_ls_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  /*
   * update the class_attributes  of the copied surface
   */

  OM_stat = om$send( msg = message GRvg.GRputattr( &mthd_stat,
                      construct_list->class_attr),
                     senderid = NULL_OBJID,
                     targetid = cp_sf_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  /*
   * Display the newly created surface
   */

    DisplayMode = GRbd;
    OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                        &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &DisplayMode,
                        &md_env->md_id),
                       senderid = NULL_OBJID,
                       targetid = cp_sf_id, targetos = sf_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  /*
   * Construct the EMSsldlift class object and connect the active_state
   * and the copied surface to it.
   */

  flag = 1;
  props = construct_list->properties | GRIS_NEW;

  OM_stat = om$construct( classid = OPP_EMSsldlift_class_id,
                          msg = message GRgraphics.GRchgprops( &mthd_stat,
                           &flag, &props),
                          p_objid = &sl_GRid.objid, 
                          osnum = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  sl_GRid.osnum = sf_GRid.osnum;

  OM_stat = om$send( msg = message GRconnector.GRrigidconn( &mthd_stat,
                      &sl_GRid, &owner_index),
                     senderid = NULL_OBJID,
                     targetid = active_state_GRid->objid, 
                     targetos = active_state_GRid->osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  OM_stat = om$send( msg = message GRconnector.GRrigidconn( &mthd_stat,
                      &sl_GRid, &owner_index),
                     senderid = NULL_OBJID,
                     targetid = cp_sf_id, targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  active_state_GRid->objid = sl_GRid.objid;

  /*
   * post ssi table.
   */

 my_info = &ssi_table.lft_info;
 my_info->num_composites = 0;
 my_info->composite_ids = NULL;
 my_info->num_surfaces_out = 0;
 my_info->surface_out_ids = NULL;
 my_info->composite_indices = NULL;
 my_info->num_sf_lifted = 1;
 my_info->sf_lifted_ids = &sf_GRid.objid;
 my_info->num_sf_affected = 0;
 my_info->sf_affctd_ids = NULL;
 my_info->num_regions_in = 0;
 my_info->region_in_ids = NULL;
 my_info->num_regions_out = 0;
 my_info->region_out_ids = NULL;
 my_info->num_eds_rplcd = 0;
 my_info->ed_rplcd_ids = NULL;
 my_info->num_eds_in = 0;
 my_info->ed_in_ids = NULL;
 my_info->num_eds_wcm_md = 0;
 my_info->ed_mcm_ed_ids = NULL;
 my_info->num_ed_wmv_cm = 0;
 my_info->ed_ced_ids = NULL;
 my_info->num_eds_wcm_eds = 0;
 my_info->ed_cm_ed_ids = NULL;

 OM_stat = om$send (msg = message EMSdpr.EMputSSI( &mthd_stat, 
                     &ssi_table), 
                    senderid = NULL_OBJID,
                    targetid = active_state_GRid->objid,
                    targetos = active_state_GRid->osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);


wrapup:
 EMWRAPUP (*EFmsg, OM_stat, "In EFprepare_single_sf_lift");

 return;

} /*  EFprepare_single_sf_lift */

end implementation EMSsubbs;
