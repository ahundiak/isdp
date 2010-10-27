/* $Id: VDgeomSym.I,v 1.1 2001/01/11 18:41:19 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomSym.I
 *
 * Description:	Symmetric (circle and oval) processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomSym.I,v $
 *      Revision 1.1  2001/01/11 18:41:19  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  17:07:18  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:31:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/27/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

static int traceFlag;

/* -----------------------------------------------
 * Determine if the curve is an flattened oval
 * With circular end caps
 *
 * No bs routines so have to roll our own
 *
 *          (M1 is the minor axis)
 *       P1  M1  P2
 * E1    P3  C   P4   E2      (E1 is tha major point)
 *       P5  M2  P6
 *
 * Center,major,minor have already been filled in
 * Usually called by VDgeomIsSymCrv
 */
IGRstat VDgeomIsCrvSymOval(TGRbsp_curve *crv,
			   IGRdouble     tol,
			   TVDgeomSym   *sym)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  BSrc     rc;  
  IGRint   flag;
  
  IGRpoint c,p1,p2,p3,p4,p5,p6,e1,e2,m1,m2;
  IGRint   i;
  
  IGRvector vec_c_e1;
  IGRvector vec_c_m1;
  IGRvector vec_c_p3;
  
  IGRdouble dis_c_e1;
  IGRdouble dis_c_m1;
  IGRdouble dis_c_p3;
  
  IGRdouble scale;

  TGRbsp_curve *oval = NULL;
  TGRbsp_curve *crvs[4];
  
  TGRbsp_curve *crv_p1_p2 = NULL;  // Line
  TGRbsp_curve *crv_p2_p6 = NULL;  // Arc
  TGRbsp_curve *crv_p6_p5 = NULL;  // Line
  TGRbsp_curve *crv_p5_p1 = NULL;  // Arc

  IGRchar buf_p1_p2[VDGEOM_SIZE_LINE];
  IGRchar buf_p2_p6[VDGEOM_SIZE_ARC];
  IGRchar buf_p6_p5[VDGEOM_SIZE_LINE];
  IGRchar buf_p5_p1[VDGEOM_SIZE_ARC];
  
  // Arg check
  if (crv == NULL) goto wrapup;
  if (sym == NULL) goto wrapup;
  
  // Pull out major,minor,center;
  for(i = 0; i < 3; i++) {
    c [i] = sym->center[i];
    e1[i] = sym->major [i];
    m1[i] = sym->minor [i];
  }
  // e2,m2 is just flip of e1,m1
  BSmkvec(&rc,vec_c_e1,c,e1);
  BSmkvec(&rc,vec_c_m1,c,m1);
  for(i = 0; i < 3; i++) {
    e2[i] = c[i] - vec_c_e1[i];
    m2[i] = c[i] - vec_c_m1[i];
  }

  // The radius of the end caps is the difference in distances
  VDgeomGetDisPtPt(c,e1,&dis_c_e1);
  VDgeomGetDisPtPt(c,m1,&dis_c_m1);
  dis_c_p3  = dis_c_e1 - dis_c_m1;
  
  if (dis_c_p3 < 0.0001) goto wrapup; // Something wrong
  if (dis_c_e1 < 0.0001) goto wrapup; // Something wrong
  
  // Scale the vector to e1 to get p3
  scale = (dis_c_e1 - dis_c_m1) / dis_c_e1;

  for(i = 0; i < 3; i++) {

    vec_c_p3[i] = vec_c_e1[i] * scale;

    p1[i] = m1[i] + vec_c_p3[i];
    p3[i] = c [i] + vec_c_p3[i];
    p5[i] = m2[i] + vec_c_p3[i];

    p2[i] = m1[i] - vec_c_p3[i];
    p4[i] = c [i] - vec_c_p3[i];
    p6[i] = m2[i] - vec_c_p3[i];
  }

  // Now mark the individual segments
  crv_p1_p2 = (TGRbsp_curve*)buf_p1_p2;
  crv_p2_p6 = (TGRbsp_curve*)buf_p2_p6;
  crv_p6_p5 = (TGRbsp_curve*)buf_p6_p5;
  crv_p5_p1 = (TGRbsp_curve*)buf_p5_p1;
  
  sts = VDgeomMakeLineCurve(p1,p2,&crv_p1_p2);
  if (!(sts & 1)) goto wrapup;
  
  sts = VDgeomMakeArcCurve(p2,e2,p6,&crv_p2_p6);
  if (!(sts & 1)) goto wrapup;

  sts = VDgeomMakeLineCurve(p6,p5,&crv_p6_p5);
  if (!(sts & 1)) goto wrapup;

  sts = VDgeomMakeArcCurve(p5,e1,p1,&crv_p5_p1);
  if (!(sts & 1)) goto wrapup;

  // Could merge two at a time to get around memory allocation

  // Merge them to create oval
  crvs[0] = crv_p1_p2;
  crvs[1] = crv_p2_p6;
  crvs[2] = crv_p6_p5;
  crvs[3] = crv_p5_p1;
  
  BSmergarrcv(4,crvs,&oval,&rc);
  if (rc != BSSUCC) goto wrapup;
  
  // Now check the two curves
  VDgeomDoCurvesMatch(crv,oval,tol,&flag);
  if (!(flag & 1)) goto wrapup;

  // Copy it
  vdgeom$AllocCurve(order     = 3,
		    num_poles = 15,
		    rational  = 1,
		    crv       = &sym->bsp,
		    buf       =  sym->buf,
		    bufSize   = VDGEOM_SIZE_OVAL);

  BScv_copy(&rc,oval,sym->bsp);

  // Done
  sym->type = VDGEOM_SYM_TYPE_OVAL;
  retFlag = 1;
  
