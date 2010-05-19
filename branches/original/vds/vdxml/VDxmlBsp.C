/* $Id: VDxmlBsp.C,v 1.4 2001/02/20 15:19:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDxmlBsp.C
 *
 * Description: Basic xml bsp functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlBsp.C,v $
 *      Revision 1.4  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/02/08 17:02:02  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.2  2000/10/16  17:20:40  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/24  15:22:06  pinnacle
 * bsp
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/20/00  ah      Created
 * 02/02/01  ah      Removed some VDgeom calls for the moment
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDxml.h"
#include "VDbspXml.h"
#include "bsalloccv.h"
#include "gocmacros.h"

static int traceFlag;

/* -----------------------------------------------
 * Write a curve
 * Note that the actual values of the boolean flags
 * are being written which are not always 0 or 1 as expected
 * Dont' know if this is by design or not but keep for now
 */
IGRstat VDxmlWriteBspCurve(TVDxmlFileInfo *xml, TGRbsp_curve *crv)
{
  IGRstat retFlag = 0;
  IGRint  i,j,k;
  IGRchar props[32];
  
  // Arg check
  if (xml == NULL) goto wrapup;
  if (crv == NULL) goto wrapup;
  
  VDxmlWriteObjBeg(xml,XML_BSP_CRV,1,0);

  // Encode Properties
  props[XML_BSP_CRV_PROP_PERIODIC]    = '0' + crv->periodic;
  props[XML_BSP_CRV_PROP_NON_UNIFORM] = '0' + crv->non_uniform;
  props[XML_BSP_CRV_PROP_RATIONAL]    = '0' + crv->rational;
  props[XML_BSP_CRV_PROP_PLANAR]      = '0' + crv->planar;
  props[XML_BSP_CRV_PROP_PHY_CLOSED]  = '0' + crv->phy_closed;
  props[XML_BSP_CRV_PROP_END]         = 0;
  
  VDxmlWriteAtrTxt(xml,XML_BSP_CRV_PROPS,props,0,0);

  VDxmlWriteAtrInt(xml,XML_BSP_CRV_ORDER,    crv->order,0,0);
  VDxmlWriteAtrInt(xml,XML_BSP_CRV_NUM_POLES,crv->num_poles,  0,0);
  //xmlWriteAtrInt(xml,XML_BSP_CRV_NUM_KNOTS,crv->num_knots,  0,0);
  VDxmlWriteAtrInt(xml,XML_BSP_CRV_NUM_BNDYS,crv->num_boundaries, 0,0);

  VDxmlWriteAtrEnd(xml,0,1);

  // Knots,poles, weights and boundaries
  VDxmlWriteObjBeg(xml,XML_BSP_CRV_KPWBS,0,1);

  // Knots should aways be the most but what the heck
  k = crv->num_knots;
  if (k < crv->num_poles)      k = crv->num_poles;
  if (k < crv->num_boundaries) k = crv->num_boundaries;
  
  for(i = 0; i < k; i++) {

    VDxmlWriteObjBeg(xml,XML_BSP_CRV_KPWB,1,0);

    // Knots
    if (i < crv->num_knots) {      
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_K,crv->knots[i],0,0);
    }
    
    // Poles and weights
    if (i < crv->num_poles) {
      j = i * 3;
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_X,crv->poles[j+0],0,0);
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_Y,crv->poles[j+1],0,0);
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_Z,crv->poles[j+2],0,0);
      if ((crv->rational) && (crv->weights)) {
	VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_W,crv->weights[i],0,0);
      }
    }

    // Boundaries
    if (i < crv->num_boundaries) {
      j = i * 2;      
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_B1,crv->bdrys[j+0],0,0);
      VDxmlWriteAtrDbl(xml,XML_BSP_CRV_KPWB_B2,crv->bdrys[j+1],0,0);
    }
    
    // Done
    VDxmlWriteAtrEnd(xml,0,0);
    VDxmlWriteObjEnd(xml,XML_BSP_CRV_KPWB,0);    
  }
  VDxmlWriteObjEnd(xml,XML_BSP_CRV_KPWBS,1);
 
  // End
  VDxmlWriteObjEnd(xml,XML_BSP_CRV,1);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Process bsp curve attributes
 */
