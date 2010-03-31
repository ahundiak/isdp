/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This file contains the set of special constructor functions that can be
    used to construct shell objects.  If a NULL constructor-function pointer
    is passed to the shell manager it constructs the object by a call
    to om$construct with a NULL message. 

    Each function must have exactly the same formal arguments - i) a pointer
    to a long for the return message code, ii) a pointer to some information
    packet and iii) a pointer to the GRid structure that will contain the shell
    object-id that has been constructed.

  HISTORY
 
    SS  :  08/17/88  :  Creation
*/

class implementation Root;

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSobjmgrdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSstruct.h"
#include "emserr.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSsurface import EMmk_nat_bdry;
from EMSloopset import EMset_props;

/*
 * This is a special function used to construct shell loopsets. It is
 * currently being used in the file EMsslocate.I
 */

IGRboolean EMlsconstructor (msg, sfinfo, lsid)
IGRlong *msg;
struct EMSgrobj *sfinfo;
struct GRid *lsid;
{
  IGRboolean ls_constructed;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  GRobjid obj;
  GRspacenum os;
  struct GRmdenv_info *mdenv;
  OM_S_CHANSELECT chan_to_loopset;
  OM_S_OBJECT_LINKAGE objlink;

  *msg = EMS_S_Success;
  ls_constructed = FALSE;

  obj = sfinfo->grid.objid;
  os = sfinfo->grid.osnum;
  mdenv = sfinfo->envptr ? sfinfo->grenv.ptr : &sfinfo->grenv.val;

  stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg_loc,
             mdenv, NULL), targetid = obj, targetos = os,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM | msg_loc), *msg, EMS_E_SurfaceError,
   ret_end);
 
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$get_channel_objects (objid = obj, osnum = os,
             p_chanselect = &chan_to_loopset, list = &objlink, size = 1,
             count = &count);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

  lsid->osnum = os;
  lsid->objid = objlink.S_objid;
  ls_constructed = TRUE;

  stat_OM = om$send (msg = message EMSloopset.EMset_props (&msg_loc,
             EMLS_SHELL, EMS_O_ON), targetid = lsid->objid, 
             targetos = lsid->osnum, senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMlsconstructor");
  return (ls_constructed);
}

end implementation Root;
