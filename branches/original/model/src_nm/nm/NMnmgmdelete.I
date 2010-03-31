/*
Delete my save state information and send wrt message GRowner.GRdelete.

History

	SM		??		Creation.
*/
class implementation NMnonmanigm;

method GRdelete (IGRlong *EMmsg; struct GRmd_env *env)
{
 IGRlong		sts;
 IGRushort	options = NMssiact_EraseFlps
                        | NMssiact_EraseVtx | NMssiact_DeactTopology
			| NMssiact_DeleteTopology;

 *EMmsg = EMS_S_Success;

 /* Delete my save state info.
 */
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, options, env, 
       NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;


 sts = om$send(mode = OM_e_wrt_message, 
              msg = message GRowner.GRdelete(EMmsg, env), targetid = my_id);

wrapup:
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.GRdelete");
return(sts);
}

method NDdelete(struct GRmd_env *md_env)
{
 IGRlong	sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;

 /* Send GRdrop to self. NDdelete should delete this node only and not
    everyting owned by this node.
 */
 sts = om$send(msg = message GRowner.GRdrop(&EMmsg, md_env), 
       targetid = my_id);

return(sts);

}

end implementation NMnonmanigm;
