class implementation EMSpatfea;

#include "EMSprop.h"
#include "nddef.h"
#include "asbox.h"
#include "dm_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasprops.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"
#include "report.h"
#include "REassoc.h"
#include "EMSopt.h"
#include "EMSasmacros.h"
#include "EMSasfeatdef.h"
#include "REcurve.h"
#include "REaddrmfea.h"

from EMSsurface import EMpattern_copy, EMgetactiveid,EMmake_active_state,
                       EMget_tree_top;

from EMSdpr import EMsetprops,EMget_dpr_props, EMundo;
from EMSdatpln import EMget_pln_info;
from EMSsfmacro import EMcreate_yourself, EMaddnode_to_macro ,
                       EMdelete_macro_node;
from EMSparampt import EMconstruct;
from EMSassoc import EMget_info,EMput_info;

from EMSparameter import EMparam_delete;

extern GRclassid OPP_EMSsfboolean_class_id, 
  OPP_EMSslboolfea_class_id, 
  OPP_EMSparampt_class_id, 
  OPP_GRcompcurve_class_id, 
  OPP_EMSslrndbool_class_id, 
  OPP_EMSslslotfea_class_id, 
  OPP_EMSpointer_class_id, 
  OPP_GR3dpoint_class_id, 
  OPP_GRbspline_class_id,
  OPP_EMSslmacro_class_id,
  OPP_EMSslfeature_class_id,
  OPP_EMSsurface_class_id,
  OPP_DMroot_class_id;

extern IGRdouble BSdistptpt();
#define fe_projpt(vc,s,vr,V) \
{ \
        V[0] = vc[0] + s*vr[0];\
        V[1] = vc[1] + s*vr[1];\
        V[2] = vc[2] + s*vr[2];\
	}

method NDplace(
	       struct GRas * assoc_lis;
	       struct GRmd_env *md_env;
	       char           *go_cnst_lis) 