IGRstat VDxmlFilterBspAttribute(TVDxmlBspParseInfo *info,
				TVDxmlParseInfo *parseInfo)
{
  IGRstat retFlag = 0;

  IGRchar  *etag = parseInfo->eleInfo.eleType;
  IGRchar   *tag = parseInfo->eleInfo.atrType;
  IGRchar *value = parseInfo->eleInfo.atrValue;

  TGRbsp_curve *crvd = &info->crvd;
  TGRbsp_curve *crvp =  info->crvp;
  
  IGRint  i;
  IGRchar props[32];
  
  // Curve object
  if (!strcmp(etag,XML_BSP_CRV)) {
    
    // Just a signal
    retFlag = 1;
    
    if (!strcmp(tag,XML_BSP_CRV_PROPS)) {
      strcpy(props,value);
      strcat(props,"        ");
      crvd->periodic    = props[XML_BSP_CRV_PROP_PERIODIC]    - '0';
      crvd->non_uniform = props[XML_BSP_CRV_PROP_NON_UNIFORM] - '0';
      crvd->rational    = props[XML_BSP_CRV_PROP_RATIONAL]    - '0';
      crvd->planar      = props[XML_BSP_CRV_PROP_PLANAR]      - '0';
      crvd->phy_closed  = props[XML_BSP_CRV_PROP_PHY_CLOSED]  - '0';
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_ORDER)) {
      crvd->order     = atoi(value);
      crvd->num_knots = crvd->order + crvd->num_poles;
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_NUM_POLES)) {
      crvd->num_poles = atoi(value);
      crvd->num_knots = crvd->order + crvd->num_poles;
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_NUM_BNDYS)) {
      crvd->num_boundaries = atoi(value);
      goto wrapup;
    }
    goto wrapup;
  }

  // Knot-Pole-Weight-Boundary object
  if (!strcmp(etag,XML_BSP_CRV_KPWB)) {

    // Allocation Check
    if (crvp == NULL) goto wrapup;
    retFlag = 1;
    
    // Save it
    if (!strcmp(tag,XML_BSP_CRV_KPWB_K)) {
      if (crvp->num_knots >= crvd->num_knots) goto wrapup;
      if (crvp->knots) crvp->knots[crvp->num_knots] = atof(value);
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_KPWB_X)) {
      if (crvp->num_poles >= crvd->num_poles) goto wrapup;
      if (crvp->poles) crvp->poles[(3*crvp->num_poles)+0] = atof(value);
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_KPWB_Y)) {
      if (crvp->num_poles >= crvd->num_poles) goto wrapup;
      if (crvp->poles) crvp->poles[(3*crvp->num_poles)+1] = atof(value);
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_KPWB_Z)) {
      if (crvp->num_poles >= crvd->num_poles) goto wrapup;
      if (crvp->poles) crvp->poles[(3*crvp->num_poles)+2] = atof(value);
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_KPWB_W)) {
      if (crvp->num_poles >= crvd->num_poles) goto wrapup;
      if (crvp->weights) crvp->weights[crvp->num_poles] = atof(value);
      goto wrapup;
    }    
    if (!strcmp(tag,XML_BSP_CRV_KPWB_B1)) {
      if (crvp->num_boundaries >= crvd->num_boundaries) goto wrapup;
      if (crvp->bdrys) crvp->bdrys[(2*crvp->num_boundaries)+0] = atof(value);
      goto wrapup;
    }
    if (!strcmp(tag,XML_BSP_CRV_KPWB_B2)) {
      if (crvp->num_boundaries >= crvd->num_boundaries) goto wrapup;
      if (crvp->bdrys) crvp->bdrys[(2*crvp->num_boundaries)+1] = atof(value);
      goto wrapup;
    }    
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Start a new element
 */
