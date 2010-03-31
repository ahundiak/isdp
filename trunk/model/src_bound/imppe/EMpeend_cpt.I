/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "OMmacros.h"

from EMSgenbs import EMinsktln;
from EMSsubbs import EMmove_class;

method EMmake_end_compatible(IGRlong *EMmsg; 
                             struct GRmd_env *my_env)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError -- edge error
                - EMS_E_SurfaceError -- surface error
Assumption

Bugs

History
	
	  gupta 	11/24/87:	design date

Algorithm

*/

{
  IGRshort              my_loc;
  IGRlong               stat_OM,msg;
  IGRint                num_parms;
  IGRdouble             parm1[2];
  struct EMSedgebound   bound1[2];
  GRobjid               my_surf_id;
  GRobjid               new_surf, chg_id;

/*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* get my surface id */

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, &my_surf_id, NULL),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMpeend_cpt.EMgetsurf_info");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   /* get my end parameters */

   stat_OM = om$send(msg=message EMSedge.EMendpts(&msg, NULL, NULL,
                         &bound1[0], &bound1[1], NULL),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMpeend_cpt.EMendpts");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSedge.EMget_location(&msg, &my_loc),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMpeend_cpt.EMget_location");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (my_loc == 2 || my_loc == 3)
    {
     parm1[0] = 1 - bound1[0].param;
     parm1[1] = 1 - bound1[1].param;
    }
   else
    {
     parm1[0] = bound1[0].param;
     parm1[1] = bound1[1].param;
    }

   num_parms = 2;

   stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                           my_env, &new_surf),
                     targetid = my_surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMpeend_cpt.EMmove_class");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   if (my_loc == 1 || my_loc == 3)
    {
     stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             num_parms, parm1, NULL, NULL, 
                             NULL, 1, TRUE, FALSE, &chg_id),
                       targetid = new_surf);
    }
   else
   if (my_loc == 0 || my_loc == 2)
    {
     stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             NULL, NULL, num_parms, parm1,
                             NULL, 1, FALSE, TRUE, &chg_id),
                       targetid = new_surf);
    }
   EMomerr_hndlr(stat_OM, wrapup, "EMpeend_cpt.EMinsktln");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

wrapup:

   return(stat_OM);
}

end implementation EMSpartedge;
