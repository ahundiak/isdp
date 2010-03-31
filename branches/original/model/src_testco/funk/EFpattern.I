class implementation EMSpatfea;

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "bserr.h"		/* Math error return codes */
#include "bsnorvec.h"
#include "bscvnormal.h"
#include "bscveval_b.h"
#include "bscrossp.h"
#include "bsbx2.h"
#include "dpmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ECpattern.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include <math.h>

extern IGRdouble BSlenvec(),BSdotp();
from EMSparamvl import EMconstruct;
from ECfepattern import show_axis;
from IGEgragad import DPinrot;
extern GRclassid OPP_EMSslboolfea_class_id,
                 OPP_EMSslslotfea_class_id,
                 OPP_DMroot_class_id;

EFfepat_add_copies(list, new_list, list_count, new_count, create_count)
 struct GRid *list,*new_list;
 IGRint *list_count,new_count,create_count;
{
  IGRint status, i, td_count;
  IGRlong long_rc;

  for( i = 0; i < create_count; i++)
    {
      if (!EFisAncestryValid(&long_rc,new_list[new_count+i].objid,
			     new_list[new_count+i].osnum,
			     OPP_DMroot_class_id, TRUE))
	{
	  status = 
	  om$get_channel_count(objid = new_list[new_count+i].objid,
			       osnum = new_list[new_count+i].osnum,
			       p_chanselect = &ND_children,
			       count = (OMuint *)&td_count);
	  if(( status &1 ) && td_count)
	    list[(*list_count)++] = new_list[new_count+i];
	}
    }

  return(TRUE);
}

EFget_id_from_pattern( msg, value, exp_grid,md_env)
IGRint *msg;
IGRdouble value;
struct GRid *exp_grid;
struct GRmd_env *md_env;
{
  IGRint i, status, options;
  IGRlong long_rc;
  IGRchar sname[DI_PATH_MAX];
  struct GRid obj;
  IGRboolean aflag;
  GRspacenum osn;


  i = 0;
  *msg = MSSUCC;
  while(1)
    {
     sprintf(sname,"S%d",i);
     i= i+1;
     aflag = pwIsActivationOn();
     if(aflag)
     {
      osn = pwGetActiveOs();
      status = di$translate(objname = sname, osnum = osn, p_objid = &obj.objid);
     }
     else
      status = di$translate(objname = sname, p_objid = &obj.objid);

     if(status != DIR_S_SUCCESS)
       break;

    }

  status = 
  om$construct(classid = OPP_EMSparamvl_class_id,
	       p_objid = &exp_grid->objid,
	       msg = message EMSparamvl.EMconstruct(
					 &long_rc,
					 options,
					 value,
					 sname),
	       osnum = md_env->md_id.osnum);
  fe$status( action = RET_STATUS);
  exp_grid->osnum = md_env->md_id.osnum;

  return(TRUE);
}

EFget_reference_point_from_feature(msg,feature_id,ref_id)
IGRlong *msg;
struct GRid feature_id,*ref_id;
{
  IGRint status;
  struct GRid par_roots[MAX_FEATURE_PARENTS];
  IGRint count;
  IGRboolean axis_normal;
  IGRint param_type, next_until;

  status  = EFget_pattern_feature_defn(msg, 
				       &feature_id,
				       &axis_normal,
				       &param_type,
				       &next_until,
				       par_roots,
				       &count);
  if(*msg < 0 || *msg == MSFAIL) return(FALSE);

  if( param_type == PT_POINT_TYPE)
    {
      *ref_id = par_roots[0];
    }
  else if( param_type == PT_CLOSED_CURVE)
    {
      ref_id->objid = NULL_OBJID;
    }
  else 
    ref_id->objid = NULL_OBJID;

  return(TRUE);
}

IGRint ECpattern_locate_dynamics(grid, event, cmd)
 struct GRid  *grid;
 struct GRevent  *event;
 struct GRid  *cmd;
 
{
  IGRint status;
  IGRlong long_rc;

