/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>
#include "emsmacros.h"
#include "emsdef.h"
#include "EMSssprops.h"
#include "godef.h"
#include "gocmacros.h"

method EMrevorient (IGRlong *EMmsg)
/*
Description
    This method simply reverses the orientation of the surfaces, by
    reversing the "pos_orient" bit in the surfaces.

Return values
    EMS_S_Success if all is well

Notes
 
History
    DLB 4/20/87 creation.
    dhm 4/06/88 Added GR_NOTIFY_LISTENERS.
*/
{
  IGRint                OM_stat;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*Toggle the orientation of me*/
  me^^EMSsubbs.ss_props ^= EMSIS_NRML_REVERSED;
 
  {
    IGRboolean loc_sts;  /*DECLARE*/

    /*Delete the abs buffer to ensure that the abs geom will be 
     * extracted thereby reflecting the change in instance data -DLB.
     */
    loc_sts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);
  }

 wrapup:
  GR_NOTIFY_LISTENERS(EMmsg, &OM_stat, GR_GEOM_MODIFIED);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMrevorient")
  return (OM_stat);
}

end implementation EMSsubbs;
