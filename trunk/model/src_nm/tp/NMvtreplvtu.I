class implementation NMvertex;

#include "OMmacros.h"

#define StaticBuf 10

from NMvertex_use import NMgetsurface_info;

method NMreplace_vtxuse(IGRlong *EMmsg; GRobjid exist_vtxuse;
		         IGRint num_replacements; GRobjid *replacements;
		         unsigned int connect_opt; struct NMgmSSI *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_vtxuse, to_vtx;
 OMuint			count = 0, exist_index;
 IGRint                 i;
 OM_S_OBJECT_LINKAGE	*oldvtu = NULL, oldvtubuf[StaticBuf];

 *EMmsg = EMS_S_Success;
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuse);
 NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtxuse, 
       count = &count);
 if(!(1&sts)) goto wrapup;
 if(!count)
  {
   if(!num_replacements)  /* intention was to simply disconnect the vtxuse */
    *EMmsg = EMS_I_InvalidSend;
   else
    *EMmsg = EMS_E_InvalidSend;
   goto wrapup;
  }

 sts = om$get_index(object_c = me, p_chanselect = &to_vtxuse, 
       objid = exist_vtxuse, indexaddr = &exist_index);
 if(sts == OM_W_NOTONCHAN)
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }
 if(!(1&sts)) goto wrapup;

 /* Capture existing vtu's for error recovery.
 */
 if(count > StaticBuf)
  {
   oldvtu = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count * 
	    sizeof(OM_S_OBJECT_LINKAGE));
   EMerr_hndlr(!oldvtu, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 else oldvtu = oldvtubuf;
 
 sts = om$get_channel_objects(object = me, p_chanselect = &to_vtxuse, 
       list = oldvtu, size = count, count = &count);
 if(!(1&sts)) goto wrapup;

 /* Disconnect the existing vtxuse.
 */
 sts = om$send(msg = message Root.disconnect(to_vtx, my_id, OM_Gw_current_OS, 
       to_vtxuse), targetid = exist_vtxuse);
 if(!(1&sts)) goto wrapup;

 /* Connect the replacements.
 */
 for(i=0; i<num_replacements; i++)
  {
   sts = om$send(msg = message Root.connect(to_vtx, exist_index++, my_id, 
	 OM_Gw_current_OS, to_vtxuse, NULL), targetid = replacements[i]);
   if(!(1&sts)) goto wrapup;
  }

 if( (connect_opt & NMconnect_AddToSSI) && ssi)
  {
   struct GRid sfid;

   sfid.objid = NULL_OBJID;
   sfid.osnum = OM_Gw_current_OS;
   sts = om$send(msg = message NMvertex_use.NMgetsurface_info(EMmsg, 
         &sfid.objid, NULL), targetid = exist_vtxuse);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(sfid.objid), *EMmsg, EMS_E_Fail, wrapup);
   sts = NMstore_vtxuse_transfer(EMmsg, ssi, &sfid, exist_vtxuse, my_id, 
	 NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   for(i=0; i<num_replacements; i++)
    {
     sfid.objid = NULL_OBJID;
     sfid.osnum = OM_Gw_current_OS;
     sts = om$send(msg = message NMvertex_use.NMgetsurface_info(EMmsg, 
           &sfid.objid, NULL), targetid = replacements[i]);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(IF_NULL_OBJID(sfid.objid), *EMmsg, EMS_E_Fail, wrapup);
     sts = NMstore_vtxuse_transfer(EMmsg, ssi, &sfid, replacements[i], 
	   NULL_OBJID, my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

wrapup:

/* Reconnect old vtu's in case of error.
*/
if( (!(1&*EMmsg&sts)) && count && oldvtu)
 {
  IGRlong locsts, rc;

  locsts = om$send(msg = message Root.wild_disconnect(to_vtxuse), 
   	   targetid = my_id);
  if(!(1&locsts)) goto finish;

  for(i=0; i<count; i++)
   {
    locsts = om$send(msg = message Root.connect(to_vtx, i, my_id, 
  	     OM_Gw_current_OS, to_vtxuse, NULL), targetid = oldvtu[i].S_objid);
    if(!(1&locsts)) goto finish;
   }
 }

finish:
if(oldvtu && (oldvtu != oldvtubuf)) om$dealloc(ptr = oldvtu);

EMWRAPUP(*EMmsg, sts, "NMvertex.NMreplace_vtxuse");
return(sts);
}

end implementation NMvertex;