/*
  Description
     This method will  connect this object to the parents list 
     and initialize the instance.
     All the new copies and dimensions are created and connected
     to the pattern object.
     New geometry will be posted to them, during the recompute.
  
  Return Value
      OM_S_SUCCESS if everything is fine.
      status       otherwise.

  Notes:

  Change history:

*/
{  
  IGRint                  status, rc;
  IGRlong                 long_rc, EMmsg;
  IGRint                  size, i, j;
  struct GRid             *parents, *copy_list,
                          fea_parents[MAX_FS_PARENTS];
  struct GRid             null_grid, my_grid ,active_GRid;
  struct GRid 	          dim_obj[10], macro_id,creator;
  struct GRid             list[30]; /* Max Feature Parents */
  IGRint                  num_parents, num_copies, fea_count, 
                          copy_count, display_count, invoke_count;
  IGRboolean              make_tag_con;
  char                    *p_pat;
  struct GRptrn_single    *single;
  struct GRptrn_matrix    *matrix;
  struct GRptrn_polar     *polar;
  struct GRptrn_along_ele *linear;
  IGRint                  listener_index,num_states, num_list = 0;
  IGRint                  create_count, copy_size, num_dim_obj;
  IGRmatrix               rot_matrix;
  struct EMpat_attr       *attr;
  OM_S_CHANSELECT         to_notify;
  OM_S_OBJID tree_top;
  IGRboolean undone = FALSE;
  IGRushort undo_option;
  GRobjid *display_ids;
  attr = (struct EMpat_attr *) assoc_lis->as_attr;  
  
  /* According to New specs base ceature is always included */
  me->fea_props = BASE_FEATURE_INCLUDED;

  if(attr->fea_props & REF_DIR_X_NEG)
    me->fea_props |= REF_DIR_X_NEG;

  if(attr->fea_props & REF_DIR_Y_NEG)
    me->fea_props |= REF_DIR_Y_NEG;

  if(attr->fea_props & NOT_A_FEATURE)
    me->fea_props |= NOT_A_FEATURE;

  num_parents = assoc_lis->num_parents;
  parents = assoc_lis->parents;
  
  /* Set the detached list to 0 */
  om$vla_set_dimension(varray = me->deleted, size = 0);

  fea_count = 0;  

  if(me->fea_props & NOT_A_FEATURE)
    {
      struct GRid context;
      context.objid = NULL_OBJID ; /* Objects in master OS only */
      fea_count = 1;
      status =
      as$make_source(
		     go_grid = parents[num_parents-1],
		     context_grid = context,
		     as_os = OM_Gw_current_OS,
		     as_grid = &fea_parents[0]);
      fe$status(action = RET_STATUS);
    }
  else
    {
      for (i = 3; i <num_parents ; i++)
	{
	  if (EFisAncestryValid(&EMmsg, parents[i].objid,
				parents[i].osnum,
				OPP_EMSsfboolean_class_id, TRUE))
	    fea_parents[fea_count++] = parents[i];
	}
    }
  list[0] = parents[FEATURE_PAR_REF_PLANE];
  /* Set the pattern info */
  me->pattern_type = attr->pattern.type;

  switch (me->pattern_type)
    {
    case GR_ASCOPY_SINGLE:
      size = sizeof(struct GRptrn_single);
      single = &attr->pattern.var.single;
      num_copies = 1;
      p_pat = (char *) single;
      break;
    
    case GR_ASCOPY_LINEAR:
    
      size = sizeof(struct GRptrn_along_ele);
      linear = &attr->pattern.var.linear;
      num_copies = linear->num_copies ;
      p_pat = (char *) linear;
      break;
    
    case GR_ASCOPY_RECTANGULAR:
    
      size = sizeof(struct GRptrn_matrix);
      matrix = &attr->pattern.var.matrix;
      /* Reduce the number of copies to be created since original feature
	 is included 
       */
      num_copies = matrix->rows * matrix->cols -1 ;
      p_pat = (char *) matrix;

      if(parents[1].objid != NULL_OBJID)
	list[1] = parents[1];
      else if(!(me->fea_props & NOT_A_FEATURE))
	{
	  status = 
	  EFget_reference_point_from_feature( &long_rc,
					     fea_parents[0],
					     &list[1]);
	  if(!(status &1)) return(OM_E_ABORT);
	}
      status = 
      EFget_id_from_pattern(&rc,(double)matrix->rows,
			    &list[MATRIX_PAR_ROWS],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);

      status =
      EFget_id_from_pattern(&rc,(double)matrix->cols,
			    &list[MATRIX_PAR_COLS],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);
      
      status = 
      EFget_id_from_pattern(&rc,matrix->Xdelta,
			    &list[MATRIX_PAR_X_DELTA],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);

      status =
      EFget_id_from_pattern(&rc,matrix->Ydelta,
			    &list[MATRIX_PAR_Y_DELTA],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);
      num_list = 6;
      break;
    
    case GR_ASCOPY_POLAR:
    
      size = sizeof(struct GRptrn_polar);
      polar = &attr->pattern.var.polar;
      /* reduce number of copies to be created */
      num_copies = polar->num_copies * polar->num_sweeps -1 ;
      p_pat = (char *) polar;

      if(parents[1].objid != NULL_OBJID)
	list[1] = parents[1];
      else if(!(me->fea_props & NOT_A_FEATURE))
	{
	  status = 
	  EFget_reference_point_from_feature( &long_rc,
					     fea_parents[0],
					     &list[1]);
	  if(!(status &1)) return(OM_E_ABORT); 
	}

      if(parents[2].objid == NULL_OBJID)
	{
	  /* CENTER param point is NULL,create from user input */
	  return(OM_E_ABORT);
	}
      else list[2] = parents[2];

      status =
      EFget_id_from_pattern(&rc,polar->sweep_angle,
			    &list[POLAR_PAR_SWEEP_ANGLE],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);

      status =
      EFget_id_from_pattern(&rc,(double)polar->num_copies,
			    &list[POLAR_PAR_NUM_COPY],md_env);
      fe$status(action = GOTO_VALUE,value=wrapup);
      num_list = 5;
      break;

    default:
      printf(" pattern type:%d\n", me->pattern_type);
      return(OM_E_ABORT);
    }


  for( i = 0; i < fea_count; i++)
      list[num_list++] = fea_parents[i];

  create_count = 0;
  status = om$send(msg = message EMSpatfea.EMget_copy(
					&EMmsg,
					i,
				        (struct GRid *) NULL,
					&null_grid,
					fea_parents,
					fea_count,
					&create_count,
					create_count,
					md_env,
					&list[0]), 
		   targetid = my_id);
  fe$status(action = RET_STATUS);
  
  status = om$vla_set_dimension(varray = me->info, size = size);
  fe$status(action = RET_STATUS);
  
  memcpy(me->info, p_pat, size);

  /* Create the copies and connect to them */

  copy_list = (struct GRid *)
    stackalloc((num_copies+1 ) * sizeof(struct GRid) * create_count);
  copy_size = (num_copies +1) * create_count;
  
  MAidmx(&long_rc, rot_matrix);
  
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  num_states =  0;  /* Create a dummy macro object */

  if(me->fea_props & NOT_A_FEATURE )
    {      
      if(EFisAncestryValid(&EMmsg, fea_parents[0].objid, 
		       fea_parents[0].osnum, 
		       OPP_EMSsurface_class_id, FALSE))
	{
	  status =
	  om$send( msg = message EMSsurface.EMgetactiveid(
				    &EMmsg,
				    &active_GRid,
				    NULL),
		  senderid = fea_parents[0].objid,
		  targetid = fea_parents[0].objid,
		  targetos = fea_parents[0].osnum);
	  fe$status(action = RET_STATUS);

	  undo_option = EMS_UNDO_SAVE;
      

	  status = 
	  om$send( msg = message EMSsurface. EMmake_active_state(
					 &EMmsg,
					 &undo_option,
					 md_env,
					 NULL,NULL,NULL,
					 NULL,NULL,NULL),
		  targetid = fea_parents[fea_count -1].objid,
		  targetos = fea_parents[fea_count -1].osnum);
	  if( ! (status & EMmsg & 1))
	    {
	      undone = FALSE;
	      goto wrapup;
	      
	    }
	  undone = TRUE;
	}
    }
  else 
    {
        status = om$send(msg = message EMSsurface.EMget_tree_top(
                                          &EMmsg,
                                          &tree_top,
                                          NULL,
                                          NULL),
                   targetid = fea_parents[0].objid,
                   targetos = fea_parents[0].osnum);
	fe$status(action = RET_STATUS);

      status = om$construct (classid = OPP_EMSslmacro_class_id,
			 msg = message EMSsfmacro.EMcreate_yourself(
				       &long_rc,
				       tree_top,
				       num_states,
				       md_env),
			 p_objid = &macro_id.objid,
			 osnum = md_env->md_id.osnum);
      fe$status(action = RET_STATUS);

      macro_id.osnum = md_env->md_id.osnum;

/*      for( i = 0; i< fea_count; i++)
	{
	  status = 
	    om$send(msg = message EMSdpr.EMsetprops(&EMmsg,
						    &action, &mask),
		    targetid = fea_parents[i].objid,
		    targetos = fea_parents[i].osnum);
	  fe$status(action = RET_STATUS);
	}
*/
      status = om$make_chanselect (channame = "EMSpatfea.listeners",
				   p_chanselect = &to_notify);
      fe$status(action = RET_STATUS);

      listener_index = 0;
      make_tag_con = 0;

      status = om$send( msg = message GRnotify.GRntfyconn(
				           &EMmsg,
					   &my_grid,
					   &to_notify,
					   &listener_index,
					   &make_tag_con, 
					   NULL),
		       targetid = macro_id.objid,
		       targetos = macro_id.osnum);
      fe$status(action = RET_STATUS);

      status = 
      om$send(msg = message EMSassoc.EMput_info(&EMmsg,
					   NULL,
					   EMS_ASpattern_macro,
					   NULL,NULL),
	      targetid = macro_id.objid,
	      targetos = macro_id.osnum);
      fe$status(action = RET_STATUS);
    }
  copy_count = 0;
  creator = fea_parents[fea_count -1];
  for (i = 0; i < num_copies; i++)
    {
      status = 
      om$send(msg = message EMSpatfea.EMget_copy(
				      &EMmsg,
				      i,
			              copy_list,
			              &creator,
			              fea_parents,
			              fea_count,
			              &copy_count,
			              copy_size,
			              md_env,
			              &list[0]),
	      targetid = my_id);
      
      if (!(status & EMmsg & 1) || 
	  copy_size < (copy_count + create_count))
	{
	  fe$status();
          /**********  Error handling here *************/

	  display_ids = NULL;
	  display_count = 0;
	  invoke_count = 0;
	  undo_option = EMS_UNDO_DELETE;
	  status = 
	  om$send (msg = message EMSdpr.EMundo (&long_rc, 
						&undo_option,
						md_env, 
						NULL, 
						NULL, 
						NULL, 
						&display_ids,
						&display_count, 
						&invoke_count),
              targetid = macro_id.objid,
              targetos = macro_id.osnum);

	  for ( j = 0; j <copy_count; j++)
	    {
	      status = 
	      om$send( msg = message GRgraphics.GRdelete( &EMmsg,md_env),
			   senderid = copy_list[j].objid,
			   p_chanselect = &ND_children);
	    }
	  return(OM_E_ABORT);
	}

      creator = copy_list[copy_count -1];
    }

  status = 
  om$send(msg = message NDnode.NDconnect(
			      num_list,
			      list,
			      null_grid,
			      ND_NEW),
		       targetid = my_id);
  fe$status(action = RET_STATUS);

  if( me->fea_props & NOT_A_FEATURE)
    {
      struct EMSobject_info ems_list;
      struct  GRvg_construct construct_list;
      enum GRdpmode mode = GRbd;
      struct GRsymbology symb;

      ems_list.grid.objid = my_id;
      ems_list.grid.osnum = OM_Gw_current_OS;

      ems_list.env = *md_env;
      /* Create a object of EMSassoc class and connect it  on the
       * ND_children channel.
       */
      
      status = om$send( msg = message GRvg.GRgetsymb(
					   &EMmsg,
					   &symb),
		       targetid = fea_parents[0].objid,
		       targetos = fea_parents[0].osnum);
      fe$status(action = RET_STATUS);

      construct_list.msg = &EMmsg;
      construct_list.env_info = md_env;
      construct_list.newflag = FALSE;
      construct_list.geometry = NULL;
      construct_list.class_attr = NULL;
      construct_list.level = symb.level;
      construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      construct_list.display = &symb.display_attr;
      construct_list.name = NULL;

      status = ems$associative_element_by_function(msg = &EMmsg,
                associative = TRUE,
                num_parents = 1,
                parents = &ems_list,
                function_name = "EFpattern",
                construct_list = &construct_list,
                created_id = &copy_list[0].objid);
      fe$status();
      EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMmsg, wrapup);
      
      copy_count = 1;
      copy_list[0].osnum = OM_Gw_current_OS;
      status = 
      om$send( msg = message GRgraphics.GRdisplay(
				  &long_rc,
				  &md_env->md_env.matrix_type,
				  md_env->md_env.matrix,
				  &mode,
				  &md_env->md_id),
	      targetid = copy_list[0].objid,
	      targetos = copy_list[0].osnum);
      fe$status();
      EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMmsg, wrapup);
    }
  else
    {
      status = 
      om$send(msg = message EMSassoc.EMput_info(&EMmsg,
					   NULL,
					   EMS_ASpattern_macro,
					   (IGRuint) 0,NULL),
	      targetid = macro_id.objid,
	      targetos = macro_id.osnum);
      fe$status();
      EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMmsg, wrapup);
    }

  /* Needs to connect the copied elements as parents for
   * compleing the assoc graph
   */

  for (i = 0; i < copy_count; i++)
    {
      status = 
      om$send(msg = message NDnode.NDconnect(
					 1,
					 &my_grid,
					 null_grid,
					 ND_FULL | ND_NEW),
	      targetid = copy_list[i].objid,
	      targetos = copy_list[i].osnum);
      if(!(status &1))
	 {
	   fe$status();
	   goto wrapup;
	 }
    }

  status = 
  om$send(msg = message EMSpatfea.EMplace_dimensions(
					  &EMmsg,
					  num_list,
					  list,
					  &num_dim_obj,
					  dim_obj,
					  md_env),
		   targetid = my_id);
  fe$status();
  EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMmsg, wrapup);
 wrapup:
  if(undone)
    {
      status = 
      om$send( msg = message EMSsurface. EMmake_active_state(
					 &EMmsg,
					 &undo_option,
					 md_env,
					 NULL,NULL,NULL,
					 NULL,NULL,NULL),
	      targetid = active_GRid.objid,
	      targetos = active_GRid.osnum);
    }
  return(status);
}

