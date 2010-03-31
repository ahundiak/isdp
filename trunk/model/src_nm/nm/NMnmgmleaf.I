class implementation NMnonmanigm;

#include "OMmacros.h"

extern OMuword OPP_EMSsubbs_class_id, OPP_NMnonmanigm_class_id;

method NMget_components(IGRlong *EMmsg; struct GRmd_env *env;
                        struct GRid objects[]; IGRint number_objects;
                        IGRint *count; IGRint from_obj; IGRint to_obj)
{
 IGRlong         sts = OM_S_SUCCESS;
 IGRint          my_count, i;
 OMuint		 comp_count;
 struct GRid     my_obj, *id_list;
 OM_S_CHANSELECT to_comps;
 void            EFgetobjids();
 OM_S_OBJID	mycomp = NULL_OBJID;
 OMuword	mycompos;

 *EMmsg = EMS_S_Success;
 *count = 0;
 my_count = 0;
 id_list = NULL;
 EMmake_chanselect(GRcmpowner_to_components, &to_comps);

 sts = om$get_channel_count(object = me, 
                                p_chanselect = &to_comps,
                                count = &comp_count);
 if (!(1 & sts)) goto wrapup;

 for (i = 0; i < comp_count; i ++)
 {
   /*Get leaf components of my components that are also composites*/

   sts = om$get_objid_at_index(object = me, p_chanselect = &to_comps, 
	 index = i, objidaddr = &mycomp, osnumaddr = &mycompos);
   if (!(1 & sts)) goto wrapup;	

   if(EFisAncestryValid(EMmsg,mycomp,mycompos,OPP_NMnonmanigm_class_id,FALSE))
     sts = om$send(msg = message NMnonmanigm.NMget_components(EMmsg, env,
                           &objects[*count], number_objects - *count,
                           &my_count, from_obj, to_obj), 
                     p_chanselect = &to_comps,
                     from = i, to = i);
   else
     sts = om$send(msg = message GRowner.GRget_components(EMmsg, env,
                           &objects[*count], number_objects - *count,
                           &my_count, from_obj, to_obj), 
                     p_chanselect = &to_comps,
                     from = i, to = i);

   if (!(1 & sts & *EMmsg) && (sts != OM_W_UNKNOWN_MSG)) goto wrapup;

   if (sts != OM_W_UNKNOWN_MSG)
   {
     *count += my_count;
     my_count = 0;
   }
   else 
     sts = OM_S_SUCCESS;
 }  

 /*Get my components that are leaf components*/
 my_obj.objid = my_id;
 my_obj.osnum = OM_Gw_current_OS;

 EFgetobjids(EMmsg, &my_obj, &to_comps, &id_list, &my_count,
             OPP_EMSsubbs_class_id, NULL, NULL);
 if (!(1 & *EMmsg)) goto wrapup;
 
 if (my_count + *count > number_objects) {*EMmsg = MSFAIL; goto wrapup;}

 if (my_count)
   OM_BLOCK_MOVE(id_list, &objects[*count], my_count * sizeof(struct GRid));

 *count += my_count;

wrapup:
 if (id_list) om$dealloc(ptr = id_list);
 EMWRAPUP(*EMmsg, sts, "In NMnonmanigm.NMget_components")
 return (sts);
}


method NMget_number_components(IGRlong *EMmsg; IGRint *count)

{
 IGRlong         sts = OM_S_SUCCESS;
 IGRint          my_count, i;
 OMuint		 comp_count;
 OM_S_CHANSELECT to_comps;
 OM_S_OBJID	mycomp = NULL_OBJID;
 OMuword	mycompos;

 *EMmsg = EMS_S_Success;

 *count = 0;
 my_count = 0;
 EMmake_chanselect(GRcmpowner_to_components, &to_comps);

 sts = om$get_channel_count(object = me, 
                                p_chanselect = &to_comps,
                                count = &comp_count);
 if (!(1 & sts)) goto wrapup;

 for (i = 0; i < comp_count; i ++)
 {
   /*Send on to comp*/

   sts = om$get_objid_at_index(object = me, p_chanselect = &to_comps, 
	 index = i, objidaddr = &mycomp, osnumaddr = &mycompos);
   if (!(1 & sts)) goto wrapup;	

   if(EFisAncestryValid(EMmsg,mycomp,mycompos,OPP_NMnonmanigm_class_id,FALSE))
    sts = om$send(msg = message NMnonmanigm.NMget_number_components(EMmsg, 
                           &my_count), 
                           p_chanselect = &to_comps,
                           from = i, to = i);
   else
    sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, 
                           &my_count), 
                           p_chanselect = &to_comps,
                           from = i, to = i);
   if (!(1 & sts & *EMmsg) && (sts != OM_W_UNKNOWN_MSG)) goto wrapup;

   if (sts == OM_W_UNKNOWN_MSG) 
   {
     (*count)++;
     sts = OM_S_SUCCESS;
   }
   else
   {
     *count += my_count;
     my_count = 0;
   }
 }  

wrapup:
 EMWRAPUP(*EMmsg, sts, "In NMnonmanigm.NMget_number_components")
 return (sts);
}

end implementation NMnonmanigm;
