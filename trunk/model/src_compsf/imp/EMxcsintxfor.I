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

 History     

        RC     11/29/88      Creation Date

*/
 
method EMxsec_int_xform(IGRlong *EMmsg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; IGRmatrix inv_matrix;
    GRobjid *newobjid; IGRboolean xform_thru_notification)
{
  OM_S_CHANSELECT    to_cmpnt_chan;
  IGRlong            OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = OPPmargs,
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat& *EMmsg), *EMmsg, EMS_E_SurfaceError,wrapup);

  *newobjid = my_id; 

  wrapup:
   EMWRAPUP (OM_stat, *EMmsg, "In EMSxscompsf.EMxsec_int_xform");
   return (OM_stat);
}

end implementation EMSxscompsf;
