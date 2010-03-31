/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

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
# include "gocmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

/*
 DESCRIPTION
   This method has been overridden to preclude the mass-prop object from
   being copied on its own.
 
 HISTORY     

        gupta     08/03/89      Creation Date

*/

method GRcopy (IGRlong             *EMmsg;
               struct GRmd_env     *obj_mdenv; 
               struct GRmd_env     *new_mdenv;
               GRobjid             *newobjid)

{
  IGRlong          stat_OM;

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ex$message(msgnumb = EMS_I_WarnDesigAssocCpRest)

   EMWRAPUP (*EMmsg, stat_OM, "In EMSmassprop.GRcopy");
   return (stat_OM);
}



end implementation EMSmassprop;
