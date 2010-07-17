/* $Id: VPextPlate.I,v 1.2 2001/02/20 01:07:57 build Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/VPextProd.I
 *
 * Description: Extract Production Pieces
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VPextPlate.I,v $
 *      Revision 1.2  2001/02/20 01:07:57  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/10/26  19:59:02  pinnacle
# ah
#
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
# Revision 1.1  1998/06/14  16:13:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/12/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDvla.h"
#include "VDsa.h"
#include "VDgeom.h"
#include "VDppl1.h"

#define   vdsDEBUGx 1
#include "vldbgmacros.h"
#include "v_miscmacros.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "mainvmx.h"
#include "martrnmx.h"
#include "maoptsxfo.h"
#include "matypemx.h"

#include "bssfnormal.h"
#include "bssfevaln.h"
#include "bstrans1.h"

#include "vs.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"

#include "VDefp.h"
#include "VSefp.h"
#include "VPpdf.h"
#include "VPextInfo.h"

from EMSsubbs import EMget_edges;
from EMSedge  import EMgetxyzobj;
from GRvg     import GRgetattr;
from VDSroot  import VDprint;
from GRvg     import GRdetplane;

from ACrg_collect import ACshow_data;
from ACrg_collect import ACget_named_attribute;

extern OPP_VSplate_class_id;

/* --------------------------------------------------------
 * Given a vector, return material orientation
 */
IGRstar VPextGetPlateMaterialDirection(IGRvector vec, IGRchar *dir)
{
  IGRstat retFlag = 0;
  
  IGRint x,y,z;
  
  // Arg check
  if (dir == NULL) goto wrapup;
  strcpy(dir,"UNK");
  
  // Assume only has major orientations
  x = y = z = 0;
  if (vec[0] >  .9) x =  1;
  if (vec[0] < -.9) x = -1;
  if (vec[1] >  .9) y =  1;
  if (vec[1] < -.9) y = -1;
  if (vec[2] >  .9) z =  1;
  if (vec[2] < -.9) z = -1;
  
  // Up/down
  if ((x == 0) && (y == 0) && (z == 1)) {
    strcpy(dir,"UP");
    return 1;
  }
  if ((x == 0) && (y == 0) && (z == -1)) {
    strcpy(dir,"DOWN");
    return 1;
  }

  // Fwd/aft
  if ((x == 1) && (y == 0) && (z == 0)) {
    strcpy(dir,"FWD");
    return 1;
  }
  if ((x == -1) && (y == 0) && (z == 0)) {
    strcpy(dir,"AFT");
    return 1;
  }

  // Port/stbd
  if ((x == 0) && (y == 1) && (z == 0)) {
    strcpy(dir,"PORT");
    return 1;
  }
  if ((x == 0) && (y == -1) && (z == 0)) {
    strcpy(dir,"STBD");
    return 1;
  }

  printf("### Unknown orientation %8.2f,%8.2f,%8.2f %d,%d,%d\n",
	 vec[0],vec[1],vec[2],x,y,z);
  
wrapup:
  return retFlag;
}
/* --------------------------------------------------------
 * Get and process the plate surface
 * 2.6.0.2 version
 */
