/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "EMSdef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

from EMSsubbs import EMpratmpt;
from GRvg import EMptatpr;

method EMchild_crv_parm(IGRlong             *EMmsg;
                        struct EMSedgebound *my_edge_info,
                                            *child_edge_info; 
                        struct GRmd_env     *my_env;
                        IGRshort            my_edge_pos;
                        GRobjid             child_id) 
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method
Assumption

Bugs

History
	
	  gupta 	05/05/87:	design date

Algorithm

      This method takes a parameter on an edge (me) and finds the 
      corresponding parameter on another edge (child), whose
      parametrization is such that it will be a part of me.

      First get the uo,vo corresponding to the incoming parameter on
      my surface. Get the xyz, corresponding to this uo,vo. Get the
      un,vn on the child edge's surface corresponding to xyz. Finally
      decide the child edge parameter based on this un,vn.
*/

{
  IGRlong          stat_OM,msg;
  IGRdouble        my_uv[2], child_uv[2], xyz[3];
  IGRdouble	       dist;
  IGRpoint	       base_point;
  GRobjid          child_surf, my_surf;

/*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* get the uv corresponding to my crv_param */

  stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          my_edge_info, NULL, my_uv),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmypar.EMptatpr");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
	
  /* get my surface id as well as the child's surface id */

  stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                          (&msg,&my_surf,NULL),
                    targetid=my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmypar.EMgetsurf_info");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                          (&msg,&child_surf,NULL),
                    targetid = child_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmypar.EMgetsurf_info");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /* get the xyz point on my surface */

  stat_OM = om$send(msg = message GRvg.EMptatpr(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, my_uv, 2, xyz),
                          targetid = my_surf);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmypar.EMptatpr");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /* the uv on the child's surface */

  stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, 1,
                          xyz, child_uv, &dist, base_point),
               targetid = child_surf);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmypar.EMpratmpt");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  /* get the crv parameter on the child edge's curve */

  switch (my_edge_pos)
   {
    case 0:
           child_edge_info->param = child_uv[1];
           break;
    case 1:
           child_edge_info->param = child_uv[0];
           break;
    case 2:
           child_edge_info->param = 1 - child_uv[1];
           break;
    case 3:
           child_edge_info->param = 1 - child_uv[0];
           break;
   }

   child_edge_info->span_inx = 0;

wrapup:
  
   return(stat_OM);
}
end implementation EMSedge;
