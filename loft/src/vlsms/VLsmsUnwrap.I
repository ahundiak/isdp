/* $Id: VLsmsUnwrap.I,v 1.13 2002/06/13 19:05:30 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLextUnwrap.I
 *
 * Description: Extract Unwrap For Production
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsUnwrap.I,v $
 *      Revision 1.13  2002/06/13 19:05:30  ahundiak
 *      ah
 *
 *      Revision 1.12  2001/10/26 20:16:00  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/09/06 14:41:30  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/06/27 15:34:43  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/06/15 13:58:07  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/06/08 20:50:03  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/06/07 21:00:38  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/06/06 15:54:15  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/05/21 13:02:30  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/05/11 13:07:15  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/19 14:22:05  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.15  2000/12/19  13:40:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/25/00  ah      Creation
 * 05/11/01  ah      TR5205 Need to send new auto labels
 * 06/13/02  ah      Treat VA_Bevel as a makring line
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

from ACrg_collect import ACget_named_attribute;
from ACrg_collect import AClist_attribute;

static IGRint traceFlag;

extern VDclassid OPP_VSedge3Datt_class_id;

extern VDclassid OPP_GRcurve_class_id;
extern VDclassid OPP_GR3dlinestr_class_id;
extern VDclassid OPP_GR3dtext_class_id;
extern VDclassid OPP_AScompcurve_class_id;
extern VDclassid OPP_nci_macro_class_id;

/* -----------------------------------------------
 * Certain layers and colors are needed to process
 * features, need to add these to the setup file
 * sometime
 */
#define NC_COLOR    25
#define SEND_LAYER 400
#define SKIP_LAYER 405

/* -------------------------------------------------------------------
 * For a given unwrap. find the transformation as well as scale
 * The scale is not currently used, it was an early attempt to use
 * the svg format
 */
