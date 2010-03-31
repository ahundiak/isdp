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
   This method returns the edges of the cross section composite surface
   that are associated to the model's surfaces.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method EMget_associated_edges (
        IGRlong            *EMmsg;
        GRobjid            **act_eds, **inact_eds;
        IGRint             *num_act_eds, *num_inact_eds,
                           *act_eds_arrsz, *inact_eds_arrsz;
        IGRushort  options;
        IGRint             tree_depth)
{
  OM_S_CHANSELECT  to_cmpnt_chan;
  IGRlong          OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (--tree_depth)
  {
   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = om$send (msg = OPPmargs,
                      p_chanselect = &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

  } /* if (--tree_depth) */

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMget_associated_edges");
   return (OM_stat);
  
}

end implementation EMSxscompsf;
