/* $Id: VDgeomMat.I,v 1.2 2001/01/11 18:41:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDgeomMat.I
 *
 * Description:	Geometry Matrix Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomMat.I,v $
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/00  ah      Creation, Broke up geom routines
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDobj.h"
#include "VDmem.h"

/* -------------------------------------------------
 * Init matrix to identity
 */
IGRstat VDgeomSetMatToIdentity(TGRmdenv_info *mat)
{
  IGRlong msg;

  MAidmx(&msg,mat->matrix);
  mat->matrix_type = MAIDMX;
  
  return 1;
}

/* -------------------------------------------------
 * Init matrix to identity
 */
IGRstat VDgeomSetMatToIdentity2(IGRshort *matrix_type, IGRmatrix matrix)
{
  IGRlong msg;

  if (matrix) MAidmx(&msg,matrix);
  if (matrix_type) *matrix_type = MAIDMX;
  
  return 1;
}
/* -------------------------------------------------
 * Set Matrix type
 */
IGRstat VDgeomSetMatType(IGRmatrix matrix, IGRshort *matrix_type)
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
IGRstat VDgeomMultMat(TGRmdenv_info *mat1, 
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


end implementation Root;









