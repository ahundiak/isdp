/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"

method EMgetactiveid(IGRlong *EMmsg; struct GRid *active_id, *top_lm_id)
/*
Description
   This method will return the active state id and the top local mod id if
   the message originates below the active state AND top lm ids.

Return Values
   EMSS_S_Success if all is well

Notes
   This method will mainly be used be the local mod operations when
   it is operating at the surface level and needs to know the active
   solid state.

   The top_lm_id is used by the local mods to determine where to insert a
   local mod state.  

   This method will return garbage in the top_lm_id parameter if the message
   was originally sent to a state above the top lm stack (not originally to
   a local mod or solid, surface, or composite surface state). 

History
   DLB 11/27/90 If im not in active_path return NULL_OBJID.
   DLB 10/31/87 mod for version 1.1.0
   DLB 03/28/87 creation
*/
{
 IGRlong         OM_stat=OM_S_SUCCESS;
 IGRboolean      active_state, active_path; 


 *EMmsg = EMS_S_Success;

 if (top_lm_id)  /*I am the top lm until told otherwise.*/
 {
   top_lm_id->objid = my_id;
   top_lm_id->osnum = OM_Gw_current_OS;
 }

 /*ask myself if I am active*/
 OM_stat = om$send(msg = message EMSsurface.EMisactive(EMmsg, 
                         &active_state, &active_path),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 if (active_state)
 {
   /*I am the active state*/
   active_id->objid = my_id;
   active_id->osnum = OM_Gw_current_OS;
 }  
 else if (active_path)
 {
   OM_S_CHANSELECT to_owners;
   EMmake_chanselect(GRconnector_to_owners, &to_owners);
   OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg, active_id,
                           top_lm_id),
                     p_chanselect = &to_owners,
                     from = 0, to = 0);
   if(!(1 & OM_stat & *EMmsg)) goto wrapup;
 }                    
 else 
 {
   /*NOT IN ACTIVE PATH!*/
   active_id->objid = NULL_OBJID;
   active_id->osnum = OM_Gw_current_OS;

   if (top_lm_id)
   {
     top_lm_id->objid = NULL_OBJID;
     top_lm_id->osnum = OM_Gw_current_OS;
   }
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsurf.EMgetactiveid")
  return(OM_stat);
}
end implementation EMSsurface;


