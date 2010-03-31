/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdumedge;

method EMsend_dummy_edge(IGRlong *EMmsg;
			 GRobjid sender_obj;
			 OM_p_MESSAGE messg;
			 IGRboolean *dummy_edge_found)
{
  IGRlong sts;
  
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  *dummy_edge_found = TRUE;

/*  if(*messg != OM_GS_NULL_MESSAGE) -### USING memcmp() INSTEAD - Ashok */

/*  This compares padding, and p_arglist, which is itself a pointer. Modified to
    compare fields directly. p_arglist is ignored. Allen I Clark

    if( memcmp( (char *) messg, (char *) OM_Gp_NULL_MESSAGE, 
           sizeof(struct OM_sd_message)) )
*/

    if((messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.DefClassid) ||
       (messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.ReqClassid) ||
       (messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.FuncIndex) ||
       (messg->size != OM_GS_NULL_MESSAGE.size))
    sts = om$send(msg = messg, senderid = sender_obj, targetid = my_id);

wrapup:

	EMWRAPUP(*EMmsg, sts, "In EMSdumedge.EMsend_dummy_edge");
	return(sts);
}

end implementation EMSdumedge;
