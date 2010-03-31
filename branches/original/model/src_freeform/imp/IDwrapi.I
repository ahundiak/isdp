class implementation IDwrap;

#include <stdio.h>
#include <math.h>
#include <values.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "adpdef.h"
#include "grmacros.h"
#include "exdef.h"
#include "dpstruct.h"
#include "bs.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "bserr.h"
#include "IDffmsg.h"
#include "IDwrapi.h"
#include "bsalloccv.h"    /* prototypes */
#include "bsconstprcv.h"    /* prototypes */
#include "bscrossp.h"    /* prototypes */
#include "bsdotp.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsint2lns.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bsmkvec.h"    /* prototypes */
#include "bsnorvec.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */

from GRgraphics import GRgetrang;
from GRvg import GRgetsymb, GRdetplane;

/*----------------------------------------------------------------------*
 * Intersect two infinite lines                                         *
 *----------------------------------------------------------------------*/
IGRint lnlnint(
	IGRpoint ln1_p, 
	IGRvector ln1_v, 
	IGRpoint ln2_p, 
	IGRvector ln2_v, 
	IGRpoint int_pt)
{
  struct IGRline ln1, ln2;
  struct IGRline *lns[2];
  IGRpoint ln1_p2, ln2_p2, pts[2];
  IGRdouble dist;
  IGRlong msg;

  /* initialize line 1 */
  ln1.point1 = ln1_p;
  ln1_p2[0] = ln1_p[0] + ln1_v[0];
  ln1_p2[1] = ln1_p[1] + ln1_v[1];
  ln1_p2[2] = ln1_p[2] + ln1_v[2];
  ln1.point2 = ln1_p2;
  lns[0] = &ln1;

  /* initialize line 2 */
  ln2.point1 = ln2_p;
  ln2_p2[0] = ln2_p[0] + ln2_v[0];
  ln2_p2[1] = ln2_p[1] + ln2_v[1];
  ln2_p2[2] = ln2_p[2] + ln2_v[2];
  ln2.point2 = ln2_p2;
  lns[1] = &ln2;

  /* intersect two lines */
  BSint2lns( lns, pts, &dist, &msg );

  if ( msg == BSNOINTERS || msg == BSPARALLEL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
    return msg;
  }

  int_pt[0] = pts[0][0];
  int_pt[1] = pts[0][1];
  int_pt[2] = pts[0][2];

  return BSSUCC;
}

/*----------------------------------------------------------------------*
 * Display or erase a rule line on the conical surface                  *
 *----------------------------------------------------------------------*/
method disp_iso_cv( IGRlong *rc;
		    struct BSgeom_bsp_surf *quad_surf; IGRdouble uv_par;
		    IGRshort u_or_v;
		    struct IGRdisplay *disp; IGRboolean draw )
{
  struct IGResbc attr;
  struct IGRbsp_curve *iso_cv;
  IGRboolean test_planar, ratn = TRUE;
  IGRshort iso_opt;
  struct DPele_header iso_buf;
  IGRlong msg;

  /* initialize to display curve only */
  attr.is_polydis = FALSE;
  attr.is_curvedis = TRUE;

  /* allocate memory to store the iso curve */
  if ( quad_surf->type == BSSPHERE )
  {
    BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 0,
	       &iso_cv, &msg );
    iso_opt = 2;
  }
  else
  {
    ratn = FALSE;
    if ( u_or_v == 1 )
      BSalloccv( quad_surf->bspsf->v_order, quad_surf->bspsf->v_num_poles,
		 quad_surf->bspsf->rational, 0, &iso_cv, &msg );
    else
      BSalloccv( quad_surf->bspsf->u_order, quad_surf->bspsf->u_num_poles,
		 quad_surf->bspsf->rational, 0, &iso_cv, &msg );
    iso_opt = u_or_v;
  }
  test_planar = FALSE;

  /* construct the iso curve */
  BSconstprcv( &msg, quad_surf->bspsf, &iso_opt, &uv_par,
	       &test_planar, iso_cv );

  /* build the display buffer */
  dp$build_dis_buffer( buffer = &iso_buf,
		       type = IGRBC,
		       display_att = disp,
		       ele_spec_att = &attr,
		       geometry = ( struct IGRbsp_curve * ) iso_cv );

  /* draw or erase the curve */
  dp$display( msg = &msg,
	      mode = ( draw ? GRhd : GRhe ),
	      num_elem = 1,
	      buffer = &iso_buf );

  /* free allocated memory and return */
  BSfreecv( &msg, iso_cv );
  *rc = msg;

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Display or erase a tangent vector on a surface                       *
 *----------------------------------------------------------------------*/
