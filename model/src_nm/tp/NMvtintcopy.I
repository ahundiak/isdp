class implementation NMvertex;

#include "OMmacros.h"

#define StaticBuf 10

from NMvertex_use import NMintcopy;

method NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRboolean		copy_exists = FALSE;
 OMuint			numvtxuses = 0;
 IGRint			i;
 OM_S_OBJECT_LINKAGE	*vtxuses = NULL, vtxusesbuf[StaticBuf];
 OM_S_CHANSELECT	to_vtxuses;
 struct GRid		*copyvtxuses = NULL, copyvtxusesbuf[StaticBuf];
 GRobjid		my_creator = NULL_OBJID, copy_creator = NULL_OBJID;

 *EMmsg = EMS_S_Success;
 *newobjid = NULL_OBJID;
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuses);


 /* If Already copied, exit.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 0, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;
 if(copy_exists) goto wrapup;

 sts = om$send(mode = OM_e_wrt_message, msg = message GRgraphics.GRcopy(EMmsg,
       obj_env, new_mdenv, newobjid), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Add myself to the list.
 */
 EMcpsearch (EMmsg, my_id, newobjid, copy_info, 3, &copy_exists);
 if(!(1&*EMmsg)) goto wrapup;

 /* Set up the creator id of the copy.
 */
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &my_creator, FALSE), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!IF_NULL_OBJID(my_creator))
  {
   EMcpsearch (EMmsg, my_creator, &copy_creator, copy_info, 0, &copy_exists);
   if(!(1&*EMmsg)) goto wrapup;
   EMerr_hndlr(!copy_exists, *EMmsg, EMS_E_InvalidCase, wrapup);
  }
 sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
       &copy_creator, TRUE), targetid = *newobjid);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtxuses, 
       count = &numvtxuses);
 if(!(1&sts)) goto wrapup;
 if(!numvtxuses) goto wrapup;

 if(numvtxuses > StaticBuf)
  {
   vtxuses = (OM_S_OBJECT_LINKAGE *) om$malloc(size = numvtxuses *
	     sizeof(OM_S_OBJECT_LINKAGE));
   copyvtxuses = (struct GRid *) om$malloc(size = numvtxuses *
	     sizeof(struct GRid));
  }
 else
  {
   vtxuses = vtxusesbuf;
   copyvtxuses = copyvtxusesbuf;
  }
 EMerr_hndlr(!vtxuses || !copyvtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$get_channel_objects(object = me, p_chanselect = &to_vtxuses, 
       list = vtxuses, size = numvtxuses, count = &numvtxuses);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<numvtxuses; i++)
  {
   copyvtxuses[i].osnum = vtxuses[i].osnum;
   copy_exists = FALSE;
   EMcpsearch(EMmsg, vtxuses[i].S_objid, &copyvtxuses[i].objid, copy_info, 1, 
	      &copy_exists);
   if(!copy_exists)
    {
     sts = om$send(msg = message NMvertex_use.NMintcopy(EMmsg, obj_env, 
	   new_mdenv, &copyvtxuses[i].objid, copy_info, nm_opt, bdry_options, 
	   sf_options), targetid = vtxuses[i].S_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

 sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, numvtxuses, 
       copyvtxuses, ME.GR3dpoint->point, NULL, NMconnect_NoChecks), 
       targetid = *newobjid);

wrapup:
if(vtxuses && (vtxuses != vtxusesbuf)) om$dealloc(ptr = vtxuses);
if(copyvtxuses && (copyvtxuses != copyvtxusesbuf)) 
 om$dealloc(ptr = copyvtxuses);
EMWRAPUP(*EMmsg, sts, "NMvertex.NMintcopy");
return(sts);
}

end implementation NMvertex;
