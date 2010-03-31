/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "bserr.h"
#include "emsmacros.h"
#include "emsdef.h" 
#include "OMmacros.h"
#include "bssfeval.h"
#include "bscv_copy.h"
#include "bsalloccv.h"

from EMSedge import EMget_bcxyz_geom;

method EMget_boundary_in_model_space (IGRlong                 *EMmsg;
                                      struct GRmd_env         *my_env;
                                      GRobjid                 srf_id;
                                      struct IGRbsp_surface   *srf_geom;
                                      GRobjid                 *edge_id;
                                      struct IGRbsp_curve     **edge_geom;
                                      IGRpoint                pt_area;
                                      IGRint                  *index;
                                      IGRboolean              *bnd_found)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	06/07/88:	design date
          Sudha         06/23/93        Modified for BSprototype ansification

Algorithm

*/

{
 IGRlong 		           stat_OM, msg;
 OMuword                   dum_os;
 IGRint                    i, j;
 IGRint                    ls_count;
 OMuint                    count;
 struct GRid               surf_GRid;
 struct IGRbsp_curve       xyz_curve;
 OM_S_CHANSELECT           to_edges, to_loopset;
 OM_S_OBJECT_LINKAGE       ls_linkage;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 *bnd_found = FALSE;
 surf_GRid.objid = srf_id;
 surf_GRid.osnum = OM_Gw_current_OS;
 
 stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 stat_OM = om$get_channel_objects (objid = surf_GRid.objid,
                                   osnum = surf_GRid.osnum,
                                   p_chanselect = &to_loopset,
                                   list = &ls_linkage,
                                   size = 1,
                                   count = &count);
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 ls_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 for (i=0; i<ls_count; i++)
  {
   if (IF_EQ_OBJID(ME.EMSdpr->ids[i], ls_linkage.S_objid))
    {
     for (j=0; j<ME.EMSsfround->no_of_boundaries; j++)
      {
       if (ME.EMSsfround->round_exec_info[j].index == i)
        {
         stat_OM = om$get_objid_at_index(objid = 
                   ME.EMSsfround->round_exec_info[j].bnd_info.loop_id,
                                         p_chanselect = &to_edges,
                                         index = 0,
                                         objidaddr = edge_id,
                                         osnumaddr = &dum_os);
         EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

         xyz_curve.weights = NULL;
         xyz_curve.poles = NULL;
         xyz_curve.knots = NULL;
         xyz_curve.bdrys = NULL;

         stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                                 &my_env->md_env, &surf_GRid, srf_geom, 0,
                                 OM_K_MAXINT, FALSE, NULL, &xyz_curve),
                      targetid = *edge_id);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

         BSalloccv(xyz_curve.order, xyz_curve.num_poles,
                   xyz_curve.rational, 0, edge_geom, &msg);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         BScv_copy(&msg, &xyz_curve, *edge_geom);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         BSsfeval(srf_geom,
              ME.EMSsfround->round_exec_info[j].bnd_info.point_in_area[0],
              ME.EMSsfround->round_exec_info[j].bnd_info.point_in_area[1],
              0, (IGRpoint *)pt_area, &msg);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         *index = j;
         *bnd_found = TRUE;
         goto wrapup;
        }
      }
    }
  }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMget_boundary_in_model_space");
 return (stat_OM);
}

end implementation EMSsfround;
