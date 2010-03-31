/*
History
	SM	??		Creation.
	SM	06-Sept-91	If I am in the delete batch do not
				update.
*/
class implementation NMnonmanigm;

extern struct NMgmssi_cache NMnonmanigm_ssi_cache;
extern struct ext_list NDdelete;

method NDupdate (IGRint *EMmsg, cn_type, count; struct GRid list [];
		 IGRint *parent_state; struct GRid *context, *new_objid;
                 struct GRmd_env *md_env)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRvg_construct  construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;

 *EMmsg = EMS_S_Success;
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

 if(NDin_buffer(*new_objid, &NDdelete) != -1)
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = (IGRlong *) EMmsg;
 construct.env_info = &env;
 env = *md_env;

 sts = om$send(msg = message EMSassoc.EMget_construction_info((IGRlong *)EMmsg, &construct), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 NMnonmanigm_ssi_cache.elemid.objid = NULL_OBJID;
 NMnonmanigm_ssi_cache.is_valid  = FALSE;

 sts = om$send(msg = message NMnonmanigm.NMreexecute((IGRlong *)EMmsg, &construct, NULL), 
       targetid = my_id);
 
wrapup: 

if(1&*EMmsg&sts) *EMmsg = ND_COMP_SUCC;
else *EMmsg = ND_COMP_FAIL;

EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NDcompute_node");
 return(sts);
}

end implementation NMnonmanigm;
