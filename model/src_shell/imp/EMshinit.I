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

  HISTORY

    SS  :  04/06/88  :  Creation
    SS  :  09/15/88  :  Creation of associated cleaner object.
*/

class implementation EMSshobjmgr;

#include "EMS.h"
#include "exmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMinit (IGRulong label; IGRchar *moreinfo)
{
  IGRlong stat_OM;

  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message EMSobjmgr.EMinit (label, moreinfo),
             mode = OM_e_wrt_message, targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
   
  ME.EMSshobjmgr->watermark = EMSSHELL_WATERMARK_LEVEL;
  ME.EMSshobjmgr->numclasses = 0;
  ME.EMSshobjmgr->numobjects = 0;

ret_end:
  return (stat_OM);
}

end implementation EMSshobjmgr;
