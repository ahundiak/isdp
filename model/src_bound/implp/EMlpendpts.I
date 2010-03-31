/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method gives the endpoints of a loop in parametric space.
  The end points are determined based on the direction of the loop.
  The end points are determined as follows-
    loop reversed?	begin			end
    --------------      -----			---
	FALSE		begin of edge0		end of last edge
	TRUE		begin of last edge	end of edge 0
	The parameter values for the end points are also returned.If not
  required, NULL can be passed.

History
	SM	03/07/87	Creation date
*/
  

class implementation EMSloop;

#include "EMS.h"
#include "emsmacros.h"

from EMSedge import EMendpts;

method EMendpts(IGRlong *EMmsg;IGRdouble *begin_pt, *end_pt;
		struct EMSedgebound *begin_param,*end_param)
{
  IGRlong sts;
  OMuint num_edges;
  OM_S_CHANSELECT edge_channel;
  
  edge_channel.type = OM_e_addr;
  edge_channel.u_sel.addr = &ME.EMSbd_owner->to_comps;

  sts = om$get_channel_count(object = me,
                             p_chanselect = &edge_channel,
                             count = &num_edges);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  if(num_edges == 1)
  {
    /*
     * There is only one edge: get its endpoints.
     */
    sts = om$send(msg = message EMSedge.EMendpts(EMmsg,begin_pt,end_pt,
				begin_param,end_param,NULL),
                  p_chanselect = &edge_channel);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
  }
  else
  {
      if(ME.EMSloop->lp_props & EMLP_REVERSED)
      {
	sts = om$send(msg = message EMSedge.EMendpts
				(EMmsg,begin_pt,NULL,begin_param,NULL,NULL),
                      p_chanselect = &edge_channel,
                      from = num_edges - 1,to = num_edges - 1);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	sts = om$send(msg = message EMSedge.EMendpts
				(EMmsg,NULL,end_pt,NULL,end_param,NULL),
                      p_chanselect = &edge_channel,from = 0,to = 0);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      }
      else
      {
	sts = om$send(msg = message EMSedge.EMendpts
				(EMmsg,begin_pt,NULL,begin_param,NULL,NULL),
                      p_chanselect = &edge_channel,from = 0,to = 0);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	sts = om$send(msg = message EMSedge.EMendpts
				(EMmsg,NULL,end_pt,NULL,end_param,NULL),
                      p_chanselect = &edge_channel,
                      from = num_edges - 1,to = num_edges - 1);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      }


  }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMendpts")
  return(OM_S_SUCCESS);
}

end implementation EMSloop;
