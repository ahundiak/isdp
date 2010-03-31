class implementation NMassoctrans;

#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern struct ext_list NDdelete;

method EMparent_owned(IGRlong *EMmsg;
		      OM_S_MESSAGE *messg;
                       OMuword options)
{
  struct GRid 		my_GRid;
  struct GRmd_env 	my_env;
  IGRint 		bytes_in, bytes_out, rc;
  IGRint		ndcode = GR_GEOM_POSTED;

  *EMmsg = EMS_S_Success;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                    nret = &bytes_out);
  EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
  nd$wait_batch(type = ndcode, nb_obj = 1, 
                 l_object = &my_GRid, 
		 l_obj_info = &my_env);   /* want myself to get update */
wrapup:
return(OM_S_SUCCESS);

}


method EMparent_disowned(IGRlong *EMmsg;
			 OM_S_MESSAGE *messg;
                          OMuword options)
{
  struct GRid 		my_GRid;
  struct GRmd_env 	my_env;
  IGRint 		bytes_in, bytes_out, rc;
  IGRint		ndcode = GR_GEOM_POSTED;

  *EMmsg = EMS_S_Success;

  if(options != GR_RIGID_RELATIONSHIP) goto wrapup;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                    nret = &bytes_out);
  EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  /* If I am in the delete batch, ignore this notification.
  */
  if(NDin_buffer(my_GRid, &NDdelete) == -1)
   nd$wait_batch(type = ndcode, nb_obj = 1, 
                 l_object = &my_GRid, 
	         l_obj_info = &my_env);   /* want myself to get update */

wrapup:
return(OM_S_SUCCESS);
}


end implementation NMassoctrans;
