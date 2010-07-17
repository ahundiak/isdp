/* $Id: VPextBeam.I,v 1.2 2001/02/20 01:07:55 build Exp $  */

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
 *      $Log: VPextBeam.I,v $
 *      Revision 1.2  2001/02/20 01:07:55  build
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

#include "VDatMaster.h"

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
#include "bsdistptpt.h"

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

extern VDclassid OPP_VSplate_class_id;
extern VDclassid OPP_VSbeam_class_id;

static int traceFlag;

/* --------------------------------------------------
 * Put out oval closed beam
 */
IGRstar VPextWriteClosedBeamOval(TGRbsp_curve *crvBsp)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  TGRoval oval;
  
  IGRpoint  ptx;
  IGRdouble par1,par2,par3;
  IGRdouble distance;
  
  // Put through some tests for "standard oval"
  if (crvBsp->order     !=  3) goto wrapup;
  if (crvBsp->rational  ==  0) goto wrapup;

  switch(crvBsp->num_poles){

  case 13: 
    par1 = .125;
    par2 = .375;
    par3 = .625;
    break;

  case 15: 
    par1 = .000;
    par2 = .300;
    par3 = .500;
    break;
    
  default:
    goto wrapup;
  }
  
  // Get the six points of the curve
  VDgeomGetCrvPt(crvBsp,par1,oval.axis2); // Minor axis
  VDgeomGetCrvPt(crvBsp,par2,oval.axis1); // Major axis
  VDgeomGetCrvPt(crvBsp,par3,ptx);        // To locate center

  // Center of oval is mid between minor axis and ptx
  oval.origin[0] = oval.axis2[0] + ((ptx[0] - oval.axis2[0]) * .5);
  oval.origin[1] = oval.axis2[1] + ((ptx[1] - oval.axis2[1]) * .5);
  oval.origin[2] = oval.axis2[2] + ((ptx[2] - oval.axis2[2]) * .5);

  if (traceFlag) {
  printf("Oval   %s, %d\n",crvBsp->num_poles);
  printf("AXIS1 %.3f %10.3f,%9.3f,%9.3f\n",par1,oval.axis1 [0],oval.axis1 [1],oval.axis1 [2]);
  printf("AXIS2 %.3f %10.3f,%9.3f,%9.3f\n",par2,oval.axis2 [0],oval.axis2 [1],oval.axis2 [2]);
  printf("ORG    %4s %10.3f,%9.3f,%9.3f\n","  ",oval.origin[0],oval.origin[1],oval.origin[2]);
  printf("PTX   %.3f %10.3f,%9.3f,%9.3f\n",par3,ptx[0],ptx[1],ptx[2]);
  printf("\n");
  }
  
  // Flag it
  oval.flat = 1;
  
  // write it out
  VPpdfWriteBspOval(PDF_ATR_HOLE_CURVE,&oval);

  // Write it out
  VPpdfWriteHdr(PDF_ATR_BEAM_CLOSED,PDF_DT_REALS,2);

  distance = BSdistptpt(&rc,oval.origin,oval.axis1);
  VPpdfWriteReal(distance * 2.0);

  distance = BSdistptpt(&rc,oval.origin,oval.axis2);
  VPpdfWriteReal(distance * 2.0);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Put out circle beam info
 */
IGRstar VPextWriteClosedBeamCircle(TGRbsp_curve *crvBsp)
{
  IGRstat retFlag = 0;
  IGRint  arcFlag;
    
  TGRcir_arc  arc;

  // See if it is a arc, another routine allows specifying tolerance
  // Tol is .01
  // }
  arcFlag = VDgeomIsCirArc(crvBsp,arc.center,&arc.radius);
  if (arcFlag == 0) {
    goto wrapup;
  }
  VPpdfWriteHdr(PDF_ATR_BEAM_CLOSED,PDF_DT_REAL,1);
  VPpdfWriteReal(arc.radius * 2.0);
  
  retFlag = 1;
  
wrapup:
  
  return retFlag;
}

/* -------------------------------------------------------
 * Write info for a closed beam
 */
