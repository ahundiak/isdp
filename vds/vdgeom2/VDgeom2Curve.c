/* $Id: VDgeom2Curve.c,v 1.6 2001/07/23 16:26:48 ahundiak Exp $  */

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
 *      $Log: VDgeom2Curve.c,v $
 *      Revision 1.6  2001/07/23 16:26:48  ahundiak
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

#include "gocmacros.h"
#include "bsarclnparc.h"
#include "bsellctaxrm.h"

VDASSERT_FFN("VDgeom2Curve.c");

/* -----------------------------------------------------
 * Make a line from two points
 * If *crv points somewhere then it is assumes that it is big
 * enough for a line buffer
 */
IGRstat VDgeom2MakeLineCurve(IGRpoint pt1, IGRpoint pt2, TGRbsp_curve **crv)
{
  VDASSERT_FN("VDgeom2MakeLineCurve");
  
  IGRstat retFlag = 0;
  IGRint  type;
  BSrc    rc;
  IGRint  nullFlag = 0;
  
  // Arg check
  VDASSERTW(crv);
  if (*crv == NULL) nullFlag = 1;
  
  // Alloc or Partition Curve
  VDgeom2AllocCurveBuf(2,2,0,crv,(IGRchar*)*crv,VDGEOM_SIZE_LINE);
  VDASSERTW(*crv);
  
  // Do it
  type = 0;
  BSptlngen(&rc,pt1,pt2,*crv,&type);
  if (rc != BSSUCC) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  if ((retFlag == 0) && (nullFlag == 1)) {
    free(*crv);
    *crv = NULL;
  }
  return retFlag;
}

/* -----------------------------------------------------
 * Make an arc from three points
 * If *crv points somewhere then it is assumes that it is big
 * enough for an arc buffer
 */
IGRstat VDgeom2MakeArcCurve(IGRpoint pt1, 
			    IGRpoint pt2, 
			    IGRpoint pt3, 
			    TGRbsp_curve **crv)
{
  VDASSERT_FN("VDgeom2MakeArcCurve");

  IGRstat retFlag = 0;
  IGRint  nullFlag = 0;
  BSrc    rc;
  
  // Arg check
  VDASSERTW(crv);
  if (*crv == NULL) nullFlag = 1;
  
  // Alloc or Partition Curve
  VDgeom2AllocCurveBuf(3,7,1,crv,(IGRchar*)*crv,VDGEOM_SIZE_ARC);
  VDASSERTW(*crv);
    
  // Do it
  BSarc3pts(&rc, pt1, pt2, pt3, *crv);
  if (rc != BSSUCC) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  if ((retFlag == 0) && (nullFlag == 1)) {
    free(*crv);
    *crv = NULL;
  }
  
  return retFlag;
}

/* -----------------------------------------------------
 * Make a circle from three points
 * If *crv points somewhere then it is assumes that it is big
 * enough for an circle buffer
 */
IGRstat VDgeom2MakeCircleCurve(IGRpoint pt1, 
			       IGRpoint pt2, 
			       IGRpoint pt3, 
			       TGRbsp_curve **crv)
{
  VDASSERT_FN("VDgeom2MakeCircleCurve");

  IGRstat retFlag = 0;
  BSrc    rc;
  IGRint  nullFlag = 0;
  
  // Arg check
  VDASSERTW(crv);
  if (*crv == NULL) nullFlag = 1;
  
  // Alloc or Partition Curve
  VDgeom2AllocCurveBuf(3,7,1,crv,(IGRchar*)*crv,VDGEOM_SIZE_ARC);
  VDASSERTW(*crv);
    
  // Do it
  BScirc3pts(&rc, pt1, pt2, pt3, *crv);
  if (rc != BSSUCC) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  if ((retFlag == 0) && (nullFlag == 1)) {
    free(*crv);
    *crv = NULL;
  }
  return retFlag;
}

/* -----------------------------------------------------
 * Make a ellipse from three points
 * If *crv points somewhere then it is assumes that it is big
 * enough for an ellipse buffer
 */
