/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

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
 
method GRxform(IGRlong *EMmsg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
  IGRmatrix          inv_matrix;
  IGRlong            OM_stat, rc;
  IGRshort           dim = 4;
  IGRboolean         status;
  extern IGRboolean  MAinvmx();  

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  status = MAinvmx (&rc, &dim, matrix, inv_matrix);
  EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  OM_stat = om$send (msg = message EMSxsection.EMxsec_int_xform(EMmsg, 
                      md_env, matrix_type, matrix, inv_matrix, newobjid, 
                      FALSE),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat& *EMmsg), *EMmsg, EMS_E_SurfaceError,wrapup);

  wrapup:
   EMWRAPUP (OM_stat, *EMmsg, "In EMSxsplane.GRxform");
   return (OM_stat);
}

end implementation EMSxsplane;
