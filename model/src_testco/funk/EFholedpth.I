/*
SM	04/07/92	Moved this function from the
                        file ../imp/ECcounterpti.I to here. See comments
                        in the original file.
			Changed input argument type md_env from GRmdenv_info
			to GRmd_env, because that's what EMget_params
			needs. Incorrect type was being sent to EMget_params
			earlier. Changed function name to EFget_the_hole_depth
			from EMget_hole_depth.
Sudha   07/02/93        Modified for BSprototypes ansification

*/
class implementation ECcounterpt;

%safe
#include <math.h>
%endsafe
#include <stdio.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "emsdef.h"	/* for MAXINT */
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSsfparms.h"
#include "bserr.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "EMScmacros.h"
#include "EMSlogic.h"
#include "maacos.h"
#include "bsdistptpt.h"


# ifndef DEBUG
# define DEBUG 0
# endif

# define FAIL		0

extern OMuword OPP_EMScylindr_class_id;

from GRvg import  GRgetrang;
from EMSsubbs import  EMget_unit_norm, GRptproject;
from EMSsolid import  EMcrvsrfint;
from EMSsurface import EMget_params;

#if DEBUG
#define ERROR1(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
    	printf("\nIn EFget_hole_depth: %s\n", error_message);\
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#else
#define ERROR1(sts, msg, error_message)\
 {\
    if(! (1 & sts & msg))\
    {\
	sts = FAIL; \
	goto ret_end;\
    }\
 }
#endif

/* Tapadia - 01/17/92 Fix for TR 92n0181 */

IGRlong EFget_the_hole_depth(mdenv, axis_normal, hole_radius, part, 
		active_GRid, my_object_id)
struct GRmd_env *mdenv;
IGRboolean axis_normal;
IGRdouble *hole_radius; 
struct part_data *part;
struct GRid *active_GRid;
GRobjid my_object_id;

