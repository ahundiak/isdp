/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include <string.h>
#include "griodef.h"
#include "exdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "ECprepsf.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

IGRint ECunprepsurf (msg, sfid, changes)
IGRlong *msg;
struct GRid sfid;
IGRushort changes;
{
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_loopset;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the surface-object has had a natural loopset connected to it
   * delete this.
   */

  if (changes & EMS_SURF_NATLOOP_ADDED)
  {
    stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);

    {
      OMuint stupid;
      OM_S_OBJECT_LINKAGE loopset_id;
     

      stat_OM = om$get_channel_objects(objid = sfid.objid,
                                       osnum = sfid.osnum,
                                       p_chanselect = &chan_to_loopset,
                                       list = &loopset_id,
                                       size = 1,
                                       count = &stupid);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$send(msg = message Root.delete (TRUE), 
                        senderid = NULL_OBJID,
                        targetid = loopset_id.S_objid,
                        targetos = loopset_id.osnum);
      EMomerr_exit (stat_OM, ret_end);
    }
  }

  /*
   * If this surface-object has had it's orientation reversed, toggle it
   * back to the original state.
   */

  if (changes & EMS_SURF_ORIENT_REVERSED)
    {
    stat_OM = om$send (msg = message EMSsurface.EMrevorient (&msg_loc),
               targetid = sfid.objid, targetos = sfid.osnum,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "ECunprepsurf")
  return (stat_OM);
}

end implementation EMSsurface;
