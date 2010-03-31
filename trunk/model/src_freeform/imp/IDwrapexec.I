class implementation IDwrap;

/*
Abstract
	This command wraps 3d planar vector data (wire frame) onto a
	cynlider, cone or sphere.

Algorithm
	Find a bounding rectangular box enclosing the wire frame.
	Convert the wire frame to a list of polyline strings. Then
	map end points of each segment onto the surface. Finally
	stroke out points between the end points of each segment.
*/

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
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "griomacros.h"

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
#include "emssfdef.h"
#include "EMSsfparms.h"

#include "msdef.h"
#include "comndef.h"
#include "grmessage.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "ECmsg.h"
#include "bsalloccv.h"    /* prototypes */
#include "bsconstprcv.h"    /* prototypes */
#include "bscrossp.h"    /* prototypes */
#include "bsdotp.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bslenvecsq.h"    /* prototypes */
#include "bsmkvec.h"    /* prototypes */
#include "bsnorvec.h"    /* prototypes */
#include "bsprepcarc.h"    /* prototypes */
#include "bsprepcirc.h"    /* prototypes */
#include "bssfeval.h"    /* prototypes */
#include "bsxlngmsf.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */
#include <string.h>    /* prototypes */

/* display flag used when locating surface */
#define SURF_LC_DISFLAG ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | \
                        ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | \
                        LC_ERASE_LOC_ELEMENT
                     
/* state number definition */
#define LOCATE_ELE 2
#define LOCATE_SURF 3
#define GET_SPH_AXIS 4
#define INPUT_START_PT 5
#define ACC_DIRECTION 6
#define END_PT_METHOD 7
#define INPUT_END_PT 8
#define INPUT_DISTANCE 9
#define ACC_ELE_DIRECTION 10

#define TWO_RULE_LNS 1
#define DISTANCE 2

from GRvg import GRgetsymb;
/*----------------------------------------------------------------------*
 * Function maps cursor to the point and rule line of the surface      
 *----------------------------------------------------------------------*/
