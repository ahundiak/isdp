/* $Id: VDgeomLen.I,v 1.2 2001/05/03 14:45:34 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom/VDgeomLen.I
 *
 * Description:	Chop a curve into arc lengths of interest
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomLen.I,v $
 *      Revision 1.2  2001/05/03 14:45:34  ramarao
 *      Corrected "Problem getting arc length" error.
 *
 *      Revision 1.1  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.4  2000/11/27  17:07:18  pinnacle
# ah
#
# Revision 1.3  2000/10/18  18:28:16  pinnacle
# ah
#
# Revision 1.2  2000/06/19  18:06:40  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:31:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/00  ah      Creation
 * 10/18/00  ah      Suppressed arc length warning
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "bsparameters.h"

static int traceFlag;


typedef struct 
{
  IGRdouble *sbuf;
  IGRint     cnt;
  IGRint     max;
  IGRint     i;
  IGRdouble *lens;
} TVDgeomArcLens;

/* -----------------------------------------------
 * Utility routine for adding len to list
 */
IGRstat VDgeomGetArcLensAdd(IGRdouble len, TVDgeomArcLens *lens) 
{
  IGRint i;
  
  // Arg check
  if (lens == NULL) goto wrapup;
  i = lens->cnt;
  
  // Have room
  if (i >= lens->max) goto wrapup;
  
  // Make sure not exactly the same
  if (i > 0) {
    if ((len - lens->lens[i-1]) < .0001) goto wrapup;
  }

  // Addit
  lens->lens[i] = len;
  lens->cnt++;
  
  // Done
wrapup:
  return 1;
}

/* -----------------------------------------------
 * process 1 knot for the VDgeomGetArcLens routine
 */
