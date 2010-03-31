/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

#include "EMS.h"
#include "emssfdef.h"		/* matrix classification codes */
#include "emsedgedef.h"		/* Edge types */
#include "igrtypedef.h"		/* for gocmacros.h  */
#include "godef.h"		/* for gocmacros.h  */
#include "gocmacros.h"		/* GRgetabsg macro  */
#include "emsdef.h"		/* MAXINT */
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"
#include "EMSopt.h"
#include "EMSchatch.h"
#include "bsdistptpt.h"

from EMSboundary import EMtree_traverse;
from EMSedge     import EMset_type;
from EMSgradata  import EMget_class_info;
from EMSchatch   import EMgetdef, EMputdef;

extern OMuword OPP_EMSbsedge_class_id;
extern OMuword OPP_EMSchatch_class_id;

/*
  History
          RC     01/18/89         Creation Date
          NP     08/27/92         Modified for ANSI compliance.
	  Sudha  07/06/93	  Modified for BSprototypes ansification

*/

void  EFplane_xform_support (EFmsg, trmx_type, pl_id, cur_os, sf_ogm, 
                               sf_ngm)
 IGRlong                 *EFmsg;
 IGRlong                 trmx_type;
 struct  IGRbsp_surface  *sf_ogm, *sf_ngm;
 GRobjid                 pl_id;
 GRspacenum              cur_os;

