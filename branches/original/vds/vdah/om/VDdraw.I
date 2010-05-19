/* $Id: VDdraw.I,v 1.7 2001/08/02 15:31:14 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDdraw.I
 *
 * Description: Simple drawing functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdraw.I,v $
 *      Revision 1.7  2001/08/02 15:31:14  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/07/28 17:30:58  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/22 15:39:29  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/22 15:10:00  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.1  2000/10/16  17:18:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 10/15/00  ah      Add md_env to VDdrawCurve
 * 06/22/01  ah      Just a few error message tweaks while troubleshooting
 ***************************************************************************/
// Some generic routines

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDmem.h"
#include "VDvla.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDgeom.h"
#include "VDdraw.h"
#include "VDbt.h"

#include "VDassert.h"
#include "VDlog.h"

#include "ndmacros.h"
#include "mainvmx.h"
#include "matypemx.h"
#include "bsmult_mats.h"
#include "bsdistptpt.h"

#include "v_miscmacros.h"

extern GRclassid OPP_GRcurve_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_EMSgenbs_class_id;

from GRgencs  import GRgetmatrix;
from EMSplane import EMplane_of_curve;

VDASSERT_FFN("vdah/om/VDdraw.I");

/* ----------------------------------------------------
 * Given some geomotry, make a new object
 * If a_env is NULL, use current enviroment
 */
IGRstat VDdrawCurve(TGRbsp_curve *crv,
		    TGRmd_env    *a_env, 
		    TGRid        *a_newID)
{
  VDASSERT_FN("VDdrawCurve");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  num_poles;
  
  BSrc rc;
  IGRdouble dist;
  
  TGRid           newID;
  TGRvg_construct cst;
  TGRmd_env       env;
  TGRpolyline     poly;
  
  VDclassid classID = 0;

  IGRint planar;
  
  // Arg check
  if (a_newID) a_newID->objid = NULL_OBJID;
  VDASSERTW(crv);

  // This can actuall get reset sometimes?
  planar = crv->planar;
  
  // Init cst stuff
  VDsupInitCnst(&cst);

  // Enviroment
  if (a_env) cst.env_info = a_env;
  else {  
    gr$get_module_env(buffer = &env);
    cst.env_info = &env;
  }
  
  // See if linear
  if ((crv->order == 2) && (crv->rational == 0)) {
    
    // Could be a point
    num_poles = crv->num_poles;
    if (num_poles < 1) goto wrapup;

    if (num_poles == 2) {
      dist = BSdistptpt(&rc,&crv->poles[0],&crv->poles[3]);
      if (dist < .001) num_poles = 1;
    }

    // Geometry
    poly.num_points = num_poles;
    poly.points     = crv->poles;
    cst.geometry = (IGRchar *)&poly;

    switch(num_poles) {
    case 1:  classID = OPP_GR3dpoint_class_id;   break;
    case 2:  classID = OPP_GR3dlineseg_class_id; break;
    default: classID = OPP_GR3dlinestr_class_id; break;
    }
  }
  else {
    cst.geometry = (IGRchar *)crv;
    classID = OPP_GRbcsubbc_class_id;
  }
  
  // Create the object
  newID.osnum = cst.env_info->md_id.osnum;
  newID.objid = NULL_OBJID;
  sts = om$construct(
    classid =  classID,
    osnum   =  newID.osnum,
    p_objid = &newID.objid
  );
  if (!(sts & 1)) goto wrapup;
  if (newID.objid == NULL_OBJID) goto wrapup;

  // Construct the geometry
  if (classID == OPP_GRbcsubbc_class_id) {
    sts = om$send(
      msg  = message GRgraphics.GRconstruct(&cst),
      senderid = NULL_OBJID,
      targetid = newID.objid,
      targetos = newID.osnum);
  }
  else {
    sts = om$send(
      msg  = message GRgraphics.GRaltconstruct(&cst),
      senderid = NULL_OBJID,
      targetid = newID.objid,
      targetos = newID.osnum);
  }
  if (!(sts & 1)) {
    VDlogPrintFmt(VDLOG_ERROR,1,"In %s, Problem constructing graphics",fn);
    vdobj$Delete(objID = &newID);
    // vdgeom$Print(crv = crv);
    goto wrapup;
  }

  // Xfer
  if (a_newID) *a_newID = newID;

  // Display and done
  //vd_$bulk_display(dpmode = GRbd, theEnv = cst.env_info, grids = newID);
  retFlag = 1;

wrapup:
  if (crv) crv->planar = planar;
  
  return retFlag;
}

/* ----------------------------------------------------
 * Given some geomotry, make a new object
 * If a_env is NULL, use current enviroment
 */