IGRstat VDgeomGetArcLensForKnot(TGRbsp_curve   *crv, 
				IGRdouble       par0,
				IGRdouble       par1,
				IGRint          numSegs,
				IGRdouble       minSegLen,
				TVDgeomArcLens *lens)
{
  IGRchar fn[]="VDgeomGetArcLensForKnot";
  IGRstat retFlag = 1;

  struct 
  {    
    IGRdouble par0;
    IGRdouble par1;
    IGRdouble  inc;
  } len;
  
  // Arg check
  if (crv  == NULL) goto wrapup;
  if (lens == NULL) goto wrapup;
  
  // Start by adding the distance for the knot itself
  vdgeom$GetCrvArcLen(crv = crv, par1 = par0, len = &len.par0);
  VDgeomGetArcLensAdd(len.par0,lens);

  printf("%s %.2f %.2f %.2f\n",fn,par0,par1,len.par0);
  
  // Any segment stuff
  if (numSegs < 1)         goto wrapup;
  if (par1 - par0 < .0001) goto wrapup;

  // Get the distance
  vdgeom$GetCrvArcLen(crv = crv, par1 = par1, len = &len.par1);
  len.inc = len.par1 - len.par0;
  
  // Set a min limit
  if (minSegLen < .01) minSegLen = 1.0;
  
  // Chop down until reach numSegs or min distance
  while((numSegs) && (len.inc >= minSegLen)) {
    len.inc *= 0.5;
    numSegs--;
  }
  
  // Cycle through and add
  for(len.par0 += len.inc; 
      len.par0 <  len.par1; 
      len.par0 += len.inc) {
    VDgeomGetArcLensAdd(len.par0,lens);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#if 0
/* -----------------------------------------------
 * Gets a list of arc lens to check to see if curves
 * are the same and for min/max evaluations
 *
 * The theory is that knots represent special points so
 * we get a len for them but we also need to check between
 * knots because often have something going on there
 *
 * Pass the number of segments between knots as well as
 * the min seg length
 */
IGRstat VDgeomGetArcLens(TGRbsp_curve   *crv, 
			 IGRdouble       par0,
			 IGRdouble       par1,
			 IGRint          numSegs,
			 IGRdouble       minSegLen,
			 TVDgeomArcLens *lens)
{
  IGRstat retFlag = 0;

  TVDgeomKnots knots;
  IGRdouble    knotsBuf[512];
  
  IGRdouble par,parx;

  // vdgeom$Print(crv = crv);
  
  // Init
  VDgeomInitKnots(&knots,knotsBuf,512);
  
  // Arg check
  if (lens == NULL) goto wrapup;
  lens->cnt = 0;
  if (crv == NULL) goto wrapup;
  
  // Grab the knots
  vdgeom$GetKnotsFromCurve(crv   = crv, 
			   par0  = par0,
			   par1  = par1,
			   knots = &knots);

  printf("Knots %d\n",knots.cnt);
  
  // Cycle through
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {
    par = knots.knots[knots.i];

    // Need the next parameter
    if ((knots.i+1) < knots.cnt) parx = knots.knots[knots.i+1];
    else                         parx = par;
      
    // Process it
    VDgeomGetArcLensForKnot(crv,par,parx,numSegs,minSegLen,lens);
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  VDgeomFreeKnots(&knots);
  
  return retFlag;
}
#endif

/* -----------------------------------------------
 * Gets a list of arc lens to check to see if curves
 * are the same and for min/max evaluations
 *
 * The theory is that knots represent special points so
 * we get a len for them but we also need to check between
 * knots because often have something going on there
 *
 * Pass the number of segments between knots as well as
 * the min seg length
 *
 * The knot theory is good but does not always work
 * Also need set of points along the curve based on total length
 */
IGRstat VDgeomGetArcLens(TGRbsp_curve   *crv, 
			 IGRdouble       par0,
			 IGRdouble       par1,
			 IGRint          numSegs,
			 IGRdouble       minSegLen,
			 TVDgeomArcLens *lens)
{
  IGRstat retFlag = 0;

  TVDgeomKnots knots;
  IGRdouble    knotsBuf[512];
  
  IGRdouble par,parx;

  // vdgeom$Print(crv = crv);
  
  // Init
  VDgeomInitKnots(&knots,knotsBuf,512);
  
  // Arg check
  if (lens == NULL) goto wrapup;
  lens->cnt = 0;
  if (crv == NULL) goto wrapup;
  
  // Grab the knots
  vdgeom$GetKnotsFromCurve(crv   = crv, 
			   par0  = par0,
			   par1  = par1,
			   knots = &knots);

  printf("Knots %d\n",knots.cnt);
  
  // Cycle through
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {
    par = knots.knots[knots.i];

    // Need the next parameter
    if ((knots.i+1) < knots.cnt) parx = knots.knots[knots.i+1];
    else                         parx = par;
      
    // Process it
    VDgeomGetArcLensForKnot(crv,par,parx,numSegs,minSegLen,lens);
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  VDgeomFreeKnots(&knots);
  
  return retFlag;
}

/* -----------------------------------------------
 * Initialize a lens buffer
 */
IGRstat VDgeomInitCrvLens(TVDgeomArcLens *lens, IGRdouble *buf, IGRint max)
{ 
  if (lens == NULL) goto wrapup;
  
  memset(lens,0,sizeof(TVDgeomArcLens));
  lens->sbuf  = buf;
  lens->lens  = buf;
  lens->max   = max;

 wrapup:  
  return 1;
}
/* -----------------------------------------------
 * Frees a knot buffer if required
 */
IGRstat VDgeomFreeCrvLens(TVDgeomArcLens *lens)
{

  if (lens == NULL) goto wrapup;
  if (lens->lens != lens->sbuf) _FREE(lens->lens);

 wrapup:  
  return 1;
}

/* -------------------------------------------------
 * Get the arc length between two parameters
 *
 * The bs routine sometime fails when the two parameter
 * values are not at the ends so break it up into
 * two calls
 */
IGRstat VDgeomGetCrvArcLen(TGRbsp_curve *crv, 
			   IGRdouble     par0, 
			   IGRdouble     par1, 
			   IGRdouble    *len)
{
  IGRstat retFlag = 0;
  BSrc       rc1;
  IGRboolean rc2;
  
  IGRdouble parM;
  IGRdouble parZero = 0.0;
  IGRdouble parOne  = 0.0;
  IGRdouble savedtol; 
  IGRdouble len0,len1,lenx;

  // Arg check
  if (len == NULL) goto wrapup;
  *len = 0.0;
  if (crv == NULL) goto wrapup;

  BSxtractpar ( &rc1, BSTOLARCLEN, &savedtol );

  // Get To par0
  parM = (parZero + par0) * 0.5;
  BSarclen2(&rc1,&rc2,crv,&parZero,&par0,&parM,&len0);
  if (rc1 != BSSUCC) {
    BSchangepar( &rc1, BSTOLARCLEN, BSVALARCLEN );
    BSarclen2(&rc1,&rc2,crv,&parZero,&par0,&parM,&len0);
    BSchangepar( &rc2, BSTOLARCLEN, savedtol );
    if (rc1 != BSSUCC) {
       printf("*** Problem getting arc length\n");
       goto wrapup;
    }
  }
  
  // Get to par1
  parM = (parZero + par1) * 0.5;
  BSarclen2(&rc1,&rc2,crv,&parZero,&par1,&parM,&len1);
  if (rc1 != BSSUCC) {
    BSchangepar( &rc1, BSTOLARCLEN, BSVALARCLEN );
    BSarclen2(&rc1,&rc2,crv,&parZero,&par1,&parM,&len1);
    BSchangepar( &rc2, BSTOLARCLEN, savedtol );
    if (rc1 != BSSUCC) {
       printf("*** Problem getting arc length\n");
       goto wrapup;
    }
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
    BSchangepar( &rc1, BSTOLARCLEN, BSVALARCLEN );
    BSarclen2(&rc1,&rc2,crv,&parZero,&parOne,&parM,&lenx);
    BSchangepar( &rc2, BSTOLARCLEN, savedtol );
    if (rc1 != BSSUCC) {
       printf("*** Problem getting arc length\n");
       goto wrapup;
    }
  }
  *len = lenx - len1 + len0;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Get the either the parameter or point at given
 * distance along a curve
 */
IGRstat VDgeomGetCrvArcParPt(TGRbsp_curve *crv, 
			     IGRdouble     par0, 
			     IGRdouble     par1, 
			     IGRdouble     len,
			     IGRdouble    *par,
			     IGRpoint      pt)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRdouble parX;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  
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
    VDgeomGetCrvPt(crv,parX,pt);
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

/* ---------------------------------------------------
 * Gets a point between two parameter points
 * the lenr is the fraction of the length between
 * the two parameters to find
 */
IGRstat VDgeomGetCrvArcRatioParPt(TGRobj_env   *objOE,    // I - Object
				  TGRbsp_curve *a_crv,    // I - Curve
				  IGRdouble     par0,     // I Parameter boundaries
				  IGRdouble     par1,
				  IGRdouble     lenRatio, // I - usually .5 for mid
				  IGRdouble    *a_par,    // O - Parameter of point
				  IGRpoint      a_pt)     // O - The point
{
  IGRstat retFlag = 0;
  
  TGRbsp_curve *crv = NULL;

  IGRdouble len,len0,len01;
  IGRdouble par;
  IGRpoint  pt;
  
  // Arg check
  if (a_par) *a_par = 0.0;
  if (a_pt)  a_pt[0] = a_pt[1] = a_pt[2] = 0.0;
  
  // Get the geometry
  if (objOE) vdgeom$Get2(objOE = objOE, crv = &crv);
  else crv = a_crv;
  
  // Need some lengths
  if (par0 > .001) vdgeom$GetCrvArcLen(crv = crv, par1 = par0, len = &len0);
  else             len0 = 0.0;
  
  vdgeom$GetCrvArcLen(crv = crv, par0 = par0, par1 = par1, len = &len01);
  
  len = len0 + (len01 * lenRatio);
  
  // Get the point/parameter
  vdgeom$GetCrvArcParPt(crv = crv, len = len, par = &par, pt = pt);
  if (a_par) *a_par = par;
  if (a_pt) {
    a_pt[0] = pt[0];
    a_pt[1] = pt[1];
    a_pt[2] = pt[2];
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free Up
  if ((crv) && (crv != a_crv)) _FREE(crv);
  
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance from point to a curve
 */
IGRstat VDgeomGetDisPtCrvX(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis)
{
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble  par;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;

  // Arg check
  if (dis == NULL) goto wrapup;
  *dis = 0.0;
  
  BSmdistptcv(crv,pt,&k,&n,&pars,dis,&intpars,&rc);

  if ((pars) && (n > 0)) par = pars[0];
  else                   par = 0.0;
  
  printf("BSmdistptcv k=%d, n=%d, dis=%.2f, par=%.2f\n",k,n,*dis,par);
  
  if (rc == BSSUCC) retFlag = 1;
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}

end implementation Root;






