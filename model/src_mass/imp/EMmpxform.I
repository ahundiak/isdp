/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

# include "EMS.h"
# include "gocmacros.h"
#include "msdef.h" 
#include "msmacros.h"
#include "ECmsg.h"

/*

 History     

        gupta     08/02/89      Creation Date

*/
 
method GRxform (IGRlong         *EMmsg;
                struct GRmd_env *md_env;
                IGRshort        *matrix_type;
                IGRmatrix       matrix;
                GRobjid         *newobjid)
{
  IGRlong            stat_OM;
 
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ex$message(msgnumb = EMS_I_WarnDesigAssocTrRest)

   EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.GRxform");
   return (stat_OM);
}

end implementation EMSmassprop;