IGRstat VDxmlFilterBspBegElement(TVDxmlBspParseInfo *info,
				 TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VDxmlFilterBspBegElement";
  IGRstat retFlag = 0;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;

  TGRbsp_curve *crvd = &info->crvd;
  TGRbsp_curve *crvp =  info->crvp;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Maybe do error checking later
  if (!strcmp(tag,XML_BSP_CRV)) {
    memset(info,0,sizeof(TVDxmlBspParseInfo));
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * End element
 */
IGRstat VDxmlFilterBspEndElement(TVDxmlBspParseInfo *info,
				 TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VDxmlFilterBspEndElement";
  IGRstat retFlag = 0;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;

  TGRbsp_curve *crvd = &info->crvd;
  TGRbsp_curve *crvp =  info->crvp;

  TGRid objID;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Array Pointers
  if (!strcmp(tag,XML_BSP_CRV_KPWB)) {
    if (crvp == NULL) goto wrapup;
    if (crvp->num_poles < crvd->num_poles)           crvp->num_poles++;
    if (crvp->num_knots < crvd->num_knots)           crvp->num_knots++;
    if (crvp->num_boundaries < crvd->num_boundaries) crvp->num_boundaries++;
    retFlag = 1;
    goto wrapup;
  }
  
  // Break out of parser if end of the curve
  if (!strcmp(tag,XML_BSP_CRV)) {
    // VDdrawCurve(crvp,NULL,&objID);
    retFlag = XML_BSP_CRV_LOADED;
  }
  
wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * End the attribute portion of an element
 */
IGRstat VDxmlFilterBspEndElementAttrs(TVDxmlBspParseInfo *info,
				      TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VDxmlFilterBspEndElementAttrs";
  IGRstat retFlag = 0;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;
  BSrc    rc;
  
  TGRbsp_curve  *crvd  = &info->crvd;
  TGRbsp_curve **crvpp = &info->crvp;
  TGRbsp_curve  *crvp;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Only interested in curve information
  if (!strcmp(tag,XML_BSP_CRV)) {

    *crvpp = NULL;
#if 0
    vdgeom$AllocCrv(order          = crvd->order,
		    num_poles      = crvd->num_poles,
		    rational       = crvd->rational,
		    num_boundaries = crvd->num_boundaries,
		    crv            = crvpp);
#endif
    crvp = *crvpp;
    if (crvp == NULL) {
      printf("*** Problem allocating curve while reading in XML\n");
      retFlag = 0;
      goto wrapup;
    }
    // Xfer header info
    crvp->order       = crvd->order;
    crvp->periodic    = crvd->periodic;
    crvp->non_uniform = crvd->non_uniform;
    crvp->rational    = crvd->rational;
    crvp->planar      = crvd->planar;
    crvp->phy_closed  = crvd->phy_closed;

    // These get set as the arrays are loaded
    crvp->num_knots = 0;
    crvp->num_poles = 0;
    crvp->num_boundaries = 0;
    retFlag = 1;
  }
  
  // Done
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * Callback traffic director
 * Only used for local testing
 */
static IGRstat VDxmlFilterBspCallback(TVDxmlParseInfo *parseInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts = 0;
  
  IGRchar fn[] = "VDxmlFilterBspCallback";
  
  TVDxmlBspParseInfo *info = parseInfo->data;
  
  //if (traceFlag) printf(">>> %s %d\n",fn,parseInfo->eleInfo.type);
  
  switch(parseInfo->eleInfo.type) {

  case VDXML_TYPE_BEG_ELEMENT:        
    sts = VDxmlFilterBspBegElement(info,parseInfo);
    break;
    
  case VDXML_TYPE_END_ELEMENT:        
    sts = VDxmlFilterBspEndElement(info,parseInfo);
    break;
    
  case VDXML_TYPE_END_ELEMENT_ATTRS:        
    sts = VDxmlFilterBspEndElementAttrs(info,parseInfo);
    break;
    
  case VDXML_TYPE_ATTRIBUTE:          
    sts =  VDxmlFilterBspAttribute(info,parseInfo);
    break;
    
  }
  
  retFlag = 1;
  return retFlag;
}

/* -------------------------------------------------------
 * Load bsp curve object from xml buffer
 */
IGRstat VDxmlLoadBspCrvFromBuffer(IGRchar *buf, TGRbsp_curve **crv)
{
  IGRchar fn[] = "VDxmlLoadBspCrvFromBuffer";

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDxmlParseInfo parseInfo;
  TVDxmlBspParseInfo info;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Init the data structures
  if (crv == NULL) goto wrapup;
  *crv = NULL;

  memset(&info,0,sizeof(TVDxmlBspParseInfo));
 
  // All the real work
  sts = VDxmlParseBuf(&parseInfo,  // Parse Info
		       NULL,        // Buffer name for debugging
		       buf,         // Actual buffer
		       0,           // Buffer length
		       VDxmlFilterBspCallback,
		       &info);      // User info
  if (!(sts & 1)) goto wrapup;

  *crv = info.crvp;
  // vdgeom$Print(crv = *crv);
  
		     
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}





