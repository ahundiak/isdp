class implementation NMvertex_use;

#include "nddef.h"

method NDupdate(int *EMmsg, cn_type, count;
		   struct GRid *parents;
		   int * parent_state;
		   struct GRid *context,*new_objid;
		   struct GRmd_env *md_env)
{
 *EMmsg = ND_COMP_SUCC;

 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);
}

method EMinit_associative  (IGRlong *EMmsg;
                            IGRushort options;
                            IGRint num_parents;
                            struct EMSobject_info *parent_info;
                            IGRint type;
                            unsigned int size;
                            IGRchar *recomp_info;
                            struct GRvg_construct *construct_list)

{
 IGRlong sts;

 options |= (EMS_no_const_assoc | EMSinit_dont_store_recomp_info);
 sts = om$send(mode = OM_e_wrt_message, msg =message NMassoc.EMinit_associative
        (EMmsg, options, num_parents, parent_info, type, size, recomp_info, 
         construct_list), targetid = my_id);
 return(sts);
}


method EMput_info  (IGRlong *EMmsg; IGRushort options;
                    unsigned int type; unsigned int info_size;
                     IGRchar *info)
{
 *EMmsg = EMS_I_InvalidSend;
 return(OM_S_SUCCESS);
}


method EMget_info(IGRlong *EMmsg; IGRushort options;
                  unsigned int *type; unsigned int *info_size;
                  IGRchar **info)
{
 *EMmsg = EMS_I_InvalidSend;
 return(OM_S_SUCCESS);
}

end implementation NMvertex_use;
