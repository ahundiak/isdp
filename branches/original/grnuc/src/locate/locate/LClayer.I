/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        LClayer

Description
        This function gets the active layer list from the dpb and
        performs a logical "and" with that list and the list input to
        this function.  The results are returned in the input array. 

Synopsis
        IGRlong     layers[32]  I/O Layers
        OM_S_OBJID  module_id   I   Active module id
        OMuword     module_os   I   Active module object space number

History
        rc      07/20/87    Started documentation.
        mrm     05/18/90    2.0 changes
        scw     07/13/92    Ansi conversion
*/

class implementation Root;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"


#argsused
IGRint LClayer(layers, module_id, module_os)
IGRlong *layers;
OM_S_OBJID module_id;
OMuword module_os;
{
    IGRint ii;
    IGRlong mask[32], msg;
    struct var_list list[2];

    if (LCget_layer_check())
    {
        list[0].var = DPB_GET_LAYER;
        list[0].var_ptr = (char*)mask;
        list[1].var = END_PARAM;

        gr$set_inq(msg = &msg, var_list = list);

        for (ii = 0; ii < 32; ii++)
        {
            layers[ii] &= mask[ii];
        }
    }
    return (1);
}

end implementation Root;
