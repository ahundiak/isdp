/* $Id: VDgeom2Mat.c,v 1.1 2001/04/12 14:38:22 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom2/VDgeom2Mat.c
 *
 * Description:	Geometry Matrix Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeom2Mat.c,v $
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
#include "VDlog.h"
#include "VDgeomc.h"

VDASSERT_FFN("VDgeom2Mat.c");

/* -------------------------------------------------
 * Init matrix to identity
 */
IGRstat VDgeom2SetMatrixToIdentity(TGRmdenv_info *mat)
{
  IGRlong msg;

  MAidmx(&msg,mat->matrix);
  mat->matrix_type = MAIDMX;
  
  return 1;
}

/* -------------------------------------------------
 * Init matrix to identity
 */
IGRstat VDgeom2SetMatrixTypeToIdentity(IGRshort *matrix_type, IGRmatrix matrix)
{
  IGRlong msg;

  if (matrix) MAidmx(&msg,matrix);
  if (matrix_type) *matrix_type = MAIDMX;
  
  return 1;
}

/* -------------------------------------------------
 * Set Matrix type
 */
IGRstat VDgeom2SetMatrixType(IGRmatrix matrix, IGRshort *matrix_type)
{
  BSrc rc;
  
  if (matrix_type == NULL) return 0;
  *matrix_type = 0;
  if (matrix == NULL) return 0;

  MAtypemx(&rc,matrix,matrix_type);

  return 1;
}

/* -------------------------------------------------
 * Mat1 by mat2 into mat3
 * If mat3 is null, store in mat1
 */
IGRstat VDgeom2MultMat(TGRmdenv_info *mat1, 
		       TGRmdenv_info *mat2, 
		       TGRmdenv_info *mat3)
{
  BSrc rc;
  TGRmdenv_info matx;

  // Adjust output
  if (mat3 == NULL) mat3 = &matx;
  
  /* Check ident */
  if (mat2->matrix_type == MAIDMX) {
    *mat3 = *mat1;
    goto wrapup;
  }

  /* Do It */
  BSmult_mats(
    4,4,mat1->matrix,0,
    4,4,mat2->matrix,0,
    mat3->matrix,
   &rc);

  MAtypemx(&rc,mat3->matrix,&mat3->matrix_type);

wrapup:
  if (mat3 == &matx) {
    *mat1 = matx;
  }
  
  return 1;
}










