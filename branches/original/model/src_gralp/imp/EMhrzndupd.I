/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include "EMS.h"
#define DEBUG 0
#include <stdio.h>
#include "graph.h"
#include "EMSasopts.h" /*  For EMSasconst_recompute */
#include "gocmacros.h"
#include "nddef.h" /* For ND_COMP_SUCC */
#include "exmacros.h"

method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
                struct GRid *list;
                IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
/* *************************************************************************

Description                      
This method computes the new geometry and updates the node for all
associative vector graphic constructions.

History
 PP      03/07/91        Creation Date 
 Jack    09/29/91        Overridden for EMShorizon 
 Jack    11/18/91        Changed to just pass on message to parent.
 
 *********************************************************************** */
{
 IGRlong status;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 cnt_type |= ND_COMP_NO_DISPLAY | ND_COMP_NO_ERASE |
             ND_COMP_NO_REM_RT  | ND_COMP_NO_ADD_RT ;


 status = om$send( msg = message EMSassoc.NDupdate(
                                            EMmsg,
                                            cnt_type,
                                            count,
                                            list,
                                            parent_state,
                                            context,
                                            new_objid,
                                            md_env),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
                     



wrapup:
/*
 * Set the return codes correctly for the graph.
 * pp 07/12/91
 */
 if (1&status&*EMmsg)
  *EMmsg = ND_COMP_SUCC;
 else
  *EMmsg = ND_COMP_FAIL;

 EMWRAPUP (*EMmsg, status, "In EMShorizon.NDupdate error");
 return (status);
}
end implementation EMShorizon;

