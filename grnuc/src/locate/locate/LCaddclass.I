/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        LCaddclass
    
Description
        This function is used to add a category to the locate eligibility
        data maintained in the dpb.

History
        rc      ??/??/??    creation
        mrm     05/03/91    2.0.1 changes
        scw     07/13/92    Ansi conversion
*/

class implementation Root;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ex.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRdpb import GRputname;

IGRint LCadd_class (owner_key, properties, ascii_key, classlist, dpb_id, dpb_os)
IGRchar *ascii_key, *owner_key;
IGRint properties;
OM_S_CLASSLIST classlist;
OM_S_OBJID dpb_id;
OMuword dpb_os;
{
    IGRlong sts, msg;
    struct  var_list list[2];
    struct  GRelclass_a elclass;

    elclass.ascii_key = ascii_key;
    elclass.owner_key = owner_key;
    elclass.properties = properties;
    elclass.classlist = &classlist;

    list[0].var = DPB_ADD_CLASSLIST;
    list[0].var_ptr = (IGRchar *)&elclass;
    list[1].var = END_PARAM;

    if (dpb_id == NULL_OBJID)
    {
        sts = gr$set_inq(msg = &msg, set_inq = DPB_SET, var_list = list);
    }
    else
    {
        sts = om$send(msg = message GRdpb.GRputname(&msg, list),
                      senderid = NULL_OBJID,
                      targetid = dpb_id,
                      targetos = dpb_os);
    }
    return (sts & msg & 1);
}

end implementation Root;

