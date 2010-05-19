/* $Id: VDgeomTran.I,v 1.1 2001/01/11 18:41:19 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomTran.I
 *
 * Description: For Space Transformation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomTran.I,v $
 *      Revision 1.1  2001/01/11 18:41:19  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  17:06:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/07/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDassert.h"

VDASSERT_FFN("vdgeom/VDgeomTran.I");

/* -----------------------------------------------
 * Transform a point using the supplied origins and
 * matrix, probably a better way to make a 4x4 matrix but
 * hey it works and lends itself to trouble shooting
 */
IGRstat VDgeomTransformPt(IGRpoint      origin1, 
			  IGRpoint      origin2, 
			  TVDgeomMat3x3 mat,
			  IGRpoint      pt1,
			  IGRpoint      pt2)
{
  VDASSERT_FN("VDgeomTransformPt");
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

/* -----------------------------------------------
 * Given three points in one space and three pts
 * In another, return a translation matrix
 *
 * Up to the calling code to track the center points
 * for when the matrix is applied
 */
IGRstat VDgeomGetTranForPts(IGRpoint center1,
			    IGRpoint minor1,
			    IGRpoint major1,
			    IGRpoint center2,
			    IGRpoint minor2,
			    IGRpoint major2,
			    TVDgeomMat3x3 mat)
{
  VDASSERT_FN("VDgeomGetTranForPts");
  IGRstat retFlag = 0;
  IGRstat sts;

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
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }
      
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
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Must be an easier way to copy stupid points
 */
IGRstat VDgeomCpyPt(IGRpoint pt1, IGRpoint pt2)
{
  IGRint i;
  for(i = 0; i < 3; i++) {
    pt2[i] = pt1[i];
  }
  return 1;
}

end implementation Root;

