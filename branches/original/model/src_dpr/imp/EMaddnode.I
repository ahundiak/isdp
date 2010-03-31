class implementation EMSsfmacro;
#include "EMSdpr.h"
#include "exdef.h"
#include "exmacros.h"

from EMSpatfea import GRdelete;
extern IGRint EMSget_pattern_object();

method EMaddnode_to_macro(IGRlong *EMmsg;
                           struct GRid *node;
                           struct GRmd_env *md_env)
{

  IGRint status;
  IGRuint options,info_size,type;
  IGRint obj_count;
  IGRchar *info;
  struct GRid *grid;
  OM_S_CHANSELECT to_comp;
  struct GRid comp;

  status = EMmake_chanselect(GRcmpowner_to_components, &to_comp);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  status = om$get_objid_at_index( object = me,
			 p_chanselect = &to_comp,
			 index = 0,
			 objidaddr = &comp.objid,
			 osnumaddr = &comp.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  status = EFset_dpr_copy_prop(EMmsg,&comp,node,md_env);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  
  status = EFinsert_dpr_node(EMmsg, &comp, node);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  
  me->num_states += 1;
  /* Set the recompute info for the dpr node */
  
  status = om$send( msg = message EMSassoc.EMget_info( EMmsg,
				   options,
				   &type,
				   &info_size,
				   (IGRchar **)NULL),
		   targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  
  /* if the type is not equal to your type  return */
  info = (IGRchar *) stackalloc(info_size + sizeof(struct GRid));
  EMerr_hndlr(!info, *EMmsg, EMS_E_NoStackMemory,wrapup);

  if(info_size)
    {
      status = 
	om$send (msg = message EMSassoc.EMget_info((IGRlong *) EMmsg,
						   NULL, &type,
						   &info_size,
						   &info),
		 targetid = my_id);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    }
  obj_count = info_size/sizeof(struct GRid);
  grid = (struct GRid *)info;
  grid[obj_count] = *node;

  info_size  += sizeof(struct GRid);
  status = 
  om$send( msg = message EMSassoc.EMput_info(EMmsg, 
					    NULL,
					    type,
					    info_size,
					    info),
	  targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  
 wrapup:
  return(status);

}

method EMdelete_macro_node( IGRlong *EMmsg;
			    struct GRid *feature;
			   struct GRmd_env *md_env)
{
  IGRint status = OM_S_SUCCESS;
  IGRint del_options;
  IGRboolean  action = FALSE;
  IGRushort mask = EMS_MACRO_STATE ,md_id_save;
  struct GRid fea,pattern;

  del_options = EMdel_fea_DELETE_AND_SAVE| EMdel_fea_DELAY_UPDATE;

  md_id_save = md_env->md_id.objid;
  status = ex$get_modid( mod_osnum = md_env->md_id.osnum,
			 mod_id = &md_env->md_id.objid);
			 
  status = 
  om$send( msg = message EMSdpr.EMsetprops(EMmsg,
					   &action,
					   &mask),
	  targetid = feature->objid,
	  targetos = feature->osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  if( me->num_states >1)
    fea = *feature;
  else
    {
      fea.objid = my_id;
      fea.osnum = OM_Gw_current_OS;
    }

  status = EMSget_pattern_object(EMmsg,feature,md_env,&pattern);

  status =
  om$send( msg = message EMSdpr.EMdelete_feature(
				 EMmsg,
                                 md_env,
                                 del_options),
	  targetid = fea.objid,
	  targetos = fea.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  

  /* Delete it totallly now */
  del_options = EMdel_fea_CLEANUP_DELETED;
  status =
  om$send( msg = message EMSdpr.EMdelete_feature(
				 EMmsg,
                                 md_env,
                                 del_options),
	  targetid = fea.objid,
	  targetos = fea.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup); 

/*     
 * If all the pattern created features are deleted, all the extra nodes
 * that resulted due to pattern (includes active dimension) should be
 * deleted from the DPR tree : Fix for TR#119423832 . Hari
 */

  if(me->num_states==1)  
   {
     status = om$send( msg = message EMSpatfea.GRdelete(EMmsg,md_env),
                  targetid = pattern.objid,
                  targetos = pattern.osnum);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

     status = om$send( msg = message EMSdpr.EMdelete_feature(
                                            EMmsg,md_env,
                                            EMdel_fea_CLEANUP_DELETED),
                  targetid = feature->objid,
                  targetos = feature->osnum);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);      
   }
 
  md_env->md_id.objid = md_id_save;
  if( fea.objid != my_id)
    me->num_states -= 1;
 wrapup:
  return(status);
}
			   
end implementation EMSsfmacro;



