class implementation NMassoctrans;

#include "nddef.h"
#include "ndmacros.h"

extern struct ext_list NDdelete;

method NDmove_to_root (IGRlong *EMmsg; struct GRid *src_grid;
			  struct GRmd_env *md_env)
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid 		my_GRid;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoctrans.NMtransmigrate(EMmsg, NULL, NULL, 
       NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Put myself into the recompute or delete batch, based on whether I
    successfully transmigrated or was deemed useless.
 */
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if( (*EMmsg == EMS_I_Useless) && (NDin_buffer(my_GRid, &NDdelete) == -1))
  nd$wait_batch(type = GR_DELETED, nb_obj = 1, 
                l_object = &my_GRid, l_obj_info = md_env);
 else
  nd$wait_batch(type = GR_GEOM_POSTED, nb_obj = 1, 
		 l_object = &my_GRid, l_obj_info = md_env);

 if(src_grid)
  {
   src_grid->objid = my_id;
   src_grid->osnum = OM_Gw_current_OS;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "In NMassoctrans.NDmove_to_root");
return(sts);
}

end implementation NMassoctrans;