IGRstat VPextWriteClosedBeam(TVSefpBeamInfo *beamInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Only deal with closed beams
  if (!beamInfo->isClosed) {
    goto wrapup;
  }
  
  // See if it's a cirvle
  sts = VPextWriteClosedBeamCircle(beamInfo->axisBsp);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  // See if it's an oval
  sts = VPextWriteClosedBeamOval(beamInfo->axisBsp);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
 
  printf("*** Closed beam of unknown type\n");
  
  // Done
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Write the end treatments
 */
IGRstat VPextWriteEndTreatment(TVSefpBeamInfo *beamInfo, TVSefpEtInfo *etInfo)
{
  IGRstat retFlag = 0;
  FILE   *file = VPextGetEtTraceFile();
  
  // Closed beams will not have end treatments
  if (beamInfo->isClosed) {
    retFlag = 1;
    goto wrapup;
  }
  
  // May have gotten this far without really having an et
  if (etInfo->gotIt == 0) {

    // Fake It
    VPpdfWriteObjBeg  (PDF_OBJ_BEAM_ET);
    VPpdfWriteAttrText(PDF_ATR_BEAM_ET_TYPE, "NONE FOUND");
    VPpdfWriteObjEnd  (PDF_OBJ_BEAM_ET);
    if (file) fprintf(file,"%s NONE FOUND\n",beamInfo->desc);
    retFlag = 1;
    goto wrapup;
  }
  
  // Do the header
  VPpdfWriteObjBeg(PDF_OBJ_BEAM_ET);

  // The type
  VPpdfWriteAttrText(PDF_ATR_BEAM_ET_TYPE, etInfo->etType);

  // Two angles
  VPpdfWriteAttrReal(PDF_ATR_BEAM_ET_WEB_ANGLE,    etInfo->angle0);
  VPpdfWriteAttrReal(PDF_ATR_BEAM_ET_FLANGE_ANGLE, etInfo->angle2);

  // Finish up
  VPpdfWriteObjEnd(PDF_OBJ_BEAM_ET);

  // Trace
  if (file) fprintf(file,"%s %-12s %f %f\n",
		    beamInfo->desc,
		    etInfo->etType,
		    etInfo->angle0,
		    etInfo->angle2);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Writes the 3d reference points
 * Check for closed beams and write curve if dound
 */
IGRstat VPextWriteBeam3dPoints(TVSefpBeamInfo *beamInfo)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  IGRdouble pts[15];
  
  // Need an array for writing
  for(i = 0; i < 3; i++) {
    pts[ 0+i] = beamInfo->pt1[i];
    pts[ 3+i] = beamInfo->pt2[i];
    pts[ 6+i] = beamInfo->pt3[i];
    pts[ 9+i] = beamInfo->pt4[i];
    pts[12+i] = beamInfo->pt5[i];
  }
  VPpdfWrite3dPts(PDF_ATR_BEAM_WEB_3D,4,pts);
    
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Write a cutout
 */
IGRstat VPextWriteCutout(TVSefpBeamInfo *beamInfo, TGRobj_env *cutoutOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  BSrc    rc;
  
  TVSefpCutoutInfo cutoutInfo;
  
  IGRchar   buf[128];

  IGRdouble pts[9];
  IGRdouble distance;
  IGRint    i;
  
  // Arg check
  if (beamInfo == NULL) goto wrapup;
  if (cutoutOE == NULL) goto wrapup;
  
  // Gather up cutout information
  sts = VSefpGetCutoutInfo(&beamInfo->beamOE,cutoutOE,&cutoutInfo);
  if (!(sts & 1)) goto wrapup;
 
  // Start the object
  VPpdfWriteObjBeg(PDF_OBJ_CUTOUT);

  // Pull type from macro
  strcpy(buf,"3 672");
  VPpdfWriteAttrText(PDF_ATR_CUTOUT_TYPE,buf);
  
  // Intersecting information
  vdsa$GetStruct(objOE = &cutoutInfo.piece2OE, 
		 name  = "SA_AST:StagingTree:0:pcmk", 
		 txt   = buf);
  VPpdfWriteAttrText(PDF_ATR_TREE_NODE_PCMK,buf);

  vdsa$GetStruct(objOE = &cutoutInfo.piece2OE, 
		 name  = "family_name", 
		 txt   = buf);
  VPpdfWriteAttrText(PDF_ATR_PIECE_FAMILY,buf);

  vdsa$GetStruct(objOE = &cutoutInfo.piece2OE, 
		 name  = "part_num", 
		 txt   = buf);
  VPpdfWriteAttrText(PDF_ATR_PIECE_PART_NUM,buf);

  // Location is actually in an xy plane
  for(i = 0; i < 9; i++) pts[i] = 0.0;
  
  /* Still not completely comfortable with this but the cs should
   * lie only along the bottom curve on the left web.
   */
  distance = BSdistptpt(&rc,beamInfo->pt1,cutoutInfo.csOrg);
  pts[0] = distance;
  
  VPpdfWrite2dPts(PDF_ATR_CUTOUT_LOCATION, 3, pts);
  
  // Done
  VPpdfWriteObjEnd(PDF_OBJ_CUTOUT);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Process a beam
 */
IGRstat VPextProcessBeam(TGRobj_env *beamOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVSefpBeamInfo *beamInfo = NULL;

  IGRchar buf      [256];

  FILE *beamTraceFile = VPextGetBeamTraceFile();
  
  IGRint i;
  TGRobj_env cutoutOE;
  
  // Init
  beamInfo = (TVSefpBeamInfo*)_CALLOC(1,TVSefpBeamInfo);
  if (beamInfo == NULL) return 0;
  VSefpInitBeamInfo(beamInfo);
  
  sts = VSefpGetBeamInfo(beamOE,0,beamInfo);
  UI_status(beamInfo->desc);
  printf("%s\n",beamInfo->desc);

  if (!(sts & 1)) {
    printf("Problem getting beam info\n");
    goto wrapup;
  }

  // Write the 3d points
  VPextWriteBeam3dPoints(beamInfo);

  // Handle closed beams
  VPextWriteClosedBeam(beamInfo);
  
  // End treatments
  VPextWriteEndTreatment(beamInfo, &beamInfo->etInfo0);
  VPextWriteEndTreatment(beamInfo, &beamInfo->etInfo1);

  // Process each cutout
  for(i = 0;
      vdvlaoe$GetNth(vla = &beamInfo->macVLA, nth = i, data = &cutoutOE);
      i++) {
    VPextWriteCutout(beamInfo,&cutoutOE);
  }
  
  // Summarize
  sprintf(buf,"%s ",beamInfo->desc);

  if (beamTraceFile) fprintf(beamTraceFile,"%s\n",buf);
      
  // Done
  retFlag = 1;

wrapup:

  if (beamInfo) {
    VSefpFreeBeamInfo(beamInfo);  
    _FREE(beamInfo);
  }
  
  return retFlag;
}

/* -------------------------------------------------------
 * Extracts one beam for a tree node
 */
IGRstat VPextExtractBeamNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid  pplID;
  IGRint pplRet;
  
  TGRobj_env beamOE;
  
  // Make sure have a beam
  VDatGetLeafObject(nodeID,&beamOE);
  
  sts = vdobj$IsAncestryValid(objOE = &beamOE, superClassName = "VSbeam");
  if (!(sts & 1)) goto wrapup;

  // Start
  VPpdfWriteObjBeg(PDF_OBJ_BEAM);
  
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
                data  = (IGRchar *)&beamOE);

  vdppl$Run(pplID = &pplID, name = "extractBeam", ret = &pplRet);

  VPextProcessBeam(&beamOE);
  
  // Finish Up
  VPpdfWriteObjEnd(PDF_OBJ_BEAM);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Tester for extracting one beam
 */
IGRstat VPextExtractBeam(TGRobj_env *beamOE)
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
  VPpdfWriteObjBeg(PDF_OBJ_BEAM);
  
  // Pump out the attributes
  vdppl$Load(name = "VPextract", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  VDatGetObjectLeafForSetType(beamOE,"StagingTree",&nodeID);
  
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar *)&nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar *)beamOE);

  vdppl$Run(pplID = &pplID, name = "extractBeam", ret = &pplRet);

  VPextProcessBeam(beamOE);
  
  // Close Up
  VPpdfWriteObjEnd(PDF_OBJ_BEAM);
  VPextCloseDataFile("ProdData.pdf");

  // Done
  retFlag = 1;
  
