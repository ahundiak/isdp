/*

Name
  SKdisppt

Abstract
    Used to display an SKpoint object

Synopsis
   *msg		long		Return code	(OUT)
   ptobj	GRobjid		SKptvar object ... NULL if the pt is passed in.  (IN)
   pt		IGRpoint	3D point information .. NULL if ptobj is passed in. (IN)
   mode		enum GRdpmode	Display mode. (IN)
   
Description

Return Value

Notes

Index

Keywords
  display, point
  
History
  05/21/90 : Sikandar Saifullah : created
  04/27/93 : Rajiv Agrawal : Updated documentation.
  07/02/93 : Sudha         : Modified for BSprototypes ansification

 */

class implementation SKptvar;

#include "EMS.h"
#include "OMmacros.h"
#include "madef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "maidmx.h"

extern GRclassid OPP_SKmgr_class_id;

from SKmgr import SKgetornt;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define MAX_LEN  1e5

void SKdisppt (msg, ptobj, pt, mode)
IGRlong 	*msg;
GRobjid 	ptobj;
IGRpoint 	pt;
enum GRdpmode 	mode;
{
  IGRint i, count, bytes_in, bytes_out;
  IGRlong msg_loc, stat_OM;
  IGRpoint ptvar;
  struct IGRdisplay active_display;
  struct GRmd_env active_md_env;
  IGRlong ECdisplayPointSetByBuffer0();
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the active module env
   */

  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
   buffer = &active_md_env, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

  /*
   * Obtain the point's geometry.
   */

  if (!pt)
  {
   stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
              &active_md_env.md_env.matrix_type,
              active_md_env.md_env.matrix,
              ptvar), targetid = ptobj, 
              targetos = active_md_env.md_id.osnum, 
              senderid = NULL_OBJID);
   EMomerr_exit (stat_OM, ret_end);
   EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
   pt = ptvar;
  }

  /*
   * Display the point
   */

  bytes_in = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
   buffer = &active_display, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  active_display.weight = 4;

  if (mode == GRhd)
    count = 5;
  else
    count = 1;

  for (i=0; i<count; i++)
    {
    stat_OM = ECdisplayPointSetByBuffer0 (&msg_loc, active_display,
               active_md_env, NULL_OBJID, 1, pt, mode, IGRPS);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    sleep(1);
    mode = i%2 ? GRhe : GRhd;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKdispptvar");
  return;
}

end implementation SKptvar;
