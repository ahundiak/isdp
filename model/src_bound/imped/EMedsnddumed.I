/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "OMmacros.h"

extern OMuword OPP_EMSdumedge_class_id;

method EMsend_dummy_edge(IGRlong *EMmsg;
			 GRobjid sender_obj;
			 OM_p_MESSAGE messg;
			 IGRboolean *dummy_edge_found)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_owners;
  IGRint		i;
  OMuint                count;
  OMuword		owner_classid, owner_os;
  GRobjid		owner_id;


  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *dummy_edge_found = FALSE;

  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.EMSedge->to_owner;

  sts = om$get_channel_count(object = me, p_chanselect = &to_owners, 
			     count = &count);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  for(i=0; (i<count) && (!(*dummy_edge_found)); i++)
   {
     owner_id = NULL_OBJID;
     
     sts = om$get_objid_at_index(object = me, p_chanselect = &to_owners, 
				 index = i, objidaddr = &owner_id, 
				 osnumaddr = &owner_os);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

     /*****************************
     sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &owner_id), 
			p_chanselect = &to_owners, from=i, to=i);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     *****************************/

     if(IF_NULL_OBJID(owner_id)) continue;

     sts = om$get_classid(objid = owner_id, p_classid = &owner_classid);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
     if(owner_classid == OPP_EMSdumedge_class_id)
      {
	*dummy_edge_found = TRUE;
/*	if(*messg != OM_GS_NULL_MESSAGE) ### USING memcmp() INSTEAD - Ashok */
 
/*  This compares padding, and p_arglist, which is itself a pointer. Modified to
    compare fields directly. p_arglist is ignored. Allen I Clark

    if( memcmp( (char *) messg, (char *) OM_Gp_NULL_MESSAGE, 
           sizeof(struct OM_sd_message)) )
*/

    if((messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.DefClassid) ||
       (messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.ReqClassid) ||
       (messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.FuncIndex) ||
       (messg->size != OM_GS_NULL_MESSAGE.size))
	   sts = om$send(msg = messg, targetid = owner_id, 
			 senderid = sender_obj);
      }
   }

wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMSedge.EMsend_dummy_edge");
	return(sts);
}

end implementation EMSedge;
