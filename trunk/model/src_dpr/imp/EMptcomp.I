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
#include "bserr.h"
#include "bsdotp.h"
#include "dimsrc.h"
#include "EMSasfeatdef.h"

extern GRclassid OPP_EMSsfboolean_class_id, 
                 OPP_DMsrc_class_id,
                 OPP_EMSparamvc_class_id,
                 OPP_EMSslslotfea_class_id,
                 OPP_DMroot_class_id;

from EMSassoc import EMput_info,EMget_info;
from EMSparamgm import EMgetgeom;
method NDcompute_node(
        IGRlong *msg;
        IGRint cn_type;
        IGRint count;
        struct GRid list[];
        struct GRmd_env *md_env)
{ 

  IGRint i, j, index, status,rc;
  IGRlong EMmsg,long_rc;
  struct GRid null_grid, newgrid, fea_parents[MAX_FS_PARENTS];
  struct GRid my_grid,param,par_list[10];
  IGRint create_count, fea_count,num_copies,options,p_count;
  struct GRas_pattern pattern;
  IGRmatrix rot_matrix, plane,matrix;
  IGRint dimension_count, start_index, l_count ,xflag;
  IGRshort matrix_type;
  IGRdouble point[3],ref_pt[3],radius,vector[3],ref_dir[3],
            angle,rdelta;
  IGRint chan_index,delete_count,r_index;
  IGRmatrix otoref;
  struct GRptrn_polar *polar;
  struct ret_struct info_struct;
  IGRdouble center[3],xdir[3],ydir[3];

  if(me->fea_props & NOT_A_FEATURE)
    return(OM_S_SUCCESS);

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status =
  om$send(msg = message EMSpatfea.EMupdate_feature_pattern(
					&long_rc,
					md_env),
	    targetid = my_id);
  fe$status(action = RET_STATUS);

  status = 
  om$send(msg = message EMSpatfea.EMget_pattern_info( &long_rc,
						    &pattern,
						    md_env),
	  targetid = my_id);
  fe$status(action = RET_STATUS);

  status = om$get_channel_count(object = me,
				p_chanselect = &ND_children,
				count = (OMuint *)&l_count);
  fe$status(action = RET_STATUS);

  create_count = 0;
  fea_count = 0;

  for( i = 0 ; i < count ; i++)
  {
    if(EFisAncestryValid(&EMmsg,list[i].objid,
			 list[i].osnum,
			 OPP_EMSsfboolean_class_id,TRUE))
      fea_parents[fea_count++] = list[i];
  }

      status = om$send(msg = message EMSpatfea.EMget_copy(
					&EMmsg,
                                        i,
                                        (struct GRid *)NULL,
                                        &null_grid,
                                        fea_parents,
                                        fea_count,
                                        &create_count,
                                        create_count,
                                        md_env,
                                        NULL),
		       targetid = my_id);
      fe$status(action = RET_STATUS);

  status = om$send(msg = message EMSpatfea.EMget_plane_info(
					&EMmsg,
					list,
					plane,
					md_env),
		   targetid = my_id); 
  fe$status(action = RET_STATUS);

  /* Compute the transformation matrix from the original to 
     reference point in otoref, this should be got from
     first feature located.
  */
  MAidmx(&long_rc,otoref);
  
  dimension_count = 0;

  delete_count = om$dimension_of(varray = me->deleted);

