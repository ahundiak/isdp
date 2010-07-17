/* $Id: VLunwBevel.I,v 1.7 2002/06/13 19:05:31 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLunwBevel.I
 *
 * Description: Unwrap Bevel Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwBevel.I,v $
 *      Revision 1.7  2002/06/13 19:05:31  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/07/23 15:59:07  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/27 15:34:43  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/05/21 13:02:32  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/22 17:07:38  ramarao
 *      Compilation Error Fixed.
 *
 *      Revision 1.2  2001/01/22 16:42:34  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.4  2000/07/08  15:25:04  pinnacle
# ah
#
# Revision 1.3  2000/07/06  14:35:50  pinnacle
# ah
#
# Revision 1.2  2000/06/26  15:47:34  pinnacle
# ah
#
# Revision 1.1  2000/06/19  18:40:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/14/00  ah      Creation
 * 07/06/00  ah      Wrong attribute name for adjacent plate thickness
 ***************************************************************************/

class implementation VLunwObj;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VDsa.h"

#include "VDassert.h"
#include "VDlog.h"

#include "VLunwMisc.h"

VDASSERT_FFN("VLunwBevel.I");

static int traceFlag;

from ACrg_collect import ACget_named_attribute;
from ACrg_collect import AClist_attribute;
from GRcurve      import GRendpts;

/* -------------------------------------------------------------------
 * Helper routine, returns true if the object is a new bevel macro
 * 13 June 2002 - As far as the unwrap/spades process is concerned,
 * A VA_Bevel is not really a bevel, it's just a marking line
 */
IGRstat VLunwIsBevel(TGRobj_env *a_bevelOE, TGRid *a_bevelID) 
{
  IGRchar macName[64];
  TGRid   bevelID;
  
  // get the object
  bevelID.objid = NULL_OBJID;
  if (a_bevelOE) bevelID =  a_bevelOE->obj_id;
  if (a_bevelID) bevelID = *a_bevelID;
  if (bevelID.objid == NULL_OBJID) return 0;
  
  vdobj$Get(objID = &bevelID, macName = macName);
  
  if (!strcmp(macName,"Bevel"))    return 1;
  if (!strcmp(macName,"EJ_Bevel")) return 1;
  // (!strcmp(macName,"VA_Bevel")) return 1;
  return 0;
}

/* -----------------------------------------------
 * Collects basic data for bevel attached to unwrap
 * via feature
 * Only for new bevel macros
 */
