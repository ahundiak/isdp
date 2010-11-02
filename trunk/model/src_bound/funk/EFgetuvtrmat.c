/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
Notes

This function computes a matrix [4,4], to
map a given (u,v) space to a new (u,v) 
space. It is assumed that both of these spaces
belong to the same surface or one (u,v) space's surface 
is a part of the other space's surface.

Arguments
   rc -- output - function return code
	
   org_range -- input - original (u,v) space
	range. It is an array of 4 doubles. The
	sequence of the values stored are,
	umin, vmin, umax and vmax.

   new_range -- input - new (u,v) space range.
      	The sequence of the values stored are,
	umin, vmin, umax and vmax.

   trans_mat -- output - transformation matrix.
	The space should be allocated by the caller.
History
	RC	04/31/87	Creation date
	RC	08/31/87	Modified to return 4*4 matrix
*/

typedef double IGRdouble;

short  EFget_uv_trans_mat (rc,
                           org_range,
                           new_range,
                           trans_mat)

  long        *rc;
  IGRdouble    org_range[4];
  IGRdouble    new_range[4];
  IGRdouble    trans_mat[16];

{
  int	i;

  *rc = 1;

  for (i = 0; i < 16; i++)
	trans_mat[i] = 0;

  trans_mat[10] = trans_mat[15] = 1.;

  /* 
   * calculate scale factors
   */

  trans_mat[0] = (new_range[2] - new_range[0]) / 
                      (org_range[2] - org_range[0]);

  trans_mat[5] = (new_range[3] - new_range[1]) /
                             (org_range[3] - org_range[1]);

  /*
   * calculate translation factors
   */

  trans_mat[3] = new_range[0] - org_range[0] * trans_mat[0];
  trans_mat[7] = new_range[1] - org_range[1] *trans_mat[5];

  return (1);

}
