/* $Id: SMsurf_fn.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMsurf_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMsurf_fn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.5  1997/02/19  21:18:54  pinnacle
# Replaced: smsurf/imp/SMsurf_fn.I for:  by jwfrosch for vds.241
#
# Revision 1.3  1997/02/12  22:03:22  pinnacle
# Replaced: smsurf/imp/SMsurf_fn.I for:  by jwfrosch for vds.241
#
# Revision 1.2  1997/02/06  21:03:08  pinnacle
# Replaced: smsurf/imp/SMsurf_fn.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  15:07:14  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*

      PL       22 NOV 1991  : Design date

 ABSTRACT :

	Implements Functions used for the space management product.
	- 1/	SMCrtCircCamber
	- 2/	SMCrtLnStrgSlCamber
	- 3/	SMCrtLnStrgPtsCamber
	- 4/	SMGetPtsFrSlope
	- 5/	SMGetVectCs
	- 6/	SMCrtBulkhead
	- 7/	SMSetSurfOrient
	- 8/	SMCrtLnStrgSlSheer
	- 9/	SMHullOrient

*/

class implementation Root;

#include <stdio.h>
#include <math.h>

#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "growner.h"
#include "grdpbmacros.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"

#include "EMSmsgdef.h"
#include "EMSssprops.h"
#include "EMS.h"
#include "EMSdef.h"
#include "EMScmacros.h"
#include "EMSopt.h"
#include "EMSdef.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "csdef.h"
#include "csmacros.h"

#include "VDSutil_def.h"
#include "VDmem.h"

#include "AS_status.h"

/* prototypes include */

#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsalloccv.h"
#include "bsprepcirc.h"
#include "bsarc3pts.h"
#include "bsfreecv.h"
#include "bsmkvec.h"

#include "bslenvec.h"
#include "bsfilletatr.h"
#include "bsmergarrcv.h"
#include "bspt_on_lne.h"

#define VD_DEBUG

#include "VDdebug.h"

#define  AS_DEBUG	1
#define  EPS		1e-6

from GRcurve		import	GRptextend;
from EMSsurface		import	EMalgnnrml,
				EMget_point_on_surface;
from GRgraphics		import	GRgetrang,
				GRdelete,
				GRaddwrng;
from GRvg		import	GRgenabsg;
from EMSsubbs		import	EMget_props,
				EMset_props;
from EMSproject		import	EMplace_surface_of_projection;
from GRgraphics		import	GRxform,
				GRaltconstruct,
				GRconstruct;
from SMglob		import	SMGetConnected;
from GRcontext		import	GRgetmodule_env;
from GRcoords		import	GRcvt_to_lcl_coords,
				GRcvt_to_wld_coords;

extern GRclassid	OPP_EMSproject_class_id,
			OPP_GR3dlinestr_class_id,
			OPP_GRbcsubbc_class_id;

/*1 ====================== SMCrtCircCamber =====================

	Function that creates a surface of projection based on a
	circular arc.

		- extension :0=hull range + 10%, 1 =bounded by hull,
				2=user defined

	return 1 if OK
	else 0.
 */

int	SMCrtCircCamber(msg, cs, md_env, prj_axis, rot_axis, position, ray,
			extension, ext_y1, ext_y2,
			ext_x1, ext_x2, cst, projsf )

long			*msg;		/* (O) completion code */
struct GRobj_env	*cs;		/* (I) input coord system */
struct GRmd_env		*md_env;	/* (I) md_env where create the surf */
char			prj_axis;	/* (I) axis of projection */
char			rot_axis;	/* (I) axis of rotation */
IGRdouble		position;	/* (I) position on rot_axis z0 */
IGRdouble		ray;		/* (I) rayon of circle */
IGRint			extension;	/* (I) how to extend the surface*/
IGRdouble		ext_y1;		/* (I) extension y negative */
IGRdouble		ext_y2;		/* (I) extension y positive */
IGRdouble		ext_x1;		/* (I) extension x negative */
IGRdouble		ext_x2;		/* (I) extension x positive */
struct GRvg_construct	*cst;		/* (I) construction list */
struct GRid		*projsf;	/* (O) constructed projection surface */

{
  IGRint		i,k, stat, type, Rev;
  IGRdouble		origine[3],vx[3],vy[3],vz[3], p1[3], p2[3], p3[3],
			center[3], a, b, dist1, dist2, point1[3], point2[3],
			rate, min[3], max[3],trmat[15], newpt[3];
  IGRdouble		range[6];
  struct IGRbsp_curve	*circarc;
  IGRshort		order;
  IGRlong		num_poles;
  IGRboolean		pos_orient_flag, rational;
  GRobjid		new_objid;
  struct GRmd_env	hull_env;
  struct  GRid		newsf, hull, go_hull;
  struct GRobj_env	surf1, surf2;
  double		my_x1, my_x2, my_y1,my_y2;
  IGRvector		normal;
  BSrc			rc;
  struct GRvg_construct	tmp_cst;

  *msg = OM_S_SUCCESS;