#argsused
static IGRint DPsurf_pt(
        struct DPquad_surf *DYinfo,
        struct EX_button *point,
        IGRdouble *matrix,
        struct GRid **objects,
        IGRint *num_objects,
        struct DPele_header **buffers,
        IGRint *num_buffers,
        IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3,
        IGRchar *dummy_out1, IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  struct GRevent event;
  GRobjid stupid_id = NULL;
  struct IGRline bore_ln;
  IGRpoint start_pt, end_pt, int_pts[2], *pts2, cnt_pt;
  IGRshort iso_opt, draw_circle = 0;
  IGRpoint box_p1, box_p2, box_p3, box_p4;
  IGRvector vec, vec1, start_vec, end_vec, x_axis, y_axis, unit_normal;
  IGRint buff_size, npts, type;
  IGRdouble int_uvs[4], *uvpar2, angle, angle1, sin_val, cos_val;
  IGRdouble cht_tol, v, radius, radius1;
  IGRboolean alloc_pts, test_planar;
  IGRlong msg;

  radius = radius1 = 0.0;	/* shut off compiler warning */

  /* extract chord height tolerance */
  BSxtractpar( &msg, BSTOLCHRDHT, &cht_tol );

  event.event.button = *point;
  bore_ln.point1 = start_pt;
  bore_ln.point2 = end_pt;

  /* construct a boreline */
  EFboreline( &msg, stupid_id, &event, &bore_ln );

  /* determine the vector from start_pt to end_pt (used in BSxlngmsf) */
  BSmkvec( &msg, vec, start_pt, end_pt );
  BSnorvec( &msg, vec );

  /* do boreline/surface intersection */
  buff_size = 2;
  BSxlngmsf( DYinfo->quad_surf, start_pt, vec, TRUE, buff_size,
	     int_pts, int_uvs, &alloc_pts, &npts, &pts2, &uvpar2, &msg );

  if ( msg == BSNOMEMORY || msg == BSNOSTKMEMORY )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    DYinfo->rc = BSFAIL;
    goto quit;
  }
  if ( msg == BSNOSOLUTION || msg == BSCOINCIDENT )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WrpCurOutSf );
    DYinfo->rc = BSFAIL;
    goto quit;
  }

  UI_status( " " );

  /* assign the intersection point */
  memcpy( (char *)DYinfo->int_pt, (char *)int_pts[0], 3 * sizeof( IGRdouble ));

  /* note that the u,v space orientation is different for sphere
     and cylinder, cone. For cylinder or cone, the u determines a
     rule line with v from 0 to 1. For sphere, each v determines
     a rule line with u from 0 to 1 */
  if ( DYinfo->quad_surf->type == BSSPHERE )
  {
    DYinfo->int_uv = int_uvs[1];

    /* construct the constant parameter curve */
    iso_opt = 2;
    test_planar = FALSE;
    BSconstprcv( &msg, DYinfo->quad_surf->bspsf, &iso_opt, &int_uvs[1],
		 &test_planar, DYinfo->header[0].geometry.bspcurve );
  }
  else
  {
    if ( DYinfo->u_or_v == 1 )
    {
      DYinfo->int_uv = int_uvs[0];

      /* find the starting and ending points of the rule line */
      BSsfeval( DYinfo->quad_surf->bspsf, int_uvs[0], 0.0, 0, &start_pt, &msg );
      BSsfeval( DYinfo->quad_surf->bspsf, int_uvs[0], 1.0, 0, &end_pt, &msg );
    }
    else
    {
      DYinfo->int_uv = int_uvs[1];

      /* find the starting and ending points of the rule line */
      BSsfeval( DYinfo->quad_surf->bspsf, 0.0, int_uvs[1], 0, &start_pt, &msg );
      BSsfeval( DYinfo->quad_surf->bspsf, 1.0, int_uvs[1], 0, &end_pt, &msg );
    }

    /* set up starting and ending points of the rule line */
    memcpy((char *) DYinfo->pt_buf, (char *)start_pt, 3 * sizeof( IGRdouble ));
    memcpy( (char *)(DYinfo->pt_buf + 3), (char *)end_pt, 
        3 * sizeof( IGRdouble ));
  }

  /* do following only if want to show element enclosing box */
  if ( DYinfo->which )
  {
    /* save the u/v parameter */
    DYinfo->uv1 = DYinfo->int_uv;

    if ( DYinfo->quad_surf->type == BSFULL_CYL ||
	 DYinfo->quad_surf->type == BSPART_CYL ||
	 DYinfo->quad_surf->type == BSFULL_CONE ||
	 DYinfo->quad_surf->type == BSPART_CONE )
    {
      /* check whether the end points of the box is out of surface */
      BSmkvec( &msg, vec, int_pts[0], start_pt );
      if ( BSlenvec( &msg, vec ) < DYinfo->len2 )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WrpPtOutSf );
	DYinfo->rc = BSFAIL;
	goto quit;
      }
      BSmkvec( &msg, vec, int_pts[0], end_pt );
      if ( BSlenvec( &msg, vec ) < DYinfo->len2 )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WrpPtOutSf );
	DYinfo->rc = BSFAIL;
	goto quit;
      }

      if ( DYinfo->quad_surf->type == BSFULL_CYL ||
	   DYinfo->quad_surf->type == BSPART_CYL )
      {
	/* compute the vector on the rule line */
	vec[0] = DYinfo->len2 * DYinfo->quad_surf->vec1[0];
	vec[1] = DYinfo->len2 * DYinfo->quad_surf->vec1[1];
	vec[2] = DYinfo->len2 * DYinfo->quad_surf->vec1[2];
      }
      else
      {
	/* compute the vector on the rule line */
	BSmkvec( &msg, vec1, start_pt, end_pt );
	BSnorvec( &msg, vec1 );
	vec[0] = DYinfo->len2 * vec1[0];
	vec[1] = DYinfo->len2 * vec1[1];
	vec[2] = DYinfo->len2 * vec1[2];
      }

      /* compute the first two points (on the rule line) */
      box_p1[0] = int_pts[0][0] + vec[0];
      box_p1[1] = int_pts[0][1] + vec[1];
      box_p1[2] = int_pts[0][2] + vec[2];
      box_p2[0] = int_pts[0][0] - vec[0];
      box_p2[1] = int_pts[0][1] - vec[1];
      box_p2[2] = int_pts[0][2] - vec[2];

      /* construct line 1: box_p2 --> box_p1 */
      memcpy( (char *)DYinfo->header[1].geometry.polyline->points, 
        (char *)box_p2,
	      3 * sizeof( IGRdouble ));
      memcpy( (char *)(DYinfo->header[1].geometry.polyline->points + 3), 
        (char *)box_p1, 3 * sizeof( IGRdouble ));

      /* save the two points into DYinfo */
      memcpy( (char *)DYinfo->p1, (char *)box_p1, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->p2, (char *)box_p2, 3 * sizeof( IGRdouble ));

      if ( DYinfo->quad_surf->type == BSFULL_CYL ||
	   DYinfo->quad_surf->type == BSPART_CYL )
      {
	/* calculate rotation angle */
	angle = DYinfo->len1 / DYinfo->quad_surf->len1;
	if ( angle > 2 * M_PI )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_WrpOverlap );
	  draw_circle = 1;
	}
	sin_val = sin( angle );
	cos_val = cos( angle );

	/* compute the tangent vector at the starting point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, int_pts[0] );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* find the center of the circle at the starting point */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* compute the radius vector from center to starting point */
	BSmkvec( &msg, x_axis, cnt_pt, int_pts[0] );
	BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, DYinfo->tang_vec );
	BSnorvec( &msg, DYinfo->tang_vec );

	/* compute the unit_pts using the radius at the starting point */
	angle1 = 2 * acos(( DYinfo->quad_surf->len1 - cht_tol ) /
			    DYinfo->quad_surf->len1 );
	DYinfo->unit_pts = 1.0 / ( angle1 * DYinfo->quad_surf->len1 );

	/* compute the third point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p1 );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* first compute the center of the circle */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* compute the coordinate system for rotation */
	BSmkvec( &msg, x_axis, cnt_pt, box_p1 );
	BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, y_axis );

	/* save the center and coordiante system to DYinfo sturct */
	memcpy( (char *)DYinfo->cnt1, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->x_axis1, (char *)x_axis, 
            3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->y_axis1, (char *)y_axis, 
            3 * sizeof( IGRdouble ));

	/* now rotate box_p1 to the desired position */
	box_p3[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
	box_p3[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
	box_p3[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;

	/* construct first arc connecting box_p1 and box_p3 */
	BSprepcarc( &msg, box_p1, cnt_pt, box_p3, DYinfo->quad_surf->vec1,
		    DYinfo->header[2].geometry.bspcurve, unit_normal, &type );

	/* if there is overlapping, then draw a circle */
	if ( draw_circle )
	  /* construct a full circle centered at cnt_pt */
	  BSprepcirc( &msg, cnt_pt, &DYinfo->quad_surf->len1,
		      DYinfo->quad_surf->vec1,
		      DYinfo->header[5].geometry.bspcurve,
		      unit_normal, &type );

	/* compute the fourth point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p2 );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* compute the center of the new circle */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* save the center and coordiante system to DYinfo sturct */
	memcpy( (char *)DYinfo->cnt2, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->x_axis2, (char *)x_axis, 
            3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->y_axis2, (char *)y_axis, 
            3 * sizeof( IGRdouble ));

	/* rotate box_p2 to the desired position */
	box_p4[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
	box_p4[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
	box_p4[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;

	/* construct line 2 of the circular box */
	memcpy( (char *)DYinfo->header[3].geometry.polyline->points, 
            (char *)box_p3, 3 * sizeof( IGRdouble ));
	memcpy( (char *)(DYinfo->header[3].geometry.polyline->points + 3), 
            (char *)box_p4, 3 * sizeof( IGRdouble ));
      
	/* construct second arc connecting box_p4 and box_p2 */
	BSprepcarc( &msg, box_p2, cnt_pt, box_p4, DYinfo->quad_surf->vec1,
		    DYinfo->header[4].geometry.bspcurve, unit_normal, &type );

	/* if there is overlapping, then draw a circle */
	if ( draw_circle )
	  /* construct a full circle centered at cnt_pt */
	  BSprepcirc( &msg, cnt_pt, &DYinfo->quad_surf->len1,
		      DYinfo->quad_surf->vec1,
		      DYinfo->header[6].geometry.bspcurve,
		      unit_normal, &type );
      }
      else
      {
	/* compute the tangent vector at the starting point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, int_pts[0] );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* find the center of the circle at the starting point */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* compute the radius vector from center to starting point */
	BSmkvec( &msg, x_axis, cnt_pt, int_pts[0] );
	BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, DYinfo->tang_vec );
	BSnorvec( &msg, DYinfo->tang_vec );

	/* connect from the cursor point to the tip point of the cone */
	BSmkvec( &msg, vec, int_pts[0], DYinfo->quad_surf->pt5 );
	radius = BSlenvec( &msg, vec ) * sin( DYinfo->quad_surf->len4 );

	/* now the angle of rotation is determined */
	angle = DYinfo->len1 / radius;
	if ( angle > 2 * M_PI )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_WrpOverlap );
	  draw_circle = 1;
	}
	sin_val = sin( angle );
	cos_val = cos( angle );

	/* compute the third point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p1 );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* first compute the center of the circle */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* now computing the radius of the circle passing box_p1 */
	BSmkvec( &msg, vec, box_p1, DYinfo->quad_surf->pt5 );
	radius = BSlenvec( &msg, vec ) * sin( DYinfo->quad_surf->len4 );

	/* compute the coordinate system for rotation */
	BSmkvec( &msg, x_axis, cnt_pt, box_p1 );
	BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, y_axis );

	/* save the center and coordiante system to DYinfo sturct */
	memcpy( (char *)DYinfo->cnt1, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->x_axis1, (char *)x_axis, 
            3 * sizeof( IGRdouble ));
	memcpy( (char *)DYinfo->y_axis1, (char *)y_axis, 
            3 * sizeof( IGRdouble ));

	/* now rotate box_p1 to the desired position */
	box_p3[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
	box_p3[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
	box_p3[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;
    
	/* construct first arc connecting box_p1 and box_p3 */
	BSprepcarc( &msg, box_p1, cnt_pt, box_p3, DYinfo->quad_surf->vec1,
		    DYinfo->header[2].geometry.bspcurve, unit_normal, &type );

	/* if there is overlapping, then draw a circle */
	if ( draw_circle )
	  /* construct a full circle centered at cnt_pt */
	  BSprepcirc( &msg, cnt_pt, &radius, DYinfo->quad_surf->vec1,
		      DYinfo->header[5].geometry.bspcurve,
		      unit_normal, &type );

	/* compute the fourth point */
	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p2 );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* compute the center of the new circle */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* now computing the radius of the circle passing box_p2 */
	BSmkvec( &msg, vec, box_p2, DYinfo->quad_surf->pt5 );
	radius1 = BSlenvec( &msg, vec ) * sin( DYinfo->quad_surf->len4 );

	/* compute the coordinate system for rotation */
	BSmkvec( &msg, x_axis, cnt_pt, box_p2 );
	BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, y_axis );

	/* save the center and coordiante system to DYinfo sturct */
	memcpy( (char *)DYinfo->cnt2, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
	memcpy((char *)DYinfo->x_axis2, (char *)x_axis, 3 * sizeof( IGRdouble));
	memcpy((char *)DYinfo->y_axis2, (char *)y_axis, 3 * sizeof( IGRdouble ));

	/* rotate box_p2 to the desired position */
	box_p4[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
	box_p4[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
	box_p4[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;

	/* construct line 2 of the circular box */
	memcpy( (char *)DYinfo->header[3].geometry.polyline->points, 
            (char *)box_p3, 3 * sizeof( IGRdouble ));
	memcpy( (char *)(DYinfo->header[3].geometry.polyline->points + 3), 
            (char *)box_p4, 3 * sizeof( IGRdouble ));
      
	/* construct second arc connecting box_p4 and box_p2 */
	BSprepcarc( &msg, box_p2, cnt_pt, box_p4, DYinfo->quad_surf->vec1,
		    DYinfo->header[4].geometry.bspcurve, unit_normal, &type );

	/* if there is overlapping, then draw a circle */
	if ( draw_circle )
	  /* construct a full circle centered at cnt_pt */
	  BSprepcirc( &msg, cnt_pt, &radius1, DYinfo->quad_surf->vec1,
		      DYinfo->header[6].geometry.bspcurve,
		      unit_normal, &type );

	/* compute the unit_pts using the radius at the starting point */
	if ( radius > radius1 )
	{
	  angle1 = 2 * acos(( radius - cht_tol ) / radius );
	  DYinfo->unit_pts = 1.0 / ( angle1 * radius );
	}
	else
	{
	  angle1 = 2 * acos(( radius1 - cht_tol ) / radius1 );
	  DYinfo->unit_pts = 1.0 / ( angle1 * radius1 );
	}
      }
    }
    else
    {	/* input surface is sphere or partial sphere */

      /* compute the half angle along the rule line */
      angle = DYinfo->len2 / DYinfo->quad_surf->len1;

      /* compute the angle connecting cursor to top/bottom/middle point */
      if ( int_uvs[0] == 0.5 )
	angle1 = M_PI / 2.0;
      else
      {
	if ( int_uvs[0] < 0.5 )	/* check the upper half */
	  /* compute the angle from intersection to the top pole */
	  BSmkvec( &msg, vec, int_pts[0], DYinfo->quad_surf->pt2 );
	else
	  /* compute the angle from intersection to the bottom pole */
	  BSmkvec( &msg, vec, int_pts[0], DYinfo->quad_surf->pt4 );

	v = BSlenvecsq( &msg, vec );
	angle1 = acos( 1 - v / ( 2.0 * DYinfo->quad_surf->len1 * DYinfo->quad_surf->len1 ));
      }

      /* angle cannot be greater than angle1 */
      if ( angle > angle1 )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WrpPtOutSf );
	DYinfo->rc = BSFAIL;
	goto quit;
      }

      /* now rotate intersection angle and -angle to get first two points */
      sin_val = sin( angle );
      cos_val = cos( angle );

      BSmkvec( &msg, x_axis, DYinfo->quad_surf->pt1, int_pts[0] );
      BScrossp( &msg, x_axis, DYinfo->quad_surf->vec1, vec );
      BSnorvec( &msg, vec );
      BScrossp( &msg, vec, x_axis, y_axis );

      /* now rotate intersection to get first two points */
      box_p1[0] = DYinfo->quad_surf->pt1[0] + x_axis[0] * cos_val
	                                    + y_axis[0] * sin_val;
      box_p1[1] = DYinfo->quad_surf->pt1[1] + x_axis[1] * cos_val
	                                    + y_axis[1] * sin_val;
      box_p1[2] = DYinfo->quad_surf->pt1[2] + x_axis[2] * cos_val
	                                    + y_axis[2] * sin_val;

      box_p2[0] = DYinfo->quad_surf->pt1[0] + x_axis[0] * cos_val
	                                    - y_axis[0] * sin_val;
      box_p2[1] = DYinfo->quad_surf->pt1[1] + x_axis[1] * cos_val
	                                    - y_axis[1] * sin_val;
      box_p2[2] = DYinfo->quad_surf->pt1[2] + x_axis[2] * cos_val
	                                    - y_axis[2] * sin_val;

      /* construct first arc from box_p1 to box_p2 */
      BSprepcarc( &msg, box_p2, DYinfo->quad_surf->pt1, box_p1, vec,
		  DYinfo->header[1].geometry.bspcurve, unit_normal, &type );

      /* save the two points into DYinfo */
      memcpy( (char *)DYinfo->p1, (char *)box_p1, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->p2, (char *)box_p2, 3 * sizeof( IGRdouble ));

      /* calculate the width on the rotation axis by projecting
	 line segments int_pts[0]-->box_p1 and box_p2-->int_pts[0] */
      BSmkvec( &msg, vec, int_pts[0], box_p1 );
      DYinfo->width1 = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

      BSmkvec( &msg, vec, box_p2, int_pts[0] );
      DYinfo->width2 = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

      /* compute the tangent direction at the intersection */
      BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, int_pts[0] );
      BScrossp( &msg, DYinfo->quad_surf->vec1, vec, DYinfo->tang_vec );
      BSnorvec( &msg, DYinfo->tang_vec );

      /* calculate rotation angle in DYinfo->len1 direction */
      radius = DYinfo->quad_surf->len1 * sin( angle1 );
      angle = DYinfo->len1 / radius;
      if ( angle > 2 * M_PI )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_WrpOverlap );
	draw_circle = 1;
      }
      sin_val = sin( angle );
      cos_val = cos( angle );

      /* compute the third point: box_p3 */
      /* first compute the center of the circle */
      BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p1 );
      v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

      cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
      cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
      cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

      /* compute the coordinate system for rotation */
      BSmkvec( &msg, x_axis, cnt_pt, box_p1 );
      BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, y_axis );
      radius = BSlenvec( &msg, x_axis );

      /* save the center and coordiante system to DYinfo sturct */
      memcpy( (char *)DYinfo->cnt1, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->x_axis1, (char *)x_axis, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->y_axis1, (char *)y_axis, 3* sizeof( IGRdouble ));

      /* now rotate box_p1 to the desired position */
      box_p3[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
      box_p3[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
      box_p3[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;

      /* construct second arc connecting box_p1 and box_p3 */
      BSprepcarc( &msg, box_p1, cnt_pt, box_p3, DYinfo->quad_surf->vec1,
		  DYinfo->header[2].geometry.bspcurve, unit_normal, &type );

      /* if there is overlapping, then draw a circle */
      if ( draw_circle )
	/* construct a full circle centered at cnt_pt */
	BSprepcirc( &msg, cnt_pt, &radius, DYinfo->quad_surf->vec1,
		    DYinfo->header[5].geometry.bspcurve, unit_normal, &type );

      /* compute the fourth point: box_p4 */
      /* first compute the center of the circle */
      BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, box_p2 );
      v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

      cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
      cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
      cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

      /* save the center and coordiante system to DYinfo sturct */
      memcpy( (char *)DYinfo->cnt2, (char *)cnt_pt, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->x_axis2, (char *)x_axis, 3 * sizeof( IGRdouble ));
      memcpy( (char *)DYinfo->y_axis2, (char *)y_axis, 3 * sizeof( IGRdouble ));

      /* compute the coordinate system for rotation */
      BSmkvec( &msg, x_axis, cnt_pt, box_p2 );
      BScrossp( &msg, DYinfo->quad_surf->vec1, x_axis, y_axis );
      radius1 = BSlenvec( &msg, x_axis );

      /* now rotate box_p2 to the desired position */
      box_p4[0] = cnt_pt[0] + x_axis[0] * cos_val + y_axis[0] * sin_val;
      box_p4[1] = cnt_pt[1] + x_axis[1] * cos_val + y_axis[1] * sin_val;
      box_p4[2] = cnt_pt[2] + x_axis[2] * cos_val + y_axis[2] * sin_val;

      /* construct third arc connecting box_p3 and box_p4 */
      BSmkvec( &msg, x_axis, DYinfo->quad_surf->pt1, box_p3 );
      BSmkvec( &msg, y_axis, DYinfo->quad_surf->pt1, box_p4 );
      BScrossp( &msg, x_axis, y_axis, vec );
      BSprepcarc( &msg, box_p3, DYinfo->quad_surf->pt1, box_p4, vec,
		  DYinfo->header[3].geometry.bspcurve, unit_normal, &type );

      /* construct fourth arc connecting box_p2 and box_p4 */
      BSprepcarc( &msg, box_p2, cnt_pt, box_p4, DYinfo->quad_surf->vec1,
		  DYinfo->header[4].geometry.bspcurve, unit_normal, &type );

      /* if there is overlapping, then draw a circle */
      if ( draw_circle )
	/* construct a full circle centered at cnt_pt */
	BSprepcirc( &msg, cnt_pt, &radius1, DYinfo->quad_surf->vec1,
		    DYinfo->header[6].geometry.bspcurve, unit_normal, &type );

      /* compute the unit_pts using the radius at the starting point */
      if ( radius > radius1 )
      {
	angle1 = 2 * acos(( radius - cht_tol ) / radius );
	DYinfo->unit_pts = 1.0 / ( angle1 * radius );
      }
      else
      {
	angle1 = 2 * acos(( radius1 - cht_tol ) / radius1 );
	DYinfo->unit_pts = 1.0 / ( angle1 * radius1 );
      }
    }
    *buffers = DYinfo->header;
    if ( draw_circle )
      *num_buffers = 7;
    else
      *num_buffers = 5;
  }
  else
  {
    IGRvector z_vec;
    IGRboolean which;

    if ( DYinfo->quad_surf->type == BSFULL_CYL ||
	 DYinfo->quad_surf->type == BSPART_CYL ||
	 DYinfo->quad_surf->type == BSFULL_CONE ||
	 DYinfo->quad_surf->type == BSPART_CONE )
    {
      /* construct line 1 of the circular box */
      memcpy( (char *)DYinfo->header[1].geometry.polyline->points, 
        (char *)DYinfo->p2,
	      3 * sizeof( IGRdouble ));
      memcpy( (char *)(DYinfo->header[1].geometry.polyline->points + 3), 
        (char *)DYinfo->p1,
	      3 * sizeof( IGRdouble ));
    }
    else
    {
      /* construct third arc connecting box_p3 and box_p4 */
      BSmkvec( &msg, x_axis, DYinfo->quad_surf->pt1, DYinfo->p2 );
      BSmkvec( &msg, y_axis, DYinfo->quad_surf->pt1, DYinfo->p1 );
      BScrossp( &msg, x_axis, y_axis, vec );
      BSprepcarc( &msg, DYinfo->p2, DYinfo->quad_surf->pt1, DYinfo->p1, vec,
		  DYinfo->header[1].geometry.bspcurve, unit_normal, &type );
    }

    /* if the tangent vector is reversed, do flip y and z vectors */
    if ( DYinfo->reverse == TRUE )
    {
      DYinfo->tang_vec[0] = -DYinfo->tang_vec[0];
      DYinfo->tang_vec[1] = -DYinfo->tang_vec[1];
      DYinfo->tang_vec[2] = -DYinfo->tang_vec[2];
      DYinfo->y_axis1[0] = -DYinfo->y_axis1[0];
      DYinfo->y_axis1[1] = -DYinfo->y_axis1[1];
      DYinfo->y_axis1[2] = -DYinfo->y_axis1[2];
      DYinfo->y_axis2[0] = -DYinfo->y_axis2[0];
      DYinfo->y_axis2[1] = -DYinfo->y_axis2[1];
      DYinfo->y_axis2[2] = -DYinfo->y_axis2[2];
      z_vec[0] = -DYinfo->quad_surf->vec1[0];
      z_vec[1] = -DYinfo->quad_surf->vec1[1];
      z_vec[2] = -DYinfo->quad_surf->vec1[2];
    }

    /* compute the angle of rotation */
    if ( fabs( DYinfo->int_uv - DYinfo->uv1 ) <= 1e-4 )
      angle = 2.0 * M_PI;
    else
    {
      /* compute two unit vectors which will span the angle */
      switch ( DYinfo->quad_surf->type )
      {
      case BSFULL_CYL:
      case BSPART_CYL:
	/* get starting and ending points */
	if ( DYinfo->u_or_v == 1 )
	  BSsfeval( DYinfo->quad_surf->bspsf, DYinfo->uv1, 0.0, 0,
		    &start_pt, &msg );
	else
	  BSsfeval( DYinfo->quad_surf->bspsf, 0.0, DYinfo->uv1, 0,
		    &start_pt, &msg );
	memcpy((char *) end_pt, (char *)DYinfo->pt_buf, 
            3 * sizeof( IGRdouble ));

	BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, start_pt );
	v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	/* find the center of the circle at the starting point */
	cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v * DYinfo->quad_surf->vec1[0];
	cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v * DYinfo->quad_surf->vec1[1];
	cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v * DYinfo->quad_surf->vec1[2];

	/* compute starting and ending vectors */
	BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	BSnorvec( &msg, start_vec );
	BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	BSnorvec( &msg, end_vec );
	break;

      case BSFULL_CONE:
      case BSPART_CONE:
	which = ( DYinfo->quad_surf->flag1 == 0 ||
		  DYinfo->quad_surf->flag1 == 1 );

	/* get starting and ending points */
	if ( which )
	{
	  if ( DYinfo->u_or_v == 1 )
	    BSsfeval( DYinfo->quad_surf->bspsf, DYinfo->uv1, 0.0, 0,
		      &start_pt, &msg );
	  else
	    BSsfeval( DYinfo->quad_surf->bspsf, 0.0, DYinfo->uv1, 0,
		      &start_pt, &msg );
	  memcpy( (char *)end_pt, (char *)DYinfo->pt_buf, 
            3 * sizeof( IGRdouble ));

	  BSmkvec( &msg, vec, DYinfo->quad_surf->pt1, start_pt );
	  v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	  /* find the center of the circle at the starting point */
	  cnt_pt[0] = DYinfo->quad_surf->pt1[0] + v*DYinfo->quad_surf->vec1[0];
	  cnt_pt[1] = DYinfo->quad_surf->pt1[1] + v*DYinfo->quad_surf->vec1[1];
	  cnt_pt[2] = DYinfo->quad_surf->pt1[2] + v*DYinfo->quad_surf->vec1[2];

	  /* compute the starting and ending vectors */
	  BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	  BSnorvec( &msg, start_vec );
	  BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	  BSnorvec( &msg, end_vec );
	}
	else
	{
	  if ( DYinfo->u_or_v == 1 )
	    BSsfeval( DYinfo->quad_surf->bspsf, DYinfo->uv1, 1.0, 0,
		      &start_pt, &msg );
	  else
	    BSsfeval( DYinfo->quad_surf->bspsf, 1.0, DYinfo->uv1, 0,
		      &start_pt, &msg );
	  memcpy( (char *)end_pt, (char *)(DYinfo->pt_buf + 3), 
            3 * sizeof( IGRdouble ));

	  BSmkvec( &msg, vec, DYinfo->quad_surf->pt2, start_pt );
	  v = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );

	  /* find the center of the circle at the starting point */
	  cnt_pt[0] = DYinfo->quad_surf->pt2[0] + v*DYinfo->quad_surf->vec1[0];
	  cnt_pt[1] = DYinfo->quad_surf->pt2[1] + v*DYinfo->quad_surf->vec1[1];
	  cnt_pt[2] = DYinfo->quad_surf->pt2[2] + v*DYinfo->quad_surf->vec1[2];

	  /* compute the starting and ending vectors */
	  BSmkvec( &msg, start_vec, cnt_pt, start_pt );
	  BSnorvec( &msg, start_vec );
	  BSmkvec( &msg, end_vec, cnt_pt, end_pt );
	  BSnorvec( &msg, end_vec );
	}
	break;

      case BSSPHERE:
	/* find mid points on the starting and ending rule lines */
	BSsfeval( DYinfo->quad_surf->bspsf, 0.5, DYinfo->uv1, 0,
		  &start_pt, &msg );
	BSsfeval( DYinfo->quad_surf->bspsf, 0.5, DYinfo->int_uv, 0,
		  &end_pt, &msg );

	/* compute starting and ending vectors */
	BSmkvec( &msg, start_vec, DYinfo->quad_surf->pt1, start_pt );
	BSnorvec( &msg, start_vec );
	BSmkvec( &msg, end_vec, DYinfo->quad_surf->pt1, end_pt );
	BSnorvec( &msg, end_vec );
	break;
      }

      BScrossp( &msg, DYinfo->tang_vec, start_vec, vec );
      if ( BSdotp( &msg, vec, DYinfo->quad_surf->vec1 ) > 0 )
	BScrossp( &msg, end_vec, start_vec, vec );
      else
	BScrossp( &msg, start_vec, end_vec, vec );

      sin_val = BSdotp( &msg, vec, DYinfo->quad_surf->vec1 );
      cos_val = BSdotp( &msg, start_vec, end_vec );

      angle = atan2( sin_val, cos_val );
      if ( angle < 0 )
	angle += 2 * M_PI;
    }

    /* evaluate sin and cos */
    sin_val = sin( angle );
    cos_val = cos( angle );

    /* now rotate DYinfo->p1 to the desired position */
    box_p3[0] = DYinfo->cnt1[0] + DYinfo->x_axis1[0] * cos_val
                                + DYinfo->y_axis1[0] * sin_val;
    box_p3[1] = DYinfo->cnt1[1] + DYinfo->x_axis1[1] * cos_val
                                + DYinfo->y_axis1[1] * sin_val;
    box_p3[2] = DYinfo->cnt1[2] + DYinfo->x_axis1[2] * cos_val
                                + DYinfo->y_axis1[2] * sin_val;

    /* construct first arc connecting DYinfo->p1 and box_p3 */
    BSprepcarc( &msg, DYinfo->p1, DYinfo->cnt1, box_p3,
	        ( DYinfo->reverse == TRUE ? z_vec : DYinfo->quad_surf->vec1 ),
	        DYinfo->header[2].geometry.bspcurve, unit_normal, &type );

    /* now rotate DYinfo->p2 to the desired position */
    box_p4[0] = DYinfo->cnt2[0] + DYinfo->x_axis2[0] * cos_val
                                + DYinfo->y_axis2[0] * sin_val;
    box_p4[1] = DYinfo->cnt2[1] + DYinfo->x_axis2[1] * cos_val
                                + DYinfo->y_axis2[1] * sin_val;
    box_p4[2] = DYinfo->cnt2[2] + DYinfo->x_axis2[2] * cos_val
                                + DYinfo->y_axis2[2] * sin_val;

    if ( DYinfo->quad_surf->type == BSFULL_CYL ||
	 DYinfo->quad_surf->type == BSPART_CYL ||
	 DYinfo->quad_surf->type == BSFULL_CONE ||
	 DYinfo->quad_surf->type == BSPART_CONE )
    {
      /* construct line 2 of the circular box */
      memcpy( (char *)DYinfo->header[3].geometry.polyline->points, 
        (char *)box_p3,
	      3 * sizeof( IGRdouble ));
      memcpy( (char *)(DYinfo->header[3].geometry.polyline->points + 3), 
        (char *)box_p4,
	      3 * sizeof( IGRdouble ));
    }
    else
    {
      /* construct third arc connecting box_p3 and box_p4 */
      BSmkvec( &msg, x_axis, DYinfo->quad_surf->pt1, box_p3 );
      BSmkvec( &msg, y_axis, DYinfo->quad_surf->pt1, box_p4 );
      BScrossp( &msg, x_axis, y_axis, vec );
      BSprepcarc( &msg, box_p3, DYinfo->quad_surf->pt1, box_p4, vec,
		  DYinfo->header[3].geometry.bspcurve, unit_normal, &type );
    }

    /* construct second arc connecting DYinfo->p2 and box_p4 */
    BSprepcarc( &msg, DYinfo->p2, DYinfo->cnt2, box_p4,
	        ( DYinfo->reverse == TRUE ? z_vec : DYinfo->quad_surf->vec1 ),
	        DYinfo->header[4].geometry.bspcurve, unit_normal, &type );

    *buffers = DYinfo->header;
    *num_buffers = 5;
  }

  DYinfo->rc = BSSUCC;

 quit:
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Init method                                                          *
 *----------------------------------------------------------------------*/
