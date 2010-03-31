/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"

method EMgetowner(IGRlong *EMmsg; GRobjid *owner_id; 
                  IGRboolean immediate_owner) 
/*
Description
    This message will return the object id of the owner of the surface.
    If immediate_owner is TRUE then the owner on the to_owners channel will
    be returned.  Otherwise, the active owner will be returned (they may
    be the same).
    
Notes
    If the surface has no owner then NULL_OBJID will be returned.
    
History

09 Dec 1988 Noticed *EMmsg was not set in immediate case. 
            Changed implementation to return *EMmsg as follows:

            EMS_I_Found upon complete success.
            EMS_I_NotFound when returning NULL_OBJID or when
                failing upon the immediate case.
            Whatever EMSsurface.EMgetactiveid returns upon
                failure.

    DLB 09/28/88 Creation date.
*/
{
 IGRlong         OM_stat;
 OM_S_CHANSELECT to_owners;
 OMuword         dumosnum;

 *EMmsg = EMS_I_NotFound;

 to_owners.type = OM_e_addr;
 to_owners.u_sel.addr = &ME.GRconnector->to_owners;

 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP) 
 {
   if (immediate_owner)
   {
     OM_stat = om$get_objid_at_index(object = me,
                                     p_chanselect = &to_owners,
                                     index = 0,
                                     objidaddr = owner_id,
                                     osnumaddr = &dumosnum);
   }
   else
   {
     struct GRid active_GRid;

     OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                             &active_GRid, NULL),
                       p_chanselect = &to_owners);
     *owner_id = active_GRid.objid;
   }

   if (EMSokay (OM_stat) AND EMSokay (*EMmsg)) *EMmsg = EMS_I_Found;
 }
 else
 {
   OM_stat = OM_S_SUCCESS;
   *owner_id = NULL_OBJID;
 } 

 wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMgetowner")
   return(OM_stat);
}

end implementation EMSsubbs;
