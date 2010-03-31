/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef EMSfrtdef_include
#include "EMSfrtdef.h"
# endif

#include "emserr.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "EMSssprops.h"
#include "EMSopt.h"
#include "EMSerrordef.h"
#include "OMmacros.h"


from EMSloop import EMget_props;
from EMSsubbs import EMset_props;

/*
DESCRIPTION:

This message is sent to the graphics data any time the graphics data gets
 messages such as Init, Reset, delete ( Instances at which the surface
 could have undergone range changes). These range changes are only due to
 changes to external P loops on the surface. If this graphics data is 
 is connected to such a loop, it sends a message to the surface which 
 would set it's EMIS_RANGE_MODIFIES bit.

HISTORY:

SAM		06/20/88		Creation date.
SAM		07/29/88		Added code which checks for loop
                        property = !EMLP_NOAREA_NOHOLE
                        (which is a feature loop).
RC      11/02/88        Modified such that the message is sent to
                        loop or surface by objid instead of channel send.
*/

method EMnotify_surface_range_modify(IGRlong *EMmsg)
{
  IGRlong           sts;
 
  /*
   * Initialize
   */

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  if(ME.EMShelper->props & EMGD_NONNATURAL)
  {
   GRobjid           lp_id, sf_id;
   IGRushort lp_props;
   extern void       EFget_gd_lp_sf();  

   EFget_gd_lp_sf (EMmsg, my_id, OM_Gw_current_OS, &lp_id, &sf_id);
   EMerr_hndlr (!(1& *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (!IF_NULL_OBJID (lp_id) && !IF_NULL_OBJID(sf_id))
   {
     sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lp_props),
                   targetid = lp_id);
     EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

     if(  (lp_props & EMLP_EXTERNAL) && !(lp_props & EMLP_NATURAL) && 
          !(lp_props & EMLP_NOAREA_NOHOLE) )
     {
       sts = om$send(msg = message EMSsubbs.EMset_props(EMmsg, 
                      EMSIS_RANGE_MODIFIED, EMS_O_ON),
                     targetid = sf_id);
       EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

     } /* If external, non-natural P_LOOP */

   } /* if (!IF_NULL_BJID (lp_id) && !IF_NULL_OBJID(sf_id)) */

  } /* if(ME.EMShelper->props & EMGD_NONNATURAL) */

   
wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSgradata.EMnotify_surface_range_modify");
  return(sts);
}

end implementation EMSgradata;
