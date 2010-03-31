/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method initializes the manager object. Mainly it performs
    the arduous task of moving the short value of watermark into the
    exact field of the instance data, where it is expected by all
    the other methods of this object.

    Of late this method has started doing more work. It constructs a
    cleaner object (EMSshcleaner) and connects it to this shell. This
    object will be responsible for cleaning up the shell's that are
    not in a binding relationship.

  NOTES
  
    This method is expected to be invoked by every override of EMinit.
    The send with respect to message must be used. This send must be performed
    before doing anything else.

  HISTORY

    SS  :  04/06/88  :  Creation
    SS  :  09/15/88  :  Creation of associated cleaner object.
*/

class implementation EMSobjmgr;

#include "EMS.h"
#include "exmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMinit (IGRulong label; IGRchar *moreinfo)
{
  IGRlong stat_OM;
  GRobjid mdobj, cleanerid;
  OM_S_CHANSELECT chan_to_cleaner, chan_to_objmgr;

  stat_OM = OM_S_SUCCESS;

  ME.EMSobjmgr->label = label;

  stat_OM = ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mdobj);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = ex$get_super (mod_id = mdobj, mod_osnum = OM_Gw_current_OS,
             super_name = EMSobjmgr_cleaner, create = TRUE, 
             super_class = "EMScleaner", super_id = &cleanerid);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMSobjmgr_to_cleaner, &chan_to_cleaner);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = EMmake_chanselect (EMScleaner_to_objmgr, &chan_to_objmgr);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message Root.connect (chan_to_cleaner,
             MAXINT, cleanerid, OM_Gw_current_OS, chan_to_objmgr, NULL),
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  return (stat_OM);
}

end implementation EMSobjmgr;