IGRstat VLunwGetBevelInfo(TGRid           *unwrapID,  // Optional
			  TGRid           *bevelID,
			  TVLunwBevelInfo *info)
{
  IGRstat retFlag = 1;
  IGRstat sts,msg;

  TGRid      colID; 
  TACrg_coll col;

  IGRchar macName[40];
  
  IGRchar *p;
  IGRchar buf[128];
  
  TGRobj_env plateOE;
  TGRobj_env parentOE;
  
  IGRdouble thickness,side;
  IGRint i,flag;
  
  // Arg check
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVLunwBevelInfo));
  
  // Make sure have a bevel
  sts = VLunwIsBevel(NULL,bevelID);
  if (!(sts & 1)) goto wrapup;
  
  // Get the collector
  vdchn$Get2(objID  = bevelID, 
             chnIDx = VDCHN_IDX_PARENT, 
             nth    = 0, 
             outID  = &colID);
  if (colID.objid  == NULL_OBJID) goto wrapup;
  
  // Pull out Bevel type
  strcpy(col.name,"bevel_type");
  sts = om$send(msg = message 
		ACrg_collect.ACget_named_attribute(&msg,&col),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);
  strcpy  (info->spec,col.desc.value.att_txt);
  VDstrupr(info->spec);
  strcpy  (info->specx,info->spec);
  
  // Pull out Process type
  strcpy(col.name,"process_type");
  sts = om$send(msg = message 
		ACrg_collect.ACget_named_attribute(&msg,&col),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);
  strcpy  (info->process,col.desc.value.att_txt);
  VDstrupr(info->process);
  
  // Pull out stock
  strcpy(col.name,"stock_value");
  sts = om$send(msg = message 
		ACrg_collect.ACget_named_attribute(&msg,&col),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);
  info->stock = col.desc.value.att_exp;

  // Do we have a target plate?
  plateOE.obj_id.objid = NULL_OBJID;
  if (unwrapID) {
    VLunwGetPlateForUnwrap(NULL,unwrapID,&plateOE);
  }
  
  // Cycle through, look for plate parents
  for(i = 1; 
      vdobj$GetTemplate(objID = bevelID, nth = i, templateOE = &parentOE);
      i++) {

    sts = vdobj$IsAncestryValid(objOE = &parentOE, superClassName = "VSplate");
    if (sts & 1) {
      vdsa$Get(objOE = &parentOE, name = "plate_thk", dbl = &thickness);

      // Do we have a plate
      if (plateOE.obj_id.objid == NULL_OBJID) {

	// Just go in order
	if (info->thickness < .01) info->thickness = thickness;
	else                       info->adj_thickness = thickness;
      }
      else {
	
	// Is it the target plate
	if ((plateOE.obj_id.objid == parentOE.obj_id.objid) &&
	    (plateOE.obj_id.osnum == parentOE.obj_id.osnum)) {
	  info->thickness = thickness;
	}
	else {
	  info->adj_thickness = thickness;
	}
      }
      
    }
  }

  // Flag for X or Y bevels
  p = strchr(info->spec,'X');
  if (p == NULL) p = strchr(info->spec,'Y');
  
  // For EJ bevels, adjacent thickness is an attribute
  vdobj$Get(objID = bevelID, macName = macName);
  if (!strcmp(macName,"EJ_Bevel")) {  
    strcpy(col.name,"adjacent_plate_thickness");
    sts = om$send(msg = message 
		  ACrg_collect.ACget_named_attribute(&msg,&col),
		  senderid = NULL_OBJID,
		  targetid = colID.objid,
		  targetos = colID.osnum);
    info->adj_thickness = col.desc.value.att_exp;
    if (info->adj_thickness < .01) {

      // Try again different name
      strcpy(col.name,"adj_thickness");
      sts = om$send(msg = message 
		    ACrg_collect.ACget_named_attribute(&msg,&col),
		    senderid = NULL_OBJID,
		    targetid = colID.objid,
		    targetos = colID.osnum);
      info->adj_thickness = col.desc.value.att_exp;
    }
    
    //printf("Adj Thickness from attribute %.1f\n",col.desc.value.att_exp);
    
    // If have an X or Y then adjacent thickness should be non-zero
    // and less than thickness
    if (p) {

      // Dont like doing this but adj_thickness of 0 implies that this is the thinner plate
      if (info->adj_thickness < .01) {
	sprintf(info->msg,"*** EJ_Bevel %s, Thickness %.1f, Adjacent Thickness %.1f\n",
		info->spec,info->thickness,info->adj_thickness);
	printf("%s",info->msg);
	vdobj$Print(objID = bevelID);
	*p = 0;
      }
      else {
     
	// If its not 0 then assume user puts in correct value
	if ((info->thickness - info->adj_thickness) < .01) {

	  //Still don't flag, assume user is correct
#if 0
	  sprintf(info->msg,"*** EJ_Bevel %s, Thickness %.1f, Adjacent Thickness %.1f\n",
	  	  info->spec,info->thickness,info->adj_thickness);
	  printf("%s",info->msg);
	  vdobj$Print(objID = bevelID);
#endif
	  // So rest of system accepts it
	  *p = 0;
	
	}
      }
    }
  }
  if (!strcmp(macName,"Bevel")) {
    if (p) {

      // An adjacent thickness of zero gets flagged(no plate???)
      if (info->adj_thickness < .01) {
	sprintf(info->msg,"*** Bevel %s, Thickness %.1f, Adjacent Thickness %.1f\n",
		info->spec,info->thickness,info->adj_thickness);
	printf("%s",info->msg);
	vdobj$Print(objID = bevelID);
	*p = 0;
      }
      else {
	
	// Keep only the thicker one
	if ((info->thickness - info->adj_thickness) < .01) {
	  *p = 0;
	}
      }
    }
  }
 
  // All variable bevels are really manual
  if (!strcmp(macName,"VA_Bevel")) {
    strlcpy(buf,info->process,sizeof(buf));
    snprintf(info->process,sizeof(info->process),"M %s",buf);
    printf("Have VA_Bevel, Process %s\n",info->process);
  }
  // If unwrap is specified, adjust A B parameter for flipped unwraps
  if (unwrapID) {

    // Adjust a and b based on side presented
    VLunwGetUnwrapAttribute(unwrapID,"Side to Unwrap",NULL,&side);
    flag = side;
  
    if ((flag == 1) || (flag == 3)) {
      p = strchr(info->spec,'A');
      if (p) *p = 'B';
      else {
	p = strchr(info->spec,'B');
	if (p) *p = 'A';
      }
    }
  }
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Static structure for processing bevels on unwrap
 */
