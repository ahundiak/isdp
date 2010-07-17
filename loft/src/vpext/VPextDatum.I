class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "bsconic.h"
#include "bspl_pl.h"
#include "maoptsxfo.h"

#include "VPextInfo.h"
#include "VPpdf.h"

#define vdsDEBUGx 1 

from GRvg import GRdetplane;

extern GRclassid OPP_SMInfPlane_class_id;

#define VP_MAX_DATUM 16

static int      datumPlaneCnt;
static TVDplane datumPlanes[VP_MAX_DATUM];

static int traceFlag;

/* --------------------------------------------------------
 * Process one possible datum plane
 */
IGRstat VPextFindDatum(TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar  name[128];
  IGRchar *p;
  
  TGRplane  plane;
  TVDplane *planex;
  
  // Look for infinite planes
  sts = vdobj$IsAncestryValid(objOE = objOE, 
			      superClassID = OPP_SMInfPlane_class_id);
  if (!(sts & 1)) goto wrapup;

  // Check name
  vdobj$Get(objOE = objOE, objName = name);
  for(p = name; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
  if (strncmp("DATUM",name,5)) goto wrapup;
  
  // Append
  if (datumPlaneCnt >= VP_MAX_DATUM) goto wrapup;
  planex = &datumPlanes[datumPlaneCnt];
  
  plane.normal = planex->normal;
  plane.point  = planex->point;
  
  om$send(msg = message 
	  GRvg.GRdetplane(&msg,
			  &objOE->mod_env.md_env.matrix_type,
			  objOE->mod_env.md_env.matrix,
			  &plane),
	  senderid = NULL_OBJID,
	  targetid = objOE->obj_id.objid,
	  targetos = objOE->obj_id.osnum);
  
  if (traceFlag) {
    printf("Plane %-8s %12.4f,%12.4f,%12.4f\n"
           "      %-8s %12.4f,%12.4f,%12.4f\n",
           name,plane.point [0],plane.point [1],plane.point [2],
	   "",  plane.normal[0],plane.normal[1],plane.normal[2]);
  }

  datumPlaneCnt++;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Scan osnum for datum planes
 */
IGRstar VPextFindDatums(VDosnum osnum)
{
  IGRstat retFlag = 0;
  
  IGRlong    max;
  TGRobj_env objOE;

  if (traceFlag) {
    printf(">>> VPextFindDatums, %d\n",datumPlaneCnt);
  }

  datumPlaneCnt = 0;
  
  // Need module env
  gr$get_module_env(buffer = &objOE.mod_env);

  // Scan os
  objOE.obj_id.osnum = osnum;
  max = OM_GA_OSDs[objOE.obj_id.osnum]->CurSpaceMapSize;
  for(objOE.obj_id.objid = 0; objOE.obj_id.objid < max; objOE.obj_id.objid++) {

    VPextFindDatum(&objOE);
    
  }
  
  retFlag = 1;

  if (traceFlag) {
    printf("@@@ VPextFindDatums, %d\n",datumPlaneCnt);
  }
  
  return retFlag;
  
}

/* --------------------------------------------------------
 * Write single datum plane
 */
IGRstat VPextWritePlateDatum(TVPextPlateInfo *plateInfo,
			     TVDplane        *a_datumPlane)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  IGRlong  numPoles;
  TVDplane datumPlane;
  TVDplane xyPlane;

  TVDplane intLine;
  IGRint   intFlag;

  IGRdouble lineMul;
  IGRpoint  pt1,pt2;
  IGRint    flag1,flag2;
  
  IGRint i;
  
  BSrc rc;
  
  TGRbsp_curve *markBsp = NULL;
  TGRbsp_curve *lineBsp = NULL;

  TGRpoint  linePt, edgePt;
  IGRdouble linePar,edgePar;
  
  IGRdouble dist;
  
  // Say hi
  if (traceFlag) {
    printf(">>> VPextWritePlateDatum\n");
  }

  // Only want to rotate and not translate
  // Translate into 2d space
  datumPlane = *a_datumPlane;
  numPoles = 1;

  MAoptsxform(&msg,&numPoles,
	      &plateInfo->srcSrfMat.matrix_type,
	       plateInfo->srcSrfMat.matrix,
	       datumPlane.point,
	       datumPlane.point);

  MAoptsxform(&msg,&numPoles,
	      &plateInfo->srcSrfMat.matrix_type,
	       plateInfo->srcSrfMat.matrix,
	       datumPlane.normal,
	       datumPlane.normal);

  datumPlane.normal[0] -= plateInfo->srcSrfMat.matrix[ 3];
  datumPlane.normal[1] -= plateInfo->srcSrfMat.matrix[ 7];
  datumPlane.normal[2] -= plateInfo->srcSrfMat.matrix[11];
  
  
  // See if intersect with xy plane
  memset(&xyPlane,0,sizeof(xyPlane));
  xyPlane.normal[2] = 1.0;

  // Intersect as infinite planes
  intFlag = 0;
  
  BSpl_pl(xyPlane.point,xyPlane.normal,
	  datumPlane.point,datumPlane.normal,
	  &intFlag,
	  intLine.point,intLine.normal,&rc);

  if ((rc != BSSUCC) || (intFlag != BSCINTERSECTING)) {
    goto wrapup;
  }

  // Make big line segment
  lineMul = 10000.0 * 10000.0;
  for(i = 0; i < 3; i++) {
    pt1[i] = intLine.point[i] + (lineMul * intLine.normal[i]);
    pt2[i] = intLine.point[i] - (lineMul * intLine.normal[i]);
  }
  VDgeomMakeLineCurve(pt1,pt2,&lineBsp);
  if (lineBsp == NULL) goto wrapup;
  
  // see where edges intersect
  flag1 = flag2 = 0;
  for(i = 0; i < plateInfo->edges.cnt; i++) {

    VDsupIntCrvCrv(lineBsp,plateInfo->edges.info[i].crv2Dstk,
		   &linePt, &edgePt,
		   &linePar,&edgePar,
		   &dist);
  
    if (dist < .01) {

      if (flag2 == 1) {
	printf("*** Multiple edges intersect datum plane\n");
      }
      
      if (flag1 == 1) {
	flag2  = 1;
	pt2[0] = linePt.x;
	pt2[1] = linePt.y;
	pt2[2] = linePt.z;
      }
      
      if (flag1 == 0) {
	flag1 = 1;
	pt1[0] = linePt.x;
	pt1[1] = linePt.y;
	pt1[2] = linePt.z;
      }
      
    }
    
  }
  if (flag2 == 0) goto wrapup;

  // Make curve
  VDgeomMakeLineCurve(pt1,pt2,&markBsp);
  if (markBsp == NULL) goto wrapup;
  
  // Dump out datum line
  VPpdfWriteObjBeg(PDF_OBJ_MARKING_LINE);

  VPpdfWriteAttrText(PDF_ATR_MARKING_LINE_TYPE, "DATUM");

  VPpdfWriteBspCurve2D(PDF_ATR_MARKING_LINE_CURVE,markBsp);

  VPpdfWriteObjEnd(PDF_OBJ_MARKING_LINE);

  if (traceFlag) {
  printf("Plane %12.4f,%12.4f,%12.4f\n"
         "      %12.4f,%12.4f,%12.4f\n",
	 a_datumPlane->point [0],a_datumPlane->point [1],a_datumPlane->point [2],
	 a_datumPlane->normal[0],a_datumPlane->normal[1],a_datumPlane->normal[2]);

  printf("Plane %12.4f,%12.4f,%12.4f\n"
         "      %12.4f,%12.4f,%12.4f\n",
	   datumPlane.point [0],datumPlane.point [1],datumPlane.point [2],
	   datumPlane.normal[0],datumPlane.normal[1],datumPlane.normal[2]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  _FREE(lineBsp);
  _FREE(lineBsp);
  
  if (traceFlag) {
    printf("@@@  VPextWritePlateDatum\n");
  }
  return retFlag;
}


/* --------------------------------------------------------
 * Write datum planes
 */
IGRstar VPextWritePlateDatums(TVPextPlateInfo *plateInfo)
{
  IGRstat   retFlag = 0;
  IGRint    i;
  
  if (traceFlag) {
    printf(">>> VPextWritePlateDatums, %d\n",datumPlaneCnt);
  }
  
  // Find datum planes
  if (datumPlaneCnt == 0) VPextFindDatums(2);
  
  // Cycle though each plane
  for(i = 0; i < datumPlaneCnt; i++) {
    VPextWritePlateDatum(plateInfo,&datumPlanes[i]);
  }
  
  // Done
  retFlag = 1;
  
//wrapup:

  if (traceFlag) {
    printf("@@@ VPextWritePlateDatums, %d\n",datumPlaneCnt);
  }

  return retFlag;
}

end implementation VDbtBase;

