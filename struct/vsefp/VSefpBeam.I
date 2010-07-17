/* ------------------------------------
 * Surface Edge Processing
 * for production work
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDsa.h"
#include "VDvla2.h"
#include "VDmac.h"

#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"
#include "VSefp.h"

#include "VDchn.h"

#include "VDdbgProto.h"

#include "vsdpb.h"
#include "vsattr.h"
#include "vsbeam.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsbeamproto.h"
#include "vsoptdef.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"

#include "bssfevaln.h"
#include "bsdistptpt.h"
#include "bsinv_mat.h"

#include "matypemx.h"
#include "maoptsxfo.h"
#include "maunitvc.h"

#include "VDct1.h"

from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;
from ACrg_collect import ACset_list_attribute;
from GRgencs      import GRgetmatrix;

from ci_macro     import init;

from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRvg         import GRgetattr;

from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from ACncpx       import ACmplace;
from GRconnector  import GRrigidconn;
from GRcurve      import GRendpts;

from VSbeam import VSgetSupportSf;
from VSbeam import VSgetSupportAxis;
from VSbeam import VSgetCrossSectionCS;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;

extern VDclassid OPP_VSbeam_class_id;
extern VDclassid OPP_VSbeamAxis_class_id;
extern VDclassid OPP_VSsrcBeam_class_id;
extern VDclassid OPP_VStwsBeam_class_id;
extern VDclassid OPP_VSsubBeam_class_id;
extern VDclassid OPP_VSsplBeam_class_id;
extern VDclassid OPP_VSbooBeam_class_id;

static IGRint traceFlag;

extern void VSefpMxPt( IGRmatrix mat, IGRpoint pt1, IGRpoint pt2);


/* ------------------------------------
 * Initialized beamInfo structure
 * Call at the beginning of a function
 * with a new beamInfo
 */
