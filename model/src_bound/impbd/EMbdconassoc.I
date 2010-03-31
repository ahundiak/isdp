/* ###################   APOGEE COMPILED   ################## */
/*
This method will connect all the objects on the association chanel of the
receiving boundary object to the association channel of all the input
objects. The channel connections for the receiving boundary objects remain
unchanged.

History
	SS	Long Ago	Creation.
	SM	30_oct-89	Moved Siki's method from EMSedge to
				EMSboundary so that it is inherited by all
				boundary objects.
*/
class implementation EMSboundary;

#include "EMS.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE 5

method EMconn_to_myassoc (IGRlong *msg; IGRint num_conobjs; GRobjid *conobjs)
{
  IGRint i, j, listsize = 0;
  OMuint assoc_count;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_assoc;
  OM_S_OBJECT_LINKAGE init_list[INIT_OBJLIST_SIZE], *objlist = NULL;
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect (GRnotify_notification, &chan_to_assoc);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_assoc,
             count = &assoc_count);
  EMomerr_exit (stat_OM, ret_end);

  if (assoc_count > INIT_OBJLIST_SIZE)
    {
    objlist = (OM_S_OBJECT_LINKAGE *)om$malloc (size = 
            assoc_count * sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);
    listsize = assoc_count;
    }
  else
    {
    objlist = init_list;
    listsize = INIT_OBJLIST_SIZE;
    }
  
  stat_OM = om$get_channel_objects (object = me, p_chanselect = &chan_to_assoc,
             list = objlist, size = listsize, count = &assoc_count);
  EMomerr_exit (stat_OM, ret_end);

  for (i=0; i<assoc_count; i++)
    for (j=0; j<num_conobjs; j++)
      {
      stat_OM = om$send (msg = message Root.connect (chan_to_assoc, MAXINT, 
                 conobjs[j], OM_Gw_current_OS, chan_to_assoc, MAXINT),
                 targetid = objlist[i].S_objid, targetos = objlist[i].osnum);
      EMomerr_exit (stat_OM, ret_end);
      }
  
ret_end:
  if (listsize > INIT_OBJLIST_SIZE)
    om$dealloc (ptr = objlist);
  EMWRAPUP (*msg, stat_OM, "EMSboundary.EMconn_assoc");
  return (stat_OM);
}

end implementation EMSboundary;