wrapup:
  if (retFlag == 0) sym->bsp = NULL;

  _FREECV(&rc,oval);
  
  return retFlag;
}

/* -----------------------------------------------
 * Determine if the curve is an ellpise
 *
 * Center,major,minor have already been filled in
 * Usually called by VDgeomIsSymCrv
 */
IGRstat VDgeomIsCrvSymEllipse(TGRbsp_curve *crv,
			      IGRdouble     tol,
			      TVDgeomSym   *sym)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  BSrc     rc;  
  IGRint   flag;
  
  
  // Arg check
  if (crv == NULL) goto wrapup;
  if (sym == NULL) goto wrapup;
  
  // Make an ellipse
  vdgeom$AllocCurve(order     = BSCIRCLE_ORDER,
		    num_poles = BSCIRCLE_NUM_POLES_MAX,
		    rational  = 1,
		    crv       = &sym->bsp,
		    buf       =  sym->buf,
		    bufSize   = VDGEOM_SIZE_CIRCLE);

  BSellctaxrm(&rc, sym->center, sym->major, sym->minor, sym->bsp);
  if (rc != BSSUCC) {
    // printf("Cannot make a ellipse\n");
    goto wrapup;
  }
  // Now check the two curves
  VDgeomDoCurvesMatch(crv,sym->bsp,tol,&flag);
  if (!(flag & 1)) goto wrapup;

  // Done
  sym->type = VDGEOM_SYM_TYPE_ELLIPSE;
  retFlag = 1;
  
wrapup:
  if (retFlag == 0) sym->bsp = NULL;
  
  return retFlag;
}

/* -----------------------------------------------
 * Determine if the curve is a circle
 *
 * Currently treats the curve as being closed even if it is not.
 * Means that arc will come back as circles.
 * 
 * Need to do this since unwrap has started leaving some circles open???
 *
 * The tolerance has to be pretty big.
 * Even for an actual circle (number of poles = 7 etc)
 * Get distances > .1mm,  maybe some tolerance issue?
 *
 * In any event .7mm is fine for production so use it
 *
 * Usually called from VDgeomIsSym
 */
IGRstat VDgeomIsCrvSymCircle(TGRbsp_curve *crv,
			     IGRdouble     tol,
			     TVDgeomSym   *sym)

{
  IGRstat  retFlag = 0;
  IGRint   flag;
  
  BSrc     rc;
  
  IGRdouble len;
  
  // Arg check
  if (crv == NULL) goto wrapup;
  if (sym == NULL) goto wrapup;
  
  // Get the total length, then 3 points along it
  vdgeom$GetCrvArcLen  (crv = crv, len = &len);
  vdgeom$GetCrvArcParPt(crv = crv, len = (len * .000), pt = sym->pt0);
  vdgeom$GetCrvArcParPt(crv = crv, len = (len * .333), pt = sym->pt1);
  vdgeom$GetCrvArcParPt(crv = crv, len = (len * .667), pt = sym->pt2);

  // Make a circle from the three points
  vdgeom$AllocCurve(order     = BSCIRCLE_ORDER,
		    num_poles = BSCIRCLE_NUM_POLES_MAX,
		    rational  = 1,
		    crv       = &sym->bsp,
		    buf       =  sym->buf,
		    bufSize   = VDGEOM_SIZE_CIRCLE);

  BScirc3pts(&rc, sym->pt0, sym->pt1, sym->pt2, sym->bsp);
  if (rc != BSSUCC) {
    goto wrapup;
  }
  
  // Now check the two curves
  VDgeomDoCurvesMatch(crv,sym->bsp,tol,&flag);
  if (!(flag & 1)) {
    //printf("Not a circle\n");
    goto wrapup;
  }
  
  // Done
  sym->type = VDGEOM_SYM_TYPE_CIRCLE;
  retFlag = 1;
  
 wrapup:

  if (retFlag == 0) sym->bsp = NULL;
  
  return retFlag;
}

/* -----------------------------------------------
 * Checks to see of a curve is symmetric meaning
 * it's a closed parametric curve
 */