  status = 
  om$send( msg = message ECfepattern.show_axis(&long_rc,
					        event),
	  senderid = NULL_OBJID,
	  targetid = cmd->objid,
	  targetos = cmd->osnum);
  fe$status(action = RET_STATUS);
  return(TRUE);
} 

IGRint ECget_window_dittol (win_grid, dittol)
     struct GRid  *win_grid;
     IGRdouble  *dittol;
{
  IGRint ret_stat,status;
  IGRlong msg;
  struct var_list list_var[2];
  IGRdouble vwscale;

  gr$get_dit_tolerance(msg = &msg, 
		       buffer = dittol, 
		       nret = &ret_stat);

  list_var[0].var = VVOL_VIEWPORT_SCALE;
  list_var[0].var_ptr = (char *)&vwscale;
  list_var[0].num_bytes = sizeof (IGRdouble);
  list_var[0].bytes_returned = (IGRlong *)&ret_stat;
  
  list_var[1].var = END_PARAM;
  list_var[1].var_ptr = NULL;
  list_var[1].num_bytes = 0;
  list_var[1].bytes_returned = NULL;

  status = 
  dp$inq_set_gragad (msg = &msg,
		     osnum = win_grid->osnum, 
		     gragad_objid = win_grid->objid, 
		     which_error = &ret_stat,
		     var_list = list_var);
  fe$status(action= RET_STATUS);
  (*dittol) /= vwscale;
  return(TRUE);
}

EFshow_dynamic_arrow(rc, win_grid,reference_point,center,plane,vec,state,button_data,dynamics)
IGRlong *rc;
struct GRid *win_grid;
IGRdouble *reference_point,*plane,*vec,*center;
struct EX_button *button_data;
int state,dynamics;
{
  struct IGRpolyline line;
  IGRdouble ref_line[15];
  IGRint EMpattern_dyn();
  struct IGRdisplay display;
  struct EMSdyn_pattern dyn_pattern;
  IGRint status;
  IGRlong long_rc;
  IGRmatrix rot_matrix;

  
  *rc = OM_S_SUCCESS;

  ECget_window_dittol (win_grid, &dyn_pattern.dittol);
 
  memcpy(dyn_pattern.ref_point,reference_point,3*sizeof(IGRdouble));
  memcpy(dyn_pattern.plane,plane,16*sizeof(double));
  memcpy(dyn_pattern.vec,vec,3*sizeof(double));
  memcpy(dyn_pattern.center,center,3*sizeof(double));
  dyn_pattern.state = state;
	
  line.num_points = 5;
  line.points = ref_line;

  display.color = 1;
  display.weight = 0;
  display.style = 0;


  dp$build_dis_buffer(
	   buffer = &dyn_pattern.arrow_buf,
	   type = IGRPY,
	   display_att = &display,
	   geometry = &line);


  if(dynamics)
    {
      dp$dynamics(dyn_fun = EMpattern_dyn ,
		  information=(char *)&dyn_pattern);
  
    }
  else
    {
      /* Get the rotation matrix from the button Data */

      status = 
      om$send(msg = message IGEgragad.DPinrot(&long_rc,rot_matrix),
	      senderid  = NULL_OBJID,
	      targetid  = win_grid->objid,
	      targetos  = win_grid->osnum);

      EMpattern_dyn(&dyn_pattern, button_data, rot_matrix, NULL,NULL,
		  NULL, NULL,
		  NULL,NULL,NULL,
		  NULL,NULL,NULL);
    }

  memcpy(vec,dyn_pattern.vec,3*sizeof(double));

  return(TRUE);
}
#define SCALE_FACTOR 1.5
#argsused
IGRint EMpattern_dyn(info, pnt, rot_matrix, objects, num_objects,
		     buffer, num_buffers,
		     in_dummy1, in_dummy2, in_dummy3,
		     out_dummy1, out_dummy2, out_dummy3)

