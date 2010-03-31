/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "godef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSprop.h"
#include "stdio.h"

from EMSdpr import EMget_dpr_props;

extern OMuword OPP_EMScompsurf_class_id, OPP_EMSdpr_class_id;

method EMisactive(IGRlong *EMmsg; IGRboolean *active_state, *active_path)
/*
Description
   This method should be sent to an object indicating a state on the 
   state tree.  The method is used to determine if a particular state is
   active.

Return Values
   EMS_S_Success if all is well

   active_state - TRUE if state represented by the object is active.
   active_path - TRUE is state represented by the object is in active path.


History
   DLB 04/20/90 Reset stat in om$get_classid class due to unknown objects.
   DLB 10/31/87 modified for version 1.1.0
   AIC 8/x/87 added group check
   DLB 4/1/87 creation
*/
{
 IGRlong         OM_stat;     /* method return status      */
 OM_S_CHANSELECT to_owners;  
    

 *EMmsg = EMS_S_Success;                  /* initialize messages      */
 OM_stat = OM_S_SUCCESS;

 /*I am the active state unless convinced otherwise*/
 *active_state = TRUE;

 if (active_path)
   /*Since I am a primitive I am always in the active path.*/
   *active_path = TRUE;

 /*If I have a rigid owner then see if its a subclass of composite surface.
  * If I have no rigid owner then I am active.
  */
 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
 {
   GRobjid ownerid;                   /*DECL*/
   OMuword owner_classid, dumosnum;
   
   to_owners.type = OM_e_addr;
   to_owners.u_sel.addr = &ME.GRconnector->to_owners;

   OM_stat = om$get_objid_at_index(object = me,
                                   p_chanselect = &to_owners,
                                   index = 0,
                                   objidaddr = &ownerid,
                                   osnumaddr = &dumosnum);
   if (OM_stat == OM_E_INVINDEX)
   {
     ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;
     fprintf(stderr,"Composite %d has incorrect rigid owner bit. Repaired.\n",
             my_id);
     OM_stat = OM_S_SUCCESS;
     *EMmsg = EMS_S_Success;
     goto wrapup;
   }

   OM_stat = om$get_classid(objid = ownerid,
                            p_classid = &owner_classid);
   if (!(1 & OM_stat))
   {
     /*Possible unknown class; I am active.*/
     OM_stat = OM_S_SUCCESS;
     goto wrapup;
   }

   OM_stat = om$is_ancestry_valid(subclassid = owner_classid,
                                  superclassid = OPP_EMScompsurf_class_id);
   if (!(1 & OM_stat))
   {
     /*Possible unknown class; I am active.*/
     OM_stat = OM_S_SUCCESS;
     goto wrapup;
   }

   if (owner_classid == OPP_EMScompsurf_class_id ||
       OM_stat != OM_I_INVANCESTRY)   
   {
     /*Its a composite object, now get its dpr type properties.
      * If it doesn't understand the message then I am not active since
      * my owner is a composite (non dpr) object.
      */
     IGRushort props = NULL;
    
     OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                             &props), 
                       targetid = ownerid);
     if (! (1&OM_stat&*EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;

     if (OM_stat == OM_W_UNKNOWN_MSG)
     {
       /*I know its a solid or composite surface so now I'm convinced that
        * I'm not active. 
        */
       *active_state = FALSE; 
       OM_stat = OM_S_SUCCESS;
     }
     else if (props & EMSIS_ACTIVE_PATH) 
     {
       /*I am a primitive owned by a dpr who is part of the active path so
        * I know I am NOT active.
        */
       *active_state = FALSE;
     }
   }
 }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMisactive")
  return(OM_stat);
}

end implementation EMSsurface;
