/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"

from EMSsubbs import EMleavecs;

method GRremove_components(IGRlong *msg; struct GRmd_env *md_env;
                           IGRint *num_objects; struct GRobj_env drp_obj[])

/*
Abstract

    This method removes  components (one by one) from a composite surface.

Arguments

    *msg       IGRlong            error return code
    *md_env    struct GRmd_env    module environment of the object

Notes
    EMS_S_Success    returns if all goes well
    EMS_E_Fail       returns if any error occurs

    It is assumed that all the component objects are individual single
    surfaces.

Files
    EMcsremvcomp.I

History
    SS    11/02/89    Notification
    RV    04/06/88    creation date.
*/

{
  IGRboolean   notify;
  IGRlong      msg_loc, status, i;

  /*
   * Initalize
   */

  status = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  for (i=0; i<*num_objects; i++)
  {
    status = om$send(msg = message EMSsubbs.EMleavecs (&msg_loc, md_env),
                     targetid = drp_obj[i].obj_id.objid,
                     targetos = drp_obj[i].obj_id.osnum);
    if (! (1&msg_loc&status)) {*msg = EMS_I_Fail; goto ret_end;}
  }

  if (notify = EMcheck_inhibit_postproc())
    {
    om$send (msg = message EMSsurface.EMpostdelete (&msg_loc,
     EMS_POST_NOCOMPONENTS, md_env, NULL, NULL), targetid = my_id);
    EMrestore_postproc();
    }

ret_end:

  return(status);

}

end  implementation EMScompsurf;
