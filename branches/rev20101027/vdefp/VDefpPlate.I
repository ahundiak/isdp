/* ------------------------------------
 * Surface Edge Processing
 * for production work
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"
#include "bssfevaln.h"
#include "bstst_plan.h"

from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;
from ACrg_collect import ACset_list_attribute;

from ci_macro     import init;
from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from ACncpx       import ACmplace;
from GRconnector  import GRrigidconn;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;

static IGRint traceFlag;

// Unwrap surface information (based on mise_a_plat)
typedef struct {
  TGRobj_env      plateOE;
  TGRobj_env      srfOE;
  TGRbsp_surface *srfBsp;

  IGRint    tessOption;   // 0 = iso paramertic, 1 = 4 sides
  IGRint    type;         // Default is 4???

  IGRint    developpable; // 0=not,1=planar,2=other like cone
  IGRdouble fiber_ratio;  // Default is .5
  IGRdouble thickness;    // Use negaative to reverse direction

  // Probably dont need
  IGRint side_of_plate;
  IGRint WantedLinesCode;
  IGRint AllWaterLines;

  IGRint traceFlag;

} TVDefpDevSrfInfo;

/* -----------------------------------
 * Debug trace flag
 */
IGRstat VDefpGetPlateTraceFlag()
{
  IGRstat retFlag = VDdbgGetTraceFlag(44);
  return  retFlag;
}

/* ------------------------------------
 * Init the devlopppable surface info
 */
IGRstat VDefpInitDevSrfInfo(TVDefpDevSrfInfo *devInfo)
{
  if (devInfo == NULL) return 0;
  memset(devInfo,0,sizeof(TVDefpDevSrfInfo));
  return 1;
}

/* ------------------------------------
 * Free any resources used by devInfo
 */
IGRstat VDefpFreeDevSrfInfo(TVDefpDevSrfInfo *devInfo)
{
  if (devInfo == NULL) return 0;
  if (devInfo->srfBsp) {
    // Need to see how to free edges
    free(devInfo->srfBsp);
  }
  return 1;
}

/* -------------------------------------------------------
 * Evaluate developpable surface's points and normals
 * Based on VLgetPtsNorm
 */

#if 0
struct mise_a_plat	*dev; /*I the structure containing everything */

IGRshort		opt;    /*I opt = 0 ---> iso parametric distribution
				    of the tessalation.
				    opt = 1 ---> tessalation using the four
				    sides of a plate. This new approach is
				    mainely used for shell plates
				*/

IGRdouble		MeshTol;/*I approximate length in the case of opt = 1.
				    if The approximate length is <= 0 then
				    the function will evaluate the appropriated
				    length.
				*/
