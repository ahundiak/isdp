/*
  HISTORY
	Sudha	07/02/93	Modified for BSprototype ansification
*/

#include "igrtypedef.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "mamulmx.h"
#include "maidmx.h"
#include "bserr.h"
#include "bscrossp.h"
#include "bslocalcord.h"
#include "bsinvtmat.h"

void SKgetmat (msg, origin, zvec, xvec, mattyp, mat)
IGRlong *msg;
IGRdouble *origin;
IGRdouble *zvec, *xvec;
IGRshort *mattyp;
IGRmatrix mat;
{
  IGRshort  four = 4;
  IGRint    inx;
  IGRlong   msg_loc;
  IGRvector yvec;
  IGRmatrix tmat, rmat;

  *msg = EMS_S_Success;

  /*
   * Obtain the translation matrix
   */

  if (origin)
  {
    MAidmx (&msg_loc, tmat);
    MAtrlmx (&msg_loc, origin, tmat);
    tmat[3] = -tmat[3];
    tmat[7] = -tmat[7];
    tmat[11] = -tmat[11];
  }
  else
    MAidmx (&msg_loc, tmat);

  /*
   * Obtain the rotation matrix
   */

  if (zvec && xvec)
  {
    BScrossp (&msg_loc, zvec, xvec, yvec);
    for (inx=0; inx<3; inx++)
    {
      rmat[inx] = xvec[inx];
      rmat[4+inx] = yvec[inx];
      rmat[8+inx] = zvec[inx];
    }
    rmat[3] = rmat[7] = rmat[11] = 0.0;
    rmat[12] = rmat[13] = rmat[14] = 0.0;
    rmat[15] = 1.0;
  }
  else
    MAidmx (&msg_loc, rmat);

  /*
   * Multiply the two matrices and obtain the type of the matrix if
   * asked for.
   */

  MAmulmx (&msg_loc, &four, &four, &four, rmat, tmat, mat);
  if (mattyp)
    MAtypemx (&msg_loc, mat, mattyp);
  return;
}

/*

Name
  SKgetmatrix

Abstract
  Find the transformation matrix for a coordinate system.
  
Synopsis

Description

Return Value

Notes

Index

Keywords

History
  11/29/93 : Rajiv Agrawal : created

 */
void SKgetmatrix (long *msg, IGRpoint origin, IGRvector zvec, IGRvector xvec, 
                  IGRmatrix hmat, IGRmatrix hmat_t)
{
  IGRboolean 	right_hand = TRUE;
  int 		i;
  long 		msg_loc;
  double 	rot_mat[3][3], scale = 1.0;
  IGRpoint 	p1, p2;
  IGRvector 	yvec;
  
  *msg = EMS_S_Success;

  BScrossp (&msg_loc, zvec, xvec, yvec);  
  for (i=0;i<=2;i++) 
  {
    p1[i] = origin[i] + xvec[i];
    p2[i] = origin[i] + yvec[i];
  }
  BSlocalcord(&msg_loc, origin, p1, p2, &right_hand, rot_mat);
  BSinvtmat( 0, origin, (double *) rot_mat, &scale, hmat, hmat_t, &msg_loc );
}
