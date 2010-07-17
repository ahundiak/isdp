/* ----------------------------------------------------
 * Curve Extraction 
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VPpdf.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "maoptsxfo.h"
#include "bststcvcarc.h"
#include "bststcvfln.h"

#define vdsDEBUGx 1
#include "vldbgmacros.h"

/* ----------------------------------------
 * List of vertexes for line arc curve
 */
typedef struct {
  IGRint    type;
  IGRdouble x,y,z;
} PDF_VERTEX;

static PDF_VERTEX *vtxList;
static IGRint      vtxMax;
static IGRint      vtxCnt;

static IGRint        pdfTranslationMatrixFlag;
static TGRmdenv_info pdfTranslationMatrix;

#define PDF_ARC_TOL  .70
#define PDF_LINE_TOL .70

/* ----------------------------------
 * Gets point along curve
 */
IGRstat VPpdfGetCvEval(TGRbsp_curve *bsp, IGRdouble par, TGRpoint *pt)
{
  IGRstat retFlag = 0;
  BSrc rc;
  IGRpoint ptList[1];
  IGRdouble *val;

  IGRint   numDeriv = 0;

  BScveval(bsp,par,numDeriv,ptList,&rc);
  if (rc != BSSUCC) {
    printf("*** Problem Evaluating Curve\n");
    goto wrapup;
  }
  val = (IGRdouble*)&ptList[0];

  pt->x = *(val+0);
  pt->y = *(val+1);
  pt->z = *(val+2);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------
 * Filles in array of points
 */
IGRstat VPpdfGetBspPoints(TGRbsp_curve *bsp, TGRpoint *ptList)
{
  IGRdouble par;
  IGRint i;

  ptList[0].x = bsp->poles[0];
  ptList[0].y = bsp->poles[1];
  ptList[0].z = bsp->poles[2];

  ptList[8].x = bsp->poles[((bsp->num_poles-1)*3)+0];
  ptList[8].y = bsp->poles[((bsp->num_poles-1)*3)+1];
  ptList[8].z = bsp->poles[((bsp->num_poles-1)*3)+2];

  par = 0.0;
  for(i = 1; i < 8; i++) {
    par += .125;
    VPpdfGetCvEval(bsp,par,&ptList[i]);
  }
  return 1;
}

IGRstat VPpdfIsPtsLinear(IGRint numPoints, IGRdouble *pts) 
{
  IGRstat   retFlag = 0;
  IGRint    code;
  IGRpoint  pt;
  IGRvector vec;
  IGRdouble err;
  BSrc      rc;

  BSlsqptlnpl(
    numPoints,pts,NULL,
    2,&code,
    pt,vec,&err,&rc);

  if (rc != BSSUCC) goto wrapup;

  if (code == 1) return 1;
  if (code == 2) return 1;
  if (code != 4) goto wrapup;

  if (err < PDF_LINE_TOL) retFlag = 1;

  // printf("Code 4 %.4f\n",err);

wrapup:
  return retFlag;
}

/* -----------------------------------
 * No knots, convert to simple line/arcs
 */
IGRstat VPpdfNoIntKnots(TGRbsp_curve *bsp) 
{
  IGRstat retFlag = 0;
//IGRstat sts;
  BSrc    rc;

  IGRshort lineFlag;
  IGRpoint lineBeg,lineEnd;
  
  IGRpoint  arcMid,arcEnd;
  IGRshort  arcFlag;

  IGRdouble endPt[3];
  
#if 0
  IGRpoint  arcCenter;
  IGRdouble arcRadius;

   struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
  } crv;

  TGRbsp_curve *arcBsp = NULL;

  IGRdouble par,par1,par2,par3;

  IGRdouble midPt[3];
  IGRdouble endPt[3];
  
  IGRdouble crvPt[3];
  IGRint    numDeriv;
  IGRint    rational;
  IGRint    numPoles;

  IGRint    i;

  IGRdouble crvRadius;
  IGRdouble arcCrvTol;
  
  TGRpoint  ptList[10];
#endif

  /* Lots of checking */
  if (bsp == NULL) goto wrapup;

  // vdgeom$Print(txt = "In VPpdfNoKNOTS",crv = bsp);

  switch(bsp->order) {
  case 3:
  case 4:
    break;
  default:
    printf("In VPpdfNoIntKnots, Curve order: %d\n",bsp->order);
    goto wrapup;
  }

  if (bsp->order != bsp->num_poles) {
    printf("In VPpdfNoIntKnots, Order/Poles %d %d\n",bsp->order,bsp->num_poles);
    goto wrapup;
  }

  // Is it linear
  BStstcvfln(bsp,&lineFlag,lineBeg,lineEnd,&rc);
  if (lineFlag != 0) {
    VDgeomGetCrvPt(bsp,1.0,endPt);
    VPpdfAddVtx(0,endPt);
    retFlag = 1;
    goto wrapup;
  }
  
  // See if it is a arc, another routine allows specifying tolerance
  //BStstcvcarc(bsp,&arcFlag,arcCenter,&arcRadius,&rc);
  arcFlag = VDgeomIsCrvArc(bsp,PDF_ARC_TOL,NULL,NULL);

  /* ---------------------------------------------------------
   * 07 Jun 1999, back bracket on 2310-d was differnet from same
   * bracket on 2310-c, had two edges failing arc test, and they really
   * are not arcs though they sure look like it.
   *
   * Finally gave up and just treated them as arcs, see what happens
   */
  arcFlag = 1;
  if (arcFlag != 0) {
  
    // Need point along arc
    VDgeomGetCrvPt(bsp,.5,arcMid);
 
    VPpdfAddVtx(1, arcMid);
    VDgeomGetCrvPt(bsp,1.0,arcEnd);
    VPpdfAddVtx(0,arcEnd);

    retFlag = 1;
    goto wrapup;
    
  }
  
  vdgeom$Print(txt = "In VPpdfNoKnots",crv = bsp);
  
#if 0
  /* Grab Points along curve */
  sts = VPpdfGetBspPoints(bsp,ptList);
  if (!(sts & 1)) goto wrapup;

  /* See if linear */
  sts = VPpdfIsPtsLinear(9,(IGRdouble*)ptList);
  if (sts == 1) {
    VPpdfAddVtx(0,&bsp->poles[(numPoles-1)*3]);
    retFlag = 1;
    // printf("Linear\n");
    goto wrapup;
  }

  /* At this point, it would be nice to check for conic or
     at least arc but I don't know how yet.
     So take the middle of the curve (par = .5) and turn
     into an arc then bounce it against the original curve
  */

  /* Allocate room for arc */
  crv.order = 4;
  crv.num_poles = 20;
  crv.rational  = 1;
  crv.num_bound = 0;
  arcBsp = NULL;

  BSalloccv(
    crv.order,
    crv.num_poles,
    crv.rational,
    crv.num_bound,
   &arcBsp,&rc);

  if (rc != BSSUCC) {
    printf("Problem allocating arc curve\n");
    goto wrapup;
  }

  /* Need Mid Point of arc */
  par = 0.5;
  numDeriv = 0;
  BScveval(bsp,par,numDeriv,(IGRpoint*)midPt,&rc);

  if (rc != BSSUCC) {
    printf("Problem getting center of curve\n");
    goto wrapup;
  }
  printf("Mid Point %10.3f,%10.3f,%10.3f\n",midPt[0],midPt[1],midPt[2]);
  
  /* Arc It */
  BSarc3pts(&rc,&bsp->poles[0],midPt,&bsp->poles[6],arcBsp);
  if (rc != BSSUCC) {
    printf("Problem Creating Arc\n");
    goto wrapup;
  }
  vdgeom$Print(txt = "The arc", crv = arcBsp);
  
  /* Get Center */
  BSarccen(&rc,arcBsp,arcCenter);
  if (rc != BSSUCC) {
    printf("Problem Getting Center Of Arc\n");
    goto wrapup;
  }

  /* Get radius */
  arcRadius = BSdistptpt(&rc,midPt,arcCenter);

  printf("Arc Created: %.2f,%.2f,%.2f Radius: %.2f\n",
	 arcCenter[0],
	 arcCenter[1],
	 arcCenter[2],
	 arcRadius);

  /* Now test to see if it is really an arc */
  for(par = .1; par < 1.0; par += .1) {

    BScveval(bsp,par,numDeriv,(IGRpoint*)crvPt,&rc);

    if (rc != BSSUCC) {
      printf("Problem getting parameter of curve\n");
      goto wrapup;
    }
    crvRadius = BSdistptpt(&rc,crvPt,arcCenter);
    
    arcCrvTol = fabs(arcRadius - crvRadius);

    printf(
	   "Radius %5.2f %8.2f %8.2f %8.2f\n",
	   par,
	   arcRadius,
	   crvRadius,
	   arcCrvTol); 

    if (arcCrvTol > PDF_ARC_TOL) {

      if (bsp->order == 3) {
        printf("3rd Order curve failed arc test\n");
        goto wrapup; 
      }

      /* Split into two and try again */
      par1 = 0.0;
      par2 = 0.25;
      par3 = 0.50;

      BSpartofcv(&rc,bsp,par1,par2,par3,arcBsp);

      if (rc != BSSUCC) {
        printf("Problem splitting curve\n");
        goto wrapup;
      }

      sts = VPpdfNoIntKnots(arcBsp);
      if (!(sts & 1)) goto wrapup;

      /* Other Half */
      par1 = 0.50;
      par2 = 0.75;
      par3 = 1.00;

      BSpartofcv(&rc,bsp,par1,par2,par3,arcBsp);

      if (rc != BSSUCC) {
        printf("Problem splitting curve\n");
        goto wrapup;
      }

      sts = VPpdfNoIntKnots(arcBsp);
      if (!(sts & 1)) goto wrapup;

      retFlag = 1;
      goto wrapup;
    }
  }

  printf("Added Arc Middle\n");  
  VPpdfAddVtx(1, midPt);
  VDgeomGetCrvPt(bsp,1.0,endPt);
  VPpdfAddVtx(0,endPt);

  retFlag = 1;
#endif

wrapup:
  // _FREECV(&rc,arcBsp);
  return retFlag;
}

