/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "msdef.h"

extern GRclassid  OPP_EMSmassprop_class_id;

from EMSmassprop import EMset_density;

method EMreset_density (IGRlong *EMmsg;
                        IGRdouble *density)

/*
History
  gupta 11/07/89 : Creation
*/
{
 IGRlong                stat_OM, msg;
 IGRint                 i;
 OMuint			count, chan_count;
 GRclassid              obj_class_id;
 OM_S_CHANSELECT        to_comps, notify_chan;
 OM_S_OBJECT_LINKAGE    *chan_objects;

 /*-----------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 chan_objects = NULL;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 /* Send on down */

 stat_OM = om$send(msg = OPPmargs,
                   p_chanselect = &to_comps);
 if (!(1 & stat_OM) && (stat_OM != OM_W_UNKNOWN_MSG)) goto wrapup;

 stat_OM = om$make_chanselect (channame = "GRnotify.notification",
                               p_chanselect = &notify_chan);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$get_channel_count (object = me,
                                 p_chanselect = &notify_chan,
                                 count = &chan_count);
 if (! (1 & stat_OM)) goto wrapup;

 if (chan_count)
  {
   chan_objects = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                      chan_count * (sizeof (OM_S_OBJECT_LINKAGE)));
   if (! chan_objects) goto wrapup;
  }

 stat_OM = om$get_channel_objects (object = me,
                                   p_chanselect = &notify_chan,
                                   list = chan_objects,
                                   size = chan_count,
                                   count = &count);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<chan_count; i++)
  {
   stat_OM = om$get_classid(osnum = chan_objects[i].osnum,
                            objid = chan_objects[i].S_objid,
                            p_classid = &obj_class_id);
   if (! (1 & stat_OM)) goto wrapup;

   if (obj_class_id == OPP_EMSmassprop_class_id)
    {
     stat_OM = om$send(msg = message EMSmassprop.EMset_density (&msg,
                             *density),
                       targetid = chan_objects[i].S_objid,
                       targetos = chan_objects[i].osnum);
     if (! (1 & stat_OM & msg)) goto wrapup;
     break;
    }
  }

 wrapup:

  EMWRAPUP(*EMmsg, stat_OM, "In EMScompsurf.EMreset_density")
  if (chan_objects) om$dealloc (ptr = chan_objects);
  return (stat_OM);
}
end implementation EMScompsurf;
