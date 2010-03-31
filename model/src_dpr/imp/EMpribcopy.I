class implementation EMSslfeature;

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
#include "EMSasfeatdef.h"
#include "REaddrmfea.h"

extern GRclassid OPP_EMSparampt_class_id,OPP_GRcompcurve_class_id,
                 OPP_GRcurve_class_id, OPP_EMSparamgm_class_id,
		 OPP_EMSpointer_class_id,OPP_ASsource_class_id;
               

/*
	SAM	Dec 29, 1994	Modified it to support Protrusion/Cutout
				features also. Since, EMSparamgm (proj vect
				or pt ) is the parent and also derived from
				GRcurve, it was treating it the same way it
				treated profile parents. This parent just
				needs to be connected to and not copied 

*/
method EMpattern_copy( IGRlong *EMmsg;
		      struct GRid *creator;
		      struct GRid *p_new;
		      struct GRid *p_par_list;
		      IGRint *p_count;
		      IGRint  p_size;
		      struct GRmd_env *md_env;
		      struct GRid *ref_plane)
{
  IGRint status, sts ,options;
  IGRuint assoc_type,info_size;
  IGRlong long_rc;
  IGRshort action , mask;
  IGRint index,l_count,count_only,fe_par;
  OM_S_OBJECT_LINKAGE *list;
  struct GRid context,as,*parents;
  struct GRid null_grid,go_grid,root_grid; 
  OMuword classid;
  IGRint pattern_type;
  struct   EMSAddRm_RecompInfo *recomp = NULL;


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