IGRstat VDgeom2MakeEllipseCurve(IGRpoint center, 
				IGRpoint  major, 
				IGRpoint  minor, 
				TGRbsp_curve **crv)
{
  VDASSERT_FN("VDgeom2MakeEllipseCurve");

  IGRstat retFlag = 0;
  BSrc    rc = BSSUCC;

  IGRvector normal;
  IGRint    ltype;
  IGRint    nullFlag = 0;

  IGRdouble width,depth;
  IGRpoint  pt3;
  IGRint    i;
  
  IGRdouble tol;
  
  // Arg check
  VDASSERTW(crv);
  if (*crv == NULL) nullFlag = 1;
  
  // Alloc or Partition Curve
  VDgeom2AllocCurveBuf(3,7,1,crv,(IGRchar*)*crv,VDGEOM_SIZE_ARC);
  VDASSERTW(*crv);
    
  // Do it
  BSellctaxrm(&rc,center,major,minor,*crv);
  if (rc == BSSUCC) {
    retFlag = 1;
    goto wrapup;
  }
    
  /* ---------------------------------------------
   * Bit of a hack here
   * The above routine will fail on curves that are only
   * somewhat ellipse i.e. almost circular
   * Actually, the tolerance is pretty high
   *
   * In any event, if it's almost a circle then just go ahead
   * and make a circle
   *
   * This happened when using BSprepelli which required orthogonal
   * points, see what this other one does
   */
  VDgeom2GetDisPtPt(center,major,&width);
  VDgeom2GetDisPtPt(center,minor,&depth);
  VDvalGetTolerance("ellipse_is_circle",&tol);
  if (fabs(width - depth) > tol) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Ellipse failed Width %.2f, Depth %.2f, Delta %.2f",
		  width,depth,fabs(width-depth));
    goto wrapup;
  }  
  for(i = 0; i < 3; i++) {
    pt3[i] = center[i] - (major[i] - center[i]);
  }  
  retFlag = VDgeom2MakeCircleCurve(major,minor,pt3,crv);
  
wrapup:
  if ((retFlag == 0) && (nullFlag == 1)) {
    free(*crv);
    *crv = NULL;
  }  
  return retFlag;
}

/* -----------------------------------------------------
 * Make a flat oval from three points
 * Does NOT support pre-allocated buffers
 */
