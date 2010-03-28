/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GSadd 

Description
   This method is used to add an object to the current graphics set.

    *msg         IGRlong       return code 
    *obj_id      GRid          The object id of the object to be
                               added to the save set.
    *rp_relation IGRint        contains the relationship with the
                               right prism (i.e. inside, outside,
                               or overlap).
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
     msm          07/10/92    ANSI-C conversion.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"

from GRconnector import GRflexconn;

method GSadd (IGRlong *msg; struct GRid *obj_id; IGRint *rp_relation)
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           connect_flag;
IGRlong           index;
struct GRid       my_GRid;

   *msg = MSSUCC;
   index = OM_K_MAXINT;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   /*
    *  Add the object to the save set.
    */

   connect_flag = 1;    /* Override */
   om_msg = om$send(
            msg = message GRconnector.GRflexconn (&ret_msg, 
            &connect_flag, &my_GRid, &index, &index),
            targetid = obj_id->objid, targetos = obj_id->osnum);

   return (om_msg);
}

end implementation GRsvset;