char			*info;
struct EX_button	*pnt;
IGRdouble               *rot_matrix;
struct GRid		**objects;
IGRint			*num_objects;
struct DPele_header	**buffer;
IGRint			*num_buffers;
IGRchar			**in_dummy1 , **in_dummy2 , **in_dummy3 ;
IGRchar			**out_dummy1, **out_dummy2, **out_dummy3;
{
  IGRint rc, i;
  IGRlong long_rc;
  BSrc bsrc;
  struct IGRpolyline *pline;
  IGRdouble ref_line[15],newpt[3];
  struct EMSdyn_pattern *dyn_pattern;
  IGRdouble point[3],point2[3],plane_perp,p_normal[3], 
            pt_on_plane[3],pt_proj[3],dotp, *perpvec ,
            rdir[3],ref_dir[3] ,rad;
  
  dyn_pattern = (struct EMSdyn_pattern *)info;
  point[0] = pnt->x;
  point[1] = pnt->y;
  point[2] = pnt->z;

  dotp = BSdotp(&rc,&rot_matrix[8], &dyn_pattern->plane[8]);
  plane_perp = (fabs(dotp) < 0.001);

  for( i = 0; i < 3; i++)
  {
    p_normal[i] = dyn_pattern->plane[8+i];
    pt_on_plane[i] = dyn_pattern->ref_point[i];
    point2[i] = point[i] + ( plane_perp ?
			    rot_matrix[8+i]:dyn_pattern->plane[8+i]);
  }

  /* Project the user point on to  plane */

  BSxlnpl(&rc,p_normal,pt_on_plane,point,point2,pt_proj);

  /* Construct a dynamic arrow between current point and ref point */

  if ( dyn_pattern->state == GET_RADIAL_DIR)
    {
      BSmkvec(&long_rc, rdir , dyn_pattern->center,dyn_pattern->ref_point);
      rad = BSlenvec(&long_rc,rdir);
      BSnorvec(&long_rc, rdir);
      BScrossp(&long_rc, rdir,p_normal,ref_dir);
    }

  for( i = 0; i< 3; i++)
    {
      ref_line[i] = dyn_pattern->ref_point[i];
      if(dyn_pattern->state == SEL_MAT_DIR_X)
	{
	  ref_line[3+i] = dyn_pattern->ref_point[i] + dyn_pattern->plane[i];
	  perpvec = &dyn_pattern->plane[4];
	}
      else if(dyn_pattern->state == SEL_MAT_DIR_Y)
	{
	  ref_line[3+i] = dyn_pattern->ref_point[i] + dyn_pattern->plane[4 +i];
	  perpvec = &dyn_pattern->plane[0];
	}
      else if ( dyn_pattern->state == GET_RADIAL_DIR)
	{
	  ref_line[i] = dyn_pattern->ref_point[i];
	  ref_line[3+i] =  ref_line[i] + rad*ref_dir[i];
	  perpvec = rdir;
	}
    }
  
  /* Project the cursor on the line */
  
  BSproj0(&rc,pt_proj,ref_line,newpt);

  for( i = 0; i < 3; i++)
    {
      ref_line[3+i] = newpt[i];
      ref_line[9+i] = newpt[i];
    }

  BSmkvec( &rc, dyn_pattern->vec, dyn_pattern->ref_point,newpt);

  BSnorvec(&bsrc,dyn_pattern->vec);

  for( i = 0 ; i< 3; i++)
    newpt[i] = ref_line[3+i] - dyn_pattern->dittol*SCALE_FACTOR * 
                               dyn_pattern->vec[i];

  for( i = 0; i< 3; i++)
    {
      ref_line[6+i] = newpt[i] + perpvec[i]*SCALE_FACTOR * dyn_pattern->dittol;
      ref_line[12+i]= newpt[i] - perpvec[i]*SCALE_FACTOR * dyn_pattern->dittol;
    }

  pline = dyn_pattern->arrow_buf.geometry.polyline;
  memcpy(pline->points,ref_line,15*sizeof(IGRdouble));

  if( num_objects)
    {
      *num_objects = 0;
      *num_buffers = 1;
      *buffer = &dyn_pattern->arrow_buf;
    }
  else
    {
      dp$display(msg = &long_rc, 
		 mode = GRhd, 
		 num_elem = 1,
		 buffer = &dyn_pattern->arrow_buf);
    }
  return(TRUE);
}