IGRstar VPextGetPlateSurface(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  TGRplane  srfPlane;
  
  IGRpoint  pt1,pt2;
  IGRvector vec;
  IGRvector vecx[3];
  
  IGRint i;

  TGRobj_env    *srfOE;
  TGRmdenv_info *mat,mat1,mat2;

  IGRdouble mat3x3[3][3];
  IGRvector transVector;
  IGRdouble scale[3];
  IGRdouble normal[3];
  
  // Get its base surface
  srfOE = &plateInfo->srcSrfOE;
  vdobj$GetFoot(objOE    = &plateInfo->srcPlateOE, 
		footName = VS_K_plBotSfPath, 
		footOE   = srfOE);

  // vdobj$Print(objOE = srfOE);
  if (srfOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  // For planar plates, get surface normal and point
  srfPlane.point  = &pt1[0];
  srfPlane.normal =  plateInfo->srcSrfNormal;
  
  sts = om$send(msg = message GRvg. 
		GRdetplane(&msg,
			   &srfOE->mod_env.md_env.matrix_type,
			    srfOE->mod_env.md_env.matrix,
			   &srfPlane),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("Plate surface is not planar\n");
    goto wrapup;
  }

  //    VPpdfWrite3dPts(PDF_ATR_PLATE_PLANE, 2, plane);
#if 0
  printf("nrm %8.2f,%8.2f,%8.2f\n",
	 srfPlane.normal[0],
	 srfPlane.normal[1],
	 srfPlane.normal[2]);
#endif

  // Get the geomotry
  vdgeom$Get(objOE = &plateInfo->srcSrfOE, bsp = (IGRchar**)&plateInfo->srcSrfBsp);
  if (plateInfo->srcSrfBsp == NULL) {
    printf("Problem getting surface geometry\n");
    goto wrapup;
  }

  /* Want to calculate physical center of surface
   * Some surfaces can have unexpected .5,.5 points */
  BSsfevaln(plateInfo->srcSrfBsp,0.0,0.0,1,&i,pt1,vecx,&rc);
  BSsfevaln(plateInfo->srcSrfBsp,1.0,1.0,1,&i,pt2,vecx,&rc);

  for(i = 0; i < 3; i++) {
    plateInfo->srcSrfCenter[i] = pt1[i] + ((pt2[i] - pt1[i]) * .5);
  }
#if 0
  printf("cen %8.2f,%8.2f,%8.2f\n",
	 plateInfo->srcSrfCenter[0],
	 plateInfo->srcSrfCenter[1],
	 plateInfo->srcSrfCenter[2]);
#endif
  // Want translation matrix to xy plane
  pt1[0] = 0.0; pt1[1] = 0.0; pt1[2] =  0.0;
  vec[0] = 0.0; vec[1] = 0.0; vec[2] = -1.0; // Material goes into xy plane

  /* ------------------------------------------
   * Flip the normal if want to present offset side 
   */
  for(i = 0; i < 3; i++) {
    if (plateInfo->presentOffset) normal[i] = plateInfo->srcSrfNormal[i] * -1.0;
    else                          normal[i] = plateInfo->srcSrfNormal[i];
  }
  
  BStrans1(&rc,
	   plateInfo->srcSrfCenter,
	   normal,
	   pt1, vec,
	   transVector,
	   mat3x3,
	   scale);

  if (rc != BSSUCC) {
    printf("BStrans1 failed\n");
    goto wrapup;
  }

  // Xfer to final matrix
  // You might think this works but it don't
  mat = &plateInfo->srcSrfMat;
  for(i = 0; i < 3; i++) {
    mat->matrix[(i*4)+0] = mat3x3[i][0];
    mat->matrix[(i*4)+1] = mat3x3[i][1];
    mat->matrix[(i*4)+2] = mat3x3[i][2];
    mat->matrix[(i*4)+3] = -transVector[i];
  }
  mat->matrix[(i*4)+3] = 1.0;

  MAtypemx(&rc,mat->matrix,&mat->matrix_type);

  //vdgeom$Print(mat = mat);


  /* Rotate it to xy plane */
  VDgeomSetMatToIdentity(&mat2);
  for(i = 0; i < 3; i++) {
    mat2.matrix[(i*4)+0]  =  mat3x3[i][0];
    mat2.matrix[(i*4)+1]  =  mat3x3[i][1];
    mat2.matrix[(i*4)+2]  =  mat3x3[i][2];
#if 0
    printf("mat %8.2f %8.2f %8.2f\n",
	   mat3x3[i][0],mat3x3[i][1],mat3x3[i][2]);
#endif	       				  
  }
  MAtypemx(&rc,mat2.matrix,&mat2.matrix_type);

  /* Translate to origin */
  VDgeomSetMatToIdentity(&mat1);
  mat1.matrix[ 3] = -transVector[0];
  mat1.matrix[ 7] = -transVector[1];
  mat1.matrix[11] = -transVector[2];
  MAtypemx(&rc,mat1.matrix,&mat1.matrix_type);

  vdgeom$MultMat(mat1 = &mat2, mat2 = &mat1, mat3 = mat);

  //vdgeom$Print(mat = mat);
  
  // Convert direction
  VPextGetPlateMaterialDirection(plateInfo->srcSrfNormal,
                                 plateInfo->srcSrfDirection);
  //printf("Material Direction %s\n",dir);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* --------------------------------------------------------
 * Fills in plateInfo with the tree
 */
IGRstat VPextGetPlateTree(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;

  TVDvlaOE vlaOE;

  IGRchar  buf[256];
  IGRint   i;
  IGRint   cnt;

  // Init
  vdvla_oe$Construct(vla = &vlaOE);
  if (plateInfo == NULL) goto wrapup;

  // Get the tree
  VSefpGetNeatPlate(&plateInfo->curPlateOE,
                    &plateInfo->srcPlateOE,
                    &vlaOE);

  // Get the source plate
  cnt = vdvla_oe$GetCnt(vla = &vlaOE);
  if (cnt < 1) {
    printf("Problem getting tree of plates\n");
    goto wrapup;
  }

  //vdobj$Print(objOE = &plateInfo->srcPlateOE);
  vdobj$Print(objOE = &plateInfo->srcPlateOE, str = buf);
  UI_status(buf);

  // Xfer to plate data
  if (cnt > VP_EXT_INFO_MAX) {
    vdobj$Print(objOE = &plateInfo->curPlateOE);
    printf("Warning plate tree is huge: %d\n",cnt);
    cnt = VP_EXT_INFO_MAX;
  }
  for(i = 0; i < cnt; i++) {
    vdvla_oe$GetAt(vla   = &vlaOE, 
                   nth   = i, 
                   objOE = &plateInfo->plates.plateOEs[i]);
  }
  plateInfo->plates.cnt = cnt;
   
  retFlag = 1;

wrapup:
  vdvla_oe$Delete(vla = &vlaOE);
  return retFlag;
}

/* --------------------------------------------------------
 * Writes 3d points for the plate
 */
IGRstar VPextWritePlate3dPoints(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  TGRmdenv_info inv;

  IGRshort  dim = 4;
  IGRdouble ref[9];
  IGRlong   numPoles;

  BSrc      rc;

  // Arg check
  if (plateInfo == NULL) goto wrapup;

  // Find the inverse translation matrix
  
  //MArtrnmx(&msg2,&row,&col,plateInfo->srcSrfMat.matrix,trn);
  MAinvmx(&msg,&dim,plateInfo->srcSrfMat.matrix,inv.matrix);
  MAtypemx(&rc,inv.matrix,&inv.matrix_type);

#if 0
  VPpdfWriteHdr(PDF_ATR_PIECE_3D_MATRIX,PDF_DT_REALS,12);
  for(i = 0; i < 12; i++) {
    VPpdfWriteReal(inv.matrix[i]);
  }
#endif

  // Using the inverse matrix, construct three ref points
  ref[0] =    0.0; ref[1] =    0.0; ref[2] = 0.0;
  ref[3] = 1000.0; ref[4] =    0.0; ref[5] = 0.0;
  ref[6] =    0.0; ref[7] = 1000.0; ref[8] = 0.0;
  numPoles = 3;
  
  MAoptsxform(&msg,&numPoles,
	      &inv.matrix_type,
	       inv.matrix,
	       ref,ref);

  VPpdfWrite3dPts(PDF_ATR_PIECE_3D_REF_PTS, numPoles, ref);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Flips a plate if need be
 */
IGRstat VPextFlipPlate(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 1;
  IGRstat msg;
  
  TGRid    unwrapID;
  TGRobj_env collOE;

  TACrg_coll sideToPresent;
  IGRint flag;
  
  // Find the unwrap object
  vdchn$GetChildrenByClass(objOE     = &plateInfo->curPlateOE,
			   className = "VLunwObj",
			   childID   = &unwrapID);
  if (unwrapID.objid == NULL_OBJID) goto wrapup;

  // Grab it's first parent
  vdobj$GetTemplate(objID      = &unwrapID,
                    nth        = 0,
                    templateOE = &collOE);

  // vdobj$Print(objID = &unwrapID);

  strcpy(sideToPresent.name,"Side to Unwrap");
  
  om$send(msg = message ACrg_collect.ACget_named_attribute(&msg,&sideToPresent),
	  senderid = NULL_OBJID,
	  targetid = collOE.obj_id.objid,
	  targetos = collOE.obj_id.osnum);

  flag = sideToPresent.desc.value.att_exp;
  if ((flag == 1) || (flag == 3)) {
    plateInfo->presentOffset = 1;
    //VPpdfWriteAttrInt(PDF_ATR_PLATE_FLIP,1);
  }
  
wrapup:
  return retFlag;
}

 
/* --------------------------------------------------------
 * Process a plate
 */
IGRstar VPextProcessPlate(TGRobj_env *curPlateOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVPextPlateInfo *plateInfo = NULL;
  
  TVDvlaOE vlaOE;

  IGRchar buf[256];
  IGRchar plateName [128];
  IGRchar plateClass[128];
  IGRchar platePcmk [128];
  
  //IGRint   cnt;
  //IGRint   i;

//  TGRobj_env edgeOE;

  FILE *plateTraceFile = VPextGetPlateTraceFile();
  
  // Init
  plateInfo = (TVPextPlateInfo*)_CALLOC(1,TVPextPlateInfo);
  if (plateInfo == NULL) return 0;
  
  plateInfo->curPlateOE = *curPlateOE;
  
  vdvla_oe$Construct(vla = &vlaOE);
  
  // Say hi
  vdobj$Get(objOE = curPlateOE, objName   = plateName);
  vdobj$Get(objOE = curPlateOE, className = plateClass);

  vdsa$GetStruct(objOE = curPlateOE, name = "SA_AST:StagingTree:0:pcmk", txt = platePcmk);

  sprintf(plateInfo->desc,"%2d %6d %-10s %4s %-20s",
	  curPlateOE->obj_id.osnum,
	  curPlateOE->obj_id.objid,
	  plateClass,
	  platePcmk,
	  plateName);

  UI_status(plateInfo->desc);
  printf("%s\n",plateInfo->desc);

  // get list of all plates upto and including source/split plate
  sts = VPextGetPlateTree(plateInfo);
  if (!(sts & 1)) {
    printf("Problem getting plate tree\n");
    goto wrapup;
  }

  // See if plate needs to be flipped (based on unwrap)
  VPextFlipPlate(plateInfo);

  // Get the surface and translation matrix
  sts = VPextGetPlateSurface(plateInfo);
  if (!(sts & 1)) goto wrapup;
  
  VPpdfWriteAttrText(PDF_ATR_PLATE_MAT_DIR, plateInfo->srcSrfDirection);
  
  // Need the surface transformation matrix
  VPpdfSetTranslationMatrix(&plateInfo->srcSrfMat);

  // Write 3d orientation points
  VPextWritePlate3dPoints(plateInfo);

  // Get the bevel information
  VPextGetPlateBevels(plateInfo);

  // Get the edge information
  VPextGetPlateEdges(plateInfo);

  // fool around with adding stock and other such nonsense
  VPextAdjustPlateEdges(plateInfo);

  // Add any plate labels to the edges
  VPextGetPlateLabels(plateInfo);
  
  // Dump the edges (and any edge labels)
  VPextWritePlateEdges(plateInfo);

  // Do the holes
  VPextWritePlateHoles(plateInfo);
  
  // Do the marks
  VPextGetPlateMarkLines(plateInfo);

  // Do the datumes
  VPextWritePlateDatums(plateInfo);

  // Summarize
  sprintf(buf,"%s %-4s Edges %2d, Holes %2d, Labels %2d",
	  plateInfo->desc,
	  plateInfo->srcSrfDirection,	 
	  plateInfo->edges.cnt,
	  plateInfo->holes.cnt,
	  plateInfo->labels.cnt);

  printf("%s\n",buf);

  if (plateTraceFile) fprintf(plateTraceFile,"%s\n",buf);
      
  // Done
  retFlag = 1;

wrapup:

  // vdobj$Delete( vlaOE = &plateInfo->edgeVLA);

  vdvla_oe$Delete(vla = &vlaOE);

  _FREE(plateInfo);
  
  return retFlag;
}

/* -------------------------------------------------------
 * Extracts one plate for a tree node
 */
IGRstat VPextExtractPlateNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid  pplID;
  IGRint pplRet;
  
  TGRobj_env plateOE;
  
  // Make sure have a plate
  VDatGetLeafObject(nodeID,&plateOE);
  
  sts = vdobj$IsAncestryValid(objOE = &plateOE, superClassName = "VSplate");
  if (!(sts & 1)) goto wrapup;

  // Start
  VPpdfWriteObjBeg(PDF_OBJ_PLATE);
  
  // Pump out the attributes
  vdppl$Load(name = "VPextract", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar *)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar *)&plateOE);

  vdppl$Run(pplID = &pplID, name = "extractPlate", ret = &pplRet);


  VPextProcessPlate(&plateOE);
  
  // Finish Up
  VPpdfWriteObjEnd(PDF_OBJ_PLATE);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Tester for extracting one plate
 */
IGRstat VPextExtractPlate(TGRobj_env *plateOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid pplID;
  TGRid nodeID;
  
  IGRint pplRet;
  
  // Init
  VPextInitMasterInfo();
  
  // Open
  sts = VPextOpenDataFile("ProdData.pdf");
  if (!(sts & 1)) goto wrapup;

  // Start
  VPpdfWriteObjBeg(PDF_OBJ_PLATE);
  
  // Pump out the attributes
  vdppl$Load(name = "VPextract", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  VDatGetObjectLeafForSetType(plateOE,"StagingTree",&nodeID);
  
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar *)&nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar *)plateOE);

  vdppl$Run(pplID = &pplID, name = "extractPlate", ret = &pplRet);


  VPextProcessPlate(plateOE);
  
  // Close Up
  VPpdfWriteObjEnd(PDF_OBJ_PLATE);
  VPextCloseDataFile("ProdData.pdf");

  // Done
  retFlag = 1;
  
wrapup:
  VPextDeleteMasterInfo();
  return retFlag;
}

end implementation VDbtBase;





