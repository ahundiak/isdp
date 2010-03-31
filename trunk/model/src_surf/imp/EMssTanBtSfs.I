/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMerrordef_include
#include "OMerrordef.h"
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igr_include
#include "igr.h"
#endif

#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
#endif

#ifndef emserr_include
#include "emserr.h"
#endif

#ifndef emsdef_include
#include "emsdef.h"
#endif

#ifndef EMSprop_include
#include "EMSprop.h"
#endif

#ifndef msdef_include
#include "msdef.h"
#endif

#ifndef exdef_include
#include "exdef.h"
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#endif

#ifndef bsgeom_cvsf_include
#include "bsgeom_cvsf.h"
#endif

#define MAXNUM	50
#define MAXNUM2	100
#define MAXNUM3	150

#define DEGREE	57.295779513082322

#if DEBUG
#define EMomerr_exit(sts, msg, errmsg) \
{ \
  if(!(1 & sts & msg)) \
  { \
	printf("\nIn EMget_tan_btn_surfs: %s\n", errmsg); \
	*EMmsg = EMS_E_Success; \
	goto wrapup; \
  } \
}
#else
#define EMomerr_exit(sts, msg, errmsg) \
{ \
  if(!(1 & sts & msg)) \
  { \
	*EMmsg = EMS_E_Success; \
	goto wrapup; \
  } \
}
#endif

#if DEBUG
#define ERROR(msg, errmsg) \
{ \
  if(msg) \
  { \
	printf("\nIn EMget_tan_btn_surfs: %s\n", errmsg); \
	*EMmsg = EMS_E_Success; \
	goto wrapup; \
  } \
}
#else
#define ERROR(msg, errmsg) \
{ \
  if(msg) \
  { \
	*EMmsg = EMS_E_Success; \
	goto wrapup; \
  } \
}
#endif


from EMSedge import EMget_bcxyz_geom, EMget_props;
from EMSboundary import EMgetsurface_info;


method  EMget_tan_btn_surfs(IGRlong *EMmsg; struct GRmdenv_info *md_env;
		struct GRid *surf1; GRobjid *edge1_objid;
		struct IGRbsp_curve *cur;
		IGRint num_pts;
		IGRdouble *len;
		IGRpoint dirpt;
		IGRdouble *polylines;
		IGRdouble *angles)
/*
DISCRIPTION:

This method is used by the CO measuring tangency between two surfaces.  It
receives the surface's objid & osnum, the common edge's objid and geometry data 
between two stitched surfaces, number of points along the common edge needed 
to be measured, the length and direction of the surfaces' normals (for showing
the tangency) and returns the tangency(angles) between two surfaces and the 
polylines of the normals.

VARIABLES:

EMmsg		Output	return status.

md_env		Input	module environment information for the surface.

surf1		Input	one of the stitched surfaces' objid and osnum.

edge1_objid	Input	the common edge's objid in surf1.

cur		Input	the common edge's geometry data; can be NULL.

num_pts		Input	number of points along the common edge.

len		Input	the length of the normals (tangency).

dirpt		Input	the direction of the normals; NULL if natural normal.

polylines	Output	the linestring to be displayed as tangency;
			the caller must malloc the space (9 * IGRdouble
			* num_pts) for it.

angles		Output	the tangency data; the caller must malloc the 
			space (num_pts * IGRdouble) for it.

HISTORY:

06/19/89   BL	Creation date.
07/24/89   BL	Changed the return angles using degree instead of radian.
02/16/90   BL	Changed BSTOLCOLLINVEC to BSTOLSQCOLLINVEC in BSEXTRACTPAR()
		and fixed the potential memory fault problem at free memory
		of curve.
07/12/92  Jack  Added option to send in NULL for polylines.
08/26/92  NP	Modified for ANSI compliance. Changed variable count_obj to IGRuint.
01/07/93  WBC   Replaced the calls to BSprptsonsf with calls to BSprptarrsf.

*/

