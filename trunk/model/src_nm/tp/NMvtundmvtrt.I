class implementation NMvertex_use;

#include "nddef.h"
#include "ndmacros.h"

method NDmove_to_root (IGRlong *EMmsg; struct GRid *src_grid;
			  struct GRmd_env *md_env)
{
 IGRlong sts = OM_S_SUCCESS;
 struct GRid my_GRid;

 *EMmsg = EMS_S_Success;
	
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 nd$wait_batch(type = GR_DELETED, nb_obj = 1, 
               l_object = &my_GRid, l_obj_info = md_env);

 if(src_grid)
  {
   src_grid->objid = my_id;
   src_grid->osnum = OM_Gw_current_OS;
  }

EMWRAPUP(*EMmsg, sts, "NMvertex_use.NDmove_to_root");
return(sts);
}

end implementation NMvertex_use;
