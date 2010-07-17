/* $Id: VLunwMisc.I,v 1.6 2002/04/09 20:54:13 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLunwMisc.I
 *
 * Description: Some Misc Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwMisc.I,v $
 *      Revision 1.6  2002/04/09 20:54:13  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/07 21:00:38  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/06 15:54:15  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/21 13:02:34  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/20 01:07:53  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.3  2000/08/21  19:04:08  pinnacle
# ah
#
# Revision 1.2  2000/06/19  18:39:36  pinnacle
# ah
#
# Revision 1.1  2000/05/24  13:23:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/13/99  ah      Creation
 * 04/18/00  ah      Make stock case insensitive
 * 06/14/00  ah      Moved bevel stuff to it's own file
 * 05/17/01  ah      GetComp/Feat can now return count
 ***************************************************************************/

class implementation VLunwObj;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VDsa.h"

#include "vddrwattr.h"
#include "vlmsg.h"
#include "vlstructure.h"
#include "vlunwext.h"

#include "VLunwMisc.h"

#include "mainvmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maoptsxfo.h"

#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

static int traceFlag;

extern VDclassid OPP_GRbcsubbc_class_id;
extern VDclassid OPP_GR3dtext_class_id;
extern VDclassid OPP_GR3dcircle_class_id;
extern VDclassid OPP_GR3dlinestr_class_id;
extern VDclassid OPP_VSedge3Datt_class_id;

from ACrg_collect import ACget_named_attribute;
from ACrg_collect import AClist_attribute;
from GRcurve      import GRendpts;

/* -----------------------------------------------
 * Copy the 2d unwrap contour to 3d space
 */