  if (cs == NULL || projsf == NULL || md_env == NULL || cst == NULL)
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }
  if (prj_axis != 'x' && prj_axis != 'X' && prj_axis != 'y' && prj_axis != 'Y' && prj_axis != 'z' && prj_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }
  if (rot_axis != 'x' && rot_axis != 'X' && rot_axis != 'y' && rot_axis != 'Y' && rot_axis != 'z' && rot_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  tmp_cst = *cst;

  circarc = NULL;
  projsf->objid = NULL_OBJID;
  projsf->osnum = md_env->md_id.osnum;

  stat = SMGetVectCs (	msg, &cs->obj_id, &cs->mod_env, prj_axis, rot_axis,
			origine, vx, vy, vz, (IGRdouble *)NULL);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetVectCs\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* if extension == 0 or 1 extend the curve to the hull range + 10% */

  my_x1 = fabs(ext_x1);
  my_x2 = fabs(ext_x2);
  my_y1 = fabs(ext_y1);
  my_y2 = fabs(ext_y2);

  if (extension !=2)
  {
    /* retrieve the active hull */

    if (!SMGetActHull(&hull,NULL, &hull_env,&go_hull))
    {
      printf("ERROR SMGetActHull\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    rate = 0.1;
    stat = SMExtToRng(&go_hull, &hull_env, NULL, &rate, range);
    if (!(stat&1))
    {
      printf("ERROR SMExtToRng\n ");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    my_x1 = fabs(BSdotp(&rc,&range[0],&vx[0]));
    my_x2 = fabs(BSdotp(&rc,&range[3],&vx[0]));
    my_y1 = fabs(BSdotp(&rc,&range[0],&vy[0]));
    my_y2 = fabs(BSdotp(&rc,&range[3],&vy[0]));
  }

  center[0] = -my_x1;
  center[1] = 0.;
  center[2] = position - ray;

  min[0] = center[0];
  min[1] = center[1] - my_y1;
  min[2] = center[2];

  max[0] = center[0];
  max[1] = center[1] + my_y2;
  max[2] = center[2];

  for(i=0;i<3;i++) point1[i] = point2[i] = center[i] ;
  point2[0] = my_x1+my_x2+center[0];

  dist1 = BSdistptpt(&rc, min, center);
  dist2 = BSdistptpt(&rc, max, center);

  if (rc != BSSUCC)
  {
    printf("ERROR BSdistptpt\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  k=0;
  for(i=0;i<9;i=i+3)
  {
    trmat[i] = vx[k];
    trmat[i+1] = vy[k];
    trmat[i+2] = vz[k];
    k++;
  }

  if (dist1 > ray || dist2 > ray )
  {
    /* compute the circle */

    order = 3;
    num_poles = 7;
    rational = TRUE;

    MatxVect(trmat, origine, center, newpt);
    for(k=0;k<3;k++) center[k] = newpt[k];

    (void)BSalloccv(order,num_poles, rational, 0, &circarc, &rc);
    if (rc != BSSUCC && rc!=BSNULL)
    {
      printf("ERROR Bad dynamic allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    (IGRboolean)BSprepcirc(&rc, center, &ray, vx, circarc, normal, &type);
    if (rc != BSSUCC)
    {
      printf("ERROR BSprepcirc\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }
  else
  {
    /* compute the circular arc by 3 ordered pts p1, p2, p3
       (y1= -my_y1, y2 = (my_y2-my_y1)/2 , y3= my_y2 ) */

    a = (my_y2-my_y1)/2;
    b = sqrt(ray*ray - a*a);

    p2[0] = center[0];
    p2[1] = center[1] + a;
    p2[2] = center[2] + b;

    a = my_y2;
    b = sqrt(ray*ray - a*a);

    p3[0] = center[0];
    p3[1] = center[1] + a;
    p3[2] = center[2] + b;

    a = -my_y1;
    b = sqrt(ray*ray - a*a);

    p1[0] = center[0];
    p1[1] = center[1] + a;
    p1[2] = center[2] + b;

    MatxVect(trmat, origine, p1, newpt);
    for(k=0;k<3;k++) p1[k] = newpt[k];

    MatxVect(trmat, origine, p2, newpt);
    for(k=0;k<3;k++) p2[k] = newpt[k];

    MatxVect(trmat, origine, p3, newpt);
    for(k=0;k<3;k++) p3[k] = newpt[k];

    /* alloc circarc of 7 poles, 7 weights, 10 knots (order 3)*/

    order = 3;
    num_poles = 7;
    rational = TRUE;

    (void)BSalloccv(order,num_poles, rational, 0, &circarc, &rc);
    if (rc != BSSUCC && rc!=BSNULL)
    {
      printf("ERROR Bad dynamic allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    (IGRboolean) BSarc3pts(&rc, p1, p2, p3, circarc);
    if (rc != BSSUCC)
    {
      printf("ERROR BSarc3pts\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }

  /* create the surface of projection */

  MatxVect(trmat, origine, point1, newpt);
  for(k=0;k<3;k++) point1[k] = newpt[k];

  MatxVect(trmat, origine, point2, newpt);
  for(k=0;k<3;k++) point2[k] = newpt[k];

  pos_orient_flag = TRUE;

  stat = om$construct (	msg	= message EMSproject.EMplace_surface_of_projection(
									&tmp_cst,
									 NULL,
									 NULL,
									 circarc,
									 NULL,
									 point1,
									 point2,
									 pos_orient_flag,
									&new_objid ),
			classid = OPP_EMSproject_class_id,
			p_objid = &projsf->objid,
			osnum	= projsf->osnum  );

  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR EMSproject.EMplace_surface_of_projection\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  projsf->objid = new_objid;

  /* limit the surface by the hull , Rev = 1 if hull is oriented outward */

  if (extension == 1)
  {
    surf1.obj_id.objid  = projsf->objid;
    surf1.obj_id.osnum  = projsf->osnum;
    surf1.mod_env.md_id = md_env->md_id;
    surf1.mod_env.md_env = md_env->md_env;
    surf1.mod_env.md_id.objid = NULL_OBJID;

    surf2.obj_id = go_hull;
    surf2.mod_env = hull_env;

    stat = SMHullOrient(&surf2, &Rev);

    tmp_cst = *cst;

    stat = SMSplS1ByS2(&tmp_cst, &surf1, &surf2, TRUE, TRUE, Rev, FALSE, &newsf);
    if (!(stat & 1))
    {
      printf("ERROR SMSplS1ByS2\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    projsf->objid = newsf.objid;
    projsf->osnum = newsf.osnum;
  }

wrapup:

  if (circarc)
  {
    (IGRboolean)BSfreecv(&rc,circarc);circarc = NULL;
  }
  return(1);
}

/*2 ====================== SMCrtLnStrgSlCamber =====================

	Function that creates a surface of projection based on a
	line string given by slope.

	x is the axis to create the surface of projection

	the line string is construct in the plane y/z.

	slopes are defined as z/y.

	(slopes, lens) must be given from depart point .

	symetry is made on z axis at y_depart.

	If no symetry is needed and there are some points on the other part
	of the symetry axis, these points must have their lens negatives.

		- extension :0=hull range + 10%, 1 =bounded by hull,
				2=user defined

	return 1 if OK
	else 0.
*/

int	SMCrtLnStrgSlCamber(msg, cs, md_env,  z_depart,
			y_depart, nb_pts, slopes, lens, symetry,
			extension, ext_x1, ext_x2, ext_y1, ext_y2, cst, projsf )

 long			*msg;		/* (O) completion code */
 struct GRobj_env	*cs;		/* (I) input coord system */
 struct GRmd_env	*md_env;	/* (I) active md_env */
 IGRdouble		z_depart;	/* (I) z depart*/
 IGRdouble		y_depart;	/* (I) y depart */
 IGRint			nb_pts;		/* (I) I = nb of defined slope */
 IGRdouble		*slopes;	/* (I) slope definition (z/y) */
 IGRdouble		*lens;		/* (I) len along each slope (y)*/
 IGRboolean		symetry	;	/* (I) if half side */
 IGRint			extension;	/* (I) how to extend the surface*/
 IGRdouble		ext_x1;		/* (I) extension x negative */
 IGRdouble		ext_x2;		/* (I) extension x positive */
 IGRdouble		ext_y1;		/* (I) extension y negative */
 IGRdouble		ext_y2;		/* (I) extension y positive */
 struct GRvg_construct	*cst;		/* (I) construction list */
 struct GRid		*projsf;	/* (O) constructed projection surface */

{
  IGRint		i,k, stat, num_pts, Rev;
  IGRdouble		origine[3], vx[3],vy[3],vz[3], *pts, *sympts,
			depart[3], point1[3], point2[3], rate,a, b,
			my_x1, my_x2, my_y1, my_y2, my_z1, my_z2,
			previous[3], endpt[3], extpt[3], y_min,
			y_max, x_min, x_max, scale, trmat[9];
  IGRdouble		range[6];
  IGRboolean		pos_orient_flag;
  struct IGRpolyline	polyline;
  GRobjid		new_objid;
  struct GRobj_env	surf1, surf2;
  struct GRvg_construct	tmp_cst;
  struct GRid		act_cs, line_id;
  struct GRmd_env	hull_env;
  struct  GRid		newsf, hull, go_hull;
  BSrc			rc;

  *msg = OM_S_SUCCESS;

  if (cs == NULL || projsf == NULL || md_env == NULL || cst == NULL || slopes == NULL || lens == NULL)
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  polyline.num_points = 0;
  polyline.points = NULL;
  pts = NULL;
  sympts = NULL;

  act_cs.osnum = md_env->md_id.osnum;
  cs$get_active_info(msg = msg, objid = &act_cs.objid);

  line_id.objid = NULL_OBJID;
  line_id.osnum = md_env->md_id.osnum;

  projsf->objid = NULL_OBJID;
  projsf->osnum = md_env->md_id.osnum;

  stat = SMGetVectCs(msg, &cs->obj_id, &cs->mod_env, 'x', 'z', origine, vx, vy, vz, &scale );
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetVectCs\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* if extension == 0 or 1 extend the curve to the hull range + 10% */

  my_x1 = fabs(ext_x1);
  my_x2 = fabs(ext_x2);
  my_y1 = fabs(ext_y1);
  my_y2 = fabs(ext_y2);

  if (extension !=2)
  {
    /* retrieve the active hull */

    if (!SMGetActHull(&hull,NULL, &hull_env,&go_hull))
    {
      printf("ERROR SMGetActHull\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    rate = 0.1;
    stat = SMExtToRng(&go_hull, &hull_env, NULL, &rate, range);
    if (!(stat&1))
    {
      printf("ERROR SMExtToRng\n ");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    my_x1 = fabs(BSdotp(&rc,&range[0],vx));
    my_x2 = fabs(BSdotp(&rc,&range[3],vx));

    my_y1 = fabs(BSdotp(&rc,&range[0],vy));
    my_y2 = fabs(BSdotp(&rc,&range[3],vy));
    my_z1 = fabs(BSdotp(&rc,&range[0],vz));
    my_z2 = fabs(BSdotp(&rc,&range[3],vz));
  }

  depart[0] = -my_x1;
  depart[1] = y_depart;
  depart[2] = z_depart;

  /* pts are on (vx, vy, vz) */

  if (symetry == TRUE)
  {
    pts = _MALLOC(3*(nb_pts+1),IGRdouble);
    if (pts == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    stat = SMGetPtsFrSlope(msg, 'y', depart, nb_pts, slopes, lens, pts);
    if (!(stat&(*msg)&1))
    {
      printf("ERROR SMGetPtsFrSlope\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    sympts = _MALLOC(3*(nb_pts),IGRdouble);
    if (sympts == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    for(i=0;i<nb_pts;i++)
      for(k=0;k<3;k++) sympts[3*i+k] = pts[3*(nb_pts-i) +k];

    for(i=0;i<nb_pts;i++)
      sympts[3*i+1] = 2*depart[1] - pts[3*(nb_pts-i) +1];

    polyline.num_points = 2*nb_pts+1;
    polyline.points = _MALLOC(3*(2*nb_pts+1),IGRdouble);
    if (polyline.points == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    for(i=0;i<3*nb_pts;i++)
      polyline.points[i] = sympts[i];

    k=i;
    for(i=0;i<3*(nb_pts+1);i++)
      polyline.points[k++] = pts[i];

    num_pts = 2*nb_pts+1;
  }
  else
  {
    polyline.num_points = nb_pts+1;
    polyline.points = _MALLOC(3*(nb_pts+1),IGRdouble);
    if (polyline.points == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    stat = SMGetPtsFrSlope(msg,'y',  depart, nb_pts, slopes, lens, polyline.points);
    if (!(stat&(*msg)&1))
    {
      printf("ERROR SMGetPtsFrSlope\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    num_pts = nb_pts+1;
  }

  /* extend the curve to the range if needed */

  y_min = polyline.points[1];
  x_min = polyline.points[0];

  previous[0] = polyline.points[3];
  endpt[0]    = polyline.points[0];

  previous[1] = polyline.points[4];
  endpt[1]    = polyline.points[1];

  previous[2] = polyline.points[5];
  endpt[2]    = polyline.points[2];

  for(i=0;i<3;i++) extpt[i] = polyline.points[i];

  if (y_min > -my_y1)
  {
    if ( fabs(endpt[1] - previous[1]) > EPS)
    {
      /* else  y cst cannot be changed */
      if (symetry == TRUE) a = -slopes[nb_pts-1];
      else a = slopes[0];

      b = previous[2] - a* previous[1];

      extpt[0] = polyline.points[0];
      extpt[1] = -my_y1;
      extpt[2] = -a*my_y1+b;
    }
  }

  for(i=0;i<3;i++)  polyline.points[i] = extpt[i];

  y_max = polyline.points[3*(polyline.num_points-1)+1];
  x_max = polyline.points[3*(polyline.num_points-1)];

  previous[0] = polyline.points[3*(polyline.num_points-1)-3];
  endpt[0]    = polyline.points[3*(polyline.num_points-1)];

  previous[1] = polyline.points[3*(polyline.num_points-1)+1-3];
  endpt[1]    = polyline.points[3*(polyline.num_points-1)+1];

  previous[2] = polyline.points[3*(polyline.num_points-1)+2-3];
  endpt[2]    = polyline.points[3*(polyline.num_points-1)+2];

  for(i=0;i<3;i++) extpt[i] = polyline.points[3*(polyline.num_points-1)+i];

  if (y_max < my_y2)
  {
    if ( fabs(endpt[1]-previous[1]) > EPS)
    {
      a = slopes[nb_pts-1];
      b = previous[2] - a* previous[1];

      extpt[0] = polyline.points[3*(polyline.num_points-1)];
      extpt[1] = my_y2;
      extpt[2] = a*my_y2+b;
    }
  }

  for(i=0;i<3;i++)  polyline.points[3*(polyline.num_points-1)+i] = extpt[i];

  /* convert in wrld cs */

  k=0;
  for(i=0;i<9;i=i+3)
  {
    trmat[i  ] = vx[k];
    trmat[i+1] = vy[k];
    trmat[i+2] = vz[k];
    k++;
  }

  for(i=0;i<3*polyline.num_points; i=i+3)
  {
    MatxVect(trmat, origine, &polyline.points[i], extpt);
    for(k=0;k<3;k++) polyline.points[i+k] = extpt[k];
  }

  /* create the polyline */

  tmp_cst = *cst;
  tmp_cst.geometry = (char *)&polyline;

  stat = om$construct (	msg	= message GRgraphics.GRaltconstruct(&tmp_cst),
			classid = OPP_GR3dlinestr_class_id,
			p_objid = &line_id.objid,
			osnum	= line_id.osnum  );
  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR GRgraphics.GRaltconstruct\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* create the surface of projection */

  for(i=0;i<3;i++) point1[i] = point2[i] = 0; ;
  point2[0] = my_x1 + my_x2;

  MatxVect(trmat, origine, point1, extpt);
  for(k=0;k<3;k++) point1[k] = extpt[k];

  MatxVect(trmat, origine, point2, extpt);
  for(k=0;k<3;k++) point2[k] = extpt[k];

  pos_orient_flag = TRUE;

  tmp_cst = *cst;

  stat = om$construct (	msg	= message EMSproject.EMplace_surface_of_projection(
									&tmp_cst,
									&line_id,
									 tmp_cst.env_info,
									 NULL,
									 NULL,
									 point1,
									 point2,
									 pos_orient_flag,
									&new_objid ),
			classid = OPP_EMSproject_class_id,
			p_objid = &projsf->objid,
			osnum	= projsf->osnum  );

  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR EMSproject.EMplace_surface_of_projection\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  projsf->objid = new_objid;

  /* limit the surface by the hull , Rev = 1 if hull is oriented outward */

  if (extension == 1)
  {
    surf1.obj_id.objid  = projsf->objid;
    surf1.obj_id.osnum  = projsf->osnum;
    surf1.mod_env.md_id = md_env->md_id;
    surf1.mod_env.md_env = md_env->md_env;
    surf1.mod_env.md_id.objid = NULL_OBJID;

    surf2.obj_id = go_hull;
    surf2.mod_env = hull_env;

    stat = SMHullOrient(&surf2, &Rev);

    tmp_cst = *cst;

    stat = SMSplS1ByS2(&tmp_cst, &surf1, &surf2, TRUE, TRUE, Rev, FALSE, &newsf);
    if (!(stat & 1))
    {
      printf("ERROR SMSplS1ByS2\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    projsf->objid = newsf.objid;
    projsf->osnum = newsf.osnum;
  }

wrapup:

  tmp_cst = *cst;
  if (line_id.objid != NULL_OBJID)
  {
    stat = om$send (	msg	 = message GRgraphics.GRdelete(msg,tmp_cst.env_info),
			senderid = NULL_OBJID,
			targetid = line_id.objid,
			targetos = line_id.osnum );
    as$status(sts=stat);
  }

  _FREE(pts);
  _FREE(sympts);
  _FREE(polyline.points);

  return(1);
}

/*3 ====================== SMCrtLnStrgPtsCamber =====================

	Function that creates a surface of projection based on a
	line string given by pts.

	prj_axis is the axis to create the surface of projection

	line string is construct in the plane ortho to this axis.

		- extension :0=hull range + 10%, 1 =bounded by hull,
				2=user defined

	return 1 if OK
	else 0.
*/

int	SMCrtLnStrgPtsCamber(msg, cs, md_env, prj_axis, z_axis,
			nb_pts, z_pos, y_pos, symetry,
			extension, ext_x1, ext_x2,cst, projsf )

 long			*msg;		/* (O) completion code */
 struct GRobj_env	*cs;		/* (I) input coord system */
 struct GRmd_env	*md_env;	/* (I) active md_env */
 char			prj_axis;	/* (I) axis of projection taken as x_axis*/
 char			z_axis;		/* (I) z axis  */
 IGRint			nb_pts;		/* (I) I = nb of defined (z_pos, y_pos)*/
 IGRdouble		*z_pos;		/* (I) z coords of pts*/
 IGRdouble		*y_pos;		/* (I) y coords of pts*/
 IGRboolean		symetry	;	/* (I) if half side */
 IGRint			extension;	/* (I) how to extend the surface*/
 IGRdouble		ext_x1;		/* (I) extension x negative */
 IGRdouble		ext_x2;		/* (I) extension x positive */
 struct GRvg_construct	*cst;		/* (I) construction list */
 struct GRid		*projsf;	/* (O) constructed projection surface */

{
  IGRint		i,k,l, stat, Rev;
  IGRdouble		origine[3], vx[3],vy[3],vz[3], my_x1, my_x2,
			my_y1, my_y2, depart[3], point1[3], point2[3], rate;
  IGRdouble		a, b, range[6], previous[3], endpt[3], extpt[3], y_min,
			y_max, x_min, x_max;
  IGRboolean		CENTER, pos_orient_flag;
  struct IGRpolyline	polyline;
  GRobjid		new_objid;
  struct GRvg_construct	tmp_cst;
  struct GRid		line_id;
  struct GRmd_env	hull_env;
  struct GRid		newsf, hull, go_hull;
  struct GRobj_env	surf1, surf2;
  BSrc			rc;

  *msg = OM_S_SUCCESS;
  if (cs == NULL || projsf == NULL || md_env == NULL || cst == NULL || z_pos == NULL || y_pos == NULL)
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  if (prj_axis != 'x' && prj_axis != 'X' && prj_axis != 'y' && prj_axis != 'Y' && prj_axis != 'z' && prj_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  if (z_axis != 'x' && z_axis != 'X' && z_axis != 'y' && z_axis != 'Y' && z_axis != 'z' && z_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  tmp_cst = *cst;

  CENTER = FALSE;
  polyline.num_points = 0;
  polyline.points = NULL;

  line_id.objid = NULL_OBJID;
  line_id.osnum = md_env->md_id.osnum;

  projsf->objid = NULL_OBJID;
  projsf->osnum = md_env->md_id.osnum;

  stat = SMGetVectCs(msg, &cs->obj_id, &cs->mod_env, prj_axis, z_axis,
		     origine,vx, vy, vz, (IGRdouble *)NULL);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetVectCs\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* if extension == 0 or 1 extend the curve to the hull range + 10% */

  my_x1 = fabs(ext_x1);
  my_x2 = fabs(ext_x2);
  my_y1 = 0.;
  my_y2 = 0.;

  if (extension !=2)
  {
    /* retrieve the active hull */

    if (!SMGetActHull(&hull,NULL, &hull_env,&go_hull))
    {
      printf("ERROR SMGetActHull\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    rate =0.1;
    stat = SMExtToRng(&go_hull, &hull_env, NULL, &rate, range);
    if (!(stat&1))
    {
      printf("ERROR SMExtToRng\n ");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    my_x1 = fabs(BSdotp(&rc,&range[0],vx));
    my_x2 = fabs(BSdotp(&rc,&range[3],vx));
    my_y1 = fabs(BSdotp(&rc,&range[0],vy));
    my_y2 = fabs(BSdotp(&rc,&range[3],vy));
  }

  if (symetry == TRUE)
  {
    for(i=0;i<3;i++)
      depart[i] = origine[i] + -my_x1 *vx[i] + y_pos[0]*vy[i] + z_pos[0]*vz[i];

    polyline.num_points = 2*nb_pts-1;
    polyline.points = _MALLOC(3*(2*nb_pts-1),IGRdouble);

    if (polyline.points == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    for(i=0;i<nb_pts-1;i++)
    {
      for(k=0;k<3;k++)
      {
	polyline.points[3*i+k] = origine[k] - my_x1*vx[k]
				  +(2*y_pos[0] - y_pos[nb_pts-1-i])*vy[k]
				  + z_pos[nb_pts-1-i]*vz[k];
      }
    }

    l = nb_pts -1;
    for(i=0;i<nb_pts;i++)
    {
      for(k=0;k<3;k++)
      {
	polyline.points[3*l+k] = origine[k] - my_x1*vx[k] +y_pos[i]*vy[k] +z_pos[i]*vz[k];
	l++;
      }
    }
  }
  else
  {
    polyline.num_points = nb_pts ;
    polyline.points = _MALLOC(3*nb_pts,IGRdouble);

    if (polyline.points == NULL)
    {
      printf("ERROR, Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    for(i=0;i<nb_pts;i++)
    {
      for(k=0;k<3;k++)
      {
	polyline.points[3*i+k] = origine[k]+ -my_x1 *vx[k] + y_pos[i]  *vy[k] + z_pos[i]  *vz[k];
      }
    }
  }

  /* extend the curve to the range */

  y_min = 0;
  for(i=0;i<3;i++) y_min = y_min +  polyline.points[i]*vy[i];

  x_min = 0;
  for(i=0;i<3;i++) x_min = x_min +  polyline.points[i]*vx[i];

  previous[0] = 0;
  for(i=0;i<3;i++) previous[0] = previous[0] + polyline.points[i+3]*vx[i];

  endpt[0] = 0;
  for(i=0;i<3;i++) endpt[0]    = endpt[0] + polyline.points[i]*vx[i];

  previous[1] = 0;
  for(i=0;i<3;i++) previous[1] = previous[1] + polyline.points[i+3]*vy[i];

  endpt[1] = 0;
  for(i=0;i<3;i++) endpt[1]    = endpt[1] + polyline.points[i]*vy[i];

  previous[2] = 0;
  for(i=0;i<3;i++) previous[2] = previous[2] + polyline.points[i+3]*vz[i];

  endpt[2] = 0;
  for(i=0;i<3;i++) endpt[2]    = endpt[2] + polyline.points[i]*vz[i];

  for(i=0;i<3;i++) extpt[i]    = polyline.points[i];

  if (prj_axis == 'x' && y_min > -my_y1)
  {
    if ( fabs(endpt[1] - previous[1]) > EPS)
    {
      /* else  y cst cannot be changed */
      a = (endpt[2] - previous[2])/(endpt[1] - previous[1]);
      b = previous[2] - a* previous[1];

      for(i=0;i<3;i++) extpt[i] = polyline.points[i]*vx[i] -my_y1*vy[i] +(-a*my_y1+b)*vz[i];
    }
  }
  else if (prj_axis == 'y' && x_min > -my_y1)
  {
    if ( fabs(endpt[0] - previous[0]) > EPS)
    {
      /* else  x cst cannot be changed */
      a = (endpt[2] - previous[2])/(endpt[0] - previous[0]);
      b = previous[2] - a* previous[0];

      for(i=0;i<3;i++) extpt[i] = -my_y1*vx[i] +polyline.points[i]*vy[i] +(-a*my_y1+b)*vz[i];
    }
  }
  for(i=0;i<3;i++)  polyline.points[i] = extpt[i];

  y_max = 0;
  for(i=0;i<3;i++) y_max = y_max+polyline.points[3*(polyline.num_points-1)+i]*vy[i];

  x_max = 0;
  for(i=0;i<3;i++) x_max = x_max+polyline.points[3*(polyline.num_points-1)+i]*vx[i];

  previous[0] = 0;
  for(i=0;i<3;i++) previous[0] = previous[0] + polyline.points[3*(polyline.num_points-1)+i-3]*vx[i];

  endpt[0] = 0;
  for(i=0;i<3;i++) endpt[0] = endpt[0] + polyline.points[3*(polyline.num_points-1)+i]*vx[i];

  previous[1] = 0;
  for(i=0;i<3;i++) previous[1] = previous[1] + polyline.points[3*(polyline.num_points-1)+i-3]*vy[i];

  endpt[1] = 0;
  for(i=0;i<3;i++) endpt[1] = endpt[1] + polyline.points[3*(polyline.num_points-1)+i]*vy[i];

  previous[2] = 0;
  for(i=0;i<3;i++) previous[2] = previous[2] + polyline.points[3*(polyline.num_points-1)+i-3]*vz[i];

  endpt[2] = 0;
  for(i=0;i<3;i++) endpt[2] = endpt[2] + polyline.points[3*(polyline.num_points-1)+i]*vz[i];

  for(i=0;i<3;i++) extpt[i] = polyline.points[3*(polyline.num_points-1)+i];

  if (prj_axis == 'x' && y_max  < my_y2)
  {
    if ( fabs(endpt[1]-previous[1]) > EPS)
    {
      a = (endpt[2]-previous[2])/(endpt[1]-previous[1]);
      b = previous[2] - a* previous[1];

      for(i=0;i<3;i++) extpt[i] = polyline.points[3*(polyline.num_points-1)]*vx[i] +my_y2*vy[i] +(a*my_y2+b)*vz[i];
    }
  }
  else if (prj_axis == 'y' && x_max < my_y2)
  {
    if ( fabs(endpt[0]-previous[0]) > EPS)
    {
      /* else  x cst cannot be changed */
      a = (endpt[2]-previous[2])/(endpt[0]-previous[0]);
      b = previous[2] - a* previous[0];

      for(i=0;i<3;i++) extpt[i] = my_y2*vx[i] +polyline.points[3*(polyline.num_points-1)+1]*vy[i] +(a*my_y2+b)*vz[i];
    }
  }

  for(i=0;i<3;i++)  polyline.points[3*(polyline.num_points-1)+i] = extpt[i];

  /* create the polyline */

  tmp_cst = *cst;
  tmp_cst.geometry = (char *) &polyline;

  stat = om$construct (	msg	= message GRgraphics.GRaltconstruct(&tmp_cst),
			classid = OPP_GR3dlinestr_class_id,
			p_objid = &line_id.objid,
			osnum	= line_id.osnum  );
  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR GRgraphics.GRaltconstruct\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* create the surface of projection */

  for(i=0;i<3;i++) point1[i] = polyline.points[i] ;
  for(i=0;i<3;i++) point2[i] = polyline.points[i] + my_x2*vx[i] + my_x1*vx[i];

  pos_orient_flag = TRUE;

  tmp_cst = *cst;

  stat = om$construct (	msg	= message EMSproject.EMplace_surface_of_projection(
									&tmp_cst,
									&line_id,
									 tmp_cst.env_info,
									 NULL,
									 NULL,
									 point1,
									 point2,
									 pos_orient_flag,
									&new_objid ),
			classid = OPP_EMSproject_class_id,
			p_objid = &projsf->objid,
			osnum	= projsf->osnum  );
  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR EMSproject.EMplace_surface_of_projection\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  projsf->objid = new_objid;

  if (extension == 1)
  {
    surf1.obj_id.objid  = projsf->objid;
    surf1.obj_id.osnum  = projsf->osnum;
    surf1.mod_env.md_id = md_env->md_id;
    surf1.mod_env.md_env = md_env->md_env;
    surf1.mod_env.md_id.objid = NULL_OBJID;

    surf2.obj_id = go_hull;
    surf2.mod_env = hull_env;

    stat = SMHullOrient(&surf2, &Rev);

    tmp_cst = *cst;

    stat = SMSplS1ByS2(&tmp_cst, &surf1, &surf2, TRUE, TRUE, Rev, FALSE, &newsf);
    if (!(stat & 1))
    {
      printf("ERROR SMSplS1ByS2\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    projsf->objid = newsf.objid;
    projsf->osnum = newsf.osnum;
  }

wrapup:

  if (line_id.objid != NULL_OBJID)
  {
    tmp_cst = *cst;
    stat = om$send (	msg	 = message GRgraphics.GRdelete(msg,tmp_cst.env_info),
			senderid = NULL_OBJID,
			targetid = line_id.objid,
			targetos = line_id.osnum );
    as$status(sts=stat);
  }

  _FREE(polyline.points);

  return(1);
}


/*4 ====================== SMGetPtsFrSlope =====================

	Function that return the pts of a line string if given
	the depart point and n times [the slope and the length]

	lens is the lenght on len_axis (coord. can be negative).
	All the computations are made in the plane len_axis,z .
	Slope is on z/len_axis
	pts must be allocated of 3*(nb_pts +1) (pts includes depart at position 0)
	return 1 if OK
	else 0.
*/

int	SMGetPtsFrSlope(msg, len_axis, depart, nb_pts, slopes, lens, pts )

 long			*msg;		/* (O) completion code */
 IGRchar		len_axis;	/* (I) length axis */
 IGRdouble		*depart;	/* (I) depart pt */
 IGRint			nb_pts;		/* (I) I = nb of defined slope */
 IGRdouble		*slopes;	/* (I) slope definition */
 IGRdouble		*lens;		/* (I) len along each slope (y)*/
 IGRdouble		*pts;		/* (O) returned pts */

{
  IGRint		i,k;
  IGRdouble		len, previous[3];

  *msg = OM_S_SUCCESS;

  if (depart == NULL || slopes == NULL || lens == NULL || pts == NULL || len_axis == 'z')
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  for(i=0;i<3;i++) pts[i] = depart[i];

  for(i=0;i<3;i++) previous[i] = depart[i];

  switch(len_axis)
  {
    case 'y':
    {
      len = depart[1];
      for(k=1;k<nb_pts +1;k++)
      {
	len = len + lens[k-1] ;
	pts[3*k] = depart[0];
	pts[3*k+1] = len ;
	pts[3*k+2] = previous[2] + slopes[k-1]*lens[k-1];

	for(i=0;i<3;i++) previous[i] =  pts[3*k+i];
      }
      break;
    }
    case 'x':
    {
      len = depart[0];
      for(k=1;k<nb_pts +1;k++)
      {
	len = len + lens[k-1] ;
	pts[3*k] = len;
	pts[3*k+1] = depart[1] ;
	pts[3*k+2] = previous[2] + slopes[k-1]*lens[k-1];

	for(i=0;i<3;i++) previous[i] =  pts[3*k+i];
      }
      break;
    }
  }
  return 1;
}

/*5 ====================== SMGetVectCs =====================

	Function that Get the vect vx, vy vz, if given
	the cs, the x axis, the z axis

	return 1 if OK
	else 0.
*/

int	SMGetVectCs(msg, cs, md_env, x_axis, z_axis, origine, vx, vy, vz, scale)

 long			*msg;		/* (O) completion code */
 struct GRid		*cs;		/* (I) input coord system */
 struct GRmd_env	*md_env;	/* (I) md_env of the cs */
 char			x_axis;		/* (I) axis of projection */
 char			z_axis ;	/* (I) axis of rotation */
 IGRdouble		*origine;	/* (O) origine */
 IGRdouble		*vx;		/* (O) out vx */
 IGRdouble		*vy;		/* (O) out vy */
 IGRdouble		*vz;		/* (O) out vz */
 IGRdouble		*scale;		/* (O) out scale */

{
  IGRint			i,stat;
  struct IGRlbsys	*p_geom;

  *msg = OM_S_SUCCESS;

  if (cs == NULL || md_env == NULL )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  if (x_axis != 'x' && x_axis != 'X' && x_axis != 'y' && x_axis != 'Y' && x_axis != 'z' && x_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  if (z_axis != 'x' && z_axis != 'X' && z_axis != 'y' && z_axis != 'Y' && z_axis != 'z' && z_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  stat = om$send (	msg	 = message GRvg.GRgenabsg(msg,
							&md_env->md_env.matrix_type,
							 md_env->md_env.matrix,
							(char **)&p_geom ),
			senderid = NULL_OBJID,
			targetid = cs->objid,
			targetos = cs->osnum );
  as$status(sts=stat);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR genabsg\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  for(i=0;i<3;i++) origine[i] =  (* p_geom).matrix[4*i+3];

  switch(x_axis)
  {
  case 'x':
  case 'X':
    {
      for(i=0;i<3;i++) vx[i] = (* p_geom).matrix[4*i+0];

      switch(z_axis)
      {
      case 'x':
      case 'X':
	printf("ERROR x_axis and rot axis cannot be the same\n");
	*msg = OM_E_ABORT;
	goto wrapup;
      case 'y':
      case 'Y':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+1];
	  vy[i] = (* p_geom).matrix[4*i+2];
	}
	break;
      case 'z':
      case 'Z':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+2];
	  vy[i] = (* p_geom).matrix[4*i+1];
	}
	break;
      }
      break;
    }
  case 'y':
  case 'Y':
    {
      for(i=0;i<3;i++) vx[i] = (* p_geom).matrix[4*i+1];

      switch(z_axis)
      {
      case 'x':
      case 'X':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+0];
	  vy[i] = (* p_geom).matrix[4*i+2];
	}
	break;
      case 'y':
      case 'Y':
	printf("ERROR x_axis and rot axis cannot be the same\n");
	*msg = OM_E_ABORT;
	goto wrapup;
      case 'z':
      case 'Z':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+2];
	  vy[i] = (* p_geom).matrix[4*i+0];
	}
	break;
      }
      break;
    }
  case 'z':
  case 'Z':
    {
      for(i=0;i<3;i++) vx[i] = (* p_geom).matrix[4*i+2];

      switch(z_axis)
      {
      case 'x':
      case 'X':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+0];
	  vy[i] = (* p_geom).matrix[4*i+1];
	}
	break;

      case 'y':
      case 'Y':
	for(i=0;i<3;i++)
	{
	  vz[i] = (* p_geom).matrix[4*i+1];
	  vy[i] = (* p_geom).matrix[4*i+0];
	}
	break;
      case 'z':
      case 'Z':
	printf("ERROR x_axis and rot axis cannot be the same\n");
	*msg = OM_E_ABORT;
	goto wrapup;
      }
      break;
    }
  }

  if (scale) *scale = (* p_geom).matrix[15];

wrapup:

  return(1);
}

/*7 ====================== SMSetSurfOrient =====================

	Function that set the orientation of the surface.
	The surface will be oriented in the direction given by point
	if reverse = 0.


	return 1 if OK
	else 0.
 */


 int	SMSetSurfOrient(msg, surf, md_env, point, reverse)

 long			*msg;		/* (O) completion code */
 struct GRid		*surf;		/* (I) input surf */
 struct GRmd_env	*md_env;	/* (I) md_env of the surf */
 IGRdouble		point[3];	/* (I) orient of the normal */
 IGRint			reverse;	/* (I) 1 = must reverse */

{
  IGRushort	option;
  IGRshort	orient;
  int		stat;

  *msg = OM_S_SUCCESS;
  option = EMS_GET_POS_ORIENT | EMS_SET_POS_ORIENT;

  stat = om$send (	msg	 = message EMSsurface.EMalgnnrml
							(msg,option,&orient, point, md_env),
			senderid = NULL_OBJID,
			targetid = surf->objid,
			targetos = surf->osnum);
  if (!(stat & *msg & 1))
  {
    printf("ERROR EMSsurface.EMalgnnrml\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  if (reverse)
  {
    stat = om$send (	msg	 = message EMSsubbs.EMset_props(msg,
						      (unsigned char) EMSIS_NRML_REVERSED, (char) EMS_O_TOGGLE),
			senderid = NULL_OBJID,
			targetid = surf->objid,
			targetos = surf->osnum);
    as$status(sts = stat);
    if (!((*msg)&stat&1))
    {
      printf("ERROR in EMSsubbs.EMset_props\n" );
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }

wrapup:
  return OM_S_SUCCESS;
}

/*8 ====================== SMCrtLnStrgSlSheer =====================

	Function that creates a surface of projection based on a
	line string given by slope.

	y is the axis to create the surface of projection

	the line string is construct in the plane x/z.

	slopes are defined as z/x.

	(slopes, lens) must be given from depart point .


		- extension :0=hull range + 10%, 1 =bounded by hull,
				2=user defined

	return 1 if OK
	else 0.
 */

int	SMCrtLnStrgSlSheer(msg, cs, md_env,  z_depart,
			x_depart, nb_pts, slopes, lens,
			extension, ext_x1, ext_x2, ext_y1, ext_y2, cst, projsf )

 long			*msg;		/* (O) completion code */
 struct GRobj_env	*cs;		/* (I) input coord system */
 struct GRmd_env	*md_env;	/* (I) active md_env */
 IGRdouble		z_depart;	/* (I) z depart*/
 IGRdouble		x_depart;	/* (I) x depart */
 IGRint			nb_pts;		/* (I) I = nb of defined slope */
 IGRdouble		*slopes;	/* (I) slope definition (z/x) */
 IGRdouble		*lens;		/* (I) len along each slope (x)*/
 IGRint			extension;	/* (I) how to extend the surface*/
 IGRdouble		ext_x1;		/* (I) extension x negative */
 IGRdouble		ext_x2;		/* (I) extension x positive */
 IGRdouble		ext_y1;		/* (I) extension y negative */
 IGRdouble		ext_y2;		/* (I) extension y positive */
 struct GRvg_construct	*cst;		/* (I) construction list */
 struct GRid		*projsf;	/* (O) constructed projection surface */

{
  IGRint		i,k, stat, Rev;
  IGRdouble		origine[3], vx[3],vy[3],vz[3],
			depart[3], point1[3], point2[3], rate,a, b,
			my_x1, my_x2, my_y1, my_y2, my_z1, my_z2,
			previous[3], endpt[3], extpt[3], y_min,
			y_max, x_min, x_max, scale, trmat[9];
  IGRdouble		range[6];
  IGRboolean		pos_orient_flag;
  struct IGRpolyline	polyline;
  GRobjid		new_objid;
  struct GRvg_construct	tmp_cst;
  struct GRid		act_cs, line_id;
  struct GRmd_env	hull_env;
  struct GRobj_env	surf1, surf2;
  struct GRid		newsf,hull, go_hull;
  BSrc			rc;

  *msg = OM_S_SUCCESS;

  if (cs == NULL || projsf == NULL || md_env == NULL || cst == NULL || slopes == NULL || lens == NULL)
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  polyline.num_points = 0;
  polyline.points = NULL;

  act_cs.osnum = md_env->md_id.osnum;
  cs$get_active_info(msg = msg, objid = &act_cs.objid);

  line_id.objid = NULL_OBJID;
  line_id.osnum = md_env->md_id.osnum;

  projsf->objid = NULL_OBJID;
  projsf->osnum = md_env->md_id.osnum;

  stat = SMGetVectCs(msg, &cs->obj_id, &cs->mod_env, 'x', 'z', origine, vx, vy, vz, &scale);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetVectCs\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* if extension == 0 or 1 extend the curve to the hull range + 10% */

  my_y1 = fabs(ext_y1);
  my_y2 = fabs(ext_y2);
  my_x1 = fabs(ext_x1);
  my_x2 = fabs(ext_x2);

  if (extension !=2)
  {
    /* retrieve the active hull */

    if (!SMGetActHull(&hull,NULL, &hull_env,&go_hull))
    {
      printf("ERROR SMGetActHull\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    rate = 0.1;
    stat = SMExtToRng(&go_hull, &hull_env, NULL, &rate, range);
    if (!(stat&1))
    {
      printf("ERROR SMExtToRng\n ");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    my_x1 = fabs(BSdotp(&rc,&range[0],vx));
    my_x2 = fabs(BSdotp(&rc,&range[3],vx));

    my_y1 = fabs(BSdotp(&rc,&range[0],vy));
    my_y2 = fabs(BSdotp(&rc,&range[3],vy));
    my_z1 = fabs(BSdotp(&rc,&range[0],vz));
    my_z2 = fabs(BSdotp(&rc,&range[3],vz));
  }

  depart[0] = x_depart;
  depart[1] = -my_y1;
  depart[2] = z_depart;

  /* pts are on (vx, vy, vz) */

  polyline.num_points = nb_pts+1;
  polyline.points = _MALLOC(3*(nb_pts+1),IGRdouble);
  if (polyline.points == NULL)
  {
    printf("ERROR, Bad allocation\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  stat = SMGetPtsFrSlope(msg,'x',  depart, nb_pts, slopes, lens, polyline.points);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetPtsFrSlope\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* extend the curve to the range if needed */

  y_min = polyline.points[1];
  x_min = polyline.points[0];

  previous[0] =  polyline.points[3];
  endpt[0]    = polyline.points[0];

  previous[1] = polyline.points[4];
  endpt[1] = polyline.points[1];

  previous[2] = polyline.points[5];
  endpt[2] = polyline.points[2];

  for(i=0;i<3;i++) extpt[i] = polyline.points[i];

  if (x_min > -my_x1)
  {
    if ( fabs(endpt[0] - previous[0]) > EPS)
    {
      a = slopes[0];
      b = previous[2] - a* previous[0];

      extpt[0] = -my_x1;
      extpt[1] = polyline.points[1];
      extpt[2] = -a*my_x1+b;
    }
  }

  for(i=0;i<3;i++)  polyline.points[i] = extpt[i];

  y_max = polyline.points[3*(polyline.num_points-1)+1];
  x_max = polyline.points[3*(polyline.num_points-1)];

  previous[0] = polyline.points[3*(polyline.num_points-1)-3];
  endpt[0] = polyline.points[3*(polyline.num_points-1)];

  previous[1] = polyline.points[3*(polyline.num_points-1)+1-3];
  endpt[1] = polyline.points[3*(polyline.num_points-1)+1];

  previous[2] = polyline.points[3*(polyline.num_points-1)+2-3];
  endpt[2] = polyline.points[3*(polyline.num_points-1)+2];

  for(i=0;i<3;i++) extpt[i] = polyline.points[3*(polyline.num_points-1)+i];

  if (x_max < my_x2)
  {
    if ( fabs(endpt[0]-previous[0]) > EPS)
    {
      a = slopes[nb_pts-1];
      b = previous[2] - a* previous[0];
      extpt[0] = my_x2;
      extpt[1] = polyline.points[3*(polyline.num_points-1)+1];
      extpt[2] = a*my_x2+b;
    }
  }

  for(i=0;i<3;i++)  polyline.points[3*(polyline.num_points-1)+i] = extpt[i];

  /* convert in wrld cs */

  k=0;
  for(i=0;i<9;i=i+3)
  {
    trmat[i] = vx[k];
    trmat[i+1] = vy[k];
    trmat[i+2] = vz[k];
    k++;
  }

  for(i=0;i<3*polyline.num_points; i=i+3)
  {
    MatxVect(trmat, origine, &polyline.points[i], extpt);
    for(k=0;k<3;k++) polyline.points[i+k] = extpt[k];
  }

  /* create the polyline */

  tmp_cst = *cst;
  tmp_cst.geometry = (char *)&polyline;

  stat = om$construct (	msg	= message GRgraphics.GRaltconstruct(&tmp_cst),
			classid = OPP_GR3dlinestr_class_id,
			p_objid = &line_id.objid,
			osnum	= line_id.osnum  );
  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR GRgraphics.GRaltconstruct\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /* create the surface of projection */

  for(i=0;i<3;i++) point1[i] = point2[i] = 0; ;
  point2[1] = my_y1 + my_y2;

  MatxVect(trmat, origine, point1, extpt);
  for(k=0;k<3;k++) point1[k] = extpt[k];

  MatxVect(trmat, origine, point2, extpt);
  for(k=0;k<3;k++) point2[k] = extpt[k];

  pos_orient_flag = TRUE;

  tmp_cst = *cst;

  stat = om$construct (	msg	= message EMSproject.EMplace_surface_of_projection(
									&tmp_cst,
									&line_id,
									 tmp_cst.env_info,
									 NULL,
									 NULL,
									 point1,
									 point2,
									 pos_orient_flag,
									&new_objid ),
			classid = OPP_EMSproject_class_id,
			p_objid = &projsf->objid,
			osnum	= projsf->osnum  );
  as$status(sts=stat);

  if (!(stat & 1))
  {
    printf("ERROR EMSproject.EMplace_surface_of_projection\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  projsf->objid = new_objid;

  if (extension == 1)
  {
    surf1.obj_id.objid  = projsf->objid;
    surf1.obj_id.osnum  = projsf->osnum;
    surf1.mod_env.md_id = md_env->md_id;
    surf1.mod_env.md_env = md_env->md_env;
    surf1.mod_env.md_id.objid = NULL_OBJID;

    surf2.obj_id = go_hull;
    surf2.mod_env = hull_env;

    stat = SMHullOrient(&surf2, &Rev);

    tmp_cst = *cst;

    stat = SMSplS1ByS2(&tmp_cst, &surf1, &surf2, TRUE, TRUE, Rev, FALSE, &newsf);
    if (!(stat & 1))
    {
      printf("ERROR SMSplS1ByS2\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    projsf->objid = newsf.objid;
    projsf->osnum = newsf.osnum;
  }

wrapup:

  if (line_id.objid != NULL_OBJID)
  {
    tmp_cst = *cst;
    stat = om$send (	msg	 = message GRgraphics.GRdelete(msg,tmp_cst.env_info),
			senderid = NULL_OBJID,
			targetid = line_id.objid,
			targetos = line_id.osnum );
    as$status(sts=stat);
  }

  _FREE(polyline.points);

  return(1);
}

/*9 ====================== SMHullOrient =====================

	Function that return the orientation of the given hull

	Rev = 1 if the hull is oriented outward.

	return 1 if OK
	else 0.
 */

int	SMHullOrient(surf, Rev )

struct GRobj_env	*surf;
IGRint			*Rev;

{
  IGRint		i, nb_points, status;
  IGRboolean		world;
  IGRlong		msg;
  GRrange		range;
  IGRdouble		dotp, center[3], points[9], vect[3];
  IGRuint		attempt_no;
  struct EMparms	params[3];
  BSrc			rc;
  unsigned char		props;

  *Rev = 0;
  world = TRUE;
  status = om$send (	msg	 = message GRgraphics.GRgetrang(&msg,
								&surf->mod_env.md_env.matrix_type,
								 surf->mod_env.md_env.matrix,
								&world, range),
			senderid = NULL_OBJID,
			targetid = surf->obj_id.objid,
			targetos = surf->obj_id.osnum);
  as$status();
  if (!(status & msg & 1)) return(0) ;

  for(i=0;i<3;i++) center[i] = (range[i] + range[3+i]) /2;

  attempt_no = 0;
  nb_points = 3;
  status = om$send (	msg	 = message EMSsurface.EMget_point_on_surface(
								&msg,
								&surf->mod_env,
								 attempt_no,
								 nb_points,
								 points,
								 params),
			senderid = NULL_OBJID,
			targetid = surf->obj_id.objid,
			targetos = surf->obj_id.osnum);
  as$status();
  if (!(status & msg & 1)) return(0) ;

  status = om$send (	msg	 = message EMSsubbs.EMget_props(&msg, &props),
			senderid = NULL_OBJID,
			targetid = params[0].leaf_id.objid,
			targetos = params[0].leaf_id.osnum );
  as$status();
  if (!(status & msg & 1)) return(0) ;

  BSmkvec(&rc, vect, &points[0], &center[0]);

  dotp = (IGRdouble) BSdotp(&rc, vect, params[0].normal);

  if ( (dotp < 0 && !(props & EMSIS_NRML_REVERSED)) ||
       (dotp > 0 &&  (props & EMSIS_NRML_REVERSED)) ) *Rev = 1;

  return 1;
}

/*10 ====================== MatxVect =====================

	Function that multiplie the given matrix (3*3)
	by the vector and add the origine.

	Hyp: scale = 1;

	always return 1

 */

int	MatxVect(Mat, origine, in_vect, out_vect )

IGRdouble	*Mat;
IGRdouble	*origine;
IGRdouble	*in_vect;
IGRdouble	*out_vect;

{
  out_vect[0] = Mat[0]*in_vect[0] + Mat[1]*in_vect[1] + Mat[2]*in_vect[2] + origine[0];
  out_vect[1] = Mat[3]*in_vect[0] + Mat[4]*in_vect[1] + Mat[5]*in_vect[2] + origine[1];
  out_vect[2] = Mat[6]*in_vect[0] + Mat[7]*in_vect[1] + Mat[8]*in_vect[2] + origine[2];

  return(1);
}

/* 6 ============================================ SMCrtBulkhead ===========================================
 *
 *	Function that creates a Corrugated Bulkhead
 *
 *	step is defined by:
 *
 *		- depart point
 *		- step height = h
 *
 *		- period (must be larger then either l1 or l2)
 *		- l1 (len of step on which startpoint P is located)
 *		- l2 (len of step on which startpoint P is not located)
 *
 *		- r1 bendradius closest to startpoint P
 *		- r2 alternate bendradius
 *
 *		- extension :	0 = hull range + 10%,
 *				1 = bounded by hull,
 *				2 = user defined
 *
 *	The step begins from the depart point and ends at ext_x1 and ext_x2 on x_axis.
 *
 *	return 1 if OK
 *	else   0.
 *
 * ============================================ SMCrtBulkhead =========================================== */

int	SMCrtBulkhead
(
  long			*msg,		/* (O) completion code				*/
  struct GRobj_env	*cs,		/* (I) input coord system			*/
  struct GRmd_env	*md_env,	/* (I) active md_env				*/
  char			 prj_axis,	/* (I) axis of projection taken as z_axis	*/
  char			 y_axis,	/* (I) y axis					*/
  IGRshort		 version,	/* (I) 0 = old ; 1 = new version for class SMbulkhead	*/
  IGRdouble		 height,	/* (I) step height				*/
  IGRdouble		 len1,		/* (I) step len1				*/
  IGRdouble		 len2,		/* (I) step len2				*/
  IGRdouble		 period,	/* (I) step period				*/
  IGRdouble		*depart,	/* (I) depart point				*/
  IGRint		 extension,	/* (I) how to extend the surface		*/
  IGRint		 reverse,	/* (I) how to orient the normal of the surface	*/
  IGRdouble		 ext_y1,	/* (I) extension y negative			*/
  IGRdouble		 ext_y2,	/* (I) extension y positive			*/
  IGRdouble		 ext_z1,	/* (I) extension z negative			*/
  IGRdouble		 ext_z2,	/* (I) extension z positive			*/
  IGRdouble		 rad1,		/* (I) radius 1					*/
  IGRdouble		 rad2,		/* (I) radius 2					*/
  IGRdouble		*pnt,		/* (I) direction vector				*/
  struct GRvg_construct	*cst,		/* (I) construction list			*/
  struct GRid		*projsf		/* (O) constructed projection surface		*/
)
{
  IGRchar		x_axis;
  BSrc			rc;
  IGRboolean		pos_orient_flag;
  IGRint		i,j,k,l, stat, nb_pos_pts, nb_neg_pts, sgn = -1,
			nb_pos_period, nb_neg_period, Rev;
  IGRlong		nput, nret;
  IGRdouble		a0, basis_tol, z_coord, my_y1, my_y2, my_z1, my_z2, rate, 
			origine[3], vx[3], vy[3], vz[3], range[6], org_pt[3], start_pt[3],
			point1[3], point2[3], def_pt[15], extpt[3], point[3], trmat[16] ;
  IGRdouble		*pts, *sympts;
  GRobjid		new_objid;
  struct GRid		line_id, newsf, hull, go_hull;
  struct GRmd_env	hull_env, my_env;
  struct GRobj_env	surf1, surf2;
  struct GRvg_construct	tmp_cst;
  struct IGRpolyline	polyline;

  *msg = OM_S_SUCCESS;

  if (cs == NULL || md_env == NULL || cst == NULL || projsf == NULL || depart == NULL || pnt == NULL)
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  if ( prj_axis != 'x' && prj_axis != 'X' && prj_axis != 'y' && prj_axis != 'Y' && prj_axis != 'z' && prj_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  if ( y_axis != 'x' && y_axis != 'X' && y_axis != 'y' && y_axis != 'Y' && y_axis != 'z' && y_axis != 'Z' )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  __enterFunction ( name = "SMCrtBulkhead" );

  pts	 = NULL;
  sympts = NULL;
  polyline.num_points	= 0;
  polyline.points	= NULL;

  if      (prj_axis != 'x' && y_axis != 'x' && prj_axis != 'X' && y_axis != 'X')
  {
    x_axis = 'x';
  }
  else if (prj_axis != 'y' && y_axis != 'y' && prj_axis != 'Y' && y_axis != 'Y')
  {
    x_axis = 'y';
  }
  else
  {
    x_axis = 'z';
  }

  line_id.objid = NULL_OBJID;
  line_id.osnum = md_env->md_id.osnum;

  projsf->objid = NULL_OBJID;
  projsf->osnum = md_env->md_id.osnum;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);
  if (!((*msg)&1))
  {
    printf("ERROR gr$get_chord_height_tolerance\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  stat = SMGetVectCs (	msg, &cs->obj_id, &cs->mod_env, x_axis, prj_axis,
			origine, vx, vy, vz, (IGRdouble *)NULL);
  if (!(stat&(*msg)&1))
  {
    printf("ERROR SMGetVectCs\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  k=0;
  for(i=0;i<9;i=i+3)
  {
    trmat[i  ] = vx[k];
    trmat[i+1] = vy[k];
    trmat[i+2] = vz[k];
    k++;
  }

  my_z1 = fabs(ext_z1);
  my_z2 = fabs(ext_z2);
  my_y1 = fabs(ext_y1);
  my_y2 = fabs(ext_y2);

  /* if extension == 0 or 1 extend the curve to the hull range + 10% */

  if (extension != 2)
  {
    /* retrieve the active hull */

    if ( ! SMGetActHull ( &hull, NULL, &hull_env, &go_hull) )
    {
      printf("ERROR SMGetActHull\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    rate =0.1;
    stat = SMExtToRng ( &go_hull, &hull_env, NULL, &rate, range);
    if (!(stat&1))
    {
      printf("ERROR SMExtToRng\n ");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    if ( version )	//HF: range is in world coordinates, so do NOT transform
    {
      my_y1 = BSdotp(&rc,&range[0],vy);
      my_y2 = BSdotp(&rc,&range[3],vy);
      my_z1 = BSdotp(&rc,&range[0],vz);
      my_z2 = BSdotp(&rc,&range[3],vz);
    }
    else		//HF: maintain erroneous processing for the old classes: SMLgCrgtBk & SMTrCrgtBk
    {
      my_y1 = fabs(BSdotp(&rc,&range[0],vy));
      my_y2 = fabs(BSdotp(&rc,&range[3],vy));
      my_z1 = fabs(BSdotp(&rc,&range[0],vz));
      my_z2 = fabs(BSdotp(&rc,&range[3],vz));
    }
  }

  __printf ( "my_y1 = %lg, my_y2 = %lg, my_z1 = %lg, my_z2 = %lg", `my_y1, my_y2, my_z1, my_z2` );

  memcpy ( start_pt, depart , sizeof (IGRpoint) );
  memcpy ( org_pt  , origine, sizeof (IGRpoint) );

  /*
   * HF: Different processing is required for the old classes: SMLgCrgtBk & SMTrCrgtBk
   *     (in order to prevent unexpected behaviour after a recompute !!!!!)
   *	 The new class SMbulkhead requires : version == TRUE
   *	 ===================================================
   */
  if ( version )
  {
    sgn = 1;
    memcpy ( org_pt, depart, sizeof (IGRpoint) );
  }

  /* convert my_z in wrld cs */

  if ( extension == 2 || version == 0 )
  {
    memset ( point   , 0, sizeof (IGRpoint) );
    point[2] = -my_z1;
    MatxVect ( trmat, org_pt, point, extpt);		//HF: origine <<==>> depart

    my_z1 = 0;
    for(i=0 ;i<3 ;i++) my_z1 += extpt[i] * vz[i];	/* coord on vz */

    memset ( point, 0, sizeof (IGRpoint) );
    point[2] = my_z2;
    MatxVect ( trmat, org_pt, point, extpt);		//HF: origine <<==>> depart

    my_z2 = 0;
    for(i=0 ;i<3 ;i++) my_z2 += extpt[i] * vz[i];	/* coord on vz */
  }

  /* depart is already in the active md_env */

  z_coord = 0;
  for(i=0 ;i<3 ;i++) z_coord += depart[i] * vz[i];	/* coord on vz */

  if ( my_y1 > my_y2 )		//HF: swap my_y1 & my_y2
  {
    double yy = my_y2;
    my_y2 = my_y1;
    my_y1 = yy;
  }

  if	  (z_coord < my_z1) my_z1 = z_coord;
  else if (z_coord > my_z2) my_z2 = z_coord;

  __printf ( "my_y1 = %lg, my_y2 = %lg, z_coord = %lg", `my_y1, my_y2, z_coord` );

//  for(i=0;i<3;i++) def_pt[i]    = (my_z1-z_coord) * vz[i] + depart[i];	//HF: causes colinear points
//  for(i=0;i<3;i++) def_pt[i+ 3] = def_pt[i  ] + ( len1 / 2 )	   * vy[i];

  for(i=0;i<3;i++) start_pt[i]  = (my_z1-z_coord) * vz[i] + depart[i];		//HF: translate to proper depth

  for(i=0;i<3;i++) def_pt[i]    = (my_z1-z_coord) * vz[i] + depart[i] - ( len1 / 2 )* vy[i];
  for(i=0;i<3;i++) def_pt[i+ 3] = def_pt[i  ] + ( len1 )	   * vy[i];

  for(i=0;i<3;i++) def_pt[i+ 6] = def_pt[i+3] + ((len2-len1) / 2 ) * vy[i] + height * vx[i] * sgn;	//HF: was - height
  for(i=0;i<3;i++) def_pt[i+ 9] = def_pt[i+6] + ( period-len2 )    * vy[i];
  for(i=0;i<3;i++) def_pt[i+12] = def_pt[i+9] + ((len2-len1) / 2 ) * vy[i] - height * vx[i] * sgn;	//HF: was + height

  nb_pos_period = 0;
  nb_neg_period = 0;

  a0 = 0;
  for(i=0 ;i<3 ;i++) a0 += def_pt[i] * vy[i];		/* coord on vy */

  /* convert my_y in wrld cs */

  if ( extension == 2 || version == 0 )
  {
    memset ( point, 0, sizeof (IGRpoint) );
    point[1] = my_y2;
    MatxVect ( trmat, org_pt, point, extpt);		//HF: origine <<==>> depart

    my_y2 = 0;
    for(i=0 ;i<3 ;i++) my_y2 += extpt[i] * vy[i];	/* coord on vy */
  }
  __printf ( "a0 = %lg, my_y2 = %lg", `a0, my_y2` );

//  if ( a0 < my_y2 ) nb_pos_period = fabs(my_y2 - a0) / period + 1 ;	//HF: see next line
  nb_pos_period = fabs(my_y2 - a0) / period + 1 ;

  if ( ! nb_pos_period ) nb_pos_period = 1;		/* must include the depart point */
  nb_pos_pts = 5 * nb_pos_period;

  if (nb_pos_pts)
  {
    pts = _MALLOC(nb_pos_pts * 3,IGRdouble);
    if (pts == NULL)
    {
      printf("ERROR Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    k=0;
    l=-1;
    for(i=0 ;i<nb_pos_pts ;i++)
    {
      if (i % 5 == 0) {k=0; l++;}

      for(j=0;j<3;j++) pts[3*i + j] = def_pt[3*k + j] + l * period * vy[j];

      a0 = 0;
      for(j=0;j<3;j++) a0 += pts[3*i + j] * vy[j];	/* coord on vy */

  __printf ( "a0 = %lg, my_y2 = %lg", `a0, my_y2` );

      if ( a0 > my_y2 )
      {
	nb_pos_pts = i+1;				/* it is the last pt */
	break;
      }
      k++;
    }
  }

  if ( extension == 2 || version == 0 )
  {
    memset ( point, 0, sizeof (IGRpoint) );
    point[1] = -my_y1;
    MatxVect ( trmat, org_pt, point, extpt);		//HF: origine <<==>> depart

    my_y1 = 0;
    for(i=0 ;i<3 ;i++) my_y1 += extpt[i] * vy[i];	/* coord on vy */
  }
  __printf ( "a0 = %lg, my_y1 = %lg", `a0, my_y1` );

//  if (a0 > my_y1)  nb_neg_period = fabs(a0 - my_y1) / period +1;	//HF: see next line
  nb_neg_period = fabs(a0 - my_y1) / period +1;

  nb_neg_pts = 5 * nb_neg_period;

  if (nb_neg_pts)
  {
    sympts = _MALLOC(nb_neg_pts * 3,IGRdouble);
    if (sympts == NULL)
    {
      printf("ERROR Bad allocation\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    k=0;
    l=0;
    for(i=0;i<nb_neg_pts;i++)
    {
      if (i % 5 == 0) {k=4; l++;}

      for(j=0;j<3;j++) sympts[3*i + j] = def_pt[3*k + j] - l * period * vy[j];

      a0 = 0;
      for(j=0;j<3;j++) a0 += sympts[3*i + j] * vy[j];	/* coord on vy */

  __printf ( "a0 = %lg, my_y1 = %lg", `a0, my_y1` );

      if ( a0 < my_y1 )
      {
	nb_neg_pts = i+1;				/* it is the first pt */
	break;
      }
      k--;
    }
  }

  polyline.num_points = nb_neg_pts + nb_pos_pts;
  polyline.points = _MALLOC(3 * (polyline.num_points),IGRdouble);
  if (polyline.points == NULL)
  {
    printf("ERROR, Bad allocation\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  for(i=0;i<nb_neg_pts;i++)
  {
    for(k=0;k<3;k++)
    {
      polyline.points[3*i + k] = sympts[3 * (nb_neg_pts-i-1) + k] ;
    }
  }

  if (nb_neg_pts) l = i;
  else		  l = 0;

  for(i=0;i<nb_pos_pts;i++)
  {
    for(k=0;k<3;k++)
    {
      polyline.points[3*l + k] = pts[3*i + k] ;
    }
    l++;
  }

  /*
   * HF: Remove coincident vertices from array of points
   */
  l = 0;
  for(i=0; i < 3 * (polyline.num_points - 1); i+=3)
  {
    double	*pt1, *pt2, vec[3], dst = 0.0;

    pt1 = &polyline.points[l  ];
    pt2 = &polyline.points[l+3];

    vec[0] = pt2[0] - pt1[0];
    vec[1] = pt2[1] - pt1[1];
    vec[2] = pt2[2] - pt1[2];

    if ( (dst = BSlenvec (&rc, vec)) < EPS )
    {
      memcpy ( pt1, pt2, sizeof (IGRpoint) * ( polyline.num_points - l/3 - 1) );
    }
    else
    {
      l+=3;
    }
  }
  polyline.num_points = l/3 + 1;

  /* create the polyline */

  if ( rad1 < EPS && rad2 < EPS )
  {
    tmp_cst = *cst;
    tmp_cst.geometry = (char *) &polyline;

    stat = om$construct(	msg	=  message GRgraphics.GRaltconstruct ( &tmp_cst ),
				classid =  OPP_GR3dlinestr_class_id,
				p_objid = &line_id.objid,
				osnum	=  line_id.osnum  );
    as$status(sts=stat);
    if (!(stat & 1))
    {
      printf("ERROR GRgraphics.GRaltconstruct\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }
  else
  {
    stat = VDfillet_and_merge_linestr ( msg, md_env, start_pt, rad1, rad2, cst, &polyline, &line_id );
    as$status(sts=stat);
    if (!(stat & 1 & *msg))
    {
      printf("ERROR VDfillet_and_merge_linestr\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }

  /* create the surface of projection */

  for(i=0;i<3;i++) point1[i] = polyline.points[i] ;
  for(i=0;i<3;i++) point2[i] = polyline.points[i] + my_z2 * vz[i] - my_z1 * vz[i];

  pos_orient_flag = TRUE;

  tmp_cst = *cst;

  stat = om$construct (	msg	= message EMSproject.EMplace_surface_of_projection(
									&tmp_cst,
									&line_id,
									 tmp_cst.env_info,
									 NULL,
									 NULL,
									 point1,
									 point2,
									 pos_orient_flag,
									&new_objid ),
			classid =  OPP_EMSproject_class_id,
			p_objid = &projsf->objid,
			osnum	=  projsf->osnum  );
  as$status(sts=stat);
  if (!(stat & 1))
  {
    printf("ERROR EMSproject.EMplace_surface_of_projection\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }
  projsf->objid = new_objid;

  if (extension == 1)
  {
    surf1.obj_id.objid		= projsf->objid;
    surf1.obj_id.osnum		= projsf->osnum;
    surf1.mod_env.md_id		= md_env->md_id;
    surf1.mod_env.md_env	= md_env->md_env;
    surf1.mod_env.md_id.objid	= NULL_OBJID;

    surf2.obj_id  = go_hull;
    surf2.mod_env = hull_env;

    stat = SMHullOrient ( &surf2, &Rev);

    tmp_cst = *cst;

    stat = SMSplS1ByS2 ( &tmp_cst, &surf1, &surf2, TRUE, TRUE, Rev, FALSE, &newsf );
    if (!(stat & 1))
    {
      printf("ERROR SMSplS1ByS2\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
    projsf->objid = newsf.objid;
    projsf->osnum = newsf.osnum;
  }

  my_env = *md_env;
  my_env.md_id.objid = NULL_OBJID;		/* Computation out of RTREE */

  stat = SMSetSurfOrient ( msg, projsf, &my_env, pnt, reverse );

  if(!(stat & *msg & 1))
  {
    printf("ERROR SMSetSurfOrient\n");
    goto wrapup;
  }

  if ( md_env->md_id.objid != NULL_OBJID )
  {
    /* Add the feet in the rtree */

    stat = om$send (	msg	 = message GRgraphics.GRaddwrng ( msg, md_env ),
			senderid = NULL_OBJID,
			targetid = projsf->objid,
			targetos = projsf->osnum);
    if(!(stat & *msg & 1))
    {
      printf("Failed adding the resulting surface to the rtree\n");
    }
  }

wrapup:

  if (line_id.objid != NULL_OBJID)
  {
    tmp_cst = *cst;
    stat = om$send (	msg	 = message GRgraphics.GRdelete ( msg, tmp_cst.env_info ),
			senderid = NULL_OBJID,
			targetid = line_id.objid,
			targetos = line_id.osnum );
    as$status(sts=stat);
  }

  _FREE(pts);
  _FREE(sympts);
  _FREE(polyline.points);

  __exitFunction ( name = "SMCrtBulkhead" );

  return(1);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDfillet_and_merge_linestr
(
  long			*msg,		/* (O) completion code			*/
  struct GRmd_env	*md_env,	/* (I) active md_env			*/
  IGRdouble		*start_pt,	/* (I) start point (translated to curve)*/
  IGRdouble		 rad1,		/* (I) radius 1				*/
  IGRdouble		 rad2,		/* (I) radius 2				*/
  struct GRvg_construct	*cst,		/* (I) construction list		*/
  struct IGRpolyline	*polyline,	/* (I) linestring to fillet & merge	*/
  struct GRid		*mrgd_curve_id	/* (O) Resulting merged_curve		*/
)
{
  IGRint		i,j,k, sts, num_cvs, nb_line_segs, nb_fillets, indx = -1;

  IGRdouble		u_par;
  IGRboolean		online;

  struct GRvg_construct	tmp_cst;

  struct IGRbsp_curve	**lineseg	= NULL;
  struct IGRbsp_curve	**fillets	= NULL;
  struct IGRbsp_curve	**cvs		= NULL;
  struct IGRbsp_curve	*merged_cv	= NULL;
  BSrc			rc;

  if ( md_env == NULL || cst == NULL || polyline == NULL || mrgd_curve_id == NULL )
  {
    printf("ERROR, Invalid argument\n");
    *msg = OM_E_ABORT;
    return(0);
  }

  __enterFunction ( name = "VDfillet_and_merge_linestr" );

if (0)
{
  __printf ( "polyline->num_points = %d", polyline->num_points );
  for(i=0; i < 3 * polyline->num_points; i+=3)
  {
    __printf ( "polyline->points[%2d] = %lf %lf %lf",
		`i/3, polyline->points[i], polyline->points[i+1], polyline->points[i+2]` );
  }
}
  __printf ( "start_pt = %lf %lf %lf", `start_pt[0], start_pt[1], start_pt[2]` );

  mrgd_curve_id->objid = NULL_OBJID;
  mrgd_curve_id->osnum = md_env->md_id.osnum;

  nb_line_segs	= polyline->num_points - 1;
  nb_fillets	= polyline->num_points - 2;
  num_cvs	= nb_line_segs + nb_fillets;

  /*
   * Allocate arrays of (struct IGRbsp_curve *) pointers for line_segments, fillets and combined total
   */
  lineseg = _MALLOC ( nb_line_segs, struct IGRbsp_curve * );
  fillets = _MALLOC ( nb_fillets  , struct IGRbsp_curve * );
  cvs	  = _MALLOC ( num_cvs     , struct IGRbsp_curve * );

  if (lineseg == NULL || fillets == NULL || cvs == NULL)
  {
    printf("ERROR, Bad allocation\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  /*
   * Allocate each separate IGRbsp_curve for line_segments, and copy the polyline data
   */


  k = 0;
  for(i=0; i < nb_line_segs; i++)
  {
    BSalloccv ( (IGRshort)2, (IGRlong)2, (IGRshort)0, (IGRshort)0, &lineseg[i], &rc);
    if (rc != BSSUCC)
    {
      printf("ERROR BSalloccv\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }

    lineseg[i]->order		= 2;
    lineseg[i]->periodic	= FALSE;
    lineseg[i]->non_uniform	= TRUE;
    lineseg[i]->num_poles	= 2;
    lineseg[i]->num_knots	= 4;
    lineseg[i]->rational	= FALSE;
    lineseg[i]->weights		= NULL;
    lineseg[i]->planar		= FALSE;
    lineseg[i]->phy_closed	= FALSE;
    lineseg[i]->num_boundaries	= 0;
    lineseg[i]->bdrys		= NULL;

    lineseg[i]->knots[0] = lineseg[i]->knots[1] = 0.0;
    lineseg[i]->knots[2] = lineseg[i]->knots[3] = 1.0;

    memcpy ( lineseg[i]->poles, &polyline->points[k], 2 * sizeof (IGRpoint) );
    k += 3;

    /*
     * Determine the index of the linesegment on which the startpoint is located
     */
    u_par = -1.0;
//    start_pt[2] = ( lineseg[i]->poles[2] + lineseg[i]->poles[5] ) / 2;
    BSpt_on_lne( &rc, &lineseg[i]->poles[0], &lineseg[i]->poles[3], start_pt, &u_par, &online );

    if ( rc == BSSUCC && online == TRUE )
    {
      indx = i;
      __printf ( ">>>>> indx = %d, u_par = %lg", `indx, u_par` );
    }

    __printf ( "lineseg[%2d]->poles = %lf %lf %lf\t%lf %lf %lf", `i,
			lineseg[i]->poles[0], lineseg[i]->poles[1], lineseg[i]->poles[2],
			lineseg[i]->poles[3], lineseg[i]->poles[4], lineseg[i]->poles[5]` );
  }

  /*
   * Allocate each separate IGRbsp_curve for fillets
   */

  for(i=0; i < nb_fillets; i++)
  {
    BSalloccv ( (IGRshort)3, (IGRlong)7, (IGRshort)1, (IGRshort)0, &fillets[i], &rc);
    if (rc != BSSUCC)
    {
      printf("ERROR BSalloccv\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
  }

  /*
   * Perform a filleting operation on the line_segments.
   * The function BSfilletatr() will update the struct IGRbsp_curve for the fillets.
   *
   * NOTE: the function header of BSfilletatr() claims to automatically trim the input curves,
   *	   but what it actually does is create a boundary
   *
   * indx    is used to determine which radius (rad1 or rad2) is to be used for starting
   *	     the filleting operation:
   * even =  0  4   8  12  16	==>>	r1  r2  r2  r1  r1
   *	  =  2  6  10  14  18	==>>	r2  r1  r1  r2  r2
   *
   * odd  =  1  5   9  13  17	==>>	r1  r1  r2  r2  r1
   *	  =  3  7  11  15  19	==>>	r2  r2  r1  r1  r2
   */

  if ( indx == -1 ) indx = 3;
  j = indx % 4;

  for(i=0; i < nb_line_segs - 1; i++)
  {
    double	radius;
    IGRpoint	dir_pt, cnt_pt;

    k = i % 4;

    switch ( j )
    {
      case 0 : radius = (k == 0 || k == 3) ? rad1 : rad2; break;
      case 1 : radius = (k == 0 || k == 1) ? rad1 : rad2; break;
      case 2 : radius = (k == 0 || k == 3) ? rad2 : rad1; break;
      case 3 : radius = (k == 0 || k == 1) ? rad2 : rad1; break;
    }

    if ( radius < EPS ) continue;	// Do NOT process for radius = 0

    dir_pt[0] = ( lineseg[i]->poles[0] + lineseg[i]->poles[3] + lineseg[i+1]->poles[0] + lineseg[i+1]->poles[3] ) / 4;
    dir_pt[1] = ( lineseg[i]->poles[1] + lineseg[i]->poles[4] + lineseg[i+1]->poles[1] + lineseg[i+1]->poles[4] ) / 4;
    dir_pt[2] = ( lineseg[i]->poles[2] + lineseg[i]->poles[5] + lineseg[i+1]->poles[2] + lineseg[i+1]->poles[5] ) / 4;

    BSfilletatr ( &rc, lineseg[i], lineseg[i+1], &lineseg[i]->poles[3], &lineseg[i]->poles[3],
		  dir_pt, &radius, fillets[i], cnt_pt );
    if (rc != BSSUCC)
    {
      printf("ERROR BSfilletatr\n");
      *msg = OM_E_ABORT;
      goto wrapup;
    }
//    __printf ( "dir_pt[%2d] = %lf %lf %lf\tcnt_pt = %lf %lf %lf", `i,
//		dir_pt[0], dir_pt[1], dir_pt[2], cnt_pt[0], cnt_pt[1], cnt_pt[2]` );

    __printf ( "fillets[%2d]->poles = %lf %lf %lf\t %lf %lf %lf", `i,
		fillets[i]->poles[0], fillets[i]->poles[1], fillets[i]->poles[2],
		fillets[i]->poles[6], fillets[i]->poles[6], fillets[i]->poles[8]` );
  }

  /*
   * Copy the line_segments and fillets into one array of curves:
   *
   *	skip the fillets which have not been filled out because of radius = 0
   */

  k = 0;
  for(i=0; i < nb_line_segs; i++)
  {
    cvs[k++] = lineseg[i];
    if ( i < nb_fillets && fillets[i]->num_poles == 3 )
    {
      cvs[k++] = fillets[i];
    }
  }
  num_cvs = k;

  /*
   * Because BSfilletatr() does NOT trim the lineseg itself, we have to do it ourselves
   */

  i = 0;
  while ( i < num_cvs - 2 )
  {
    if ( cvs[i+1]->num_poles == 3 )
    {
      memcpy ( &cvs[i  ]->poles[3], &cvs[i+1]->poles[0], sizeof (IGRpoint) );
      memcpy ( &cvs[i+2]->poles[0], &cvs[i+1]->poles[6], sizeof (IGRpoint) );
      i+=2;
    }
    else
    {
      i++;
    }
  }

  /*
   * Now merge all curves together into one
   */

  BSmergarrcv ( num_cvs, cvs, &merged_cv, &rc );
  if (rc != BSSUCC)
  {
    printf("ERROR BSmergarrcv\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

  tmp_cst = *cst;
  tmp_cst.geometry = (char *) merged_cv;

  sts = om$construct (	msg	= message GRgraphics.GRconstruct ( &tmp_cst ),
			classid	= OPP_GRbcsubbc_class_id,
			p_objid	= &mrgd_curve_id->objid,
			osnum	=  mrgd_curve_id->osnum  );
  as$status(sts=sts);
  if ( ! (sts & 1) )
  {
    printf("ERROR GRgraphics.GRconstruct\n");
    *msg = OM_E_ABORT;
    goto wrapup;
  }

wrapup:

  for(i=0; i < nb_line_segs; i++)
  {
    if (lineseg[i])
    {
      (IGRboolean) BSfreecv ( &rc, lineseg[i] );
      lineseg[i] = NULL;
    }
  }

  for(i=0; i < nb_fillets; i++)
  {
    if (fillets[i])
    {
      (IGRboolean) BSfreecv ( &rc, fillets[i] );
      fillets[i] = NULL;
    }
  }
  _FREE(lineseg);
  _FREE(fillets);
  _FREE(cvs);

  if ( merged_cv )
  {
    (IGRboolean) BSfreecv ( &rc, merged_cv );
    merged_cv = NULL;
  }

  __exitFunction ( name = "VDfillet_and_merge_linestr" );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation Root;
