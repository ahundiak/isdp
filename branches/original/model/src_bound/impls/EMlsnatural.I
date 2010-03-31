/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
%safe
#include "math.h"
%endsafe
#include "bsparameters.h"
#include "bserr.h"
#include <stdio.h>

extern OMuword	OPP_EMSloop_class_id;

from EMSloop import EMmake_natural_loop;

method EMmake_natural_loopset(
 IGRlong               *EMmsg;
 IGRuchar      *curve_type;
 IGRushort     *edge_props;
 GRobjid               *edge_ids)

/*
Notes
       
Assumption

	The loopset has no loops when it recieves this message. If it
	has loops, they will not be properly nested.
   
        If the caller wishes to set any of the following edge
        properties, they sould be sent in an array of edge_props.
        The elements in the array edge_props should correspond
        to natural edge locations.

        The properties that can be sent in are:
        EMED_DEGENERATE
        EMED_XYZ_CLOSED
        EMED_SEAM
        EMED_REVERSE_CONNECT
             
History

	AIC	08/27/87	Modified to the new class structure
        RC      11/10/87        Changed arguments and code.
Algorithm

	This method constructs a natural loop and attaches it to
	itself.
*/

{
  IGRlong               OM_stat;
  GRobjid               loopid;
  OM_S_CHANSELECT       to_loops, to_outter;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ME.EMSloopset->ls_props = EMLS_NATURAL;

  /*
   * Make the channel selectors
   */
  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;
  OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror,wrapup);

  /*
   * Construct the natural loop
   */

  OM_stat = om$construct(classid=OPP_EMSloop_class_id, 
                p_objid = &loopid,
                msg = message EMSloop.EMmake_natural_loop(EMmsg,
                curve_type, edge_props, edge_ids));
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror,wrapup);
  EMerr_hndlr (!(1&*EMmsg),*EMmsg, EMS_E_LoopError,wrapup);

  /*
   * Connect the loop to the loopset (me)
   */

  OM_stat = om$send(msg = message Root.connect(to_outter, 0, my_id,
		OM_Gw_current_OS, to_loops, 0), targetid = loopid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSloopset.EMmake_natural_loopset");
  return(OM_stat);
}

end implementation EMSloopset;
