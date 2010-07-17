/* $Id: VLsmsMark.I,v 1.2 2001/04/18 13:20:12 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLextMark.I
 *
 * Description: Extract Part Marking Lines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsMark.I,v $
 *      Revision 1.2  2001/04/18 13:20:12  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.2  2000/11/27  20:26:08  pinnacle
# ah
#
# Revision 1.1  2000/08/05  17:00:00  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/25/00  ah      Creation
 * 04/18/01  ah      New format for part marking features
 ***************************************************************************/

class implementation VLunwObj;

/* ------------------------------------------------------
 * Initial shot at extracting data from the unwrap object
 */
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDsa.h"

#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"

#include "vddrwattr.h"
#include "vlstructure.h"
#include "vlunwext.h"

#include "VLunwMisc.h"

#include "VDassert.h"

from ACrg_collect import ACget_named_attribute;
from ACrg_collect import AClist_attribute;

static IGRint traceFlag;

extern VDclassid OPP_VSedge3Datt_class_id;

extern VDclassid OPP_GRcurve_class_id;
extern VDclassid OPP_GR3dlinestr_class_id;
extern VDclassid OPP_GR3dtext_class_id;
extern VDclassid OPP_AScompcurve_class_id;
extern VDclassid OPP_nci_macro_class_id;

VDASSERT_FFN("loft/src/vlsms/VLsmsMark.I");

/* -----------------------------------------------
 * Need to fill up a structure for each marking line
 * Mainly so that we can do error checking when
 * the entire object is broken up
 */
#define MARK_FEET_MAX 20

typedef struct 
{

  // All marked by information
  IGRchar node_path[128];
  IGRchar node_name[128];
    
  IGRchar pcmk[128];
  IGRchar type[128];

  TGRobj_env markedByOE;
  
  IGRint isBeam;
  IGRint isPlate;

  // Labels
  TGRobj_env textOEs[MARK_FEET_MAX];
  IGRint     textOEcnt;

  // Actual marking lines 
  // Can cross holes resulting in multiple curves
  TGRobj_env punchOEs[MARK_FEET_MAX];
  IGRint     punchOEcnt;
  
  // Original list of curve component
  // Trick is to figure out which does which
  TGRobj_env curveOEs[MARK_FEET_MAX];
  IGRint     curveOEcnt;
  
  // One material direction object per mark
  TGRobj_env matlOE;

  // An optional hat for beams
  TGRobj_env hatOE;
  
  IGRchar side[32]; // Marked Side
} TVLsmsPartMarkInfo;

#define MIN_PUNCH_LEN 10.0

/* -----------------------------------------------
 * This routines purpose is to fogure out what the 
 * curveOSs are used for
 *
 * 18 Apr 2001 - In the new format, no difference between plates and beams
 * No output for marks with less than three curves
 */
