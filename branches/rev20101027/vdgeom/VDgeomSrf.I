/* $Id: VDgeomSrf.I,v 1.1 2001/01/11 18:41:19 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomSrf.I
 *
 * Description: Surface Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomSrf.I,v $
 *      Revision 1.1  2001/01/11 18:41:19  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  17:06:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/07/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"

#include "v_measmacros.h"

#include "VDassert.h"

VDASSERT_FFN("vdgeom/VDgeomSrf.I");

from GRvg import GRdetplane;

/* -----------------------------------------------
 * Get planar information about a surface
 * Use this routine since sometimes surfaces
 * which are almost planar get reported as non-planar
 */
IGRstat VDgeomGetSurfacePlanarProps(TGRobj_env *srfOE,
				    IGRdouble   tol,
				    IGRint     *isPlanar,
				    IGRpoint    pt,
				    IGRvector   nrm)
{
  VDASSERT_FN("VDgeomGetSurfacePlanarProps");
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRplane  plane;
  IGRpoint  planePt;
  IGRvector planeNrm;
  
  // Arg check
  if (isPlanar) *isPlanar = 0;
  if (srfOE == NULL) goto wrapup;
  
  // Setup
  if (pt) plane.point = pt;
  else    plane.point = planePt;
  
  if (nrm) plane.normal = nrm;
  else     plane.normal = planeNrm;
  
  // Do it
  sts = om$send(msg = message GRvg.
		GRdetplane(&msg,
			   &srfOE->mod_env.md_env.matrix_type,
			    srfOE->mod_env.md_env.matrix,
			   &plane),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);
  
  if (sts & msg & 1) {
    if (isPlanar) *isPlanar = 1;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Getting area is harder than is may seem,
 * Use this as a wrapper to the vds routines
 * Might need to tweak later
 */
IGRstat VDgeomGetSurfaceAreaProps(TGRobj_env *srfOE,
				  IGRdouble  *area,
				  IGRpoint    centroid,
				  IGRdouble   moment[6])
{
  VDASSERT_FN("VDgeomGetSurfaceAreaProps");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  // Arg check
  if (area) *area = 0.0;
  if (srfOE == NULL) goto wrapup;
  
  // Wrap it
  sts = vd_$get_area_props(msg      = &msg,
			   surfId   = &srfOE->obj_id,
			   surfEnv  = &srfOE->mod_env,
			   area	    = area,
			   centroid = centroid,
			   moment   = moment);
  
  if (!(sts & msg & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;