method disp_tang_vec( IGRlong *rc; struct GRlc_info *lc_surf;
		      IGRpoint pt; IGRvector vec;
		      struct IGRdisplay *disp; IGRboolean draw )
{
  struct GRmd_env surf_mod;
  IGRboolean wd_loc = TRUE;
  GRrange surf_range;
  struct IGRdisplay tang_disp;
  GRobjid stupid_id = NULL;
  IGRlong status, msg;
  extern void EFdraw_vector_on_screen();

  /* get surface module env */
  surf_mod = lc_surf->module_info;

  /* get the range of the surface */
  status = om$send( msg = message GRgraphics.GRgetrang( &msg,
						        &surf_mod.md_env.matrix_type,
						        surf_mod.md_env.matrix,
						        &wd_loc,
						        surf_range ),
		    targetid = lc_surf->located_obj.objid,
		    targetos = lc_surf->located_obj.osnum );

  /* copy the input display to tang_disp */
  memcpy( (char *)&tang_disp, (char *)disp, sizeof( struct IGRdisplay ));

  /* must be a solid line */
  tang_disp.style = 0;

  /* display the vector direction */
  EFdraw_vector_on_screen( stupid_id, &tang_disp, &ME.ECelement->md_env,
			   ( draw ? GRhd : GRhe ), FALSE,
			   pt, vec, surf_range, &msg );
  *rc = msg;

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Construct a rectangle enclosing the input planar element             *
 *----------------------------------------------------------------------*/
method cnst_ele_rect( IGRlong *rc; struct GRlc_info *element;
		      IGRvector rot_axis; struct ele_rect *rect )
{
  struct IGRplane ele_plane;
  IGRpoint plane_pt, cur_pt;
  IGRvector plane_norm, vec;
  IGRboolean first = TRUE;
  IGRint max_pt_ind, min_pt_ind, max_which_ln, min_which_ln;
  IGRint max_v_pt_ind, min_v_pt_ind, max_v_which_ln, min_v_which_ln;
  IGRdouble lenvec_tol, cur_min, cur_max, cur_v_min, cur_v_max, cur_val;
  IGRint i, j;
  struct IGRpolyline poly_ln;
  IGRlong msg, status;

  BSxtractpar( &msg, BSTOLLENVEC, &lenvec_tol );

  /* determine the plane that the planar element lies on */
  ele_plane.point = plane_pt;
  ele_plane.normal = plane_norm;
  status = om$send( msg = message GRvg.GRdetplane( &msg,
						   &element->module_info.md_env.matrix_type,
						   element->module_info.md_env.matrix,
						   &ele_plane ),
		    targetid = element->located_obj.objid,
		    targetos = element->located_obj.osnum );

  /* compute the directions of the enclosing rectangle */
  BScrossp( &msg, plane_norm, rot_axis, rect->h_vec );

  if ( BSlenvec( &msg, rect->h_vec ) < lenvec_tol )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WRPELEPERP );
    *rc = BSFAIL;
    goto quit;
  }

  BScrossp( &msg, plane_norm, rect->h_vec, rect->v_vec );

  if ( BSdotp( &msg, rot_axis, rect->v_vec ) < 0 )
  {
    rect->v_vec[0] = -rect->v_vec[0];
    rect->v_vec[1] = -rect->v_vec[1];
    rect->v_vec[2] = -rect->v_vec[2];
  }

  /* normalize h_vec and v_vec */
  BSnorvec( &msg, rect->h_vec );
  BSnorvec( &msg, rect->v_vec );

  /* find the minimum and maximum points along h_vec and v_vec */

  /* initialization */
  max_v_pt_ind = min_v_pt_ind = max_pt_ind = min_pt_ind = 0;
  max_v_which_ln = min_v_which_ln = max_which_ln = min_which_ln = 0;
  cur_v_max = cur_v_min = cur_max = cur_min = 0.0;

  /* loop through all the points */
  for ( j = 0; j < me->num_poly_ln; j++ )
  {
    poly_ln = me->poly_lns[j];

    for ( i = 0; i < poly_ln.num_points; i++ )
    {
      cur_pt[0] = poly_ln.points[i*3];
      cur_pt[1] = poly_ln.points[i*3+1];
      cur_pt[2] = poly_ln.points[i*3+2];

      if ( first == TRUE )
      {
	cur_max = cur_min = BSdotp( &msg, cur_pt, rect->h_vec );
	cur_v_max = cur_v_min = BSdotp( &msg, cur_pt, rect->v_vec );
	first = FALSE;
      }
      else
      {
	/* find minimum and maximum along h_vec direction */
	cur_val = BSdotp( &msg, cur_pt, rect->h_vec );
	if ( cur_val < cur_min )
	{
	  cur_min = cur_val;
	  min_pt_ind = i * 3;
	  min_which_ln = j;
	}
	if ( cur_val > cur_max )
	{
	  cur_max = cur_val;
	  max_pt_ind = i * 3;
	  max_which_ln = j;
	}

	/* find minimum and maximum along v_vec direction */
	cur_val = BSdotp( &msg, cur_pt, rect->v_vec );
	if ( cur_val < cur_v_min )
	{
	  cur_v_min = cur_val;
	  min_v_pt_ind = i * 3;
	  min_v_which_ln = j;
	}
	if ( cur_val > cur_v_max )
	{
	  cur_v_max = cur_val;
	  max_v_pt_ind = i * 3;
	  max_v_which_ln = j;
	}
      }
    }
  }

  /* get the minimum and maximum points */
  memcpy( (char *)rect->min_pt,
	  (char *)((me->poly_lns[min_which_ln].points) + min_pt_ind),
	  3 * sizeof( IGRdouble ));
  memcpy( (char *)rect->max_pt,
	  (char *)((me->poly_lns[max_which_ln].points) + max_pt_ind),
	  3 * sizeof( IGRdouble ));

  memcpy( (char *)rect->min_v_pt,
	  (char *)((me->poly_lns[min_v_which_ln].points) + min_v_pt_ind),
	  3 * sizeof( IGRdouble ));
  memcpy( (char *)rect->max_v_pt,
	  (char *)((me->poly_lns[max_v_which_ln].points) + max_v_pt_ind),
	  3 * sizeof( IGRdouble ));

  /* now define the rectangle which encloses the planar element */
  if ( lnlnint( rect->min_v_pt, rect->h_vec, rect->min_pt, rect->v_vec, rect->rect_pts[0] ) != BSSUCC )
  {
    *rc = BSFAIL;
    goto quit;
  }
  if ( lnlnint( rect->min_pt, rect->v_vec, rect->max_v_pt, rect->h_vec, rect->rect_pts[1] ) != BSSUCC )
  {
    *rc = BSFAIL;
    goto quit;
  }
  if ( lnlnint( rect->max_v_pt, rect->h_vec, rect->max_pt, rect->v_vec, rect->rect_pts[2] ) != BSSUCC )
  {
    *rc = BSFAIL;
    goto quit;
  }
  if ( lnlnint( rect->max_pt, rect->v_vec, rect->min_v_pt, rect->h_vec, rect->rect_pts[3] ) != BSSUCC )
  {
    *rc = BSFAIL;
    goto quit;
  }

  /* assign the last point same as the first one */
  memcpy( (char *)rect->rect_pts[4], (char *)rect->rect_pts[0],
	  3 * sizeof( IGRdouble ));

  /* assign polyline structure to form a rectangle */
  rect->rect_ln.num_points = 5;
  rect->rect_ln.points = &(rect->rect_pts[0][0]);

  /* compute length of the element */
  BSmkvec( &msg, vec, rect->min_pt, rect->max_pt );
  rect->rect_len = BSdotp( &msg, vec, rect->h_vec );
  
  /* compute height of the element */
  BSmkvec( &msg, vec, rect->min_v_pt, rect->max_v_pt );
  rect->rect_hgt = BSdotp( &msg, vec, rect->v_vec );

  *rc = BSSUCC;

 quit:
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Display or erase a rectangle that enclosed the planar element        *
 *----------------------------------------------------------------------*/
