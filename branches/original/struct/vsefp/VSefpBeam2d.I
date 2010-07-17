/* ---------------------------------------------
 * Extract a beam for production with 2d results
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
#include "bstrans1.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "maunitvc.h"

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

/* ------------------------------------
 * Extracts Cut Out Information
 */
IGRstat VSefpGetCutoutInfo(TGRobj_env       *piece1OE, 
			   TGRobj_env       *cutoutOE, 
			   TVSefpCutoutInfo *cutoutInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRchar buf[128];
  TGRid      etID;
  
  // Init Trace
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_VERIFY_PIECE);
  if (traceFlag) {
    printf(">>> VSefpGetCutoutInfo\n");
  }
  *buf = 0;
  
  // Arg check
  if (cutoutInfo == NULL) goto wrapup;
  memset(cutoutInfo,0,sizeof(TVSefpCutoutInfo));
  if (piece1OE == NULL) goto wrapup;
  if (cutoutOE == NULL) goto wrapup;

  // Having an et_type means not a cutout
  vdmac$Get(objOE = cutoutOE, footName = "et_type", footID = &etID);
  if (etID.objid != NULL_OBJID) goto wrapup;

  // Xfer some stuff
  cutoutInfo->piece1OE = *piece1OE;
  cutoutInfo->cutoutOE = *cutoutOE;

  if (traceFlag) {
    vdobj$Print(objOE = cutoutOE);
  }
  
  // Store the macro information
  vdmac$Get(objOE = cutoutOE, defName = cutoutInfo->macType);
  vdobj$Get(objOE = cutoutOE, objName = cutoutInfo->macName);

  // Need a cut curve
  vdmac$Get(objOE = cutoutOE, footName = "cut", footID = &cutoutInfo->cutID);
  if (cutoutInfo->cutID.objid == NULL_OBJID) {
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objID = &cutoutInfo->cutID);

  // Should have a marking line 
  vdmac$Get(objOE = cutoutOE, footName = "mark", footID = &cutoutInfo->markID);
  if (traceFlag) vdobj$Print(objID = &cutoutInfo->markID);

  // Get it's cs
  vdmac$Get(objOE = cutoutOE, footName = "cs", footID = &cutoutInfo->csID);
  if (cutoutInfo->csID.objid == NULL_OBJID) {
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objID = &cutoutInfo->csID);
    
  // Get the cs matrix 
  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,cutoutInfo->csMatrix.matrix),
		senderid = NULL_OBJID,
		targetid = cutoutInfo->csID.objid,
		targetos = cutoutInfo->csID.osnum);
  if (!(sts & 1)) {
    strcpy(buf,"Problem getting cs matrix");
    goto wrapup;
  }
  MAtypemx(&rc,cutoutInfo->csMatrix.matrix,&cutoutInfo->csMatrix.matrix_type);
    
  // Stash origin
  cutoutInfo->csOrg[0] = cutoutInfo->csMatrix.matrix[ 3];
  cutoutInfo->csOrg[1] = cutoutInfo->csMatrix.matrix[ 7];
  cutoutInfo->csOrg[2] = cutoutInfo->csMatrix.matrix[11];
  
  // Grab the id
  vdmac$Get(objOE = cutoutOE, footName = "id", footID = &cutoutInfo->idID);
  if (cutoutInfo->idID.objid == NULL_OBJID) {

    // Try again
    vdmac$Get(objOE = cutoutOE, footName = "ID", footID = &cutoutInfo->idID);
  }
  if (cutoutInfo->idID.objid == NULL_OBJID) { // Fail silently, not cutout macro
    goto wrapup;
  }
  vdsa$Get(objID = &cutoutInfo->idID, name = "id", txt = cutoutInfo->idType);

  if (traceFlag) {
    vdobj$Print(objID = &cutoutInfo->idID);
    printf("idType '%s'\n",cutoutInfo->idType);
  }

  // Second parent is the intersecting element
  vdobj$GetTemplate(objOE = cutoutOE,
		    nth   = 1,
		    templateOE = &cutoutInfo->piece2OE);
  if (cutoutInfo->piece2OE.obj_id.objid == NULL_OBJID) {
    strcpy(buf,"Cannot get intersecting element");
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objOE = &cutoutInfo->piece2OE);
  
  // Next is the extra which probably ignore
  VDpplGetDoubleParent(&cutoutOE->obj_id,2,&cutoutInfo->extra);
  VDpplGetDoubleParent(&cutoutOE->obj_id,3,&cutoutInfo->base);
  VDpplGetDoubleParent(&cutoutOE->obj_id,4,&cutoutInfo->web);
          
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) {
    if (*buf) {
      printf("*** %s\n",buf);
    }
    
    printf("<<< VSefpGetEtInfo %d\n",retFlag);
  }
  else {
    if (*buf) {
      printf("------- Problem getting end treatment info -------------\n");
      vdobj$Print(objOE = cutoutOE);
      printf("*** %s\n",buf);
      printf("-----\n");
    }
  }
  
  return retFlag;
}