  for(i = l_count -1; i> 0; i --)
    {
      status = om$get_objid_at_index( object = me,
                                     p_chanselect = &ND_children,
                                     index = i,
                                     objidaddr = &newgrid.objid,
                                     osnumaddr = &newgrid.osnum);
      fe$status(action = RET_STATUS);

      if (EFisAncestryValid(&EMmsg, newgrid.objid,
			    newgrid.osnum,
			    OPP_DMroot_class_id, TRUE))
	dimension_count++;
    }
  MAidmx(&long_rc,rot_matrix);
  switch(me->pattern_type)
  {

  case GR_ASCOPY_SINGLE:
    if(l_count != (create_count + dimension_count))
    {
      return(OM_E_ABORT);
    }

    center[0] = plane[3];
    center[1] = plane[7];
    center[2] = plane[11];

    MAtypemx(&long_rc,otoref,&matrix_type);

    for(index = 0; index < create_count; index++)
      {
	status = om$get_objid_at_index(
			    object = me,
			    p_chanselect = &ND_children,
			    index = index,
			    objidaddr=&param.objid,
			    osnumaddr=&param.osnum);
	fe$status(action = RET_STATUS);
				       
	
	status=
	EFtransform_feature_copy(
		   &EMmsg,
		   &my_grid,
		   param,
		   null_grid,
		   center,
		   rot_matrix,
		   md_env);
	fe$status(action = RET_STATUS);
      }
    
    break;

  case GR_ASCOPY_LINEAR:
 
    if (me->fea_props & BASE_FEATURE_INCLUDED)
      {
	num_copies = pattern.var.linear.num_copies -1;
	index = 1 ;
      }
    else
      {
	num_copies = pattern.var.linear.num_copies ;
	index = 0;
      }

    if(l_count != (create_count * num_copies + dimension_count))
    {
      return(OM_E_ABORT);
    }

    start_index = 0;
    for( i = index ; i < num_copies; i++)
    {
      status = om$send(msg = message EMSpatfea.get_xform_at_index(
						   &EMmsg,
						   i,
						   plane,
						   rot_matrix,
						   md_env),
		       targetid = my_id);
      fe$status(action = RET_STATUS);

      for( index = 0; index < create_count; index++)
      {
	status = om$get_objid_at_index( object = me,
				     p_chanselect = &ND_children,
                                     index = start_index + index,
                                     objidaddr = &param.objid,
                                     osnumaddr = &param.osnum);
        fe$status(action = RET_STATUS);

	status =
	EFtransform_feature_copy(&EMmsg,
				 &my_grid,
				 param,
				 null_grid,
				 otoref,
				 rot_matrix,
				 md_env);
	fe$status(action = RET_STATUS);
      }
      start_index +=create_count;
    }    
    break;

  case GR_ASCOPY_RECTANGULAR:

    num_copies = pattern.var.matrix.rows * pattern.var.matrix.cols;

    index = ( me->fea_props & BASE_FEATURE_INCLUDED ? 1:0 );

    num_copies = ( me->fea_props & BASE_FEATURE_INCLUDED ? 
		   num_copies -1: num_copies);

    if(l_count != (create_count * num_copies + dimension_count))
      fe$status( msg = "numcopies donot match", 
		action = RET_VALUE,value= OM_E_ABORT);

    status = om$send(msg = message EMSpatfea.get_xform_at_index(
					    &EMmsg,
					    0,
					    plane,
					    rot_matrix,
					    md_env),
		     targetid = my_id);
    fe$status(action = RET_STATUS);

    chan_index = 0;
    point[0] = point[1] =  point[2] = 0.0;

    for( i = 0; i < 3; i++)
      {
	center[i] = plane[3 +4 *i];
	if(me->fea_props & REF_DIR_X_NEG)
	  {
	    xdir[i] = -plane[i];
	  }
	else
	    xdir[i] = plane[i];

	if(me->fea_props & REF_DIR_Y_NEG)
	  {
	    ydir[i] = -plane[4+i];
	  }
	else
	  ydir[i] = plane[4+i];
      }

    for( i = 0; i < pattern.var.matrix.rows; i++)
    {
      for(j = (!i && index)? 1:0; j< pattern.var.matrix.cols; j++)
      {
	IGRint ind;

	
	MATH_ptdelta(&rc,point,xdir,
		     i* pattern.var.matrix.Xdelta,
		     ref_pt);

	MATH_ptdelta(&rc,ref_pt,ydir,
		     j*pattern.var.matrix.Ydelta,
		     ref_pt);

	rot_matrix[3]  = ref_pt[0];
	rot_matrix[7]  = ref_pt[1];
	rot_matrix[11] = ref_pt[2];

	for( ind= 0; ind < fea_count; ind++)
	  {
	    int ii;
	    p_count = options = 0;
	    status =
	    EFget_control_parents(&EMmsg,options,1,
				  &fea_parents[ind],0,
				  par_list,&p_count);
	    status =
	    EFcheck_deleted_fea(&long_rc,
				&delete_count,
				me->deleted,
				(i*pattern.var.matrix.cols -1 + j),&r_index);

	    if(long_rc == OM_S_SUCCESS ) continue;

	    for( ii = 0;ii < p_count; ii++)
	      {
		status = om$get_objid_at_index(object = me,
					       p_chanselect = &ND_children,
					       index = chan_index ,
					       objidaddr = &param.objid,
					       osnumaddr = &param.osnum);
		fe$status(action = RET_STATUS);	      
		
		status =
		EFtransform_feature_copy(&long_rc,
					 &my_grid,
					 param,
					 par_list[ii],
					 center,
					 rot_matrix,
					 md_env);
		fe$status(action = RET_STATUS);
		chan_index++;
	      }
	  }
      }
    }
  
    break;

  case GR_ASCOPY_POLAR:

    polar = &pattern.var.polar;
    num_copies = polar->num_copies * polar->num_sweeps;

    index = (me->fea_props & BASE_FEATURE_INCLUDED ? 1:0);
    num_copies = (me->fea_props & BASE_FEATURE_INCLUDED ?
		  num_copies -1 : num_copies);

    if(l_count != (create_count * num_copies + dimension_count))
      fe$status( msg = "numcopies donot match", 
		action = RET_VALUE,value= OM_E_ABORT);

    radius = polar->radius;
    rdelta = 0.0;
    status = om$send( msg = message NDnode.ASreturn_go(
					     &param,
					     &matrix_type,
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

    ref_pt[0]= plane[3];
    ref_pt[1]= plane[7];
    ref_pt[2]= plane[11];

    BSproj1(&long_rc,center,&plane[8],ref_pt,center);

    BSmkvec(&long_rc, ref_dir, center, ref_pt);
    BSnorvec(&long_rc,ref_dir);

    /* compute vector along starting direction

    MATH_rotate_vector(&long_rc,
		       vector,
		       polar->start_angle,
		       plane,
		       vector);
    */

    if(polar->start_angle >0.0)
      MAgrotmx(&long_rc,&plane[8],center,&polar->start_angle,rot_matrix);

    xflag = (me->fea_props & REF_DIR_X_NEG ?-1:1);
    chan_index =0;
    for( i = index; i < polar->num_copies;i++)
      {
	angle = polar->start_angle + xflag*i *polar->sweep_angle * 
	        1.74532925199432958e-2;

	MAgrotmx(&long_rc,&plane[8],center,&angle,rot_matrix);

	MATH_rotate_vector(&long_rc,
			   ref_dir,
			   angle,
			   plane,
			   vector);
	for( j =(!i&&index)?1:0; j < polar->num_sweeps; j++)
	  {
	    int ind;
	    long_rc = 0;
	    status = 
	    EFcheck_deleted_fea(&long_rc,
				&delete_count,
				me->deleted,
				(i*polar->num_sweeps -1 + j) ,&r_index);
	    if(long_rc == OM_S_SUCCESS) continue;
/*
	    MATH_ptdelta(&rc,ref_pt,vector,(radius + j*rdelta),end_pt);

	    rot_matrix[3] = end_pt[0] - center[0];
	    rot_matrix[7] = end_pt[1] - center[1];
	    rot_matrix[11] = end_pt[2] - center[2];
*/
	    for( ind = 0; ind< fea_count; ind++)
	      {
		int ii;
		p_count = options = 0;
		status =
		EFget_control_parents(&EMmsg,options,1,
					&fea_parents[ind],0,
					par_list,&p_count);
		for(ii = 0; ii <p_count; ii++)
		  {
		    status = om$get_objid_at_index(object = me,
						   p_chanselect = &ND_children,
						   index = chan_index,
						   objidaddr = &param.objid,
						   osnumaddr = &param.osnum);
		    fe$status(action = RET_STATUS);

		    status=
		    EFtransform_feature_copy(&long_rc,
					     &my_grid,
					     param,
					     par_list[ii],
					     ref_pt,
					     rot_matrix,
					     md_env);
		    fe$status(action = RET_STATUS);
		    chan_index++;
		  }
	      }
	  }
      }
     break;

  default:
    fe$status(msg = " Unknown pattern type:",action = RET_VALUE,
	      value = OM_E_ABORT);
  }

  /* Update dimensions */
  
  return(OM_S_SUCCESS);
}

method get_xform_at_index(IGRlong *msg;
			  IGRint index ;
			  IGRdouble  *ref_plane;
			  IGRmatrix rot_matrix;
			  struct GRmd_env *md_env)
{
  IGRint status;
  IGRlong long_rc;
  struct GRas_pattern pattern;
  struct IGRbsp_curve *bsp_curve;
  IGRdouble point[3],u_par,incr;
  struct GRid go_grid;
  struct GRptrn_along_ele   *linear;
  IGRmatrix plane;
	
  status = om$send(msg = message EMSpatfea.EMget_pattern_info(
				     &long_rc,
                                     &pattern,
                                     md_env),
		   targetid = my_id);
  fe$status(action = RET_STATUS);

  MAidmx(&long_rc,rot_matrix);

  if(!ref_plane)
  {
      status = om$send(msg = message EMSpatfea.EMget_plane_info(
					&long_rc,
					NULL,
					plane,
					md_env),
		   targetid = my_id);
      fe$status(action = RET_STATUS);
      ref_plane = plane;
  }

  switch(me->pattern_type)
  {
  case GR_ASCOPY_LINEAR:
    /* Get the curve parameters  at the index specified */
    linear = &pattern.var.linear;
    
    status =
      om$send(msg = message NDnode.ASreturn_go(&go_grid,
				  &md_env->md_env.matrix_type,
				  md_env->md_env.matrix),
	      p_chanselect = &ND_father,
	      from = LINEAR_PAR_CURVE_ELEM, 
	      to = LINEAR_PAR_CURVE_ELEM);
    fe$status(action = RET_STATUS);

    status =
    om$send(msg = message GRvg.GRgenabsg(&long_rc,
					 &md_env->md_env.matrix_type,
					 md_env->md_env.matrix,
					 (char **)&bsp_curve),
	    targetid = go_grid.objid,
	    targetos = go_grid.osnum);
    fe$status(action = RET_STATUS);

    incr= (linear->end_uparm - linear->start_uparm)/ linear->num_copies;

    u_par = linear->start_uparm  + index* incr;
    BScveval(bsp_curve,u_par,0, point,&long_rc);
    if(long_rc != BSSUCC)
      return(FALSE);

    rot_matrix[3] = point[0];
    rot_matrix[7] = point[1];
    rot_matrix[11] = point[2];
    break;
  case GR_ASCOPY_RECTANGULAR:
  break;
    /* Currently the rot matrix is nothing */

  case GR_ASCOPY_POLAR:
    /* Compute the vector at the start angle */
   break;
  default:
#ifdef DEBUG
    printf(" Unknown pattern type:%d\n",me->pattern_type);
#endif
    break;
  }
  return(OM_S_SUCCESS);
}

EFtransform_feature_copy(msg,my_grid,param,parent,origin,rot_matrix,md_env)
IGRlong *msg;
struct GRid param,parent,*my_grid;
IGRmatrix rot_matrix;
IGRdouble *origin;
struct GRmd_env *md_env;
{
  IGRint status, rc,i;
  IGRlong long_rc;
  struct dim_ret_struct ret_struct;
  struct ret_struct ret;
  struct GRid new,go_grid ,feature, o_feature;
  OM_S_CHANSELECT to_notify;
  IGRlong one = 1;
  IGRmatrix t_mat;
  extern GRclassid OPP_GAcurve_class_id;

  if (EFisAncestryValid(msg, parent.objid,
			parent.osnum,
			OPP_EMSparamvc_class_id, TRUE))    
    {
	  struct EMSgeomdata axis;

	  status = om$send(msg = message EMSparamgm.EMgetgeom(
					     msg,
					     NULL,
					     &md_env->md_env.matrix_type,
					     md_env->md_env.matrix,
					     &axis),
			   senderid = NULL_OBJID,
			   targetid = parent.objid,
			   targetos = parent.osnum);
	  fe$status(action = RET_STATUS);

      memcpy(t_mat,rot_matrix,16*sizeof(double));
      t_mat[3] = t_mat[7] = t_mat[11] =  0.0;

	  MAptsxform(&long_rc,&one,t_mat, axis.vector,
		     ret_struct.var.dm_line.line);

	  ret_struct.type = DMconstln;
	  ret_struct.var.dm_line.line[3] =
	   ret_struct.var.dm_line.line[4] = 
	   ret_struct.var.dm_line.line[5] = 0.0;
 /* 
	printf(" axis vector:%lf %lf %lf\n", axis.vector[0],axis.vector[1],
		axis.vector[2]);
	printf(" axis vector:%lf %lf %lf\n", ret_struct.var.dm_line.line[0],
	  ret_struct.var.dm_line.line[1],
	  ret_struct.var.dm_line.line[2]);
*/
  

	  status = 
	    om$send(msg = message dim_src.DMgive_structure(
					&rc,
					0, /* unused*/
					1,
					&ret_struct,
					md_env),
		    senderid = NULL_OBJID,
		    targetid = param.objid,
		    targetos = param.osnum);
	  fe$status(action = RET_STATUS);

    }
  else if (EFisAncestryValid(msg, param.objid,
			param.osnum,
			OPP_DMsrc_class_id, TRUE))    
    {

      status = om$send (msg = message NDnode.NDgive_structure (&long_rc,
                              &ret, md_env),
                        senderid = NULL_OBJID,
                        targetid = parent.objid,
                        targetos = parent.osnum);

      if( ret.type != point_generic) return( OM_E_ABORT);
      MAptsxform(&long_rc,&one,rot_matrix,ret.var.point_st.pt,
		 ret_struct.var.dm_pt.point);
      ret_struct.type = DMconstpt;

     status = 
     om$send(msg = message dim_src.DMgive_structure(
					&rc,
					0, /* unused*/
					1,
					&ret_struct,
					md_env),
	     senderid = NULL_OBJID,
	     targetid = param.objid,
	     targetos = param.osnum);
     fe$status(action = RET_STATUS);
   }
  else
    { IGRint md_id_save;

      status = om$make_chanselect(channame ="GRnotify.notification",
                                p_chanselect = &to_notify);
      fe$status(action = RET_STATUS);

      status =
      om$send(msg = message NDnode.ASreturn_go(&go_grid,
				  &md_env->md_env.matrix_type,
				  md_env->md_env.matrix),
	      senderid = NULL_OBJID,
	      targetid = param.objid,
	      targetos = param.osnum); 
      fe$status(action = RET_STATUS);

      md_id_save = md_env->md_id.objid;
      md_env->md_id.objid = NULL_OBJID;

      status = 
      om$send( msg = message GRgraphics.GRcptform(
					   &long_rc,
					   md_env,
					   rot_matrix,
					   md_env,
					   &new.objid),
	      senderid = NULL_OBJID,
	      targetid = parent.objid,
	      targetos = parent.osnum);
      fe$status(action = RET_STATUS);
      new.osnum = md_env->md_id.osnum;
      md_env->md_id.objid = md_id_save;

      if(EFisAncestryValid(&long_rc, go_grid.objid,
                           go_grid.osnum,
                           OPP_GAcurve_class_id,FALSE))
	{
	  EMtransform_pattern_element_assoc(&long_rc,&parent,&new,rot_matrix,md_env);

	  status = om$send(msg = message Root.move_chan(ND_father,
							go_grid.objid,
							go_grid.osnum,
							ND_father),
			   senderid = new.objid,
			   targetid = new.objid,
			   targetos = new.osnum);
	  fe$status();
	  status = om$send(msg = message Root.move_chan(ND_children,
							go_grid.objid,
							go_grid.osnum,
							ND_children),
			   senderid = new.objid,
			   targetid = new.objid,
			   targetos = new.osnum);
	  fe$status();
	}
      else
	{
	  status = om$get_objid_at_index(objid = param.objid,
					 osnum = param.osnum,
					 index = 0,
					 p_chanselect = &ND_children,
					 objidaddr = &feature.objid,
					 osnumaddr = &feature.osnum);
	  fe$status(action = RET_STATUS);

	  if ( EFisAncestryValid(&long_rc, feature.objid, feature.osnum , 
				 OPP_EMSslslotfea_class_id, FALSE ) ) 
	    { 
	      IGRvector o_normal , o_mat_dir , cv_normal , mat_dir ; 
	      struct EMSplace_slot slot_info ; 
	      IGRuint type , info_size , l_count; 
	      IGRboolean is_nor_rev , is_dir_rev ; 
	      char *info;
	      OM_S_OBJECT_LINKAGE *obj;

	      status = om$get_channel_count(objid = my_grid->objid,
					    osnum = my_grid->osnum,
					    p_chanselect = &ND_father,
					    count = (OMuint *)&l_count);
	      fe$status(action = RET_STATUS);

	      obj = (OM_S_OBJECT_LINKAGE *)
		stackalloc( l_count * sizeof(OM_S_OBJECT_LINKAGE));

	      status =
	      om$get_channel_objects( objid = my_grid->objid,
				     osnum = my_grid->osnum,
				     p_chanselect = &ND_father,
				     list = obj,
				     size = l_count,
				     count = (OMuint *)&l_count);
	      fe$status(action = RET_STATUS);
	      
	      o_feature.objid = obj[l_count -1].S_objid,
	      o_feature.osnum = obj[l_count -1].osnum;

	      info = NULL;
	      
	      EFcompute_slot_curve_normal(&long_rc, &parent, md_env, 
					  o_mat_dir , o_normal ) ; 

	      EFcompute_slot_curve_normal(&long_rc, &new, md_env, 
					  mat_dir, cv_normal ) ; 

	      memcpy ( t_mat , rot_matrix , 16 * sizeof ( IGRdouble ) ) ; 
	      t_mat [ 3 ] = t_mat [ 7 ] = t_mat [ 11 ] = 0.0 ; 

	      MAptsxform (&long_rc, &one ,t_mat ,o_normal ,o_normal ) ; 
	      MAptsxform (&long_rc, &one, t_mat, o_mat_dir, o_mat_dir ) ; 

	      is_nor_rev =(BSdotp(&long_rc, o_normal, cv_normal)>0.0 ? 0:1) ; 
	      is_dir_rev =(BSdotp(&long_rc, o_mat_dir, mat_dir )>0.0 ? 0:1) ; 


	      status = om$send( msg = message EMSassoc.EMget_info(
							&long_rc,
							NULL,
							&type,
							&info_size,
							NULL),
			       senderid = NULL_OBJID,
			       targetid = o_feature.objid,
			       targetos = o_feature.osnum);
	      fe$status(action = RET_STATUS);

	      if( info_size == sizeof(struct EMSplace_slot))
		{
		  info = (char *) &slot_info;
		  
		  status = om$send( msg = message EMSassoc.EMget_info(
							&long_rc,
							NULL,
							&type,
							&info_size,
							&info),
				   senderid = NULL_OBJID,
				   targetid = o_feature.objid,
				   targetos = o_feature.osnum);
		  fe$status(action = RET_STATUS);
		  
		  if ( is_dir_rev ) 
		    slot_info.dir_rev = !slot_info.dir_rev ; 
		  if ( is_nor_rev ) 
		    slot_info.pro_nor_rev = !slot_info.pro_nor_rev; 

		  status =
		  om$send(msg = message EMSassoc.EMput_info( &long_rc,
						 NULL,
						 type,
						 info_size,
						 (IGRchar *)&slot_info),
			  senderid = NULL_OBJID,
			  targetid = feature.objid,
			  targetos = feature.osnum);
		  fe$status(action = RET_STATUS);
		}
	    }

	  status = 
	  om$send( msg = message Root.move_chan( to_notify,
					    go_grid.objid,
					    go_grid.osnum,
					    to_notify),
		    senderid = new.objid,
		    targetid = new.objid,
		    targetos = new.osnum);
	  fe$status(action = RET_STATUS);

	}
      status = om$send(msg = message GRgraphics.GRdelete(&long_rc,
							 md_env),
		       senderid = go_grid.objid,
		       targetid = go_grid.objid,
		       targetos = go_grid.osnum);
    }
  return(TRUE);
}

EFcheck_deleted_fea(long_rc,delete_count,deleted,index,r_index)
IGRlong *long_rc;
IGRshort *deleted;
IGRint *delete_count;
IGRint index, *r_index;
{
  IGRint i,val_changed = 0;
  
  *r_index = 0;
  for( i = 0; i < *delete_count;i++)
    if(index == deleted[i])
      {
	val_changed = TRUE;
	*r_index  = i;
	break;
      }
  if(val_changed) *long_rc = TRUE;
  else *long_rc = FALSE;
  return(TRUE);
}

end implementation EMSpatfea;







