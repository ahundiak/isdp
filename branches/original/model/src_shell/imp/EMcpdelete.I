/* ###################   APOGEE COMPILED   ################## */
class implementation EMScpmgr;

#include "EMSopt.h"
#include "EMSprop.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSedge_class_id, OPP_EMSloop_class_id;

from OMObjSpace import pass;
from EMSloop import EMset_props;
from EMSedge import EMset_props;

method delete (IGRint defer_flag)
{
  IGRlong msg_loc, stat_OM;
  GRobjid osobj;
  OM_S_CLASSLIST classlist;
  extern void EMremmgr();

  stat_OM = OM_S_SUCCESS;

  /*
   * Remove my entry from the local control tables. Then delete myself
   * with a call to Root.delete declared at Root.
   */

  EMremmgr (&msg_loc, OM_Gw_current_OS, OPP_EMScpmgr_class_id,
   ME.EMSobjmgr->label);

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message Root.delete (TRUE),
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * For each special type of object perform the specialized cleanups.
   */

  if (ME.EMSobjmgr->label == EMScp_sfbdry)
    {
    stat_OM = om$osnum_to_oso_objid (osnum = OM_Gw_current_OS,
               p_objid = &osobj);
    EMomerr_exit (stat_OM, ret_end);

    classlist.w_count = 1;
    classlist.w_flags = OM_CLST_subclass;

    classlist.p_classes = &OPP_EMSloop_class_id;
    stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
               OM_e_wrt_object, message EMSloop.EMset_props
               (&msg_loc, EMLP_MSCEXISTS, EMS_O_OFF)), targetid = osobj);

    classlist.p_classes = &OPP_EMSedge_class_id;
    stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
               OM_e_wrt_object, message EMSedge.EMset_props
               (&msg_loc, /* EMED_MSCCOMMON | */ EMED_MSCEXISTS, EMS_O_OFF)),
               targetid = osobj);
    }

ret_end:
  msg_loc = TRUE;
  EMWRAPUP (msg_loc, stat_OM, "EMScpmgr.delete");
  return (stat_OM);
}

end implementation EMScpmgr;
