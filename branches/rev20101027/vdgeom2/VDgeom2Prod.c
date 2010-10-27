/* $Id: VDgeom2Prod.c,v 1.1 2001/07/23 16:26:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom2/VDgeom2Curve.c
 *
 * Description:	C Geometry Curve Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeom2Prod.c,v $
 *      Revision 1.1  2001/07/23 16:26:48  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/14 18:32:18  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/07 19:05:24  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/25 15:44:17  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:55:28  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/12 14:38:22  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/12/01  ah      Creation,
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgeomc.h"
#include "VDval.h"

VDASSERT_FFN("VDgeom2Prod.c");

/* -------------------------------------------------
 * Get the either the parameter or point at given
 * distance along a curve
 */
IGRstat VDgeom2GetCrvArcParPt(TGRbsp_curve *crv, 
			      IGRdouble     par0, 
			      IGRdouble     par1, 
			      IGRdouble     len,
			      IGRdouble    *par,
			      IGRpoint      pt)
{
  VDASSERT_FN("VDgeom2GetCrvArcParPt");
  
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRdouble parX;
  
  // Arg check
  VDASSERTW(crv);
  
  // Get the parameter
  BSiarcln(&rc,crv,&par0,&len,&par1,&parX);
  if (rc != BSSUCC) {

    // Sometimes it fails right at the very end
    len -= .01;
    if (len < 0.0) len = 0.0;
    BSiarcln(&rc,crv,&par0,&len,&par1,&parX);
    if (rc != BSSUCC) {
      printf("*** Problem getting arc parameter along distance %.4f %.4f\n",len,parX);
      //vdgeom$Print(crv = crv);
      goto wrapup;
    }
  }
  if (par) *par = parX;
  
  // And the point
  if (pt) {
    VDgeom2GetCrvPt(crv,parX,pt);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (!(retFlag & 1)) {
    if (par) *par = 0.0;
    if (pt) {
      pt[0] = 0.0;
      pt[1] = 0.0;
      pt[2] = 0.0;
    }
  }
  return retFlag;
}

/* -------------------------------------------------
 * Get the arc length between two parameters
 *
 * The bs routine sometime fails when the two parameter
 * values are not at the ends so break it up into
 * two calls
 */
IGRstat VDgeom2GetCrvArcLen(TGRbsp_curve *crv, 
			    IGRdouble     par0, 
			    IGRdouble     par1, 
			    IGRdouble    *len)
{
  VDASSERT_FN("VDgeom2GetCrvArcLen");
  
  IGRstat retFlag = 0;
  BSrc       rc1;
  IGRboolean rc2;
  
  IGRdouble parM;
  IGRdouble parZero = 0.0;
  IGRdouble parOne  = 0.0;
  
  IGRdouble len0,len1,lenx;

  // Arg check
  VDASSERTW(len);*len = 0.0;
  VDASSERTW(crv);
  
  // Get To par0
  parM = (parZero + par0) * 0.5;
  BSarclen2(&rc1,&rc2,crv,&parZero,&par0,&parM,&len0);
  if (rc1 != BSSUCC) {
    printf("*** Problem getting arc length\n");
    goto wrapup;
  }
  
  // Get to par1
  parM = (parZero + par1) * 0.5;
  BSarclen2(&rc1,&rc2,crv,&parZero,&par1,&parM,&len1);
  if (rc1 != BSSUCC) {
    printf("*** Problem getting arc length\n");
    goto wrapup;
  }
  
  // Included length
  if (par0 < par1) {

    // Calc it
    *len = len1 - len0;
    retFlag = 1;
    goto wrapup;
    
  }

  // Excluded length
  parM = (parZero + parOne) * 0.5;
  BSarclen2(&rc1,&rc2,crv,&parZero,&parOne,&parM,&lenx);
  if (rc1 != BSSUCC) {
    printf("*** Problem getting arc length\n");
    goto wrapup;
  }
  *len = lenx - len1 + len0;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given three points, return the angle between the
 * line segments from pt1-p2 and pt2-pt3
 */
IGRstat VDgeom2GetAngleFrom3Points(IGRpoint   pt1,
				   IGRpoint   pt2,
				   IGRpoint   pt3,
				   IGRdouble *angle)
{
  VDASSERT_FN("VDgeom2GetAngleFrom3Points");
  
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRdouble dotp;
  IGRvector vec21,vec23;
  
  // Arg check
  VDASSERTW(angle);*angle = 0.0;
  VDASSERTW(pt1);
  VDASSERTW(pt2);
  VDASSERTW(pt3);
  
  // Vectors and dot product
  BSmkvec(&rc,vec21,pt2,pt1); MAunitvc(&rc,vec21,vec21);
  BSmkvec(&rc,vec23,pt2,pt3); MAunitvc(&rc,vec23,vec23);
  dotp = BSdotp(&rc,vec21,vec23);

  // Range check (sometimes -1.0 kicks off DOMAIN errors)
  if (dotp > 1.0) {
    //printf("dotp %f\n",dotp);
    dotp = 1.0;
  }
  if (dotp < -1.0) {
    //printf("dotp %f\n",dotp);
    dotp = -1.0;
  }
  *angle = acos(dotp);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Little convertors
 */
IGRdouble VDgeom2RadToDeg(IGRdouble rad)
{
  return 180.0 * (rad / VDGEOM_M_PI);
}
IGRdouble VDgeom2DegToRad(IGRdouble deg)
{
  return VDGEOM_M_PI * (deg / 180.0);
}