/* -----------------------------------
 * Breaks up curve into curves with no
 * internal knots
 */
IGRstar VPpdfNthOrderCrv(TGRbsp_curve *bsp)
{
  IGRstat retFlag = 0;
  BSrc rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
    TGRbsp_curve *bsp;
  } crv;

  IGRdouble par1,par2,par3;
  IGRint i;
  IGRint rational;

  //vdgeom$Print(crv = bsp, txt = "Check Curve ");

  /* Init values */
  memset(&crv,0,sizeof(crv));

  /* Filter */
  if (bsp == NULL) goto wrapup;
  switch (bsp->order) {
    case 3:
    case 4:
    break;

    default:
      printf("Can't process curve with order: %d\n",bsp->order);
      goto wrapup;
  }

  if (bsp->num_boundaries != 0) {
    printf("Curve has boundaries: %d\n",bsp->num_boundaries);
    goto wrapup;
  }

  /* Rational/Weight Flag */
  if (bsp->weights) rational = 1;
  else              rational = 0;

  /* Get rid of internal knots */
  crv.order = 4;
  crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
  crv.rational = 1;
  crv.num_bound = 0;
  crv.bsp = NULL;

  BSalloccv(
    crv.order,
    crv.num_poles,
    crv.rational,
    crv.num_bound,
   &crv.bsp,&rc);

  if (rc != BSSUCC) {
    printf("Problem allocating new curve\n");
    goto wrapup;
  }

  /* Setup Paraneters */
  par1 = bsp->knots[0];

  for(i = 1; i < bsp->num_knots; i++) {

    if (fabs(par1 - bsp->knots[i]) > .001) {

      par3 = bsp->knots[i];
      par2 = (par1 + par3) / 2.0;

      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

      if (rc != BSSUCC) {
        printf("Problem Getting Part Of\n");
        goto wrapup;
      }

      //vdgeom$Print(crv = crv.bsp, txt = "Sub Curve ");
      VPpdfNoIntKnots(crv.bsp);

      par1 = par3;
    }
  }

  retFlag = 1;