IGRstat VDdrawSurface(TGRbsp_surface *srf,
		      TGRmd_env    *a_env, 
		      TGRid        *a_newID)
{
  VDASSERT_FN("VDdrawSurface");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  num_poles;
  
  BSrc rc;
  IGRdouble dist;
  
  TGRid           newID;
  TGRvg_construct cst;
  TGRmd_env       env;
  TGRpolyline     poly;
  
  VDclassid classID = 0;

  IGRint m;
  
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  if (a_newID) a_newID->objid = NULL_OBJID;
  VDASSERTW(srf);

  // Init cst stuff
  VDsupInitCnst(&cst);
  if (traceFlag) {
    
    printf("Number of boundaries %d for %s\n",
	   srf->num_boundaries,fn);
    for(m = 0; m < srf->num_boundaries; m++) {
      printf("Boundary %2d %3d\n",m,srf->bdrys[m].num_points);
    }
  }
  
  // Enviroment
  if (a_env) cst.env_info = a_env;
  else {  
    gr$get_module_env(buffer = &env);
    cst.env_info = &env;
  }
  // Geometry
  cst.geometry = (IGRchar *)srf;

  if (traceFlag) {
    printf("About to construct surface object, osnum %d, boundaries %d\n",
	   cst.env_info->md_id.osnum,
	   srf->num_boundaries);
  }

  // Create the object
  newID.osnum = cst.env_info->md_id.osnum;
  newID.objid = NULL_OBJID;
  sts = om$construct(classid =  OPP_EMSgenbs_class_id,
		     osnum   =  newID.osnum,
		     p_objid = &newID.objid,
		     msg = message GRgraphics.GRconstruct (&cst));

  if (traceFlag) printf("Back from constructing surface object\n");
  
  if (!(sts & 1)) goto wrapup;
  if (newID.objid == NULL_OBJID) goto wrapup;


#if 0
  // Construct the geometry
  sts = om$send(msg  = message GRgraphics.GRconstruct(&cst),
		senderid = NULL_OBJID,
		targetid = newID.objid,
		targetos = newID.osnum);

  if (!(sts & 1)) {
    VDlogPrintFmt(VDLOG_ERROR,1,"In %s, Problem constructing surface graphics",fn);
    vdobj$Delete(objID = &newID);
    // vdgeom$Print(crv = crv);
    goto wrapup;
  }
#endif

  // Xfer
  if (a_newID) *a_newID = newID;
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

/* ----------------------------------------------------
 * Create and display curves
 */
IGRstar VDdrawLinear(IGRint     numPts, 
                     IGRdouble *pts, 
                     TGRmd_env *a_env, 
                     TGRid     *newID)
{
  VDASSERT_FN("VDdrawLinear");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRpolyline poly;
  
  VDclassid classID;

  TGRvg_construct cst;
  TGRmd_env       env;
  
  // Arg check
  if (newID == NULL) goto wrapup;
  newID->objid = NULL_OBJID;
  VDASSERTW(pts);
  
  // Init cst stuff
  VDsupInitCnst(&cst);

  // Make a default enviroment
  if (a_env != NULL) cst.env_info = a_env;
  else {
    gr$get_module_env(buffer = &env);
    cst.env_info = &env;
  }
  
  // Geomotry
  poly.num_points = numPts;
  poly.points     = pts;
  cst.geometry = (IGRchar *)&poly;

  // Determine class
  classID = 0;

  if (numPts == 1) {
    classID = OPP_GR3dpoint_class_id;
  }
  
  if (numPts == 2) {
    classID = OPP_GR3dlineseg_class_id;
  }
  
  if (numPts >  2) {
    classID = OPP_GR3dlinestr_class_id;
  }
  
  if (classID == 0) goto wrapup;
  
  // Create the object
  newID->osnum = cst.env_info->md_id.osnum;
  sts = om$construct(
    classid =  classID,
    osnum   =  newID->osnum,
    p_objid = &newID->objid
  );
  if (!(sts & 1)) goto wrapup;

  // Construct the geometry
  sts = om$send(
    msg  = message GRgraphics.GRaltconstruct(&cst),
    senderid = NULL_OBJID,
    targetid = newID->objid,
    targetos = newID->osnum  
  );
  if (!(sts & 1)) {
    VDlogPrintFmt(VDLOG_ERROR,1,"In %s, Problem constructing graphics",fn);
    newID->objid = NULL_OBJID;
    goto wrapup;
  }

  // Display and done
  //vd_$bulk_display(dpmode = GRbd, theEnv = cst.env_info, grids = newID);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Given an input object, make a copy of its geomotry
 */
IGRstar VDdrawCopyCurve(TGRobj_env *objOE, 
                        TGRmd_env  *env, 
			TGRid      *newID)
{
  IGRstat retFlag = 0;
  
  IGRstat sts;
  
  TGRbsp_curve *bsp = NULL;
  
  // Only good for curves for now
  sts = vdobj$IsAncestryValid(objOE        = objOE, 
                              superClassID = OPP_GRcurve_class_id);
  if (!(sts & 1)) goto wrapup;

  // Get the geometry
  vdgeom$Get(objOE = objOE, bsp = (IGRchar**)&bsp);
  if (bsp == NULL) goto wrapup;
  
  // Copy the geometry
  VDdrawCurve(bsp,env,newID);
  
  // Done
  retFlag = 1;
wrapup:

  _FREE(bsp);
  return retFlag;
}

/* -----------------------------------------------
 * Convert the planar curve to a plane object
 * Not working, oh well, using pla_encomp for now
 */
IGRstat VDdrawPlane(TGRbsp_curve *crv,
		    TGRmd_env    *a_env, 
		    TGRid        *a_newID)
{
  VDASSERT_FN("VDdrawPlane");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid           newID;
  TGRvg_construct cst;
  TGRmd_env       env;

  // Arg check
  if (a_newID) a_newID->objid = NULL_OBJID;
  VDASSERTW(crv);

  // Init cst stuff
  VDsupInitCnst(&cst);

  // Enviroment
  if (a_env) cst.env_info = a_env;
  else {  
    gr$get_module_env(buffer = &env);
    cst.env_info = &env;
  }
  
  // Create the object
  newID.osnum = cst.env_info->md_id.osnum;
  newID.objid = NULL_OBJID;
  sts = om$construct(classid = OPP_EMSplane_class_id,
		     osnum   =  newID.osnum,
		     p_objid = &newID.objid);
  if (newID.objid == NULL_OBJID) goto wrapup;

  // Construct the geometry
  sts = om$send(msg  = message EMSplane.
		  EMplane_of_curve(&msg,&cst,NULL,crv,NULL,0,0,NULL,NULL),
		  senderid = NULL_OBJID,
		  targetid = newID.objid,
		  targetos = newID.osnum);
  if (!(sts & msg & 1)) {
    VDlogPrintFmt(VDLOG_ERROR,1,"In %s, Problem constructing plane from curve",fn);
    vdobj$Delete(objID = &newID);
    // vdgeom$Print(crv = crv);
    goto wrapup;
  }

  // Xfer
  if (a_newID) *a_newID = newID;

  // Display and done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Allows some of the stand alone programs
 * to change their behaviour when isdp is not running
 */
IGRstat VDahIsIsdpRunning()
{
  return 1;
}

/* Try dropping stuff from macro
 */

from GRowner     import GRdrop;
from GRconnector import GRdisconn;

void VDobjDisconnectFromOwner(TGRid *ownerID, TGRid *childID)
{
  IGRstat sts,msg;
  
  sts = om$send(msg  = message GRconnector.GRdisconn(&msg,ownerID),
		senderid = NULL_OBJID,
		targetid = childID->objid,
		targetos = childID->osnum);
  
  return;
}

extern VDclassid OPP_GRgencs_class_id;

#include "grcoordsys.h"
#include "csdef.h"

/* ----------------------------------------------------
 * Given some geomotry, make a new object
 * If a_env is NULL, use current enviroment
 */
IGRstat VDdrawCS(IGRdouble *matrix,
		 TGRmd_env *a_env, 
		 TGRid     *a_newID)
{
  VDASSERT_FN("VDdrawCS");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;
  
  TGRid           newID;
  TGRvg_construct cst;
  TGRmd_env       env;

  struct GRcs_construct cs_args;    /* cs-specific construction args */
  struct IGRlbsys       lbs_geom;   /* local bounded system geometry */
  
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  if (a_newID) a_newID->objid = NULL_OBJID;
  VDASSERTW(matrix);

  // Init cst stuff
  VDsupInitCnst(&cst);
  
  // Enviroment
  if (a_env) cst.env_info = a_env;
  else {  
    gr$get_module_env(buffer = &env);
    cst.env_info = &env;
  }

  // Class args
  memset(&cs_args,0,sizeof(struct GRcs_construct));
  cs_args.type = RECTANGULAR;
  cst.class_attr = (IGRchar *) &cs_args;

  // Geometry
  memset(&lbs_geom,0,sizeof(struct IGRlbsys));
  for(i = 0; i < 16; i++) {
    lbs_geom.matrix[i] = matrix[i];
  }
  cst.geometry = (IGRchar *)&lbs_geom;

  // Create the object
  newID.osnum = cst.env_info->md_id.osnum;
  newID.objid = NULL_OBJID;
  sts = om$construct(classid =  OPP_GRgencs_class_id,
		     osnum   =  newID.osnum,
		     p_objid = &newID.objid,
		     msg = message GRgraphics.GRconstruct (&cst));
  
  if (!(sts & 1)) goto wrapup;
  if (newID.objid == NULL_OBJID) goto wrapup;

  // Xfer
  if (a_newID) *a_newID = newID;
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

end implementation VDbtBase;




