/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "OMminimum.h"
#include "godef.h"
#include "gocmacros.h"

method EMmovesurfs (IGRlong *EMmsg; struct GRid *prim_id;
                    struct GRmd_env *env)
/*
Description
    if prim_id != NULL_OBJID
       This method will move me from my current rigid owner to the prim_id
       object.
    else
       Only disconnect from my owner and return my id in prim_id param.

Return values 
    EMS_S_Success is returned if all is well.
    if single surf state tree then return my GRid in prim_id structure.

Change history:
    DLB 10/31/87 Rewrote for version 1.1.0
    DLB 4/28/87 Creation.
    dhm 4/06/88 Added GR_NOTIFY_LISTENERS.
    SM  13-Jun-89 The surface used to connect to the new primitive always
		  at index 0. This used to transpose the ordering of the
		  leaf surfaces in the new primitive. Changed this to
		  connect the surface at the last index.
*/
{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT to_owners;
 struct GRid     owner_GRid;  

      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 /*I assume that if I have a rigid owner it is a subclass of EMScomposite*/
 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
 {
   OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners);
   if (! (1 & OM_stat)) goto wrapup;

   OM_stat = om$get_objid_at_index(object = me,
                                   p_chanselect = &to_owners,
                                   index = 0,
                                   objidaddr = &owner_GRid.objid,
                                   osnumaddr = &owner_GRid.osnum);
   if (!(1 & OM_stat)) goto wrapup;                                   

   OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, 
                           &owner_GRid),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 if (prim_id->objid != NULL_OBJID)
 {
   IGRlong     stupid_index;   /*DECL*/

   /*Connect me to the new owner*/
   stupid_index = MAXINT /*0*/;
   OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg, 
                           prim_id, &stupid_index),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else 
 {
   /*Tell the world I am the new primitive*/
   prim_id->objid = my_id;
   prim_id->osnum = OM_Gw_current_OS;  
 }

 wrapup:
  GR_NOTIFY_LISTENERS(EMmsg, &OM_stat, GR_CHANNEL_USED);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMmovesurfs")
  return (OM_stat);
}
end  implementation EMSsubbs;
