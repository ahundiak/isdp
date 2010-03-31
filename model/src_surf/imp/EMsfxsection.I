/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include  "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
# include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

/*

  HISTORY
         
    RC       09/11/88      Creation Date
    Inasu    June 8, 90    Fix for TR 90n0724
    Jack     31-May-91     After the call to GRconstruct, added a call
                           to EMdelete_boundary to remove the loopset
                           associated with the profile since one will
                           be created later for it.  This is related
                           to 2.0.1 Horizon Loops. 
    NP	     08/24/92	   "GRmdenv_info" was being passed into the 
			   "EMdelete_boundary" message instead of "GRmd_env".
			   Modified for ANSI compliance. Also added typecasts.

*/

extern OMuword  OPP_EMSxsplane_class_id, OPP_GRcompcurve_class_id,
                OPP_EMSxscompsf_class_id;

from EMSxsection import EMperform_xsection, EMxsec_int_xform,
                        EMattach_vsgd, EMconnect_edges;
from EMSxsplane  import EMput_alignment_info;

method EMcross_section2(
       IGRlong                   *EMmsg;
       struct GRvg_construct     *construct_list;
       struct GRlc_info          *xs_pf_info;
       IGRvector                 win_zvec;
       struct GRmd_env           *mdl_env;
       struct GRid               *cs_GRid;
       struct GRid               *vd_wn_GRid;
       IGRboolean                want_status_messages)
{
 OM_S_CHANSELECT             notify_chan, to_model_chan, to_cmpnt_chan;
 struct     EMSxs_assoc_info xs_assoc_info;
 struct     IGRbsp_surface   pl_gm;
 struct     GRid             my_GRid;
 struct     EMSfnmgr_info    fnmgr_info;
 struct     EMSxs_pl_info    *xs_pl_info = NULL;
 struct     IGRbsp_curve     *cmpnt_gm = NULL;
 struct     GRid             xs_pf_GRid, cmpnt_GRid, tmp_GRid;

 GRrange                     my_range;
 IGRpoint                    poles[4];

 IGRdouble                   u_knots[4], v_knots[4], dotp, dotp_tol, 
                             first_sg_vec[3], cur_sg_vec[3], pi,
                             rot_mat[4][4], rot_axis[3], rot_angles[3];

 extern IGRdouble            BSdotp();

 IGRlong                     OM_stat, mthd_stat, rc, cmpnt_size,
                             owner_index = OM_K_MAXINT, num_pts = 2;

 IGRint                      cmpnt_inx, cmpnt_buf_size = 0, sg_inx,
                             num_xs_pls = 0, xs_pl_inx, i, INITIAL_SIZE,
                             BUF_INC, xs_pls_arrsz = 0;

 GRobjid                     newobjid, xp_id;

 IGRshort                    mat_type;

 OMuword                     xs_pf_classid;

 GRspacenum                  dum_os;

 OMuint                      num_cmpnts;

 IGRboolean                  world = TRUE, xs_pf_cm_cv,
                             status, sg_good, pl_mdl_int;

 extern IGRboolean           BScrossp(), MAang2vc(), MAtypemx(),
                             MAoptsxform(), MAidmx();

 IGRchar                     *char_ptr = NULL;

 extern void                 EFfnmgr_manipulation(),
                             EFconstruct_xs_plane ();

 /* ************************************************************ */

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 pi = 22./7.;

 xs_assoc_info.sf_list = xs_assoc_info.ed_list = NULL;
 xs_assoc_info.num_eds_sf = NULL;
 xs_assoc_info.sf_list_arrsz = xs_assoc_info.num_sfs = 0;
 xs_assoc_info.ed_list_arrsz = xs_assoc_info.num_eds = 0;

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 /*
  * Construct the cross_section surface if one does not
  * exist. For time being, it is expecting only profile object.
  */

 ex$message ( msgnumb = EMS_S_ConstructingCrossSectionPlane);

 OM_stat = om$send(msg = message GRgraphics.GRgetrang (&mthd_stat,
                    &mdl_env->md_env.matrix_type, mdl_env->md_env.matrix,
                    &world, my_range), 
                   targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * Check if the cross_section profile is a composite curve
  * or not.
  */

 xs_pf_GRid = xs_pf_info->located_obj;

 OM_stat = om$get_classid (osnum = xs_pf_GRid.osnum,
                           objid = xs_pf_GRid.objid,
                           p_classid = &xs_pf_classid);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = om$is_ancestry_valid (subclassid = xs_pf_classid,
              superclassid = OPP_GRcompcurve_class_id);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 if (OM_stat == OM_S_SUCCESS)
 {
   OM_stat = om$get_channel_count (osnum = xs_pf_GRid.osnum,
                objid = xs_pf_GRid.objid, p_chanselect = &to_cmpnt_chan,
                count = &num_cmpnts);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   xs_pf_cm_cv = TRUE;

 } /* if (OM_stat == OM_S_SUCCESS) */
 else
 {
  num_cmpnts = 1;
  xs_pf_cm_cv = FALSE;
 }

/* status = BSEXTRACTPAR (&rc, BSVALORTHOVEC, dotp_tol); ## COMMENTED OUT - Ashok */
 status = BSEXTRACTPAR (&rc, BSTOLORTHOVEC, dotp_tol);

 for (cmpnt_inx = 0; cmpnt_inx < num_cmpnts; cmpnt_inx++)
 {
   if (xs_pf_cm_cv)
   {
     OM_stat = om$get_objid_at_index (osnum = xs_pf_GRid.osnum,
                 objid = xs_pf_GRid.objid, p_chanselect = &to_cmpnt_chan,
                 index = cmpnt_inx, objidaddr = &cmpnt_GRid.objid,
                 osnumaddr = &cmpnt_GRid.osnum);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   } /* if (xs_pf_cm_cv) */
   else
    cmpnt_GRid = xs_pf_GRid;

   OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                       &xs_pf_info->module_info.md_env.matrix_type,
                       xs_pf_info->module_info.md_env.matrix,
                       &cmpnt_size),
                      targetid = cmpnt_GRid.objid,
                      targetos = cmpnt_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   if (!cmpnt_buf_size)
    char_ptr = om$malloc (size = cmpnt_size);
   else if (cmpnt_size > cmpnt_buf_size)
    char_ptr = om$realloc (ptr = char_ptr, size = cmpnt_size);

   if (cmpnt_size > cmpnt_buf_size)
      cmpnt_buf_size = cmpnt_size;
   cmpnt_gm = (struct IGRbsp_curve *) char_ptr;

   OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat,
                       &xs_pf_info->module_info.md_env.matrix_type,
                       xs_pf_info->module_info.md_env.matrix,
                       char_ptr),
                      targetid = cmpnt_GRid.objid, 
                      targetos = cmpnt_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   /*
    * The component will be used for cross_section plane only
    * if it is of order 2 and is not rational.
    */

   if (cmpnt_gm->order == 2 && !cmpnt_gm->rational)
   {
     for (sg_inx = 0; sg_inx < cmpnt_gm->num_poles-1; sg_inx++)
     {
      /*
       * Check if this segment is normal to the last segment
       * picked, discard this segment.
       */

      sg_good = TRUE;
      for (i = 0; i < 3; i++)
        cur_sg_vec[i] = cmpnt_gm->poles[3*sg_inx+i+3] -
                      cmpnt_gm->poles[3*sg_inx+i];

      if (num_xs_pls)
      {
         dotp = BSdotp (&rc, first_sg_vec, cur_sg_vec);
         EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         if (dotp <= dotp_tol) sg_good = FALSE;

      } /* if (num_xs_pls) */
      else
       OM_BLOCK_MOVE (cur_sg_vec, first_sg_vec, sizeof(IGRpoint));
      
      /*
       * If the segment is valid for cross_section plane, load
       * the following information:
       *
       * o segment points.
       * o plane normal.
       * o Translation vec to align the cross_planes to align with
       *   the first plane.
       */

      if (sg_good)
      {
        if (num_xs_pls+1 > xs_pls_arrsz)
        {
         INITIAL_SIZE = BUF_INC = 6;
         EFmemory_allocation (&rc, (IGRchar **)&xs_pl_info,
                             num_xs_pls+1, &xs_pls_arrsz,
                             sizeof(struct EMSxs_pl_info), INITIAL_SIZE,
                             BUF_INC);
         EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (num_xs_pls+1 > xs_pls_arrsz) */

        OM_BLOCK_MOVE (&cmpnt_gm->poles[3*sg_inx], 
           xs_pl_info[num_xs_pls].seg_pts, sizeof(IGRdouble) * 6);


        status = BScrossp (&rc, cur_sg_vec, win_zvec, 
                           xs_pl_info[num_xs_pls].pl_nrml);
        EMerr_hndlr(!status || rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

        num_xs_pls++;

      } /* if (sg_good) */

     } /* for (sg_inx = 0; sg_inx < cmpnt_gm->num_poles-1; sg_inx++) */

   } /* if (cmpnt_gm->order == 2 && !cmpnt_gm->rational) */
    
 } /* for (cmpnt_inx = 0; cmpnt_inx < num_cmpnts; cmpnt_inx++) */
  
 /*
  * If number of segments is more than 1, construct a EMSxscompsf
  * object and connect all of the cross_planes to it.
  */

 cs_GRid->osnum = construct_list->env_info->md_id.osnum;

 if (num_xs_pls > 1)
 {
   OM_stat = om$construct (classid = OPP_EMSxscompsf_class_id,
                           osnum = cs_GRid->osnum,
                           p_objid = &cs_GRid->objid);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
   
 } /* if (num_xs_pls > 1) */

 /*
  * Now all of the information regarding the planes is available.
  * Construct these planes such that the width is governed by
  * the segment length and hight is by the range of the model.
  * Keep these planes in its orientation. They will be aligned
  * after performing the cross_section.
  */

 pl_gm.poles = (IGRdouble *)poles;
 pl_gm.u_knots = u_knots;
 pl_gm.v_knots = v_knots; 

 for (xs_pl_inx = 0; xs_pl_inx < num_xs_pls; xs_pl_inx++)
 {
   EFconstruct_xs_plane (&rc, my_range, xs_pl_info[xs_pl_inx].seg_pts,
                         xs_pl_info[xs_pl_inx].pl_nrml, win_zvec,
                         1.05, &pl_gm, &pl_mdl_int);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

   construct_list->geometry = (IGRchar *) &pl_gm;

   OM_stat = om$construct (classid = OPP_EMSxsplane_class_id,
                osnum = cs_GRid->osnum,
                p_objid = num_xs_pls > 1 ? &xp_id : &cs_GRid->objid,
                msg = message GRgraphics.GRconstruct (construct_list) );
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);


   tmp_GRid.objid = num_xs_pls > 1 ? xp_id : cs_GRid->objid;
   tmp_GRid.osnum = cs_GRid->osnum; 

   /* if the profile has a loopset at this point we want to delete it
      since we will create a new one later.
    */   
   OM_stat = om$send(msg = message EMSsurface.EMdelete_boundary(
                                         &mthd_stat,
                                         &xs_pf_info->module_info,
                                         &xs_pf_info->module_info.md_id,
                                         &tmp_GRid),
                 targetid =  tmp_GRid.objid,
                 targetos =  tmp_GRid.osnum);

   /*
    * If there are more than one cross_section planes,
    * connect them to the EMSxscompsf object constructed
    * above.
    */

   if (num_xs_pls > 1)
   {

     OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                         cs_GRid, &owner_index),
                        targetid = xp_id, targetos = cs_GRid->osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   } /* if (num_xs_pls > 1) */

 } /* for (xs_pl_inx = 0; xs_pl_inx < num_xs_pls; xs_pl_inx++) */

  /* if no cross section planes are created, program exits with no
     further processing                                            */
  if(!num_xs_pls)
  {
    ex$message ( msgnumb = EMS_S_ProfileDoesNotHaveLinearComp);
    *EMmsg = EMS_I_NoxsectionPlane;
    goto wrapup;
  }
 /*
  * Connect view specific graphics data objects to the above
  * constructed cross section planes. These view specific gradatas
  * will represent viewing direction window.
  */

 OM_stat = om$send (msg = message EMSxsection.EMattach_vsgd (
                     &mthd_stat, vd_wn_GRid),
                    targetid = cs_GRid->objid,
                    targetos = cs_GRid->osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 /*
  * perform the cross section between the model and the cross_section
  * plane.
  */

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;

OM_stat = om$send (msg = message EMSxsection.EMperform_xsection ( 
                    &mthd_stat, construct_list, 
                    construct_list->env_info, &my_GRid, mdl_env, 
                    &xs_assoc_info),
                   targetid = cs_GRid->objid, targetos = cs_GRid->osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

/*
 * Copy and Display the cross_section in its non_aligned state. 
 * This is just for debugging purposes.
 */

#if DEBUG
 {
   enum GRdpmode DisplayMode;

   DisplayMode = GRbd;
   OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                       &construct_list->env_info->md_env.matrix_type,
                       construct_list->env_info->md_env.matrix, 
                       &DisplayMode,
                       &construct_list->env_info->md_id),
                      targetid = cs_GRid->objid, 
                      targetos = cs_GRid->osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

/*

  OM_stat = om$send (msg = message GRgraphics.GRcopy (&mthd_stat,
                    construct_list->env_info, construct_list->env_info,
                    &newobjid),
                   targetid = cs_GRid->objid, targetos = cs_GRid->osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

*/

}

#endif

/*
 * Align the cross_section planes with the first plane and
 * post its geomtery.
 */

ex$message ( msgnumb = EMS_S_AligningCrossSectionPlanes );

for (xs_pl_inx = 0; xs_pl_inx < num_xs_pls; xs_pl_inx++)
{
  if (!xs_pl_inx)
  {
    for (i = 0; i < 3; i++)
      xs_pl_info[0].trans_vec[i] = 0;
    xs_pl_info[0].rot_ang = 0;
    xp_id = cs_GRid->objid;
  }
  else
  {
    OM_stat = om$get_objid_at_index (osnum = cs_GRid->osnum,
                 objid = cs_GRid->objid, p_chanselect = &to_cmpnt_chan,
                 index = xs_pl_inx,
                 objidaddr = &xp_id, osnumaddr = &dum_os);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    status = MAang2vc (&rc, xs_pl_info[xs_pl_inx].pl_nrml,
                       xs_pl_info[0].pl_nrml, rot_angles);
    EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

    xs_pl_info[xs_pl_inx].rot_ang = rot_angles[0];

    if (xs_pl_info[xs_pl_inx].rot_ang != 0.)
    {
      status = BScrossp (&rc, xs_pl_info[xs_pl_inx].pl_nrml,
                         xs_pl_info[0].pl_nrml, rot_axis);
      EMerr_hndlr(!status || rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      if (xs_pl_info[xs_pl_inx].rot_ang > pi )
        xs_pl_info[xs_pl_inx].rot_ang = 
                     2 * pi - xs_pl_info[xs_pl_inx].rot_ang;
   
      MAgrotmx (&rc, rot_axis, xs_pl_info[xs_pl_inx].seg_pts, 
                &xs_pl_info[xs_pl_inx].rot_ang, rot_mat);
      EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

    } /* if (xs_pl_info[xs_pl_inx].rot_ang != 0.) */
    else
    {
      status = MAidmx (&rc, rot_mat);
      
    } /* else for if (xs_pl_info[xs_pl_inx].rot_ang != 0.) */

    /*
     * o Get the translation vector. This is the vector used to
     *   bring the parallel planes aligned. The planes have
     *   been made parallel by rotation.
     * o Add the translation vector to the rotation matrix.
     */

    for (i = 0; i < 3; i++)
    {
      xs_pl_info[xs_pl_inx].trans_vec[i] = 
              xs_pl_info[xs_pl_inx-1].seg_pts[3+i] -
              xs_pl_info[xs_pl_inx].seg_pts[i];

      rot_mat[i][3] += xs_pl_info[xs_pl_inx].trans_vec[i];
    }

    /*
     * o Transform the plane
     * o Transform the xs_plane's profile segment.
     */

    status = MAtypemx (&rc, rot_mat, &mat_type);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = message EMSxsection.EMxsec_int_xform (
                        &mthd_stat, construct_list->env_info, 
                        &mat_type, (IGRdouble *)rot_mat, NULL, 
                        &newobjid, TRUE),
                      targetid = xp_id, targetos = cs_GRid->osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
                        
    status = MAoptsxform (&rc, &num_pts, &mat_type, rot_mat, 
                          xs_pl_info[xs_pl_inx].seg_pts,
                          xs_pl_info[xs_pl_inx].seg_pts);
    EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

    /*
     * Save the trans_vec and rot_ang to bring the aligned plane
     * to its offset orientation.
     */

    for (i = 0; i < 3; i++)
     xs_pl_info[xs_pl_inx].trans_vec[i] = 
                                   -xs_pl_info[xs_pl_inx].trans_vec[i];

     dotp = BSdotp (&rc, rot_axis, win_zvec);
     EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     
     if (dotp > 0.)
       xs_pl_info[xs_pl_inx].rot_ang = -xs_pl_info[xs_pl_inx].rot_ang;

  } /* else for if (!xs_pl_inx) */

  OM_stat = om$send (msg = message EMSxsplane.EMput_alignment_info (
                      &mthd_stat,
                      EMS_FMT_TRANS_VEC_ROT_ANGLE,
                      xs_pl_info[xs_pl_inx].trans_vec,
                      xs_pl_info[xs_pl_inx].rot_ang, NULL),
                     targetid = xp_id, targetos = cs_GRid->osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
                        
} /* for (xs_pl_inx = 0; xs_pl_inx < num_xs_pls; xs_pl_inx++) */

/*
 * Save the cross section association data.
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
 * Associate the cross section to the model.
 */

OM_stat = EMmake_chanselect (GRnotify_notification, &notify_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = EMmake_chanselect (EMSxsection_to_model, &to_model_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = om$send (msg = message Root.connect (notify_chan, NULL,
                cs_GRid->objid, cs_GRid->osnum, to_model_chan,
                OM_K_MAXINT), targetid = my_id);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

/*
 * Peform common edge connections.
 */

OM_stat = om$send (msg = message EMSxsection.EMconnect_edges (&mthd_stat,
                    construct_list->env_info),
                   targetid = cs_GRid->objid,
                   targetos = cs_GRid->osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSsurface.EMcross_section2");
  if (xs_assoc_info.sf_list) om$dealloc (ptr = xs_assoc_info.sf_list);
  if (xs_assoc_info.ed_list) om$dealloc (ptr = xs_assoc_info.ed_list);
  if (xs_assoc_info.num_eds_sf) 
     om$dealloc (ptr = xs_assoc_info.num_eds_sf);
  if (char_ptr) om$dealloc (ptr = char_ptr);
  if (xs_pl_info) om$dealloc (ptr = xs_pl_info);

  return(OM_stat);

}

end implementation EMSsurface;

