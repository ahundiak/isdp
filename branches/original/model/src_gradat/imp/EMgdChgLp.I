/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
/*
History

    28 Apr 88   AIC     Change EMFRT_UPTODATE to EMGD_UPTODATE.
    12/08/87    RC      Creation Date
*/

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE    */
# endif

# include "emsdef.h"

method EMchangeLoop(IGRlong *EMmsg; GRobjid loop_id)
{
  IGRlong           sts;
  OM_S_CHANSELECT   to_requesters, to_GD;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  to_requesters.type = OM_e_addr;
  to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
  sts = EMmake_chanselect (EMSrequester_to_helpers, &to_GD);
  if(! (1 & sts)) goto wrapup;

  /*
   * Disconnect the old loop
   */
  sts = om$send(msg = message Root.range_disconnect(to_requesters, 1, 1),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;

  /*
   * Connect the new loop
   */
  sts = om$send(msg = message Root.connect(to_GD, 1, my_id,
                OM_Gw_current_OS, to_requesters, 0), targetid = loop_id);
  if(! (1 & sts)) goto wrapup;

  me^^EMShelper.props &= ~EMGD_UPTODATE;

wrapup:
  EMSmsgReport(sts, "EMSgradata.EMchangeLoop", FALSE);
  return(sts);
}

end implementation EMSgradata;
