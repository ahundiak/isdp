/*
History
	SM	??		Creation.
	SM	06-Sept-91	If I am in the delete batch do not
				update.
*/
class implementation NMinters;

extern struct ext_list NDdelete;
from NMnonmanigm import NMprop, NMSSI_action;

method NDupdate (IGRint *EMmsg, cn_type, count; struct GRid list [];
		 IGRint *parent_state; struct GRid *context, *new_objid;
                 struct GRmd_env *md_env)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRvg_construct  construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;
 OM_S_CHANSELECT	to_children;
 OMuint			count = 0;
 IGRint			i, j, ndbufsize = 0, num_all_nmnodes = 0;
 struct GRid		nmGRid, *all_nmnodes = NULL;
 IGRushort ssiopt = NMssiact_EraseFlps | NMssiact_DeactTopology |
   	                     NMssiact_EraseVtx, nmprop;
      


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

 sts = om$send(msg = message EMSassoc.EMget_construction_info((IGRlong *) EMmsg, &construct), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 sts = EMmake_chanselect(NDchildren_children, &to_children);
 if (!(1&sts)) goto wrapup;
 sts = om$get_channel_count(object = me, p_chanselect = &to_children, 
           count = &count);
 if(!(1&sts)) goto wrapup;

  /* Unevaluate each NM tree dependent upon me (if it has not been already
     done). This needs to happen before my instance data is updated
     to the new intersection and the old data is lost.
  */
 for(i=0; i<count; i++)
  {
   sts = om$get_objid_at_index(object = me, p_chanselect = &to_children, 
         index = i, objidaddr = &nmGRid.objid, osnumaddr = &nmGRid.osnum);
   if(!EFisAncestryValid((IGRlong *) EMmsg, nmGRid.objid, nmGRid.osnum, 
       OPP_NMnonmanigm_class_id, FALSE)) continue;

   sts = om$send(msg = message NMnonmanigm.NMprop((IGRlong *) EMmsg, NMprop_Get, 
         &nmprop), targetid = nmGRid.objid, targetos = nmGRid.osnum);
   if(!(1&sts&*EMmsg)) goto wrapup;
   if(nmprop & NMgm_Unevaluated) continue;
	
   if(all_nmnodes) om$dealloc(ptr = all_nmnodes);
   all_nmnodes = NULL;
   num_all_nmnodes = 0;
   ndbufsize = 0;
   sts = NMget_node((IGRlong *) EMmsg, &nmGRid, NULL, NULL, &all_nmnodes, 
	     &num_all_nmnodes, &ndbufsize, NULL, NMgetnode_All);
   if(!(1&*EMmsg&sts)) goto wrapup;
	
   for(j=num_all_nmnodes-1; j>=0; j--)
    {
     sts = om$send(msg = message NMnonmanigm.NMSSI_action((IGRlong *) EMmsg, 
              ssiopt, construct.env_info, NULL), 
              targetid = all_nmnodes[j].objid, 
    	      targetos = all_nmnodes[j].osnum);
    }

   } /* for(i=0; i<count; i++) */

 for (i=0;i<count;i++)
  {
   sts = om$send (msg = message EMSpointerA.EMstore_key_from_id(
         (IGRlong *)EMmsg,
         NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }

 sts = om$send(msg = message NMinters.NMintersect((IGRlong *) EMmsg, 
       ME.NMinters->operation, EMSsfbool_opt_doublecheck, NULL, NULL, 
       NULL, NULL, NULL, NMintersect_IsRecompute, &construct, NULL, NULL, NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup: 
 if(all_nmnodes) om$dealloc(ptr = all_nmnodes);
 if(*EMmsg != EMS_I_Useless)
  for (i=0;i<count;i++)
   {
    IGRlong rc, locsts;
    locsts = om$send (msg = message EMSpointerA.EMstore_id_from_key(&rc,
             NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   }

if(1&*EMmsg&sts) *EMmsg = ND_COMP_SUCC;
else *EMmsg = ND_COMP_FAIL;

EMWRAPUP(*EMmsg, sts, "NMinters.NDcompute_node");
 return(sts);
}

end implementation NMinters;