typedef struct 
{
  FILE *file;
  TGRobj_env unwrapOE;
  TGRobj_env featureOE;
  TGRobj_env bevelOE;
  
  IGRint maxInfo;
  IGRint numInfo;

  TVLunwUnwrapBevelInfo *infos;
  TVLunwUnwrapBevelInfo  info;

  TGRobj_env    contourOE;
  TGRbsp_curve *contourBsp;

  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];

} TVLunwUnwrapBevelInfox;

/* ----------------------------------------------------------
 * Bounces one bevel curve against one contour curve and
 * pulls the information as required
 *
 * Endpoints to bevel are already in info
 */
IGRstat VLunwGetUnwrapBevelInfoFromContour(TGRobj_env   *contourOE,
					   TGRbsp_curve *a_contourBsp,   // Optional
					   TVDgeomKnots *a_contourKnots, // Optional
					   TGRobj_env   *bevelCurveOE,
					   TVLunwUnwrapBevelInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  traceFlagx = 0;
  
  TGRbsp_curve *bevelCurveBsp = NULL;

  TGRbsp_curve *contourBsp   = NULL;
  TVDgeomKnots *contourKnots = NULL;

  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];

  IGRdouble dis1, dis2;
  IGRdouble disx1,disx2;
  IGRint    knot1,knot2;
  IGRpoint  pt;
  
  IGRint i;

  IGRdouble  par;
  IGRdouble  dis;
  IGRdouble  len;
  
  // Arg check
  if (info         == NULL) goto wrapup;
  if (bevelCurveOE == NULL) goto wrapup;
  if (contourOE    == NULL) goto wrapup;
  
  if (traceFlagx) {
    printf(">>> --------  VLunwGetUnwrapBevelInfoFromContour \n");
  }
  
  // Get the geometry if necessary
  if (a_contourBsp != NULL) {
    contourBsp   = a_contourBsp;
    contourKnots = a_contourKnots;
    if (traceFlagx) {
      printf("Contour geometry passed as argument\n");
    }
  }
  else {

    // Get the geometry
    vdgeom$Get2(objOE = contourOE, crv = &contourBsp);
    if (contourBsp == NULL) {
      if (traceFlagx) printf("*** Failure getting unwrap contour geometry\n");
      goto wrapup;
    }
    
    // Grab the knots as well
    VDgeomInitKnots(&knots,bufKnots,512);
    vdgeom$GetKnotsFromCurve(crv = contourBsp, knots = &knots);
    contourKnots = &knots; 

    if (traceFlagx) {
      printf("Pulled contour geometry\n");
    }
  }

  // Now see if the end points are near the contour
  VDgeomGetDisPtParCrv(info->end1,contourBsp,&dis1,&info->par1);
  VDgeomGetDisPtParCrv(info->end2,contourBsp,&dis2,&info->par2);
  
  // The tolerance here is kind of a guess, weld expansion shifts stuff slightly
  // On the other hand, you sometimes do have short bevels
  /* ----------------------------------------------
   * 26 June 2001
   * Sometimes the bevels get shifted entirely off the plate
   * during expansion
   * Increase this to deal with a few cases
   * trust the rest of the code to map the bevel directly
   */
  if ((dis1 > 30.0) || (dis2 > 30.0)) goto wrapup;
  
  // On the contour
  info->contourID =  contourOE->obj_id;
  info->contourOE = *contourOE;

  // Adjust ends for stock by finding closest knot
  knot1 = -1;
  knot2 = -1;
  disx1 = 100000.0;
  disx2 = 100000.0;

  if (traceFlagx) {
    printf("Num Knots %d\n",contourKnots->cnt);
  }
  
  for(i = 0; i < contourKnots->cnt; i++) {

    VDgeomGetCrvPt(contourBsp,contourKnots->knots[i],pt);
    VDgeomGetDisPtPt(pt,info->end1,&dis1);
    VDgeomGetDisPtPt(pt,info->end2,&dis2);
    if (dis1 < disx1) {
      disx1 = dis1;
      knot1 = i;
    }
    if (dis2 < disx2) {
      disx2 = dis2;
      knot2 = i;
    }
  }
  if (traceFlagx) {
    printf("Dis1 %12.4f, Dis2 %12.4f\n",disx1,disx2);
  }

  // Now adjust (Hope knots represent true ends after stock is applied)
  // The adjustment is limited to 30 mm (normal stock is 25 mm)
  if (disx1 < 30.0) {
    info->par1 = contourKnots->knots[knot1];
    VDgeomGetCrvPt(contourBsp,info->par1,info->end1);
    if (traceFlagx) {
      printf("Got point 1 for %.2f\n",info->par1);
    }
  }
  if (disx2 < 30.0) {
    info->par2 = contourKnots->knots[knot2];
    VDgeomGetCrvPt(contourBsp,info->par2,info->end2);
    if (traceFlagx) {
      printf("Got point 2 for %.2f\n",info->par2);
    }
  }
  if (traceFlagx) {    
    printf("1 End1 %10.4f, End2 %10.4f\n",info->par1,info->par2);
    printf("  End1 %10.2f %10.2f %10.2f\n",
	   info->end1[0],
	   info->end1[1],
	   info->end1[2]);
    printf("  End2 %10.2f %10.2f %10.2f\n",
	   info->end2[0],
	   info->end2[1],
	   info->end2[2]);
  }
  
  // Note: For closed bevels, pars could be the same
  if (fabs(info->par1 - info->par2) < .001) 
  {
    // Verify bevel has not degenerated to a point
    vdgeom$Get2(objOE = bevelCurveOE, crv = &bevelCurveBsp);
    vdgeom$GetCrvArcLen(crv = bevelCurveBsp, len = &len);   
    _FREE(bevelCurveBsp);
    if (len < 1.0) {
      printf("*** Very short bevel found\n");
      goto wrapup;
    }
    // Adjust parameters to include entire contour
    info->par1 = 0.0;
    info->par2 = 1.0;
    VDgeomGetCrvPt(contourBsp,info->par1,info->end1);
    VDgeomGetCrvPt(contourBsp,info->par2,info->end2);
    
    // Done
    retFlag = 1;
    goto wrapup;
    
  }

  /* --------------------------------------------------------
   * Still not completely sure if the case where bevels cross
   * Is properly handles
   *
   * May also be cases where an inner contour is broke into two identical
   * bevels and depending on where the break occurs, they may not merge
   * properly
   */

  // Sort by paramertization
  if (info->par1 > info->par2) {
    for(i = 0; i < 3; i++) {
      pt[i] = info->end2[i];
      info->end2[i] = info->end1[i];
      info->end1[i] = pt[i];
    }
    par = info->par1;
    info->par1 = info->par2;
    info->par2 = par;
  }
  if (traceFlagx) {    
    printf("2 End1 %.2f, End2 %.2f\n",info->par1,info->par2);
  }
  

  // Done unless par1 is 0.0
  if (info->par1 > .001) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Don't trust GRmidpoint
  vdgeom$Get2(objOE = bevelCurveOE, crv = &bevelCurveBsp);
  VDgeomGetCrvPt(bevelCurveBsp,0.5,pt);
  VDgeomGetDisPtParCrv(pt,contourBsp,&dis,&par);

  if (par > info->par2) {
     
    // Need to swap ends so curve ends on par1
    // printf("Swapping ends\n");
    for(i = 0; i < 3; i++) {
      pt[i] = info->end2[i];
      info->end2[i] = info->end1[i];
      info->end1[i] = pt[i];
    }
    info->par1 = info->par2;
    info->par2 = 1.0;
  }
       
  // Clean up
  _FREE(bevelCurveBsp);
  
  // Done
  retFlag = 1;
  