wrapup:
  _FREECV(&rc,crv.bsp);
  return retFlag;
}


/* ----------------------------------------
 * Handles 2nd order non-rational
 */
IGRstat VPpdf2ndOrderCrv(TGRbsp_curve *bsp) {

  IGRstat retFlag = 0;
  IGRint  i;
    
  IGRint    code;
  IGRpoint  pt;
  IGRvector vec;
  IGRdouble err;
  BSrc      rc;

  SetProc(VPpdf2ndOrderCrv); Begin
  
  // printf("Entered VPpdf2ndOrderCrv %d %d\n",bsp->order,bsp->num_poles);
  // see if 2nd order non-rational
  if (bsp->order != 2) goto wrapup;
  if (bsp->weights != NULL) {
    printf("Have a 2nd order RATIONAL curve???\n");
    goto wrapup;
  }
  //printf("Have 2nd order with %d poles\n",bsp->num_poles);
  
  /* ------------------------------------------------
   * Many seemingly straight edges end up with hundreds
   * of poles, bounce against line tolerance to see if
   * it should be treated as a straight line
   *
   * A more advanced version might attempt to split the line if the
   * tolerance is exceeded but save that for later
   */
  BSlsqptlnpl(
    bsp->num_poles,bsp->poles,NULL,
    2,&code,
    pt,vec,&err,&rc);

  // printf("2nd Order, %d, %.4f\n",bsp->num_poles,err);

  if (err <= PDF_LINE_TOL) {
    VPpdfAddVtx(0,&bsp->poles[(bsp->num_poles - 1) * 3]);
    retFlag = 1;
    goto wrapup;
  }
  
  // Just dump out poles
  for(i = 1; i < bsp->num_poles; i++) {
    VPpdfAddVtx(0,&bsp->poles[i*3]);
  }
  retFlag = 1;

wrapup:
  End
  return retFlag;
}

