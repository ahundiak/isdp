class implementation NMnonmanigm;

#include "ndmacros.h"

#define StaticBuf 10

extern OMuword OPP_NMinters_class_id;
extern struct ext_list NDdelete;

method GRdrop (IGRlong *EMmsg; struct GRmd_env *env)
{
 IGRlong		sts;
 IGRushort	options = NMssiact_EraseFlps | NMssiact_DrawFlps 
                        | NMssiact_EraseVtx | NMssiact_DeactTopology |
			  NMssiact_DeleteTopology | NMssiact_RedrawAffectedSfs;
 struct EMSobject_info	*parents = NULL, parentsbuf[StaticBuf];
 IGRint			i, numparents = 0;
 IGRushort 	nmprops = NMgm_Active;

 parents = parentsbuf;
 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       StaticBuf, &numparents), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, options, env, 
       NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<numparents; i++)
  {
   if(EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
      OPP_NMinters_class_id, FALSE) &&
     (NDin_buffer(parents[i].grid, &NDdelete) == -1))
     nd$wait_batch(type = GR_DELETED, l_object = &parents[i].grid, 
		nb_obj = 1, l_obj_info = env);
   else
    sts = om$send(msg = message NMnonmanigm.NMprop(EMmsg, NMprop_SetOn, 
          &nmprops), targetid = parents[i].grid.objid, 
          targetos = parents[i].grid.osnum);
  }

 sts = OM_S_SUCCESS;

 sts = om$send(mode = OM_e_wrt_message, 
              msg = message GRowner.GRdrop(EMmsg, env), 
      targetid = my_id);

wrapup:
if(parents && (parents != parentsbuf)) om$dealloc(ptr = parents);
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.GRdrop");
return(sts);
}

end implementation NMnonmanigm;