wrapup:
  
  // Clean up
  if (contourKnots != a_contourKnots) VDgeomFreeKnots(&knots);
  if (contourBsp   != a_contourBsp)   _FREE(contourBsp);

  if (traceFlagx) {
    
    printf("3 End1 %.2f, End2 %.2f\n",info->par1,info->par2);
    printf("  End1 %10.2f %10.2f %10.2f\n",
	   info->end1[0],
	   info->end1[1],
	   info->end1[2]);
    printf("  End2 %10.2f %10.2f %10.2f\n",
	   info->end2[0],
	   info->end2[1],
	   info->end2[2]);
  }
  
  return retFlag;
}

extern VDclassid OPP_AScompcurve_class_id;

/* ----------------------------------------------------------
 * Gets information for one bevel feature
 */
IGRstat VLunwGetUnwrapBevelInfo(TVLunwUnwrapBevelInfox *infox)
{
  IGRchar fn[] = "VLunwGetUnwrapBevelInfo";
  
  IGRstat retFlag = 1;
  IGRstat sts,msg;
  IGRstat traceFlagx = 0;
  
  TGRobj_env    drwOE,curveOE,compOE;
  TGRbsp_curve *curveBsp = NULL;

  TVLunwUnwrapBevelInfo *info;
    
  IGRint i,j;
  IGRint isBevel = 0;
 
  IGRint      compCnt;
  IGRint      compMax;
  TGRobj_env *compOEs = NULL;
  
  IGRpoint  end1,end2,endx;
  IGRdouble par,dis;
  
  // Get the actual bevel
  vdobj$GetTemplate(objOE = &infox->featureOE,
		    nth   = 1,
		    templateOE = &infox->bevelOE);
  if (infox->bevelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // See if its a nci_macro bevel
  isBevel = VLunwIsBevel(&infox->bevelOE,NULL);
  if (!(isBevel & 1)) goto wrapup;

  // Say Hi
  traceFlagx = 0;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = &infox->bevelOE);
  }
  
  // Grab basic info
  info = &infox->info;
  VLunwGetBevelInfo(&infox->unwrapOE.obj_id,&infox->bevelOE.obj_id,&info->info);
  
  if (traceFlagx) {
    printf("Spec %s, Stock %.2f\n",info->info.spec,info->info.stock);
  }
  // Look for spec with bevel
  if (*info->info.spec == 0) goto wrapup;

  // Label if have stock (ignore here)
  if (info->info.stock > .01) goto wrapup;

  // Start filling
  info->type = 0;
  info->bevelID = infox->bevelOE.obj_id;
  info->contourID.objid = NULL_OBJID;

  // The VDdrwgm object actually holds the graphics
  vdobj$GetFoot(objOE = &infox->featureOE, footName = "geom", footOE = &drwOE);
  if (drwOE.obj_id.objid == NULL_OBJID) {
    if (traceFlagx) printf("*** Cannot get drw object\n");
    goto wrapup;
  }
  
  // First foot is the curve
  curveOE = drwOE;
  vdchn$Get2(objOE  = &drwOE, 
	     chnIDx = VDCHN_IDX_TO_COMPONENTS, 
	     nth    = 0, 
	     outID  = &curveOE.obj_id);
  if (curveOE.obj_id.objid == NULL_OBJID) {
    if (traceFlagx) printf("*** Cannot bevel feature curve object\n");
    goto wrapup;
  }
  
  // Get the end points
  sts = om$send(msg = message GRcurve.
		GRendpts(&msg,
			 &curveOE.mod_env.md_env.matrix_type,
			  curveOE.mod_env.md_env.matrix,
			  info->end1,info->end2),
    senderid = NULL_OBJID,
    targetid = curveOE.obj_id.objid,
    targetos = curveOE.obj_id.osnum);

  if (!(sts & msg & 1)) {
    if (traceFlagx) printf("*** failure getting bevel end points\n");
    goto wrapup;
  }
  
  // Get the contour geometry if necessary
  if (infox->contourBsp == NULL) {

    // Get the contour
    VLunwGetExternalContour(&infox->unwrapOE,&infox->contourOE);
    if (infox->contourOE.obj_id.objid == NULL_OBJID) {
      if (traceFlagx) printf("*** failure getting unwrap contour\n");
      goto wrapup;
    }
    
    // Get the geometry
    vdgeom$Get2(objOE = &infox->contourOE, crv = &infox->contourBsp);
    if (infox->contourBsp == NULL) {
      if (traceFlagx) printf("*** failure getting unwrap contour geometry\n");
      goto wrapup;
    }
    
    /* -------------------------------------------
     * Most contours are comp curves, assume that
     * only the individual end points are important
     */
    sts = vdobj$IsAncestryValid(objOE        = &infox->contourOE, 
				superClassID = OPP_AScompcurve_class_id);
    if (sts & 1) {
  
      // Break it up
      compOE = infox->contourOE;
      for(j = 0; 
	  vdchn$Get2(objOE  = &infox->contourOE,
		     chnIDx = VDCHN_IDX_TO_COMPONENTS,
		     nth    = j,
		     outID  = &compOE.obj_id);
	  j++) {

	// Grab the ends
	sts = om$send(msg = message GRcurve.
		      GRendpts(&msg,
			       &compOE.mod_env.md_env.matrix_type,
			        compOE.mod_env.md_env.matrix,
			        end1,end2),
		      senderid = NULL_OBJID,
		      targetid = compOE.obj_id.objid,
		      targetos = compOE.obj_id.osnum);
	if (!(sts & msg &1)) {
	  printf("*** Problem getting end points of contour segment\n");
	  goto wrapup;
	}
	// Find its parameter value on original curve
	VDgeomGetDisPtParCrv(end1,infox->contourBsp,&dis,&par);
	infox->knots.knots[j] = par;
	infox->knots.cnt++;

	if (traceFlagx) {	  
	  printf("Knot %2d %10.4f, PT %12.2f %12.2f %12.2f\n",j,par,end1[0],end1[1],end1[2]);
	  VDgeomGetCrvPt(infox->contourBsp,par,endx);
	  printf("%-19s PT %12.2f %12.2f %12.2f\n","",endx[0],endx[1],endx[2]);
	}
	
      }
      // Last 1 is 1.0
      infox->knots.knots[j] = 1.0;
      infox->knots.cnt++;        
    }
    else {      
      // Grab the knots as well
      if (traceFlagx) {
	printf("Using all the knots\n");
      }
      vdgeom$GetKnotsFromCurve(crv = infox->contourBsp, knots = &infox->knots);
    }
  }

  // See if one the outer contour
  sts = VLunwGetUnwrapBevelInfoFromContour(&infox->contourOE,
					    infox->contourBsp,
					   &infox->knots,
					   &curveOE,
					   info);
  if (sts & 1) goto got_it;

  // Try each of the inner contours
  VLunwGetComponents(&infox->unwrapOE,VLEXT_TYPE_CONTOUR,0,&compCnt,NULL);
  if (compCnt) {
    compMax = compCnt;
    compOEs = calloc(sizeof(TGRobj_env),compCnt);
    if (compOEs == NULL) goto wrapup;    
    VLunwGetComponents(&infox->unwrapOE,VLEXT_TYPE_CONTOUR,compMax,&compCnt,compOEs);
  }
  
  for(i = 0; i < compCnt; i++) {

    sts = VLunwGetUnwrapBevelInfoFromContour(&compOEs[i],
					     NULL,
					     NULL,
					     &curveOE,
					     info);
    if (sts & 1) {
#if 0
      printf("--- Inner Contour Found ---\n");
      vdobj$Print(objOE = &compOEs[i]);
#endif
      goto got_it;
    }
    
  }
 
  // Not match at all
  VLsmsLog1(1,1,"*** Unable to match bevel end points, Feature %d\n",infox->featureOE.obj_id.objid);
  
  goto wrapup;
  
  // Add it