IGRstat VLunwCopyContour(TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  
  TGRobj_env contourOE;
  TGRobj_env contourOEx;
  
  IGRdouble pt2d[16],pt3d[16];
		
  // Get the contour
  VLunwGetExternalContour(unwrapOE,&contourOE);
  if (contourOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Copy It
  VLunwCopyObject(unwrapOE,1,&contourOE,&contourOEx);

  // The little markers
  VLunwGet3DPts(unwrapOE,pt2d,pt3d);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the 3d reference points for mapping an
 * unwrap back to model space
 *
 * In 3d space
 * Use the left hand, point thumb in the x (the short) direction
 * Point fingers in the y direction
 * Palm should face material direction
 *
 * In the 2d (unwrap space) always get the same points regardless
 * of base or offset being presented
 */
IGRstat VLunwGet3DPts(TGRobj_env *unwrapOE, IGRdouble *pt2d, IGRdouble *pt3d)
{
  IGRstat retFlag = 0;
  IGRstat msg,sts;
  
  IGRdouble toMat  [16];
  IGRdouble fromMat[16];
  IGRdouble tmpMat [16];
  IGRdouble trfMat [16];

  IGRshort  trfMatType;
  IGRshort  four = 4;
  IGRlong   numPoles;
  
  TGRid     obj2dID;
  TGRid     obj3dID;
  
  IGRint i,j;
  
  GRrange range;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  if (pt2d == NULL) goto wrapup;
  if (pt3d == NULL) goto wrapup;
  for(i = 0; i < 9; i++) {
    pt2d[i] = 0.0;
    pt3d[i] = 0.0;
  }
  
  // Set the Z depth to the unwrap's z
  VLunwGetRange(unwrapOE,range);
  pt2d[0] = range[0];
  pt2d[1] = range[1];
  pt2d[2] = range[2];
  pt2d[3] = range[3];
  pt2d[4] = range[1];
  pt2d[5] = range[2];
  pt2d[6] = range[0];
  pt2d[7] = range[4];
  pt2d[8] = range[2];
    
  // Get the matrix, switch order on purpose
  sts = VLunwGetMatrixes(unwrapOE,toMat,fromMat);
  if (!(sts & 1)) goto wrapup;
  
  // Copied this nonsense from VLapplyTransf
  MAinvmx (&msg, &four, fromMat, tmpMat);
  MAmulmx (&msg, &four, &four, &four, toMat, tmpMat, trfMat);
  MAtypemx(&msg, trfMat,&trfMatType);

  // To make vectors
  //pt2d[3] += 1000.0;
  //pt2d[7] += 2000.0;

  // Transform
  numPoles = 3;
  MAoptsxform(&msg,&numPoles,
	      &trfMatType,trfMat,
	       pt2d,pt3d);
   
  // Place them
  //VDdrawLinear(3,pt2d,NULL,&obj2dID);
  //VDdrawLinear(3,pt3d,NULL,&obj3dID);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Copy an object from one space to another
 * Use the current symbology
 */
IGRstat VLunwCopyObject(TGRobj_env *unwrapOE, 
			IGRint      dir,
			TGRobj_env *fromOE, 
			TGRobj_env *toOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRshort  trfMatType;
  IGRdouble trfMat[16];
  
  TGRsymbology symb;
  
  // Arg check
  if (fromOE   == NULL) goto wrapup;
  if (toOE     == NULL) goto wrapup;
  if (unwrapOE == NULL) goto wrapup;

  // Get the matrix
  VLunwGetMatrix(unwrapOE,dir,&trfMatType,trfMat);

  // Get current symbology
  VDahGetActiveSymbology(&symb);
  
  // Copy it
  *toOE = *fromOE;
  toOE->obj_id.objid = NULL_OBJID;

  vd_$grCopy(msg    = &msg, 
	     frEnv  = &fromOE->mod_env, 
	     frObj  = &fromOE->obj_id, 
	     toEnv  = &toOE->mod_env, 
	     mxType = trfMatType, 
	     mx     = trfMat,
	     symb   = &symb,
	     toObj  = &toOE->obj_id);
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Apply a transformation from 3d space to
 * unwrap space on an object
 */
IGRstat VLunwTransform(TGRobj_env *unwrapOE, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRdouble toMat  [16];
  IGRdouble fromMat[16];
  IGRdouble tmpMat [16];
  IGRdouble trfMat [16];

  IGRshort  trfMatType;
  IGRshort  four = 4;
  
  TGRid newID;
  
  // Arg check
  if (objOE    == NULL) goto wrapup;
  if (unwrapOE == NULL) goto wrapup;
  
  // Get the matrixes
  sts = VLunwGetMatrixes(unwrapOE,fromMat,toMat);
  if (!(sts & 1)) goto wrapup;

  // Copied this nonsense from VLapplyTransf
  MAinvmx (&msg, &four, fromMat, tmpMat);
  MAmulmx (&msg, &four, &four, &four, toMat, tmpMat, trfMat);
  MAtypemx(&msg, trfMat,&trfMatType);
  
  // Apply It
  sts = om$send(msg = message GRgraphics.
		GRxform(&msg,
			&objOE->mod_env,
			&trfMatType,
			 trfMat,
			&newID.objid),
		senderid = NULL_OBJID,
		targetid = objOE->obj_id.objid,
		targetos = objOE->obj_id.osnum);

  // Check for new object

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get a transformation matrix either 3d to 2d or
 * 2d to 3d
 */
IGRstat VLunwGetMatrix(TGRobj_env *unwrapOE, 
		       IGRint      dir,        // 0 - 3d to 2d
		       IGRshort   *trfMatType,
		       IGRdouble  *trfMat)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRdouble toMat  [16];
  IGRdouble fromMat[16];
  IGRdouble tmpMat [16];
  IGRshort  four = 4;
  
  TGRid newID;
  
  // Arg check
  if (unwrapOE   == NULL) goto wrapup;
  if (trfMatType == NULL) goto wrapup;
  if (trfMat     == NULL) goto wrapup;
  
  // Get the matrixes
  if (dir == 0) sts = VLunwGetMatrixes(unwrapOE,fromMat,toMat);
  else          sts = VLunwGetMatrixes(unwrapOE,toMat,fromMat);
  if (!(sts & 1)) goto wrapup;

  // Copied this nonsense from VLapplyTransf
  MAinvmx (&msg, &four, fromMat, tmpMat);
  MAmulmx (&msg, &four, &four, &four, toMat, tmpMat, trfMat);
  MAtypemx(&msg, trfMat,trfMatType);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Get the transformation matrixes stored
 * as instance data
 */
IGRstat VLunwGetMatrixes(TGRobj_env *unwrapOE, 
			 IGRdouble  *fromMat, 
			 IGRdouble  *toMat)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  VDpartAttr attr;

  // Arg check (set matrixes to identity???)
  if (unwrapOE == NULL) goto wrapup;
  if ((fromMat == NULL) || (toMat == NULL)) goto wrapup;
  
  attr.Iwant = VL_I_fromMat ;
  attr.specific = (void *) fromMat;
  sts = om$send(msg = message GRvg.GRgetattr(&msg, (char *)&attr),
		senderid = NULL_OBJID,
		targetid = unwrapOE->obj_id.objid,
		targetos = unwrapOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("*** Problem getting the from matrix for\n");
    vdobj$Print(objOE = unwrapOE);
    goto wrapup;
  }

  attr.Iwant = VL_I_toMat ;
  attr.specific = (void *) toMat;
  sts = om$send(msg = message GRvg.GRgetattr(&msg, (char *)&attr),
		senderid = NULL_OBJID,
		targetid = unwrapOE->obj_id.objid,
		targetos = unwrapOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("*** Problem getting the to matrix for\n");
    vdobj$Print(objOE = unwrapOE);
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the unwrap object for a feature
 */
from VLunwFeat import VLgetUnw_obj;

IGRstat VLunwGetUnwrapForFeature(TGRobj_env *featureOE, TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid   unwrapID;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  unwrapOE->obj_id.objid = NULL_OBJID;
  if (featureOE == NULL) goto wrapup;
  
  // Use the official method
  unwrapID.objid = NULL_OBJID;
  sts = om$send(msg = message VLunwFeat.
		VLgetUnw_obj(&msg,&unwrapID),
		senderid = NULL_OBJID,
		targetid = featureOE->obj_id.objid,
		targetos = featureOE->obj_id.osnum);
  if (unwrapID.objid == NULL_OBJID) goto wrapup;
  
  // Transfer
  *unwrapOE = *featureOE;
  unwrapOE->obj_id = unwrapID;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Get the unwrap object for a plate
 */
IGRstat VLunwGetUnwrapForPlate(TGRobj_env *plateOE, TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  TGRid   unwrapID;
  
  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  unwrapOE->obj_id.objid = NULL_OBJID;
  if (plateOE == NULL) goto wrapup;
  
  // Get the unwrap
  vdchn$GetChildrenByClass(objOE     = plateOE,
			   className = "VLunwObj",
			   childID   = &unwrapID);
  // vdobj$Print(objOE = plateOE);
  // vdobj$Print(objID = &unwrapID);
  
  if (unwrapID.objid == NULL_OBJID) goto wrapup;
 
  // Assume identity matrix
  unwrapOE->obj_id = unwrapID;
  unwrapOE->mod_env.md_env.matrix_type = MAIDMX;
  MAidmx(&msg,unwrapOE->mod_env.md_env.matrix);
  
  // Set md_id 
  unwrapOE->mod_env.md_id.osnum = unwrapID.osnum;
  ex$get_modid(mod_osnum =  unwrapOE->mod_env.md_id.osnum, 
	       mod_id    = &unwrapOE->mod_env.md_id.objid);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Opens the unwrap_setup file given the file name
 * Optionally return the full setup file path
 */
FILE *VLunwOpenSetupFilex(IGRchar *fileName, IGRchar *a_filePath)
{
  FILE   *file = NULL;
  IGRchar filePath[1024];
  IGRchar initPath[1024];
  
  IGRint  i;
  
  // Arg check
  if (a_filePath) *a_filePath = 0;
  if ((fileName == NULL) || (*fileName == 0)) goto wrapup;
  
  // Try local directory first
  file = fopen(fileName,"rt");
  if (file) {
    if (a_filePath) strcpy(a_filePath,fileName);
    goto wrapup;
  }
  
  // Flip through paths
  i = 0;
  while(1) {

    *initPath = 0;
    ex$get_path(index = i,
		path  = initPath,
		len   = sizeof(initPath),
		type  = EX_CONFIG_PATH);

    if (*initPath == 0) goto wrapup;
    
    sprintf(filePath,"%sconfig/drawing/%s",initPath,fileName);
    file = fopen(filePath,"rt");
    if (file) {
      //printf("Setup %s\n",filePath);
      if (a_filePath) strcpy(a_filePath,filePath);
      goto wrapup;
    }
    
    i++;
  }
  
wrapup:
  return file;
}

/* -----------------------------------------------
 * Opens the unwrap_setup file
 * Optionally return the full setup file path
 */
FILE *VLunwOpenSetupFile(TGRobj_env *unwrapOE, IGRchar *a_filePath)
{
  IGRstat msg,sts;

  FILE   *file = NULL;
  IGRchar fileName[1024];
  
  VDpartAttr attr;
  
  // Arg check
  if (a_filePath) *a_filePath = 0;
  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Get the file name
  attr.Iwant = VD_I_drwVisual;
  *attr.aString = 0;
  sts = om$send(msg = message GRvg.GRgetattr(&msg,(char *)&attr),
		senderid = NULL_OBJID,
		targetos = unwrapOE->obj_id.osnum,
		targetid = unwrapOE->obj_id.objid);
  strcpy(fileName,attr.aString);
  if (*fileName == 0) strcpy(fileName,"unwrap_setup");
 
  // Use the x routine
  file = VLunwOpenSetupFilex(fileName,a_filePath);
    
wrapup:
  return file;
}

/* -----------------------------------------------
 * Gets the symbology for the given extracted element
 * from the buffer 
 */
IGRstat VLunwGetSymbologyFromBuf(IGRchar *buf, IGRchar *type, TGRsymbology *symb)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  // Arg check
  if (symb == NULL) goto wrapup;
  if (type == NULL) goto wrapup;
  if (buf  == NULL) goto wrapup;
  
  // Look for ext flag
  if (strncmp(buf,"#EXT ",5)) goto wrapup;
  
  // Look for the type
  p = strstr(buf,type);
  if (p == NULL) goto wrapup;
  
  // Got it
  retFlag = 1;
  
  // Level
  for(; *p  > ' '; p++);
  for(; *p == ' '; p++);
  if (*p < ' ') goto wrapup;
  symb->level = atoi(p);
  
  // Color
  for(; *p  > ' '; p++);
  for(; *p == ' '; p++);
  if (*p < ' ') goto wrapup;
  symb->display_attr.color = atoi(p);

  // Weight
  for(; *p  > ' '; p++);
  for(; *p == ' '; p++);
  if (*p < ' ') goto wrapup;
  symb->display_attr.weight = atoi(p);

  // Style
  for(; *p  > ' '; p++);
  for(; *p == ' '; p++);
  if (*p < ' ') goto wrapup;
  symb->display_attr.style = atoi(p);

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Gets the symbology for the given extracted element
 */
IGRstat VLunwGetSymbologyFromSetupFile(TGRobj_env   *unwrapOE, 
				       IGRchar      *type, 
				       TGRsymbology *symb)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  FILE   *file = NULL;
  
  IGRchar buf[1024];
  
  // Arg check
  if (symb == NULL) goto wrapup;
  memset(symb,0,sizeof(TGRsymbology));
  if (type == 0) goto wrapup;
  
  // In case of a problem, hardcode default values
  if (!strcmp(type,VLEXT_TYPE_CONTOUR)) {
    symb->level               = 400;
    symb->display_attr.color  =  21;
    symb->display_attr.weight =   0;
    symb->display_attr.style  =   0;
  }
  if (!strcmp(type,VLEXT_TYPE_MIN_REC)) {
    symb->level               = 401;
    symb->display_attr.color  =  21;
    symb->display_attr.weight =   0;
    symb->display_attr.style  =   0;
  }
  if (!strcmp(type,VLEXT_TYPE_STOCK_LINE)) {
    symb->level               = 400;
    symb->display_attr.color  =  21;
    symb->display_attr.weight =   0;
    symb->display_attr.style  =   1;
  }
  if (!strcmp(type,VLEXT_TYPE_STOCK_TEXT)) {
    symb->level               = 400;
    symb->display_attr.color  =  21;
    symb->display_attr.weight =   1;
    symb->display_attr.style  =   0;
  }
  if (symb->level == 0) goto wrapup;
  
  // Return true from here
  retFlag = 1;
  
  // Open the setup file
  file = VLunwOpenSetupFile(unwrapOE,NULL);
  if (file == NULL) goto wrapup;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {

    sts = VLunwGetSymbologyFromBuf(buf,type,symb);
    if (sts & 1) goto wrapup;
    
  }
  
wrapup:
  if (file) fclose(file);
  
  return retFlag;
}

/* ------------------------------------------------------
 * Check to see if the symbology of the object matches
 * the symb information
 */
IGRstat VLunwCheckSymbology(TGRid *objID, TGRsymbology *a_symb)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRsymbology symb;
  
  // Arg check
  if (a_symb == NULL) goto wrapup;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // Get the symbology
  sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);
  if (!(sts & msg & 1)) goto wrapup;
  
  // Compare
  if (symb.level != a_symb->level) goto wrapup;

  if (symb.display_attr.color  != a_symb->display_attr.color)  goto wrapup;
  if (symb.display_attr.weight != a_symb->display_attr.weight) goto wrapup;
  if (symb.display_attr.style  != a_symb->display_attr.style)  goto wrapup;
  
  // Got it
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * This generic routine gets all the objects of a given
 * type (as defined by symbology) from the component channel
 * of the unwrap
 *
 * compOEs can be NULL, count is returned
 */
IGRstat VLunwGetComponents(TGRobj_env *unwrapOE, 
			   IGRchar    *type, 
			   IGRint      max, 
			   IGRint     *cnt, 
			   TGRobj_env *compOEs)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env drwOE;
  IGRint     i;
  TGRid      compID;
  
  TGRsymbology symb;
  IGRchar buf[128];
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  // if (compOEs == NULL) goto wrapup;
  if (type == NULL) goto wrapup;
  
  // Get the drawing object
  VLunwGetDrawingObject(unwrapOE,&drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // get the symbology
  VLunwGetSymbologyFromSetupFile(unwrapOE,type,&symb);
  if (symb.level == 0) goto wrapup;

  // Cycle through skipping the outer contour
  for(i = 1;
      vdchn$Get2(objOE  = &drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &compID);
      i++) {

    sts = VLunwCheckSymbology(&compID,&symb);
    if (sts & 1) {
      if (compOEs) {
	if (*cnt >= max) goto wrapup;
	compOEs[*cnt].obj_id  = compID;
	compOEs[*cnt].mod_env = unwrapOE->mod_env;
      }      
      *cnt = *cnt + 1;

      // For stock, look ahead one and see if it's text
      // Pairs up text with graphics
      // Works around text symboogy problems
      if (!strcmp(type,VLEXT_TYPE_STOCK_LINE)) {

	vdchn$Get2(objOE  = &drwOE, 
		   chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		   nth    = i + 1, 
		   outID  = &compID);
	if (compID.objid != NULL_OBJID) {

	  VDcvgGetTextInfo(NULL,&compID,buf,128,NULL);
	  VDstrupr(buf);
	  
	  if (!strcmp(buf,"STOCK")) {

	    // Add it
	    if (compOEs) { 
	      if (*cnt >= max) goto wrapup;
	      compOEs[*cnt].obj_id  = compID;
	      compOEs[*cnt].mod_env = unwrapOE->mod_env;
	    }
	    *cnt = *cnt + 1;
	    i++;
	    
	  }
	  else {
	    printf("*** Stock curve with no text!!!\n");
	    goto wrapup;
	  }
	}
	else {
	  printf("*** Sotck curve with no text!!!\n");
	  goto wrapup;
	}
      }
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Gets the drawing object from the unwrap
 */
IGRstat VLunwGetDrawingObject(TGRobj_env *unwrapOE, TGRobj_env *drwOE)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (drwOE == NULL) goto wrapup;
  drwOE->obj_id.objid = NULL_OBJID;

  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Get the foot
  vdobj$GetFoot(objOE = unwrapOE, footName = "geom", footOE = drwOE);
  if (drwOE->obj_id.objid == NULL_OBJID) goto wrapup;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Given a drawing object and a component channel index
 * determine if the index points to a stock curve/text pair
 */
IGRstat VLunwIsComponentStock(TGRobj_env *drwOE, IGRint nth)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid   textID;

  IGRchar buf[256];
  
  // Arg check
  if (drwOE == NULL) goto wrapup;
  if (nth < 1)       goto wrapup;
  
  // Get the possible text
  vdchn$Get2(objOE  = drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     nth    = nth, 
	     outID  = &textID);
  if (textID.objid == NULL_OBJID) goto wrapup;
  
  // See if got a text object
  sts = vdobj$IsAncestryValid(objID = &textID, superClassID = OPP_GR3dtext_class_id);
  if (!(sts & 1)) goto wrapup;
  
  // Get it's value
  VDcvgGetTextInfo(NULL,&textID,buf,0,NULL);
  VDstrlwr(buf);
  if (strcmp(buf,"stock")) {
    printf("*** Warning text as component of VDdrwGm %s\n",buf);
    goto wrapup;
  }
  
  // Take it on faith that the component before this is the stock curve

  // Got it
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Finds the index on the component channel of the
 * Min Rec line string on the VDdrwGm object for the unwrap
 * 
 * The structure looks like this (I think)
 * Composite Curve (Outer Contour)
 * 0 or more inner contours (cutting curves)
 * The min rec line string
 * 0 or more curve/text pairs for stock lines
 *
 * Need to go through the ACconstruct_feet to verify this
 * Need to see if any other types of obejects end up here
 *
 */
IGRstat VLunwGetMinRectIndex(TGRobj_env *unwrapOE, IGRint *nth)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint     cnt,i;
  TGRobj_env drwOE;
  TGRid      recID;
  
  // Arg check
  if (nth == NULL) goto wrapup;
  *nth = 1;
  if (unwrapOE == NULL) goto wrapup;
  
  // Get the drawing object
  vdobj$GetFoot(objOE = unwrapOE, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Need to work backwards on the component channel
  vdchn$Get2(objOE  = &drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     cnt    = &cnt);

  // Skip any stock lines
  for(i = cnt - 1; i > 0; i = i - 2) {
    sts = VLunwIsComponentStock(&drwOE,i);
    if (!(sts & 1)) {

      // Get it, make sure it's a line string
      vdchn$Get2(objOE  = &drwOE, 
		 chnIDx = VDCHN_IDX_TO_COMPONENTS, 
		 nth    = i, 
		 outID  = &recID);

      sts = vdobj$IsAncestryValid(objID = &recID,
				  superClassID = OPP_GR3dlinestr_class_id);
      if (!(sts & 1)) {
	printf("*** Warning: Have Min Rect which is not a line string\n");
	vdobj$Print(objID = &recID);
      }
      
      // Should probably verify have a line string here
      *nth = i;
      retFlag = 1;
      goto wrapup;
    }
  }

  // Done
  retFlag = 0;
    
wrapup:
  return retFlag;
}
  
/* ------------------------------------------------------
 * Determines if a given object is in fact a contour
 * Mainly for error checking
 */
IGRstat VLunwIsInternalContour(TGRobj_env *unwrapOE, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // All contours are GRbcsubbc (I think)
  sts = vdobj$IsAncestryValid(objID = objID,
			      superClassID = OPP_GRbcsubbc_class_id);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Circles are ok
  sts = vdobj$IsAncestryValid(objID = objID,
			      superClassID = OPP_GR3dcircle_class_id);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Expect to get some text objects which can be ignored
  sts = vdobj$IsAncestryValid(objID = objID,
			      superClassID = OPP_GR3dtext_class_id);
  if (sts & 1) goto wrapup;

  /* -------------------------------------------------------
   * For now, ignore line strings as it's the min rectangle
   * Need to find a way to tell if the component is the min rect
   * or is an internal cutout
   */
  sts = vdobj$IsAncestryValid(objID = objID,
			      superClassID = OPP_GR3dlinestr_class_id);
  if (sts & 1) goto wrapup;
  
  // Anything else is unexpected
  printf("*** Unexpected internal contour for\n");
  vdobj$Print(objOE = unwrapOE);
  vdobj$Print(objID = objID);
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Returns a list of internal contours
 */
IGRstat VLunwGetInternalContours(TGRobj_env *unwrapOE,
				 IGRint      contourMax,
				 IGRint     *contourCnt,
				 TGRobj_env *contourOEs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;
  
  TGRobj_env drwOE;
  TGRid      objID;
  
  IGRint     i;
  IGRint     nth;
  
  // Arg check
  if (contourCnt == NULL) goto wrapup;
  *contourCnt = 0;
  if (contourOEs == NULL) goto wrapup;

  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Need the VDdrwGm foot
  vdobj$GetFoot(objOE = unwrapOE, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // All objects between the contour and the min rec are cutting curves?
  VLunwGetMinRectIndex(unwrapOE,&nth);
  
  // Return all GRbcsubbc on the component channel
  for(i = 1; i < nth; i++) {
    
    vdchn$Get2(objOE  = &drwOE, 
	       chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	       nth    = i, 
	       outID  = &objID);
      
    // Just a check
    sts = VLunwIsInternalContour(unwrapOE,&objID);
    
    if (sts & 1) {
      if (*contourCnt >= contourMax) {
	printf("*** Buffer overflow in internal contours\n");
	goto wrapup;
      }
      contourOEs[*contourCnt].obj_id = objID;
      contourOEs[*contourCnt].mod_env = unwrapOE->mod_env;
      *contourCnt = *contourCnt + 1;
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * In many cases, features do not actually cause markings
 * on the plate.  For example, waterlines which are perpendicular
 * to the plate show up as features with no graphics.
 *
 * Filter these out
 */
IGRstat VLunwIsFeatureValid(TGRid *featureID)
{
  IGRstat    retFlag = 0;
  TGRobj_env drwOE;
  IGRint     cnt;
  
  // Arg check
  if (featureID == NULL) goto wrapup;

  // Need the VDdrwGm foot
  vdobj$GetFoot(objID = featureID, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // See if have any attached feet
  vdchn$Get2(objOE  = &drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     cnt    = &cnt);
  if (cnt == 0) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Returns a list of features
 * Retruns count if featuresOE is NULL
 */
IGRstat VLunwGetFeatures(TGRobj_env *unwrapOE,
			 IGRint      featureMax,
			 IGRint     *featureCnt,
			 TGRobj_env *featureOEs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;
  
  TGRid      featureID;
  
  IGRint     i;
  
  // Arg check
  if (featureCnt == NULL) goto wrapup;
  *featureCnt = 0;
  // if (featureOEs == NULL) goto wrapup;

  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Transfer everything on the to_feature channel
  for(i = 0; 
      vdchn$Get2(objOE   = unwrapOE, 
		 chnName = "VLunwObj.to_feat", 
		 nth     = i, 
		 outID   = &featureID);
      i++) {

    // Make sure it's really a valid feature
    sts = VLunwIsFeatureValid(&featureID);
    if (sts & 1) {
      
      // Check for overflow
      if (featureOEs) {
	
	if (*featureCnt >= featureMax) {
	  // printf("*** Buffer overflow while getting features\n");
	  goto wrapup;
	}
	featureOEs[*featureCnt].obj_id = featureID;
	featureOEs[*featureCnt].mod_env = unwrapOE->mod_env;
      }
      *featureCnt = *featureCnt + 1;
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * Standard interface to min rectangle
 *
 * Have to assume that the 3dlinestr in the min rect, there does not appear
 * to be any way to tell for sure, sometimes it's last, sometimes it's not
 *
 * Updated to search by symbology
 *
 * Just a wrapper to the get components routine
 */
IGRstat VLunwGetMinRectangle(TGRobj_env *unwrapOE, TGRobj_env *rectOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  cnt,i;
  
  TGRobj_env compOEs[10];
  
  // Arg check
  if (rectOE == NULL) goto wrapup;
  rectOE->obj_id.objid = NULL_OBJID;
  
  // Get the component
  cnt = 0;
  VLunwGetComponents(unwrapOE,VLEXT_TYPE_MIN_REC,10,&cnt,compOEs);
  if (cnt < 1) {
    printf("*** No min rect candidates found for\n");
    vdobj$Print(objOE = unwrapOE);
    goto wrapup;
  }
  if (cnt > 1) {
    printf("*** More than one min rect candidate found for\n");
    vdobj$Print(objOE = unwrapOE);
    for(i = 0; i < cnt; i++) {
      vdobj$Print(objOE = &compOEs[i]);
    }
    goto wrapup;
  }
  
  // Verify it's a line string
  sts = vdobj$IsAncestryValid(objOE = &compOEs[0],
			      superClassID = OPP_GR3dlinestr_class_id);
  if (!(sts & 1)) {
    printf("*** Min rect candidate is not a line string for\n");
    vdobj$Print(objOE = unwrapOE);
    vdobj$Print(objOE = &compOEs[0]);
    goto wrapup;
  }

  // Got it
  *rectOE = compOEs[0];
  retFlag = 1;
    
wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * The external contour of the plate is always the first
 * component of the drawing object, at least I hope so
 */
IGRstat VLunwGetExternalContour(TGRobj_env *unwrapOE, TGRobj_env *contourOE)
{
  IGRstat retFlag = 0;
  TGRobj_env drwOE;
  
  // Arg check
  if (contourOE == NULL) goto wrapup;
  contourOE->obj_id.objid = NULL_OBJID;
  
  // Get the drawing object
  VLunwGetDrawingObject(unwrapOE,&drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // First object on the channel should be the contour
  vdchn$Get2(objOE  = &drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     nth    = 0, 
	     outID  = &contourOE->obj_id);

  if (traceFlag) vdobj$Print(objOE = contourOE);
  if (contourOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  // In the same os as the unwrap
  contourOE->mod_env = unwrapOE->mod_env;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Wrap the get range code as well
 * The overridden method GRgetrang does not seem to work
 * Status codes always fail and get zero for data
 */
IGRstat VLunwGetRange(TGRobj_env *unwrapOE, GRrange range)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRboolean world = TRUE;
  
  // Arg check
  if (range == NULL) goto wrapup;
  if ((unwrapOE == NULL) || (unwrapOE->obj_id.objid == NULL_OBJID)) goto wrapup;
#if 0
  // Cross fingers and hope this works
  sts = om$send(msg = message VLunwObj.
		GRgetrang(&msg,
			  &unwrapOE->mod_env.md_env.matrix_type,
			   unwrapOE->mod_env.md_env.matrix,
			  &world,
			   range),
		senderid = NULL_OBJID,
		targetid = unwrapOE->obj_id.objid,
		targetos = unwrapOE->obj_id.osnum);
  if (!(sts & msg & 1)) {
    printf("Problem getting range\n");
  }
  if (traceFlag) {  
    printf("Range %8.2f %8.2f %8.2f\n",range[0],range[1],range[2]);
    printf("      %8.2f %8.2f %8.2f\n",range[3],range[4],range[5]);
  }
#endif
  // Cross fingers and hope this works
  world = FALSE;
  sts = om$send(msg = message VLunwObj.
		GRgetrang(&msg,
			  NULL,NULL,
			  &world,
			   range),
		senderid = NULL_OBJID,
		targetid = unwrapOE->obj_id.objid,
		targetos = unwrapOE->obj_id.osnum);
  if (!(sts & msg & 1)) {
    printf("Problem getting range\n");
  }
  if (traceFlag) {    
    printf("Range %8.2f %8.2f %8.2f\n",range[0],range[1],range[2]);
    printf("      %8.2f %8.2f %8.2f\n",range[3],range[4],range[5]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets a single unwrap attribute
 */
IGRstat VLunwGetUnwrapAttribute(TGRid     *unwrapID, 
				IGRchar   *a_name, 
				IGRchar   *txt, 
				IGRdouble *dbl)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid colID; 
  TACrg_coll col;

  IGRchar name[40];
  IGRchar *p;
  
  // Init
  if (txt) *txt = 0;
  if (dbl) *dbl = 0.0;
  
  // Arg check
  if (name == NULL) goto wrapup;
  if ((unwrapID == NULL) || (unwrapID->objid == NULL_OBJID)) goto wrapup;

  // Get the collector
  vdchn$Get2(objID  = unwrapID, 
             chnIDx = VDCHN_IDX_PARENT, 
             nth    = 0, 
             outID  = &colID);
  if (colID.objid == NULL_OBJID) goto wrapup;

  // name is case sensitive,
  strcpy(name,a_name);
  for(p = name; *p; p++) {
    //if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
  
  // Ask for the attribute
  memset(&col,0,sizeof(col));
  strcpy(col.name,name);

  sts = om$send(msg = message 
          ACrg_collect.ACget_named_attribute(&msg,&col),
          senderid = NULL_OBJID,
          targetid = colID.objid,
          targetos = colID.osnum);
  if (!(sts & msg & 1)) goto wrapup;

  // Extract value
  switch(col.desc.type) {
	   
  case AC_ATTRIB_DOUBLE:
    if (txt) sprintf(txt,"%f",col.desc.value.att_exp);
    if (dbl) *dbl = col.desc.value.att_exp;
    break;
    
  case AC_ATTRIB_TEXT: 
    if (txt)  strcpy(txt,col.desc.value.att_txt);
    if (dbl) *dbl = atof(col.desc.value.att_txt);

    // printf("%s '%s'\n",name,col.desc.value.att_txt);
    
    break;
    
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given an unwrap, return the plate object 
 * taking into account the possibility that the unwrap
 * may link to the developable version of an undevelopable plate
 *
 * In this case, return the undevlopable plate
 *
 * With the new unwrap rogue plate functionality, the undeveloppable plate
 * will be attached somewhere besides the second parent
 */
IGRstat VLunwGetPlateForUnwrap(TGRobj_env *a_unwrapOE, TGRid *a_unwrapID, TGRobj_env *plateOE)
{
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TGRid  unwrapID;
  IGRint i;
  
  // Arg check
  if (plateOE == NULL)  goto wrapup;
  plateOE->obj_id.objid = NULL_OBJID;
  
  // Get the unwrap object
  unwrapID.objid = NULL_OBJID;
  if (a_unwrapOE) unwrapID =  a_unwrapOE->obj_id;
  if (a_unwrapID) unwrapID = *a_unwrapID;
  if (unwrapID.objid == NULL_OBJID) goto wrapup;
  
  // Rogue plates attache beyone 2nd parent
  for(i = 2; 
      vdobj$GetTemplate(objID = &unwrapID,
			nth   = i,
			templateOE = plateOE);
      i++) {
    
    // Make sure its a plate, might be a bevel or something else
    sts = vdobj$IsAncestryValid(objOE = plateOE,
				superClassName = "VSplate");
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
    
    plateOE->obj_id.objid = NULL_OBJID;
  }
  
  // First parent is it
  if (plateOE->obj_id.objid == NULL_OBJID) {
    vdobj$GetTemplate(objID = &unwrapID,
		      nth   = 1,
		      templateOE = plateOE);
  }
  if (plateOE->obj_id.objid == NULL_OBJID) {
    printf("*** Missing The Plate for Unwrap\n");
    vdobj$Print(objID = &unwrapID);
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Recursive routine to find leaf with given piece mark
 */
IGRstat VLunwFindLeafForPcmk(TGRid *parentID, IGRint pcmk, TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[32];
  IGRint  pcmkx,i;
  TGRid   childID;
  
  // Arg check
  if (leafID == NULL) goto wrapup;
  leafID->objid = NULL_OBJID;
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup;
  
  // Is it a leaf
  sts = VDatIsLeaf(parentID);
  if (sts & 1) {
    
    // See if it's the one
    //vdobj$Print(objID = parentID);
    vdsa$GetStruct(objID = parentID, name = "pcmk", txt = buf);
    pcmkx = atoi(buf);
    //printf("Piece Mark %d\n",pcmkx);
    if (pcmk == pcmkx) {
      *leafID = *parentID;
      retFlag = 1;
      goto wrapup;
    }
    goto wrapup;
  }
  
  // Try the kids
  for(i = 0; VDatGetChildObject(parentID,i,&childID); i++) {
    sts = VLunwFindLeafForPcmk(&childID,pcmk,leafID);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // No luck
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Finds the unwrap for an undevopable plate
 * by looking up it's piece mark in the undev tree
 */
IGRstat VLunwGetUndevUnwrapForPlate(TGRid *setID, IGRint pcmk, TGRobj_env *unwrapOE)
{
  IGRstat retFlag = 0;
  
  TGRid leafsID,leafID;
  TGRobj_env pieceOE;

  // Say hi
  //printf("===================================\n");
  //printf("Looking for piece mark %d\n",pcmk);
  //vdobj$Print(objID = setID);

  // Arg check
  if (unwrapOE == NULL) goto wrapup;
  unwrapOE->obj_id.objid = NULL_OBJID;
  if ((setID == NULL) || (setID->objid == NULL_OBJID)) goto wrapup;
  
  // Cycle through the leafs
  VDatGetLeafs(setID,&leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;
  
  // Find the leaf
  VLunwFindLeafForPcmk(&leafsID,pcmk,&leafID);
  if (leafID.objid == NULL_OBJID) goto wrapup;
  //vdobj$Print(objID = &leafID);
  
  // Pull the unwrap
  VDatGetLeafObject(&leafID,&pieceOE);
  //vdobj$Print(objOE = &pieceOE);
  
  VLunwGetUnwrapForPlate(&pieceOE,unwrapOE);
  //vdobj$Print(objOE = unwrapOE);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation VLunwObj;