IGRstat VLsmsWriteUnwrapFeaturePartMarkingCheck(TVLsmsFileInfo     *info,
						TVLsmsPartMarkInfo *mark)
{
  VDASSERT_FN("VLsmsWriteUnwrapFeaturePartMarkingCheck");
  IGRstat retFlag = 0;

  TGRbsp_curve *crv = NULL;
  IGRdouble len;
  
  IGRint i,x;
  
  TGRobj_env *punchOE;

  if (mark->curveOEcnt < 3) {
    VLsmsLog1(1,1,"### Part Marking Line %s has only %d curves, skipping it.\n",mark->pcmk,mark->curveOEcnt);
    goto wrapup;
  }
#if 0    
  // If have no curves at all then that's really bad
  if (mark->curveOEcnt == 0) {
    VLsmsLog1(1,1,"*** Part Marking Line %s has no curves at all\n",mark->pcmk);
    goto wrapup;
  }
  
  // If we have one curve that's pretty bad but allow it if its long enough
  if (mark->curveOEcnt == 1) {

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[0], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      VLsmsLog1(1,1,"*** Part Marking Line %s has only one curve\n",mark->pcmk);
      VLsmsLog1(1,1,"    And it's too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }
    
    // Use it
    mark->punchOEs[0] = mark->curveOEs[0];
    mark->punchOEcnt  = 1;
    
    VLsmsLog1(1,1,"### Part Marking Line %s has no material direction\n",mark->pcmk);
    retFlag = 1;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * For pieces with only two marks then assume material direction
   * is complety missing and both should be valid punch marks
   *
   * I really don't like this default at all but oh well
   */
  if (mark->curveOEcnt == 2) {

    // Tell the user
    VLsmsLog1(1,1,"### Part Marking Line %s has only two curves\n",mark->pcmk);

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[0], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      VLsmsLog1(1,1,"    The first is too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[1], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      VLsmsLog1(1,1,"    The second is too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }

    // Accept
    VLsmsLog1(1,1,"    Sending it with no material direction\n");
    mark->punchOEs[0] = mark->curveOEs[1];
    mark->punchOEs[1] = mark->curveOEs[0];
    mark->punchOEcnt  = 2;
    
    retFlag = 1;
    goto wrapup;
    
  }
#endif

  /* -------------------------------------------------------
   * Have at least three curves
   * Pull out the material direction and hat stuff
   */
  mark->matlOE = mark->curveOEs[0];
  mark->hatOE  = mark->curveOEs[1];
  
  /* -------------------------------------------------------
   * Cycle and as long as they meet the
   * length requirement then assume they are valid punches
   */
  if (mark->isBeam) i = 2;
  else              i = 2;
  for(; i < mark->curveOEcnt; i++) {

    punchOE = &mark->curveOEs[i];

    // Get the length
    vdgeom$Get2(objOE = punchOE, crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
    
      // Tell the user
      printf("### Part Marking Line %s has short punch line %.1f %.1f\n",
	     mark->pcmk,MIN_PUNCH_LEN,len);
    }
    else {
      if (mark->punchOEcnt < MARK_FEET_MAX) {
	mark->punchOEs[mark->punchOEcnt] = *punchOE;
	mark->punchOEcnt++;
      }
    }
  }
  
  // Make sure have at least one punch mark
  if (mark->punchOEcnt == 0) {
    VLsmsLog1(1,1,"### Part Marking Line %s has no punch marks.\n",mark->pcmk);
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * This routines purpose is to fogure out what the 
 * curveOSs are used for
 *
 * This is the old format in which plate marks did not
 * hav a hat
 */
#if 0
IGRstat VLsmsWriteUnwrapFeaturePartMarkingCheck(TVLsmsFileInfo     *info,
						TVLsmsPartMarkInfo *mark)
{
  VDASSERT_FN("VLsmsWriteUnwrapFeaturePartMarkingCheck");
  IGRstat retFlag = 0;

  TGRbsp_curve *crv = NULL;
  IGRdouble len;
  
  IGRint i,x;
  
  TGRobj_env *punchOE;
  
  // If have no curves at all then that's really bad
  if (mark->curveOEcnt == 0) {
    printf("*** Part Marking Line %s has no curves at all\n",mark->pcmk);
    goto wrapup;
  }
  
  // If we have one curve that's pretty bad but allow it if its long enough
  if (mark->curveOEcnt == 1) {

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[0], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      printf("*** Part Marking Line %s has only one curve\n",mark->pcmk);
      printf("    And it's too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }
    
    // Use it
    mark->punchOEs[0] = mark->curveOEs[0];
    mark->punchOEcnt  = 1;
    
    printf("### Part Marking Line %s has no material direction\n",mark->pcmk);
    retFlag = 1;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * For a beam with only two marks then assume material direction
   * is complety missing and both should be valid punch marks
   */
  if ((mark->curveOEcnt == 2) && (mark->isBeam)) {

    // Tell the user
    printf("### Part Marking Line %s is a beam with only two curves\n",mark->pcmk);

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[0], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      printf("    The first is too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }

    // Get the length
    vdgeom$Get2(objOE = &mark->curveOEs[1], crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
      printf("    The second is too short, min length %.1f, Actual length %.1f\n",
	     MIN_PUNCH_LEN,len);
      goto wrapup;
    }

    // Accept
    printf("    Sending it with no material direction\n");
    mark->punchOEs[0] = mark->curveOEs[1];
    mark->punchOEs[1] = mark->curveOEs[0];
    mark->punchOEcnt  = 2;
    
    retFlag = 1;
    goto wrapup;
    
  }
  
  /* -------------------------------------------------------
   * Have at least two curves for plates and three for beams
   * Pull out the material direction and hat stuff
   */
  mark->matlOE = mark->curveOEs[0];
  if (mark->isBeam) {
    mark->hatOE  = mark->curveOEs[1];
  }
  
  /* -------------------------------------------------------
   * Cycle and as long as they meet the
   * length requirement then assume they are valid punches
   */
  if (mark->isBeam) i = 2;
  else              i = 1;
  for(; i < mark->curveOEcnt; i++) {

    punchOE = &mark->curveOEs[i];

    // Get the length
    vdgeom$Get2(objOE = punchOE, crv = &crv);
    vdgeom$GetCrvArcLen(crv = crv, len = &len);
    _FREE(crv);

    // Check it
    if (len < MIN_PUNCH_LEN) {
    
      // Tell the user
      printf("### Part Marking Line %s has short punch line %.1f %.1f\n",
	     mark->pcmk,MIN_PUNCH_LEN,len);
    }
    else {
      if (mark->punchOEcnt < MARK_FEET_MAX) {
	mark->punchOEs[mark->punchOEcnt] = *punchOE;
	mark->punchOEcnt++;
      }
    }
  }
  
  // Make sure have at least one punch mark
  if (mark->punchOEcnt == 0) {
    printf("### Part Marking Line %s has no punch marks.\n",mark->pcmk);
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
#endif

/* -----------------------------------------------
 * Writes a single structure out
 * After doing some last error checking
 */
IGRstat VLsmsWriteUnwrapFeaturePartMarkingOne(TVLsmsFileInfo     *info,
					      TVLsmsPartMarkInfo *mark)
{
  VDASSERT_FN("VLsmsWriteUnwrapFeaturePartMarkingOne");
  
  IGRstat retFlag = 0;
  
  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;

  IGRchar buf[256];
  IGRint  i;
  
  // Init
  xml = &info->cvg.xml;
  cvg = &info->cvg;
  
  // No material direction is ok ???
  if (mark->matlOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"### No material direction %s\n",mark->pcmk);
  }
  
  // No punch lines are not
  if (mark->punchOEcnt == 0) {
    VLsmsLog1(1,1,"### No punch marks %s\n",mark->pcmk);
    goto wrapup;
  }

  // No text???
  if (mark->textOEcnt == 0) {
    VLsmsLog1(1,1,"### No text %s\n",mark->pcmk);
    // goto wrapup;
  }

  // Unknown piece mark???

  // Do it
  VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
  VDxmlWriteAtrTxt(xml,
		   XML_SMS_MARKING_TYPE,
		   XML_SMS_MARKING_TYPE_PART,0,0);

  // Side goes in the marking object
  VDxmlWriteAtrTxt(xml,XML_SMS_MARKING_MARKED_SIDE,mark->side,0,0);
  VDxmlWriteAtrEnd(xml,0,1);

  // Part information
  VDxmlWriteObjBeg(xml,XML_SMS_MARKING_PART_INFO,1,0);

  // Build composite marked by info
  sprintf(buf,"%s,%s,%s,%s",
	  mark->type,
	  mark->pcmk,
	  mark->node_name,
	  mark->node_path);
    
  VDxmlWriteAtrTxt(xml,XML_SMS_MARKING_PART_INFO_MARKED_BY,buf,0,0);
  
  // Done with part info
  VDxmlWriteAtrEnd(xml,0,1);
  VDxmlWriteObjEnd(xml,XML_SMS_MARKING_PART_INFO,1);

  // Wrap in edge
  VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);

  // Write out labels (backwards to maintain compatibility)
  for(i = mark->textOEcnt - 1; i >= 0; i--) {    
    VDcvgWriteObject(cvg,&mark->textOEs[i]);
  }
  
  // Write out punch marks backwards to maintain compatibility
  for(i = mark->punchOEcnt-1; i >= 0; i--) {

    VDxmlWriteObjBeg(xml,XML_SMS_MARKING_PART_INFO_CURVE_ACTUAL,0,1);
    VDcvgWriteObject(cvg,&mark->punchOEs[i]);
    VDxmlWriteObjEnd(xml,XML_SMS_MARKING_PART_INFO_CURVE_ACTUAL,1);
   
  }

  // Note: Must write hat before material for backwards compatibility

  // Hat if we have one
  if (mark->hatOE.obj_id.objid != NULL_OBJID) {
    VDxmlWriteObjBeg(xml,XML_SMS_MARKING_PART_INFO_CURVE_HAT,0,1);
    VDcvgWriteObject(cvg,&mark->hatOE);
    VDxmlWriteObjEnd(xml,XML_SMS_MARKING_PART_INFO_CURVE_HAT,1);
  }
  
  // Material if we have one
  if (mark->matlOE.obj_id.objid != NULL_OBJID) {
    VDxmlWriteObjBeg(xml,XML_SMS_MARKING_PART_INFO_CURVE_MTL_DIR,0,1);
    VDcvgWriteObject(cvg,&mark->matlOE);
    VDxmlWriteObjEnd(xml,XML_SMS_MARKING_PART_INFO_CURVE_MTL_DIR,1);
  }
  
  // Done
  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
  VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out marking line feature
 *
 * Return true if it's a marking line
 *
 * This routines main job is to fill up the partMarkInfo structure
 *
 * Skips marking lines if the actual line is < 1 mm
 * This usually indicates a problem with the marking line
 * itself, skip it to prevent spades crashing
 *
 * Another anomaly that should be dealt with sometime is that
 * sometimes that same marking line is attached to the unwrap twice
 * via two different features.
 *
 * The VLmrkLine is sometimes used for generic marking
 * without attaching the parent doing the marking, deal with it
 */
IGRstat VLsmsWriteUnwrapFeaturePartMarking(TVLsmsFileInfo *info,
					   TGRobj_env     *unwrapOE, 
					   TGRobj_env     *featureOE,
					   TGRobj_env     *markOE,
					   TGRobj_env     *drwOE)
{
  VDASSERT_FN("VLsmsWriteUnwrapFeaturePartMarking");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  // All the real data
  TVLsmsPartMarkInfo mark;

  // Components
  TGRobj_env footOE;
  IGRint     i;
  
  // Side to mark
  TGRid      collID;  
  TACrg_coll sideOfPlate;
  IGRint     flag;
  
  
  // Say hi later
  traceFlag = traceFlagx;
  
  // Arg Check
  if (unwrapOE  == NULL) goto wrapup;
  if (info      == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  if (markOE    == NULL) goto wrapup;
  if (drwOE     == NULL) goto wrapup;
  
  // Init
  memset(&mark,0,sizeof(TVLsmsPartMarkInfo));
  mark.matlOE.obj_id.objid = NULL_OBJID;
  mark.hatOE.obj_id.objid  = NULL_OBJID;
  
  // See if its a marking line
  sts = vdobj$IsAncestryValid(objOE = markOE, 
			      superClassName = "VLmrkLine");
  if (!(sts & 1)) goto wrapup;

  // Regardless of errors, it's been processed
  retFlag = 1;

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    vdobj$Print(objOE = featureOE);
    vdobj$Print(objOE = markOE);
  }

  // Find out who marked it, filter some markings
  vdobj$GetTemplate(objOE      = markOE,
		    nth        = 2,
		    templateOE = &mark.markedByOE);

  // Pull info
  if (mark.markedByOE.obj_id.objid != NULL_OBJID) {

    vdsa$Get(objOE = &mark.markedByOE, 
	     name  = "SA_AST:StagingTree:0:node_path",
	     txt   = mark.node_path);

    vdsa$Get(objOE = &mark.markedByOE, 
	     name  = "SA_AST:StagingTree:0:node_name",
	     txt   = mark.node_name);

    vdsa$Get(objOE = &mark.markedByOE, 
	     name  = "SA_AST:StagingTree:0:pcmk",
	     txt   = mark.pcmk);

    sts = vdobj$IsAncestryValid(objOE = &mark.markedByOE, superClassName = "VSplate");
    if (sts & 1) {
      strcpy(mark.type,"PLATE");
      mark.isPlate = 1;
    }
    
    sts = vdobj$IsAncestryValid(objOE = &mark.markedByOE, superClassName = "VSbeam");
    if (sts & 1) {
      strcpy(mark.type,"BEAM");
      mark.isBeam = 1;
    }  
  }

  if (traceFlag) {
    printf("Marked by %s %s\n",mark.pcmk,mark.type);
  }

  /* --------------------------------------------------------
   * So all part marks for which we cannot get the marking
   * parent will be sent as just dumb labels for now
   */
  // If not marked by either plate or beam, treat as dumb mark
  if (*mark.type == 0) {
    retFlag = 0;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * Any plates whose name starts with co gets
   * skipped during the extraction process
   */
  // Skips the collars
  if ((strlen(mark.node_name) > 2) && (!strncmp(mark.node_name,"co",2))) {
    if (traceFlag) printf("Skipping collar\n");
    retFlag = 1;
    goto wrapup;
  }
  
  // Need at least two graphical drawing components
  footOE.mod_env = featureOE->mod_env;
  for(i = 0;
      vdchn$Get2(objOE  = drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {

    // Is it a curve
    sts = vdobj$IsAncestryValid(objOE = &footOE,
				superClassID = OPP_GRcurve_class_id);
    if (sts & 1) {
      if (mark.curveOEcnt < MARK_FEET_MAX) {
	mark.curveOEs[mark.curveOEcnt] = footOE;
	mark.curveOEcnt++;
      }
    }

    // Is it text
    sts = vdobj$IsAncestryValid(objOE = &footOE,
				superClassID = OPP_GR3dtext_class_id);
    if (sts & 1) {

      /* -----------------------------------------
       * Could suppress some text here for spades
       * but do it during the conversion if possible
       */
      if (mark.textOEcnt < MARK_FEET_MAX) {
	mark.textOEs[mark.textOEcnt] = footOE;
	mark.textOEcnt++;
      }
    }

  }

  // Need to know which side is being marked
  vdchn$Get2(objOE  = markOE,
	     chnIDx = VDCHN_IDX_PARENT,
	     nth    = 0,
	     outID  = &collID);

  strcpy(sideOfPlate.name,"PlateBotOrTop");
  
  om$send(msg = message ACrg_collect.ACget_named_attribute(&msg,&sideOfPlate),
	  senderid = NULL_OBJID,
	  targetid = collID.objid,
	  targetos = collID.osnum);
  
  flag = sideOfPlate.desc.value.att_exp;
  if (traceFlag) {  
    printf("Side Of Plate %19.8f %d %d\n",
	   sideOfPlate.desc.value.att_exp,
	   flag,
	   info->presentOffset);
  }
  
  /* --------------------------------------
     side  present  flag
     near  offset   offset
     near  base     base
     far   offset   base
     far   base     offset
   */

  // Setup material side
  if (info->presentOffset) {
    if (flag) strcpy(mark.side,XML_SMS_MARKING_MARKED_SIDE_NEAR);
    else      strcpy(mark.side,XML_SMS_MARKING_MARKED_SIDE_FAR);
  }
  else {
    if (flag) strcpy(mark.side,XML_SMS_MARKING_MARKED_SIDE_FAR);
    else      strcpy(mark.side,XML_SMS_MARKING_MARKED_SIDE_NEAR);
  }
 
  // Now figure out what the component curves do
  sts = VLsmsWriteUnwrapFeaturePartMarkingCheck(info,&mark);
  if (!(sts & 1)) goto wrapup;
  
  // The actual xml writing
  VLsmsWriteUnwrapFeaturePartMarkingOne(info,&mark);

wrapup:
  
  if (traceFlag && retFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

end implementation VLunwObj;
