/* $Id: VDgeomOld.I,v 1.2 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeom.I
 *
 * Description:	Geometry Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomOld.I,v $
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
# Revision 1.5  2000/03/21  17:37:08  pinnacle
# ah
#
# Revision 1.4  1999/10/26  18:38:54  pinnacle
# ah
#
# Revision 1.3  1999/05/24  18:22:12  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/08/98  ah      Creation
 * 03/21/00  ah      Added VDgeomAllocCrv()
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"

static int traceFlag;

/* ----------------------------------------------------------------
 * Tests to see if a curve is a circular arc
 * Can handle composite curves
 * Recursive routine
 */
IGRstar VDgeomIsCrvArc(TGRbsp_curve *a_crv,
		       IGRdouble     a_tol,
                       IGRpoint      a_arcCenter, 
                       IGRdouble    *a_arcRadius)
{
  IGRstat retFlag = 0;
  BSrc    rc;

  IGRint  i;
  
  struct {    
    IGRshort  flag;
    IGRpoint  center;
    IGRdouble radius;
    TGRbsp_curve *bsp;
  } arc,arc1,arc2;

  IGRdouble par1,par2,dist;

  TGRbsp_curve *arcxBsp = NULL;
  
  // Init
  arc1.bsp = NULL;
  arc2.bsp = NULL;
  
  // Arg check
  if (a_arcRadius) *a_arcRadius = 0.0;
  if (a_crv == NULL) goto wrapup;
  
  // Arc Test
  // BStstcvcarc(a_crv,&arc.flag,arc.center,&arc.radius,&rc);
  vdgeom$AllocCrv(order     = 3,
		  num_poles = 7,
		  rational  = 1,
		  crv       = &arcxBsp);

  if (arcxBsp == NULL) goto wrapup;
  
  BStstcvarct(a_crv,a_tol,&arc.flag,arc.center,&arc.radius,arcxBsp,&rc);
  if (arc.flag != 0) {

    if (traceFlag) {
      printf("Arc0 Center %8.2f,%8.2f,%8.2f\n",
             arc.center[0],
  	     arc.center[1],
	     arc.center[2]);
    }

    if (a_arcCenter) {
      a_arcCenter[0] = arc.center[0];
      a_arcCenter[1] = arc.center[1];
      a_arcCenter[2] = arc.center[2];
    }
    
    if (a_arcRadius) *a_arcRadius =  arc.radius;
    retFlag = 1;
    goto wrapup;
  }
  
  // Sometimes get a composite curve with identical arcs
  for(i = 0; (i < a_crv->num_knots) && (a_crv->knots[i] < .01); i++);
  par2 = a_crv->knots[i];
  if (par2 > .99) {
    //printf("============== In circular arc with no internal knots\n");
    goto wrapup; // No internal knots
  }
  //printf("============== In circular arc with internal knots\n");
  
  par1 = 0.0;
  
  // Pull first curve
  VDgeomExtractCurve(a_crv,par1,par2,&arc1.bsp);
  if (arc1.bsp == NULL) goto wrapup;
  
  // Is it an arc???
  arc1.flag = VDgeomIsCrvArc(arc1.bsp,a_tol,arc1.center,&arc1.radius);
  if (arc1.flag == 0) goto wrapup;
  
  // printf("Arc 1, %6.3f,%6.3f Radius %8.3f\n",par1,par2,arc1.radius);
  
  // Test each additional curve for same arc
  par1 = par2;
  for(i++; i < a_crv->num_knots; i++) {
    par2 = a_crv->knots[i];
    if ((par2-par1) > .01) {

      VDgeomExtractCurve(a_crv,par1,par2,&arc2.bsp);
      if (arc2.bsp == NULL) goto wrapup;

      arc2.flag = VDgeomIsCrvArc(arc2.bsp,a_tol,arc2.center,&arc2.radius);
      if (arc2.flag == 0) goto wrapup;
  
      // printf("Arc 2, %6.3f,%6.3f Radius %8.3f\n",par1,par2,arc2.radius);

      if (fabs((arc1.radius - arc2.radius) > .01)) goto wrapup;

      dist = BSdistptpt(&rc,arc1.center,arc2.center);
      if (dist > .01) goto wrapup;
      
      _FREE(arc2.bsp);
      arc2.bsp = NULL;

      par1 = par2;
      
    }
  }
  
  // Got it
  if (a_arcCenter) {
    a_arcCenter[0] = arc1.center[0];
    a_arcCenter[1] = arc1.center[1];
    a_arcCenter[2] = arc1.center[2];
  }
  if (a_arcRadius) *a_arcRadius =  arc1.radius;

  if (traceFlag) {
    printf("Arc1 Center %8.2f,%8.2f,%8.2f\n",
           arc1.center[0],
           arc1.center[1],
           arc1.center[2]);
  }

  retFlag = 1;
  
wrapup:

  if (arc1.bsp) _FREE(arc1.bsp);
  if (arc2.bsp) _FREE(arc2.bsp);

  if (arcxBsp)  _FREE(arcxBsp);
  
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Checks for linear points within tolerance
 */
IGRstar VDgeomIsPtsLinear(IGRint     cnt, 
                          IGRdouble *pts, 
                          IGRdouble *wgts,
                          IGRdouble  tol)
{
  IGRstat retFlag = 0;

  IGRint    code = 0;
  IGRint    i;
  IGRpoint  pt;
  IGRvector vec;
  IGRdouble err = 0.0;

  BSrc rc;

  if (traceFlag) {

    printf("=======================================\n");
    printf(">>> VDgeomIsPtsLinear Tol = %f, Cnt = %d\n",tol,cnt);
    for(i = 0; i < cnt; i++) {
      printf("%2d %12.4f %12.4f %12.4f ",i,
             pts[(i*3)+0],
	     pts[(i*3)+1],
	     pts[(i*3)+2]);
      if (wgts) printf("%8.2f\n",wgts[i]);
      else     printf("\n");
    }
  }

  // Weight least square fit to line
  BSlsqptlpl2(cnt,pts,wgts,2,
	      &code,pt,vec,&err,&rc);

  if ((code == 1) || (code == 2)) {
    //    printf("Is Linear\n");
    retFlag = 1;
    goto wrapup;
  }
 
  if (code != 4) {
    //printf("Points are not linear %d,%f,%f\n",code,tol,err);
    goto wrapup;
  }

  // Check against tolerance
  if (err > tol) {
    //printf("Straight Line Tolerance Failed %f %f\n",tol,err);
    goto wrapup;
  }
  //printf("Is Linear\n");
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------
 * Tests to see if a curve is a circular arc
 * Can handle composite curves
 * Recursive routine
 */
IGRstat VDgeomIsCirArc(TGRbsp_curve *a_crv, 
                       IGRpoint      a_arcCenter, 
                       IGRdouble    *a_arcRadius)
{
  IGRstat retFlag = 0;
  BSrc    rc;

  IGRint  i;
  
  struct {    
    IGRshort  flag;
    IGRpoint  center;
    IGRdouble radius;
    TGRbsp_curve *bsp;
  } arc,arc1,arc2;

  IGRdouble par1,par2,dist;

  TGRbsp_curve *arcxBsp = NULL;
  
  // Init
  arc1.bsp = NULL;
  arc2.bsp = NULL;
  
  // Arg check
  if (a_arcRadius) *a_arcRadius = 0.0;
  if (a_crv == NULL) goto wrapup;
  
  // Arc Test
  // BStstcvcarc(a_crv,&arc.flag,arc.center,&arc.radius,&rc);
  vdgeom$AllocCrv(order     = 3,
		  num_poles = 7,
		  rational  = 1,
		  crv = &arcxBsp);
  if (arcxBsp == NULL) goto wrapup;

  // Tolerance is critical, .1,.15 is too small
  //tstcvarct(a_crv,.15,&arc.flag,arc.center,&arc.radius,arcxBsp,&rc);
  //printf("Arc Testing\n");
  BStstcvarct(a_crv,.15,&arc.flag,arc.center,&arc.radius,arcxBsp,&rc);
  
  if (arc.flag != 0) {

#if 0
    printf("Arc0 Center %8.2f,%8.2f,%8.2f\n",
	   arc.center[0],
	   arc.center[1],
	   arc.center[2]);
#endif

    if (a_arcCenter) {
      a_arcCenter[0] = arc.center[0];
      a_arcCenter[1] = arc.center[1];
      a_arcCenter[2] = arc.center[2];
    }
    
    if (a_arcRadius) *a_arcRadius =  arc.radius;
    retFlag = 1;
    goto wrapup;
  }
  
  // Sometimes get a composite curve with identical arcs
  for(i = 0; (i < a_crv->num_knots) && (a_crv->knots[i] < .01); i++);
  par2 = a_crv->knots[i];
  if (par2 > .99) {
    //printf("============== In circular arc with no internal knots\n");
    goto wrapup; // No internal knots
  }
  //printf("============== In circular arc with internal knots\n");
  
  par1 = 0.0;
  
  // Pull first curve
  VDgeomExtractCurve(a_crv,par1,par2,&arc1.bsp);
  if (arc1.bsp == NULL) goto wrapup;
  
  // Is it an arc???
  arc1.flag = VDgeomIsCirArc(arc1.bsp,arc1.center,&arc1.radius);
  if (arc1.flag == 0) goto wrapup;
  
  // printf("Arc 1, %6.3f,%6.3f Radius %8.3f\n",par1,par2,arc1.radius);
  
  // Test each additional curve for same arc
  par1 = par2;
  for(i++; i < a_crv->num_knots; i++) {
    par2 = a_crv->knots[i];
    if ((par2-par1) > .01) {

      VDgeomExtractCurve(a_crv,par1,par2,&arc2.bsp);
      if (arc2.bsp == NULL) goto wrapup;

      arc2.flag = VDgeomIsCirArc(arc2.bsp,arc2.center,&arc2.radius);
      if (arc2.flag == 0) goto wrapup;
  
      // printf("Arc 2, %6.3f,%6.3f Radius %8.3f\n",par1,par2,arc2.radius);

      if (fabs((arc1.radius - arc2.radius) > .01)) goto wrapup;

      dist = BSdistptpt(&rc,arc1.center,arc2.center);
      if (dist > .01) goto wrapup;
      
      _FREE(arc2.bsp);
      arc2.bsp = NULL;

      par1 = par2;
      
    }
  }
  
  // Got it
  if (a_arcCenter) {
    a_arcCenter[0] = arc1.center[0];
    a_arcCenter[1] = arc1.center[1];
    a_arcCenter[2] = arc1.center[2];
  }
  if (a_arcRadius) *a_arcRadius =  arc1.radius;

#if 0
  printf("Arc1 Center %8.2f,%8.2f,%8.2f\n",
	 arc1.center[0],
	 arc1.center[1],
	 arc1.center[2]);
#endif

  retFlag = 1;
  
wrapup:

  if (arc1.bsp) _FREE(arc1.bsp);
  if (arc2.bsp) _FREE(arc2.bsp);

  if (arcxBsp)  _FREE(arcxBsp);
  
  return retFlag;
}

/* -----------------------------------------------------
 * Turns the input curve into a line
 * *line is NULL if crv is already a line
 * 
 * Obsolete 
 */
IGRstar VDgeomConvertToLine(TGRbsp_curve *crv, TGRbsp_curve **line)
{
  IGRstat retFlag = 0;
  
  IGRpoint pt1,pt2;
  
  // Arg check
  if (line == NULL) goto wrapup;
  *line = NULL;
  if (crv == NULL) goto wrapup;
  
  /* Input curve might already be a line segment
   * Just return for now
   */
  if ((crv->order == 2) && (crv->num_poles == 2)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Use endpoints
  VDgeomGetCrvEndPts(crv,pt1,pt2);

  // Do it
  VDgeomMakeLineCurve(pt1,pt2,line);
  if (*line == NULL) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Compares two edge geometries and combines into one
 * if it can, assumes curve end pts match
 * Calling routine should check to see if crv3 was created
 * Does NOT free crv1 or crv2
 *
 * Obsolete - Dont Use
 */
IGRstar VDgeomConcatEdges(TGRbsp_curve  *crv1,
	 		  TGRbsp_curve  *crv2,
                          IGRdouble      tol,
			  TGRbsp_curve **crv3)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRdouble pts[9];
  IGRint    i,j;
  IGRint    mergePoles = 0;
  IGRint    mergeOrder = 0;
  
  BSrc rc;

  if (traceFlag) {
    printf(">>> VPextConcatEdges\n");
  }

  // Arg check
  if (crv3 == NULL) goto wrapup;
  *crv3 = NULL;
  
  if (crv1 == NULL) goto wrapup;
  if (crv2 == NULL) goto wrapup;
  if (crv1->num_poles < 2) goto wrapup;
  if (crv2->num_poles < 2) goto wrapup;

  if (traceFlag) {
    vdgeom$Print(crv = crv1);
    vdgeom$Print(crv = crv2);
  }

  // Use poles to form tanget lines nonsense
  // Take last two points from crv1 and second poles in curve 2
  j = (crv1->num_poles -2) * 3;
  for(i = 0; i < 6; i++) pts[i] = crv1->poles[j+i];

  // Might need to adjust first pole if it is rationsl
  if (crv1->rational) {
    for(i = 0; i < 3; i++) pts[i] /= crv1->weights[crv1->num_poles-2];
  }

  // Use second pole from crv2, adjust if rational
  for(i = 0; i < 3; i++) pts[i+6] = crv2->poles[i+3];
  if (crv2->rational) {
    for(i = 6; i < 9; i++) pts[i] /= crv2->weights[1];
  }
  if (traceFlag) {
    for(i = 0; i < 3; i++) {
      printf("PT %d %8.2f %8.2f %8.2f\n",i,
  	     pts[(3*i)+0],
	     pts[(3*i)+1],
	     pts[(3*i)+2]);  
    }
  }
  sts = VDgeomIsPtsLinear(3,pts,NULL,tol);
  if (!(sts & 1)) goto wrapup;
  
  if (traceFlag) {
    printf("Merging curves\n");
  }

  // Allocate  
  if (crv1->order == crv2->order) {
    mergeOrder = crv1->order;
    mergePoles = crv1->num_poles + crv2->num_poles - 1;
  }
  
  if (crv1->order > crv2->order) {
    mergeOrder = crv1->order;
    mergePoles = crv1->num_poles + crv2->num_poles + 
               ((crv2->num_poles - crv2->order + 2) *
                (crv1->order     - crv2->order));
  }
  if (crv1->order < crv2->order) {
    mergeOrder = crv2->order;
    mergePoles = crv1->num_poles + crv2->num_poles + 
               ((crv1->num_poles - crv1->order + 2) *
                (crv2->order     - crv1->order));
  }

  vdgeom$AllocCrv(order     = mergeOrder,
		  num_poles = mergePoles,
		  rational  = 1,
		  crv       = crv3);

  if (*crv3 == NULL) {
    printf("*** Problem allocating merged curve\n");
  }  
  BSmerge_cv(&rc,crv1,crv2,*crv3);
  
  if (rc != BSSUCC) {
    printf("Problem with BSmergarrcv\n");
    goto wrapup;
  }
  if (*crv3 == NULL) {
    printf("Problem with BSmergarrcv, merge is NULL\n");
    goto wrapup;
  }
  if (traceFlag) {
    printf("Did the merge\n");
  }

  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) {
    printf("<<< VDgeomConcatEdges %d\n",retFlag);
  }

  return retFlag;
}

/* -----------------------------------------------
 * Little convertors
 */
IGRdouble VDgeomRadToDeg(IGRdouble rad)
{
  return 180.0 * (rad / VDGEOM_M_PI);
}
IGRdouble VDgeomDegToRad(IGRdouble deg)
{
  return VDGEOM_M_PI * (deg / 180.0);
}

end implementation Root;









