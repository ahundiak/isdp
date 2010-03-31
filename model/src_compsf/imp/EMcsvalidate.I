/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSopt.h"

method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info; IGRchar *greom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)


/*
Description


Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV 			Creation
    SM	23-Jun-89	argument additions.
    WBC 22-Nov-93       Ignoring the return code OM_W_REJECTED_METHOD when
                        EMvalidate is sent to the owner since the owner could
                        be subclassed from GRgraphics but has not overridden
                        EMvalidate (e.g. GRsvset).  Fix for TR#119311382.
*/
{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_comps, to_owner;
 extern IGRboolean   IGEstop();
 IGRboolean	     continu = TRUE, undo = FALSE, from_comp = FALSE, 
                     from_own = FALSE;
 IGRushort	locopt = NULL;
     
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(!(continu = !(IGEstop()))) goto wrapup;
 if(!option) option = &locopt;

 EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 EMmake_chanselect(GRconnector_to_owners, &to_owner);

 /* If the message came from component, do not send back to it.
 */

 OM_stat = om$is_objid_on_channel(object_c = me, p_chanselect = &to_comps, 
           objid = sender_id);
 if(OM_stat == OM_S_SUCCESS) from_comp = TRUE;
 else
  {
   OM_stat = om$is_objid_on_channel(object_c = me, p_chanselect = &to_owner, 
           objid = sender_id);
   if(OM_stat == OM_S_SUCCESS) from_own = TRUE;
   else OM_stat = OM_S_SUCCESS;
  }

 /* Consider only the non subordinate edges for degeneracy tests, 
    common edge matching etc. If we set this option here, turn it off
    when it has served its purpose. If it came in set, leave it alone.
 */
 if(!from_comp)
  {
   if(!(*option & EMSvalidateNonSubEdge)) undo = TRUE;
   (*option) |= EMSvalidateNonSubEdge;
   OM_stat = om$send(msg = message GRgraphics.EMvalidate(EMmsg,
					mod_info,
					NULL,
					cancer,
					option, 
					objinfo, 
					ioptr),
			 p_chanselect = &to_comps);
   if(undo) (*option) &= ~EMSvalidateNonSubEdge; 			
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
   if( (*EMmsg == EMS_I_Interrupt) || (OM_stat == OM_I_STOP_SENDING))
     goto wrapup;
  }

 if(!from_own)
  {
   OM_stat = om$send(msg = message GRgraphics.EMvalidate(EMmsg, mod_info, 
             NULL, cancer, option, objinfo, ioptr), p_chanselect = &to_owner);
   if ((OM_stat == OM_W_UNKNOWN_MSG) ||
       (OM_stat == OM_W_REJECTED_METHOD))
    OM_stat = OM_S_SUCCESS;
  }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt)) 
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (OM_stat);
}
end  implementation EMScompsurf;

