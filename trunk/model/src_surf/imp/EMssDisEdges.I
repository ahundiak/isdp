/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSlmdef.h"
#include "godef.h"
#include "gocmacros.h"

from EMSboundary import EMget_edges;
from EMSedge import EMdisplay;

method  EMdisplay_edges(IGRlong *EMmsg;
		struct GRmd_env *mod_info;
		IGRlong option;
                enum GRdpmode display_mode;
		IGRint 	*num_edges)




/*
Description
    
	This method displays edges (based on an option) of the surface.
	It adds the number of edges displayed to (*num_edges).

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV	12/01/87	Creation.
    dhm 04/05/88    Added GR_NOTIFY_LISTENERS.
    AIC 06 Oct 91   Changed arguments to EMget_ele_header.
    NP  08/25/92    Modified for ANSI compliance. Changed "count" to "IGRuint".
*/

{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_loopset;
 struct GRid 	     *edges = NULL;
 IGRint 	     i, num_my_edges = 0, buf_size = 0;
 IGRuint	     count;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 OM_stat = om$get_channel_count(object = me,
                                 p_chanselect=&to_loopset,
                                 count=&count);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 if(!count)
 {
        OM_stat = om$send(msg=message EMSsubbs.EMmk_nat_bdry (EMmsg, 
                          &mod_info->md_env, NULL), 
                      targetid = my_id);
	EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	
 }

 OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                    MAXINT,
					option,
					&edges,
					&buf_size,
					&num_my_edges),
			 p_chanselect = &to_loopset);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 if (num_my_edges)
 {
	 struct DPele_header surface_ele_header;
	 GRrange             range;
	 struct GRsymbology  symb;
	 struct IGResqbs     bsqsurf;
	 union IGRele_attr   ele_spec_att;

      ele_spec_att.bsqsurf = &bsqsurf;
      OM_stat = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg,
		    NULL,
                    &mod_info->md_env,
		    NULL,
		    &surface_ele_header,
		    range,
                    &symb.display_attr,
		    ele_spec_att, NULL),
                targetid = my_id);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

      for (i=0; i<num_my_edges; i++)
      {
          OM_stat = om$send (msg = message EMSedge.EMdisplay (EMmsg,
			    &surface_ele_header,
			    &mod_info->md_env.matrix_type,
			    mod_info->md_env.matrix,
                            &display_mode, NULL,
                            EMS_EDGE_W_VERTICES, NULL),
                         targetid = edges[i].objid);
          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
      }
      (*num_edges)+= num_my_edges;
 }

 wrapup:

  if (edges) om$dealloc(ptr = edges);

  GR_NOTIFY_LISTENERS(EMmsg, &OM_stat, GR_DISPLAYED);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMdisplay_edges")
  return (OM_stat);
}
end  implementation EMSsubbs;