IGRstat VDgeom2MakeFlatOvalCurve(IGRpoint center, 
				 IGRpoint  major, 
				 IGRpoint  minor, 
				 TGRbsp_curve **oval)
{
  VDASSERT_FN("VDgeom2MakeFlatOvalCurve");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  BSrc    rc;

  IGRpoint c,p1,p2,p3,p4,p5,p6,e1,e2,m1,m2;
  IGRint   i;
  
  IGRvector vec_c_e1;
  IGRvector vec_c_m1;
  IGRvector vec_c_p3;
  
  IGRdouble dis_c_e1;
  IGRdouble dis_c_m1;
  IGRdouble dis_c_p3;
  
  IGRdouble scale;

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
  VDASSERTW(oval); *oval = NULL;
  
  // Pull out major,minor,center;
  for(i = 0; i < 3; i++) {
    c [i] = center[i];
    e1[i] = major [i];
    m1[i] = minor [i];
  }
  // e2,m2 is just flip of e1,m1
  BSmkvec(&rc,vec_c_e1,c,e1);
  BSmkvec(&rc,vec_c_m1,c,m1);
  for(i = 0; i < 3; i++) {
    e2[i] = c[i] - vec_c_e1[i];
    m2[i] = c[i] - vec_c_m1[i];
  }

  // The radius of the end caps is the difference in distances
  VDgeom2GetDisPtPt(c,e1,&dis_c_e1);
  VDgeom2GetDisPtPt(c,m1,&dis_c_m1);
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
  
  sts = VDgeom2MakeLineCurve(p1,p2,&crv_p1_p2);
  if (!(sts & 1)) goto wrapup;
  
  sts = VDgeom2MakeArcCurve(p2,e2,p6,&crv_p2_p6);
  if (!(sts & 1)) goto wrapup;

  sts = VDgeom2MakeLineCurve(p6,p5,&crv_p6_p5);
  if (!(sts & 1)) goto wrapup;

  sts = VDgeom2MakeArcCurve(p5,e1,p1,&crv_p5_p1);
  if (!(sts & 1)) goto wrapup;

  // Merge them to create oval
  crvs[0] = crv_p1_p2;
  crvs[1] = crv_p2_p6;
  crvs[2] = crv_p6_p5;
  crvs[3] = crv_p5_p1;
  
  BSmergarrcv(4,crvs,oval,&rc);
  if (rc != BSSUCC) goto wrapup;
        
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Merge two curves, really up to the calling routine to make
 * sure the curves should be merged
 */
IGRstat VDgeom2MergeTwoCurves(TGRbsp_curve  *crv1,
			      TGRbsp_curve  *crv2,
			      TGRbsp_curve **crv3)
{
  VDASSERT_FN("VDgeom2MergeTwoCurves");  
  IGRstat retFlag = 0;
  
  IGRint mergePoles = 0;
  IGRint mergeOrder = 0;
  
  BSrc rc;
  
  IGRint i,crv1i,crv2i;
  IGRpoint pt1,pt2,pt3;
  
  // Arg check
  VDASSERTW(crv3); *crv3 = NULL;
  VDASSERTW(crv1 && crv1->num_poles >= 2);
  VDASSERTW(crv2 && crv2->num_poles >= 2);
  
#if 0
  if (traceFlag) {
    vdgeom$Print(crv = crv1);
    vdgeom$Print(crv = crv2);
  }
#endif

  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   */
  VDgeom2LinkCurves(crv1,crv2);
  
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
    mergePoles = crv2->num_poles + crv1->num_poles + 
               ((crv1->num_poles - crv1->order + 2) *
                (crv2->order     - crv1->order));
  }

  VDgeom2AllocCurve(mergeOrder,mergePoles,1,crv3);
  VDASSERTW(*crv3);

  // The merge
  BSmerge_cv(&rc,crv1,crv2,*crv3);  
  if (rc != BSSUCC) {
    free(*crv3);    
    *crv3 = NULL;
    VDASSERTW(0);
    goto wrapup;
  }
  VDASSERTW(*crv3);  

  /* 
   *  TR# MP4532 - Rama Rao
   *  Reparametrize this merged curve so that interior knots
   *  of multiplicity order-1 are arc length-distributed.
   */
  BSarclnparc(&rc, *crv3);

  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------------
 * Determines how much room a curve needs 
 */
IGRstat VDgeom2GetCurveSize(IGRint order,
			    IGRint num_poles,
			    IGRint rational,
			    IGRint num_boundaries,
			    IGRint *crvSize)
{
  IGRstat retFlag = 1;
  IGRint  size;

  GRbc_size(order,num_poles,rational,num_boundaries,size);
  if (crvSize) *crvSize = size;
  
  return retFlag;
}

/* -------------------------------------------------
 * Get the center of a curve
 */
void VDgeom2GetCurveCenter(TGRbsp_curve *crv, IGRpoint center)
{
  VDASSERT_FN("VDgeom2GetCurveCenter");
  
  BSrc rc;
  
  // Arg check
  VDASSERTW(crv);
  
  // Get it
  BSfndcent(crv,center,&rc);

 wrapup:
  return;
}
/* -------------------------------------------------
 * Get the area of a closed planar curve
 */
void VDgeom2GetCurveArea(TGRbsp_curve *crv, IGRdouble *area)
{
  VDASSERT_FN("VDgeom2GetCurveArea");
  
  BSrc rc;
  IGRpoint center;
  
  // Arg check
  VDASSERTW(area); *area = 0.0;
  VDASSERTW(crv);
  
  // Get it
  BSctrarplcv(1,&crv,center,area,&rc);
  if (rc != BSSUCC) {
    printf("*** VDgeom2GetCurveArea failed\n");
  }
  
 wrapup:
  return;
}
/* -------------------------------------------------
 * Get the range of a curve
 */
void VDgeom2GetCurveRange(TGRbsp_curve *crv, IGRpoint minPt, IGRpoint maxPt)
{
  VDASSERT_FN("VDgeom2GetCurveRange");
  
  BSrc rc;

  // Arg check
  VDASSERTW(crv);
  VDASSERTW(minPt);
  VDASSERTW(maxPt);
  
  BScvmnmxbx(crv, minPt, maxPt, &rc);
  
 wrapup:
  return;
}

/* ----------------------------------------------------------------
 * Transform curve given a matrix
 */
IGRstat VDgeom2TransformCurve(TGRbsp_curve  *a_crv, 
			      TGRmdenv_info *a_mat, 
			      IGRvector      a_vec)
{
  VDASSERT_FN("VDgeom2TransformCurve");
  
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  TGRmdenv_info mat;
  
  // Arg check
  VDASSERTW(a_crv);
  
  // Use passed matrix or idenity
  if (a_mat) mat = *a_mat;
  else {
    VDgeom2SetMatrixToIdentity(&mat);
  }

  // Apply vector if passed
  if (a_vec) {
    mat.matrix[ 3] = a_vec[0];
    mat.matrix[ 7] = a_vec[1];
    mat.matrix[11] = a_vec[2];
    MAtypemx(&rc,mat.matrix,&mat.matrix_type);
  }
  
  // Transform
  if (a_crv->rational) {
    
    MArptsxform(&rc,
		&a_crv->num_poles,
		&a_crv->rational,
		 a_crv->weights,
		 mat.matrix,
		 a_crv->poles,
		 a_crv->poles);
  } 
  else {
    MAoptsxform(&rc,
		&a_crv->num_poles,
		&mat.matrix_type,
		 mat.matrix,
		 a_crv->poles,
		 a_crv->poles);
  }

  retFlag = 1;
  
wrapup:
  return retFlag;

}
/* ----------------------------------------------------------------
 * Transform curve given a matrix
 */
IGRstat VDgeom2MatrixCurve(TGRbsp_curve  *crv, 
			   IGRdouble     *matrix)
{
  VDASSERT_FN("VDgeom2MatrixCurve");
  
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  IGRshort type;
  
  // Arg check
  VDASSERTW(crv);
  VDASSERTW(matrix);
  
  // Transform
  if (crv->rational) {
    
    MArptsxform(&rc,
		&crv->num_poles,
		&crv->rational,
		 crv->weights,
		 matrix,
		 crv->poles,
		 crv->poles);
  } 
  else {
    MAtypemx(&rc,matrix,&type);
    MAoptsxform(&rc,
		&crv->num_poles,
		&type,matrix,
		 crv->poles,
		 crv->poles);
  }

  retFlag = 1;
  
wrapup:
  return retFlag;

}

/* -----------------------------------------------
 * Extracts curve between parameters
 */
IGRstat VDgeom2ExtractCurve(TGRbsp_curve  *crv1, 
			   IGRdouble       par1, 
			   IGRdouble       par2, 
			   TGRbsp_curve **crv2)
{
  VDASSERT_FN("VDgeom2ExtractCurve");
  
  IGRstat retFlag = 0;
  BSrc    rc;
  IGRdouble parM;
  IGRint    num_poles;
  
  // Arg check
  VDASSERTW(crv2); *crv2 = NULL;
  VDASSERTW(crv2);
    
  // Allocate
  num_poles = crv1->num_poles + (crv1->order * 2) - 1;
  VDgeom2AllocCurve(4,num_poles,1,crv2);
  VDASSERTW(*crv2);
  
  // Extract
  parM = (par1 + par2) * .5;
  BSpartofcv(&rc,crv1,par1,parM,par2,*crv2);
  VDASSERTW(rc == BSSUCC);
  
  // Done
  retFlag = 1;
  
wrapup:  
  return retFlag;
}

/* -----------------------------------------------
 * Copies a curve, taking care of allocating stuff
 */
IGRstat VDgeom2CopyCurve(TGRbsp_curve *crv1, TGRbsp_curve **crv2)
{
  VDASSERT_FN("VDgeom2CopyCurve");
  
  IGRstat retFlag = 0;
  BSrc    rc;
    
  IGRint num_poles;
  
  // Arg check
  VDASSERTW(crv2); *crv2 = NULL;
  VDASSERTW(crv1);
  
  // Allocate conservativily
  num_poles = crv1->num_poles + (crv1->order * 2) - 1;  
  VDgeom2AllocCurve(4,num_poles,1,crv2);
  VDASSERTW(*crv2);
  
  // Copy It
  BScv_copy(&rc,crv1,*crv2);
  VDASSERTW(rc == BSSUCC);
  
  retFlag = 1;
  
wrapup:  
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Force the curve to be physically closed by moving end points to
 * the mid point of a line drawn between them
 */
IGRstat VDgeom2CloseCurve(TGRbsp_curve *crv)
{
  VDASSERT_FN("VDgeom2CloseCurve");  
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  IGRint   i,i1,i2;
  IGRpoint pt1,pt2,pt3;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(crv);
  
  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   *
   * Copied from BuildCrv()
   */
  i1 = 0;
  i2 = 3 * (crv->num_poles - 1);
  
  // Get the endpoints
  VDgeom2GetCrvPt(crv,0.0,pt1);
  VDgeom2GetCrvPt(crv,1.0,pt2);
  
  // Adjust
  for(i = 0; i < 3; i++) {
    pt3[i] = (pt1[i] + pt2[i]) * 0.5;
    crv->poles[i1+i] = pt3[i];
    crv->poles[i2+i] = pt3[i];    
  }

  // Watch out for weights
  if(crv->rational){
    for(i = 0; i < 3; i++) {
      crv->poles[i1+i] *= crv->weights[i1/3];
      crv->poles[i2+i] *= crv->weights[i2/3];
    }
  }

  // Done
  crv->phy_closed = 1;
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------
 * Allocates and partitions a curve
 * should be freed with free() and NOT BSfreecv()
 *
 * If an optional buffer is passed then it will be used if
 * it is big enough
 */
IGRstat VDgeom2AllocCurveMaster(IGRint order,
				IGRint num_poles,
				IGRint rational,
				IGRint num_boundaries,
				IGRint flag,
				TGRbsp_curve **crv,
				IGRchar       *buf,
				IGRint         bufSize,
				IGRint        *crvSize)
{
  VDASSERT_FN("VDgeomAllocCurveMaster");
  
  IGRstat retFlag = 0;
  IGRint  size;
  
  // Arg check
  VDASSERTW(crv); *crv = NULL;
    
  // Get the size (this is a macro, hence no address for size)
  GRbc_size(order,num_poles,rational,num_boundaries,size);
#if 0
  printf("Order %d, poles %d, rational %d, boundaries %d, sixe %d\n",
	 order,num_poles,rational,num_boundaries,size);
#endif
  // If the buffer big enough?
  if ((buf) && (bufSize >= size)) {

    // Use the buffer
    *crv = (TGRbsp_curve *)buf;
    if (crvSize) *crvSize = bufSize;
    memset(buf,0,sizeof(TGRbsp_curve));
  }
  else {
    
    // Allocate it
    *crv = (TGRbsp_curve*)calloc(1,size);
    VDASSERTW(*crv);    
    if (crvSize) *crvSize = size;
  }
  
  // Partition It
  GRbc_partition(*crv,order,num_poles,rational,num_boundaries);
  
  /* For now, leave the non-pointer fields as 0 (num_knots etc)
   * Just to be consistent with other software,
   * Really might make more sense to init these values
   */
  if (flag) {
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Force par 1.0 of crv1 to match par0 of curve 2 exactly
 * Adjust to mid point if necessary
 */
IGRstat VDgeom2LinkCurves(TGRbsp_curve *crv1, TGRbsp_curve *crv2)
{
  VDASSERT_FN("VD2geomLinkCurves");  
  IGRstat retFlag = 0;
  
  BSrc rc;
  
  IGRint   i,i1,i2;
  IGRpoint pt1,pt2,pt3;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(crv1);
  VDASSERTW(crv2);
  
  /* ---------------------------------------------
   * Know that the endpoints are withing production tolerance
   * Adjust them to be exactly the same to avoid base tolerance
   * issues when merging
   *
   * Copied from BuildCrv()
   */
  i1 = 3 * (crv1->num_poles - 1);
  i2 = 0;
  
  // Get the endpoints
  VDgeom2GetCrvPt(crv1,1.0,pt1);
  VDgeom2GetCrvPt(crv2,0.0,pt2);
  
  // Adjust
  for(i = 0; i < 3; i++) {
    pt3[i] = (pt1[i] + pt2[i]) * 0.5;
    crv1->poles[i1+i] = pt3[i];
    crv2->poles[i2+i] = pt3[i];    
  }

  // Watch out for weights
  if(crv1->rational){
    for(i = 0; i < 3; i++) {
      crv1->poles[i1+i] *= crv1->weights[i1/3];
    }
  }
  if(crv2->rational){
    for(i = 0; i < 3; i++) {
      crv2->poles[i2+i] *= crv2->weights[i2/3];
    }
  }

  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* ----------------------------------
 * Gets point along curve
 */
IGRstat VDgeom2GetCrvPt(TGRbsp_curve *crv, IGRdouble u, IGRpoint pt)
{
  VDASSERT_FN("VDgeom2GetCrvPt");
  
  IGRstat retFlag = 0;
  BSrc rc;

  IGRint numDeriv = 0;

  VDASSERTW(crv);

  BScveval(crv,u,numDeriv,(IGRpoint*)pt,&rc);
  if (rc != BSSUCC) goto wrapup;
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets the end points of a curve
 */
IGRstat VDgeom2GetCrvEndPts(TGRbsp_curve *crv, IGRpoint pt1, IGRpoint pt2)
{
  VDASSERT_FN("VDgeom2GetCrvEndPts");
  IGRstat retFlag = 0;

  VDASSERTW(crv);
  
  VDgeom2GetCrvPt(crv,0.0,pt1);
  VDgeom2GetCrvPt(crv,1.0,pt2);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* ---------------------------------------------------
 * Get the parameter value of a point on a curve
 */
IGRstat VDgeom2GetParPtCrv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *par)
{
  VDASSERT_FN("VDgeom2GetParPtCrv");
  
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  IGRdouble  disx = 0.0;
  BSrc       rc;

  // Arg check
  VDASSERTW(par); *par = 0.0;
  VDASSERTW(crv);
  VDASSERTW(pt);

  
  BSmdistptcv(crv,pt,&k,&n,&pars,&disx,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
  if (pars) *par = pars[0];
  
wrapup:
  if (pars)    free(pars);
  if (intpars) free(intpars);
  
  return retFlag;
}
/* ---------------------------------------------------
 * Get the distance from the point to the curve
 */
IGRstat VDgeom2GetDisPtCrv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis)
{
  VDASSERT_FN("VDgeom2GetParPtCrv");
  
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  IGRdouble  disx = 0.0;
  BSrc       rc;

  // Arg check
  VDASSERTW(dis); *dis = 0.0;
  VDASSERTW(crv);
  VDASSERTW(pt);

  
  BSmdistptcv(crv,pt,&k,&n,&pars,&disx,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
  *dis = disx;
  
wrapup:
  if (pars)    free(pars);
  if (intpars) free(intpars);
  
  return retFlag;
}