{
  extern IGRboolean  BSfreecv();
  IGRboolean  all_on_surf;
  IGRushort  edge_prop;
  IGRint  double_size, np_double_size, num_ints;
  IGRlong  stat_OM, msg_loc, buf_size;
  IGRdouble  begin_par, end_par, *pars, pairs[MAXNUM], *tag, before;
  IGRdouble  *cur_pts, points[MAXNUM3], delta;
  IGRdouble  *uvs1, *uvs2, uv_array1[MAXNUM2], uv_array2[MAXNUM2];
  IGRdouble  twice_chrdht_tol;
  GRobjid  edge_objid;
  struct GRid  surf_id, surf2;
  OM_S_CHANSELECT  to_common_edge;
  struct IGRbsp_curve  *curve, cur_space;
  struct IGRbsp_surface  *surf_geom1, *surf_geom2;
  struct BSgeom_bsp_surf geom_surface;
  extern void BScvarrev0(), BSsfarrevnd(), BSprptarrsf(), EFinit_geom_surface();

  /* initialize */
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  cur_pts = pars = uvs1 = uvs2 = NULL;
  curve = NULL;
  surf_geom1 = surf_geom2 = NULL;
  surf2.osnum = surf1->osnum;
  (void)BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, twice_chrdht_tol);
  twice_chrdht_tol *= 2;
  geom_surface.sfgen_cv = NULL;

  stat_OM = om$make_chanselect(channame= "EMSedge.to_common_edge",
	p_chanselect = &to_common_edge);
  EMomerr_exit(stat_OM, 1, "make_chanselect error");

  /* get the adjacent surface object id */
  stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info(
		&msg_loc, &surf2.objid, NULL),
            	senderid = *edge1_objid,
            	p_chanselect = &to_common_edge,
		targetos = surf1->osnum);
  EMomerr_exit(stat_OM, msg_loc, "EMgetsurface_info error");

  stat_OM = om$send(msg = message EMSedge.EMget_props(&msg_loc, 
		&edge_prop),
		targetid = *edge1_objid,
		targetos = surf1->osnum);
  EMomerr_exit(stat_OM, msg_loc, "EMget_props error");

  /* check the edge's property only the dominant edge will be used */

  if(edge_prop & EMED_SUBORDINATE)
  {
     OM_S_OBJECT_LINKAGE  common_edge;
     IGRuint  count_obj;

     stat_OM = om$get_channel_objects(osnum = surf1->osnum,
		objid = *edge1_objid,
		p_chanselect = &to_common_edge,
		list = &common_edge, size = 1,
		count = &count_obj);
     ERROR(!(1 & stat_OM), "get_channel_objects error");
     if(count_obj != 1)
     {
	/* can not get the commom edge */
	*EMmsg = EMS_E_Success;
	goto wrapup;
     } /* if */

     edge_objid = common_edge.S_objid;
     surf_id = surf2;

  } /* if edge1 is subordinate */
  else  
  {
     surf_id = *surf1;
     edge_objid = *edge1_objid;
  }

  if(cur)  curve = cur;
  else
  {
     /* initialize */
     curve = &cur_space;
     curve->poles = NULL;
     curve->knots = NULL;
     curve->weights = NULL;
     curve->bdrys = NULL;

     /* get the common edge's information */
     stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
		md_env, &surf_id, NULL, 
		0, MAXINT, FALSE, NULL, curve),
		targetid = edge_objid,
		targetos = surf1->osnum);
     EMomerr_exit(stat_OM, msg_loc, "EMget_bcxyz_geom");
  }

  double_size = sizeof(IGRdouble);
  np_double_size = num_pts * double_size;

  /* get start and end knots data */
  begin_par = curve->knots[curve->order-1];
  end_par = curve->knots[curve->num_poles];

  if(num_pts > MAXNUM)
  {
     pars = (IGRdouble *) om$malloc(size = np_double_size);
     ERROR(!pars, "malloc(1) error"); 

     cur_pts = (IGRdouble *) om$malloc(size = 3 * np_double_size);
     ERROR(!cur_pts, "malloc(2) error");
  }
  else
  {
     pars = pairs;
     cur_pts = points;
  }

  /* number of intervals */
  num_ints = curve->phy_closed ? num_pts : (num_pts - 1);

  delta = (end_par - begin_par) / num_ints;

  before = pars[0] = begin_par;
  for(tag = pars+1 ; tag < pars + num_ints ; )
  { 
     *tag = before + delta;
     before = *tag++;
  }

  if(!curve->phy_closed)  pars[num_ints] = end_par;

  BScvarrev0(&msg_loc, curve, pars, num_pts, cur_pts);
  ERROR(msg_loc, "BScvarrev0 error");

  if(num_pts > MAXNUM) {  free(pars);  pars = NULL; }

  stat_OM = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc,
		&md_env->matrix_type, md_env->matrix,
		&buf_size),
		targetid = surf1->objid,
		targetos = surf1->osnum);
  EMomerr_exit(stat_OM, msg_loc, "GRgetsize(1) error");

  surf_geom1 = (struct IGRbsp_surface *) om$malloc(size = buf_size);
  ERROR(!surf_geom1, "malloc(3) error"); 

  stat_OM = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc, 
		&md_env->matrix_type, md_env->matrix, &buf_size),
		targetid = surf2.objid,
		targetos = surf2.osnum);
  EMomerr_exit(stat_OM, msg_loc, "GRgetsize(2) error");

  surf_geom2 = (struct IGRbsp_surface *) om$malloc(size = buf_size);
  ERROR(!surf_geom2, "malloc(4) error");

  /* get surface geometry */
  stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc, 
		&md_env->matrix_type, md_env->matrix, (IGRchar *) surf_geom1),
		targetid = surf1->objid,
		targetos = surf1->osnum);
  EMomerr_exit(stat_OM, msg_loc, "GRgetgeom(1) error");

  stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc, 
		&md_env->matrix_type, md_env->matrix, (IGRchar *) surf_geom2),
		targetid = surf2.objid,
		targetos = surf2.osnum);
  EMomerr_exit(stat_OM, msg_loc, "GRgetgeom(2) error");

  if(num_pts > MAXNUM)
  {
     uvs1 = (IGRdouble *) om$malloc(size= 2 * np_double_size);
     uvs2 = (IGRdouble *) om$malloc(size= 2 * np_double_size);
     ERROR((!uvs1 && !uvs2), "malloc(5) error"); 
  } /* if */
  else
  {
     uvs1 = uv_array1;
     uvs2 = uv_array2;
  } /* else */

  /* get uv parameters on the surface */

  EFinit_geom_surface(&msg_loc, surf_geom1, surf1->objid, surf1->osnum,
                      &geom_surface);
  ERROR(!(msg_loc & 1), "EFinit_geom_surface error");

  BSprptarrsf(&geom_surface, twice_chrdht_tol, 0, 0, &num_pts, cur_pts, uvs1,
              NULL, &all_on_surf, NULL, &msg_loc);
  ERROR(msg_loc, "BSprptarrsf error"); 
  if (geom_surface.sfgen_cv)
    {
    BSfreecv(&msg_loc, geom_surface.sfgen_cv);
    geom_surface.sfgen_cv=NULL;
    }

  EFinit_geom_surface(&msg_loc, surf_geom2, surf2.objid, surf2.osnum,
                      &geom_surface);
  ERROR(!(msg_loc & 1), "EFinit_geom_surface error");

  BSprptarrsf(&geom_surface, twice_chrdht_tol, 0, 0, &num_pts, cur_pts, uvs2,
              NULL, &all_on_surf, NULL, &msg_loc);
  ERROR(msg_loc, "BSprptarrsf error"); 
  if (geom_surface.sfgen_cv)
    {
    BSfreecv(&msg_loc, geom_surface.sfgen_cv);
    geom_surface.sfgen_cv=NULL;
    }

  /*
   * Calculate the tangency between two surfaces 
   */

  {
     IGRint  double_3_size, double_6_size, double_9_size;
     IGRdouble	pts[6], lines[9], length, cosv;
     IGRdouble  cross_tol, cross_1_tol, cross_tol_1;
     IGRdouble  *tag_uv1, *tag_uv2, *tag_angle, *tag_poly, *vect1, *vect2;
     IGRvector	va, vb;
     extern IGRdouble  MAacos();

     /* initialize */
     length = 1.0; /* make a unit vector */
     double_3_size = 3 * double_size;
     double_6_size = 6 * double_size;
     double_9_size = 9 * double_size;
     vect1 = va;	vect2 = vb;
     tag_uv1 = uvs1;	tag_uv2 = uvs2;
     tag_angle = angles; tag_poly = polylines;

     stat_OM = BSEXTRACTPAR(&msg_loc, BSTOLSQCOLLINVEC, cross_tol);
     ERROR(!stat_OM, "BSEXTRACTPAR error");

     cross_tol_1 = cross_tol - 1;
     cross_1_tol = 1 - cross_tol;

     for( ; tag_angle < angles + num_pts ; ++tag_angle)
     {
	BSsfarrevnd(surf_geom1, 1, tag_uv1, 1, tag_uv1+1, 
		length, dirpt, pts, &msg_loc);
        ERROR(msg_loc, "BSsfarrevnd(1) error"); 

	/*
	 * The logical normal of surface is being used
	 */

	if(surf_geom1->pos_orient)
	{
	   *vect1 = pts[3] - pts[0];
	   *(vect1+1) = pts[4] - pts[1];
	   *(vect1+2) = pts[5] - pts[2];
	} /* if */
	else
	{
	   *vect1 = pts[0] - pts[3];
	   *(vect1+1) = pts[1] - pts[4];
	   *(vect1+2) = pts[2] - pts[5];
	} /* else */
	pts[3] = pts[0] + *len * *vect1;
	pts[4] = pts[1] + *len * *(vect1+1);
	pts[5] = pts[2] + *len * *(vect1+2);

	OM_BLOCK_MOVE(pts, &lines[3], double_6_size);

	BSsfarrevnd(surf_geom2, 1, tag_uv2, 1, tag_uv2+1, 
		length, dirpt, pts, &msg_loc);
        ERROR(msg_loc, "BSsfarrevnd(2) error"); 

	if(surf_geom2->pos_orient)
	{
	  *vect2  = pts[3] - pts[0];
	  *(vect2+1)  = pts[4] - pts[1];
	  *(vect2+2)  = pts[5] - pts[2];
	} /* if */
	else
	{
	   *vect2 = pts[0] - pts[3];
	   *(vect2+1) = pts[1] - pts[4];
	   *(vect2+2) = pts[2] - pts[5];
	} /* else */
	pts[3] = pts[0] + *len * *vect2;
	pts[4] = pts[1] + *len * *(vect2+1);
	pts[5] = pts[2] + *len * *(vect2+2);

	OM_BLOCK_MOVE(&pts[3], lines, double_3_size);

	/* use dot product to get the angle between two unit normals */
	cosv = (*vect1)*(*vect2) + *(vect1+1)*(*(vect2+1)) + 
		*(vect1+2)*(*(vect2+2));

	if(cosv >= cross_1_tol)  *tag_angle = 0;
	else if(cosv <= cross_tol_1)  *tag_angle = 180;
	else if((cosv >= 0 && cosv <= cross_tol) || 
		(cosv <= 0 && cosv >= cross_tol))  *tag_angle = 90;
	else
	{
	   *tag_angle = MAacos(&msg_loc, &cosv) * DEGREE;
           ERROR(msg_loc != MSSUCC, "MAacos error");
	}

        if(tag_poly)
          OM_BLOCK_MOVE(lines, tag_poly, double_9_size);

	/* increment */
	tag_uv1 += 2;	tag_uv2 += 2;	
        if(tag_poly)
          tag_poly += 9;

     } /* for */
  }

wrapup:
  if(!cur)
  {
    if(curve->poles)  free(curve->poles);
    if(curve->knots)  free(curve->knots);
    if(curve->weights)  free(curve->weights);
    if(curve->bdrys)  free(curve->bdrys);
  }
  if(num_pts > MAXNUM)
  {
     if(pars)  free(pars);
     if(cur_pts)  free(cur_pts);
     if(uvs1)  free(uvs1);
     if(uvs2)  free(uvs2);
  }
  if(surf_geom1)  free(surf_geom1);
  if(surf_geom2)  free(surf_geom2);
  if (geom_surface.sfgen_cv)
    BSfreecv(&msg_loc, geom_surface.sfgen_cv);

  return(stat_OM);

} /* EMget_tan_btn_surfs */

end implementation EMSsubbs;
