/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"

method EMuv_transform (
        IGRlong                 *EMmsg;
        IGRdouble               matrix[16];
        struct EMSpartolbasis   *partolbasis;
        IGRshort                option;
        IGRchar                 *null_ptr1;
        IGRchar                 *null_ptr2)

/*
 Notes
        This method tranforms the loopset by incoming matrix.

History
        RC      04/29/87        Creation date
        RC      08/31/87        Modified the arguments and
                                the appropriate code.
*/

{
     IGRlong               OM_stat;
   IGRlong   mthd_stat;
  IGRushort     ls_props, lp_props, ed_props;
  OM_S_CHANSELECT       ls_lp_chan;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ls_lp_chan.type = OM_e_addr;
  ls_lp_chan.u_sel.addr = &ME.EMSloopset->to_loops;

  OM_stat = om$send (msg = message EMSboundary.EMuv_transform (
			&mthd_stat, matrix, partolbasis, option,
			null_ptr1, null_ptr2),
			p_chanselect = &ls_lp_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopError,wrapup);

  /*
   * check if I am nonmodifiable and natural or not
   */

  lp_props = ed_props = NULL;
  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
  
  OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                      &ls_props, &lp_props, &ed_props),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
	
    EMWRAPUP (*EMmsg, OM_stat, "In EMSloopset.EMuv_transform");
 
    return (OM_stat);

}

end implementation EMSloopset;
