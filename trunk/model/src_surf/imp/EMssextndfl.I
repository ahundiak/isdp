/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "emserr.h"
#include "emsmacros.h"

method EMextend_fillet (IGRlong                *EMmsg;
                        struct GRmd_env        *my_env;
                        IGRdouble              radius;
                        IGRdouble              *param;
                        struct IGRbsp_surface  *my_geom,
                                               **extended_surface)

{
 
 IGRlong                 stat_OM, msg;
 IGRint                  i, option;
 IGRint                  num_u = 1, num_v = 1;
 IGRdouble               disp_fac;
 IGRdouble               u_param, point_on_surf[2];
 IGRpoint                dir_point, pts[3], dum_pt;
 GRobjid                 new_objid;
 struct GRpost_info      post_info;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 *extended_surface = NULL;
 disp_fac = 2.0 * radius;
 option = 2;
 u_param = 0.5;

 BSsfarrevt(my_geom, num_u, &u_param, num_v, &param[1], disp_fac, pts,
            &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (param[1] < 0.5)
  {
   for (i=0; i<3; i++)
        pts[2][i] = 2 * pts[0][i] - pts[2][i];
  }

 for (i=0; i<3; i++)
      dir_point[i] = (pts[2][i] + 10 * pts[0][i]) / 11.0;
 
 BSsfxttpt(option, my_geom, dir_point, pts[2], extended_surface, &msg);

 /* if dir point or ext point are inside the surface -- extension is not
  * needed , if both are inside the surface, it returns BSINARG -- hence
  * the filter
  */

/*
 if ((msg == BSINVEXTDIR) || (msg == BSINARG) || (msg == BSPHYCLOSED))
*/
 if (msg != BSSUCC)
  {
   msg = BSSUCC;
   *extended_surface = my_geom;
  }
 else
  {
   (*extended_surface)->pos_orient = (my_geom->pos_orient) ? TRUE : FALSE;
  }

 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 post_info.construct_flag = FALSE;
 stat_OM = om$send(msg = message GRvg.GRpostabsg(&msg, my_env, &post_info,
                         (IGRchar *) *extended_surface, &new_objid),
                   targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMextend_fillet");
 GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
 return (stat_OM);
}

end implementation EMSsubbs;