/* ---------------------- */
/* Add one vertex to list */
IGRstar VPpdfAddVtx(IGRint type, IGRdouble *vtx) 
{
  if ((vtx == NULL) || (vtxList == NULL)) return 0;
  if (vtxCnt >= vtxMax) return 0;

  vtxList[vtxCnt].type = type;
  vtxList[vtxCnt].x = vtx[0];
  vtxList[vtxCnt].y = vtx[1];
  vtxList[vtxCnt].z = vtx[2];
  vtxCnt++;

  return 1;
}

/* ----------------------------------------
 * Adds contour to existing list
 */
IGRstar VPpdfAddContour(TGRbsp_curve *bsp) {

  IGRstat   retFlag = 0;
  IGRstat   sts;
  IGRdouble pt[3];
 
  SetProc(VPpdfAddContour); Begin 

  // vdgeom$Print(crv = bsp, txt = "Contour Curve ");
  
  /* Make sure have something */
  if ((bsp == NULL) ||
      (bsp->num_poles == 0) || 
      (vtxList == NULL)) goto wrapup;

  /* For very first vertex, add it */
  if (vtxCnt == 0) {
    VDgeomGetCrvPt(bsp,0.0,pt);
    VPpdfAddVtx(0,pt);
  }

  /* 2nd order curves are easy */
  sts = VPpdf2ndOrderCrv(bsp);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  /* More complicated curve */
  sts = VPpdfNthOrderCrv(bsp);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  End
  return retFlag;
}