IGRstat VLsmsGetUnwrapRangeScale(TVLsmsFileInfo *info, TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env rectOE;
  GRrange    range;
  
  IGRboolean world = TRUE;
  
  IGRdouble dx,dy;
  IGRdouble bx,by,b; // Border
  IGRdouble sx,sy,s;
  
  // Arg check
  if (info == NULL) goto wrapup;
  info->r1[2] = 0.0;
  info->r2[2] = 0.0;
  info->scale = 1.0;
  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Work from min rect since the overridden GRgetrang does not work
  VLunwGetMinRectangle(unwrapOE,&rectOE);
  if (rectOE.obj_id.objid == NULL_OBJID) {
    printf("Problem getting min rectangle for\n");
    vdobj$Print(objOE = unwrapOE);
    goto wrapup;
  }
  
  // Get the range
  sts = om$send(msg = message VLunwObj.
		GRgetrang(&msg,
			  &rectOE.mod_env.md_env.matrix_type,
			   rectOE.mod_env.md_env.matrix,
			  &world,
			   range),
		senderid = NULL_OBJID,
		targetid = rectOE.obj_id.objid,
		targetos = rectOE.obj_id.osnum);
  if (!(sts & msg & 1)) {
    printf("Problem getting range for\n");
    vdobj$Print(objOE = unwrapOE);
    vdobj$Print(objOE = &rectOE);
  }

  // Find deltas
  dx = fabs(range[3] - range[0]);
  dy = fabs(range[4] - range[1]);

  bx = dx * .1;
  by = dy * .1;

  if (bx < by) b = bx;
  else         b = by;
  
  dx = dx * 1.1;
  dy = dy * 1.1;

  // Round to nearest meter
  dx = (int)(dx + 500.0);
  dy = (int)(dx + 500.0);

  // Add a 10% border and round to nearest meter for translation
#if 0
  if (range[0] >= 0.0) r1[0] =  range[0] - b;
  else                 r1[0] =  range[0] + b;
  if (range[1] >= 0.0) r1[1] =  range[1] - b;
  else                 r1[1] =  range[1] + b;

  if (range[3] >= 0.0) r2[0] =  1.1 * range[3];
  else                 r2[0] =  0.9 * range[3];
  if (range[4] >= 0.0) r2[1] =  1.1 * range[4];
  else                 r2[1] =  0.9 * range[4];
#endif
  //b = 0;
  info->r1[0] = range[0] - b;
  info->r1[1] = range[1] - b;
  info->r1[2] = range[2];
  info->r2[0] = range[3] + b;
  info->r2[1] = range[4] + b;
  info->r2[2] = range[5];

  // Not sure what I was doing with the dx/dy above so start over
  dx = fabs(range[3] - range[0]);
  dy = fabs(range[4] - range[1]);
  
  sx = 600.0 / dx;
  sy = 600.0 / dy;
  if (sx < sy) s = sx;
  else         s = sy;

  // Round down to nearest .01
  s = ((int)(s*100.0))/100.0;
  if (s < .01) s = .01;
  
  // Hardcode the scale for now
  info->scale = .25;
  info->scale = s;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -------------------------------------
 * Extracts master plate attributes
 */
IGRstat VLsmsWriteUnwrapAttributes(TVLsmsFileInfo *info,
				   TGRobj_env     *unwrapOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env plateOE;

  IGRdouble  side;
  IGRint     flag;
  
  IGRdouble thickness;
  IGRchar   material[32];
  IGRchar   grade[32];
  IGRchar   unit [32];
  IGRchar   pcmk [32];
  IGRchar   buf [128];
  IGRint    pcmki;

  struct {
    IGRchar nodeType[128];
    IGRchar nodeName[128];
    IGRchar stage[128];
  } parent;

  IGRint len;
  
  IGRchar  name  [128];
  IGRchar  family[128];
  IGRchar  part  [128];
  
  TVDxmlFileInfo *xml = NULL;

  IGRshort  trfType;
  IGRdouble trfMat[16];
  GRrange   range;
  
  // Arg Check
  if (unwrapOE == NULL) goto wrapup;
  if (info     == NULL) goto wrapup;
  xml = &info->cvg.xml;
  
  // Get the plate
  VLunwGetPlateForUnwrap(unwrapOE,NULL,&plateOE);  
  if (plateOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"Unable to get plate for unwrap\n");
  }

  // Do the plate attributes
  vdsa$Get(objOE = &plateOE, name = "plate_thk", dbl = &thickness);
  VDxmlWriteAtrDbl(xml,XML_SMS_PLATE_THICKNESS,thickness,1,1);

  // Determine which side is being presented
  VLunwGetUnwrapAttribute(&unwrapOE->obj_id,"Side to Unwrap",NULL,&side);
  
  info->presentOffset = 0;
  flag = side;
  strcpy(buf,XML_SMS_PLATE_NEAR_SIDE_MOLDED);
  
  if ((flag == 1) || (flag == 3)) {
    info->presentOffset = 1;
    strcpy(buf,XML_SMS_PLATE_NEAR_SIDE_OFFSET);
  }
  VDxmlWriteAtrTxt(xml,XML_SMS_PLATE_NEAR_SIDE,buf,1,1);

  // Done with plate attributes
  VDxmlWriteAtrEnd(xml,1,1);
  
  // Start the part information object
  VDxmlWriteObjBeg(xml,XML_SMS_PART_INFO,1,1);
  
  //pt[0] =(file->r1[0] + file->r2[0] ) * .5;
  vdsa$Get(objOE = &plateOE, name = "SA_AST:StagingTree:UNIT:node_name",txt = unit);
  vdsa$Get(objOE = &plateOE, name = "SA_AST:StagingTree:PM:pcmk",       txt = pcmk);
  // printf("Unit %s, Pcmk %s\n",unit,pcmk);
  
  if (*unit == 0) strcpy(unit,"0000");
  if (*pcmk == 0) strcpy(pcmk,"000");
  else {
    pcmki = atoi(pcmk);
    sprintf(pcmk,"%03u",pcmki);
  }
  sprintf(buf,"LP17A-%s-%s",unit,pcmk);

  VDxmlWriteAtrTxt(xml,XML_SMS_PART_INFO_PART_NUM,buf,1,1);

  // Status
  VLsmsLog2(0,1,NULL,&plateOE,NULL);
  VLsmsLog1(0,1,"%s\n",buf);
  
  // Misc info mainly for spades
  vdsa$Get(objOE = &plateOE, name = "memb_name",   txt = name);
  vdsa$Get(objOE = &plateOE, name = "family_name", txt = family);
  vdsa$Get(objOE = &plateOE, name = "part_num",    txt = part);
  sprintf(buf,"%s:%s:%s",family,part,name);
  VDxmlWriteAtrTxt(xml,XML_SMS_PART_INFO_PART_NAME,buf,1,1);
  
  // Material string
  vdsa$Get(objOE = &plateOE, name = "grade",     txt = grade);
  vdsa$Get(objOE = &plateOE, name = "material",  txt = material);

  VDxmlWriteAtrTxt(xml,XML_SMS_PART_INFO_MATERIAL_TYPE, material, 1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_PART_INFO_MATERIAL_GRADE,grade,    1,1);

  // Detect collars
  if ((strlen(name) > 2) && (!strncmp(name,"co",2))) {
    VDxmlWriteAtrTxt(xml,
		     XML_SMS_PART_INFO_PROD_TYPE,
		     XML_SMS_PART_INFO_PROD_TYPE_COLLAR,
		     1,1);
  }
  
  // Done with attributes
  VDxmlWriteAtrEnd(xml,1,1);

  // Special spades 3d information
  VLsmsWritePlatePdfStuff(info,unwrapOE,&plateOE);
  
  // Range Points
  VLunw2GetRange(unwrapOE,range);
  VDxmlWriteObjBeg(xml,XML_CVG_RANGE,1,1);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_X1,range[0],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_Y1,range[1],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_Z1,range[2],0,1);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_X2,range[3],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_Y2,range[4],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_RANGE_Z2,range[5],0,1);
  VDxmlWriteAtrEnd(xml,1,1);
  VDxmlWriteObjEnd(xml,XML_CVG_RANGE,1);

  // Store 2d to 3d transformation matrix
  VLunw2GetMatrix(unwrapOE,NULL,trfMat);  
  VDxmlWriteObjBeg(xml,XML_CVG_MATRIX_4X3,1,1);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I00,trfMat[ 0],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I01,trfMat[ 1],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I02,trfMat[ 2],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I03,trfMat[ 3],0,1);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I10,trfMat[ 4],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I11,trfMat[ 5],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I12,trfMat[ 6],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I13,trfMat[ 7],0,1);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I20,trfMat[ 8],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I21,trfMat[ 9],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I22,trfMat[10],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_MATRIX_I23,trfMat[11],0,1);
  VDxmlWriteAtrEnd(xml,1,1);
  VDxmlWriteObjEnd(xml,XML_CVG_MATRIX_4X3,1);

  /* ---------------------------------------------
   * For completness, really should put out the points
   * used to generate the transformation matrix
   */

  // Need assembly information
  memset(&parent,0,sizeof(parent));
  vdsa$Get(objOE = &plateOE, name = "SA_AST:StagingTree:1:node_type",txt = parent.nodeType);
  vdsa$Get(objOE = &plateOE, name = "SA_AST:StagingTree:1:node_name",txt = parent.nodeName);

  // Basically copied from processNode in the extraction ppl
  // Need to wrap properly, , given type and name, produce stage, keep exact for spades
  // Split type and name for sa stuff
  if ((!strncmp(parent.nodeType,"SA",2)) && (strlen(parent.nodeType) == 3)) {
    strcpy(parent.nodeName,parent.nodeType+2);
    *(parent.nodeType+2) = 0;
  }
  // Format psu a bit special
  if (!strcmp(parent.nodeType,"PSU")) {
    len = strlen(parent.nodeName);
    if (len < 3) {
      strcpy(buf,"000");
      strcpy(buf + (3 - len),parent.nodeName);
      strcpy(parent.nodeName,buf);
    }
  }
  // Build the stage
  if (*parent.nodeType == 0) {
    strcpy(parent.stage,"UNIT MD01");
  }
  else {
    if (*parent.nodeName == 0) strcpy(parent.stage,parent.nodeType);
    else sprintf(parent.stage,"%s %s",parent.nodeType,parent.nodeName);
  }

  VDxmlWriteObjBeg(xml,XML_SMS_PROD_INFO,1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_PROD_INFO_HULL,    "lpd17a",      1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_PROD_INFO_BLOCK,    unit,         1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_PROD_INFO_ASSEMBLY, parent.stage, 1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_PROD_INFO_PCMK,     pcmk,         1,1);
  VDxmlWriteAtrInt(xml,XML_SMS_PROD_INFO_QTY,      1,            1,1);

  VDxmlWriteAtrEnd(xml,1,1);
  VDxmlWriteObjEnd(xml,XML_SMS_PROD_INFO,1);

  // Part information is done
  VDxmlWriteObjEnd(xml,XML_SMS_PART_INFO,1);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Tangent lines placed with the PartMark macro
 * Not to be confused with VLmrkLine used for part marking
 */
