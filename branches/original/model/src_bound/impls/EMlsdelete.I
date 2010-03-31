/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method deletes each component object (loop) 
    belonging to the loopset, then deletes the loopset
    object itself.

  ALGORITHM

    This method deletes the component objects of a loopset and then 
    deletes the loopset object itself. Just before deleting itself
    it sends out an EMpostdelete message to itself, for any postprocessing
    (notification, handling of shell-loopsets, etc) that might be
    necessary.

  HISTORY:
	
    gupta  : 12/04/86 :  Creation date.
    RC     : 02/12/87 :  modification for topology
                         class structure changes
    RC     : 11/04/87 :  Modified for version 1.1.0
    WBC    : 01/04/94 :  Making sure EMrestore_postproc gets called if
                         necessary, even when EMSboundary.EMpostdelete
                         fails (TR#119313321).
*/

class implementation EMSloopset;

#include "EMS.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method delete(int defer_flag)
{
  IGRboolean notify = FALSE;
  IGRlong msg_loc, OM_stat;
  OM_S_CHANSELECT to_loops;

  OM_stat = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  
  OM_stat = om$send(msg = message Root.delete(defer_flag), 
             p_chanselect = &to_loops);
  EMomerr_exit (OM_stat, wrapup);


  if (notify = EMcheck_inhibit_postproc())
    {
    OM_stat = om$send (msg = message EMSboundary.EMpostdelete (&msg_loc,
               NULL, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (OM_stat & msg_loc), msg_loc, EMS_E_Fail, 
     wrapup);
    }
  OM_stat = om$send(mode = OM_e_wrt_message, 
             msg = message Root.delete (defer_flag), targetid = my_id);
  if (notify)
  {
    EMrestore_postproc();
    notify = FALSE;
  }
  EMomerr_exit (OM_stat, wrapup);

wrapup:

  if (notify)
    EMrestore_postproc();

  EMWRAPUP (msg_loc, OM_stat, "EMlsdelete");
  return (OM_stat);
}

end implementation EMSloopset;