/* ------------------------------------
 * Compute function for the efp_beam
 */
IGRstat VSefpComputeEfpBeam2d(TGRobj_env *macOE,
			      IGRint      opFlag,
			      IGRint     *feetCnt,
			      TGRid      *feetIDs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts,msg;
  BSrc       rc;
  
  TGRobj_env beamOE;
  TGRobj_env csOE;
  
  IGRchar    macObjName[128];
  IGRchar    macObjDesc[128];
  IGRchar    buf[128];

  IGRdouble  ptx[15];
  IGRdouble  pts[15];
  IGRint     i;

  TVSefpBeamInfo beamInfo;
  
  IGRmatrix csMatrix;
  IGRdouble xDis,yDis;
  
  // For the processed macros
  IGRint           cutoutI;
  TGRobj_env       cutoutOE;
  TVSefpCutoutInfo cutoutInfo;
  
  // Init
  VSefpInitBeamInfo(&beamInfo);
  
  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_COMPUTE_EFP_BEAM2D);
  traceFlag = 1;
  strcpy(macObjDesc,"Unknown");

  if (traceFlag) {
    printf(">>> VSefpComputeEfpBeam2d\n");
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
                    nth        = VDEFP_EFP_BEAM2D_PARENT_BEAM,
                    templateOE = &beamOE);
  if (beamOE.obj_id.objid == NULL_OBJID) goto wrapup;

  sts = vdobj$IsAncestryValid(objOE          = &beamOE, 
                              superClassName = "VSbeam");
  if (!(sts & 1)) goto wrapup;
  
  if (traceFlag) vdobj$Print(objOE = &beamOE);

  // Get the cs
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_EFP_BEAM2D_PARENT_CS,
                    templateOE = &csOE);
  if (csOE.obj_id.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) vdobj$Print(objOE = &csOE);

  // Get the five key points
  sts = VSefpGetBeamInfo(&beamOE,0,&beamInfo);
  if (!(sts & 1)) {
    printf("Problem getting beam information\n");
    goto wrapup;
  }
  // sts = VSefpGetBeam3dPoints(&beamInfo);
  if (!(sts & 1)) {
    printf("Problem getting beam 3d points\n");
    goto wrapup;
  }
  
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
  
  // The cs origin and the z-axis for the second parameter
  // At this point, only using the origin, consider using x and y later
  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,csMatrix),
		senderid = NULL_OBJID,
		targetid = csOE.obj_id.objid,
		targetos = csOE.obj_id.osnum);

  if (!(sts & 1)) {
    strcpy(buf,"Problem getting cs matrix");
    goto wrapup;
  }

  /* ---------------------------------------------------
   * Maybe don't need all that xform stuff at all
   */
  for(i = 0; i < 5; i++) {  
    pts[(i*3)+0] = csMatrix[ 3];
    pts[(i*3)+1] = csMatrix[ 7];
    pts[(i*3)+2] = csMatrix[11];
  }
  
  xDis = BSdistptpt(&rc,beamInfo.pt1,beamInfo.pt2);
  yDis = BSdistptpt(&rc,beamInfo.pt1,beamInfo.pt3);

  pts[ 3] += xDis;
  pts[ 6] += xDis;
  pts[ 7] += yDis;
  pts[10] += yDis;
  
  VDdrawLinear(5,pts,&macOE->mod_env,&feetIDs[5]);

  // Cycle through each macro
  for(cutoutI = 0; 
      vdvlaoe$GetNth(vla = &beamInfo.macVLA, nth = cutoutI, data = &cutoutOE); 
      cutoutI++) {

    sts = VSefpGetCutoutInfo(&beamInfo.beamOE,&cutoutOE,&cutoutInfo);
    if (sts & 1) {
      
      vdobj$Print(objOE = &cutoutOE);

    }
    
  }
  
  // Done
  *feetCnt = 6;
  retFlag  = 1;

