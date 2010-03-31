class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRdrop                                                          |
 |                                                                           |
 | This method drops the EMdescribe object to it's graphic components.       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRdrop (IGRlong * msg; struct GRmd_env * mod_env)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRboolean      old_system_mode;
    
    *msg = MSSUCC;

    /*
     * Turn on the system mode. 
     */
    old_system_mode = EMdesc_set_system_mode (TRUE);
    
    /*
     * Delete the owner.
     */
    om_msg = om$send (msg = message GRowner.GRdelete_owner (msg, mod_env),
                      targetid = my_id);

    /*
     * Restore the system mode. 
     */
    EMdesc_set_system_mode (old_system_mode);
    
    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_REM_ENTRY, my_id, OM_Gw_current_OS, mod_env);
    }
    
    return (om_msg);
}

end implementation EMinstance;