IGRstat VDgeomIsCrvSym(TGRbsp_curve *crv,
		       IGRdouble     tol,
		       TVDgeomSym   *sym)
{
  IGRstat retFlag = 0;
  IGRstat sts;
    
  // Arg check
  if (sym == NULL) goto wrapup;
  memset(sym,0,sizeof(TVDgeomSym));
  if (crv == NULL) goto wrapup;
  
  // Fairly loose tolerance
  if (tol < VDGEOM_TOL_ZERO) tol = VDGEOM_TOL_IS_SYM;
  
  // Must be exactly closed
  if (crv->phy_closed == 0) goto wrapup;
  
  // Get the major points
  VDgeomGetSymCrvAxis(crv,sym->center,sym->major,sym->minor);
  
  // Test for circle
  sts = VDgeomIsCrvSymCircle(crv,tol,sym);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Test for ellipse
  sts = VDgeomIsCrvSymEllipse(crv,tol,sym);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  // Test for oval
  sts = VDgeomIsCrvSymOval(crv,tol,sym);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
    
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * How does the bspmath routine work out
 */
IGRstat VDgeomGetSymCrvCenter(TGRbsp_curve *crv,
			      IGRpoint      center)
{ 
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  // Arg check
  if (crv    == NULL) goto wrapup;
  if (center == NULL) goto wrapup;

  // Do it
  BSfndcent(crv,center,&rc);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
 * Given a symmetric curve,
 * Return center,major and minor points
 *
 */
IGRstat VDgeomGetSymCrvAxis(TGRbsp_curve *crv,
			    IGRpoint      center,
			    IGRpoint      major,
			    IGRpoint      minor)
{
  IGRstat  retFlag = 0;

  IGRdouble len,lenTotal;
  IGRdouble angle;
  
  // The min dist is the minor axis
  IGRshort   k,n;
  IGRdouble  dis;
  IGRdouble  par;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;
  
  // Arg check
  if (crv    == NULL) goto wrapup;
  if (center == NULL) goto wrapup;
  if (major  == NULL) goto wrapup;
  if (minor  == NULL) goto wrapup;

  // Get the center
  VDgeomGetSymCrvCenter(crv,center);
  
  // Get the minor axis (min dist)
  BSmdistptcv(crv,center,&k,&n,&pars,&dis,&intpars,&rc);

  if ((pars) && (n > 0)) par = pars[0];
  else                   par = 0.0;
  
  VDgeomGetCrvPt(crv,par,minor);
  
  // The major axis should be 1/4 distance around
  vdgeom$GetCrvArcLen(crv = crv, len = &lenTotal);
  vdgeom$GetCrvArcLen(crv = crv, par1 = par, len = &len);

  len += (lenTotal * .25);
  if (len > lenTotal) len -= lenTotal;

  vdgeom$GetCrvArcParPt(crv = crv, len = len, pt = major);

  // Make sure not almost straight
  VDgeomGetAngleFrom3Points(minor,center,major,&angle);
  angle = VDgeomRadToDeg(angle);
  // printf("Angle %.2f\n",angle);
  if ((angle > 30.0) && (angle < 150.0)) {
    retFlag = 1;
    goto wrapup;
  }

  // Shift it
  len += (lenTotal * .125);
  if (len > lenTotal) len -= lenTotal;
  vdgeom$GetCrvArcParPt(crv = crv, len = len, pt = major);

  // Make sure not almost straight
  VDgeomGetAngleFrom3Points(minor,center,major,&angle);
  angle = VDgeomRadToDeg(angle);
  if ((angle > 30.0) && (angle < 150.0)) {
    retFlag = 1;
    goto wrapup;
  }
  printf("*** Have Collinear Center,Minor,Major\n");
  
  // Done
  retFlag = 1;
  
wrapup:
  _FREE(pars);
  _FREE(intpars);
  
  return retFlag;
}

/* -----------------------------------------------
 * Expand the curve about the center point
 *
 * The interaction between weight and expansion is tricky
 */
IGRstat VDgeomExpandSymCrv(TGRbsp_curve *crv,
			   IGRpoint      center,
			   IGRdouble     exp)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  IGRint    i,j;  
  IGRpoint   pt;
  IGRvector vec;
  IGRdouble dis;
  IGRdouble scale;
  IGRdouble weight;
  
  // Arg check
  if (crv    == NULL) goto wrapup;
  if (center == NULL) goto wrapup;
  
  // Cycle through poles
  for(i = 0; i < crv->num_poles; i++) {

    // Grab the weight
    if ((crv->rational) && (crv->weights)) weight = crv->weights[i];
    else                                   weight = 1.0;
    
    // Grab the pole, adjust if rational
    for(j = 0; j < 3; j++) {
      pt[j] = crv->poles[(i*3)+j] / weight;
    }
    
    // Find the vector to offset
    VDgeomGetDisPtPt(center,pt,&dis);
    if (dis >= .001) scale = (dis + (exp/weight)) / dis;
    else             scale = 0;
    //scale /= weight;
    
    // Adjust the Point
    BSmkvec(&rc,vec,center,pt);
    for(j = 0; j < 3; j++) {
      pt[j] = center[j] + (vec[j] * scale);
    }
    
    // Replace it
    for(j = 0; j < 3; j++) {
      crv->poles[(i*3)+j] = pt[j] * weight;
    }

  }
  

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;