  status = om$send( msg = message EMSassoc.EMget_info(
                                            EMmsg,
                                            options,
                                            &assoc_type,
                                            &info_size,
                                            NULL),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  recomp = (struct EMSAddRm_RecompInfo *) stackalloc(info_size);

  status = om$send( msg = message EMSassoc.EMget_info(
                                            EMmsg,
                                            options,
                                            &assoc_type,
                                            &info_size,
                                            (char **)&recomp),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  /* Do not have pattern object id , sender is pattern object */

  root_grid.objid = sender_id;
  root_grid.osnum = OM_Gw_current_OS;;

  pattern_type = GR_ASCOPY_POLAR;
/*
  status = om$send( msg = message EMSpatfea.EMget_pattern_type( &pattern_type),
		   targetid = sender_id);
  fe$status(action = RET_STATUS);
*/
  fe_par = 0;
  if( assoc_type == EMS_ASSOC_FEATURE_ADD_MATERIAL ||
      assoc_type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
    {
      /* Add/Remove material feature */

      /* 1st parent is a profile, create a copy*/

      if(count_only)
	  (*p_count)++;
      else
	{
	  if(p_size < *p_count) return(OM_E_ABORT);

	  status = 
	  EMreturn_profile_copy( &list[fe_par],&parents[fe_par],md_env);
	  fe$status(action = RET_STATUS);
	  p_par_list[*p_count] = parents[fe_par];
	  (*p_count)++;
	}      
      fe_par++;

      /* 2nd parent, depens on the project or revolve */
      if( recomp->props & EMSAddRm_Project)
	{
	  if( pattern_type == GR_ASCOPY_POLAR)
	    {
	      if(count_only)
		(*p_count)++;
	      else
		{
		  if(p_size < *p_count) return(OM_E_ABORT);
		  status = 
		  EMreturn_axis_vector_copy( &list[fe_par],&root_grid,
					    &parents[fe_par],
					    md_env);
		  fe$status(action = RET_STATUS);
		  p_par_list[*p_count] = parents[fe_par];
		  (*p_count)++;
		}
	    }
	  else 
	    {
	      parents[fe_par].objid = list[fe_par].S_objid;
	      parents[fe_par].osnum = list[fe_par].osnum;
	    }
	  fe_par++;
	}
      else if( recomp->props & EMSAddRm_Revolve )
	{
	  /* Two parents  1.EMSparampoint 2. EMSparamvc 
	     If pattern type is rectangular we need not copy
	     these parents, we can connect to same parents
	   */

	  if( pattern_type == GR_ASCOPY_POLAR)
	    {
	      if(count_only) 
		(*p_count)+=2;
	      else
		{
		  if(p_size < *p_count) return(OM_E_ABORT);
		  status = 
		  EMreturn_axis_point_copy( &list[fe_par],&root_grid,
					    &parents[fe_par],
					    md_env);
		  fe$status(action = RET_STATUS);
		  p_par_list[*p_count] = parents[fe_par];
		  (*p_count)++;
		  fe_par++;

		  if(p_size < *p_count) return(OM_E_ABORT);

		  status = 
		  EMreturn_axis_vector_copy( &list[fe_par],&root_grid,
					    &parents[fe_par],
					    md_env);
		  fe$status(action = RET_STATUS);

		  p_par_list[*p_count] = parents[fe_par];
		  (*p_count)++;
		  fe_par++;
		}
	    }
	  else 
	    {
	      parents[fe_par].objid = list[fe_par].S_objid;
	      parents[fe_par].osnum = list[fe_par].osnum;
	      fe_par++;
	      parents[fe_par].objid = list[fe_par].S_objid;
	      parents[fe_par].osnum = list[fe_par].osnum;
	      fe_par++;
	    }
	}
      else if( recomp->props & EMSAddRm_Skinned )
	{
	  /* Skinning trace curve, needs to be copied */

	  if(count_only)
	    (*p_count)++;
	  else
	    {
	      if(p_size < *p_count) return(OM_E_ABORT);
	      status = 
	      EMreturn_profile_copy( &list[fe_par],&parents[fe_par],md_env);
	      fe$status(action = RET_STATUS);
	      p_par_list[*p_count] = parents[fe_par];
	      (*p_count)++;
	      fe_par++;
	    }
	}

      if( !(recomp->props & EMSAddRm_Skinned) && 
	 recomp->props & EMSAddRm_Finite )
	{
	  parents[fe_par].objid = list[fe_par].S_objid;
	  parents[fe_par].osnum = list[fe_par].osnum;
	  fe_par++;
	  parents[fe_par].objid = list[fe_par].S_objid;
	  parents[fe_par].osnum = list[fe_par].osnum;
	  fe_par++;
	}
      else if( recomp->props & EMSAddRm_FromTo )
	{
	  /* These types may not produce desired results 
	     for radial patterning. Just connect to same parents */

	  if( !(recomp->props & EMSAddRm_NoFromSurf) )
	    {
	      parents[fe_par].objid = list[fe_par].S_objid;
	      parents[fe_par].osnum = list[fe_par].osnum;
	      fe_par++;
	    }

	  if( !(recomp->props & EMSAddRm_NoToSurf) )
	    {
	      parents[fe_par].objid = list[fe_par].S_objid;
	      parents[fe_par].osnum = list[fe_par].osnum;
	      fe_par++;
	    }
	} 

      if( !count_only && fe_par != l_count )
	{
	  /* Some of the parents could not be connected. abort */
	  return(OM_E_ABORT);
	}
    }
  else
    {
      /* Rib code */
      for( index = 0; index < l_count; index++)
	{
	  if(EFisAncestryValid(EMmsg,list[index].S_objid, 
			   list[index].osnum,
			   OPP_GRcurve_class_id,TRUE))
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
    
	  status = om$get_classid(objid = go_grid.objid,
				  osnum = go_grid.osnum,
				  p_classid = &classid);
	  fe$status(action = RET_STATUS);
 
	  status = om$is_ancestry_valid(superclassid = OPP_GRcurve_class_id,
                                        subclassid = classid);
	  fe$status(action = RET_STATUS);

	  if(status != OM_I_INVANCESTRY)
	    {
	      if(count_only)
		{
		  (*p_count)++;
		  continue;
		}
	      else
		{	      
		  if(p_size < *p_count)
		    return(OM_E_ABORT);
		  EMreturn_profile_copy( &list[index],&parents[index],md_env);
		  p_par_list[*p_count] = parents[index];
		  (*p_count)++;
		}
	    }
	  else
	    {
	      parents[index].objid = list[index].S_objid;
	      parents[index].osnum = list[index].osnum;
	    } 
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

int EMreturn_profile_copy( ingrid,outgrid,md_env)
OM_S_OBJECT_LINKAGE *ingrid;
struct GRid *outgrid;
struct GRmd_env *md_env;
{
  IGRint status,md_id_save;
  IGRlong long_rc;
  struct GRid go_grid,as,context;
  
  if(EFisAncestryValid(&long_rc,ingrid->S_objid, ingrid->osnum,
		       OPP_ASsource_class_id,TRUE))
    {
      status = 
      om$send (msg = message NDnode.ASreturn_go(
					  &go_grid,
					  &md_env->md_env.matrix_type,
                          	          md_env->md_env.matrix),
	       senderid = NULL_OBJID,
	       targetid = ingrid->S_objid,
	       targetos = ingrid->osnum);
      fe$status(action = RET_STATUS);
    }
  else
    {
      go_grid.objid = ingrid->S_objid;
      go_grid.osnum = ingrid->osnum;
    }
  
  if(!EFisAncestryValid(&long_rc,go_grid.objid, go_grid.osnum,
		       OPP_GRcurve_class_id,FALSE))
    {
      /* Not a curve segment. Reture failure */
      return(OM_E_ABORT);
    }

  /* Do not enter the copy to rtree */
  md_id_save = md_env->md_id.objid;
  md_env->md_id.objid = NULL_OBJID;
  context.objid = NULL_OBJID;
  status = 
  om$send(msg = message GRgraphics.GRcopy(
				   &long_rc,
			           md_env,
       			   	   md_env,
			           &as.objid),
	  senderid = NULL_OBJID,
	  targetid = go_grid.objid,
	  targetos = go_grid.osnum);
  fe$status(action = RET_STATUS);

  as.osnum = md_env->md_id.osnum;
  md_env->md_id.objid = md_id_save;

  /* Convert element to assoc class, and fill the instance 
     if transform matrix is available */

  EMtransform_pattern_element_assoc(&long_rc, &go_grid, &as, NULL, md_env);

 /* Incase not transformed to assoc, create a source object and return */

 status =
 as$make_source(go_grid = as,
		context_grid = context,
		as_os = md_env->md_id.osnum,
		as_grid = outgrid);
  fe$status(action = RET_STATUS);
  
  return( OM_S_SUCCESS);
}

int EMreturn_axis_point_copy( ingrid,parent,outgrid,md_env)
     OM_S_OBJECT_LINKAGE *ingrid;
     struct GRid *parent,*outgrid;
     struct GRmd_env *md_env;
{
  IGRint status;
  struct GRas assoc_list;
  struct src_attr src_attr;
  struct GRid context,as;
  IGRpoint point;
  
  context.objid = NULL_OBJID;
  point[0] = point[1] = point[2] = 0.0;

  assoc_list.num_parents = 1;
  assoc_list.parents = parent;
  assoc_list.context = &context;
  assoc_list.as_attr = (char *)&src_attr;
  src_attr.type = DMconstpt;
  src_attr.attr = point;    /* Will be posted during recompute */

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
  *outgrid = as;
  return( OM_S_SUCCESS);
}

EMreturn_axis_vector_copy(ingrid,parent,outgrid,md_env)
     OM_S_OBJECT_LINKAGE *ingrid;
     struct GRid *outgrid,*parent;
     struct GRmd_env *md_env;
{
	
  IGRint status, i;
  struct GRas assoc_list;
  struct src_attr src_attr;
  struct GRid context,as;
  struct DMln_str dm_line;
  
  context.objid = NULL_OBJID;

  for( i = 0; i< 6; i++)
    dm_line.line[i] = 0.0;

  assoc_list.num_parents = 1;
  assoc_list.parents = parent;
  assoc_list.context = &context;
  assoc_list.as_attr = (char *)&src_attr;
  src_attr.type = DMconstln;
  src_attr.attr = (IGRdouble *) &dm_line; /* Will be posted during recompute */

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
  *outgrid = as;
  return( OM_S_SUCCESS);
}

end implementation EMSslfeature;
