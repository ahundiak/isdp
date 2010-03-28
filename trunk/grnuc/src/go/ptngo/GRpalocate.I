/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRpa.GRlocate

Description
            This method disallows the location of the master element
        by keeping the header out of the locate stack unless placed there
        in the GRlocate-owner method.

History
        mrm     02/08/88    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "msdef.h"

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
    cvl->msg = MSSUCC;

    return (OM_S_SUCCESS);
}

end implementation GRpa;