/* --------------------------------------
 * Setup vertix data
 */
IGRstat VPpdfBegContour() {

  vtxCnt  = 0;
  vtxMax  = 4096;

  if (vtxList == NULL) {
    vtxList = (PDF_VERTEX*) _MALLOC(vtxMax,PDF_VERTEX);
  }
  
  if (vtxList == NULL) {
    printf("Could not allocate vertex memory\n");
    return 0;
  }

  return 1;
}

/* ----------------------------------------
 * Writes out contour stuff then empties list
 */
IGRstat VPpdfEndContour(IGRint recType) {

  IGRstat retFlag = 0;
  IGRstat msg;
  IGRint  i,j;
  IGRint  len,hdrLen;

  IGRlong   numPoles;
  IGRdouble poles[3];

  IGRint    numBundles;
  IGRint    bundle;
  unsigned int long flag;

  
  /* Ignore if no bundles */
  if (vtxCnt == 0)  goto wrapup;

  /* Bundle in groups of 32 */
  numBundles = ((vtxCnt - 1) / 32) + 1;
  len = (vtxCnt * 2) + numBundles;

  if (len > 250) hdrLen = 252;
  else           hdrLen = len;

  // printf("Length: %d, Points: %d, Bundles %d\n",len,vtxCnt,numBundles);

  VPpdfWriteHdr(
    recType,
    PDF_DT_2D_LINE_ARC,
    hdrLen
  );

  if (hdrLen == 252) {
    VPpdfWriteInt(len);
  }

  /* Go through bundle by bundle */
  for(bundle = 0; bundle < numBundles; bundle ++) {

    /* Control Flags */
    flag = 0;
    for(i = 0; i < 32; i++) {

      flag = flag >> 1;

      j = (bundle * 32) + i;
      if ((j < vtxCnt) && (vtxList[j].type == 1)) flag |= 0x80000000;
    }
    VPpdfWriteInt(flag);

    /* Data */
    for(i = 0; i < 32; i++) {

      j = (bundle * 32) + i;
      if (j < vtxCnt) {

        /* Apply final matrix */
        poles[0] = vtxList[j].x;
        poles[1] = vtxList[j].y;
        poles[2] = vtxList[j].z;
        numPoles = 1;

	if (pdfTranslationMatrixFlag) {
	  
	  MAoptsxform(&msg,
		      &numPoles,
		      &pdfTranslationMatrix.matrix_type,
		       pdfTranslationMatrix.matrix,
		       poles,poles);
	}
	
        VPpdfWriteReal(poles[0]);
        VPpdfWriteReal(poles[1]);
	
      }
    }
  }
  
  retFlag = 1;

wrapup:

  // Free up list
  //_FREE(vtxList);
  //vtxList = NULL;
  //vtxCnt = 0;
  //vtxMax = 0;
  return retFlag;

}

/* ----------------------------------------
 * Wrapper for single 3d curve
 */
IGRstar VPpdfWriteBspCurve3D(IGRint recType, TGRbsp_curve *bsp)
{
  if (bsp == NULL) return 0;

  // VDdrawCurve(bsp);
  pdfTranslationMatrixFlag = 1;
  
  VPpdfBegContour();
  VPpdfAddContour(bsp);
  VPpdfEndContour(recType);

  pdfTranslationMatrixFlag = 0;

  return 1;
}
/* ----------------------------------------
 * Wrapper for single 2d curve
 */
IGRstar VPpdfWriteBspCurve2D(IGRint recType, TGRbsp_curve *bsp)
{
  if (bsp == NULL) return 0;

  // VDdrawCurve(bsp);
  pdfTranslationMatrixFlag = 0;
  
  VPpdfBegContour();
  VPpdfAddContour(bsp);
  VPpdfEndContour(recType);

  pdfTranslationMatrixFlag = 0;

  return 1;
}

/* ----------------------------------------------------
 * Used to translate curve geometry
 */