wrapup:
  VSefpFreeBeamInfo(&beamInfo);
  
  sprintf(buf,"Processed %s",macObjDesc);
  UI_status(buf);

  if (traceFlag) {
    printf("<<< VSefpComputeEfpBeam2d\n");
  }

  return retFlag;
}

#if 0
  /* ------------------------------------------------------------
   * Make a transformation matrix from 3d to the 2d cs
   */
  
  // The first 3d beam point is th origin
  // From pt1 to pt4 is the material direction
  for(i = 0; i < 3; i++) {
     pt1[i] = beamInfo.pt1[i];
    vec1[i] = beamInfo.pt4[i] - beamInfo.pt1[i];
  }
  MAunitvc(&rc, vec1, vec1);
  printf("vec1 %f %f %f\n",vec1[0],vec1[1],vec1[2]);
  
  // The cs origin and the z-axis for the second parameter
  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,csMatrix),
		senderid = NULL_OBJID,
		targetid = csOE.obj_id.objid,
		targetos = csOE.obj_id.osnum);

  if (!(sts & 1)) {
    strcpy(buf,"Problem getting cs matrix");
    goto wrapup;
  }
  // Maybe should apply mod_env but skip for now
   pt2[0] = csMatrix[ 3];
   pt2[1] = csMatrix[ 7];
   pt2[2] = csMatrix[11];
  vec2[0] = csMatrix[ 8] * 1.0;
  vec2[0] = csMatrix[ 9] * 1.0;
  vec2[0] = csMatrix[10] * 1.0;  
  MAunitvc(&rc, vec2, vec2);
  printf("vec2 %f %f %f\n",vec2[0],vec2[1],vec2[2]);

  // Majic from here
  BStrans1(&rc,
	    pt1,vec1,
	    pt2,vec2,
	    transVector,
	    mat3x3,
	    scale);

  VDgeomSetMatToIdentity(&mat2);
  for(i = 0; i < 3; i++) {
    mat2.matrix[(i*4)+0]  =  mat3x3[i][0];
    mat2.matrix[(i*4)+1]  =  mat3x3[i][1];
    mat2.matrix[(i*4)+2]  =  mat3x3[i][2];
  }
  MAtypemx(&rc,mat2.matrix,&mat2.matrix_type);

  /* Translate to origin */
  VDgeomSetMatToIdentity(&mat1);
  mat1.matrix[ 3] = -transVector[0];
  mat1.matrix[ 7] = -transVector[1];
  mat1.matrix[11] = -transVector[2];
  MAtypemx(&rc,mat1.matrix,&mat1.matrix_type);

  vdgeom$MultMat(mat1 = &mat2, mat2 = &mat1, mat3 = &mat);
  //vdgeom$Print(mat = &mat);

  for(i = 0; i < 3; i++) {
    mat.matrix[(i*4)+0] = mat3x3[i][0];
    mat.matrix[(i*4)+1] = mat3x3[i][1];
    mat.matrix[(i*4)+2] = mat3x3[i][2];
    mat.matrix[(i*4)+3] = -transVector[i];
  }
  mat.matrix[(i*4)+3] = 1.0;

  MAtypemx(&rc,mat.matrix,&mat.matrix_type);
  //vdgeom$Print(mat = &mat);
 
  // test by transforming first two points and makeing a line segment
  MAoptsxform(&rc,
	      &numPoles,
	      &mat.matrix_type,
	       mat.matrix,
	       beamInfo.pt1,&pts[0]);

  MAoptsxform(&rc,
	      &numPoles,
	      &mat.matrix_type,
	       mat.matrix,
	       beamInfo.pt2,&pts[3]);

  MAoptsxform(&rc,
	      &numPoles,
	      &mat.matrix_type,
	       mat.matrix,
	       beamInfo.pt3,&pts[6]);

#endif

end implementation Root;



