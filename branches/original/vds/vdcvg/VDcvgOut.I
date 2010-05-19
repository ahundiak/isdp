/* $Id: VDcvgOut.I,v 1.2 2001/01/11 19:18:53 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcvg/VDcvgOut.I
 *
 * Description: XML Output routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcvgOut.I,v $
 *      Revision 1.2  2001/01/11 19:18:53  art
 *      sp merge
 *
# Revision 1.5  2000/06/23  19:12:26  pinnacle
# ah
#
# Revision 1.4  2000/06/19  18:07:00  pinnacle
# ah
#
# Revision 1.3  2000/05/15  14:41:54  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:11:22  pinnacle
# ah
#
# Revision 1.1  2000/04/14  17:06:04  pinnacle
# ah
#
# Revision 1.1  2000/02/22  20:15:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/13/00  ah      Creation
 *
 ***************************************************************************/

class implementation VDSroot;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"

#include "VDxml.h"
#include "VDcvg.h"

#include "bspartofcv.h"
#include "bsalloccv.h"
#include "bslsqptlnpl.h"
#include "bststcvfln.h"

#include "maoptsxfo.h"
#include "matypemx.h"

#include "gotextdef.h"

extern VDclassid OPP_GRcurve_class_id;
extern VDclassid OPP_GR3dtext_class_id;
extern VDclassid OPP_VDdrwGm_class_id;
extern VDclassid OPP_SMCpTxt_class_id;
extern VDclassid OPP_ACpretend_class_id;

from GRtext   import GRgettxattr;
from GR3dtext import GRgenabsg;

#define M_PI 3.14159265358979323846


/* -----------------------------------------------
 * Writes out a text object
 * Quick and dirty copy of the original code
 * Override the original value with textHack
 */