method init( IGRint type; char *str_ptr )
{
  IGRlong sts = OM_S_SUCCESS;

  ME.super_cmd->mytype = type;
  me->num_poly_ln = 0;

  return sts;
}

/*----------------------------------------------------------------------*
 * Wakeup method                                                        *
 *----------------------------------------------------------------------*/
method wakeup( IGRint pos )
{
  IGRlong msg, sts = OM_S_SUCCESS;

  switch ( ME.super_cmd->state )
  {
  case LOCATE_SURF:
    /* hilite located object */
    gr$display_object( object_id = &me->elem.located_obj,
		       mode = GRhd );
    break;

  case INPUT_START_PT:
    /* hilite located object and surface */
    gr$display_object( object_id = &me->elem.located_obj,
		       mode = GRhd );
    gr$display_object( object_id = &me->lc_surf.located_obj,
		       mode = GRhd );

    /* show the rectangle box */
    sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
						       &me->elem,
						       &me->rect,
						       &me->ele_symb.display_attr,
						       TRUE,
						       FALSE ),
		   targetid = my_id );
    break;

  case ACC_DIRECTION:
    /* show the rule line at the starting point */
    sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
						     &me->quad_surf,
						     me->start_uv,
						     me->u_or_v,
						     &me->surf_symb.display_attr,
						     TRUE ),
		   targetid = my_id );

    /* show the default wrap direction at the starting point */
    sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
						       &me->lc_surf,
						       me->start_pt,
						       me->tang_vec,
						       &ME.ECelement->active_display,
						      TRUE ),
		   targetid = my_id );
    break;

  case END_PT_METHOD:
    /* erase the box that encloses the element */
    sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
						       &me->elem,
						       &me->rect,
						       &me->ele_symb.display_attr,
						       FALSE,
						       FALSE ),
		   targetid = my_id );

    /* erase the tangent vector */
    sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
						       &me->lc_surf,
						       me->start_pt,
						       me->tang_vec,
						       &ME.ECelement->active_display,
						       FALSE ),
		   targetid = my_id );

    /* redraw the rule line (otherwise, some flaw in the display ) */
    sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
						     &me->quad_surf,
						     me->start_uv,
						     me->u_or_v,
						     &me->surf_symb.display_attr,
						     TRUE ),
		   targetid = my_id );
    break;

  case ACC_ELE_DIRECTION:
    if ( me->arc_type == TWO_RULE_LNS )
    {
      /* redraw the rule line at the starting point */
      sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
						       &me->quad_surf,
						       me->start_uv,
						       me->u_or_v,
						       &me->surf_symb.display_attr,
						       TRUE ),
		     targetid = my_id );

      /* show the rule line at the ending point */
      sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
						       &me->quad_surf,
						       me->end_uv,
						       me->u_or_v,
						       &me->surf_symb.display_attr,
						       TRUE ),
		     targetid = my_id );
    }
    /* show the box that encloses the element */
    sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
						       &me->elem,
						       &me->rect,
						       &me->ele_symb.display_attr,
						       TRUE,
						       TRUE ),
		   targetid = my_id );
    break;
  }
  return sts;
}

