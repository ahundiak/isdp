/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"

from EMSsurface import EMpostdelete;

method EMtreecleanup(IGRlong *EMmsg; struct GRmd_env *md_env)

/*
Description
    This method will take care of deleteing all next states at the first
    state sent to and above.  This is done since any state deleted in the
    tree will cause all states above it to become invalid.

Return Values
    EMS_S_Success if all is well

Notes
    The protocol for the owners channel is that if there is a rigid conn
    then a flex conn will be 'on its on' so I don't tell it Im deleting

History
   DLB    01/09/86   creation date
   DLB    03/23/87   Revised for new class structure
   DLB    10/26/87   mod for version 1.1.0
   DLB    06/01/88   modified to send GRdelete to me.
*/

{
 IGRlong         OM_stat;
 OM_S_CHANSELECT to_owners, to_comps;
 struct GRid     my_GRid;
 IGRboolean      action;
 IGRushort mask;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 /*Make the channel selectors*/
 to_owners.type = OM_e_addr;
 to_owners.u_sel.addr = &ME.GRconnector->to_owners;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 /*Send the message up the tree*/
 OM_stat = om$send(msg = OPPmargs,
                   p_chanselect = &to_owners);
 if(!(1 & *EMmsg & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
 
 /*Dont check return codes of next two messages.*/
 /*Delete my ss info stuff*/
 om$send(msg = message EMSdpr.EMsavestatedelete(EMmsg, md_env, NULL),
         targetid = my_id);

 /*Delete my recompute info stuff*/
 om$send(msg = message EMSdpr.EMrecompinfodelete(EMmsg, md_env, NULL, NULL),
         targetid = my_id);

 /* Disconnect me from the component to ensure proper setting of RR bit.*/
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 OM_stat = om$send(msg= message GRconnector.GRdisconn(EMmsg, &my_GRid), 
                   p_chanselect = &to_comps);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Root delete me and my ssi and ri stuff.*/
  if (EMcheck_inhibit_postproc())
    {
    IGRlong msg_loc;

    om$send (msg = message EMSsurface.EMpostdelete (&msg_loc, 
     EMS_POST_NOCOMPONENTS, md_env, OPPmargs, NULL), targetid = my_id);

    EMrestore_postproc();
    }

/************
 OM_stat = om$send(msg = message Root.delete(NULL),
                   targetid = my_id);
 if (! (1 & OM_stat)) goto wrapup;
************/

 OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, md_env),
                   targetid = my_id);
 if (! (1 & OM_stat)) goto wrapup;

 wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMtreecleanup")
   return(OM_stat);
}

end implementation EMSdpr;