got_it:
  if (infox->numInfo >= infox->maxInfo) goto wrapup;
  infox->infos[infox->numInfo] = *info;
  infox->numInfo++;
  
  if (traceFlagx) printf("Added bevel to list\n");
  
  // Done
  retFlag = 1;

  
wrapup:

  if (compOEs) free(compOEs);
  
  if (traceFlagx & isBevel) {
    printf("<<< %s\n",fn);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * List bevels for debugging
 */
IGRstat VLunwPrintUnwrapBevelInfos(IGRint numInfo, TVLunwUnwrapBevelInfo *infos)
{
  IGRstat retFlag = 1;
  IGRint i;

  TVLunwUnwrapBevelInfo *info;
  
  printf("---- Bevel Infos Listing ----\n");
  for(i = 0; i < numInfo; i++) {
    info = &infos[i];
    printf("Bevel %2d %-5s %-6d %-6d P1 %6.4f %10.4f,%10.4f\n"
	   "                             P2 %6.4f %10.4f %10.4f\n\n",
	   i,
	   info->info.spec,
	   info->contourID.objid,
	   info->bevelID.objid,

	   info->par1,
	   info->end1[0],
	   info->end1[1],

	   info->par2,
	   info->end2[0],
	   info->end2[1]);
    
  }
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * qsort unwrap bevel infos
 */
IGRint VLunwSortUnwrapBevelInfos(const void *p1, const void *p2)
{
  TVLunwUnwrapBevelInfo *b1 = (TVLunwUnwrapBevelInfo*)p1;
  TVLunwUnwrapBevelInfo *b2 = (TVLunwUnwrapBevelInfo*)p2;
  
  // Order by contour id
  if (b1->contourID.objid < b2->contourID.objid) return -1;
  if (b1->contourID.objid > b2->contourID.objid) return  1;

  // Order by first parameter
  if (b1->par1 < b2->par1) return -1;
  if (b1->par1 > b2->par1) return  1;

  // Equal
  return 0;
}

/* -----------------------------------------------
 * Get the knuckle angle at the given parameter point
 * Optional len is how on either side of parameter to test from
 * Defaults to 1 mm
 */
IGRstat VDgeom2GetParAngle(TGRbsp_curve *crv, IGRdouble len, IGRdouble par, IGRdouble *angle)
{
  VDASSERT_FN("VDgeom2GetParAngle");
  IGRstat retFlag = 0;
  
  IGRdouble total_len;
  IGRdouble par_len;
  
  IGRdouble len1,len2;
  IGRdouble par1,par2;
  
  IGRpoint pt1,pt2,ptM;
  
  // Arg check
  VDASSERTW(angle); *angle = 0.0;
  VDASSERTW(crv);

  // Default
  if (len < .01) len = 1.0;

  // Couple of lengths
  vdgeom$GetCrvArcLen(crv = crv, len = &total_len);
  vdgeom$GetCrvArcLen(crv = crv, par1 = par, len = &par_len);

  len1 = par_len - len;
  if (len1 < 0.0) len1 += total_len;
  
  len2 = par_len + len;
  if (len2 > total_len) len2 -= total_len;
  
  if (traceFlag) {  
    printf(">>> VDgeom2GetParAngle %.2f %.2f %.2f, Total %.2f\n",len1,par_len,len2,total_len);
  }
  
  vdgeom$GetCrvArcParPt(crv = crv, len = len1, par = &par1, pt = pt1);
  vdgeom$GetCrvArcParPt(crv = crv, len = len2, par = &par2, pt = pt2);
  VDgeomGetCrvPt(crv,par,ptM);
  
  if (traceFlag) {  
    VDgeom2GetDisPtPt(pt1,ptM,&len1);
    VDgeom2GetDisPtPt(pt2,ptM,&len2);
    printf("Par %.4f %.4f %.4f\n",par1,par,par2);
    printf("Len %.2f %.2f\n",len1,len2);  
    printf("PT1 %10.2f %10.2f %10.2f\n",pt1[0],pt1[1],pt1[2]);
    printf("PTM %10.2f %10.2f %10.2f\n",ptM[0],ptM[1],ptM[2]);
    printf("PT2 %10.2f %10.2f %10.2f\n",pt2[0],pt2[1],pt2[2]);
  }
  
  // And the angle
  VDgeomGetAngleFrom3Points(pt1,ptM,pt2,angle);
  *angle = VDgeomRadToDeg(*angle);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Checks two bevels and merges them is needed
 */
IGRstat VLunwMergeUnwrapBevelInfo(TVLunwUnwrapBevelInfo *info1,
				  TVLunwUnwrapBevelInfo *info2)
{
  IGRstat retFlag = 0;
  IGRdouble par1,par2;
  IGRdouble angle;
  
  TGRbsp_curve *contourBsp = NULL;
  IGRchar buf[128];
  
  IGRint i;
  
  // Contours need to match
  if (info1->contourID.objid <= 0) goto wrapup;
  if (info2->contourID.objid <= 0) goto wrapup;

  if (info1->contourID.objid != info2->contourID.objid) goto wrapup;
  if (info1->contourID.osnum != info2->contourID.osnum) goto wrapup;
  
  // Check end points
  par1 = info1->par2;
  par2 = info2->par1;
  
  if (par1 > .999) par1 = 0.0;
  if (fabs(par1 - par2) > .001) goto wrapup;
  
  // Need to see if there is a knuckle along the break

  // Need the contour geometry
  vdgeom$Get2(objOE = &info1->contourOE, crv = &contourBsp);
  if (contourBsp == NULL) goto wrapup;

  // Find the angle
  VDgeom2GetParAngle(contourBsp,0.0,info2->par1,&angle);
  //printf("Bevel Angle %.2f\n",angle);
  
  // The usual case, two regular edges
  if (angle < 155.0) goto wrapup;
  
  // Specs need to be the same
  // If the angle < 177 then it's always manual
  if (strcmp(info1->info.spec,info2->info.spec) || (angle < 177.0)) {

    // Convert to Manual
    if (*info1->info.process != 'M') {
      sprintf(buf,"M %s",info1->info.process);
      strcpy(info1->info.process,buf);
    }
    if (*info2->info.process != 'M') {
      sprintf(buf,"M %s",info2->info.process);
      strcpy(info2->info.process,buf);
    }
    goto wrapup;
  }
  
  // A three degree "knuckle" output as one bevel
  info1->par2 = info2->par2;
  for(i = 0; i < 3; i++) {
    info1->end2[i] = info2->end2[i];
  }
  info2->contourID.objid = 0;
  
  // Did it
  retFlag = 1;
  
wrapup:
  _FREE(contourBsp)
  return retFlag;
}

/* -----------------------------------------------
 * Scans through the list to see if any bevels can be merged
 * after merging a bevel, it returns true which causes
 * another check to be made
 */
IGRstat VLunwMergeUnwrapBevelInfos(IGRint numInfo, TVLunwUnwrapBevelInfo *infos)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,j;
  
  // Sort em
  qsort(infos,numInfo,sizeof(TVLunwUnwrapBevelInfo),VLunwSortUnwrapBevelInfos);

  // Simple loop
  for(i = 0; i < numInfo; i++) {
    j = i + 1;
    if (j == numInfo) j = 0;
    sts = VLunwMergeUnwrapBevelInfo(&infos[i],&infos[j]);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Checks that no bevels start on the same point
 */
IGRstat VLunwGetUnwrapBevelInfoCheck(IGRint numInfo, TVLunwUnwrapBevelInfo *infos)
{
  IGRstat   retFlag = 1;
  IGRstat   flag;
  IGRint    i;
  
  // Make sure have some
  if (numInfo <= 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Keep calling until all merges are made
  // Provide a break out for problems
  flag = 1;
  for(i = 0; (flag) & (i < numInfo); i++) {
    flag = VLunwMergeUnwrapBevelInfos(numInfo,infos);
  }

  // Not sure we really need this check 
  // Seems to be spurious in some cases
  // Merging seems to work fine
  if ((flag == 1) && (i == numInfo)) {
    printf("*** Problem merging bevels\n");
    VLunwPrintUnwrapBevelInfos(numInfo,infos);
  }
  
  // Sort em
  // qsort(infos,numInfo,sizeof(TVLunwUnwrapBevelInfo),VLunwSortUnwrapBevelInfos);
  
  // Print em
  //VLunwPrintUnwrapBevelInfos(numInfo,infos);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Function to get bevels attached as features
 * Filters out bevels with stock
 * tweaks the end points if required to account
 * for stock on adjacent edges
 */
IGRstat	VLunwGetUnwrapBevelInfos( FILE			*file,
				  TGRobj_env		*unwrapOE,
				  IGRint		 maxInfo,
				  IGRint		*numInfo,
				  TVLunwUnwrapBevelInfo	*infos )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env *featureOEs = NULL;
  IGRint      featureCnt;
  IGRint      featureMax;
  IGRint      i;

  TVLunwUnwrapBevelInfox infox;

  // Init
  memset(&infox,0,sizeof(TVLunwUnwrapBevelInfox));
  VDgeomInitKnots(&infox.knots,infox.bufKnots,512);
  
  // Arg check
  if (numInfo  == NULL) goto wrapup;
  *numInfo = 0;
  if (infos    == NULL) goto wrapup;
  if (unwrapOE == NULL) goto wrapup;
  if (file     == NULL) file = stdout;
  
  // Pack stuff up to make it easier to pass around
  infox.file     = file;
  infox.unwrapOE = *unwrapOE;
  infox.maxInfo  = maxInfo;
  infox.infos    = infos;
  
  // Grab all features
  VLunwGetFeatures(unwrapOE,0,&featureCnt,NULL);
  if (featureCnt) {
    featureMax = featureCnt;
    featureOEs = calloc(sizeof(TGRobj_env),featureCnt);
    if (featureOEs == NULL) goto wrapup;
    VLunwGetFeatures(unwrapOE,featureMax,&featureCnt,featureOEs);
  }
  
  // Check each one
  for(i = 0; i < featureCnt; i++) {
    infox.featureOE = featureOEs[i];
    VLunwGetUnwrapBevelInfo(&infox);
  }

  // Unpack results
  *numInfo = infox.numInfo;

  // Check for bevels with matching beg points
  VLunwGetUnwrapBevelInfoCheck(*numInfo,infos);

  // Done
  retFlag = 1;
  
wrapup:

  if (featureOEs) free(featureOEs);
  
  // Cleanup some memory
  _FREE(infox.contourBsp);
  VDgeomFreeKnots(&infox.knots);
  
  return retFlag;
}

/* -----------------------------------------------
 * 22 Jan 2001 - ah
 * Update to use new bevel macros stuff
 *
 * Hard code Avondales gap requirements
 */
IGRstat VLunwBevelGetGap(TGRid      *edgeID,
			 TGRobj_env *a_plateOE,
			 IGRchar    *a_bevelSpec,
			 IGRdouble  *gap)
{
  IGRstat retFlag = 0;
  IGRchar spec[128];
  IGRint  specNum;

  TVLunwBevelInfo info;
  
  // Arg check
  if (gap == NULL) goto wrapup;
  *gap = 0.0;
  
  // Get the spec
  *spec = 0;
  if (a_bevelSpec) strcpy(spec,a_bevelSpec);
  if (edgeID) {

    VLunwGetBevelInfo(NULL,edgeID,&info);
    strcpy(spec,info.spec);
    
  }
  if (*spec == 0) goto wrapup;
  specNum = atoi(spec);
  
  // 29 is hardcoded
  if (specNum == 29) {
    *gap = BEVEL_MM_04_16;
    retFlag = 1;
    goto wrapup;
  }
  
  // 30 is a function of plate thickness
  if (specNum == 30) {

  }
  
  // Done
  
wrapup:
  return retFlag;
}

end implementation VLunwObj;

