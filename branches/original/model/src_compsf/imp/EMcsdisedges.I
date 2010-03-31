/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"

method  EMdisplay_edges(IGRlong *EMmsg;
		struct GRmd_env *mod_info;
		IGRlong option;
                enum GRdpmode display_mode;
		IGRint 	*num_edges)


/*
Description

    This method passes the message down to its component surfaces.    
    The component surfaces display their edges (based on 'option'),
    on receipt of message and add the number of those edges to the
    accumulating argument *num_edges.

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV 	12/01/87	Creation
*/
{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_comps;
      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
    
 OM_stat = om$send(msg = message EMSsurface.EMdisplay_edges(EMmsg,
					mod_info,
					option,
					display_mode,
					num_edges),
			 p_chanselect = &to_comps);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMdisplay_edges")
  return (OM_stat);
}
end  implementation EMScompsurf;

