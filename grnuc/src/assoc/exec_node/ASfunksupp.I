class implementation ASnode;

ASredirect_msg (mess,chan_addr,send_id)
OM_S_MESSAGE *mess;
OM_p_CHANNEL_HDR *chan_addr;
OM_S_OBJID send_id;
{
 OM_S_CHANSELECT chan;
 IGRlong status;
   
 chan.type = OM_e_addr;
 chan.u_sel.addr = chan_addr;

 status = om$send( mode = OM_e_wrt_object,  p_chanselect = &chan,
	           senderid = send_id, msg = mess);
 return(status);
}

end implementation ASnode;
