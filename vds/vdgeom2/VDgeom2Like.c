/* $Id: VDgeom2Like.c,v 1.1 2001/07/23 16:26:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom2/VDgeom2Like.c
 *
 * Description:	Like part routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeom2Like.c,v $
 *      Revision 1.1  2001/07/23 16:26:48  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgeomc.h"
#include "VDctx.h"
#include "VDval.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDgeom2Like.c");

extern IGRdouble fabs(IGRdouble x);

/* ----------------------------------------------------------
 * This guy gets the actual major point
 * within the specified tolerance
 */
IGRstat VDgeom2GetCrvCMMMajor(TGRbsp_curve *crv,
			      IGRdouble     incAngle,
			      IGRdouble     tolAngle,
			      IGRpoint      center,
			      IGRpoint      minor,
			      IGRdouble     totalArcLen,
			      IGRdouble     minorArcLen,
			      IGRint        factor,
			      IGRpoint      major)
{
  VDASSERT_FN("VDgeom2GetCrvCMM");

  IGRstat retFlag = 0;
  
  IGRdouble deltaArcLen;
  IGRdouble majorArcLen;
  
  IGRint i;

  IGRdouble angle,delta;
  
  // This is the arc distances to try
  deltaArcLen = totalArcLen / factor;
  majorArcLen = minorArcLen;
  
  // Loop through
  factor--;
  for(i = 0; i < factor; i++) {

    // Setup next try
    majorArcLen += deltaArcLen;    
    if (majorArcLen > totalArcLen) majorArcLen -= totalArcLen;

    // Grab the point
    VDgeom2GetCrvArcParPt(crv,0.0,1.0,majorArcLen,NULL,major);
    
    // Check the angle
    VDgeom2GetAngleFrom3Points(minor,center,major,&angle);
    angle = VDgeom2RadToDeg(angle);

    // printf("Angle %8.2f\n",angle);
    
    delta = fabs(angle - incAngle);
    if (delta < tolAngle) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Failed

 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
 * Given a closed curve
 * Return center,minor points
 * Return a "major" point such that the angle between the
 * major and minor falls within tolerance of arguments
 */
IGRstat VDgeom2GetCrvCMM(TGRbsp_curve *crv,
			 IGRdouble     incAngle,
			 IGRdouble     tolAngle,
			 IGRpoint      center,
			 IGRpoint      minor,
			 IGRpoint      major)
{
  VDASSERT_FN("VDgeom2GetCrvCMM");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  IGRdouble len,lenTotal;
  IGRdouble angle;

  IGRdouble totalArcLen;
  IGRdouble minorArcLen;

  IGRint i,j;
  
  // The min dist is the minor axis
  IGRshort   k,n;
  IGRdouble  dis;
  IGRdouble  par;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;

  BSrc       rc;
  
  // Arg check
  VDASSERTW(crv);
  VDASSERTW(center);
  VDASSERTW(major);
  VDASSERTW(minor);

  // Get the center
  VDgeom2GetCurveCenter(crv,center);
  
  // Get the minor axis (min dist)
  BSmdistptcv(crv,center,&k,&n,&pars,&dis,&intpars,&rc);

  if ((pars) && (n > 0)) par = pars[0];
  else                   par = 0.0;
  
  VDgeom2GetCrvPt(crv,par,minor);
  
  // Setup for calculating major
  VDgeom2GetCrvArcLen(crv,0.0,1.0,&totalArcLen);
  VDgeom2GetCrvArcLen(crv,0.0,par,&minorArcLen);
  
  // Basically trial and error
  j = 1;
  for(i = 0; i < 4; i++) {
    j *= 4;

    sts = VDgeom2GetCrvCMMMajor(crv,incAngle,tolAngle,
			       center,minor,totalArcLen,minorArcLen,
			       j,major);
    if (sts == 1) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Problem getting major point for closed curve\n");
  
  retFlag = 0;
  
wrapup:
  if (pars)    free(pars);
  if (intpars) free(intpars);
  
  return retFlag;
}