{
  OM_S_OBJECT_LINKAGE     ls_list, *gd_list;
  OM_S_CHANSELECT         sf_ls_chan, sf_gd_chan;
  IGRlong                 OM_stat;
  IGRint                  inx, i;
  IGRuint                 count, num_gds;
  OMuword                 class_id;
  IGRboolean              ch_exists = FALSE;

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  gd_list = NULL;

  if (trmx_type == EMSnonuniformTransformation)
  {
    OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);    
    
    OM_stat = om$get_channel_objects (osnum = cur_os,
                 objid = pl_id, p_chanselect = &sf_ls_chan,
                 list = &ls_list, size = 1, count = &count);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    if (count)
    {
     IGRuchar   free_form_curve;

     class_id = OPP_EMSbsedge_class_id;
     free_form_curve = EMfreeform_curve;

     OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(
                        EFmsg,
                        message EMSedge.EMset_type( EFmsg,
                                                    free_form_curve),
                        MAXINT, 1, &class_id, TRUE,	NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = ls_list.S_objid, 
                       targetos = ls_list.osnum);
     EMerr_hndlr (!(1 & OM_stat & *EFmsg),*EFmsg,EMS_E_Fail, wrapup);

    } /* if (count) */

  } /* if (trmx_type == EMSnonuniformTransformation) */

   /*
    * Determine if a cross hatch table is present
    */

   OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &sf_gd_chan);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

   OM_stat = om$get_channel_count (objid = pl_id, osnum = cur_os,
                p_chanselect = &sf_gd_chan, count = &num_gds);
   EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

   if (num_gds)
   {
     OM_S_OBJECT_LINKAGE     *gd_list;

     gd_list = NULL;

     gd_list = (OM_S_OBJECT_LINKAGE *) om$malloc (size = num_gds *
                sizeof(OM_S_OBJECT_LINKAGE));
     EMerr_hndlr (!gd_list, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

     OM_stat = om$get_channel_objects (objid = pl_id, osnum = cur_os,
                  p_chanselect = &sf_gd_chan, list = gd_list, 
                  size = num_gds, count = &count);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

     for (inx = 0; inx < num_gds; inx++)
     {
       OM_stat = om$send( msg = message EMSgradata.EMget_class_info(
                           EFmsg, &class_id, NULL),
                          senderid = NULL_OBJID,
                          targetid = gd_list[inx].S_objid, 
                          targetos = gd_list[inx].osnum);
       if (OM_stat == OM_I_STOP_SENDING) 
       {
         if (class_id == OPP_EMSchatch_class_id) ch_exists = TRUE;
         OM_stat = OM_S_SUCCESS;
         break;
       }
       if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
       EMerr_hndlr (!(1&OM_stat& *EFmsg), *EFmsg, EMS_E_Fail, wrapup);

     } /* for (inx = 0; inx < num_gds; inx++) */

     if (ch_exists)
     {
      struct    EMSxh_info      xh_info;
      struct	IGRbsp_surface  old_xhsf;
      IGRdouble                 poles[12], u_knots[4], v_knots[4], 
                                uv_pts[6], cht_tol, uv_tol, 
                                osf_uv_pts[8], nsf_xyz_pts[12], ou_len, 
                                ov_len, nu_len, nv_len, xform_factor;
      IGRlong                   rc;
      extern	IGRlong         EFsspbtol_by_geom();
      IGRint                    i;
      IGRboolean                status, data_within_range, data_on_sf;
      extern IGRboolean         EFget_xh_sf_geom(), 
                                EFmap_xyz_to_uv_for_planes(),
                                EFmap_uv_to_xyz_for_planes();

      old_xhsf.poles = poles;
      old_xhsf.u_knots = u_knots;
      old_xhsf.v_knots = v_knots;
      xh_info.u_sgrp_info = xh_info.v_sgrp_info = NULL;

      /*
       * After uniform/non_uniform transformation,
       * o Cross_hatch angle should remain unchanged.
       * o Spacing should be scaled appropriately.
       */

      OM_stat = om$send (msg = message EMSchatch.EMgetdef (EFmsg, 
                          &xh_info),
                         senderid = NULL_OBJID,
                         targetid = gd_list[inx].S_objid,
                         targetos = gd_list[inx].osnum);
      EMerr_hndlr (!(1&OM_stat & *EFmsg),*EFmsg,EMS_E_Fail,wrapup);
                    
      status = EFget_xh_sf_geom (&rc, xh_info.angle, NULL, NULL, 
                                 sf_ogm, &old_xhsf);
      EMerr_hndlr(!status || !(1&rc) ,*EFmsg, EMS_E_Fail, wrapup);
     
      status = BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);
      OM_stat = EFsspbtol_by_geom (&rc, sf_ogm, &uv_tol);
      EMerr_hndlr (!(1 & OM_stat & rc),*EFmsg, EMS_E_Fail, wrapup);
      
      status = EFmap_xyz_to_uv_for_planes (&rc, sf_ogm,
                 cht_tol, uv_tol, 4, old_xhsf.poles, &data_within_range,
                 &data_on_sf, FALSE, osf_uv_pts);
      EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

      status = EFmap_uv_to_xyz_for_planes (&rc, sf_ngm, cht_tol,
                 4, osf_uv_pts, nsf_xyz_pts);
      EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

      /*
       * Update u_sgrps_info, if any.
       */

      if (xh_info.num_u_sgrps)
      {
        ou_len = BSdistptpt (&rc, old_xhsf.poles, &old_xhsf.poles[3]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

        nu_len = BSdistptpt (&rc, nsf_xyz_pts, &nsf_xyz_pts[3]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

        xform_factor = nu_len/ou_len;

        for (i = 0; i < xh_info.num_u_sgrps; i++)
        {
          xh_info.u_sgrp_info[i].sgrp_rls_spacing *= xform_factor;
          xh_info.u_sgrp_info[i].ptrn_sgrp_spacing *= xform_factor;

        } /* for (i = 0; i < xh_info.num_u_sgrps; i++) */

      } /* if (xh_info.num_u_sgrps) */

      /*
       * Update v_sgrps_info, if any.
       */

      if (xh_info.num_v_sgrps)
      {
        ov_len = BSdistptpt (&rc, old_xhsf.poles, &old_xhsf.poles[6]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

        nv_len = BSdistptpt (&rc, nsf_xyz_pts, &nsf_xyz_pts[6]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

        xform_factor = nv_len/ov_len;

        for (i = 0; i < xh_info.num_u_sgrps; i++)
        {
          xh_info.v_sgrp_info[i].sgrp_rls_spacing *= xform_factor;
          xh_info.v_sgrp_info[i].ptrn_sgrp_spacing *= xform_factor;

        } /* for (i = 0; i < xh_info.num_v_sgrps; i++) */

      } /* if (xh_info.num_v_sgrps) */

      for (inx = 0; inx < num_gds; inx++ )
      {
        OM_stat = om$send (msg = message EMSchatch.EMputdef (EFmsg, 
                            xh_info),
                           senderid = NULL_OBJID,
                           targetid = gd_list[inx].S_objid,
                           targetos = gd_list[inx].osnum);
        if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
        EMerr_hndlr (!(1&OM_stat & *EFmsg),*EFmsg, EMS_E_Fail,wrapup);

      } /* for (inx = 0; inx < num_gds; inx++ ) */
       
      if (xh_info.u_sgrp_info) om$dealloc (ptr = xh_info.u_sgrp_info);
      if (xh_info.v_sgrp_info) om$dealloc (ptr = xh_info.v_sgrp_info);

     } /* if (ch_exists) */

     if (gd_list) om$dealloc (ptr = gd_list);

   } /* if (num_gds) */

wrapup:
 
 EMWRAPUP (*EFmsg, OM_stat, "EFplane_xform_support");
 return;

} /* EFplane_xform_support () */

end implementation EMSplane;
