class implementation EMSloop;

#include "OMmacros.h"

#define StaticBuf 10

IGRint EMunreverse_loop(EMmsg, lpid, lpos)
IGRlong *EMmsg;
GRobjid lpid;
GRspacenum lpos;
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_OBJECT_LINKAGE	*ed = NULL, edbuf[StaticBuf];
 OMuint			count;
 IGRint                     i; 
 OM_S_CHANSELECT	to_lp, to_ed;
 IGRushort	lpprops = NULL;

 sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
       senderid = NULL_OBJID, targetid = lpid, targetos = lpos);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(!(lpprops & EMLP_REVERSED))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }
 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 EMmake_chanselect(EMSedge_to_owner, &to_lp);

 sts = om$get_channel_count(objid = lpid, osnum = lpos, 
       p_chanselect = &to_ed, count = &count);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_I_Useless, wrapup);

 if(count > StaticBuf)
  ed = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count * 
       sizeof(OM_S_OBJECT_LINKAGE));
 else ed = edbuf;
 EMerr_hndlr(!ed, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$get_channel_objects(objid = lpid, osnum = lpos, list = ed, 
       size = count, count = &count, p_chanselect = &to_ed);
 if(!(1&sts)) goto wrapup;

 sts = om$send(msg = message Root.wild_disconnect(to_ed), 
       senderid = NULL_OBJID, targetid = lpid, targetos = lpos);
 if(!(1&sts)) goto wrapup;

 for(i=count-1; i>=0; i--) 
  {
   sts = om$send(msg = message Root.connect(to_lp, MAXINT, lpid, lpos, to_ed, 
         NULL), senderid = lpid, targetid = ed[i].S_objid, targetos = lpos);
   if(!(1&sts)) goto wrapup;
  }

 sts = om$send(msg = message EMSloop.EMset_props(EMmsg, EMLP_REVERSED, 
       EMS_O_OFF), senderid = NULL_OBJID, targetid = lpid, targetos = lpos);
 if(!(1&*EMmsg&sts)) goto wrapup;

wrapup:
if(ed && (ed != edbuf)) om$dealloc(ptr = ed);
return(sts);
}

end implementation EMSloop;