/*----------------------------------------------------------------------*
 * Execute method                                                       *
 *----------------------------------------------------------------------*/
method execute( IGRint *response; IGRchar *response_data; IGRint pos )
{
  IGRlong loc_mask, acc_mask, event_mask;
  struct GRlc_locate loc_attr;
  OMuword ele_e_class_ids[5], ele_r_class_ids[5], ele_id;
  OMuword surf_e_class_ids[3], surf_r_class_ids[3], surf_id;
  OM_S_CLASSLIST ele_elig, ele_rtree, surf_elig, surf_rtree;
  struct GRevent acc_event;
  IGRboolean loop = TRUE;
  IGRvector vec;
  IGRdouble z1, z2;
  IGRint z_sign;
  IGRlong sts, msg, siz_buf, ret_bytes;

  ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_Wrap );

  /* initialize masks */
  loc_mask = GRm_DATA | GRm_BACK_UP | GRm_RESTART;
  acc_mask = GRm_DATA | GRm_RESTART;
  event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART;

  /* initialize locate attrbutes */
  loc_attr.properties = COPY_LC_PROPS;
  loc_attr.owner_action = LC_NON_GEOM_MOD;

  /* initialize locate eligible element classes */
  ele_rtree.w_count = ele_elig.w_count = 4;
  ele_rtree.w_flags = ele_elig.w_flags = OM_CLST_subclass;
  ele_elig.p_classes = ele_e_class_ids;
  ele_rtree.p_classes = ele_r_class_ids;

  om$get_classid( classname = "GRplanar",
		  p_classid = &ele_id );
  ele_r_class_ids[0] = ele_e_class_ids[0] = ele_id;
  om$get_classid( classname = "GRtext",
		  p_classid = &ele_id );
  ele_r_class_ids[1] = ele_e_class_ids[1] = ele_id;
  om$get_classid( classname = "GRbspline",
		  p_classid = &ele_id );
  ele_r_class_ids[2] = ele_e_class_ids[2] = ele_id;
  om$get_classid( classname = "GRgrgrp",
		  p_classid = &ele_id );
  ele_r_class_ids[3] = ele_e_class_ids[3] = ele_id;

  /* initialize locate eligible surface classes */
  surf_rtree.w_count = surf_elig.w_count = 2;
  surf_rtree.w_flags = surf_elig.w_flags = OM_CLST_subclass;
  surf_elig.p_classes = surf_e_class_ids;
  surf_rtree.p_classes = surf_r_class_ids;

  om$get_classid( classname = "EMScone",
		  p_classid = &surf_id );
  surf_r_class_ids[0] = surf_e_class_ids[0] = surf_id;
  om$get_classid( classname = "EMSsphere",
		  p_classid = &surf_id );
  surf_r_class_ids[1] = surf_e_class_ids[1] = surf_id;

  /* enter infinite loop */
  do
  {
    switch ( ME.super_cmd->state )
    {
    case 0:
      ME.super_cmd->state = LOCATE_ELE;
      break;

    case LOCATE_ELE:
      {
	/* default is to accept the displayed wrap direction */
	me->reverse = FALSE;

	/* locate the element to be wrapped */
	sts = lc$locate( rc = &msg,
			 event1 = &me->locev,
			 event2 = &acc_event,
			 mask1 = loc_mask,
			 mask2 = acc_mask,
			 response = response,
			 response_data = response_data,
			 display_flag = MANIP_LC_DISFLAG,
			 locate_key = IDFF_P_IdentElem,
			 acc_key = IDFF_P_AccptRejElem,
			 relocate_key = IDFF_E_RelocElem,
			 attributes = &loc_attr,
			 stack = &me->locate_stack,
			 rtree_classes = &ele_rtree,
			 eligible_classes = &ele_elig );

	/* verify the correctness of input */
	if ( ! ( 1 & msg ))
	{
	  if ( me->locev.response == EX_BACK_UP )
	    ME.super_cmd->state = LOCATE_ELE;
	  else
	    return OM_S_SUCCESS;
	}
	else
	{
	  /* save the located element and gragad info */
	  me->elem = acc_event.located_object[0];
	  me->gd_os = acc_event.event.button.osnum;
	  me->gd_id = acc_event.event.button.objid;

	  /* initialize active display and active level */
	  siz_buf = sizeof( ME.ECelement->active_display );
	  gr$get_active_display( msg = &msg,
				 sizbuf = &siz_buf,
				 buffer = &ME.ECelement->active_display,
				 nret = &ret_bytes );
	  siz_buf = sizeof( ME.ECelement->active_level );
	  gr$get_active_level( msg = &msg,
			       sizbuf = &siz_buf,
			       buffer = &ME.ECelement->active_level,
			       nret = &ret_bytes );
	  siz_buf = sizeof( ME.ECelement->md_env );
	  gr$get_module_env( msg = &msg,
			     sizbuf = &siz_buf,
			     buffer = &ME.ECelement->md_env,
			     nret = &ret_bytes );

	  /*---------------------------------------------------*/
	  /* initialize the polyline structure of the element  */
	  /*---------------------------------------------------*/

	  /* if allocated space before, then free it first */
	  if ( me->num_poly_ln != 0 )
	  {
	    IGRint i;

	    for ( i = 0; i < me->num_poly_ln; i++ )
	    {
	      om$dealloc( ptr = me->poly_lns[i].points );
	      me->poly_lns[i].points = NULL;
	    }
	    om$dealloc( ptr = me->poly_lns );
	    me->poly_lns = NULL;
	    me->num_poly_ln = 0;
	  }
	  sts = om$send( msg = message IDwrap.get_polyline( &msg,
							    &me->elem,
							    me->gd_os,
							    me->gd_id,
							    &ME.ECelement->active_display,
							    &me->num_poly_ln,
							    &me->poly_lns ),
			 targetid = my_id );
	  if ( msg == FALSE )
	  {
	    /* dehilite the located element */
	    gr$display_object( object_id = &me->elem.located_obj,
			       mode = GRhe );
	    return OM_S_SUCCESS;
	  }

	  /* get symbology of the element */
	  sts = om$send( msg = message GRvg.GRgetsymb( &msg, &me->ele_symb ),
			 targetid = me->elem.located_obj.objid,
			 targetos = me->elem.located_obj.osnum );
	  if ( (IGRint) me->ele_symb.display_attr.weight < GR_HI_WEIGHT - 1 )
	    me->ele_symb.display_attr.weight++;

	  /* used for dashed box enclosing element */
	  if ( me->ele_symb.display_attr.style != 3 )
	    me->ele_symb.display_attr.style = 3;
	  else
	    me->ele_symb.display_attr.style = 0;

	  /* goto the next state */
	  ME.super_cmd->state = LOCATE_SURF;
	}
	break;
      }
    case LOCATE_SURF:
      {
	/* locate the quadric surface to wrap onto */
	sts = lc$locate( rc = &msg,
			 event1 = &me->locev,
			 event2 = &acc_event,
			 mask1 = loc_mask,
			 mask2 = acc_mask,
			 response = response,
			 response_data = response_data,
			 display_flag = SURF_LC_DISFLAG,
			 locate_key = IDFF_P_IdentSurf,
			 acc_key = IDFF_P_AccptRejSurf,
			 relocate_key = IDFF_E_RelocSurf,
			 attributes = &loc_attr,
			 stack = &me->locate_stack,
			 rtree_classes = &surf_rtree,
			 eligible_classes = &surf_elig );

	/* verify the correctness of input */
	if ( !( 1 & msg ))
	{
	  if ( me->locev.response == EX_BACK_UP )
	  {
	    /* dehilite the located element */
	    gr$display_object( object_id = &me->elem.located_obj,
			       mode = GRhe );
	    ME.super_cmd->state = LOCATE_ELE;
	  }
	  else
	    return OM_S_SUCCESS;
	}
	else
	{
	  /* save the located surface */
	  me->lc_surf = acc_event.located_object[0];

	  /* dehilite both the element and the surface */
	  gr$display_object( object_id = &me->elem.located_obj,
			     mode = GRhe );
	  gr$display_object( object_id = &me->lc_surf.located_obj,
			     mode = GRhe );

	  /*---------------------------------------------------*/
	  /* initialize surface geometry                       */
	  /*---------------------------------------------------*/

	  /* if allocated space before, then free it first */
	  if ( me->quad_surf.bspsf )
	    om$dealloc( ptr = me->quad_surf.bspsf );
	  sts = om$send( msg = message IDwrap.init_surf_geom( &msg,
							      &me->lc_surf,
							      &me->quad_surf,
							      &me->u_or_v ),
			 targetid = my_id );

	  if ( msg == BSNULL )
	  {
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_UNSUPSURF );
	    /* hilite the located element and locate surface again */
	    gr$display_object( object_id = &me->elem.located_obj,
			       mode = GRhd );
	    ME.super_cmd->state = LOCATE_SURF;
	  }
	  else
	  {
	    /* get symbology of the surface */
	    sts = om$send( msg = message GRvg.GRgetsymb( &msg, &me->surf_symb ),
			   targetid = me->lc_surf.located_obj.objid,
			   targetos = me->lc_surf.located_obj.osnum );
	    if ( (IGRint)me->surf_symb.display_attr.weight < GR_HI_WEIGHT - 1 )
	      me->surf_symb.display_attr.weight++;

	    /*---------------------------------------------------*/
	    /* compute the rectangle enclosing the input planar  */
	    /* element                                           */
	    /*---------------------------------------------------*/
	    sts = om$send( msg = message IDwrap.cnst_ele_rect( &msg,
							       &me->elem,
							       me->quad_surf.vec1,
							       &me->rect ),
			   targetid = my_id );

	    if ( msg == BSFAIL )
	    {
	      /* hilite the located element and locate surface again */
	      gr$display_object( object_id = &me->elem.located_obj,
				 mode = GRhd );

	      ME.super_cmd->state = LOCATE_SURF;
	    }
	    else
	    {
	      /* show the rectangle */
	      sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
								 &me->elem,
								 &me->rect,
								 &me->ele_symb.display_attr,
								 TRUE,
								 FALSE ),
			     targetid = my_id );

	      /* determine if the height is within the surface height */
	      if ( (( me->quad_surf.type == BSFULL_CYL ||
		      me->quad_surf.type == BSPART_CYL ) &&
		      me->rect.rect_hgt >= me->quad_surf.len2 ) ||
		   (( me->quad_surf.type == BSFULL_CONE ||
		      me->quad_surf.type == BSPART_CONE ) &&
		      me->rect.rect_hgt >= ( me->quad_surf.len3 / cos( me->quad_surf.len4 ))) ||
		   ( me->quad_surf.type == BSSPHERE &&
		     me->rect.rect_hgt >= M_PI * me->quad_surf.len1 ))
	      {
		ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WRPELETOOLG );

		/* erase the box that encloses the element */
		sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
								   &me->elem,
								   &me->rect,
								   &me->ele_symb.display_attr,
								   FALSE,
								   FALSE ),
			       targetid = my_id );
		
		/* hilite the located element and locate surface again */
		gr$display_object( object_id = &me->elem.located_obj,
				   mode = GRhd );

		ME.super_cmd->state = LOCATE_SURF;
	      }
	      else
		ME.super_cmd->state = INPUT_START_PT;
	    }
	  }
	}
	break;
      }
    case INPUT_START_PT:
      {
	/* dynamically determine the starting point */
	ex$message( field = PROMPT_FIELD, msgnumb = IDFF_P_StartWrpPt );

	/* initialize the DYquad_surf surface structure */
	me->dp_surf.quad_surf = &me->quad_surf;
	me->dp_surf.len1 = me->rect.rect_len;
	me->dp_surf.len2 = me->rect.rect_hgt / 2.0;
	me->dp_surf.u_or_v = me->u_or_v;
	me->dp_surf.which = TRUE;	/* want to draw the box */
	me->dp_surf.reverse = FALSE;

	sts = DYrule_ln( &me->dp_surf, &ME.ECelement->active_display, &me->ele_symb.display_attr );

	/* accept or reject starting point */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  /* erase the box that encloses the element */
	  sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							     &me->elem,
							     &me->rect,
							     &me->ele_symb.display_attr,
							     FALSE,
							     FALSE ),
			 targetid = my_id );

	  /* hilite the located element and locate surface again */
	  gr$display_object( object_id = &me->elem.located_obj,
			     mode = GRhd );

	  ME.super_cmd->state = LOCATE_SURF;
	  break;

	case EX_RJT_MOVEON:
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
	  ME.super_cmd->state = INPUT_START_PT;
	  break;

	case EX_DATA:
	  /* if any error happened, go back to input again */
	  if ( me->dp_surf.rc == BSFAIL )
	    ME.super_cmd->state = INPUT_START_PT;
	  else
	  {
	    UI_status( " " );

	    /* save the start point, u or v parameter */
	    memcpy( (char *)me->start_pt, (char *)me->dp_surf.int_pt, 
		3 * sizeof( IGRdouble ));
	    me->start_uv = me->dp_surf.int_uv;

	    /* save the default wrap direction */
	    memcpy((char *) me->tang_vec, (char *)me->dp_surf.tang_vec, 3 * sizeof( IGRdouble ));

	    /* save the unit_pts */
	    me->unit_pts = ( IGRlong ) ( me->dp_surf.unit_pts + 0.5 );

	    /* if not sphere, then save the starting rule line */
	    if ( me->quad_surf.type != BSSPHERE )
	      memcpy((char *) me->start_ln, (char *)me->dp_surf.pt_buf, 
                6 * sizeof( IGRdouble ));
	    else
	      me->width = fabs( me->dp_surf.width1 + me->dp_surf.width2 );

	    /* computing z-offset (z_axis is the rotation axis) */
	    BSmkvec( &msg, vec, me->quad_surf.pt1, me->start_pt );
	    z1 = BSdotp( &msg, vec, me->quad_surf.vec1 );
	    z2 = BSdotp( &msg, me->rect.v_vec, me->quad_surf.vec1 );
	    z_sign = ( z2 > 0 ? 1 : -1 );

	    if ( z2 !=  0 )
	    {
	      switch ( me->quad_surf.type )
	      {
	      case BSFULL_CYL:
	      case BSPART_CYL:
		me->z_dis = z1 - z_sign * me->rect.rect_hgt / 2.0;
		break;
	      case BSFULL_CONE:
	      case BSPART_CONE:
		me->z_dis = z1 - z_sign * me->rect.rect_hgt / 2.0 * cos( me->quad_surf.len4 );
		break;
	      case BSSPHERE:
		if ( z_sign == 1 )
		  me->z_dis = z1 - me->dp_surf.width2;
		else
		  me->z_dis = z1 + me->dp_surf.width1;
		break;
	      }

	      /* show the rule line at the starting point */
	      sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							       &me->quad_surf,
							       me->start_uv,
							       me->u_or_v,
							       &me->surf_symb.display_attr,
							       TRUE ),
			     targetid = my_id );

	      /* show the default wrap direction at the starting point */
	      sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
								 &me->lc_surf,
								 me->start_pt,
								 me->tang_vec,
								 &ME.ECelement->active_display,
								 TRUE ),
			     targetid = my_id );

	      ME.super_cmd->state = ACC_DIRECTION;
	    }
	    else
	    {	/* element is perpendicular to the z_axis */
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_WRPELEPERP );
	      ME.super_cmd->state = LOCATE_ELE;
	    }
	  }
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    case ACC_DIRECTION:
      {
	/* accept or reject the wrap direction */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask,
			   msgnum = IDFF_P_AccptWrpDir,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  /* erase the wrap tangent direction vector */
	  sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
							     &me->lc_surf,
							     me->start_pt,
							     me->tang_vec,
							     &ME.ECelement->active_display,
							     FALSE ),
			 targetid = my_id );

	  /* erase the rule line */
	  sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							   &me->quad_surf,
							   me->start_uv,
							   me->u_or_v,
							   &me->surf_symb.display_attr,
							   FALSE ),
			 targetid = my_id );

	  ME.super_cmd->state = INPUT_START_PT;
	  break;

	case EX_RJT_MOVEON:
	case EX_DATA:
	  if ( acc_event.response == EX_RJT_MOVEON )
	    /* reverse the wrapping vector */
	    me->dp_surf.reverse = me->reverse = TRUE;
	  else
	    me->dp_surf.reverse = me->reverse = FALSE;

	  /* erase the box that encloses the element */
	  sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							     &me->elem,
							     &me->rect,
							     &me->ele_symb.display_attr,
							     FALSE,
							     FALSE ),
			 targetid = my_id );

	  /* erase the tangent vector */
	  sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
							     &me->lc_surf,
							     me->start_pt,
							     me->tang_vec,
							     &ME.ECelement->active_display,
							     FALSE ),
			 targetid = my_id );

	  /* redraw the rule line (otherwise, some flaw in the display ) */
	  sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							   &me->quad_surf,
							   me->start_uv,
							   me->u_or_v,
							   &me->surf_symb.display_attr,
							   TRUE ),
			 targetid = my_id );

	  /* go to the next state to get end point */
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    case END_PT_METHOD:
      {
	/* input method to select end point */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask | GRm_STRING,
			   msgnum = IDFF_P_WrpEndPtMd,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  /* show the default wrap direction at the starting point */
	  sts = om$send( msg = message IDwrap.disp_tang_vec( &msg,
							     &me->lc_surf,
							     me->start_pt,
							     me->tang_vec,
							     &ME.ECelement->active_display,
							     TRUE ),
			 targetid = my_id );
	  ME.super_cmd->state = ACC_DIRECTION;
	  break;

	case EX_RJT_MOVEON:
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_INVALIDOPT );
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	case EX_DATA:
	  /* this is save as the default */
	  strcpy( acc_event.event.keyin, "a" );

	  /* do not break so that code in the EX_STRING case will
	     be executed */

	case EX_STRING:
	  if ( acc_event.event.keyin[0] == '\0' ||
	       strcmp( acc_event.event.keyin, "a" ) == 0 )
	  {	/* default: true length */
	    /* record the type of input method */
	    me->arc_type = DISTANCE;
	    me->arc_len = me->rect.rect_len;

	    /* show the box that encloses the element */
	    sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							       &me->elem,
							       &me->rect,
							       &me->ele_symb.display_attr,
							       TRUE,
							       TRUE ),
			   targetid = my_id );

	    ME.super_cmd->state = ACC_ELE_DIRECTION;
	  }
	  else if ( strcmp( acc_event.event.keyin, "g" ) == 0 )
	    /* graphic input */
	    ME.super_cmd->state = INPUT_END_PT;

	  else if ( strcmp( acc_event.event.keyin, "d" ) == 0 )
	    /* input offset distance */
	    ME.super_cmd->state = INPUT_DISTANCE;

	  else
	  {	/* must input one choice */
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_INVALIDOPT );
	    ME.super_cmd->state = END_PT_METHOD;
	  }
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    case INPUT_END_PT:
      {
	/* dynamically determine the ending point */
	ex$message( field = PROMPT_FIELD, msgnumb = IDFF_P_InputEndPt );

	me->dp_surf.which = FALSE;	/* do not want to draw the box */

	sts = DYrule_ln( &me->dp_surf, &ME.ECelement->active_display, &me->ele_symb.display_attr );

	/* accept or reject the end point */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  /* go back to select end point method */
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	case EX_RJT_MOVEON:
	  /* you cannot reject before selecting something */
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
	  ME.super_cmd->state = INPUT_END_PT;
	  break;

	case EX_DATA:
	  /* if any error happened, go back to input again */
	  if ( me->dp_surf.rc == BSFAIL )
	    ME.super_cmd->state = INPUT_END_PT;
	  else
	  {
	    UI_status( " " );

	    /* save the end point, u parameter and end line */
	    memcpy((char *) me->end_pt, (char *)me->dp_surf.int_pt, 
                3 * sizeof( IGRdouble ));
	    me->end_uv = me->dp_surf.int_uv;

	    /* if not sphere, then save the ending rule line */
	    if ( me->quad_surf.type != BSSPHERE )
	      memcpy((char *) me->end_ln, (char *)me->dp_surf.pt_buf, 
                6 * sizeof( IGRdouble ));

	    /* redraw the rule line at the starting point */
	    sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							     &me->quad_surf,
							     me->start_uv,
							     me->u_or_v,
							     &me->surf_symb.display_attr,
							     TRUE ),
			   targetid = my_id );

	    /* show the rule line at the ending point */
	    sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							     &me->quad_surf,
							     me->end_uv,
							     me->u_or_v,
							     &me->surf_symb.display_attr,
							     TRUE ),
			   targetid = my_id );

	    /* show the box that encloses the element */
	    sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							       &me->elem,
							       &me->rect,
							       &me->ele_symb.display_attr,
							       TRUE,
							       TRUE ),
			   targetid = my_id );

	    me->arc_type = TWO_RULE_LNS;
	    me->arc_len = 0.0;
	    ME.super_cmd->state = ACC_ELE_DIRECTION;
	  }
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    case INPUT_DISTANCE:
      {
	/* input the distance offsetting from the starting rule line */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask | GRm_VALUE,
			   msgnum = IDFF_P_WrpOffDis,
			   value_type = GRIO_DISTANCE,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  /* go back to select end point method */
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	case EX_RJT_MOVEON:
	case EX_DATA:
	  /* ignore the clicks */
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_INVALIDOPT );
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	case EX_VALUE:
	  /* record the type of input method */
	  me->arc_type = DISTANCE;
	  me->arc_len = acc_event.event.value;

	  /* show the box that encloses the element */
	  sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							     &me->elem,
							     &me->rect,
							     &me->ele_symb.display_attr,
							     TRUE,
							     TRUE ),
			 targetid = my_id );

	  ME.super_cmd->state = ACC_ELE_DIRECTION;
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    case ACC_ELE_DIRECTION:
      {
	/* accept or reject the element direction */
	sts = co$getevent( msg = &msg,
			   event_mask = event_mask,
			   msgnum = IDFF_P_AccptEleWrpDir,
			   response = response,
			   response_data = response_data,
			   event = &acc_event );

	/* erase the displayed rectangle and direction */
	sts = om$send( msg = message IDwrap.disp_ele_rect( &msg,
							   &me->elem,
							   &me->rect,
							   &me->ele_symb.display_attr,
							   FALSE,
							   TRUE ),
		       targetid = my_id );

	/* erase displayed ending rule line */
	sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							 &me->quad_surf,
							 me->end_uv,
							 me->u_or_v,
							 &me->surf_symb.display_attr,
							 FALSE ),
		       targetid = my_id );

	switch ( acc_event.response )
	{

	case EX_BACK_UP:
	  ME.super_cmd->state = END_PT_METHOD;
	  break;

	case EX_RJT_MOVEON:
	case EX_DATA:
	  /* erase displayed starting rule line */
	  sts = om$send( msg = message IDwrap.disp_iso_cv( &msg,
							   &me->quad_surf,
							   me->start_uv,
							   me->u_or_v,
							   &me->surf_symb.display_attr,
							   FALSE ),
			 targetid = my_id );

	  if ( acc_event.response == EX_RJT_MOVEON )
	  {
	    me->rect.h_vec[0] = -me->rect.h_vec[0];
	    me->rect.h_vec[1] = -me->rect.h_vec[1];
	    me->rect.h_vec[2] = -me->rect.h_vec[2];

	    /* swap minimum and maximum points */
	    {
	      IGRpoint temp_pt;

	      memcpy( (char *)temp_pt, (char *)me->rect.min_pt, 
                3 * sizeof( IGRdouble ));
	      memcpy( (char *)me->rect.min_pt, (char *)me->rect.max_pt, 
                3 * sizeof( IGRdouble ));
	      memcpy( (char *)me->rect.max_pt, (char *)temp_pt, 
                3 * sizeof( IGRdouble ));
	    }
	  }

	  /* reverse the wrapping direction on the quadrics if needed */
	  if ( me->reverse == TRUE )
	  {
	    me->tang_vec[0] = -me->tang_vec[0];
	    me->tang_vec[1] = -me->tang_vec[1];
	    me->tang_vec[2] = -me->tang_vec[2];
	  }

	  /* compute the wrapping angle on the surface */
	  sts = om$send( msg = message IDwrap.comp_wrap_angle( &msg,
							       me->arc_type,
							       me->arc_len,
							       me->tang_vec,
							       &me->wrap_angle ),
			 targetid = my_id );

	  /* do actual wrapping */
	  sts = om$send( msg = message IDwrap.wrap_sf( &msg,
						       &me->rect,
						       me->wrap_angle,
						       me->width,
						       me->z_dis,
						       me->tang_vec,
						       &ME.ECelement->active_display,
						       ME.ECelement->active_level ),
			 targetid = my_id );

	  /* go back to the starting state */
	  ME.super_cmd->state = LOCATE_ELE;
	  break;

	default:
	  return OM_S_SUCCESS;
	}
	break;
      }
    }
  } while ( loop );

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Function initialize dynamic rule line display                        *
 *----------------------------------------------------------------------*/
