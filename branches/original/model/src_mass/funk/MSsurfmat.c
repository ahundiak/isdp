/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

/*
  HISTORY

	Sudha	06/28/93	Modified for BSprototype ansification

*/

void MSsurfmat(z_axis, glo_loc_mat)

IGRdouble		*z_axis;
IGRdouble		glo_loc_mat[3][3];

{
  IGRboolean	log_status;
  IGRdouble	scratch, x_axis[3], y_axis[3],
		abs_dot_x, abs_dot_y;
  IGRlong	i, bsmsg;
  static IGRdouble zero_vect[3]={0.0, 0.0, 0.0};

/* Determine a vector not aligned with z_axis */

/* Try vector {1, 0, 0}, then {0, 1, 0} */

    abs_dot_x = (z_axis[0] < 0.0) ? (-z_axis[0]) : (z_axis[0]);
    abs_dot_y = (z_axis[1] < 0.0) ? (-z_axis[1]) : (z_axis[1]);

/*  Choose the vector with minimum dot product.This has maximum offset */

   if(abs_dot_x <= abs_dot_y)
    {
      y_axis[0] = 1.0;
      y_axis[1] = 0.0;
      y_axis[2] = 0.0;
    }
   else
    {
      y_axis[0] = 0.0;
      y_axis[1] = 1.0;
      y_axis[2] = 0.0;
    }

/* Using y_axis and z_axis generate true x axis */

  scratch = BSdistptpt(&bsmsg, z_axis, zero_vect);
  z_axis[0] /= scratch;
  z_axis[1] /= scratch;
  z_axis[2] /= scratch;

  log_status = BScrossp(&bsmsg, y_axis, z_axis, x_axis);
  scratch = BSdistptpt(&bsmsg, x_axis, zero_vect);
  x_axis[0] /= scratch;
  x_axis[1] /= scratch;
  x_axis[2] /= scratch;
	
  log_status = BScrossp(&bsmsg, z_axis, x_axis, y_axis);

  for(i = 0; i < 3; i ++)
   {
	glo_loc_mat[0][i] = x_axis[i];
	glo_loc_mat[1][i] = y_axis[i];
	glo_loc_mat[2][i] = z_axis[i];
   }

  return;
}
