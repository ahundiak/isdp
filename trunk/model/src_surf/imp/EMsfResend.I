/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
# ifndef OM_D_MACROS
# include "OMmacros.h"      /* NULL_OBJID */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* AND */
# endif

method EMresend (
    OM_S_OBJID objid;
    OMuword osnum;
    OM_E_WRT_FLAG wrt_flag;
    OM_p_MESSAGE sd_message
)
{
    int bool;

    bool = IF_NULL_OBJID (objid);

    return om$send (
        mode = wrt_flag,
        msg = sd_message,
        targetid = bool ? sender_id : objid,
        targetos = bool ? sender_os : osnum
    );
}

end implementation EMSsurface;
