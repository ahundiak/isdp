/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"

method EMgetedges(IGRlong *EMmsg;
		   IGRlong option;
		   struct GRid **edges;
		   IGRint *buf_size,
			  *num_edges;
		   GRobjid **surf_list;
		   IGRint  **numed_list;
		   IGRint  *list_size,
			   *num_in_list)


/*
Description

    This method passes the message down to its component surfaces.    

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV 	09/01/87	Creation
*/
{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_comps;
      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
    
 OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
					option,
		   			edges,
					buf_size,
					num_edges,
					surf_list,
					numed_list,
					list_size,
					num_in_list),
			 p_chanselect = &to_comps);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMgetedges")
  return (OM_stat);
}
end  implementation EMScompsurf;