method EMget_copy(
	     IGRlong * EMmsg;
	     IGRint          index;
	     struct GRid    *p_par_list;
	     struct GRid    *dpr_root;
	     struct GRid    *fea_par;
	     IGRint          num_fea;
	     IGRint         *p_count;
	     IGRint          p_size;
	     struct GRmd_env *md_env;
	     struct GRid    *ref_plane)
/* 
  Description:
      Create copies of the input feature and insert them to the 
      DPR tree.

           *msg  completion code - MSSUCC if successful
                           - MSFAIL (severe) if failure
	   status
  Notes:

  Change hisotry:
*/
      
{
  IGRint          status;
  IGRint          i, fea_count;
  struct GRid     fea_list[MAX_FS_PARENTS], 
                  copy_list[MAX_FS_PARENTS];

  
  if(me->fea_props & NOT_A_FEATURE)
    return(OM_S_SUCCESS);
  if(!fea_par)
    {
      /* This code will not work */
      status = 
      om$send(msg = message EMSpatfea.get_feature_list(
					EMmsg,
					fea_list, 
					&fea_count),
		targetid = my_id);
      fe$status(action = RET_STATUS);
      
      fea_par = fea_list;
      num_fea = fea_count;
    }

  for(i = 0; i < num_fea; i++)
    {
      if(i) *dpr_root = copy_list[i-1];
      else dpr_root->objid = NULL_OBJID;
      status =
      om$send(msg = message EMSsurface.EMpattern_copy(
				    EMmsg,
				    dpr_root,
				    &copy_list[i], 
				    p_par_list, 
				    p_count, 
				    p_size, 
				    md_env,
				    ref_plane), 
		targetid = fea_par[i].objid, 
		targetos = fea_par[i].osnum);

      if (!(status & *EMmsg & 1))
      {
	  fe$status();
	  goto wrapup;
      }
    }
    
    /*
     * Reset the Dpr properties and insert copies to the DPR
     * tree
     */ 

    if (p_par_list) 
    {
      status = 
      om$send(msg = message EMSpatfea.EMadd_to_dpr_tree(
				         EMmsg, 
					 0, 
					 num_fea, 
					 fea_par,
					 copy_list, 
					 md_env),
	       targetid = my_id);
      fe$status();
    }
 wrapup: 
  /* If there is a failure , delete all the 
   * copies and return abort
   */
  if(!(status & *EMmsg &1))
    {
      for( i = 0; i< num_fea;i++)
	{
	  status = om$send( msg = message GRgraphics.GRdelete( EMmsg,md_env),
			   targetid = copy_list[i].objid,
			   targetos = copy_list[i].osnum);
	}
      return(OM_E_ABORT);
    }
    
  return (OM_S_SUCCESS);
}

method EMadd_to_dpr_tree(
			 IGRlong * EMmsg;
			 IGRint fe_index, fe_count;
			 struct GRid    *feature_list;
			 struct GRid    *copy_list;
			 struct GRmd_env *p_md_env)
/* 
  Description
   Add the new copies to the dpr tree.
   
  Return values
       *EMmsg
       status

*/
{
  IGRint          status;
  IGRint          i;
  struct GRid   macro ,my_grid;
  OM_S_CHANSELECT to_notify;
  IGRboolean action = TRUE;
  IGRushort mask1 = EMS_NULL_STATE,
            mask  = EMS_PATTERN_FEATURE;

  /* Get the macro object */

  status = om$make_chanselect (channame = "EMSpatfea.listeners",
			       p_chanselect = &to_notify);
  fe$status(action = RET_STATUS);

  status = om$get_objid_at_index(object = me,
				 p_chanselect = &to_notify,
				 index = 0,
				 objidaddr = &macro.objid,
				 osnumaddr = &macro.osnum);
  if(!( status & 1 ) )
    {
      
      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      status =
      EMSget_pattern_macro_object(EMmsg,&my_grid,p_md_env,&macro);
      fe$status(action = RET_STATUS);
    }
  for(i = 0; i < fe_count; i++)
    {
      status = 
      om$send (msg = message EMSsfmacro.EMaddnode_to_macro(
			              EMmsg,
				      &copy_list[i],
				      p_md_env),
	       targetid = macro.objid,
	       targetos = macro.osnum);

      status = 
      om$send(msg = message EMSdpr.EMsetprops(EMmsg,
                                &action, &mask),
	      targetid = copy_list[i].objid,
	      targetos = copy_list[i].osnum);
      fe$status(action = RET_STATUS);

    }
  status = 
  om$send(msg = message EMSdpr.EMsetprops(EMmsg,
                                &action, &mask1),
	  targetid = macro.objid,
	  targetos = macro.osnum);
  fe$status(action = RET_STATUS);

  return (OM_S_SUCCESS);
}

method EMget_pattern_info(
	      IGRlong * EMmsg;
	      struct GRas_pattern *pattern;
	      struct GRmd_env *md_env)
{
  IGRint size;
  IGRint status;
  IGRlong long_rc;
  IGRdouble center[3],ref_pt[3],p_center[3],normal[3];
  IGRdouble orig[3];
  struct GRid param, param1 ,go_grid;
  struct ret_struct info_struct;
  IGRshort mat_type;
  IGRmatrix matrix;
    
  *EMmsg = MSSUCC;
    
