/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRlocate

Description
   This method performs a locate operation on the fence object.

Arguments
   *cvl         GRlc_cvl       structure containing all locate info
   range_key    OM_p_KEY_DESC  range of object 

Notes
   The fence is only locable in the defining window or if the window
   id is a NULL_OBJID.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    10/05/86    Creation date.
   Gray Winn    10/07/88    Updated for message interception
   mrm          02/06/91    always return either OM_I_STOP_SENDING or
                            OM_S_SUCCESS to avoid problems with
                            premature termination of the rtree pass
                            during locate
   msm          07/09/92    ANSI-C conversion.
\*/

class implementation GRgsmgr;

#include "grimport.h"

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
IGRlong              om_msg;
unsigned int         count;
OM_S_OBJECT_LINKAGE  list;
OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_addr;
   chansel.u_sel.addr = &me->gra_gad;

   om_msg = om$get_channel_objects (object = me, p_chanselect = &chansel,
            list = &list, size = sizeof (OM_S_OBJECT_LINKAGE),
            count = &count);

   /*
    *  Compare the window id from the channel to the window id that
    *  the data point was given in.
    */

   if (((cvl->button.objid == list.S_objid) && 
        (cvl->button.osnum == list.osnum)) ||
        (cvl->button.objid == NULL_OBJID))
   {
      om_msg = GRpass_on_to_fence (OM_Gw_current_OS, my_id, OPPmargs);
   }

   if (om_msg != OM_I_STOP_SENDING) om_msg = OM_S_SUCCESS;

   return (om_msg);
} 
end implementation GRgsmgr;