IGRstat VSefpInitBeamInfo(TVSefpBeamInfo *beamInfo)
{
  IGRstat retFlag = 0;
  
  if (beamInfo == NULL) goto wrapup;
  memset(beamInfo,0,sizeof(TVSefpBeamInfo));
  strcpy(beamInfo->desc,"NO BEAM");
  vdvlaoe$Init(vla = &beamInfo->macVLA);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------
 * Frees up anyting allocatted in a beamInfo
 * Call only after Init is called
 * Should be safe at other times
 */
IGRstat VSefpFreeBeamInfo(TVSefpBeamInfo *beamInfo)
{
  IGRstat retFlag = 0;
  
  if (beamInfo == NULL) goto wrapup;

  vdvlaoe$Free(vla = &beamInfo->macVLA);
  if (beamInfo->srfBsp)  free(beamInfo->srfBsp);
  if (beamInfo->axisBsp) free(beamInfo->axisBsp);

  memset(beamInfo,0,sizeof(TVSefpBeamInfo));
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------------------------
 * Wrapper to translate a 3d model point to a 2d spades extraction point
 * For linear beams, it's a simple transform
 * for curved beams, need to use the distortion code
 */
IGRstat VSefpTranslateBeam3D2D(TVSefpBeamInfo *beamInfo, IGRpoint pt3D, IGRpoint pt2D)
{
  VSefpMxPt(beamInfo->inv,pt3D,pt2D);
  return 1;
}

/* -----------------------------------------------
 * Add end treatment info 
 */
IGRstat VSefpAddBeamEtInfo(TVSefpBeamInfo *beamInfo, TGRobj_env *macOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  BSrc    rc;
  
  TVSefpEtInfo etInfo;
  
  IGRdouble dist0,dist1;
  
  // Make sure it is an ET
  sts = VSefpGetEtInfo(&beamInfo->beamOE, macOE, &etInfo);
  if (!(sts & 1)) goto wrapup;
  etInfo.gotIt = 1;
  
  // Which end is closer
  dist0 = BSdistptpt(&rc,etInfo.csOrg,beamInfo->matInfo.O0);
  dist1 = BSdistptpt(&rc,etInfo.csOrg,beamInfo->matInfo.O1);

  if (dist0 < dist1) {
    
    // Already have one?
    if (beamInfo->etInfo0.gotIt == 1) {
      printf("Have two end treatments for the same end for \n");
      vdobj$Print(objOE = &beamInfo->beamOE);
      vdobj$Print(objOE = macOE);
      goto wrapup;
    }
    beamInfo->etInfo0 = etInfo;
  }
  else {

    // Already have one?
    if (beamInfo->etInfo1.gotIt == 1) {
      printf("Have two end treatments for the same end for \n");
      vdobj$Print(objOE = &beamInfo->beamOE);
      vdobj$Print(objOE = macOE);
      goto wrapup;
    }
    beamInfo->etInfo1 = etInfo;
  }
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------
 * Fills in beam information
 * Serves as a beam verification as well
 *
 * This routines gets geometry associated with the beam
 * The calling routine must free
 * If noGeom == 1 then geometry is not obtained
 *
 * beamInfo must already have been initted
 */
IGRstat VSefpGetBeamInfo(TGRobj_env *beamOE, IGRint noGeom, TVSefpBeamInfo *beamInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRchar buf[128];
  IGRchar beamName [128];
  IGRchar beamClass[128];
  IGRchar beamPcmk[128];
  
  IGRint     macCnt;
  IGRint     macI;
  TGRobj_env macOE;
  
  IGRint i;
  
  IGRdouble height,width,swap,distance;
  IGRmatrix mat;
  IGRpoint  pt;
  
  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_VERIFY_PIECE);
  *buf = 0;
  
  // Arg Check
  if (beamInfo == NULL) goto wrapup;
  if (beamOE   == NULL) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf("-----------------------------------------\n");
    printf(">>> VSefpGetBeamInfo\n");
    vdobj$Print(objOE = beamOE);
  }
  beamInfo->beamOE = *beamOE;

  // Say hi
  vdobj$Get(objOE = beamOE, objName   = beamName);
  vdobj$Get(objOE = beamOE, className = beamClass);

  vdsa$GetStruct(objOE = beamOE, name = "SA_AST:StagingTree:0:pcmk", txt = beamPcmk);
  
  sprintf(beamInfo->desc,"%2d %6d %-10s %4s %-20s",
	  beamOE->obj_id.osnum,
	  beamOE->obj_id.objid,
	  beamClass,
	  beamPcmk,
	  beamName);
  
  // Arg check
  sts = vdobj$IsAncestryValid(objOE = beamOE,
			      superClassID = OPP_VSbeam_class_id);
  if (!(sts & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get support surface
  sts = om$send(msg = message VSbeam.
		VSgetSupportSf(&msg,&beamOE->mod_env,&beamInfo->srfOE),
		senderid = NULL_OBJID,
		targetid = beamOE->obj_id.objid,
		targetos = beamOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    strcpy(buf,"Problem getting support surface");
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objOE = &beamInfo->srfOE);

  // Get beam axis
  sts = om$send(msg = message VSbeam.
		VSgetSupportAxis(&msg,&beamOE->mod_env,&beamInfo->axisOE),
		senderid = NULL_OBJID,
		targetid = beamOE->obj_id.objid,
		targetos = beamOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    strcpy(buf,"Problem getting support axis");
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objOE = &beamInfo->axisOE);

  // Get axis geomotry
  vdgeom$Get2(objOE = &beamInfo->axisOE,  
	      crv   = &beamInfo->axisBsp);

  if (beamInfo->axisBsp == NULL) {
    strcpy(buf,"Problem getting curve geomotry");
    goto wrapup;
  } 
  
  // Get surface geomotry
  vdgeom$Get2(objOE = &beamInfo->srfOE,  
	      srf   = &beamInfo->srfBsp);

  if (beamInfo->srfBsp == NULL) {
    strcpy(buf,"Problem getting surface geomotry");
    goto wrapup;
  }

  // Get the matrix for the production base end
  VSefpGetBeamBaseEnd(beamOE,&beamInfo->matInfo);
  
  // Default the origin of the two et's to the beam ends
  for(i = 0; i < 3; i++) {
    beamInfo->etInfo0.csOrg[i] = beamInfo->matInfo.O0[i];
    beamInfo->etInfo1.csOrg[i] = beamInfo->matInfo.O1[i];
  }

  // Find any processed macros
  VSefpGetProcessedMacros(beamOE,&beamInfo->macVLA);
  
  // Extract any end treatments
  vdvlaoe$GetCnt(vla = &beamInfo->macVLA, cnt = &macCnt);
  for(macI = 0; macI < macCnt; macI++) {

    // Get a possible et
    vdvlaoe$GetNth(vla = &beamInfo->macVLA, nth = macI, data = &macOE);

    // Add to the beam info
    VSefpAddBeamEtInfo(beamInfo,&macOE);
    
  }
  
  // Little report
  if (traceFlag) {
    if (beamInfo->etInfo0.gotIt == 0) printf("No End Treatment 0\n");
    else vdobj$Print(objOE = &beamInfo->etInfo0.etOE);

    if (beamInfo->etInfo1.gotIt == 0) printf("No End Treatment 1\n");
    else vdobj$Print(objOE = &beamInfo->etInfo1.etOE);
  }

  // Fill in 5 control points
  vdsa$GetStruct(objOE = beamOE, name = "x_Height",        dbl = &height);
  vdsa$GetStruct(objOE = beamOE, name = "x_Web_Thickness", dbl = &width);

  for(i = 0; i < 3; i++) {
    beamInfo->pt1[i] = beamInfo->etInfo0.csOrg[i];
    beamInfo->pt2[i] = beamInfo->etInfo1.csOrg[i];
    beamInfo->pt5[i] = beamInfo->etInfo1.csOrg[i];

    beamInfo->pt3[i] = beamInfo->etInfo0.csOrg[i] + (beamInfo->matInfo.Y[i] * height);
    beamInfo->pt4[i] = beamInfo->etInfo0.csOrg[i] + (beamInfo->matInfo.X[i] * width);
  }
  
  // Project pt4 onto the plate surface

  /* ---------------------------------------------------------
   * Now create an inverse matrix for transforming points from
   * 3d space to 2d space with the first end treatment being 0,0
   */
  for(i = 0; i < 16; i++) mat[i]       = beamInfo->matInfo.mat[i];
  for(i = 0; i < 3;  i++) {

    // Origin comes from the et
    mat[(i*4)+3] = beamInfo->etInfo0.csOrg[i];

    // Swap and invert X and Z vectors
    swap = mat[(i*4)+2];
    mat[(i*4)+2] = -1.0 * mat[(i*4)+0];
    mat[(i*4)+0] =  1.0 * swap;
    
  }
  
  BSinv_mat(4, mat, beamInfo->inv, &rc);
  
  // Test
  // VSefpMxPt(beamInfo->inv,beamInfo->pt1,pt);
  // VSefpMxPt(beamInfo->inv,beamInfo->pt2,pt);
  // VSefpMxPt(beamInfo->inv,beamInfo->pt3,pt);
  // VSefpMxPt(beamInfo->inv,beamInfo->pt4,pt);
  

  // Check for closed beam, usually have a 1 mm gap betweend end points
  distance = BSdistptpt(&rc,beamInfo->pt1,beamInfo->pt2);
  if (distance < 2) {
    beamInfo->isClosed = 1;
    if (traceFlag) printf("Beam is closed\n");
  }
  
  // Check for linear beam
  sts = VDgeomIsCrvLinear(beamInfo->axisBsp,.1);
  if (!(sts & 1)) beamInfo->isNotLinear = 1;
    
  if ((beamInfo->isNotLinear == 1) && (beamInfo->isClosed == 0) ) {
    if (traceFlag) printf("Axis not linear\n");
#if 1
    printf("----------------------------\n");
    printf("Axis is not linear for \n");
    vdobj$Print(objOE =  beamOE);
    vdobj$Print(objOE = &beamInfo->axisOE);
    printf("-----\n");
#endif
  }
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    if (*buf) printf("*** %s\n",buf);
    printf("<<< VSefpGetBeamInfo %d\n",retFlag);
  }
  else {
    if (*buf) {
      printf("----- Problem in Getting Beam Information -----\n");
      vdobj$Print(objOE = beamOE);
      printf("*** %s\n",buf);
      printf("-----\n");
    }
  }
  return retFlag;
}

/* ------------------------------------
 * Compute function for the efp_beam
 */
IGRstat VSefpComputeEfpBeam(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *feetCnt,
			    TGRid      *feetIDs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;

  TGRobj_env beamOE;
  
  IGRchar    macObjName[128];
  IGRchar    macObjDesc[128];
  IGRchar    buf[128];

  IGRint     i;

  IGRdouble  ptx[15];

  TVSefpBeamInfo beamInfo;

  TGRid baseID;
  OM_S_CHANSELECT *to_owner     = NULL;
  OM_S_CHANSELECT *to_component = NULL;
  
  // Init
  VSefpInitBeamInfo(&beamInfo);
  
  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_COMPUTE_EFP_BEAM);
  strcpy(macObjDesc,"Unknown");

  if (traceFlag) {
    printf(">>> VSefpComputeEfpBeam\n");
    vdobj$Print(objOE = macOE);
  }
  vdobj$Get(objOE = macOE, objName = macObjName);
  sprintf(macObjDesc,"%d,%d %s",
          macOE->obj_id.osnum,
          macOE->obj_id.objid,
          macObjName);

  sprintf(buf,"Processing %s",macObjDesc);
  UI_status(buf);

  // Arg check
  if ((feetCnt == NULL) || (feetIDs == NULL)) goto wrapup;
  *feetCnt = 0;
  if (opFlag);
  
  // Get the beam
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_EFP_BEAM_PARENT_BEAM,
                    templateOE = &beamOE);

  if (beamOE.obj_id.objid == NULL_OBJID) goto wrapup;

  sts = vdobj$IsAncestryValid(objOE          = &beamOE, 
                              superClassName = "VSbeam");
  if (!(sts & 1)) goto wrapup;
  
  if (traceFlag) vdobj$Print(objOE = &beamOE);

  // Get the five key points
  sts = VSefpGetBeamInfo(&beamOE,0,&beamInfo);
  if (!(sts & 1)) {
    printf("Problem getting beam information\n");
    goto wrapup;
  }
#if 0
  sts = VSefpGetBeam3dPoints(&beamInfo);
  if (!(sts & 1)) {
    printf("Problem getting beam 3d points\n");
    goto wrapup;
  }
#endif

  // Make the 5 point feet
  VDdrawLinear(1,beamInfo.pt1,&macOE->mod_env,&feetIDs[0]);
  VDdrawLinear(1,beamInfo.pt2,&macOE->mod_env,&feetIDs[1]);
  VDdrawLinear(1,beamInfo.pt3,&macOE->mod_env,&feetIDs[2]);
  VDdrawLinear(1,beamInfo.pt4,&macOE->mod_env,&feetIDs[3]);
  VDdrawLinear(1,beamInfo.pt5,&macOE->mod_env,&feetIDs[4]);

  // Draw sort of an outline
  for(i = 0; i < 3; i++) {
    ptx[ 0+i] = beamInfo.pt1[i];
    ptx[ 3+i] = beamInfo.pt3[i];
    ptx[ 6+i] = beamInfo.pt4[i];
    ptx[ 9+i] = beamInfo.pt1[i];
    ptx[12+i] = beamInfo.pt2[i];
  }
  //VDdrawLinear(5,ptx,&macOE->mod_env,&feetIDs[5]);

  // Just for grins, try hooking one of the feet via base object
  vdct1$CreateBaseObject(classType = 66, osnum = feetIDs[0].osnum, objID = &baseID);
  if (baseID.objid == NULL_OBJID) {
    printf("Problem creating base object\n");
    goto wrapup;
  }
  vdchn$Get(ic_IDX = VDCHN_IDX_NOTIFICATION,  oc_SEL = &to_owner);
  vdchn$Get(ic_IDX = VDCHN_IDX_CT1_TO_NOTIFY, oc_SEL = &to_component);
  
  // Connect up
  sts = om$send(msg = message 
		Root.connect(*to_component,    OM_K_MAXINT,
			      feetIDs[0].objid, 
			      feetIDs[0].osnum,
			     *to_owner,OM_K_MAXINT),
		senderid = NULL_OBJID,
		targetid = baseID.objid,
		targetos = baseID.osnum
  );
  if (!(sts & 1)) {
    printf("Trouble connecting to base owner\n");
    goto wrapup;
  }
  printf("--- New Foot ---\n");
  vdobj$Print(objID = &baseID);
  vdobj$Print(objID = &feetIDs[0]);
  
  feetIDs[0] = baseID;
  
  // Done
  *feetCnt = 5;
  retFlag  = 1;

wrapup:
  VSefpFreeBeamInfo(&beamInfo);
  
  sprintf(buf,"Processed %s",macObjDesc);
  UI_status(buf);

  if (traceFlag) {
    printf("<<< VSefpComputeEfpBeam\n");
  }

  return retFlag;
}

end implementation Root;



