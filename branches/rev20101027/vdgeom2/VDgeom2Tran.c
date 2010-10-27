/* $Id: VDgeom2Tran.c,v 1.4 2001/06/22 15:14:52 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom2/VDgeom2Tran.c
 *
 * Description:	Geometry Transformation Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeom2Tran.c,v $
 *      Revision 1.4  2001/06/22 15:14:52  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/06/08 20:50:23  ahundiak
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
 * 04/12/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"
#include "VDgeomc.h"

VDASSERT_FFN("VDgeom2Tran.c");

/* -----------------------------------------------
 * Calc a transformation matrix
 * Don't remember where this code came from but it works
 */
IGRstat VDgeom2GetTranForPts(IGRpoint center1, IGRpoint minor1, IGRpoint major1,
			     IGRpoint center2, IGRpoint minor2, IGRpoint major2,
			     TVDgeomMat3x3 mat)
{
  VDASSERT_FN("VDgeomGetTranForPts");
  IGRstat retFlag = 0;
  
  IGRvector vec1,vec2,vec3;
  
  TVDgeomMat3x3 mat1,inv1,mat2;

  IGRpoint  tvec;
  
  IGRpoint center1x,minor1x,major1x;
  IGRdouble dis;
  IGRdouble *matx;
  
  IGRint i,j;
  BSrc   rc;

  // Arg check
  VDASSERTW(mat);
  memset(mat,0,sizeof(TVDgeomMat3x3));
  
  // Say hi
  traceFlag = 0;
  if (traceFlag) printf(">>> %s\n",fn);
      
  // First set of vectors
  BSmkvec(&rc,vec1,center1,minor1);
  BSmkvec(&rc,vec2,center1,major1);

  MAunitvc(&rc,vec1,vec1);
  MAunitvc(&rc,vec2,vec2);

  BScrossp(&rc,vec1,vec2,vec3);
  MAunitvc(&rc,vec3,vec3);

  for(i = 0; i < 3; i++) {
    mat1[0][i] = vec1[i];
    mat1[1][i] = vec2[i];
    mat1[2][i] = vec3[i];
  }
  
  // Make the inverse
  BSinv_mat(3, (IGRdouble*)mat1, (IGRdouble*)inv1, &rc);
  
  if (traceFlag) {  
    for(i = 0; i < 3; i++) {
      printf("mat1 %d %8.4f %8.4f %8.4f\n",i,
	     mat1[i][0],mat1[i][1],mat1[i][2]);
    }
  }
  
  // Second set of vectors
  BSmkvec(&rc,vec1,center2,minor2);
  BSmkvec(&rc,vec2,center2,major2);

  MAunitvc(&rc,vec1,vec1);
  MAunitvc(&rc,vec2,vec2);

  BScrossp(&rc,vec1,vec2,vec3);
  MAunitvc(&rc,vec3,vec3);

  for(i = 0; i < 3; i++) {
    mat2[0][i] = vec1[i];
    mat2[1][i] = vec2[i];
    mat2[2][i] = vec3[i];
  }

  if (traceFlag) {  
    for(i = 0; i < 3; i++) {
      printf("mat2 %d %8.4f %8.4f %8.4f\n",i,
	     mat2[i][0],mat2[i][1],mat2[i][2]);
    }
  }
  
  // Now multiple to get the single translation
  BSmult_mats(3,3,(IGRdouble*)inv1,0,
	      3,3,(IGRdouble*)mat2,0,
	      (IGRdouble*)mat,&rc);

  if (traceFlag | 0) {
    for(i = 0; i < 3; i++) {
      printf("matX %d %8.4f %8.4f %8.4f\n",i,
	     mat[i][0],mat[i][1],mat[i][2]);
    }
  }
    
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}
/* -----------------------------------------------
 * Given two sets of points, create a 4x4 transformation
 * matrix, not sure if this can even be done but at least
 * have the results to check against
 *
 * Did some trial and error, it seems to work ok
 * Not very pretty but oh well
 */
