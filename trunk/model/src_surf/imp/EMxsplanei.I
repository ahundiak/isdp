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
# include "EMSobjmgrdef.h"
# include "EMSobjmgr.h"

/*
 DESCRIPTION
   This method disable smooth edges of a cross section.
   If the cross section has only one plane, there will not be any
   smooth edges and thus nothing needs to be done.
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method EMconnect_edges (
       IGRlong         *EMmsg;
       struct GRmd_env *md_env)
{
  *EMmsg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

/*
 * I am active or inactive is decided by my owner.
 * Therefore, I do not need to do anything.
 */

method EMget_active_inactive_sfs (IGRlong *EMmsg; 
        GRobjid       **active_sf_ids;
        IGRint        *num_active_sfs;
        IGRint        *active_sf_arrsz;
        GRobjid       **inactive_sf_ids;
        IGRint        *num_inactive_sfs;
        IGRint        *inactive_sf_arrsz)
{
 *EMmsg = EMS_S_Success;
 return (OM_S_SUCCESS);
}        
                           

end implementation EMSxsplane;
