class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"

/* # include "grdef.h" */
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "godef.h"
#include "gocmacros.h"

method GRcopy(
    IGRlong         *msg;
    struct GRmd_env *obj_mdenv;
    struct GRmd_env *new_mdenv;
    GRobjid         *newobjid)

/*
NOTES

     Upon exit the completion code will be one of
        - MSSUCC if successful
        - MSFAIL(severe) if failure

History
	
    RC  11/18/86 : Creation date
    rlw 05/08/87 : Modified channel name
    DLB 10/28/87 : Modified channel for version 1.1.0
    dhm 04/05/88 : Added GR_NOTIFY_LISTENERS
    RC  05/10/88 : Clear GR_RIGID_RELATIONSHIP property of the
                   copied composite curve.
    pp  11/10/88 : Added code to support active owners.


Abstract

	This method copies a composite curve and its members
    to the object space described in the structure 
    new_mdenv. The copy maintains the same linkages
    that the original contained.

*/		

{

  OM_S_CHANSELECT   composite_chan;
  struct GRid       composite_GRid;
  IGRlong           i, OM_stat;
  OMuint            count;
  GRobjid           compid;
  IGRshort          props;
  IGRboolean        clear_bits;
  
  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;

  /* 
   * construct and copy the composite curve object
   */
	
  OM_stat = om$construct_and_copy(object = me,
                      osnum = new_mdenv->md_id.osnum,
                      p_objid = newobjid);
  EMerr_hndlr (!(1&OM_stat), *msg, MSFAIL, wrapup);

  /*
   * clear GR_RIGID_RELATIONSHIP bit
   */

  clear_bits = 0;
  props = GR_RIGID_RELATIONSHIP;
  OM_stat = om$send(msg = message GRvg.GRchgprops(msg,
                     &clear_bits, &props),
       	  targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
  EMerr_hndlr(!(1&OM_stat), *msg, MSFAIL, wrapup);
	
  OM_stat = om$get_channel_count(
                                 object = me,
                                 p_chanselect = &composite_chan,
                                 count = &count);
  EMerr_hndlr (!(1&OM_stat),*msg,MSFAIL,wrapup);

  composite_GRid.objid = *newobjid;
  composite_GRid.osnum = new_mdenv->md_id.osnum;

  for (i = 0; i < count; i++)
  {
   OM_stat = om$send(msg = message GRgraphics.GRcopy (msg,
                           obj_mdenv, new_mdenv, &compid),
                     p_chanselect = &composite_chan,
                     from = (int) i, to = (int) i);
   EMerr_hndlr (!(1&OM_stat&*msg),*msg,MSFAIL,wrapup);

   OM_stat = om$send(msg = message GRconnector.GRrigidconn(msg,
                           &composite_GRid, &i),
                     targetid = compid,
                     targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr (!(1 & OM_stat & *msg), *msg, MSFAIL, wrapup);

  } /* for (i = 0; i < count; i++) */

/*
 * Begin code to support active owner
 */

  OM_stat = om$send (msg = message GRowner.GRadd_to_active_owner(msg,
                     new_mdenv),
                     targetid = composite_GRid.objid,
                     targetos = composite_GRid.osnum);
  EMerr_hndlr (!(1 & OM_stat & *msg), *msg, MSFAIL, wrapup);

/* end */

wrapup:

    EMWRAPUP (*msg, OM_stat, "In EMSsurface.GRcopy");

    GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_COPIED);

	return(OM_stat);
}

end implementation GRcompcurve;
