/*
Name
        GRsetinq

Description

History
        pth     ??/??/??    creation
        mrm     05/01/91    2.0.1 changes
*/

class implementation Root;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "gr.h"
#include "grdpbdef.h"

from GRdpb import GRgetname, GRputname;

IGRint GRsetinq (msg, var_list, set_inq)
IGRlong *msg;
struct var_list *var_list;
IGRint set_inq;
{
    IGRlong sts;
    OMuword dpb_os;
    OM_S_OBJID dpb_id;
    OM_S_MESSAGE *p_message;

    /* get the objid of the dpb  */

    GRget_dpb_objid(&dpb_id, &dpb_os);

    /* decide which message to send */

    if (set_inq == DPB_INQ)
    {
        p_message = message GRdpb.GRgetname(msg, var_list);
    }
    else
    {
        p_message = message GRdpb.GRputname(msg, var_list);
    }

    /* send the message */

    sts = om$send(msg = p_message,
                  senderid = NULL_OBJID,
                  targetid = dpb_id,
                  targetos = dpb_os);
    return(sts);
}

end implementation Root;