wrapup:
  VPextDeleteMasterInfo();
  return retFlag;
}

/* -------------------------------------------------------
 * Allows testing several beams with a locate
 * User calls this first, then calls the append
 * then calls the close
 */
IGRstat VPextExtractOpen()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Init
  VPextInitMasterInfo();
  
  // Open
  sts = VPextOpenDataFile("ProdData.pdf");
  if (!(sts & 1)) {
    VPextDeleteMasterInfo();
    goto wrapup;
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

IGRstat VPextExtractClose()
{
  IGRstat retFlag = 0;

  VPextCloseDataFile("ProdData.pdf");
  VPextDeleteMasterInfo();

  retFlag = 1;
  
  return retFlag;
}

/* -------------------------------------------------------
 * Tester for appending one beam to already open file
 */
IGRstat VPextExtractBeamAppend(TGRobj_env *beamOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid pplID;
  TGRid nodeID;
  
  IGRint pplRet;
  
  // Should probably make sure it's initted

  // Start
  VPpdfWriteObjBeg(PDF_OBJ_BEAM);
  
  // Pump out the attributes
  vdppl$Load(name = "VPextract", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  VDatGetObjectLeafForSetType(beamOE,"StagingTree",&nodeID);
  
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar *)&nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar *)beamOE);

  vdppl$Run(pplID = &pplID, name = "extractBeam", ret = &pplRet);

  VPextProcessBeam(beamOE);
  
  // Close Up
  VPpdfWriteObjEnd(PDF_OBJ_BEAM);

  // Done
  retFlag = 1;
  
wrapup:

  return retFlag;
}

end implementation VDbtBase;