IGRint DYrule_ln( dp_surf, disp1, disp2 )
struct DPquad_surf *dp_surf;
struct IGRdisplay *disp1, *disp2;
{
  struct IGRpolyline rule_ln, box_ln1, box_ln2;
  IGRdouble box_ln1_buf[6], box_ln2_buf[6];
  struct IGRbsp_curve *arc[7];
  struct IGResbc attr;
  IGRshort i, ratn = TRUE;
  IGRlong msg;

  /* initialize to display curve only */
  attr.is_polydis = FALSE;
  attr.is_curvedis = TRUE;

  if ( dp_surf->quad_surf->type == BSSPHERE )
  {	/* if sphere then this is an arc */

    /* allocate memory and initialize arc0 and arc1 */
    BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 0,
	       &arc[0], &msg );
    dp$build_dis_buffer( buffer = &dp_surf->header[0],
			 type = IGRBC,
			 display_att = disp1,
			 ele_spec_att = &attr,
			 geometry = ( struct IGRbsp_curve * ) arc[0] );

    BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 0,
	       &arc[1], &msg );
    dp$build_dis_buffer( buffer = &dp_surf->header[1],
			 type = IGRBC,
			 display_att = disp2,
			 ele_spec_att = &attr,
			 geometry = ( struct IGRbsp_curve * ) arc[1] );
  }
  else
  {
    /* initialize the first rule line structure */
    rule_ln.num_points = 2;
    rule_ln.points = dp_surf->pt_buf;
    dp$build_dis_buffer( buffer = &dp_surf->header[0],
			 type = IGRPY,
			 display_att = disp1,
			 geometry = ( struct IGRpolyline * ) &rule_ln );

    /* initialize line 1 of the circular box */
    box_ln1.num_points = 2;
    box_ln1.points = box_ln1_buf;
    dp$build_dis_buffer( buffer = &dp_surf->header[1],
			 type = IGRPY,
			 display_att = disp2,
			 geometry = ( struct IGrpolyline * ) &box_ln1 );
  }

  /* allocate memory and initialize arc2 */
  BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 1,
	     &arc[2], &msg );
  dp$build_dis_buffer( buffer = &dp_surf->header[2],
		       type = IGRBC,
		       display_att = disp2,
		       ele_spec_att = &attr,
		       geometry = ( struct IGRbsp_curve * ) arc[2] );

  if ( dp_surf->quad_surf->type == BSSPHERE )
  {	/* if sphere then this is an arc */
    
    /* allocate memory and initialize arc3 */
    BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 0,
	       &arc[3], &msg );
    dp$build_dis_buffer( buffer = &dp_surf->header[3],
			 type = IGRBC,
			 display_att = disp2,
			 ele_spec_att = &attr,
			 geometry = ( struct IGRbsp_curve * ) arc[3] );
  }
  else
  {	/* initialize line 2 of the circular box */
    box_ln2.num_points = 2;
    box_ln2.points = box_ln2_buf;
    dp$build_dis_buffer( buffer = &dp_surf->header[3],
			 type = IGRPY,
			 display_att = disp2,
			 geometry = ( struct IGrpolyline * ) &box_ln2 );
  }

  /* allocate memory and initialize arc4,5,6 */
  for ( i = 4; i < 7; i++ )
  {
    BSalloccv( BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, ratn, 0,
	       &arc[i], &msg );
    dp$build_dis_buffer( buffer = &dp_surf->header[i],
			 type = IGRBC,
			 display_att = disp2,
			 ele_spec_att = &attr,
			 geometry = ( struct IGRbsp_curve * ) arc[i] );
  }

  /* call dynamics */
  dp$dynamics( dyn_fun = DPsurf_pt,
	      information = dp_surf );

  /* free allocated memory */
  if ( dp_surf->quad_surf->type == BSSPHERE )
  {
    BSfreecv( &msg, arc[0] );
    BSfreecv( &msg, arc[1] );
    BSfreecv( &msg, arc[3] );
  }
    
  BSfreecv( &msg, arc[2] );
  for ( i = 4; i < 7; i++ )
    BSfreecv( &msg, arc[i] );

  return OM_S_SUCCESS;
}

end implementation IDwrap;