IGRstat VDgeom2GenMatrix(IGRdouble *pt1s, IGRdouble *pt2s, IGRshort *type, IGRdouble *mat4x4)
{
  VDASSERT_FN("VDgeom2GenMatrix");
  
  IGRstat retFlag = 0;
  IGRstat msg;
  BSrc    rc;
  
  TVDgeomMat3x3 mat3x3;

  IGRint i,j,k;
  
  IGRdouble mat1[16];
  IGRdouble mat2[16];
  
  // Arg check
  VDASSERTW(mat4x4);
  VDASSERTW(pt1s);
  VDASSERTW(pt2s);
  
  // Already worked this part out
  VDgeom2GetTranForPts(&pt1s[0],&pt1s[3],&pt1s[6],
		       &pt2s[0],&pt2s[3],&pt2s[6],
		       mat3x3);
  
  mat4x4[ 0] = mat3x3[0][0];
  mat4x4[ 1] = mat3x3[1][0];
  mat4x4[ 2] = mat3x3[2][0];
  mat4x4[ 3] = 0.0;
  mat4x4[ 4] = mat3x3[0][1];
  mat4x4[ 5] = mat3x3[1][1];
  mat4x4[ 6] = mat3x3[2][1];
  mat4x4[ 7] = 0.0;
  mat4x4[ 8] = mat3x3[0][2];
  mat4x4[ 9] = mat3x3[1][2];
  mat4x4[10] = mat3x3[2][2];
  mat4x4[11] = 0.0;
  mat4x4[12] = 0.0;
  mat4x4[13] = 0.0;
  mat4x4[14] = 0.0;
  mat4x4[15] = 1.0;

  // Somehow need to apply the vectors
  for(i = 0; i < 16; i++) mat1[i] = 0.0;
  mat1[ 0] = 1.0;
  mat1[ 5] = 1.0;
  mat1[10] = 1.0;
  mat1[15] = 1.0;
  mat1[ 3] = pt1s[0] * -1.0;
  mat1[ 7] = pt1s[1] * -1.0;
  mat1[11] = pt1s[2] * -1.0;
  
  BSmult_mats(4,4,(IGRdouble*)mat4x4,0,
	      4,4,(IGRdouble*)mat1,0,
	          (IGRdouble*)mat2,&rc);
  
  for(i = 0; i < 16; i++) mat4x4[i] = mat2[i];

  mat1[ 3] = pt2s[0];
  mat1[ 7] = pt2s[1];
  mat1[11] = pt2s[2];

  BSmult_mats(4,4,(IGRdouble*)mat1,0,
	      4,4,(IGRdouble*)mat4x4,0,
	          (IGRdouble*)mat2,&rc);

  for(i = 0; i < 16; i++) mat4x4[i] = mat2[i];

  /* ---------------------------------------------
   * Real hack here, if the input point are really screwed up
   * you can get totally bad results causing core dumps.
   * So put some code to protext against it.
   */
  for(i = 0; i < 3; i++) {
    for(j = 0; j < 3; j++) {
      k = (i*4) + j;
      if (mat4x4[k] >  2.0) mat4x4[k] =  2.0;
      if (mat4x4[k] < -2.0) mat4x4[k] = -2.0;
    }
  }
  for(i = 0; i < 3; i++) {
    k = (i*4) + 3;
    if (mat4x4[k] >  4000000.0) mat4x4[k] =   4000000.0;
    if (mat4x4[k] < -4000000.0) mat4x4[k] =  -4000000.0;
  }
  
  // Optional type
  if (type) MAtypemx(&msg,mat4x4,type);
  
  // Done
  retFlag = 1;

#if 0
  // Debug
  for(i = 0; i < 4; i++) {
    printf("mat %d ",i);
    for(j = 0; j < 4; j++) {
      printf("%10.2f ",mat4x4[(i*4)+j]);
    }
    printf("\n");
  }
#endif

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Transform a point using the supplied origins and
 * matrix, probably a better way to make a 4x4 matrix but
 * hey it works and lends itself to trouble shooting
 */
IGRstat VDgeom2TransformPt(IGRpoint      origin1, 
			   IGRpoint      origin2, 
			   TVDgeomMat3x3 mat,
			   IGRpoint      pt1,
			   IGRpoint      pt2)
{
  VDASSERT_FN("VDgeom2TransformPt");
  IGRstat  retFlag = 0;
  IGRint   i,j;
  IGRpoint pt,ptx;
  
  // Shift from origin1
  for(i = 0; i < 3; i++) {
    pt[i] = pt1[i] - origin1[i];
  }

  // Apply the matrix
  for(i = 0; i < 3; i++) {
    ptx[i] = 
      (pt[0] * mat[0][i]) +
      (pt[1] * mat[1][i]) +
      (pt[2] * mat[2][i]);
  }

  // Apply origin2
  for(i = 0; i < 3; i++) {
    pt[i] = ptx[i] + origin2[i];
  }
  
  // Output it
  for(i = 0; i < 3; i++) {
    pt2[i] = pt[i];
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Get the distance between points
 */
IGRstat VDgeom2GetDisPtPt(IGRpoint pt1, IGRpoint pt2, IGRdouble *dis)
{
  VDASSERT_FN("VDgeom2GetDisPtPt");
  
  IGRstat retFlag = 0;
  
  BSrc       rc;

  // Do It
  VDASSERTW(dis); *dis = 0.0;
  VDASSERTW(pt1);
  VDASSERTW(pt2);
  *dis = BSdistptpt(&rc,pt1,pt2);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance from point to a curve
 */
IGRstat VDgeom2GetDisPtCv(IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis)
{
  VDASSERT_FN("VDgeom2GetDisPtCv");
  IGRstat retFlag = 0;
  
  IGRshort   k,n;
  IGRdouble *pars    = NULL;
  IGRdouble *intpars = NULL;
  BSrc       rc;

  // Arg check
  VDASSERTW(dis); *dis = 0.0;
  VDASSERTW(pt);
  VDASSERTW(crv);
  
  BSmdistptcv(crv,pt,&k,&n,&pars,dis,&intpars,&rc);
  if (rc == BSSUCC) retFlag = 1;
  
wrapup:
  if (pars)    free(pars);
  if (intpars) free(intpars);
  
  return retFlag;
}

/* ---------------------------------------------------
 * Get the min distance between two curves
 */
IGRstat VDgeom2GetDisCvCv(TGRbsp_curve *crv1, TGRbsp_curve *crv2, IGRdouble *dis)
{
  VDASSERT_FN("VDgeom2GetDisCvCv");
  IGRstat retFlag = 0;
  
  IGRint num = 0;
  IGRdouble *par1  = NULL;
  IGRdouble *par2  = NULL;

  IGRpoint  *pt1 = NULL;
  IGRpoint  *pt2 = NULL;
  
  BSrc       rc;

  // Arg check
  VDASSERTW(dis); *dis = 0.0;
  VDASSERTW(crv1);
  VDASSERTW(crv2);
  
  BSmdistcvcv(crv1,crv2,&num,&par1,&par2,&pt1,&pt2,dis,&rc);
  if (rc == BSSUCC) retFlag = 1;
   
wrapup:
  if (par1) free(par1);
  if (par2) free(par2);
  if (pt1)  free(pt1);
  if (pt2)  free(pt2);
  
  return retFlag;
}

