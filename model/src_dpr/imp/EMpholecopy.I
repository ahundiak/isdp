class implementation EMSslboolfea;

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
#include "EMSkey.h"

from EMSdatpln import EMget_pln_info;
from EMSparamgm import EMgetgeom;
extern GRclassid OPP_EMSparampt_class_id, OPP_GRcompcurve_class_id,
		 OPP_EMSpointer_class_id, OPP_ASsource_class_id ,
                 OPP_GRcurve_class_id, OPP_EMSparamvc_class_id;

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
  IGRlong long_rc,options;
  IGRshort action , mask;
  IGRint index,l_count,count_only , bound_by_surface ;
  OM_S_OBJECT_LINKAGE *list;
  struct GRid root,context,as,*parents;
  struct GRid null_grid,go_grid,new_grid,ngrid;
  struct GRas assoc_list;
  struct src_attr src_attr;
  IGRpoint point;
  IGRuint          type;
  IGRboolean      hole_flag, axis_normal;
  IGRuint         var_par;
  IGRushort       hole_type, depth_type;
  IGRint          part_type;
  IGRboolean      through_hole;
  IGRboolean      ref_flag;
  IGRboolean  action1 = TRUE;
  IGRushort props,mask1 = EMS_PATTERN_FEATURE;

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

  status = om$send( msg = message EMSassoc.EMget_info(
					    &long_rc,
					    options,
					    &type,
					    NULL,
					    NULL),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  EFret_hole_cpart_data_mod(&long_rc, type, &hole_flag, &axis_normal, &var_par,
			    &hole_type, &depth_type, &part_type, &through_hole,
			    &ref_flag);

  null_grid.objid = NULL_OBJID;
  bound_by_surface = FALSE;
  for( index = 0; index < l_count; index++)
    {

      if(EFisAncestryValid(EMmsg,list[index].S_objid, 
			   list[index].osnum,
			   OPP_ASsource_class_id,FALSE))
	{
	  status = 
	    om$send (msg = message NDnode.ASreturn_go(
					  &go_grid,
					  &md_env->md_env.matrix_type,
                          	          md_env->md_env.matrix),
		     targetid = list[index].S_objid,
		     targetos = list[index].osnum);
	}
      else
	{
	  go_grid.objid = list[index].S_objid;
	  go_grid.osnum = list[index].osnum;
	}

      point[0]= point[1] = point[2] = 0.0;

      if(EFisAncestryValid(EMmsg,go_grid.objid, 
			   go_grid.osnum,
			   OPP_EMSparampt_class_id,TRUE))
	{
	  
	  if(count_only)
	    {
	      (*p_count)++;
	      continue;
	    }

	  /* Construct a point type of object available in DMsrc class*/  
	  root.objid = sender_id;
	  root.osnum = OM_Gw_current_OS;
	  assoc_list.num_parents = 1;
	  assoc_list.parents = &root;
	  assoc_list.context = &context;
	  assoc_list.as_attr = (char *)&src_attr;
	  src_attr.type = DMconstpt;
	  src_attr.attr = point;

	  as.osnum = md_env->md_id.osnum;
	  status =
	  om$construct(classname = "DMsrc",
		       osnum   = as.osnum,
		       p_objid = &as.objid,
		       msg = message NDnode.NDplace(
                                            &assoc_list,
                                            md_env,
                                            NULL));
	  fe$status(action = RET_STATUS);
	  p_par_list[*p_count] = as;
	  parents[index] = as;
	  (*p_count)++;	  
	}
      else if(EFisAncestryValid(EMmsg,list[index].S_objid,
				list[index].osnum,
				OPP_EMSpointer_class_id,FALSE))
	{
	  if(count_only) continue;
/*
  Type of the hole is not tested yet.
	  if( index == (l_count -2))
	    { 
	      bound_by_surface = TRUE;
	      parents[index] = *ref_plane;
	    }
	  else if( index == (l_count -1) && !bound_by_surface)
	    {
	      parents[index] = *ref_plane;
	    }
	  else
*/
	  if( depth_type == 0 && creator->objid != NULL_OBJID)
	    {
	      status = om$get_objid_at_index( 
			  objid = list[index].S_objid,
			  osnum = list[index].osnum,
			  p_chanselect = &ND_father,
			  index = 0,
			  objidaddr = &ngrid.objid,
			  osnumaddr = &ngrid.osnum);
	      fe$status(action = RET_STATUS);

	      status = 
	      om$send(msg = message EMSpointerA.EMstore_key_from_id(
						&long_rc,
						EMS_OPT_STORE_ID,
						NULL),
		      targetid = go_grid.objid,
		      targetos = go_grid.osnum);
	      fe$status();

	      new_grid.osnum = OM_Gw_current_OS;      
	      status = om$construct_and_copy ( objid = go_grid.objid,
					      osnum = go_grid.osnum,
					      p_objid= &new_grid.objid);
	      fe$status(action = RET_STATUS);
	  
	      status =
		om$send(msg = message NDnode.NDconnect(
					     1,
                                             creator,
					     null_grid,
					     ND_NEW),
			targetid = new_grid.objid,
			targetos = new_grid.osnum);
	      fe$status(action = RET_STATUS);
	      parents[index] = new_grid;
	    }
	  else
	    {
	      parents[index].objid = list[index].S_objid;
	      parents[index].osnum = list[index].osnum;
	    }
	}
      else if( hole_type == 2 && EFisAncestryValid(EMmsg, go_grid.objid,
			   go_grid.osnum,
			   OPP_GRcurve_class_id,FALSE))
	{
	  /* Cutout */
	  if(count_only)
	    {
	      (*p_count)++;
	      continue;
	    }
	  if(p_size < *p_count)
	    return(OM_E_ABORT);

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

	  status =
	  as$make_source(go_grid = as,
			 context_grid = context,
			 as_os = md_env->md_id.osnum,
			 as_grid = &parents[index]);
	  fe$status(action = RET_STATUS);

	  p_par_list[*p_count] = parents[index];
	  (*p_count)++;		
	}
      else if(EFisAncestryValid(EMmsg, go_grid.objid,
			   go_grid.osnum,
			   OPP_EMSparamvc_class_id,FALSE))
	{
	  struct EMSgeomdata axis;
	  IGRvector xaxis,normal,new_vec;
	  IGRdouble dotp;
	  struct GRid constr;

/*	  status = om$send(msg = message EMSparamgm.EMgetgeom(
					     EMmsg,
					     NULL,
					     &md_env->md_env.matrix_type,
					     md_env->md_env.matrix,
					     &axis),
			targetid = go_grid.objid,
			targetos = go_grid.osnum);
	  fe$status(action = RET_STATUS);

	  BScrossp(&long_rc,xaxis,axis.vector,new_vec);
	  dotp = BSdotp(&long_rc,new_vec,normal);
*/
	  if(count_only)
	    continue;
	  status = 
	  om$construct_and_copy(objid = go_grid.objid,
				osnum = go_grid.osnum,
				p_objid = &parents[index].objid);
	  fe$status(action = RET_STATUS);
	  
	  parents[index].osnum = go_grid.osnum;
	  /* We do not connect the axis to the pattern */

          status = 
	  om$get_objid_at_index( objid = go_grid.objid,
				 osnum = go_grid.osnum,
				 p_chanselect = &ND_father,
				 index = 0,
				 objidaddr =&constr.objid,
				 osnumaddr =&constr.osnum);
	  if(status &1)
	    {
	      status =
	      om$send(msg = message NDnode.NDconnect(
				 1,
                                 &constr,
                                 null_grid,
                                 ND_NEW),
		      targetid = parents[index].objid,
		      targetos = parents[index].osnum);
	      fe$status(action = RET_STATUS);
	    }
	  else status = OM_S_SUCCESS;

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

      status = 
      om$send( msg = message EMSdpr.EMsetprops(EMmsg,
					       &action1,
					       &mask1),
	      targetid = p_new->objid,
	      targetos = p_new->osnum);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    }
 wrapup:
  return(status);
}

end implementation EMSslboolfea;
