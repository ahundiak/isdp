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
   This method perform copy process of EMSxscompsf class.
   It is assumed that this method will be invoked directly and not
   through the associated model. In such a case the copy should be in
   of class EMSgencompsf with childern of class EMSplane.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method GRcopy(
  IGRlong             *EMmsg;
  struct GRmd_env     *obj_mdenv; 
  struct GRmd_env     *new_mdenv;
  GRobjid             *newobjid)

{
  IGRlong          OM_stat, mthd_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * o Copy as my parent does.
   * o Change my and my childern class.
   */

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMScompsurf.GRcopy (&mthd_stat, 
                      obj_mdenv, new_mdenv, newobjid),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  OM_stat = om$send (msg = message EMSxsection.EMchange_class (
                      &mthd_stat, new_mdenv, newobjid),
                     targetid = *newobjid,
                     targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.GRcopy");
   return (OM_stat);
}


end implementation EMSxscompsf;