EFcompute_slot_curve_normal(msg, go_grid, md_env, cv_normal, b_normal)
IGRlong *msg;
struct GRid *go_grid;
struct GRmd_env *md_env;
IGRdouble *cv_normal, *b_normal;
{
  IGRint status;
  IGRlong long_rc;
  struct IGRbsp_curve *curve;
  IGRvector normal;
  IGRpoint point_on_curve;

  IGRvector	tangent_vector, normal_vector;

  *msg = MSSUCC;

  /* - Get the curve geometry */

  status = om$send(msg = message GRvg.GRgenabsg(msg,
				   &md_env->md_env.matrix_type,
				   md_env->md_env.matrix,
				   (IGRchar **)&curve),
		   senderid = NULL_OBJID,
		   targetid = go_grid->objid,
		   targetos = go_grid->osnum);
  fe$status(action = RET_STATUS);

  /*
   * Get the curve normal if the curve is planar other wise
   * use the view z vector as the desired normal
   */
  status = BScvnormal2( &long_rc, curve, normal_vector);
  if (!status)
    {
      *msg = MSFAIL;
      goto wrapup;
    } /* if (!status) */

  OM_BLOCK_MOVE(normal_vector,b_normal,3*sizeof(IGRdouble));
  if(!cv_normal) goto wrapup;

  /*
   * Compute the tangent vector of the curve at
   * a predefined parameter value
   */
  {
    IGRboolean	evaluate_boundaries, was_discontinuous;
    IGRlong	loc_msg;
    IGRint        number_of_derivatives;
    IGRdouble	u_value, u_low, u_hig;
    IGRpoint	left_derv[2], right_derv[2];

    u_low = curve->knots[curve->order - 1];
    u_hig = curve->knots[curve->num_poles];
    u_value = (u_hig - u_low) / 2.0;
    evaluate_boundaries = TRUE;
    number_of_derivatives = 1;
    status = BScveval_b(
			&loc_msg,
			curve,
			&u_value,
			&number_of_derivatives,
			&evaluate_boundaries,
			&was_discontinuous,
			left_derv,
			right_derv);
    if (! status)
      {
	*msg = MSFAIL;
	goto wrapup;
      }
    /*
     * If the tangent was not continuous at the chosen
     * parameter then average the left and right tangents
     */
    if (was_discontinuous)
      {
	left_derv[1][0] += right_derv[1][0];
	left_derv[1][0] /= 2.0;
	left_derv[1][1] += right_derv[1][1];
	left_derv[1][1] /= 2.0;
	left_derv[1][2] += right_derv[1][2];
	left_derv[1][2] /= 2.0;
      }

    /*
     * Normalize the tangent vector
     */
    status = BSnorvec( &loc_msg, left_derv[1]);
    if (!status)
      {
	if (loc_msg != BSDGENRAT)
	  *msg = MSFAIL;
	goto wrapup;
      }
    point_on_curve[0] = left_derv[0][0];
    point_on_curve[1] = left_derv[0][1];
    point_on_curve[2] = left_derv[0][2];
    tangent_vector[0] = left_derv[1][0];
    tangent_vector[1] = left_derv[1][1];
    tangent_vector[2] = left_derv[1][2];
  }
  /*
   * Cross the plane normal with the curve tangent to yield
   * the curve normal.
   */
  status = BScrossp( &long_rc, normal_vector, tangent_vector, cv_normal);
  status = BSnorvec( &long_rc, cv_normal);
  if (!status)
    {
      *msg = MSFAIL;
      goto wrapup;
    }
 wrapup:
  return(status);
}
end implementation EMSpatfea;
