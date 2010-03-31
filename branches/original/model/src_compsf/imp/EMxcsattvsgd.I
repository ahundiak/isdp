/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"

/*
 DESCRIPTION
   This method attaches a view specific graphics data object to
   each of the cross section planes owned by this cross section composite
   surafce.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method EMattach_vsgd (
       IGRlong          *EMmsg;
       struct GRid      *vd_wn_GRid)
{
  OM_S_CHANSELECT  to_cmpnt_chan;
  IGRlong          OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = OPPmargs,
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMattach_vsgd");
   return (OM_stat);
  
}

end implementation EMSxscompsf;
