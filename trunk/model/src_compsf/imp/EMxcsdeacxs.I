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
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method EMdeact_xsection (
  IGRlong         *EMmsg; 
  IGRshort        *option;
  struct GRmd_env *md_env;
  GRobjid         **display_ids;
  IGRint          *display_count)
{
  enum  GRdpmode    display_mode = GRbe;
  IGRlong           OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                     &md_env->md_env.matrix_type, 
                     md_env->md_env.matrix, &display_mode,
                     &md_env->md_id),
                   targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);

  OM_stat = om$send (msg = message GRgraphics.GRdelete (EMmsg,
                      md_env),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMdeact_xsec");
   return (OM_stat);                                           
}

end implementation EMSxscompsf;