#endif
#if 0
{
	IGRint			i, i3, j;
	IGRlong			retMsg,msg, locRc;
struct	IGRbsp_surface 		*sfPtr;
	IGRdouble		ep;
	IGRint			nbPts;
	IGRdouble		nvec[3];
#endif

IGRstat VDefpGetDevSrfPointsAndNormals(TVDefpDevSrfInfo *devInfo,
                                       IGRint tessOption,
                                       IGRdouble meshTolerance)

{
  IGRstat retFlag = 0;
  IGRstat sts;
  BSrc    rc;

  TGRbsp_surface *srfBsp;

  IGRboolean isPlaner;
  IGRvector  nvec;
  
  // Arg check
  if (devInfo == NULL) goto wrapup;

  // Say hi
  if (devInfo->traceFlag) {
    printf(">>> VDefpGetDevSrfPointsAndNormals, tessOption =  %d\n",
           tessOption);
  }

  // For planer plates, need a copy
  devInfo->developpable = 0;
  srfBsp = devInfo->srfBsp;
  if (srfBsp == NULL) goto wrapup;

  // Really need to replace this with one with a tolerance
  BStst_plan((srfBsp->u_num_poles * srfBsp->v_num_poles),
	      srfBsp->poles,
	      srfBsp->weights,
	     &isPlaner,
	      nvec,
	     &rc);

  if(rc != BSSUCC){
    printf("*** Error while testing for planer in VDefpGetPointsNormal\n");
    vdobj$Print(objOE = &devInfo->plateOE);
    goto wrapup;
  }

  if (isPlaner) {
    if (devInfo->traceFlag) {
      printf("Surface is planer\n");
    }

    devInfo->developpable = 1;

    // msg = VLcreUnfoldSrfStr( dev );

  }

  // Now process based on tess option
  switch(tessOption)
  {

  case 0:
    // sts  = VLtessOpt0(devInfo);
    break;

  case 1:
    // sts = VLtessOpt1(devInfo,meshTolerance);
#if 0
		if( !(msg&1) ){
                        if (msg == GREATER_MAX_EDGE_ALLOWED) {
                          ex$message(msgnumb = VL_E_GreaterEdgeAllow);
                          dev->tesselation_option = PARAMETRIC;
                          msg = VLtessOpt0(dev);
                          if( !(msg&1) ) {
                            printf("Error in VLgetPtsNorms()\n");
                            printf("VLtessOpt0 FAILED\n");
                            goto wrapup;
                          }
                        }
                        else {
			printf("Error in VLgetPtsNorms()\n");
			printf("VLtessOpt1 FAILED\n");
	 		goto wrapup;
                        }
		}
#endif

    break;

    default: goto wrapup;

  }

  /*
   * evaluate the true position of the points depending of the thickness and
   * ratio
   */
#if 0
ep = dev->epaisseur * dev->fib_ratio;

nbPts = 3 * dev->Nb_u * dev->Nb_v;

if( fabs(ep) > 1.0E-6 ) {
 	for (i=0;i<nbPts;i+=3) {
		i3 = i + 3;
		for(j=i;j<i3;j++) dev->P[j] += ep * dev->norm[j];  
	}
}
#endif

  // Done
  retFlag = 1;

wrapup:
  if ((devInfo) && (devInfo->traceFlag)) {
    printf("<<< VDefGetDevSrfPointsAndNormals %d\n",retFlag);
  }
  return retFlag;
}

/* ------------------------------------
 * Starting point for unwrapping surface
 * in VDS
 */
IGRstat VDefpUnwrapPlate(TGRobj_env *plateOE)
{
  IGRstat retFlag = 0;

  TVDefpDevSrfInfo devInfo;
  IGRint tessOption;

  // Arg check
  if ((plateOE == NULL) || (plateOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Say hi
  traceFlag = VDefpGetPlateTraceFlag();
  traceFlag = 1;
  if (traceFlag) {
    printf("---------------------------------------\n");
    printf(">>> VDefpUnwrapPlate\n");
    vdobj$Print(objOE = plateOE);
  }

  // Setup developable stuff
  VDefpInitDevSrfInfo(&devInfo);
  devInfo.traceFlag = traceFlag;
  devInfo.plateOE = *plateOE;

  // Get the surface to work on
  vdobj$GetFoot(objOE    =  plateOE, 
		footName =  VDEFP_PLATE_BASE_SURF_NAME, 
		footOE   = &devInfo.srfOE);
  if (devInfo.srfOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Note: Loft code makes a copy here???

  // Get the surface geomotry with edges
  vdgeom$GetSurface(objOE = &devInfo.srfOE, 
                    getEdges = 1, 
                    srf = &devInfo.srfBsp);
  if (devInfo.srfBsp == NULL) goto wrapup;

  // Setup some options
  devInfo.tessOption  = 1;  // Want this for shell plates???
  tessOption          = 1;  // Check if it changes

  devInfo.type         = 4;  // Not sure
  devInfo.developpable = 0;
  devInfo.fiber_ratio  = .5;

  // Might need to mess with orientation to change direction???
  vdsa$GetStruct(objOE = plateOE, 
                 name  = "thickness", 
                 dbl   = &devInfo.thickness);

  // Ready to rock
  VDefpGetDevSrfPointsAndNormals(&devInfo,tessOption,0.0);

  // Done
  retFlag = 1;

wrapup:
  VDefpFreeDevSrfInfo(&devInfo);
  if (traceFlag) printf("<<< VDefpUnwrapPlate %d\n",retFlag);
  return retFlag;
}

end implementation Root;
