/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"

method EMuv_transform (
        IGRlong                 *EMmsg;
        IGRdouble               matrix[16];
        struct  EMSpartolbasis  *partolbasis;
        IGRshort                option;
        IGRchar                 *null_ptr1;
        IGRchar                 *null_ptr2)

/*
 Notes
        This method tranforms the loop by incoming matrix.
        And then updates its range.

History
        RC      04/29/87        Creation date
        RC      08/31/87        Modified the arguments and
                                the appropriate code.

*/

{
  IGRlong             OM_stat;
  IGRlong             mthd_stat;
  IGRushort   ls_props, lp_props, ed_props;
  OM_S_CHANSELECT     lp_ed_chan, to_inner;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  lp_ed_chan.type = OM_e_addr;
  lp_ed_chan.u_sel.addr = &ME.EMSbd_owner->to_comps;

  OM_stat = om$send (msg = message EMSboundary.EMuv_transform (
                      &mthd_stat, matrix, partolbasis, option,
                       null_ptr1, null_ptr2),
                     p_chanselect = &lp_ed_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_EdgeError,wrapup);

  /*
   * pass the message down to my inner loops, if any.
   */

  to_inner.type = OM_e_addr;
  to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  OM_stat = om$send (msg = message EMSboundary.EMuv_transform (
                      &mthd_stat, matrix, partolbasis, option,
                       null_ptr1, null_ptr2),
                     p_chanselect = &to_inner);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_EdgeError,wrapup);
  
  /*
   * update my range
   */

  OM_stat = om$send (msg = message EMSloop.EMsetrange ( &mthd_stat),
			targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopError,wrapup);

  /* 
   * check if I am a natural loop or not.
   */

  ls_props = ed_props = NULL;
  lp_props = EMLP_NATURAL;
  
  OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                      &ls_props, &lp_props, &ed_props),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
wrapup:
	
    EMWRAPUP (*EMmsg, OM_stat, "In EMSloop.EMuv_transform");
 
    return (OM_stat);

}
end implementation EMSloop;