IGRstar VPpdfSetTranslationMatrix(TGRmdenv_info *mat)
{
  pdfTranslationMatrix = *mat;
  return 1;
}

/* ----------------------------------------
 * Wrapper for single circle/arc
 */
IGRstar VPpdfWriteBspCirArc(IGRint recType, TGRcir_arc *arc)
{
  IGRstat retFlag = 0;
  
  IGRstat msg;
  
  IGRdouble origin[3];

  IGRlong numPoles = 1;
  
  // Arg check
  if (arc == NULL) goto wrapup;

  // Xlat
  MAoptsxform(&msg,
	      &numPoles,
	      &pdfTranslationMatrix.matrix_type,
	       pdfTranslationMatrix.matrix,
	       arc->center,origin);

  VPpdfWriteHdr(recType,PDF_DT_2D_CIRCLE,3);
  VPpdfWriteReal(origin[0]);
  VPpdfWriteReal(origin[1]);
  VPpdfWriteReal(arc->radius * 2.0);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Wrapper for single oval
 */
IGRstar VPpdfWriteBspOval(IGRint recType, TGRoval *oval)
{
  IGRstat retFlag = 0;
  
  IGRstat msg;
  
  IGRdouble pt[3];

  IGRlong numPoles = 1;
  
  // Arg check
  if (oval == NULL) goto wrapup;

  VPpdfWriteHdr(recType,PDF_DT_2D_OVAL,6);

  // Origin
  MAoptsxform(&msg,&numPoles,
	      &pdfTranslationMatrix.matrix_type,
	       pdfTranslationMatrix.matrix,
	       oval->origin,pt);
  
  VPpdfWriteReal(pt[0]);
  VPpdfWriteReal(pt[1]);

  // Major axis
  MAoptsxform(&msg,&numPoles,
	      &pdfTranslationMatrix.matrix_type,
	       pdfTranslationMatrix.matrix,
	       oval->axis1,pt);
  
  VPpdfWriteReal(pt[0]);
  VPpdfWriteReal(pt[1]);

  // Minor axis
  MAoptsxform(&msg,&numPoles,
	      &pdfTranslationMatrix.matrix_type,
	       pdfTranslationMatrix.matrix,
	       oval->axis2,pt);
  
  VPpdfWriteReal(pt[0]);
  VPpdfWriteReal(pt[1]);

  //Depth,width,radius
  //VPpdfWriteReal(oval->major  * 2.0);
  //VPpdfWriteReal(oval->minor  * 2.0);
  //VPpdfWriteReal(oval->radius * 2.0);
 
  retFlag = 1;
  
wrapup: 
  return retFlag;
}

/* ---------------------------------------------------
 * Write single 3D point, flag indicates xform to 2D
 */
IGRstar VPpdfWrite3dPt(IGRint recType, IGRint flag2D, IGRdouble *pt)
{
  IGRstat retFlag  = 0;
  IGRstat msg;
  IGRlong numPoles = 1;

  IGRint  dataType = PDF_DT_3D_PT;
  IGRint  dataLen  = 3;
  
  IGRdouble ptx[3];

  IGRint i;

  // Arg Check
  if (pt == NULL) goto wrapup;

  if (flag2D) {
    MAoptsxform(&msg,&numPoles,
        	&pdfTranslationMatrix.matrix_type,
	         pdfTranslationMatrix.matrix,
	         pt,ptx);
    dataLen  = 2;
    dataType = PDF_DT_2D_PT;
  }
  else {
    for(i = 0; i < 3; i++) ptx[i] = pt[i];
  }

  // Put out the header
  VPpdfWriteHdr(recType,dataType,dataLen);

  // And the data
  VPpdfWriteReal(ptx[0]);
  VPpdfWriteReal(ptx[1]);
  if (flag2D == 0) VPpdfWriteReal(ptx[2]);

#if 0
  printf("dirPt     %10.2f %10.2f %10.2f\n",
          ptx[0],ptx[1],ptx[2]);
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
  
end implementation Root;