  size = om$dimension_of(varray = me->info);
  pattern->type= me->pattern_type;
  memcpy(&pattern->var, me->info, size);
  if(me->pattern_type == GR_ASCOPY_POLAR)
    {
      
      status = om$send( msg = message NDnode.ASreturn_go(
					     &param,
					     &mat_type,
					     matrix),
		       
		       p_chanselect = &ND_father,
		       from = POLAR_PAR_CENTER,
		       to = POLAR_PAR_CENTER);
      fe$status(action = RET_STATUS);

      as$any_give_structure(go_grid = param,
			    inst = &info_struct,
			    mod_env = md_env);
    
      center[0] = info_struct.var.point_st.pt[0];
      center[1] = info_struct.var.point_st.pt[1];
      center[2] = info_struct.var.point_st.pt[2];

      status = om$send( msg = message NDnode.ASreturn_go(
					     &param1,
					     &mat_type,
					     matrix),
		       
		       p_chanselect = &ND_father,
		       from = FEATURE_PAR_REF_POINT,
		       to = FEATURE_PAR_REF_POINT);
      fe$status(action = RET_STATUS);

      status = 
      as$any_give_structure(go_grid = param1,
			  inst = &info_struct,
			  mod_env = md_env);
      fe$status(action = RET_STATUS);
    
      ref_pt[0] = info_struct.var.point_st.pt[0];
      ref_pt[1] = info_struct.var.point_st.pt[1];
      ref_pt[2] = info_struct.var.point_st.pt[2];

      status = om$send( msg = message NDnode.ASreturn_go(
					     &go_grid,
					     &mat_type,
					     matrix),
		       p_chanselect = &ND_father,
		       from = FEATURE_PAR_REF_PLANE,
		       to = FEATURE_PAR_REF_PLANE);
      fe$status(action = RET_STATUS);

      /* Project these points on the plane */
      status = 
      om$send(msg = message EMSdatpln.EMget_pln_info(
					EMmsg,
					NULL,
					md_env,
					NULL,
					NULL,
					normal,
					orig,
					NULL),
	      targetid = go_grid.objid,
	      targetos = go_grid.osnum);
	fe$status(action = RET_STATUS);

      BSproj1(&long_rc,center,normal,ref_pt,p_center);
      pattern->var.polar.radius = BSdistptpt(&long_rc,p_center,ref_pt);
    }
  
  return (OM_S_SUCCESS);
}