IGRstat VDcvgWriteTextObjectTextHack(TVDcvgFileInfo *info, TGRobj_env *textOE, IGRchar *textHack)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRuchar *str = NULL;
  IGRshort len;
  IGRint   i,beg;
  IGRdouble angle;
  
  struct IGRlbsys *lbs = NULL;
  struct IGRestx   attr;
  IGRpoint         pt1,pt2;
  IGRint   lenx;
  
  IGRchar  buf[128];
  IGRchar  just[128];
  IGRlong  numPoles;
  IGRshort matType;

  TVDxmlFileInfo *xml = NULL;
  
  // Verify
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  sts = vdobj$IsAncestryValid(objOE = textOE, superClassID = OPP_GR3dtext_class_id);
  if (!(sts & 1)) goto wrapup; 
  
  // Get the text
  len = 0;
  sts = om$send(msg = message GRtext.
		GRgettxattr(&msg,
			    &attr,
			    &len,
			    &str),
	  senderid = NULL_OBJID,
	  targetid = textOE->obj_id.objid,
	  targetos = textOE->obj_id.osnum);
  
  if ((str == NULL) || (!(sts & 1))) {
    printf("Problem getting feature text\n");
    goto wrapup;
  }
  // Paranoid check
  if (attr.text_length < attr.num_char) attr.text_length = attr.num_char;
  
  beg = attr.text_length - attr.num_char;
  len = attr.num_char;
  
  // Damn thing is not null terminated!
  memcpy(buf,str + beg,len);
  *(buf + len) = 0;
  free(str);
  
  //vdobj$Print(objOE = textOE);
  
  //printf("Text %d %s\n",len,buf);
  //printf("Font %d, Just %d, Width %f, Height %f, num_char %d, len %d\n",
  // attr.font,  attr.just, 
  // attr.width, attr.height, 
  // attr.num_char, attr.text_length);
  
  // Need 3d location
  om$send(msg = message GR3dtext.GRgenabsg(&msg,
					   &textOE->mod_env.md_env.matrix_type,
					    textOE->mod_env.md_env.matrix,
					   (IGRchar**)&lbs),
	  senderid = NULL_OBJID,
	  targetid = textOE->obj_id.objid,
	  targetos = textOE->obj_id.osnum);
  
  if (lbs == NULL) {
    printf("Problem getting label location\n");
    goto wrapup;
  }

  VDcvgGet2DRotateAngle(lbs->matrix, &angle);
  //angle = (angle / M_PI) * 180.0;

  //printf("Org %f %f %f, Angle %f\n",org[0],org[1],org[2],angle);

  // Try to make everything left justified
  for(i = 0; i < 3; i++) {
    pt1[i] = 0.0;
    pt2[i] = 0.0;
  }
  if (len > 0) lenx = len;
  else         lenx = 1;
  
  switch(attr.just) {
  case LEFT_BOTTOM:
    pt2[0] = attr.width * lenx;
    break;
    
  case LEFT_CENTER:
    pt1[0] = 0.0;
    pt1[1] =  attr.height * -0.5;

    pt2[0] =  attr.width  * lenx;;
    pt2[1] =  attr.height * -0.5;
    break;

    // Not sure what base means, test later
  case LEFT_BASE: 
    pt2[0] = attr.width * lenx;
    break;
    
  case CENTER_CENTER:
    pt1[0] = (attr.width  * len) * -0.5;
    pt1[1] =  attr.height * -0.5;

    pt2[0] = (attr.width  * lenx) * 0.5;
    pt2[1] =  attr.height * -0.5;
    break;

  case CENTER_BOTTOM: printf("### CENTER_BOTTOM\n"); break;
  case CENTER_BASE:   printf("### CENTER_BASE\n");   break;

  case RIGHT_BOTTOM:  printf("### RIGHT_BOTTOM\n");  break;
  case RIGHT_BASE:    printf("### RIGHT_BASE\n");    break;
  case RIGHT_CENTER:  printf("### RIGHT_CENTER\n");  break;
    
  default:
    printf("*** Text Justification needs cleanup\n");
  }
  // Apply it
  numPoles = 1;
  MAtypemx(&msg,lbs->matrix,&matType);
  MAoptsxform(&msg,&numPoles,&matType,lbs->matrix,pt1,pt1);
  MAoptsxform(&msg,&numPoles,&matType,lbs->matrix,pt2,pt2);

  attr.just = LEFT_BOTTOM;
  
  // Write it
  VDxmlWriteObjBeg(xml,XML_CVG_TEXT,1,0);

  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_X1,pt1[0],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_Y1,pt1[1],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_X2,pt2[0],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_Y2,pt2[1],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_ANGLE,angle,0,1);

  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_HEIGHT,attr.height,1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_WIDTH, attr.width, 0,0);
  VDxmlWriteAtrInt(xml,XML_CVG_TEXT_FONT,  attr.font,  0,0);

  // Translate the justification
  strcpy(just,"UNKNOWN");
  switch(attr.just) {

    // Difference between bottom and base???
  case LEFT_BOTTOM:   strcpy(just,XML_CVG_TEXT_JUST_LL); break;
  case LEFT_BASE:     strcpy(just,XML_CVG_TEXT_JUST_LL); break;
  case LEFT_CENTER:   strcpy(just,XML_CVG_TEXT_JUST_ML); break;

  case CENTER_BOTTOM: strcpy(just,XML_CVG_TEXT_JUST_ML); break;
  case CENTER_BASE:   strcpy(just,XML_CVG_TEXT_JUST_ML); break;
  case CENTER_CENTER: strcpy(just,XML_CVG_TEXT_JUST_MM); break;

  case RIGHT_BOTTOM:  strcpy(just,XML_CVG_TEXT_JUST_LR); break;
  case RIGHT_BASE:    strcpy(just,XML_CVG_TEXT_JUST_LR); break;
  case RIGHT_CENTER:  strcpy(just,XML_CVG_TEXT_JUST_MR); break;

  default:
    printf("Unknown Text Justification %d,%s\n",attr.just,buf);
  }
  VDxmlWriteAtrTxt(xml,XML_CVG_TEXT_JUST, just, 0,1);
  
  // And the value
  VDxmlWriteAtrTxt(xml,XML_CVG_TEXT_VALUE,textHack,1,0);

  // Done
  VDxmlWriteAtrEnd(xml,0,1);
  VDxmlWriteObjEnd(xml,XML_CVG_TEXT,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Gets a Moved text Object
 */
IGRstat VDdrawGetMovedText(TGRobj_env *textOE, TGRobj_env *textOEx)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  i,j;
  
  TGRid ownerID;
  TGRid macroID;
  TGRid pretendID;
  TGRid smtextID;

  TGRobj_env footOE;
  TGRobj_env parentOE;
  
  // Arg check
  if (textOEx == NULL) goto wrapup;
  textOEx->obj_id.objid = NULL_OBJID;
  if (textOE  == NULL) goto wrapup;
  *textOEx = *textOE;
  
  // See if owned by VDdrwGm
  vdchn$Get2(objOE  = textOE,
	     chnIDx = VDCHN_IDX_TO_OWNERS,
	     nth    = 0,
	     outID  = &ownerID);

  if (ownerID.objid == NULL_OBJID) goto wrapup;
  
  sts = vdobj$IsAncestryValid(objID = &ownerID,
			      superClassID = OPP_VDdrwGm_class_id);
  if (!(sts & 1)) goto wrapup;

  // It's is owned by the macro
  vdchn$Get2(objID  = &ownerID,
	     chnIDx = VDCHN_IDX_TO_OWNERS,
	     nth    = 0,
	     outID  = &macroID);
  if (macroID.objid == NULL_OBJID) goto wrapup;
  
  // Cycle through kids looking for ACpretend connection
  for(i = 0; 
      vdchn$Get2(objID = &macroID, chnIDx = VDCHN_IDX_CHILD, nth = i, outID = &pretendID); 
      i++) {

    sts = vdobj$IsAncestryValid(objID = &pretendID, superClassID = OPP_ACpretend_class_id);
    if (sts & 1) {

      // Look for the SMcpTxt Object
      for(j = 0; 
      vdchn$Get2(objID = &pretendID, chnIDx = VDCHN_IDX_CHILD, nth = j, outID = &smtextID); 
	  j++) {

	sts = vdobj$IsAncestryValid(objID = &smtextID, superClassID = OPP_SMCpTxt_class_id);
	if (sts & 1) {


	  // See if it's parent matches the input text
	  vdobj$GetTemplate(objID = &smtextID,
			    nth   = 1,
			    templateOE = &parentOE);

	  //printf("=========================\n");
	  //vdobj$Print(objID = &smtextID);
	  //vdobj$Print(objOE = &parentOE);
	  //vdobj$Print(objOE =  textOE);

	  if ((parentOE.obj_id.objid == textOE->obj_id.objid) && 
	      (parentOE.obj_id.osnum == textOE->obj_id.osnum)) {
	    
	    // The foot is the next text
	    vdobj$GetFoot(objID    = &smtextID,
			  footName = "cptxt",
			  footOE   = &footOE);

	    //vdobj$Print(objOE = &footOE);
	    //printf("--- Matched ---\n");

	    if (footOE.obj_id.objid != NULL_OBJID) {
	      textOEx->obj_id = footOE.obj_id;
	      retFlag = 1;
	      goto wrapup;
	      
	    }
	  } 
	}
      }
    }
  }
  
  // Done
  retFlag = 0;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Utility routine to get the value of a text object
 */
IGRstat VDtextGetValue(TGRobj_env *textOE, IGRchar *value)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRuchar *str = NULL;
  IGRshort len;
  IGRint   i,beg;
  struct IGRestx   attr;
  
  IGRchar  buf[128],*p;

  TGRobj_env textOEx;
  
  // Verify
  if (value == NULL) goto wrapup;
  *value = 0;
  sts = vdobj$IsAncestryValid(objOE = textOE, superClassID = OPP_GR3dtext_class_id);
  if (!(sts & 1)) goto wrapup; 
  
  // Might be consumed by Move Drawing text command
  VDdrawGetMovedText(textOE,&textOEx);
  
  // Get the text
  len = 0;
  sts = om$send(msg = message GRtext.
		GRgettxattr(&msg,
			    &attr,
			    &len,
			    &str),
	  senderid = NULL_OBJID,
	  targetid = textOEx.obj_id.objid,
	  targetos = textOEx.obj_id.osnum);
  
  if ((str == NULL) || (!(sts & 1))) {
    printf("Problem getting feature text\n");
    goto wrapup;
  }
  // Paranoid check
  if (attr.text_length < attr.num_char) attr.text_length = attr.num_char;
  
  beg = attr.text_length - attr.num_char;
  len = attr.num_char;
  
  // Damn thing is not null terminated!
  memcpy(buf,str + beg,len);
  *(buf + len) = 0;
  free(str);

  // Could have control nonsense in it (ESC sequences)
  for(p = buf; *p >= ' '; p++);
  *p = 0;

  // Done
  strcpy(value,buf);  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Writes out a text object
 */
IGRstat VDcvgWriteTextObject(TVDcvgFileInfo *info, TGRobj_env *textOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRuchar *str = NULL;
  IGRshort len;
  IGRint   i,beg;
  IGRdouble angle;
  
  struct IGRlbsys *lbs = NULL;
  struct IGRestx   attr;
  IGRpoint         pt1,pt2;
  IGRint   lenx;
  
  IGRchar  buf[128],*p;
  IGRchar  just[128];
  IGRlong  numPoles;
  IGRshort matType;

  TVDxmlFileInfo *xml = NULL;
  TGRobj_env textOEx;
  
  // Verify
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  sts = vdobj$IsAncestryValid(objOE = textOE, superClassID = OPP_GR3dtext_class_id);
  if (!(sts & 1)) goto wrapup; 
  
  // Might be consumed by Move Drawing text command
  VDdrawGetMovedText(textOE,&textOEx);
  
  // Get the text
  len = 0;
  sts = om$send(msg = message GRtext.
		GRgettxattr(&msg,
			    &attr,
			    &len,
			    &str),
	  senderid = NULL_OBJID,
	  targetid = textOEx.obj_id.objid,
	  targetos = textOEx.obj_id.osnum);
  
  if ((str == NULL) || (!(sts & 1))) {
    printf("Problem getting feature text\n");
    goto wrapup;
  }
  // Paranoid check
  if (attr.text_length < attr.num_char) attr.text_length = attr.num_char;
  
  beg = attr.text_length - attr.num_char;
  len = attr.num_char;
  
  // Damn thing is not null terminated!
  memcpy(buf,str + beg,len);
  *(buf + len) = 0;
  free(str);

  // Debug
#if 0
  if (textOEx.obj_id.objid != textOE->obj_id.objid) {
    
    vdobj$Print(objOE = &textOEx);
  
    printf("Text %d %s\n",len,buf);
    printf("Font %d, Just %d, Width %f, Height %f, num_char %d, len %d\n",
	   attr.font,  attr.just, 
	   attr.width, attr.height, 
	   attr.num_char, attr.text_length);
    for(p = buf; *p != 0; p++) {
      printf("Char %2x '%c'\n",*p,*p);
    }
    
  }
#endif

  // Could have control nonsense in it (ESC sequences)
  for(p = buf; *p >= ' '; p++);
  *p = 0;
  
  // Need 3d location
  om$send(msg = message GR3dtext.GRgenabsg(&msg,
					   &textOEx.mod_env.md_env.matrix_type,
					    textOEx.mod_env.md_env.matrix,
					   (IGRchar**)&lbs),
	  senderid = NULL_OBJID,
	  targetid = textOEx.obj_id.objid,
	  targetos = textOEx.obj_id.osnum);
  
  if (lbs == NULL) {
    printf("Problem getting label location\n");
    goto wrapup;
  }

  VDcvgGet2DRotateAngle(lbs->matrix, &angle);
  //angle = (angle / M_PI) * 180.0;

  //printf("Org %f %f %f, Angle %f\n",org[0],org[1],org[2],angle);

  // Try to make everything left justified
  for(i = 0; i < 3; i++) {
    pt1[i] = 0.0;
    pt2[i] = 0.0;
  }
  if (len > 0) lenx = len;
  else         lenx = 1;
  
  switch(attr.just) {
  case LEFT_BOTTOM:
    pt2[0] = attr.width * lenx;
    break;
    
  case LEFT_CENTER:
    pt1[0] = 0.0;
    pt1[1] =  attr.height * -0.5;

    pt2[0] =  attr.width  * lenx;;
    pt2[1] =  attr.height * -0.5;
    break;

    // Not sure what base means, test later
  case LEFT_BASE: 
    pt2[0] = attr.width * lenx;
    break;
    
  case CENTER_CENTER:
    pt1[0] = (attr.width  * len) * -0.5;
    pt1[1] =  attr.height * -0.5;

    pt2[0] = (attr.width  * lenx) * 0.5;
    pt2[1] =  attr.height * -0.5;
    break;

  case CENTER_BOTTOM: printf("### CENTER_BOTTOM\n"); break;
  case CENTER_BASE:   printf("### CENTER_BASE\n");   break;

  case RIGHT_BOTTOM:  printf("### RIGHT_BOTTOM\n");  break;
  case RIGHT_BASE:    printf("### RIGHT_BASE\n");    break;
  case RIGHT_CENTER:  printf("### RIGHT_CENTER\n");  break;
    
  default:
    printf("*** Text Justification needs cleanup\n");
  }
  // Apply it
  numPoles = 1;
  MAtypemx(&msg,lbs->matrix,&matType);
  MAoptsxform(&msg,&numPoles,&matType,lbs->matrix,pt1,pt1);
  MAoptsxform(&msg,&numPoles,&matType,lbs->matrix,pt2,pt2);

  attr.just = LEFT_BOTTOM;
  
  // Write it
  VDxmlWriteObjBeg(xml,XML_CVG_TEXT,1,0);

  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_X1,pt1[0],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_Y1,pt1[1],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_X2,pt2[0],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_Y2,pt2[1],   0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_ANGLE,angle,0,1);

  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_HEIGHT,attr.height,1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_TEXT_WIDTH, attr.width, 0,0);
  VDxmlWriteAtrInt(xml,XML_CVG_TEXT_FONT,  attr.font,  0,0);

  // Translate the justification
  strcpy(just,"UNKNOWN");
  switch(attr.just) {

    // Difference between bottom and base???
  case LEFT_BOTTOM:   strcpy(just,XML_CVG_TEXT_JUST_LL); break;
  case LEFT_BASE:     strcpy(just,XML_CVG_TEXT_JUST_LL); break;
  case LEFT_CENTER:   strcpy(just,XML_CVG_TEXT_JUST_ML); break;

  case CENTER_BOTTOM: strcpy(just,XML_CVG_TEXT_JUST_ML); break;
  case CENTER_BASE:   strcpy(just,XML_CVG_TEXT_JUST_ML); break;
  case CENTER_CENTER: strcpy(just,XML_CVG_TEXT_JUST_MM); break;

  case RIGHT_BOTTOM:  strcpy(just,XML_CVG_TEXT_JUST_LR); break;
  case RIGHT_BASE:    strcpy(just,XML_CVG_TEXT_JUST_LR); break;
  case RIGHT_CENTER:  strcpy(just,XML_CVG_TEXT_JUST_MR); break;

  default:
    printf("Unknown Text Justification %d,%s\n",attr.just,buf);
  }
  VDxmlWriteAtrTxt(xml,XML_CVG_TEXT_JUST, just, 0,1);
  
  // And the value
  VDxmlWriteAtrTxt(xml,XML_CVG_TEXT_VALUE,buf,1,0);

  // Done
  VDxmlWriteAtrEnd(xml,0,1);
  VDxmlWriteObjEnd(xml,XML_CVG_TEXT,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write any primitive object
 * Currently handles curves and text
 */
IGRstat VDcvgWriteObject(TVDcvgFileInfo *info, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Check for curve
  sts = vdobj$IsAncestryValid(objOE = objOE, superClassID = OPP_GRcurve_class_id);
  if (sts & 1) {
    retFlag = VDcvgWritePathObject(info,-1,objOE);
    goto wrapup;
  }
  
  // Check for text
  sts = vdobj$IsAncestryValid(objOE = objOE, superClassID = OPP_GR3dtext_class_id);
  if (sts & 1) {
    retFlag = VDcvgWriteTextObject(info,objOE);
    goto wrapup;
  }

  // Problem
  printf("*** Unable to write cvg object\n");
  vdobj$Print(objOE = objOE);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Hacked for text objects
 * override the internal value with the passwd value
 *
 * Write any primitive object
 * Currently handles curves and text
 */
IGRstat VDcvgWriteObjectTextHack(TVDcvgFileInfo *info, TGRobj_env *objOE, IGRchar *textHack)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Check for curve
  sts = vdobj$IsAncestryValid(objOE = objOE, superClassID = OPP_GRcurve_class_id);
  if (sts & 1) {
    retFlag = VDcvgWritePathObject(info,-1,objOE);
    goto wrapup;
  }
  
  // Check for text
  sts = vdobj$IsAncestryValid(objOE = objOE, superClassID = OPP_GR3dtext_class_id);
  if (sts & 1) {
    retFlag = VDcvgWriteTextObjectTextHack(info,objOE,textHack);
    goto wrapup;
  }

  // Problem
  printf("*** Unable to write cvg object\n");
  vdobj$Print(objOE = objOE);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a 2d point
 */
IGRstat VDcvgWritePoint2D(TVDcvgFileInfo *info, IGRdouble *pt)
{
  IGRstat retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (pt   == NULL) goto wrapup;
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  // Do it
  VDxmlWriteObjBeg(xml,XML_CVG_POINT,1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_POINT_X,pt[0],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_POINT_Y,pt[1],0,0);
  VDxmlWriteAtrEnd(xml,0,0);
  VDxmlWriteObjEnd(xml,XML_CVG_POINT,0);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out a 3d point
 */
IGRstat VDcvgWritePoint3D(TVDcvgFileInfo *info, IGRdouble *pt)
{
  IGRstat retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (pt   == NULL) goto wrapup;
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  // Do it
  VDxmlWriteObjBeg(xml,XML_CVG_POINT,1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_POINT_X,pt[0],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_POINT_Y,pt[1],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_POINT_Z,pt[2],0,0);
  VDxmlWriteAtrEnd(xml,0,0);
  VDxmlWriteObjEnd(xml,XML_CVG_POINT,0);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDSroot;





