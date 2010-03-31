/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method makes the edge reversed. It simply sets the bit to
  indicate that the edge direction is opposite the direction of
  parametrization of its geometry(linear/bs) and reverses the bounds of the
  partedge
	If the edge has a topological partner then it toggles the 
  EMED_REVERSE_CONNECT bit on itself and the topological partner.

History
	SM	03/3/87		Creation date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"

method EMreverse(IGRlong *EMmsg)
{
   struct EMSedgebound 	temp;
   OM_S_CHANSELECT	to_common_edge;
   IGRlong		sts;
   OMuint		count;


   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
  
  if(ME.EMSedge->ed_props&EMED_REVERSED)
	ME.EMSedge->ed_props &= ~EMED_REVERSED;
  else
	ME.EMSedge->ed_props |= EMED_REVERSED;
  OM_BLOCK_MOVE(ME.EMSpartedge->boundary,&temp,sizeof(struct EMSedgebound));
  OM_BLOCK_MOVE(&ME.EMSpartedge->boundary[1],ME.EMSpartedge->boundary,
			sizeof(struct EMSedgebound));
  OM_BLOCK_MOVE(&temp,&ME.EMSpartedge->boundary[1],
			sizeof(struct EMSedgebound));

  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;
  sts = om$get_channel_count(object=me,p_chanselect=&to_common_edge,
				count = &count);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  if(count)
   {
     if(ME.EMSedge->ed_props & EMED_REVERSE_CONNECT)
	 ME.EMSedge->ed_props &= ~EMED_REVERSE_CONNECT;
     else
	 ME.EMSedge->ed_props |= EMED_REVERSE_CONNECT;
     sts = om$send(msg=message EMSedge.EMset_props
			(EMmsg,EMED_REVERSE_CONNECT,EMS_O_TOGGLE),
			p_chanselect = &to_common_edge);
   }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSpartedge.EMreverse");
  return(sts);

}


end implementation EMSpartedge;