method get_feature_list(
	 IGRlong * EMmsg;
	 struct GRid    *fe_list;
	 IGRint *count)
{
  IGRint          status;
  struct GRid     parents[MAX_FS_PARENTS];
  IGRint          i,num_parents;
  
  *count = 0;

  status = om$send(msg = message NDnode.NDget_objects(
				     ND_ROOT,
				     parents,
				     MAX_FS_PARENTS,
				     NULL,
				     0,
				     MAX_FS_PARENTS - 1,
				     &num_parents),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  for (i = num_parents - 1; i > 0; i--)
    {
      if (EFisAncestryValid(&EMmsg, parents[i].objid,
			    parents[i].osnum,
			    OPP_EMSsfboolean_class_id, TRUE))
	fe_list[(*count)++] = parents[i];
    }

  return (OM_S_SUCCESS);
}

method get_copy_count(IGRint * msg, *count, *delete_count)
{
  
  return (OM_S_SUCCESS);
} 

IGRint EFset_dpr_copy_prop(EMmsg, p_root, p_copy, md_env)
     IGRlong *EMmsg;
     struct GRmd_env       *md_env;
     struct GRid    *p_root, *p_copy;
{
  IGRlong status;
  unsigned short  props;
  IGRboolean      action = FALSE;
  

  status = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  
  /* Set/Clear active state bit 
  
  status = om$send(msg = message EMSsurface.EMget_tree_top(
					  EMmsg,
					  &tree_top,
					  NULL,
					  NULL),
		   senderid = NULL_OBJID,
		   targetid = p_root->objid,
		   targetos = p_root->osnum);
  EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  

  if (!(tree_top == p_root->objid))
  {
*/
      /* - Turn the active state bit off */
    
    props = EMSIS_ACTIVE_STATE;
    status = om$send(msg = message EMSdpr.EMsetprops(
				     EMmsg,
				     &action,
				     &props),
		     senderid = NULL_OBJID,
		     targetid = p_copy->objid,
		     targetos = p_copy->osnum);

    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	/* Set the properties for the copy(cf:Dave Brann) */
  

  props = EMSIS_ACTIVE_PATH | EMS_UNEVAL_STATE | EMS_NULL_STATE;

  action = TRUE;
  status = om$send(msg = message EMSdpr.EMsetprops(
				    EMmsg,
				    &action,
				    &props),
		   senderid = NULL_OBJID,
		   targetid = p_copy->objid,
		   targetos = p_copy->osnum);

  EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

	/* ???  EMS set converted_to_cs bit */

 wrapup:
  EMWRAPUP(*EMmsg, status, "");
  return (status);
}

EFinsert_dpr_node(msg, p_root, p_new)
     IGRlong  *msg;
     struct GRid  *p_root, *p_new;
{

  /* Get the current owner of p_root and
     connect him  to the p_new 	 */
  
  IGRint          status;
  IGRlong         long_rc, owner_index;
  
  OM_S_CHANSELECT to_owners;
  struct GRid     owner;

  *msg = OM_S_SUCCESS;
  status = EMmake_chanselect(GRconnector_to_owners, &to_owners);
  fe$status(action = RET_STATUS);
  
  status = om$get_objid_at_index( objid = p_root->objid,
			 p_chanselect = &to_owners,
			 index = 0,
			 objidaddr = &owner.objid,
			 osnumaddr = &owner.osnum);
  if (!(status & 1))
    owner.objid =  NULL_OBJID;	/* Connect new to the owner */

  owner_index = 0;
  if (owner.objid != NULL_OBJID)
  {
    status = om$send(msg = message GRconnector.GRrigidconn(
					&long_rc,
					&owner,
					&owner_index),
		     senderid = NULL_OBJID,
		     targetid = p_new->objid,
		     targetos = p_new->osnum);
    fe$status(action = RET_STATUS);

	/* Disconnect the original parent */

    status = om$send(msg = message GRconnector.GRdisconn(
					&long_rc,
					&owner),
		     senderid = NULL_OBJID,
		     targetid = p_root->objid,
		     targetos = p_root->osnum);
    fe$status(action = RET_STATUS);
  }


  status = om$send(msg = message GRconnector.GRrigidconn(
					&long_rc,
					p_new,
					&owner_index),
		   senderid = p_root->objid,
		   targetid = p_root->objid, 
		   targetos = p_root->osnum);
  fe$status(action = RET_STATUS);

 wrapup:
  return (status);
}

method EMget_plane_info(
       IGRlong * EMmsg;
       struct GRid     *olist;
       IGRmatrix plane;
       struct GRmd_env *md_env)
{
  IGRint status;
  struct ret_struct info_struct;
  struct GRid *list,llist[30], go_grid;
  IGRint count;
  struct GRmd_env mod_env;

  if(olist)
      list = olist;
  else
    {
      status = om$send(msg = message NDnode.NDget_objects(
				     ND_ROOT,
				     llist,
				     10,
				     NULL,
				     0,
				     9,
				     &count),
		       targetid = my_id);
      fe$status(action = RET_STATUS);
      list = llist;
    }

  status = om$send( msg = message NDnode.ASreturn_go(
					 &go_grid,
					 &mod_env.md_env.matrix_type,
					 mod_env.md_env.matrix),
		   targetid = list[FEATURE_PAR_REF_PLANE].objid,
		   targetos = list[FEATURE_PAR_REF_PLANE].osnum);
  fe$status(action = RET_STATUS);
		   
  status = om$send(msg = message EMSdatpln.EMget_pln_info(
					EMmsg,
					NULL,
					md_env,
					plane,
					&plane[4],
					&plane[8],
					&plane[12],
					NULL),
		   targetid = go_grid.objid,
		   targetos = go_grid.osnum);
  fe$status(action = RET_STATUS);

  status = om$send(msg = message NDnode.NDgive_structure(
					 EMmsg,
					 &info_struct,
					 md_env),
		   targetid = list[FEATURE_PAR_REF_POINT].objid,
		   targetos = list[FEATURE_PAR_REF_POINT].osnum);
  fe$status(action = RET_STATUS);

  if(!(info_struct.type & point_generic))
    return(OM_E_ABORT);

  /* Move the origin of the plane to reference point */


  plane[3]  = info_struct.var.point_st.pt[0];
  plane[7]  = info_struct.var.point_st.pt[1];
  plane[11] = info_struct.var.point_st.pt[2];
  
  return (OM_S_SUCCESS);
}

EFget_control_parents(msg, options, num_fea,
		      feature_list, cur_index,
		      p_list, p_count)
     IGRint         *msg;
     IGRint          options;
     IGRint          num_fea;
     struct GRid    *p_list,*feature_list;
     IGRint cur_index, *p_count;
{
  IGRint status;
  IGRboolean axis_normal;
  IGRint param_type, next_until;

  status  = EFget_pattern_feature_defn(msg, 
				       &feature_list[0],
				       &axis_normal,
				       &param_type,
				       &next_until,
				       p_list,
				       p_count);
  return(status);
}

method ASreturn_go(
	struct GRid *go;
	IGRshort *mat_type;
	IGRdouble *matrix)
{
  IGRlong long_rc;

  go->objid = my_id;
  go->osnum = OM_Gw_current_OS;
  if(matrix)
    MAidmx(&long_rc,matrix);
  if(mat_type)
    *mat_type = 2;
  return(OM_S_SUCCESS);
}

method EMcreate_pattern_elements( IGRlong *EMmsg;
				  IGRint *num_copies;
				  struct GRid **copies;
				  struct GRmd_env *md_env;
				  struct GRid *master_GRid)
{
  IGRboolean undone = FALSE;
  IGRushort undo_option;
  IGRint status;
  IGRlong long_rc;
  IGRint xflag,yflag;
  struct GRptrn_matrix *matrix;
  struct GRptrn_polar *polar;
  struct GRas_pattern pattern;
  IGRdouble xdir[3],ydir[3],ref_point[3],mark_pt[3],center[3];
  IGRmatrix rot_matrix,plane;
  IGRint i,j ,size ,copy_count,nb_root, index;
  struct GRid go_grid,*copy_list,center_grid ,parent;
  IGRshort mat_type;
  struct ret_struct info_struct;
  IGRdouble angle;
  struct GRid active_GRid;

  *EMmsg = MSSUCC;
  active_GRid.objid = NULL_OBJID;

  size  = om$dimension_of(varray = me->info);
  pattern.type = me->pattern_type;
  memcpy(&pattern.var,me->info,size);

  switch(pattern.type)
    {
    case GR_ASCOPY_RECTANGULAR:
      matrix = &pattern.var.matrix;
      memcpy(matrix,me->info,sizeof(struct GRptrn_polar));
      for( index = MATRIX_PAR_X_DELTA; index <= MATRIX_PAR_COLS;index++)
      {
	  status =
	  om$send (msg = message NDnode.NDgive_structure(
					 EMmsg,
					 &info_struct,
					 md_env),
		   p_chanselect = &ND_father,
		   from = index,
		   to =  index);
	  dm$status(action = RET_STATUS);

	  if(!(info_struct.type & parameter_generic))
	    return(OM_E_ABORT);

	  switch(index)
	    {
	    case  MATRIX_PAR_X_DELTA:
	      matrix->Xdelta = 
		info_struct.var.root_pm_st.value;
	      break;
	    case  MATRIX_PAR_Y_DELTA:
	      matrix->Ydelta = 
		info_struct.var.root_pm_st.value;
	      break;
	    case  MATRIX_PAR_ROWS:
	      matrix->rows = 
		(int)(info_struct.var.root_pm_st.value + 1e-14);
	      break;
	    case  MATRIX_PAR_COLS:
	      matrix->cols= 
		(int)(info_struct.var.root_pm_st.value + 1e-14);
	      break;
	    default:
	      return(OM_E_ABORT);
	    }
	}
      memcpy(me->info,matrix,sizeof(struct GRptrn_matrix));
      break;

    case GR_ASCOPY_POLAR:
      polar = &pattern.var.polar;
      memcpy(polar,me->info,sizeof(struct GRptrn_polar));
      for( index = POLAR_PAR_SWEEP_ANGLE; index <= POLAR_PAR_NUM_COPY ;index++)
	{
	  status =
	  om$send (msg = message NDnode.NDgive_structure(
					 EMmsg,
					 &info_struct,
					 md_env),
		   p_chanselect = &ND_father,
		   from = index,
		   to =  index);
	  dm$status(action = RET_STATUS);

	  if(!(info_struct.type & parameter_generic))
	    continue;

	  switch( index)
	    {

	    case POLAR_PAR_SWEEP_ANGLE:
	      polar->sweep_angle = 
		info_struct.var.root_pm_st.value;
	      break;

	    case POLAR_PAR_NUM_COPY:
	      polar->num_copies = 
		(int)(info_struct.var.root_pm_st.value +1e-14);
	      break;
	    default:
	      printf("Pattern:Unknown Polar parent:%d\n",index);
	      break;
	    }
	}
      memcpy(me->info,polar,sizeof(struct GRptrn_polar));
    default:	
#ifdef DEBUG
      printf(" Unknown type:%ld\n",me->pattern_type);
#endif 
      break;
    }

 
  *num_copies = ( me->pattern_type == GR_ASCOPY_RECTANGULAR ?
		  pattern.var.matrix.rows * pattern.var.matrix.cols -1 :
		  pattern.var.polar.num_copies -1);
                  /* number of sweeps not supported*/

  i = ( me->pattern_type == GR_ASCOPY_RECTANGULAR ? 6:5);
 
  status =
  om$send( msg = message NDnode.NDget_objects(
				ND_ROOT|ND_IN_BUF,
                                NULL,
                                0,
                               &copy_list,
                               0,
                               OM_K_MAXINT,
                               &nb_root),
	  targetid = my_id);
  fe$status(action = RET_STATUS);
  parent =  *master_GRid = copy_list[i];
  status = om$send( msg = message NDnode.ASreturn_go(
					    &parent,
					    &mat_type,
					    rot_matrix),
		   targetid = parent.objid,
		   targetos = parent.osnum);
  fe$status(action = RET_STATUS);

  if(!copies) return(OM_S_SUCCESS);

  if( me->pattern_type == GR_ASCOPY_POLAR)
    center_grid = copy_list[POLAR_PAR_CENTER];

  copy_list = *copies;

  status = 
  om$send(msg = message EMSpatfea.EMget_plane_info(
					EMmsg,
					NULL,
					plane,
					md_env),
	  targetid = my_id);
  fe$status(action = RET_STATUS);

  if (EFisAncestryValid(EMmsg, parent.objid, parent.osnum, 
       OPP_EMSsurface_class_id, FALSE))
  {

   status =
    om$send (msg = message EMSsurface.EMgetactiveid(EMmsg, &active_GRid, NULL),
             targetid = parent.objid,
             targetos = parent.osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (active_GRid.objid != parent.objid)
   {
    undo_option = EMS_UNDO_SAVE;
    status = om$send (msg = message EMSsurface. EMmake_active_state(EMmsg,
                      &undo_option, md_env,NULL,NULL,NULL,NULL,NULL,NULL),
             targetid = parent.objid,
             targetos = parent.osnum);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    undone = TRUE;
   }
  }

  ref_point[0] = ref_point[1] = ref_point[2] = 0;
  MAidmx(&long_rc,rot_matrix);
  copy_count = 0;
  if( me->pattern_type == GR_ASCOPY_RECTANGULAR)
    {
      matrix = &pattern.var.matrix;
      xflag = (me->fea_props & REF_DIR_X_NEG ? -1:1);
      yflag = (me->fea_props & REF_DIR_Y_NEG ? -1:1);

      for( i = 0; i< 3; i++)
	{
	  xdir[i] = xflag * plane[i];
	  ydir[i] = yflag * plane[4+i];
	}
      
      for( i = 0; i < matrix->rows; i++)
	{
	  for( j = 0; j < matrix->cols; j++)
	    {
	      if( i ==0 && j== 0 ) continue;
      
	      fe_projpt(ref_point,i*matrix->Xdelta,xdir,mark_pt);
	      fe_projpt(mark_pt,j*matrix->Ydelta,ydir,mark_pt);
	      rot_matrix[3] = mark_pt[0];
	      rot_matrix[7] = mark_pt[1];
	      rot_matrix[11] = mark_pt[2];

	      status = 
	      om$send( msg = message GRgraphics.GRcptform(
					   &long_rc,
					   md_env,
					   rot_matrix,
					   md_env,
					   &copy_list[copy_count].objid),
			senderid = NULL_OBJID,
			targetid = parent.objid,
			targetos = parent.osnum);
              EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	      copy_list[copy_count].osnum = md_env->md_id.osnum;
	      copy_count++;
	    }
	}      
    }
  else /* pattern type is radial */
    {

     status = om$send( msg = message NDnode.ASreturn_go(
					     &go_grid,
					     &mat_type,
					     rot_matrix),
		      targetid = center_grid.objid,
		      targetos = center_grid.osnum);
     EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      as$any_give_structure(go_grid = go_grid,
			    inst = &info_struct,
			    mod_env = md_env);
    
      center[0] = info_struct.var.point_st.pt[0];
      center[1] = info_struct.var.point_st.pt[1];
      center[2] = info_struct.var.point_st.pt[2];
      copy_count = 0;
      MAidmx(&long_rc,rot_matrix);
      ref_point[0] = plane[3];
      ref_point[1] = plane[7];
      ref_point[2] = plane[11];
      polar = &pattern.var.polar;
      xflag = (me->fea_props & REF_DIR_X_NEG ?-1:1);
      BSproj1(&long_rc,center,&plane[8],ref_point,center);

      for( i = 1; i< polar->num_copies; i++)
	{
	  angle = xflag*i*polar->sweep_angle * 1.74532925199432958e-2;
	  MAgrotmx(&long_rc,&plane[8],center,&angle,rot_matrix);

	  status = 
	  om$send( msg = message GRgraphics.GRcptform(
					   &long_rc,
					   md_env,
					   rot_matrix,
					   md_env,
					   &copy_list[copy_count].objid),
			senderid = NULL_OBJID,
			targetid = parent.objid,
			targetos = parent.osnum);
          EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	  copy_list[copy_count].osnum = md_env->md_id.osnum;
	  copy_count++;
	} 
    }

wrapup:
  if (undone)
  {
   IGRlong l_msg;

   undo_option = EMS_UNDO_SAVE;
   om$send (msg = message EMSsurface.EMmake_active_state(&l_msg,
                  &undo_option, md_env,NULL,NULL,NULL,NULL,NULL,NULL),
            targetid = active_GRid.objid,
            targetos = active_GRid.osnum);
  }
  return(OM_S_SUCCESS);
}

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
/*

Description:
      This method will delete all graphic handles and the objects on
      component channel in addtion to deleting itself.

Return values
      *msg completion code - MSSUCC if successful
                           - MSFALI if something fails.
*/
{
  IGRint status;
  IGRlong long_rc;

  if(me->pattern_type == GR_ASCOPY_RECTANGULAR)
    {
      status = 
      om$send(msg = message EMSparameter.EMparam_delete(&long_rc,
						    md_env),
	      p_chanselect = &ND_father,
	      from = 2 , to = 5);
    }
  else
    {
      status = 
      om$send(msg = message EMSparameter.EMparam_delete(&long_rc,
						    md_env),
	      p_chanselect = &ND_father,
	      from = 2 , to = 4);
    }
  fe$status();

/*
  status =
  om$send(msg = message NDnode.NDdelete(md_env),
	  mode = OM_e_wrt_message,
	  p_chanselect=  &ND_children);
  fe$status();
*/
  status =
  om$send(msg = message  NDnode.NDdelete(md_env),
	  mode = OM_e_wrt_message,
	  targetid = my_id);
  fe$status();

  return(OM_S_SUCCESS);
}

method NDmove_to_root( IGRlong *msg; struct GRid *src_grid;
		       struct GRmd_env *md_env)
{
  IGRint status;
  IGRlong long_rc;

  /* Send param delete on the father channel */

  if(me->pattern_type == GR_ASCOPY_RECTANGULAR)
    {
      status = 
      om$send(msg = message EMSparameter.EMparam_delete(&long_rc,
						    md_env),
	      p_chanselect = &ND_father,
	      from = 2 , to = 5);
    }
  else
    {
      status = 
      om$send(msg = message EMSparameter.EMparam_delete(&long_rc,
						    md_env),
	      p_chanselect = &ND_father,
	      from = 2 , to = 4);
    }
  fe$status();

  status =
  om$send(msg = message NDnode.NDdelete(md_env),
	  p_chanselect=  &ND_children);
  fe$status();

  status = 
  om$send( msg = message NDnode.NDdisconnect(0,NULL),
	  targetid = my_id);
  fe$status();  

  status =
  om$send(msg = message Root.delete(1),
	  targetid = my_id);
  fe$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}
method NDmake_source(IGRlong *EMmsg;
		     struct GRid *located_obj,*context_GRid;char *path;
		     GRspacenum as_osnum; struct GRid *as)
{
   IGRint status;
   struct GRid go;

  if(context_GRid->objid  == NULL_OBJID)
    {
      as->objid = my_id;
      as->osnum = OM_Gw_current_OS;
    }
  else
  {
    status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                      targetid = located_obj->objid,
                      targetos = located_obj->osnum);
    if(!(status&1)) go = *located_obj;

    status = ASmake_source_from_go(EMmsg,&go,context_GRid,as_osnum,as);
  }

  return(OM_S_SUCCESS);
}

/*
method NDchildren_deleted(IGRlong *msg;
                           IGRint count_deleted; struct GRid list_deleted []; 
                           struct GRid *new_obj; struct GRmd_env *md_env)
{
  IGRint status;
  struct GRid *children;
  int n_ch;

  status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                         NULL,0,&children,0,OM_K_MAXINT,&n_ch),
                 targetid = my_id);

  status = om$send(msg = OPPmargs,
		   mode = OM_e_wrt_message,
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}
*/

method EMdelete_pattern_node( IGRlong *EMmsg;
			     struct GRid *feature;
			     struct GRmd_env *md_env)
{

  IGRint status ,i,del_count;
  IGRint options, p_count;
  struct GRid p_list[MAX_FEATURE_PARENTS] ,macro;
  OMuint ch_index;
  OM_S_CHANSELECT to_notify;

  status =
  EFget_control_parents((IGRint *)EMmsg, options, 
			1, feature, 0, p_list, &p_count);

  del_count = om$dimension_of( varray= me->deleted);
  om$vla_set_dimension( varray = me->deleted,size = del_count +p_count);

  for( i = 0; i < p_count; i++)
    {
      om$get_index( object_c = me,
		    p_chanselect = &ND_children,
		    objid = p_list[i].objid,
		    osnum2 = p_list[i].osnum,
		    indexaddr = &ch_index);
      me->deleted[del_count +i] = ch_index;
    }

  status = om$make_chanselect (channame = "EMSpatfea.listeners",
             p_chanselect = &to_notify);
  fe$status(action = RET_STATUS);

  status = om$get_objid_at_index(object = me,
				 p_chanselect = &to_notify,
				 index = 0,
				 objidaddr = &macro.objid,
				 osnumaddr = &macro.osnum);
  fe$status(action = RET_STATUS);


  status = om$send ( msg = message EMSsfmacro.EMdelete_macro_node(
							 EMmsg,
							 feature,
							 md_env),
		    targetid = macro.objid,
		    targetos = macro.osnum);
  fe$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}

EMSget_pattern_object(EMmsg,feature,md_env,pattern)
IGRlong *EMmsg;
struct GRid *feature,*pattern;
struct GRmd_env *md_env;
{
  
  IGRint status;
  IGRushort props;
  struct GRid macro;
  OM_S_CHANSELECT to_notify;
  OM_S_OBJECT_LINKAGE *list;

  GRobjid cur_id;
  OMuword cur_os;
  IGRuint l_count; 

  status = om$send(msg = message EMSdpr. EMget_dpr_props ( EMmsg, &props),
		   senderid = NULL_OBJID,
		   targetid = feature->objid,
		   targetos = feature->osnum);
  fe$status(action = RET_STATUS);

  if(!(props & EMS_PATTERN_FEATURE))
  {
    pattern->objid = NULL_OBJID;
    return(OM_S_SUCCESS);
  }


/* Get the parent parent */

  status = om$get_objid_at_index(objid = feature->objid,
				 osnum = feature->osnum,
				 p_chanselect = &ND_father,
				 index = 0,
				 objidaddr = &cur_id,
				 osnumaddr = &cur_os);
  if(!(status &1)) goto wrapup;
  
  status = om$get_objid_at_index(objid = cur_id,
				 osnum = cur_os,
				 p_chanselect = &ND_father,
				 index = 0,
				 objidaddr = &cur_id,
				 osnumaddr = &cur_os);
  if(status &1)
    {
      if(EFisAncestryValid(EMmsg,cur_id,cur_os,OPP_EMSpatfea_class_id,FALSE))
	{
	  pattern->objid = cur_id;
	  pattern->osnum = cur_os;
	  goto wrapup;
	}
    }

  cur_id = feature->objid;
  cur_os = feature->osnum;
  macro.objid = NULL_OBJID;

  while(TRUE)
    {
      status = om$get_objid_at_index(objid = cur_id,
				     osnum = cur_os,
				     p_chanselect = &AS_to_owner,
				     index = 0,
				     objidaddr = &cur_id,
				     osnumaddr = &cur_os);
      if( !(status &1))
	goto wrapup;

      if(EFisAncestryValid(EMmsg,cur_id,cur_os,OPP_EMSslmacro_class_id,FALSE))
	{
	  macro.objid = cur_id;
	  macro.osnum = cur_os;
	  break;
	}
    }

  if(macro.objid == NULL_OBJID)
    goto wrapup;

  status = om$make_chanselect (channame = "GRnotify.notification",
             p_chanselect = &to_notify);
  fe$status(action = RET_STATUS);

  status = om$get_channel_count(objid = macro.objid,
			  	osnum = macro.osnum,
				p_chanselect = &to_notify,
				count = (OMuint *)&l_count);
  fe$status(action = RET_STATUS);

  list = (OM_S_OBJECT_LINKAGE *)
	stackalloc( l_count * sizeof(OM_S_OBJECT_LINKAGE));

  status =
  om$get_channel_objects( objid = macro.objid,
			  osnum = macro.osnum,
			  p_chanselect = &to_notify,
			  list = list,
			  size = l_count,
			  count = (OMuint *)&l_count);
  fe$status(action = RET_STATUS);
  pattern->objid = list[0].S_objid;
  pattern->osnum = list[0].osnum;
 wrapup:
  if( !(status &1))
      pattern->objid = NULL_OBJID;
  return(status);
}

EFget_pattern_feature_defn(EMmsg, feature, axis_normal, param_type,
			   next_until, p_roots,p_count)
IGRlong *EMmsg;
struct GRid *feature, *p_roots;
IGRint *p_count ,*next_until, *param_type;
IGRboolean *axis_normal;
{
  IGRint status;
  IGRlong long_rc, options = NULL;
  IGRuint type, info_size = 0;
  IGRchar *info = NULL;
  GRclassid classid;
  IGRboolean      hole_flag;
  IGRuint         var_par;
  IGRushort       hole_type, depth_type;
  IGRint          part_type;
  IGRboolean      through_hole;
  IGRboolean      ref_plane;
  struct GRid  *roots;
  IGRint root_count;
  struct EMSplace_hole *hole_info;


  *EMmsg = TRUE;
  *next_until = FALSE;
  status = 
  om$get_classid(osnum = feature->osnum,
		 objid = feature->objid,
		 p_classid = &classid);

  if(!(classid == OPP_EMSslslotfea_class_id 
       || classid == OPP_EMSslboolfea_class_id
       || classid == OPP_EMSslfeature_class_id))
    {
      *EMmsg = -1;
      return(FALSE);
    }

  status = om$send( msg = message EMSassoc.EMget_info(
					    EMmsg,
					    options,
					    &type,
					    &info_size,
					    NULL),
		   senderid = NULL_OBJID,
		   targetid = feature->objid,
		   targetos = feature->osnum);
  fe$status(action = RET_STATUS);

  status = 
  om$send(msg = message NDnode.NDget_objects(
			       ND_ROOT|ND_IN_BUF,
			       NULL,
			       0,
			       &roots,
			       0,
		               OM_K_MAXINT,
			       &root_count),
	  senderid = NULL_OBJID,
	  targetid = feature->objid,
	  targetos = feature->osnum);
  fe$status(action = RET_STATUS);

  info = (char *)stackalloc(info_size);
  status = om$send( msg = message EMSassoc.EMget_info(
						  EMmsg,
						  options,
						  &type,
						  &info_size,
						  &info),
		   senderid = NULL_OBJID,
		   targetid = feature->objid,
		   targetos = feature->osnum);
  fe$status(action = RET_STATUS);

  if(classid == OPP_EMSslboolfea_class_id)
    {
      
      EFret_hole_cpart_data_mod(&long_rc, type, &hole_flag, axis_normal, 
				&var_par, &hole_type, &depth_type, &part_type,
				&through_hole, &ref_plane);

      hole_info= (struct EMSplace_hole *)info;

      if(hole_flag)
	{
	  /* Test if the hole type is thru next or thru until*/

	  *axis_normal = TRUE;
	  if( depth_type == 1 || depth_type == 2)
	    *next_until = TRUE;
	  if (hole_info->hole_count >1)
	    {
	      /* Currently not supported */
	      *EMmsg = -1;
	      goto wrapup;
	    }
	  *param_type = ( hole_type == 2 ? PT_CLOSED_CURVE: PT_POINT_TYPE);
	    p_roots[0] = roots[0];
	   *p_count = 1;

	  /* Always copy the axis, but that need not be transformed */
	}
      else
	{	 
	  if((root_count - var_par - 1) > 2)
	    {
	      /* Currently not supported */
	      *EMmsg = -1;
	      goto wrapup;
	    }

	  *param_type =  PT_POINT_TYPE;
	  p_roots[0] = roots[0];
	  *p_count = 1;
/*
	  if( !(*axis_normal))
	    {
	      p_roots[1] = roots[1];
	      (*p_count)++;
	    }
*/
	  /* Other parameters should be same */
	}
    }
  else if(classid == OPP_EMSslslotfea_class_id)
    {
      /* Test  the type of the slot */

      if( type == EMS_AS_THRU_NEXT_SLOT_TYPE ||
	  type == EMS_AS_THRU_UNTIL_SLOT_TYPE)
	*next_until = TRUE;
      p_roots[0] = roots[0];
      *p_count = 1;
      *param_type = PT_OPEN_CURVE;
    }
  else if( classid == OPP_EMSslfeature_class_id)
    {
      struct  EMSAddRm_RecompInfo *slfea_struct;
      *param_type = PT_OPEN_CURVE;
      *p_count = 0;
      if( type == EMS_ASSOC_FEATURE_ADD_MATERIAL ||
	 type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
	{
	  int index = 0;

	  slfea_struct = (struct EMSAddRm_RecompInfo *)info;
	  p_roots[0] = roots[0];
	  (*p_count)++;
	  if( slfea_struct->props & EMSAddRm_Project)
	    {
	      p_roots[1] = roots[1];
	      (*p_count)++;
	    }
	  else if(  slfea_struct->props &  EMSAddRm_Revolve)
	    {
	      p_roots[1] = roots[1];
	      p_roots[2] = roots[2];
	      (*p_count)+=2;
	    }
	  else if(slfea_struct->props &  EMSAddRm_Skinned)
	    {
	      p_roots[1] = roots[1];
	      (*p_count)++;
	    }

	}
      else
	{
	  p_roots[0] = roots[0];
	  *p_count = 1;
	}
    }
 wrapup:
  if( info) stackfree(info);
return(status);
}

EMtransform_pattern_element_assoc(EMmsg ,go_grid,as,rot_matrix,md_env)
IGRlong  *EMmsg;
struct GRid *go_grid,*as;
IGRdouble *rot_matrix;
struct GRmd_env *md_env;
{

  IGRint status;
  IGRuint mytype;
  IGRlong long_rc, one;
  char *clname = NULL;
  struct IGRplane plane;
  IGRdouble point[6];
  IGRdouble l_mat[16];

  extern GRclassid OPP_SKcircle_class_id,
                   OPP_SKarc_class_id,
                   OPP_SKline_class_id,
                   OPP_SKcompcurve_class_id;

  if(EFisAncestryValid(EMmsg, go_grid->objid,
		       go_grid->osnum,
		       OPP_SKcircle_class_id,FALSE))
    clname = "GA3dcircle";
  else if(EFisAncestryValid(EMmsg, go_grid->objid,
			    go_grid->osnum,
			    OPP_SKline_class_id,FALSE))
    clname = "GA3dlineseg";
  else if(EFisAncestryValid(EMmsg, go_grid->objid,
			    go_grid->osnum,
			    OPP_SKarc_class_id,FALSE))
    clname = "GA3dcirarc";
  else if(EFisAncestryValid(EMmsg, go_grid->objid,
			    go_grid->osnum,
			    OPP_SKcompcurve_class_id,FALSE))
    clname = "GAcompcurve";

  if(clname)
    {
      status = om$change_class(objid = as->objid,
			       osnum = as->osnum,
			       sd_override = OM_K_change_class_sd_override,
			       classname = clname);
      fe$status();
    }

  if(rot_matrix)
    {
      plane.point = point;
      plane.normal= &point[3];


      memcpy(l_mat,rot_matrix,16*sizeof(double));
      l_mat[3] = 0;
      l_mat[7] = 0;
      l_mat[11]= 0;

      status = om$send(msg = message GRvg.GRdetplane(EMmsg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&plane),
		       senderid = NULL_OBJID,
		       targetid = go_grid->objid,
		       targetos = go_grid->osnum);
      fe$status(action = RET_STATUS);

      one =1;
      MAptsxform (&long_rc, &one, rot_matrix, point, point);
      MAptsxform (&long_rc, &one, l_mat, &point[3],&point[3]);

      /* Store the information in the GAcurve seg */     
      mytype = EMSuniq_normal;
      status  = om$send(msg = message EMSassoc.EMput_info(EMmsg,
							  (IGRushort )NULL,
							  mytype,
							  6*sizeof(double),
							  (char *)point),
			senderid = NULL_OBJID,
			targetid = as->objid,
			targetos = as->osnum);
      fe$status(action = RET_STATUS);
    }

  return(TRUE);
}

EMSget_pattern_macro_object(EMmsg,pattern,md_env,macro)
IGRlong *EMmsg;
struct GRid *pattern,*macro;
struct GRmd_env *md_env;
{
  IGRint status;
  GRobjid cur_id;
  OMuword cur_os;
  int ind = 0;

  macro->objid = NULL_OBJID;
  
  cur_id = pattern->objid;
  cur_os = pattern->osnum;

  while(TRUE)
    {		
      status = om$get_objid_at_index(objid = cur_id,
				 osnum = cur_os,
				 p_chanselect = &ND_children,
				 index = ind,
				 objidaddr = &cur_id,
				 osnumaddr = &cur_os);
      if( !(status &1))
	goto wrapup;

      if(EFisAncestryValid(EMmsg,cur_id,cur_os,OPP_DMroot_class_id,FALSE))
	{
	  ind++;		/* Search next non dimension child */
	  cur_id  = pattern->objid;
	  cur_os  = pattern->osnum;
	}
      else if(EFisAncestryValid(EMmsg,cur_id,cur_os,OPP_EMSdpr_class_id,FALSE))
	  break;
      else ind = 0;
    }

  while(TRUE)
    {
      status = om$get_objid_at_index(objid = cur_id,
				     osnum = cur_os,
				     p_chanselect = &AS_to_owner,
				     index = 0,
				     objidaddr = &cur_id,
				     osnumaddr = &cur_os);
      if( !(status &1))
	goto wrapup;

      if(EFisAncestryValid(EMmsg,cur_id,cur_os,OPP_EMSslmacro_class_id,FALSE))
	{
	  macro->objid = cur_id;
	  macro->osnum = cur_os;
	  break;
	}
    }
 wrapup:
  if( !(status &1))
      macro->objid = NULL_OBJID;
  return(status);
}
end implementation EMSpatfea;


