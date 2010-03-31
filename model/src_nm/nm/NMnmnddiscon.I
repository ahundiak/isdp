class implementation NMnonmani;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "nddef.h"

#define StaticBuf 10

extern OMuword OPP_NMinters_class_id, OPP_GRconnector_class_id;


method NDdisconnect(IGRint num; struct GRid *parents)
{
 IGRlong 	sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 IGRint		i;
 struct GRid	my_GRid;
 IGRint		loc_num_parents = 0, in_num;
 struct EMSobject_info *loc_parent_info = NULL;
 struct GRid	*loc_p = NULL, loc_pbuf[StaticBuf], thisparent, *in_parents;
 OM_S_CHANSELECT to_comps;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 in_num = num;
 in_parents = parents;

 if(!num)
  {
   sts = om$send(msg = message NMassoc.NMget_parent_info(&EMmsg, 
	 &loc_parent_info, 0, &loc_num_parents), targetid = my_id);
   if(!(1&EMmsg&sts)) goto wrapup;
   if(loc_num_parents > StaticBuf)
     loc_p = (struct GRid *) om$malloc(size = loc_num_parents * 
	     sizeof(struct GRid));
   else loc_p = loc_pbuf;
   EMerr_hndlr(!loc_p, EMmsg, EMS_E_NoDynamicMemory, wrapup);
   for(i=0; i<loc_num_parents; i++)
    loc_p[num++] = loc_parent_info[i].grid;
   parents = loc_p;
  }

 for(i=0; i<num; i++)
  {
   if(EFisAncestryValid(&EMmsg, parents[i].objid, parents[i].osnum, 
                          OPP_NMinters_class_id, FALSE)) continue;
   else if(!EFisAncestryValid(&EMmsg, parents[i].objid, parents[i].osnum, 
                          OPP_GRconnector_class_id, FALSE)) continue;
   else thisparent = parents[i];

   sts = om$is_objid_on_channel(object_c = me, p_chanselect = &to_comps, 
	 objid = thisparent.objid, osnum2 = thisparent.osnum);
   if(sts == OM_S_SUCCESS)
    sts = om$send(msg = message GRconnector.GRdisconn(&EMmsg, &my_GRid), 
           targetid = thisparent.objid, targetos = thisparent.osnum);
   else sts = OM_S_SUCCESS;
  }

sts = om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDdisconnect
      (in_num, in_parents), targetid = my_id);
if(!(1&sts)) goto wrapup;


wrapup:
if(loc_p && (loc_p != loc_pbuf)) om$dealloc(ptr = loc_p);
if(loc_parent_info) om$dealloc(ptr = loc_parent_info);
EMWRAPUP(EMmsg, sts, "NMnonmani.NDdisconnect");
return(sts);

}

end implementation NMnonmani;