method disp_ele_rect( IGRlong *rc; struct GRlc_info *element;
		      struct ele_rect *rect; struct IGRdisplay *disp;
		      IGRboolean draw, show_tang )
{
  struct DPele_header dis_buf;
  IGRpoint ele_pt;
  IGRvector unit_vec;
  IGRlong status, msg;

  /* build display buffer */
  dp$build_dis_buffer( buffer = &dis_buf,
		       type = IGRPY,
		       display_att = disp,
		       geometry = &rect->rect_ln );

  /* display or erase the rectangle */
  dp$display( msg = &msg,
	      mode = ( draw ? GRbdhd : GRbehe ),
	      num_elem = 1,
	      buffer = &dis_buf );
  *rc = TRUE;

  /* do following if we want to show wrapping direction of the element */
  if ( show_tang )
  {
    /* compute the point and a unit tangent vector at the point */
    ele_pt[0] = ( rect->rect_pts[0][0] + rect->rect_pts[1][0] ) / 2;
    ele_pt[1] = ( rect->rect_pts[0][1] + rect->rect_pts[1][1] ) / 2;
    ele_pt[2] = ( rect->rect_pts[0][2] + rect->rect_pts[1][2] ) / 2;

    /* compute the vector */
    BSmkvec( &msg, unit_vec, rect->rect_pts[1], rect->rect_pts[2] );
    BSnorvec( &msg, unit_vec );

    /* display or erase the vector */
    status = om$send( msg = message IDwrap.disp_tang_vec( &msg,
							  element,
							  ele_pt,
							  unit_vec,
							  disp,
							  draw ),
		      targetid = my_id );
    *rc = msg;
  }

  return OM_S_SUCCESS;
}


end implementation IDwrap;
