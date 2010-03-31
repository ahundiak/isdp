class implementation NMvertex;

#include "NMmsg.h"
#include "msdef.h"
#include "msmacros.h"


extern short NMvertex_locatable;

method GRchgprops(IGRlong *EMmsg; IGRshort *action; IGRshort *props)
{
 IGRlong 	sts = OM_S_SUCCESS;

 *EMmsg = EMS_S_Success;

 /* If attempting to turn locatable property on, refuse to do it.
 */
 if( !NMvertex_locatable && (*action == TRUE) && (*props & GRIS_LOCATABLE))
  {
   ex$message(msgnumb = NM_I_VtxNonLocatable)
   sleep(4);
  }
 else
  sts = om$send(mode = OM_e_wrt_message, msg = message GRvg.GRchgprops
	(EMmsg, action, props), targetid = my_id);

return(sts);

}

end implementation NMvertex;
