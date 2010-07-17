
class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDmac.h"
#include "VDgeom.h"

#include "VPpdf.h"
#include "VPextInfo.h"

#include "bsdistptpt.h"
#include "bststcvcarc.h"

from ACrg_collect import ACget_named_attribute;
from GRcurve      import GRendpts;
from GRconic      import GRgetarc;

extern GRclassid OPP_ACpretend_class_id;
extern GRclassid OPP_ACconst_class_id;
extern GRclassid OPP_GR3dcircle_class_id;
extern GRclassid OPP_GR3dcirarc_class_id;
extern GRclassid OPP_AScircnt_class_id;

/* --------------------------------------------------
 * A half oval has three flat sides with an arc on the fourth
 * 
 * Need to put out origin, magor axis and minor axis points.
 * Treat as a regular oval for now since these are only used in edge
 * cutouts (I Hope!)
 *
 *
 *          -------Par1--------
 *         <                   |
 *        <                    |
 *       Par2                  |
 *        <                    |
 *         <                   |
 *          -------Par3--------
 *
 * The same code as a regular oval but break out here for now in case
 * need to enhance later
 */

static int traceFlag;

/* --------------------------------------------------
 * Put out oval hole
 */
IGRstar VPextProcessPlateHoleHalfOval(IGRchar *macName, TGRbsp_curve *crvBsp)
{
  IGRstat retFlag = 0;

  TGRoval oval;
  
  IGRpoint  ptx;
  IGRdouble par1,par2,par3;
  
  //printf(">>> VPextProcessPlateHoleHalfOval %s\n",macName);
  //vdgeom$Print(crv = crvBsp);
  
  // Put through some tests for "standard oval"
  if (crvBsp->order     !=  3) goto wrapup;
  if (crvBsp->rational  ==  0) goto wrapup;

  // Hardcode 
  switch(crvBsp->num_poles){

  case 11: 
    par1 = .125;
    par2 = .375;
    par3 = .625;
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

  if (traceFlag | 0) {
  printf("Oval   %s, %d\n",macName,crvBsp->num_poles);
  printf("AXMA1 %.3f %10.3f,%9.3f,%9.3f\n",par1,oval.axis1 [0],oval.axis1 [1],oval.axis1 [2]);
  printf("AXMI2 %.3f %10.3f,%9.3f,%9.3f\n",par2,oval.axis2 [0],oval.axis2 [1],oval.axis2 [2]);
  printf("ORG    %4s %10.3f,%9.3f,%9.3f\n","  ",oval.origin[0],oval.origin[1],oval.origin[2]);
  printf("PTX   %.3f %10.3f,%9.3f,%9.3f\n",par3,ptx[0],ptx[1],ptx[2]);
  printf("\n");
  }
  
  // Flag it
  oval.flat = 1;
  
  // write it out
  VPpdfWriteBspOval(PDF_ATR_HOLE_CURVE,&oval);  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Only certain types of oval are initially support
 * Any 3rd order, rational curve is assumed to be a flettened oval.
 * 
 * Need to put out origin, magor axis and minor axis points.
 *
 * The parameter values of these points is based on the number of poles in the oval
 * I guess there is at least two ways to make an oval.
 *  
 * This is perhaps not the best way to find and translate ovals but it works for now
 * Eventually want a list of all supported oval curves
 *
 *          -------Par1--------
 *         <                   >
 *        <                     >
 *       Par2                    >
 *        <                     >
 *         <                   >
 *          -------Par3--------
 */

/* --------------------------------------------------
 * Put out oval hole
 */
IGRstar VPextProcessPlateHoleOval(IGRchar *macName, TGRbsp_curve *crvBsp)
{
  IGRstat retFlag = 0;

  TGRoval oval;
  
  IGRpoint  ptx;
  IGRdouble par1,par2,par3;
  
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
  printf("Oval   %s, %d\n",macName,crvBsp->num_poles);
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
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Put out circle
 */
IGRstar VPextProcessPlateHoleCircle(IGRchar *macName, TGRbsp_curve *crvBsp)
{
  IGRstat retFlag = 0;
  IGRshort  arcFlag;
    
  TGRcir_arc  arc;
  BSrc   rc;
  
  if (traceFlag) {
    printf(">>> VPextProcessPlateHoleCircle %s\n",macName);
    vdgeom$Print(crv = crvBsp);
  }

  // Check based on order
#if 0
  if ((crvBsp->order == 3) && (crvBsp->rational)) {
    if ((crvBsp->num_poles == 3) || (crvBsp->num_poles == 7)) {

      // Must be a circle
      BStstcvcarc(crvBsp,&arcFlag,arc.center,&arc.radius,&rc);
      VPpdfWriteBspCirArc(PDF_ATR_HOLE_CURVE,&arc);  
      retFlag = 1;
      goto wrapup;

    }
  }
#endif

  // Heavier duty processing with tolerance
  arcFlag = VDgeomIsCirArc(crvBsp,arc.center,&arc.radius);
  if (arcFlag == 0) {
    goto wrapup;
  }

  if (traceFlag | 0) {
    printf("Got an arc\n");
    vdgeom$Print(crv = crvBsp);
  }

  VPpdfWriteBspCirArc(PDF_ATR_HOLE_CURVE,&arc);  
  
  retFlag = 1;
  
wrapup:
  
  if (traceFlag) {
    printf("@@@ VPextProcessPlateHoleCircle\n");
  }
  
  return retFlag;
}

/* -----------------------------------------------------
 * Extract one candidate macro object
 */
IGRstar VPextWritePlateHole(TVPextPlateInfo *plateInfo, 
			    TGRobj_env      *plateOE, 
			    TGRid           *parentID)
{
  IGRstat retFlag = 0;  
  IGRstat sts;
  
  IGRchar macName[64];
  TGRid   macID;

  TGRobj_env    crvOE;
  TGRbsp_curve *crvBsp = NULL;
    
  IGRint flag;
  
  // Init
  *macName = 0;
  macID.objid        = NULL_OBJID;
  crvOE.obj_id.objid = NULL_OBJID;
  if (plateOE);

  // For now, only deal with pretend until get more test cases
  sts = vdobj$IsAncestryValid(objID = parentID, 
                              superClassID = OPP_ACpretend_class_id);
  if (!(sts & 1)) {

    // Paramertic circle used sometimes
    sts = vdobj$IsAncestryValid(objID = parentID, 
				superClassID = OPP_AScircnt_class_id);
    if (!(sts & 1)) goto wrapup;
    strcpy(macName,"AScircnt");
    goto get_cutting_curve;
  }
  
  // Get the parent macro object
  vdchn$Get2(objID  = parentID, 
	     chnIDx = VDCHN_IDX_PARENT, 
	     nth    = 0, 
	     outID  = &macID);

  // Only deal with ACconst for now
  sts = vdobj$IsAncestryValid(objID = &macID, 
                              superClassID = OPP_ACconst_class_id);
  if (!(sts & 1)) goto wrapup;
  
  // Filter our struct elements to get rid of marking lines parents

  // Go based on name
  vdobj$Get(objID = &macID, macName = macName);
  
  flag = 0;
  if (!strcmp(macName,"round4_av")) flag = 1;
  if (!strcmp(macName,"osmulti"))   flag = 1;
  // if (flag == 0) goto wrapup;
  
  // Unsource the cutting curve itself
get_cutting_curve:
  VDahGetObjectEnv(parentID,&crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  // vdobj$Print(objOE = &crvOE);
  
  // Get the geomotry
  vdgeom$Get2(objOE = &crvOE, crv = &crvBsp);
  if (crvBsp == NULL) {
    goto wrapup;
  }
  
  VPpdfWriteObjBeg  (PDF_OBJ_HOLE);
  VPpdfWriteAttrText(PDF_ATR_HOLE_TYPE,macName);

  sts = VPextProcessPlateHoleCircle(macName,crvBsp);
  if (sts & 1) goto finished_hole;

  sts = VPextProcessPlateHoleOval(macName,crvBsp);
  if (sts & 1) goto finished_hole;

  sts = VPextProcessPlateHoleHalfOval(macName,crvBsp);
  if (sts & 1) goto finished_hole;
  
  printf("********* Unprocessed Macro %s ***************\n",macName);
  vdobj$Print(objID = &macID);
  vdgeom$Print(crv = crvBsp);
  
finished_hole:
  VPpdfWriteObjEnd  (PDF_OBJ_HOLE);
  
  if (plateInfo->holes.cnt < VP_EXT_INFO_MAX) {
    
    TVPextHoleInfo *info = &plateInfo->holes.info[plateInfo->holes.cnt];
    
    strcpy(info->macName,macName);
    plateInfo->holes.cnt++;
    
  }
    
  retFlag = 1;
  
wrapup:

  if (retFlag != 1) {
    printf("************* HOLE ***** %s ***************\n",macName);
     vdobj$Print(objID =  parentID);
     vdobj$Print(objID = &macID);
     vdobj$Print(objOE = &crvOE);
     vdgeom$Print(crv = crvBsp);
  }
  if (crvBsp) free(crvBsp);
  
  return retFlag;
}

/* -----------------------------------------------------
 * Given a tree of plates, find all holes and cutouts
 * Assume all cutouts have been processed in order to
 * get dumb curve type operations
 */
IGRstar VPextWritePlateHoles(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  
  IGRint i,j;

  TVPextPlates *plates = &plateInfo->plates;

  IGRint cnt;

  TGRobj_env plateOE;
  TGRid      parentID;
    
  // Process each plate in tree except top source
  cnt = plates->cnt - 1;
  for(i = 0; i < cnt; i++) {

    plateOE = plates->plateOEs[i];

    // Look on parent channel, first parent is a plate so ignore it
    for(j = 1; 
	vdchn$Get2(objOE  = &plateOE, 
		   chnIDx = VDCHN_IDX_PARENT, 
		   nth    = j, 
		   outID  = &parentID);
	j++) {
  
      VPextWritePlateHole(plateInfo,&plateOE,&parentID);
      
    }
  }
  
  retFlag = 1;

  return retFlag;
}

end implementation VDbtBase;