IGRstat VLsmsWriteUnwrapFeatureTangent(TVLsmsFileInfo *info,
				       TGRobj_env     *unwrapOE, 
				       TGRobj_env     *featureOE,
				       TGRobj_env     *markOE,
				       TGRobj_env     *drwOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapFeatureTangent";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;


  IGRint traceFlagx;
  TVDxmlFileInfo *xml;

  IGRchar macName[128],*p;
  TGRid   macID;
  
  TGRobj_env footOE;
  IGRint     i;
  
  // Say hi later
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  
  // Arg Check
  if (info      == NULL) goto wrapup;
  if (unwrapOE  == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  if (markOE    == NULL) goto wrapup;
  if (drwOE     == NULL) goto wrapup;
  
  xml = &info->cvg.xml;
  
  // See if its a nci_macro bevel
  vdobj$Get(objOE = markOE, macName = macName);
  if (strcmp(macName,"PartMark")) goto wrapup;
  
  // Want to get it's geom generating macro (and not the foot)
  vdobj$GetParent(objOE = markOE, idx=1, parentID = &macID);

  // See if it's a tangent macro
  vdobj$Get(objID = &macID, macName = macName);
  p = strstr(macName,"tan");
  if (p == NULL) goto wrapup;
  
  // Regardless of what happens, it has been processed
  retFlag = 1;

  /* -------------------------------------------------
   * To date the tanget macro text appears to be *****
   * Don't know if this is by design or not
   *
   * Fixed this in PartMacro
   */

  // Dump tangent feature
  VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
  VDxmlWriteAtrTxt(xml,
		   XML_SMS_MARKING_TYPE,
		   XML_SMS_MARKING_TYPE_TANGENT,0,0);
  VDxmlWriteAtrEnd(xml,0,1);
  
  // Wrap in edge
  VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);
  
  // Write out each component
  footOE.mod_env = featureOE->mod_env;
  for(i = 0;
      vdchn$Get2(objOE  = drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {
    VDcvgWriteObject(&info->cvg,&footOE);
  }
    
  // Done
  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
  VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * VA_Bevels get their own processing
 */
IGRstat VLsmsWriteUnwrapFeatureVABevel(TVLsmsFileInfo *info,
				       TGRobj_env     *unwrapOE, 
				       TGRobj_env     *featureOE,
				       TGRobj_env     *markOE,
				       TGRobj_env     *drwOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapFeatureVABevel";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;


  IGRint traceFlagx;
  TVDxmlFileInfo *xml;

  IGRchar macName[128],*p;
  TGRid   macID;
  
  TGRobj_env footOE;
  IGRint     i;
  
  // Say hi later
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  
  // Arg Check
  if (info      == NULL) goto wrapup;
  if (unwrapOE  == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  if (markOE    == NULL) goto wrapup;
  if (drwOE     == NULL) goto wrapup;
  
  xml = &info->cvg.xml;
  
  // See if its a nci_macro bevel
  vdobj$Get(objOE = markOE, macName = macName);
  if (strcmp(macName,"VA_Bevel")) goto wrapup;
  
  // Regardless of what happens, it has been processed
  retFlag = 1;

  // Dump va feature
  VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
  VDxmlWriteAtrTxt(xml,
		   XML_SMS_MARKING_TYPE,
		   XML_SMS_MARKING_TYPE_REF,0,0);
#if 0
  VDxmlWriteAtrTxt(xml,
                   XML_SMS_MARKING_MARKED_SIDE,
                   XML_SMS_MARKING_MARKED_SIDE_FAR,0,0); 
#endif
  VDxmlWriteAtrEnd(xml,0,1);
  
  // Wrap in edge
  VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);
  
  // Write out each component
  footOE.mod_env = featureOE->mod_env;
  for(i = 0;
      vdchn$Get2(objOE  = drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {

      sts = vdobj$IsAncestryValid(objOE = &footOE,
				  superClassID = OPP_GR3dtext_class_id);
      if (sts & 1) {
        VDcvgWriteTextObjectTextHack(&info->cvg,&footOE,"VAR_BEV FS");
      }
      else {
        VDcvgWriteObject(&info->cvg,&footOE);
      }
  }
    
  // Done
  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
  VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a feature bevel
 */
IGRstat VLsmsWriteUnwrapFeatureBevel(TVLsmsFileInfo *info,
				     TGRobj_env     *unwrapOE, 
				     TGRobj_env     *featureOE,
				     TGRobj_env     *bevelOE,
				     TGRobj_env     *drwOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapFeatureBevel";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRint traceFlagx;
  TVDxmlFileInfo *xml;
  
  TVLunwBevelInfo bevel;
  
  IGRchar   value[128];
  
  IGRint i;
  TGRobj_env footOE;
  
  // Say hi later
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  
  // Arg Check
  if (info      == NULL) goto wrapup;
  if (unwrapOE  == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  if (bevelOE   == NULL) goto wrapup;
  if (drwOE     == NULL) goto wrapup;
  
  xml = &info->cvg.xml;
  
  // See if its a nci_macro bevel
  sts = VLunwIsBevel(bevelOE,NULL);
  if (!(sts & 1)) goto wrapup;

  // Always skip
  retFlag = 1;

  // Look for bevels with spec and stock
  VLunwGetBevelInfo(&unwrapOE->obj_id,&bevelOE->obj_id,&bevel);
  if (*bevel.spec  == 0) goto wrapup;
  if ( bevel.stock < .1) goto wrapup;

  // Want to use the S object as a reference
  // Cycle through the feet
  footOE = *drwOE;
  for(i = 0;
      vdchn$Get2(objOE  = drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {

    // Get the text
    VDtextGetValue(&footOE,value);
    if (!strcmp(value,"S")) {

      // Write out label using text hack method
      VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
      VDxmlWriteAtrTxt(xml,XML_SMS_MARKING_TYPE,
		       XML_SMS_MARKING_TYPE_LABEL,0,0);
      VDxmlWriteAtrEnd(xml,0,1);
      VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);

      VDcvgWriteTextObjectTextHack(&info->cvg,&footOE,bevel.spec);
      
      VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
      VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);
      
      retFlag = 1;
      goto wrapup;
      
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a feature label
 */
IGRstat VLsmsWriteUnwrapFeatureLabel(TVLsmsFileInfo *info,
				     TGRobj_env     *unwrapOE, 
				     TGRobj_env     *featureOE,
				     TGRobj_env     *markOE,
				     TGRobj_env     *drwOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapFeatureLabel";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TVDxmlFileInfo *xml;

  IGRint i;
  TGRobj_env footOE;
  IGRchar buf[32];

  IGRint traceFlagx;
  IGRint use_it;
  
  TGRsymbology symb;
  
  // Say hi later
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  
  // Arg Check
  if (info      == NULL) goto wrapup;
  if (unwrapOE  == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  if (markOE    == NULL) goto wrapup;
  if (drwOE     == NULL) goto wrapup;
  
  xml = &info->cvg.xml;
  
  /* ---------------------------------------------
   * Check for text labels
   * All ACconsts are assumed to fall under this category
   * Note that collar markings get picked up here as well
   *
   * TR5205
   * The nci_macro plate_label is used for auto labeling
   * it gets picked up here as well
   */
  vdobj$Get(objOE = markOE, className = buf);
  if (strcmp(buf,"ACconst")) {
    vdobj$Get(objOE = markOE, macName = buf);
    if (strcmp(buf,"plate_label")) goto wrapup;
  }
  
  // Regardless of errors, it's been processed
  retFlag = 1;

  // Filter by name(These are field cuts)
  //vdobj$Get(objOE = markOE, macName = buf);
  //if (!strncmp(buf,"hull_pene",9)) goto wrapup;
  
  // Say hi
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = featureOE);
    vdobj$Print(objOE = markOE);
  }

  // Cycle through the feet
  footOE = *drwOE;
  for(i = 0;
      vdchn$Get2(objOE  = drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {

    // Get the symbology
    use_it = 0;
    memset(&symb,0,sizeof(TGRsymbology));
    sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
		  senderid = NULL_OBJID,
		  targetid = footOE.obj_id.objid,
		  targetos = footOE.obj_id.osnum);

    // Send whatever is on this layer
    if (symb.level == SEND_LAYER) use_it = 1;

    // Unless it's this color in which case it's an nc cur
    if (symb.display_attr.color == NC_COLOR) use_it = 0;

    if (use_it) {
      
      // Text objects are labels
      sts = vdobj$IsAncestryValid(objOE = &footOE,
				  superClassID = OPP_GR3dtext_class_id);
      if (sts & 1) {
  
	// Doit
	VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
	VDxmlWriteAtrTxt(xml,XML_SMS_MARKING_TYPE,
			 XML_SMS_MARKING_TYPE_LABEL,0,0);
	VDxmlWriteAtrEnd(xml,0,1);
	VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);
	VDcvgWriteObject(&info->cvg,&footOE);
	VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
	VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);
	
      }

      // And we can have curves
      sts = vdobj$IsAncestryValid(objOE = &footOE,
				  superClassID = OPP_GRcurve_class_id);
      if (sts & 1) {

	// Collar Graphics
	VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
	VDxmlWriteAtrTxt(xml,
			 XML_SMS_MARKING_TYPE,
			 XML_SMS_MARKING_TYPE_REF,0,0);
	
	VDxmlWriteAtrEnd(xml,0,1);
	VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);
	VDcvgWriteObject(&info->cvg,&footOE);
	VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
	VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);
	
      }
    }
  }
    
  // Done
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a feature
 */
IGRstat VLsmsWriteUnwrapFeature(TVLsmsFileInfo *info,
				TGRobj_env     *unwrapOE, 
				TGRobj_env     *featureOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapFeature";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar buf[128];
  IGRchar side[32];
  IGRchar lineType[32];
  IGRchar markType[128];
  IGRchar *p;
  
  TGRobj_env markOE;
  TGRobj_env footOE;

  TGRobj_env drwOE;
  IGRint     drwCnt;
  
  IGRint i,flag;
  IGRint gotOne = 0;
  
  TVDxmlFileInfo *xml = NULL;

  IGRint traceFlagx;

  TGRsymbology symb;
    
  // Say hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx | 0) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = featureOE);
  }
  
  // Arg Check
  if (unwrapOE  == NULL) goto wrapup;
  if (info      == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  *side = 0;
  xml = &info->cvg.xml;
  
  // Get its second parent */
  vdobj$GetTemplate(objOE = featureOE,
		    nth   = 1,
		    templateOE = &markOE);
  if (markOE.obj_id.objid == NULL_OBJID) {

    /* -------------------------------------------
     * 12 Jun 2000 - Allow this to fail silently
     * Getting lots of duplicate marking features
     * on the unwrap with one having parents and the other
     * not.  
     */
#if 0
    printf("*** Problem getting marking parent of feature\n");
    vdobj$Print(objOE = featureOE);
#endif
    goto wrapup;
  }
  
  // The VDdrwgm object actually holds the graphics
  vdobj$GetFoot(objOE = featureOE, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Check for ACconst
  sts = VLsmsWriteUnwrapFeatureLabel(info,unwrapOE,featureOE,&markOE,&drwOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // For the rest, reject any feature not on SEND_LAYER
  sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
		senderid = NULL_OBJID,
		targetid = featureOE->obj_id.objid,
		targetos = featureOE->obj_id.osnum);
  if (!(sts & msg & 1)) {
    VLsmsLog1(1,1,"*** Problem getting symbology for feature %d\n",
	   featureOE->obj_id.objid);
    goto wrapup;
  }
  
  switch(symb.level) {
  case SEND_LAYER: break;
  case SKIP_LAYER: goto wrapup;
  default: printf("Feature %d on layer %d\n",featureOE->obj_id.objid,symb.level);
  }

  // Check for part marking
  sts = VLsmsWriteUnwrapFeaturePartMarking(info,unwrapOE,featureOE,&markOE,&drwOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Check for Bevels
  sts = VLsmsWriteUnwrapFeatureBevel(info,unwrapOE,featureOE,&markOE,&drwOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Check for VA Bevels
  sts = VLsmsWriteUnwrapFeatureVABevel(info,unwrapOE,featureOE,&markOE,&drwOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Check tangent
  sts = VLsmsWriteUnwrapFeatureTangent(info,unwrapOE,featureOE,&markOE,&drwOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Check Knuckles

  // Need count for error checking
  vdchn$Get2(objOE  = &drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     cnt    = &drwCnt);

  // Let type be class for now
  vdobj$Get(objOE = &markOE, className = markType);
  if (*markType == 0) goto wrapup;

  // Waterline (also unprocessed VLmrkLines)
  if ((!strcmp(markType,"VLwatLine")) ||
      (!strcmp(markType,"VLmrkLine"))) {

    TGRobj_env wlOE;
    TGRobj_env planeOE;
    
    gotOne = 1;

    strcpy(lineType,XML_SMS_MARKING);
    VDxmlWriteObjBeg(xml,lineType,1,0);
    VDxmlWriteAtrTxt(xml,
		     XML_SMS_MARKING_TYPE,
		     XML_SMS_MARKING_TYPE_WATER,0,0);
    VDxmlWriteAtrEnd(xml,0,1);
  }

  // Roll line
  if (!strcmp(markType,"VLrolLine")) {
    gotOne = 1;
    
    strcpy(lineType,XML_SMS_MARKING);
    VDxmlWriteObjBeg(xml,lineType,1,0);
    VDxmlWriteAtrTxt(xml,
		     XML_SMS_MARKING_TYPE,
		     XML_SMS_MARKING_TYPE_ROLL,0,0);
    VDxmlWriteAtrEnd(xml,0,1);
  }

  if (gotOne == 0) {
    VLsmsLog1(1,1,"Unknown feature type %s\n",markType);
    goto wrapup;
  }
  
  // Wrap in edge
  VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);
  
  // Write out each component, go backwards cause marking lines
  // are backwards
  footOE.mod_env = featureOE->mod_env;
  for(i = drwCnt - 1; i >= 0; i--) {
    
    vdchn$Get2(objOE  = &drwOE, 
	       chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	       nth    = i, 
	       outID  = &footOE.obj_id);

    VDcvgWriteObject(&info->cvg,&footOE);
  }
    
  // Done
  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,1);
  VDxmlWriteObjEnd(xml,lineType,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------
 * Write out stock lines
 */
IGRstat VLsmsWriteUnwrapStockLine(TVLsmsFileInfo *info,
				  TGRobj_env     *unwrapOE,
				  TGRobj_env     *lineOE,
				  TGRobj_env     *textOE)
{
  IGRstat retFlag = 0;

  TGRobj_env crvOE;
  IGRint     i,nth;
  
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (info     == NULL) goto wrapup;
  xml = &info->cvg.xml;
  if (lineOE == NULL) goto wrapup;
  if (textOE == NULL) goto wrapup;
  
  // Doit
  VDxmlWriteObjBeg(xml,XML_SMS_MARKING,1,0);
  VDxmlWriteAtrTxt(xml,XML_SMS_MARKING_TYPE,XML_SMS_MARKING_TYPE_STOCK,0,0);
  VDxmlWriteAtrEnd(xml,0,1);

  VDxmlWriteObjBeg(xml,XML_SMS_EDGE,0,1);

  VDcvgWriteObject(&info->cvg,textOE);
  VDcvgWriteObject(&info->cvg,lineOE);

  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,   1);
  VDxmlWriteObjEnd(xml,XML_SMS_MARKING,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------
 * Open master xml file
 */
IGRstat VLsmsOpenOutputFile(TVLsmsFileInfo *info, IGRchar *a_fileName)
{
  IGRstat        retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  IGRchar        fileName[256];
  
  // Arg check
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVLsmsFileInfo));
  xml = &info->cvg.xml;
  
  // Open it
  if (a_fileName) strcpy(fileName,a_fileName);
  else            strcpy(fileName,"plate.xml");
  
  VDxmlOpenOutputFile(xml,fileName,XML_SMS_DOC_TYPE,XML_SMS_DTD);
  if (xml->io.file == NULL) goto wrapup;

  // Master objects
  VDxmlWriteObjBeg(xml,XML_SMS_DOC_TYPE,1,1);
  
  // Need some name spaces
  VDxmlWriteAtrTxt(xml,"xmlns:pdf","http://www.ingr.com/isdp/pdf",1,1);
  VDxmlWriteAtrTxt(xml,"xmlns:sms","http://www.ingr.com/isdp/sms",1,1);
  VDxmlWriteAtrTxt(xml,"xmlns:cvg","http://www.ingr.com/isdp/cvg",1,1);
  VDxmlWriteAtrEnd(xml,0,1);
     
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------
 * Close the master xml file
 * Optiionally, kick off post process
 */
IGRstat VLsmsCloseOutputFile(TVLsmsFileInfo *info, IGRint flag)
{
  IGRstat retFlag = 0;
  IGRchar cmd[256];
  
  TVDxmlFileInfo *xml = NULL;

  // Arg check
  if (info == NULL) goto wrapup;
  xml = &info->cvg.xml;
  
  // Root object
  //VDxmlWriteObjEnd(xml,XML_SMS_PLATES,  1);
  VDxmlWriteObjEnd(xml,XML_SMS_DOC_TYPE,1);

  // Close it
  VDxmlCloseOutputFile(xml);

  // Kick off process
  switch(flag) {
  case 1:
    sprintf(cmd,"dxf2 %s",xml->io.fileName);
    //system (cmd);
    break;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write an inner contour
 */
IGRstat VLsmsWriteUnwrapInnerContour(TVLsmsFileInfo *info, 
				     TGRobj_env     *unwrapOE,
				     TGRobj_env     *contourOE,
				     IGRint          expandFlag)
{

  IGRstat retFlag = 0;
  
  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;
  
  TGRbsp_curve *crv = NULL;
  
  IGRpoint center;
  TVDgeomSym sym;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (info     == NULL) goto wrapup;
  cvg = &info->cvg;
  xml = &info->cvg.xml;
  if (contourOE == NULL) goto wrapup;

  // Get the geometry
  vdgeom$Get2(objOE = contourOE, crv = &crv);
  if (crv == NULL) {
    VLsmsLog1(1,1,"*** Problem getting geomotry for inner contour\n");
    goto wrapup;
  }

  // Force it to be precisly closed
  VDgeomCloseCurve(crv);


  // Expand if desired
  if (expandFlag) {
    
    // Need center
    VDgeomGetSymCrvCenter(crv,center);
  
    // Expand it (now done in the unwrap)
    VDgeomExpandSymCrv(crv,center,1.5);
  }
  

  // Still do this to get the parametric values
  VDgeomIsCrvSym(crv,0.0,&sym);
  
  // Doit
  VDxmlWriteObjBeg      (xml,XML_SMS_INNER_CONTOUR,0,1);  
  VDxmlWriteObjBeg      (xml,XML_SMS_EDGE,         0,1);

  // In case it has a contour
  VLsmsWriteUnwrapBevelsForContour(info,unwrapOE,contourOE);

  // And the actual curve
  if (sym.type == VDGEOM_SYM_TYPE_NONE) VDcvgWritePathGeometry(cvg,-1,crv);
  else                                  VDcvgWritePathSym     (cvg,&sym);
  
  VDxmlWriteObjEnd      (xml,XML_SMS_EDGE,         1);
  VDxmlWriteObjEnd      (xml,XML_SMS_INNER_CONTOUR,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  _FREE(crv);
  return retFlag;

}

/* -----------------------------------------------
 * Write out a inner feature
 * That is, an NC curve from a feature
 */
IGRstat VLsmsWriteUnwrapInnerFeature(TVLsmsFileInfo *info,
				     TGRobj_env     *unwrapOE, 
				     TGRobj_env     *featureOE)
{
  IGRchar fn[] = "VLsmsWriteUnwrapInnerFeature";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env footOE;

  TGRobj_env drwOE;
  IGRint     drwCnt;
  
  IGRint i;
  IGRint use_it;

  IGRint traceFlagx;

  TGRsymbology symb;
    
  // Say hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx | 0) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = featureOE);
  }
  
  // Arg Check
  if (unwrapOE  == NULL) goto wrapup;
  if (info      == NULL) goto wrapup;
  if (featureOE == NULL) goto wrapup;
  
  // The VDdrwgm object actually holds the graphics
  vdobj$GetFoot(objOE = featureOE, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Cycle through
  footOE = drwOE;
  for(i = 0;
      vdchn$Get2(objOE  = &drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &footOE.obj_id);
      i++) {

    // Get the symbology
    use_it = 0;
    memset(&symb,0,sizeof(TGRsymbology));
    sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
		  senderid = NULL_OBJID,
		  targetid = footOE.obj_id.objid,
		  targetos = footOE.obj_id.osnum);

    // Send whatever is on this layer and is the right color
    if (symb.level == SEND_LAYER) use_it = 1;

    // Has to be this color in which case it's an nc cur
    if (symb.display_attr.color != NC_COLOR) use_it = 0;

    // Has to be a curve
    sts = vdobj$IsAncestryValid(objOE = &footOE,
				  superClassID = OPP_GRcurve_class_id);
    if (!(sts & 1)) use_it = 0;

    // Write it
    if (use_it) {
      VLsmsWriteUnwrapInnerContour(info,unwrapOE,&footOE,1);
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write an outer contour
 *
 * Sometimes the outer contour is just a single line string
 * make sure it's closed then write it
 *
 * Most of the time have a composite curve
 * Want to write one curve at a time to ensure the end points dont
 * get changed by the line/arc processor
 *
 * Minor problem with this is that some half circle edge cutouts
 * end up as two 90 degree arcs instead of one 180 degree
 * need to fix up later.  Maybe merge arcs together or somethng.
 *
 * Assume composite curves are closed for now
 * Not positive if this is always a good assumption, might
 * want to adjust the unwrap to ensure this
 *
 * Otherwise, need to make an array of bsp's and check each end
 * especially the first and last points might be good to do
 * this anyways 
 *
 * Note: the beg/end info is done by the calling routine
 *
 * Go back to always writing the complete curve in 1 gulp
 * New line arc should break properly
 *
 * 26 Oct 2001
 * After several years, the line-arc processor needed to be revisited
 * The little stress relief corners on collars were not getting drawn correctly
 * Unit 2582 Piece 540 is an example
 *
 * These guys have an assoc curve for geometry consisting of individual
 * 3rd order rational curves.  Since we dont break the composite curve up we
 * end up with a set of 3rd order rational curves.  This turned out not to have
 * any impact on the line-arc problem so continue touse the complete curve.
 * I just wanted to document that this is one common case and if we ever go back
 * to breaking up curves then test these throughly
 */
IGRstat VLsmsWriteUnwrapOuterContour(TVLsmsFileInfo *info, 
				     TGRobj_env     *unwrapOE,
				     TGRobj_env     *contourOE)
{

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;
  
  TGRbsp_curve *crv = NULL;
  
  IGRint i;
  TGRobj_env contourOEx;
  
  IGRint traceFlag = 0;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (info     == NULL) goto wrapup;
  cvg = &info->cvg;
  xml = &info->cvg.xml;
  if (contourOE == NULL) goto wrapup;
#if 0
  // Handle composite curves
  sts = vdobj$IsAncestryValid(objOE        = contourOE, 
			      superClassID = OPP_AScompcurve_class_id);
  if (sts & 1) {
  
    // Break it up and write
    VDcvgWritePathBeg(cvg);
    contourOEx = *contourOE;
    for(i = 0; 
	vdchn$Get2(objOE  = contourOE,
		   chnIDx = VDCHN_IDX_TO_COMPONENTS,
		   nth    = i,
		   outID  = &contourOEx.obj_id);
	i++) {
      VDcvgWritePathObject(cvg,i,&contourOEx);
    }
    VDcvgWritePathEnd(cvg);

    // Done
    retFlag = 1;
    goto wrapup;
  }
#endif
  if (traceFlag) printf(">>> VLsmsWriteUnwrapOuterContour\n");
  
  // Could be line string or bs curve
    
  // Get the geometry
  vdgeom$Get2(objOE = contourOE, crv = &crv);
  if (crv == NULL) {
    VLsmsLog1(1,1,"*** Problem getting geometry for outer contour\n");
    goto wrapup;
  }
  if (traceFlag) printf("Got the geometry\n");
  
  // Force it to be precisly closed
  VDgeomCloseCurve(crv);
  if (traceFlag) printf("Forced it to be closed\n");

  // Write it
  VDcvgWritePathGeometry(cvg,-1,crv);
  if (traceFlag) printf("wrote it out\n");
   
  // Done
  retFlag = 1;
  
wrapup:
  _FREE(crv);
  if (traceFlag) printf("<<< VLsmsWriteUnwrapOuterContour\n");
  return retFlag;

}

/* -------------------------------------
 * Process the selected unwrap
 */
IGRstat VLsmsWriteUnwrap(TVLsmsFileInfo *info, TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  
  IGRstat sts,msg;

  IGRint i;

  TGRobj_env edgeOE;
  TGRobj_env contourOE;
  TGRobj_env rectOE;
  
  TGRobj_env *objOEs = NULL;
  IGRint      objCnt;
  IGRint      objMax;
  
  TGRobj_env *featureOEs = NULL;
  IGRint      featureCnt;
  IGRint      featureMax;
  
  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;
  
  TGRbsp_curve *crv = NULL;
  
  IGRmatrix matrix;
  
  // Arg Check
  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  if (info == NULL) goto wrapup;
  cvg = &info->cvg;
  xml = &info->cvg.xml;

  // Reset plate specific data (should have wrapped this in a structure)
  info->presentOffset = 0;
  
  // Say hi
  VLsmsLog1(0,1,"-----------------------------------\n");
  VLsmsLog2(0,1,NULL,unwrapOE,NULL);

  // Grab the matrix first because it might cause a recompute
  VLunw2GetMatrix(unwrapOE,NULL,matrix);
  
  // Get the contour
  VLunwGetExternalContour(unwrapOE,&contourOE);
  if (contourOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Unable to get the outer contour of the unwrap\n");
    goto wrapup;
  }
  
  // Get the min rec
  VLunwGetMinRectangle(unwrapOE,&rectOE);
  if (rectOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Unable to get the minimum rectangle of the unwrap\n");
    goto wrapup;
  }
  
  // Grab the features
  VLunwGetFeatures(unwrapOE,0,&featureCnt,NULL);
  if (featureCnt) {
    featureMax = featureCnt;
    featureOEs = calloc(sizeof(TGRobj_env),featureCnt);
    if (featureOEs == NULL) goto wrapup;
    VLunwGetFeatures(unwrapOE,featureMax,&featureCnt,featureOEs);  
  }
  
  // Setup the output file
  info->cvg.linearTol = .70; // .07
  info->cvg.arcTol    = .25; // .25
  info->cvg.arcTol    = .70; // .25
  
  sts = VLsmsGetUnwrapRangeScale(info,unwrapOE);
  if (!(sts & 1)) goto wrapup;

  // Prepare for a plate
  VDxmlWriteObjBeg(xml,XML_SMS_PLATE,1,1);

  // Plate attributes
  VLsmsWriteUnwrapAttributes(info,unwrapOE);

  // List of bevels
  VLunwGetUnwrapBevelInfos(stdout,
			   unwrapOE,
			   VLSMS_MAX_BEVEL,
			   &info->numBevels,
			    info->bevels);

  // Begin the contour
  VDxmlWriteObjBeg    (xml,XML_SMS_PLATE_CONTOUR,0,1);  
  VDxmlWriteObjBeg    (xml,XML_SMS_EDGE,         0,1);

  // Process bevels before writing the actual contour
  // Newer code using feature bevels
  VLsmsWriteUnwrapBevelsForContour(info,unwrapOE,&contourOE);
  
  // The contour itself
  VLsmsWriteUnwrapOuterContour(info,unwrapOE,&contourOE);
  //VDgeomTestAngle(&contourOE);
  
  // Done with outer contour
  VDxmlWriteObjEnd(xml,XML_SMS_EDGE,         1);
  VDxmlWriteObjEnd(xml,XML_SMS_PLATE_CONTOUR,1);

  // Process Internal contours
  VDxmlWriteObjBeg(xml,XML_SMS_INNER_CONTOURS,0,1); 

  // Normal cuts from the unwrap object
  if (objOEs) { free(objOEs); objOEs = NULL; }
  VLunwGetComponents(unwrapOE,VLEXT_TYPE_CONTOUR,0,&objCnt,NULL);
  if (objCnt) {
    objMax = objCnt;
    objOEs = calloc(sizeof(TGRobj_env),objCnt);
    if (objOEs == NULL) goto wrapup;
    VLunwGetComponents(unwrapOE,VLEXT_TYPE_CONTOUR,objMax,&objCnt,objOEs);
  }
  for(i = 0; i < objCnt; i++) {
    VLsmsWriteUnwrapInnerContour(info,unwrapOE,&objOEs[i],0);
  }

  // Also possible to have feature based cuts
  for(i = 0; i < featureCnt; i++) {
    VLsmsWriteUnwrapInnerFeature(info,unwrapOE,&featureOEs[i]);
  }
  VDxmlWriteObjEnd(xml,XML_SMS_INNER_CONTOURS,1);  

  // Start the markings
  VDxmlWriteObjBeg(xml,XML_SMS_MARKINGS,0,1);

  // Process stock lines
  if (objOEs) { free(objOEs); objOEs = NULL; }
  sts = VLunwGetComponents(unwrapOE,VLEXT_TYPE_STOCK_LINE,0,&objCnt,NULL);
  if (objCnt) {
    objMax = objCnt;
    objOEs = calloc(sizeof(TGRobj_env),objCnt);
    if (objOEs == NULL) goto wrapup;
    sts = VLunwGetComponents(unwrapOE,VLEXT_TYPE_STOCK_LINE,objMax,&objCnt,objOEs);
  }
  if (sts & 1) {  
    for(i = 0; (i+1) < objCnt; i+=2) {
      VLsmsWriteUnwrapStockLine(info,unwrapOE,&objOEs[i],&objOEs[i+1]);
    }
  }
  
  // Process Features
  for(i = 0; i < featureCnt; i++) {
    VLsmsWriteUnwrapFeature(info,unwrapOE,&featureOEs[i]);
  }

  // Done with markings
  VDxmlWriteObjEnd(xml,XML_SMS_MARKINGS,1);  

  // Done with plate
  VDxmlWriteObjEnd(xml,XML_SMS_PLATE,1);

  // Done
  retFlag = 1;
  
wrapup:
  if (objOEs) free(objOEs);
  if (featureOEs) free(featureOEs);
  
  return retFlag;
}

end implementation VLunwObj;
