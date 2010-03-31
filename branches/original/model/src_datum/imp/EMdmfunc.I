/* ###################   APOGEE COMPILED   ################## */

class implementation EMSdatplnmgr;

#include "exmacros.h"
#include <stdio.h>
#inculde <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "EMdtmacros.h"

#include "actparam.h"

static IGRboolean aflag;
static GRspacenum osn;

from IGEgragad import DPinrot;
from EMSdatpln import EMget_pln_info;

IGRint EMget_datum_plane_mgr (EMmsg,os,mgrid, mgros)

IGRlong *EMmsg;
OMuword *os;
OM_S_OBJID *mgrid;
OMuword *mgros;

/* ***********************************************************************

 Description
  This function gets the datum plane mgr object id from the current module

   Output
     os : Object space in which to search for the manager.
     mgrid : object id of the mgr in the current module
     mgros : object space of the mgr in the current object space

 Notes
      Upon exit the completion code will always be
       EMS_S_Success :  successful

 History
      PP : 07/04/91                 Creation

   ********************************************************************** */

{
 IGRlong 		status ;
 OM_S_OBJID 		mod_id; /* Object id of the module */
 OMuword 		mod_os; /* Object space of the module */


 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;


 if (!os)
 {
  status = ex$get_cur_mod(id = &mod_id,
                          osnum = &mod_os);
  if (!(1&status)) goto wrapup;
 }
 else
 {
  mod_os = *os;
  status = ex$get_modid(mod_osnum = *os,
                       mod_id = &mod_id);
  if (!(1&status)) goto wrapup;
 }

 status = ex$get_super(mod_id = mod_id, mod_osnum = mod_os,
                       super_name = "EMSdatplnmgr", create = TRUE, 
                       super_class = "EMSdatplnmgr",
                       super_id = mgrid, super_osnum = mgros);
 if (!(1&status)) goto wrapup;

wrapup:
 return (status);
}

IGRint EMget_active_datum_plane (EMmsg,options,plane_GRid, win_GRid)
IGRlong *EMmsg;
unsigned int options;
struct GRid *plane_GRid;
struct GRid *win_GRid;
{
 IGRlong status;
 IGRint rc;
 struct GRid mgr_GRid;

 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;


 aflag = pwIsActivationOn();
 if (aflag)
 {
   osn = pwGetActiveOs();
   status = ems$get_datum_plane_mgr(msg = EMmsg,
                                    osnum = &osn,
                                    mgrid = &mgr_GRid.objid,
                                    mgros = &mgr_GRid.osnum);
 }
 else
 {
  status = ems$get_datum_plane_mgr(msg = EMmsg,
                                   mgrid = &mgr_GRid.objid,
                                   mgros = &mgr_GRid.osnum);
 }
 if (!(1&*EMmsg&status)) goto wrapup;

 status = om$send (msg = message EMSdatplnmgr.EMget_info(EMmsg, NULL,
                         NULL,NULL,&plane_GRid->objid,NULL),
                   senderid = NULL_OBJID,
                   targetid = mgr_GRid.objid,
                   targetos = mgr_GRid.osnum);
 if (!(1&*EMmsg&status)) goto wrapup;


 if (plane_GRid->objid == NULL_OBJID) return (OM_S_SUCCESS);
 plane_GRid->osnum = mgr_GRid.osnum;

wrapup:
 return (status);
}
end implementation EMSdatplnmgr;
