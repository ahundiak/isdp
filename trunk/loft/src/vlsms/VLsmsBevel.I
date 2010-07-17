/* $Id: VLsmsBevel.I,v 1.2 2001/01/18 17:55:31 art Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlsms/VLsmsBevel.I
 *
 * Description: Bevel specific routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsBevel.I,v $
 *      Revision 1.2  2001/01/18 17:55:31  art
 *      ah
 *
# Revision 1.6  2000/06/19  18:39:36  pinnacle
# ah
#
# Revision 1.5  2000/05/26  17:50:48  pinnacle
# ah
#
# Revision 1.4  2000/05/15  14:49:14  pinnacle
# ah
#
# Revision 1.3  2000/05/05  15:45:56  pinnacle
# ah
#
# Revision 1.2  2000/05/03  13:08:46  pinnacle
# ah
#
# Revision 1.1  2000/04/25  16:31:42  pinnacle
# ah
#
# Revision 1.1  2000/02/25  18:16:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/25/00  ah      Creation
 *
 ***************************************************************************/

class implementation VLunwObj;

/* ------------------------------------------------------
 * Initial shot at extracting data from the unwrap object
 */
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"
#include "VDsa.h"

#include "vddrwattr.h"
#include "vlstructure.h"
#include "vlunwext.h"

#include "VLunwMisc.h"

static IGRint traceFlag;

typedef struct 
{
  struct 
  {
    IGRint    flag;
    IGRdouble angle,length;
  } a,b,c,d,e;
  
  IGRchar   spec   [128];
  IGRchar   process[128];
  IGRdouble stock;
  IGRdouble gap;
  IGRdouble thickness,adj_thickness;
} TVLsmsBevelInfo;

#define INCH_TO_MM     25.6
#define BEVEL_CHAMFER  ((INCH_TO_MM *  2.0) / 16.0)
#define BEVEL_MM_01_16 ((INCH_TO_MM *  1.0) / 16.0)
#define BEVEL_MM_02_16 ((INCH_TO_MM *  2.0) / 16.0)
#define BEVEL_MM_03_16 ((INCH_TO_MM *  3.0) / 16.0)
#define BEVEL_MM_04_16 ((INCH_TO_MM *  4.0) / 16.0)
#define BEVEL_MM_05_16 ((INCH_TO_MM *  5.0) / 16.0)
#define BEVEL_MM_06_16 ((INCH_TO_MM *  6.0) / 16.0)
#define BEVEL_MM_07_16 ((INCH_TO_MM *  7.0) / 16.0)
#define BEVEL_MM_08_16 ((INCH_TO_MM *  8.0) / 16.0)
#define BEVEL_MM_12_16 ((INCH_TO_MM * 12.0) / 16.0)
#define BEVEL_MM_16_16 ((INCH_TO_MM * 16.0) / 16.0)
#define BEVEL_MM_24_16 ((INCH_TO_MM * 24.0) / 16.0)
#define BEVEL_MM_30_16 ((INCH_TO_MM * 30.0) / 16.0)
#define BEVEL_MM_32_16 ((INCH_TO_MM * 32.0) / 16.0)

#define ANGLE45 45.00
#define ANGLE30 30.00
#define ANGLE20 20.00
#define ANGLEC  18.43

/* -------------------------------------------------------------------
 * Make a little inch metric table
 */
