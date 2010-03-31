/* ###################   APOGEE COMPILED   ################## */

/*

   History

         Sudha 06/04/93          modified to include BSprototype header files

*/

class implementation EMSedge;

#include "EMS.h"
#include "EMSlmdef.h" 
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "bsdotp.h"
#include "bscrossp.h"

from GRvg import EMptatpr;
from EMSsubbs import EMpratmpt;
from EMSsubbs import EMtangent_normal;

method EMedge_config (IGRlong             *EMmsg;
                      struct GRmd_env     *my_env;
                      IGRpoint            point_on_edge;
                      GRobjid             my_surf_id,
                                          com_surf_id; 
                      IGRvector           av_normal;
                      struct IGRbsp_curve *my_geom;
                      IGRdouble           check_tol;
                      IGRshort            *edge_config)
{
  IGRlong                 stat_OM, msg;
  IGRint                  i;
  IGRshort                my_edge_loc;
  IGRushort       com_edge_prop;
  IGRdouble               my_parms[2], comm_parms[2];
  IGRdouble	              dist, disp_fac, config_val;
  IGRpoint	              base_point;
  IGRvector               my_TN[4], comm_TN[4];
  IGRvector               lat_vec[2], tangent;
  struct EMSedgebound     bound[2], mid_param;
  OM_S_CHANSELECT         to_common_edge;

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  disp_fac = 1.0;

  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

  stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                          &com_edge_prop),
                    p_chanselect = &to_common_edge);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (! my_surf_id)
   {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                            (&msg ,&my_surf_id, NULL),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }
  if (! com_surf_id)
   {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                            (&msg, &com_surf_id, NULL),
                      p_chanselect = &to_common_edge);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, NULL,
                          NULL, bound, &bound[1], NULL),
                    targetid = my_id);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  if (bound[0].span_inx == bound[1].span_inx)
      mid_param.span_inx = bound[0].span_inx;
  else
    mid_param.span_inx =
           (IGRint) (bound[0].span_inx + bound[1].span_inx)/2;

  mid_param.param = (bound[0].param + bound[1].param) / 2;

  stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1, &mid_param,
                          NULL, my_parms),
                    targetid = my_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message GRvg.EMptatpr(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, my_parms, 2,
                          point_on_edge),
                    targetid = my_surf_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  stat_OM = om$send(msg = message EMSsubbs.EMtangent_normal(&msg,
                          my_env, my_parms, disp_fac, my_TN),
                    targetid = my_surf_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, 1,
                          point_on_edge, comm_parms, &dist, base_point),
                    targetid = com_surf_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  stat_OM = om$send(msg = message EMSsubbs.EMtangent_normal(&msg,
                          my_env, comm_parms, disp_fac, comm_TN),
                    targetid = com_surf_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  for (i=0; i<3; i++)
       av_normal[i] = (my_TN[2][i] + comm_TN[2][i]) / 2;

  if ((ME.EMSedge->ed_props & EMED_NATURAL) &
      (com_edge_prop & EMED_NATURAL))
   {
    EFlateral_tangents(&msg, my_TN, comm_TN, lat_vec);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

    stat_OM = om$send(msg = message EMSedge.EMget_location(&msg,
                            &my_edge_loc),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    if (my_edge_loc == 1 || my_edge_loc == 2)
     {
      lat_vec[0][0] = -lat_vec[0][0];
      lat_vec[0][1] = -lat_vec[0][1];
      lat_vec[0][2] = -lat_vec[0][2];
     }
   }
  else
   {
    stat_OM = om$send(msg = message EMSedge.EMtangent(&msg,
                            my_env, &my_surf_id, point_on_edge,  
                            disp_fac, my_geom, tangent),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    BScrossp(&msg, tangent, my_TN[3], lat_vec[0]);
   }

  /*
   * angle between tangent of one surface towards area region and solid
   * normal of the other surface
   */

  config_val = BSdotp(&msg, lat_vec[0], comm_TN[2]);

  if (config_val >= -(check_tol) && config_val <= check_tol)
   {
    *edge_config = EMS_NEUTRAL_EDGE;
    if (BSdotp(&msg, my_TN[2], comm_TN[2]) < 0)
        *edge_config = EMS_CONVEX_EDGE;
   }
  else if (config_val < 0)
           *edge_config = EMS_CONCAVE_EDGE;
  else if (config_val > 0)
           *edge_config = EMS_CONVEX_EDGE;

wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMedge_config");
  return (stat_OM);
}

end implementation EMSedge;
