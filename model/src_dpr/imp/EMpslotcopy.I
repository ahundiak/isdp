class implementation EMSslslotfea;

#include "EMSprop.h"
#include "nddef.h"
#include "asbox.h"
#include "dm_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "dimsrc.h"
#include "GRascopy.h"
#include "EMpattern.h"

extern GRclassid OPP_EMSparampt_class_id,OPP_GRcurve_class_id,
		 OPP_EMSpointer_class_id,OPP_ASsource_class_id;

method EMpattern_copy( IGRlong *EMmsg;
		      struct GRid *creator;
		      struct GRid *p_new;
		      struct GRid *p_par_list;
		      IGRint *p_count;
		      IGRint  p_size;
		      struct GRmd_env *md_env;
		      struct GRid *ref_plane)
{
  IGRint status;
  IGRlong long_rc;
  IGRshort action , mask;
  IGRint index,l_count,count_only;
  OM_S_OBJECT_LINKAGE *list;
  struct GRid context,as,*parents;
  struct GRid null_grid,go_grid;

  *EMmsg = long_rc = MSSUCC;

  count_only = (p_par_list ? FALSE : TRUE);

  if( !count_only)
    {
      p_new->osnum = OM_Gw_current_OS;
      
      status = om$construct_and_copy ( object = me, 
				      p_objid= &p_new->objid);
      fe$status(action = RET_STATUS);

      action = 0;
      mask = GR_RIGID_RELATIONSHIP;

      status =
      om$send(msg = message GRgraphics.GRchgprops( &long_rc,
						  &action,
						  &mask),
	      targetid = p_new->objid,
	      targetos = p_new->osnum);
      fe$status(action = RET_STATUS);
    }

  status = om$get_channel_count(object = me,
				p_chanselect = &ND_father,
				count = (OMuint *)&l_count);
  fe$status(action = RET_STATUS);

  list = (OM_p_OBJECT_LINKAGE) stackalloc( l_count * 
					  sizeof(OM_S_OBJECT_LINKAGE));
  if(!list) return(OM_E_ABORT);
  
  parents = (struct GRid *) stackalloc( l_count * sizeof(struct GRid));
  if(!parents) return(OM_E_ABORT);
  
  status = om$get_channel_objects(object= me,
				  p_chanselect = &ND_father,
				  list = list,
				  size = l_count,
				  count = (OMuint *)&l_count);
  fe$status(action = RET_STATUS);

  context.objid = NULL_OBJID;
  context.osnum = list[0].osnum;
  null_grid.objid = NULL_OBJID;
  for( index = 0; index < l_count; index++)
    {
      if(EFisAncestryValid(EMmsg,list[index].S_objid, 
			   list[index].osnum,
			   OPP_ASsource_class_id,TRUE))
	{
	  status = 
	  om$send (msg = message NDnode.ASreturn_go(
					  &go_grid,
					  &md_env->md_env.matrix_type,
                          	          md_env->md_env.matrix),
		     targetid = list[index].S_objid,
		     targetos = list[index].osnum);
	  fe$status(action = RET_STATUS);
	}
      else
	{
	  go_grid.objid = list[index].S_objid;
	  go_grid.osnum = list[index].osnum;
	}
      
      if(EFisAncestryValid(EMmsg, go_grid.objid,
			   go_grid.osnum,
			   OPP_GRcurve_class_id,FALSE))
	{
	  int md_id_save;

	  if(count_only)
	    {
	      (*p_count)++;
	      continue;
	    }
	  if(p_size < *p_count)
	    return(OM_E_ABORT);

	  md_id_save = md_env->md_id.objid;
	  md_env->md_id.objid = NULL_OBJID;

	  status = 
	  om$send(msg = message GRgraphics.GRcopy(
					    EMmsg,
					    md_env,
       					    md_env,
					    &as.objid),
		    targetid = list[index].S_objid,
		    targetos = list[index].osnum);
	  fe$status(action = RET_STATUS);
	  as.osnum = md_env->md_id.osnum;
	  md_env->md_id.objid = md_id_save;

	  status =
	  as$make_source(go_grid = as,
			 context_grid = context,
			 as_os = md_env->md_id.osnum,
			 as_grid = &parents[index]);
	  fe$status(action = RET_STATUS);

	  p_par_list[*p_count] = parents[index];
	  (*p_count)++;
		
	}
      else
	{
	  parents[index].objid = list[index].S_objid;
	  parents[index].osnum = list[index].osnum;
	} 
    }
  if(!count_only)
    {
      status =
      om$send(msg = message NDnode.NDconnect(
			       l_count,
			       parents,
                               null_grid,
                               ND_NEW),
		targetid = p_new->objid,
		targetos = p_new->osnum);
      fe$status(action = RET_STATUS);
    }

  return(OM_S_SUCCESS);
}
end implementation EMSslslotfea;