IGRstat VLsmsPrintInchMetricTable()
{
  IGRstat retFlag = 0;
  IGRint  inch;
  IGRint  i;
  IGRdouble metric;
  
  for(inch = 0; inch < 3; inch++) {
    for(i = 0; i < 16; i++) {
      metric = (((16.0 * inch) + i) * INCH_TO_MM) / 16.0;
      printf("%2d %2d %6.2f\n",inch,i,metric);
    }
  }
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Parse the spec code into a number and parameters
 */
IGRstat VLsmsParseBevelSpecCode(IGRchar *spec, IGRint *specNum, IGRchar *specPars)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  // Init
  if (specNum == NULL)  goto wrapup; *specNum  = 0;
  if (specPars == NULL) goto wrapup; *specPars = 0;
  if (spec == NULL) goto wrapup;
  
  // Pull the number
  *specNum = atoi(spec);
  if ((*specNum < 1) || (*specNum > 40)) goto wrapup;
  
  // Pull rest
  for(p = spec; (*p) && (*p >= '0') && (*p <= '9'); p++);
  strcpy(specPars,p);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Parse the thickness returning the delta and the
 * smallest thickness
 */
IGRstat VLsmsParseBevelThickness(IGRdouble  thickness,
				 IGRdouble  adj_thickness,
				 IGRdouble *t,
				 IGRdouble *delta)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if ((t == NULL) || (delta == NULL)) goto wrapup;

  // Many times, adj_thickness will not be set
  if (adj_thickness < .01) adj_thickness = thickness;
  
  // Delta is the diffrenece between thicker plate and the thinner plate
  *t = thickness;
  *delta = thickness - adj_thickness;
  if (*delta < .01) *delta = 0.0;
  else              *t = adj_thickness;

  // Done
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The chamfering process is the same for all bevels
 */
IGRstat VLsmsCalcBevelChamfer(TVLsmsBevelInfo *info)
{
  IGRstat retFlag = 1;
  
  IGRchar specPars[128];
  IGRint  specNum;

  IGRdouble delta,t;
  
  // Get parameters
  VLsmsParseBevelSpecCode(info->spec,&specNum,specPars);
  if (*specPars == 0) goto wrapup;
  
  // Need chamfer thickness
  VLsmsParseBevelThickness(info->thickness,info->adj_thickness,&t,&delta);
  if (delta < .01) goto wrapup;

  // Check the codes
  if (!strcmp(specPars,"AX")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"AY")) {
    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"BX")) {
    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"BY")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"AXY")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta * 0.5;

    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta * 0.5;
    goto wrapup;
  }
  if (!strcmp(specPars,"BXY")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta * 0.5;

    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta * 0.5;
    goto wrapup;
  }
  if (!strcmp(specPars,"M")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"N")) {
    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta;
    goto wrapup;
  }
  if (!strcmp(specPars,"MN")) {
    info->a.flag   = 1;
    info->a.angle  = ANGLEC;
    info->a.length = delta * 0.5;

    info->e.flag   = 1;
    info->e.angle  = ANGLEC;
    info->e.length = delta * 0.5;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Two Bevels, 4,13
 */
IGRstat VLsmsCalcBevelTwoBevels(TVLsmsBevelInfo *info)
{
  IGRstat   retFlag = 0;

  IGRdouble land;
  IGRdouble b,d;
  
  IGRdouble angle;
  IGRdouble delta,t;

  IGRchar specPars[128];
  IGRint  specNum;
  
  // Get parameters
  VLsmsParseBevelSpecCode(info->spec,&specNum,specPars);
  
  // Need thinner thickness
  VLsmsParseBevelThickness(info->thickness,info->adj_thickness,&t,&delta);
  
  // Filter
  switch(specNum) {

  case 3:
    land  = BEVEL_MM_02_16;

    // Table needs to be converted to metric
    b = BEVEL_MM_07_16;
    if (t < BEVEL_MM_32_16) b = BEVEL_MM_07_16;
    if (t < BEVEL_MM_30_16) b = BEVEL_MM_06_16;
    if (t < BEVEL_MM_30_16) b = BEVEL_MM_06_16;
    d = t - b -land;
    angle = ANGLE30;
    break;

  case 4:
    land  = BEVEL_MM_02_16;
    b = (t - land) * 0.5;
    d =  t - land - b;
    angle = ANGLE30;
    break;
    
  case 8:
    land  = BEVEL_MM_04_16;
    b = (t - land) * 0.5;
    d =  t - land - b;
    if (*specPars = 0) b += delta; // Un chamfered extra material
    angle = ANGLE30;
    break;
    
  case 13:
    land  = BEVEL_MM_02_16;
    d = (t * 2.0) / 3.0;
    b =  t - d - land;
    angle = ANGLE30;
    break;

  case 14:
    land  = BEVEL_MM_02_16;
    d = (t * 2.0) / 3.0;
    d = d + BEVEL_MM_03_16 - land;    
    b =  t - d - land;
    angle = ANGLE30;
    break;

  case 18:
    land  = BEVEL_MM_01_16;
    b = (t - land) * 0.5;
    d =  t - land - b;
    angle = ANGLE30;
    break;

  case 24:
    land  = BEVEL_MM_04_16;
    b     = BEVEL_MM_04_16;
    d =  t - land - b;
    if (!strcmp(specPars,"AX")) {
      land += b;
      b = 0.0;
    }
    angle = ANGLE30;
    break;

  case 25:
    land  = BEVEL_MM_04_16;
    b = (t - land) * 0.5;
    d =  t - land - b;
    angle = ANGLE30;
    break;

  case 28:
    land  = BEVEL_MM_05_16;
    b = (t - land) * 0.5;
    d =  t - land - b;
    if (!strcmp(specPars,"AX")) {
      land += b;
      b = 0.0;
    }
    angle = ANGLE30;
    break;
    
  default: goto wrapup;
    
  }
  
  // Got one
  retFlag = 1;
  
  info->c.flag   = 1;
  info->c.angle  = 0;
  info->c.length = land;

  info->b.flag   = 1;
  info->b.angle  = angle;
  info->b.length = b;
  
  info->d.flag   = 1;
  info->d.angle  = angle;
  info->d.length = d;
  
  // Flip assignments for B types
  if (*specPars == 'B') {
    info->b.length = d;
    info->d.length = b;
  }
  
  // Chamfer it
  VLsmsCalcBevelChamfer(info);

  // Just to avoid possible later confusion
  if (info->a.length < .01) info->a.flag = 0;
  if (info->b.length < .01) info->b.flag = 0;
  if (info->d.length < .01) info->d.flag = 0;
  if (info->e.length < .01) info->e.flag = 0;
     
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Single Bevel, 2,6,9,10,16,17,20,21,23,26,27,29,30,31
 */
IGRstat VLsmsCalcBevelOneBevel(TVLsmsBevelInfo *info)
{
  IGRstat   retFlag = 0;

  IGRdouble land;
  IGRdouble b,d;
  
  IGRdouble angle;
  IGRdouble delta,t;

  IGRchar specPars[128];
  IGRint  specNum;
  
  // Get parameters
  VLsmsParseBevelSpecCode(info->spec,&specNum,specPars);
  
  // Need chamfer thickness
  VLsmsParseBevelThickness(info->thickness,info->adj_thickness,&t,&delta);
    
  // Filter
  switch(specNum){

  case 2:
    land  = BEVEL_MM_02_16;
    angle = ANGLE30;
    break;
    
  case 6:
    land  = BEVEL_MM_04_16;
    angle = ANGLE30;
    break;
    
  case 9:
    land  = t - BEVEL_MM_04_16;
    angle = ANGLE30;
    break;
    
  case 10:
    land  = BEVEL_MM_04_16;
    angle = ANGLE30;
    // Only one that allows non-chamfered extra thickness
    if (!strcmp(specPars,"A")) land += delta;
    if (!strcmp(specPars,"B")) land += delta;
    break;
    
  case 16:
    land  = BEVEL_MM_02_16;
    angle = ANGLE20;          // Spec has 45 minimum
    strcpy(specPars,"B");
    break;
    
  case 17:
    land  = BEVEL_MM_02_16;
    angle = ANGLE30;          // Spec has 45
    break;
    
  case 20:
    land  = 0.0;
    angle = 30.0;
    if (t < BEVEL_MM_16_16) angle = 40.0;
    if (t < BEVEL_MM_12_16) angle = 50.0;
    break;
    
  case 21:
    land  = 0.0;
    angle = ANGLE20;
    break;
    
  case 23:
    land  = BEVEL_MM_06_16;
    angle = ANGLE30;
    break;
    
  case 26:
    land  = BEVEL_MM_04_16;
    angle = ANGLE30;
    break;
    
  case 27:
    land  = BEVEL_MM_06_16;
    angle = ANGLE30;
    break;

  case 29:
    land  = 0.0;
    angle = 15.0;
    break;
    
  case 30:
    land  = 0.0;
    angle = 45.0;
    if (t < BEVEL_MM_24_16) angle = 45.0;
    if (t < BEVEL_MM_08_16) angle = 60.0;
    if (t < BEVEL_MM_04_16) angle =  0.0;
    strcpy(specPars,"B");
    break;
    
  case 31:
    land  = 0.0;
    angle = ANGLE20;
    break;

  case 32:
    land  = 0.0;
    angle = ANGLE45;
    strcpy(specPars,"B");
    break;

  default: goto wrapup;
    
  }
  
  // Land is always constant
  info->c.flag   = 1;
  info->c.angle  = 0;
  info->c.length = land;
    
  // A or B define bevel orientation
  switch(*specPars) {

  case 'A':
    info->d.flag   = 1;
    info->d.angle  = angle;
    info->d.length = t - land;
    break;
    
  case 'B':
    info->b.flag   = 1;
    info->b.angle  = angle;
    info->b.length = t - land;
    break;

  default:
    retFlag = 0;
    goto wrapup;
  }
  
  // See if any chamfer is required
  VLsmsCalcBevelChamfer(info);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * No Bevels, 1,11,22 (all differ by root gap)
 */
IGRstat VLsmsCalcBevelNoBevels(TVLsmsBevelInfo *info)
{
  IGRstat   retFlag = 0;

  IGRdouble land;
  IGRdouble b,d;
  
  IGRdouble angle;
  IGRdouble delta,t;

  IGRchar specPars[128];
  IGRint  specNum;
  
  // Get parameters
  VLsmsParseBevelSpecCode(info->spec,&specNum,specPars);
  
  // Need chamfer thickness
  VLsmsParseBevelThickness(info->thickness,info->adj_thickness,&t,&delta);
  
  // Filter
  switch(specNum) {
  case  1: break;
  case 11: break;
  case 22: break;
  default: goto wrapup;
  }

  // Got One
  retFlag = 1;

  info->c.flag   = 1;
  info->c.angle  = 0;
  info->c.length = t;

  // See if any chamfer is required
  VLsmsCalcBevelChamfer(info);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Calc a bevel, filling in the cutting info 
 */
IGRstat VLsmsCalcBevel(TVLsmsBevelInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Quick check
  if ((info == NULL) || (*info->spec == 0)) goto wrapup;
  if (traceFlag) {    
    printf("Bevel Spec %s, %f %f\n",
	   info->spec,
	   info->thickness,
	   info->adj_thickness);
  }
  
  // No Bevels
  sts = VLsmsCalcBevelNoBevels(info);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // One Bevel
  sts = VLsmsCalcBevelOneBevel(info);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Two Bevels
  sts = VLsmsCalcBevelTwoBevels(info);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Bad code
  printf("*** Bad Bevel Spec '%s'\n",info->spec);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out single bevel for contour
 */
IGRstat VLsmsWriteUnwrapBevelForContour(TVLsmsFileInfo *file,
					TGRobj_env *unwrapOE,
					TGRobj_env *contourOE,
					TVLunwUnwrapBevelInfo *bevel)
{
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVLsmsBevelInfo info;

  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;

  TGRid *bevelID;
  
  IGRchar *p;
  
  // Arg check
  if (bevel     == NULL) goto wrapup;
  if (unwrapOE  == NULL) goto wrapup;
  if (contourOE == NULL) goto wrapup;
  if (file      == NULL) goto wrapup;

  xml = &file->cvg.xml;
  cvg = &file->cvg;
  bevelID = &bevel->bevelID;
  
  // Make sure bevel is applied to this contour
  if ((bevel->contourID.objid != contourOE->obj_id.objid) ||
      (bevel->contourID.osnum != contourOE->obj_id.osnum)) {
    goto wrapup;
  }

  // Pull some attributes
  memset(&info,0,sizeof(TVLsmsBevelInfo));

  // These are already filled in?
  //VLunwGetBevelInfo(&unwrapOE->obj_id,bevelID,&bevel->info);
  
  // Just copy already processed stuff
  strcpy(info.process, bevel->info.process);
  strcpy(info.spec,    bevel->info.spec);
  info.gap           = bevel->info.gap;
  info.stock         = bevel->info.stock;
  info.thickness     = bevel->info.thickness;
  info.adj_thickness = bevel->info.adj_thickness;
  
#if 0
  printf("Bevel %d,%d Spec %-5s, Stock %5.2f, Thickness %5.0f, Adj Thickness %5.0f\n",
	 bevelID->osnum,
	 bevelID->objid,
	 info.spec,
	 info.stock,
	 info.thickness,
	 info.adj_thickness);
#endif
  
  // If spec is blank then just for the stock
  // These should not fail
  if (*info.spec <= ' ') goto wrapup;
  if (info.stock > .01)  goto wrapup;
  
  // Variables bevels need special processing

  // Get more bevel info
  sts = VLsmsCalcBevel(&info);
  if (!(sts & 1)) goto wrapup;
  
  // Start the object
  VDxmlWriteObjBeg(xml,XML_SMS_BEVEL,1,1);

  VDxmlWriteAtrTxt(xml,XML_SMS_BEVEL_TYPE,   info.spec,   1,1);
  VDxmlWriteAtrTxt(xml,XML_SMS_BEVEL_PROCESS,info.process,1,1);

  VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_THICK1,info.thickness,1,1);
  if ((info.thickness - info.adj_thickness) > .01) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_THICK2,info.adj_thickness,1,1);
  }
  if (info.stock > .01) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_STOCK,info.stock,1,1);
  }
  if (info.gap > .01) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_GAP,info.gap,1,1);
  }

  if ((info.a.flag) && (info.a.length > .01)) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_SIZE_A, info.a.length,1,0);
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_ANGLE_A,info.a.angle, 0,1);
  }
  if ((info.b.flag) && (info.b.length > .01)) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_SIZE_B, info.b.length,1,0);
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_ANGLE_B,info.b.angle, 0,1);
  }
  if ((info.c.flag) && (info.c.length > .01)) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_SIZE_C,  info.c.length,1,0);
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_ANGLE_C, info.c.angle, 0,1);
  }
  if ((info.d.flag) && (info.d.length > .01)) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_SIZE_D, info.d.length,1,0);
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_ANGLE_D,info.d.angle, 0,1);
  }
  if ((info.e.flag) && (info.e.length > .01)) {
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_SIZE_E, info.e.length,1,0);
    VDxmlWriteAtrDbl(xml,XML_SMS_BEVEL_ANGLE_E,info.e.angle, 0,1);
  }
  
  // Done with attributes
  VDxmlWriteAtrEnd(xml,1,1);

  // And the points
  VDcvgWritePoint2D(cvg,bevel->end1);
  VDcvgWritePoint2D(cvg,bevel->end2);
  
  // Done with the object
  VDxmlWriteObjEnd(xml,XML_SMS_BEVEL,1);
  
  // Done

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out any bevels for a particular contour
 * files already has list of bevels filled in
 */
IGRstat VLsmsWriteUnwrapBevelsForContour(TVLsmsFileInfo *info,
					 TGRobj_env *unwrapOE,
					 TGRobj_env *contourOE)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVLunwUnwrapBevelInfo *bevel;
  
  // Arg check
  if (unwrapOE  == NULL) goto wrapup;
  if (contourOE == NULL) goto wrapup;
  if (info      == NULL) goto wrapup;

  // Cycle through, look for bevels on contour
  for(i = 0; i < info->numBevels; i++) {
    bevel = &info->bevels[i];
    if ((bevel->contourID.objid == contourOE->obj_id.objid) &&
	(bevel->contourID.osnum == contourOE->obj_id.osnum)) {

      VLsmsWriteUnwrapBevelForContour(info,unwrapOE,contourOE,bevel);
      
    }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation VLunwObj;


