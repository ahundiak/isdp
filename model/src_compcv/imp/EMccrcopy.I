/*
  DESCRIPTION

    The same as copy, except the GRNOT_IN_RTREE bit in the graphic-object
    is honored.

  HISTORY

    SS  :  06/22/89  :  Creation. This method has the same as GRcopy
                        except for the message send to the children,
                        which is GRrcopy instead of GRcopy.
*/

class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "godef.h"
#include "gocmacros.h"

method GRrcopy (IGRlong *msg; struct GRmd_env *obj_mdenv;
                struct GRmd_env *new_mdenv; GRobjid *newobjid)
{
  OM_S_CHANSELECT   composite_chan;
  struct GRid       composite_GRid;
  IGRlong           i, OM_stat;
  OMuint            count;
  GRobjid           compid;
  IGRshort          props;
  IGRboolean        clear_bits;
  
  *msg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /* 
   * construct and copy the composite curve object
   */
	
  OM_stat = om$construct_and_copy(object = me,
                      osnum = new_mdenv->md_id.osnum,
                      p_objid = newobjid);
  EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

  /*
   * clear GR_RIGID_RELATIONSHIP bit
   */

  clear_bits = 0;
  props = GR_RIGID_RELATIONSHIP;
  OM_stat = om$send(msg = message GRvg.GRchgprops(msg,
                     &clear_bits, &props),
       	  targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr(!(1&OM_stat&*msg), *msg, EMS_E_CurveError, wrapup);

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
  EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
	
  OM_stat = om$get_channel_count(
                                 object = me,
                                 p_chanselect = &composite_chan,
                                 count = &count);
  EMerr_hndlr (!(1&OM_stat),*msg,EMS_E_OMerror,wrapup);

  composite_GRid.objid = *newobjid;
  composite_GRid.osnum = new_mdenv->md_id.osnum;

  for (i = 0; i < count; i++)
  {
   OM_stat = om$send(msg = message GRgraphics.GRrcopy (msg,
                      obj_mdenv, new_mdenv, &compid),
                     p_chanselect = &composite_chan,
                     from = (int) i, to = (int) i);
   EMerr_hndlr (!(1&OM_stat&*msg),*msg,EMS_E_CurveError,wrapup);

   OM_stat = om$send(msg = message GRconnector.GRrigidconn(msg,
                      &composite_GRid, &i),
                     targetid = compid,
                     targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr (!(1 & OM_stat & *msg), *msg, EMS_E_Fail, wrapup);

  } /* for (i = 0; i < count; i++) */

/*
 * Begin code to support active owner
 */

  OM_stat = om$send (msg = message GRowner.GRadd_to_active_owner(msg,
                     new_mdenv),
                     targetid = composite_GRid.objid,
                     targetos = composite_GRid.osnum);
  EMerr_hndlr (!(1 & OM_stat & *msg), *msg, EMS_E_CurveError, wrapup);

/* end */

wrapup:

    EMWRAPUP (*msg, OM_stat, "GRcompcv.GRrcopy");

    GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_COPIED);

	return(OM_stat);
}

end implementation GRcompcurve;


