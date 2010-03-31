/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
/*
Abstract

    This is a KLUGE to get by until DRAFT modified the standard
    implementation to send something other than GRlnproject for
    boreline locate. They will do this in DRAFT 1.2 released around
    April 88.

History

    01 Jul 88   AIC     Partially de-KLUGED. Complete de-KLUGE
                        will take place in 1.2.0, when accept
                        tolerance is added to the argument list
                        of GRlnprocess.

    DLB  03/33/88       Modified to return sts rather than
                        OM_S_SUCCESS. This is needed for bottom
                        up locate.

    08 Dec 87   AIC     Creation Date
*/

# include "msdef.h"     /* MSSUCC   */

method GRlocate_processing(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                           struct GRlc_path *path; IGRint *path_position;
                           IGRint *owner_eligible, *component_eligible)
{
  IGRlong   sts = OM_S_SUCCESS;

  void EMSsubbs_put_locate_window();

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  /*
   * Store the locate window id/osnum so that vsgd objects can
   * access them.
   */
  EMSsubbs_put_locate_window(cvl->button.objid, cvl->button.osnum);

  /*
   * Perform standard locate
   */
  sts = om$send(msg = message GRvg.GRlocate_processing(EMmsg, cvl, path,
                path_position, owner_eligible, component_eligible),
                mode = OM_e_wrt_message, targetid = my_id);

wrapup:
/*
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.GRlocate_processing")
  *EMmsg = MSSUCC;
*/
  return(sts);
}

end implementation EMSsubbs;