/*
ABSTRACT:
This function computes the depth of the through NEXT hole when supply the
above information.

VARIABLES:

struct GRmd_env *mdenv Input The environment information of the surface
				that hole located.
IGRboolean axis_normal	Input	axis-normal indicator.
IGRdouble *hole_radius	Input	The hole radius.
struct part_data *part	I/O	The construction part information.
struct GRid *active_GRid Input	The active solid id.
GRobjid my_object_id	Input	for senderid use.

*/
{
  IGRboolean  world, cyl_flag;
  IGRlong  sts, msg_loc, num_slots, num_intersect;
  IGRulong *inter_props;
  IGRdouble  x, y, z, len, knots[4], check_cos, *inter_pts;
  IGRdouble  axis_dir[3], depth, poles[6];
  GRrange  range;
  struct GRparms  *sf_inter_parm, *cv_inter_parm;
  struct IGRbsp_curve  curve;
  extern void  EMsort_by_parameter();
extern IGRdouble tan() ;
  extern IGRboolean EFisAncestryValid();
  IGRushort type;
  struct EMsurface_params parms;
  struct GRmdenv_info *md_env;

# define ERR_TOL	0.00001

  md_env = &mdenv->md_env;
  inter_pts = NULL;
  inter_props = NULL;
  sf_inter_parm = NULL;
  cv_inter_parm = NULL;
  world = TRUE;
  cyl_flag = FALSE;

  sts = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
	&md_env->matrix_type, md_env->matrix, &world, range),
	senderid = my_object_id,
        targetid = active_GRid->objid,
        targetos = active_GRid->osnum);
  ERROR1(sts, msg_loc, "GRgetrang error");

  x = range[3] - range[0];
  y = range[4] - range[1];
  z = range[5] - range[2];
  if(x < y)
  {
     if(y < z)  len = z;
     else  len = y;
  } /* if */
  else
  {
     if(x < z)  len = z;
     else  len = x;
  } /* else */

  /* prevent the curve doesn't intersect with the NEXT surface */

  len *= 1.8; /* I take 1.8 because (1+1+1)**(1/2) == 1.73...  */

  curve.poles = NULL;
  curve.knots = NULL;
  curve.weights = NULL;
  curve.bdrys = NULL;
  curve.poles = poles;
  curve.knots = knots;
  curve.order = curve.num_poles = 2;
  curve.num_knots = 4;
  curve.knots[0] = curve.knots[1] = 0.0;
  curve.knots[2] = curve.knots[3] = 1.0;
  curve.periodic = curve.rational = curve.phy_closed = FALSE;
  curve.non_uniform = curve.planar = TRUE;
  curve.num_boundaries = 0;
  OM_BLOCK_MOVE(part->center, curve.poles, sizeof(IGRpoint));
  curve.poles[3] = part->center[0] + part->axis_dir[0] * len;
  curve.poles[4] = part->center[1] + part->axis_dir[1] * len;
  curve.poles[5] = part->center[2] + part->axis_dir[2] * len;
 
  num_slots = num_intersect = 0;

  sts = om$send(msg = message EMSsolid.EMcrvsrfint(&msg_loc, NULL, 
	md_env, &curve, NULL, NULL, FALSE, 
	&num_slots, &num_intersect, NULL, &sf_inter_parm,
	&cv_inter_parm, &inter_pts, &inter_props), 
	senderid = my_object_id,        
	targetid = active_GRid->objid,
        targetos = active_GRid->osnum);
  ERROR1(sts, msg_loc, "EMSsolid.EMcrvsrfint error");

  EMsort_by_parameter(sf_inter_parm, cv_inter_parm, inter_pts,
	inter_props, num_intersect);


  /* Check if the object is of class EMScylindr */
  if(EFisAncestryValid(&msg_loc, sf_inter_parm[1].leaf_id.objid,
     sf_inter_parm[1].leaf_id.osnum, OPP_EMScylindr_class_id, FALSE))
	cyl_flag = TRUE;

  ERROR1(sts, msg_loc, "EFisAncestryValid error");

  /* get the bottom center point & hole depth */

  OM_BLOCK_MOVE(&inter_pts[3], part->depth_pt, sizeof(IGRpoint));

  part->hole_depth = BSdistptpt(&msg_loc, &inter_pts[3], part->center);

  /* 
   * Use Inner Product to test if top & bottom surfaces' are parallel,
   * or if hole axis is normal to the bottom surface.
   */

  sts = om$send(msg = message EMSsubbs.EMget_unit_norm(&msg_loc, 
	TRUE, NULL, md_env, &inter_pts[3], axis_dir), 
	senderid = my_object_id,
	targetid = sf_inter_parm[1].leaf_id.objid,
	targetos = sf_inter_parm[1].leaf_id.osnum);
  ERROR1(sts, msg_loc, "EMget_unit_norm error");

  check_cos = axis_dir[0] * part->axis_dir[0] + axis_dir[1] * 
	part->axis_dir[1] + axis_dir[2] * part->axis_dir[2];

  if((1-check_cos) > ERR_TOL)	/* if not parallel */
  {
     depth = *hole_radius * tan(MAacos(&msg_loc, &check_cos));
     part->depth_pt[0] += depth * part->axis_dir[0];
     part->depth_pt[1] += depth * part->axis_dir[1];
     part->depth_pt[2] += depth * part->axis_dir[2];
     part->hole_depth += depth;
  }

  if(cyl_flag) {
     /* Get the cylinder radius */
     sts = om$send(msg = message EMSsurface.EMget_params(&msg_loc,
			NULL, mdenv,
			&type, &parms),
	 	senderid = NULL_OBJID,
		targetid = sf_inter_parm[1].leaf_id.objid,
		targetos = sf_inter_parm[1].leaf_id.osnum);

     ERROR1(sts, msg_loc, "EMSsurface.EMget_params error");

     part->depth_pt[0] += fabs(parms.params.cyl.radius) * part->axis_dir[0];
     part->depth_pt[1] += fabs(parms.params.cyl.radius) * part->axis_dir[1];
     part->depth_pt[2] += fabs(parms.params.cyl.radius) * part->axis_dir[2];
     part->hole_depth += (depth + fabs(parms.params.cyl.radius));
  }

ret_end:
  if(sf_inter_parm)  om$dealloc(ptr = sf_inter_parm);
  if(cv_inter_parm)  om$dealloc(ptr = cv_inter_parm);
  if(inter_pts)  om$dealloc(ptr = inter_pts);
  if(inter_props)  om$dealloc(ptr = inter_props);

  if(sts)  return(EMS_S_Success);
  else  return(EMS_E_Success);

} /* EFget_hole_depth */

end implementation ECcounterpt;


