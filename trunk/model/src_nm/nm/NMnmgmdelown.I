class implementation NMnonmanigm;

method GRdelete_owner (IGRlong *EMmsg; struct GRmd_env *env)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid 		nmtpid, my_GRid, junk;
 IGRlong 		locmsg;
 
 *EMmsg = EMS_S_Success;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 sts = NMcreate_nmtp(EMmsg, &my_GRid, env, &nmtpid, NULL, NMcrtnmtp_QueryOnly,
       NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(*EMmsg != EMS_I_Fail)
  om$send (msg = message NDnode.NDmove_to_root(&locmsg, &junk, env),
	  targetid = nmtpid.objid);

 sts = om$send(mode = OM_e_wrt_message, msg = message GRowner.GRdelete_owner
       (EMmsg, env), targetid = my_id);

wrapup:
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.GRdelete_owner");
return(sts);
}

end implementation NMnonmanigm;
