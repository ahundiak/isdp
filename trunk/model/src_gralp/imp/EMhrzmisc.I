/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "maptsxfor.h"
#include "mainvmx.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "madef.h"
#include "OMmacros.h"

/*
History

    10 Jul 90   AIC     Creation Date
    03 Oct 90   AIC     Added support for "best hit" display.
    11 Nov 90   AIC     Removed "best hit" display, added edge-based
                        rule lines.
    26 Nov 90   AIC     Support horizon edge display on/off switch.
    01 May 91   Jack    Modified for 2.0.1 Horizon Loops.
    17 Jul 91   AIC     Added support for fence locate.
    08 Aug 91   pp      Commented EMcompare_vectors since this symbol is already
                        defined in GRNUC
    25 Jun 93   Sudha   Modified for BSprototype ansification
    14 Jul 93   WBC     Added the function EMinvmtrxmul.
*/

extern IGRboolean  MAinvmx();


int EMcompare_vectors(v1, v2, result)

IGRvector   v1, v2;
double      *result;

{
  long      rc;
  double    tol;
  double    res;
  IGRvector v;


  BScrossp(&rc, v1, v2, v);

  BSEXTRACTPAR(&rc, BSTOLCOLLINVEC, tol);

  res = BSlenvec(&rc, v);
  if(result) *result = res;
  return ((res <= tol) ? TRUE : FALSE);
};


void EMinv_xform_vector(m, v)

IGRmatrix   m;
IGRvector   v;

{
  IGRlong   value;
  IGRshort  val;
  IGRmatrix invmx;
  IGRpoint  ln[2], new_ln[2];
  BSrc      rc;

  ln[0][0] = ln[0][1] = ln[0][2] = 0.0;
  ln[1][0] = v[0];
  ln[1][1] = v[1];
  ln[1][2] = v[2];
  val = 4;
  MAinvmx(&rc, &val, m, invmx);
  value = 2;
  MAptsxform(&rc, &value, invmx, (IGRdouble *)ln, (IGRdouble *)new_ln);
  v[0] = new_ln[1][0] - new_ln[0][0];
  v[1] = new_ln[1][1] - new_ln[0][1];
  v[2] = new_ln[1][2] - new_ln[0][2];

};


void EMget_view_z(dp_info, z)

struct DP_information   *dp_info;
IGRvector               z;

{
#if VIEW_VECTOR_IS_NOT_NORMALIZED
  long rc;
#endif

  z[0] = dp_info->gragad->rotation[2][0];
  z[1] = dp_info->gragad->rotation[2][1];
  z[2] = dp_info->gragad->rotation[2][2];

#if VIEW_VECTOR_IS_NOT_NORMALIZED
  BSnorvec(&rc, z);
#endif
};


void EMget_boreline_z(boreline, z)

struct IGRline  *boreline;
IGRvector       z;

{
  long rc;

  z[0] = boreline->point2[0] - boreline->point1[0];
  z[1] = boreline->point2[1] - boreline->point1[1];
  z[2] = boreline->point2[2] - boreline->point1[2];

  BSnorvec(&rc, z);
};


void EMget_locate_z(lc, z)

struct GRlc_parms   *lc;
IGRvector           z;

{
  switch(lc->type)
  {
    case GR_bl_loc:
      EMget_boreline_z(&lc->acc_line, z);
      break;

    case GR_rp_loc:
      z[0] = lc->acc_rt_prism.matrix[8];
      z[1] = lc->acc_rt_prism.matrix[9];
      z[2] = lc->acc_rt_prism.matrix[10];
      break;

    case GR_cv_loc:
      z[0] = lc->acc_cv_prism.matrix[8];
      z[1] = lc->acc_cv_prism.matrix[9];
      z[2] = lc->acc_cv_prism.matrix[10];
      break;

    case GR_pt_loc:
    case GR_upd_loc:
    case GR_nam_loc:
    case GR_crit_loc:
      z[0] = 1;
      z[1] = z[2] = 0;
      break;
  }

};


/*
Name

    EMinvmtrxmul

Abstract

        This function multiplies a 4X4 matrix by the inverse of another
    4X4 matrix.

Synopsis

        Type                Name        I/O          Description
 --------------------- ---------------- --- --------------------------------
 IGRlong               *EMmsg            O  Return code.
 IGRmatrix              matrix           I  The 4X4 matrix to be multiplied.
 IGRmatrix              inv_matrix       I  The inverse of this matrix will
                                            be used to multiply matrix.
 IGRmatrix              out_matrix       O  The matrix produced by the
                                            matrix multiplication.
 IGRshort              *out_matrix_type  O  The matrix type of out_matrix.

Description

        This function multiplies a 4X4 matrix by the inverse of another
    4X4 matrix.  As an optiomization, the two input matrices are compare to
    each other and if they are equal, an identity matrix is created and
    returned, which avoids doing a matrix inversion and multiplication.

Keywords

    function

History

    07/14/93 : WBC : Create date.
*/

int EMinvmtrxmul(EMmsg, matrix, inv_matrix, out_matrix,
                 out_matrix_type)

IGRlong   *EMmsg;
IGRmatrix  matrix;
IGRmatrix  inv_matrix;
IGRmatrix  out_matrix;
IGRshort  *out_matrix_type;
{
    extern IGRboolean  MAmulmx();

    IGRmatrix          local_matrix;
    BSrc               rc;
    IGRuint            index;
    IGRboolean         matrices_equal;
    IGRshort           dimension;

    *EMmsg = EMS_S_Success;
    matrices_equal = TRUE;

    for (index = 0; index < 16; index++)
    {
        if (matrix[index] != inv_matrix[index])
        {
            matrices_equal = FALSE;
            break;
        }
    }

    if (matrices_equal)
    {
        MAidmx(&rc, out_matrix);
        *out_matrix_type = MAIDMX;
    }
    else
    {
        dimension = 4;

        if (! MAinvmx(&rc, &dimension, inv_matrix, local_matrix))
        {
            *EMmsg = EMS_E_Fail;
            goto wrapup;
        }

        if (! MAmulmx(&rc, &dimension, &dimension, &dimension,
                      matrix, local_matrix, out_matrix))
        {
            *EMmsg = EMS_E_Fail;
            goto wrapup;
        }

        MAtypemx(&rc, out_matrix, out_matrix_type);
    }

wrapup:

    return((1 & *EMmsg) ? TRUE : FALSE);
}

end implementation EMShorizon;
