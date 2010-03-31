/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	21-Jan-89	creation.
    RC  01-Mar-89   If the new edge is not a partedge, execute
                    EMSedge implementation only.
*/

class implementation EMSpartedge;

#include "EMS.h"

extern OMuword OPP_EMSpartedge_class_id;

method	EMreplace_edge(IGRlong *EMmsg;
		       GRobjid new_edge;
		       IGRboolean delete_old_edge)
{
 IGRlong		sts;
 OM_S_CHANSELECT	to_comps, to_owner;
 OMuword            new_ed_classid;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;


 /*
  * If the new edge is not a part edge, execute EMSedge implementation
  * only
  */

 sts = om$get_classid (objid = new_edge, p_classid = &new_ed_classid);
 EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

 if ( (sts = om$is_ancestry_valid (subclassid = new_ed_classid,
                           superclassid = OPP_EMSpartedge_class_id))
       == OM_S_SUCCESS)
 {

  /* Move the components channel and execute EMSedge implementation of the
     same message.
   */
  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
 
  if(delete_old_edge)
  {
   sts = om$send(msg = message Root.move_chan(to_comps, my_id,
                           OM_Gw_current_OS, to_comps),
                     targetid = new_edge, senderid = new_edge);
   EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  }
  else
  {
   GRobjid	child;

   sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
   EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
 
   sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &child), 
				p_chanselect = &to_comps, from = 0, to = 0);
   EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   sts = om$send(msg = message Root.connect(to_owner, NULL, new_edge, 
				OM_Gw_current_OS, to_comps, NULL), 
			senderid = new_edge, targetid = child);
   EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
  }

 } /* If new edge is a part edge */

  sts = om$send(mode = OM_e_wrt_message, 
			msg = message EMSedge.EMreplace_edge
				(EMmsg, new_edge, delete_old_edge), 
				targetid = my_id);
				
wrapup:
	return(sts);
}

end implementation EMSpartedge;
