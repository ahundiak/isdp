/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdvgrgrp;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "OMmacros.h"
#include "csmacros.h"

method GRrigidconn ( IGRlong *msg; 
                     struct GRid *owners_id; 
                     IGRlong *owners_index )
{
    IGRlong     om_msg;
    GRclassid   owners_classid;
    GRclassid   dp_classid;

    om$get_classid ( osnum = owners_id->osnum, 
                     objid = owners_id->objid,  
                     p_classid = &owners_classid );

    om$get_classid ( classname = "GRdsborder",
                     p_classid = &dp_classid );

    if (dp_classid == owners_classid) 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRconnector.GRrigidconn ( msg, 
                                                                   owners_id, 
                                                                   owners_index ),
                           targetid = my_id);
    }
    else 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRgrgrp.GRrigidconn ( msg, 
                                                               owners_id, 
                                                               owners_index ),
                           targetid = my_id);
    }

    return (om_msg);
}
end implementation GRdvgrgrp;
