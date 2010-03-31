/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "EMSdprquery.h"

method EMgetattributeid(IGRlong *EMmsg; struct GRid *attribute_GRid)
/*
Description
    This method returns the CI_executor object id on the notification
    channel.  

Return Values
    EMS_S_Success       - all is well.
    EMS_W_ChanCountNot1 - the notification channel does not have 1 object on
                          it.
    EMS_E_Fail          - if a failure occurred.

Notes
    The following assumptions are made regarding this message:

    1) This message is defined for use by Salvagnini Transferica ONLY. 

    2) This object will have one object connected across the
       notification channel and that object is CI_executor.

    3) No maintainence of the CI_executor object will be performed by EMS.
       Connect, disconnect, delete, and update operations should be handled
       by the application.

History
    DLB 10/13/88 Creation.
    NP  08/21/92 Modified for ANSI conversion. Changed "count" to "IGRuint".
*/
{
  IGRlong             OM_stat=OM_S_SUCCESS;
  IGRuint             count;
  OM_S_CHANSELECT     notif;
  OM_S_OBJECT_LINKAGE object_linkage;


  *EMmsg = EMS_S_Success;

  notif.type = OM_e_addr;
  notif.u_sel.addr = &ME.GRnotify->notification;
  
  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &notif,
                                 count = &count);
  if (!(1 & OM_stat)) goto wrapup;

  if (count != 1) {*EMmsg = EMS_W_ChanCountNot1; goto wrapup;}

  OM_stat = om$get_channel_objects(object = me,
                                   p_chanselect = &notif,
                                   list = &object_linkage,
                                   size = 1,
                                   count = &count);
  if (!(1 & OM_stat)) goto wrapup;

  attribute_GRid->objid = object_linkage.S_objid;
  attribute_GRid->osnum = object_linkage.osnum;  

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMgetattributeid")
    return(OM_stat);
}
end implementation EMSsurface;
