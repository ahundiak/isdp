/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MScnvtprop(in_prop, in_org, in_glo_loc,
		dest_prop, dest_org, dest_glo_loc)

Given mass properties in a system this function returns mass properties
in new system

IGRdouble	in_prop[];	mass properties
IGRdouble	in_org[3];	origin for the incoming mass properties
IGRdouble	in_glo_loc[9];	incoming orientation  (glo-loc)
IGRdouble	dest_prop[];	out going mass properties
IGRdouble	dest__org[3];	origin for the out going mass properties
IGRdouble	dest_glo_loc[9];	out going orientation  (glo-loc)

Note:
1.	mass properties are passed in/out as follows:
	
	0	volume
	1	mass
	2,3,4	centroid
	5	moment about x axis
	6	moment about y axis
	7	moment about z axis
	8	product moment xy
	9	product moment yz
	10	product moment zx
	11	surface area
        16,17,18 Centroid of Volume

2.	The volume, mass, centroid and surface area are not
	altered by this transformation

History:
	gk	10/26/87		creation date
*/

# include <stdio.h>
# include "igrtypedef.h"
# include "EMSlogic.h"
# include "bsparameters.h"
# include "bserr.h"

void MScnvtprop(in_prop, in_org, in_glo_loc,
		dest_prop, dest_org, dest_glo_loc)

IGRdouble	*in_prop, *in_org, *in_glo_loc,
		*dest_prop, *dest_org, *dest_glo_loc;
{
  static IGRdouble	identity_matrix[9] =
			{1.0,  0.0,  0.0,
			 0.0,  1.0,  0.0,
			 0.0,  0.0,  1.0
			};

  IGRdouble		prop_matrix[3][3], temp_prop_matrix[9], prop[20],
			temp_orient_matrix[9], dx, dy, dz,
			length_tol, matrix_tol;

  IGRlong		i;

  BSrc			bsmsg;

  IGRboolean		rotate_em, translate_em;

  void			MSmat_transpose(), MSmat_mult();


  BSEXTRACTPAR(&bsmsg, BSTOLBASIS, length_tol);
  BSEXTRACTPAR(&bsmsg, BSTOLCLOSETOZERO, matrix_tol);

  for(i = 0; i < 20; i++)prop[i] = in_prop[i];

/* Rotate the properties to global system */

  rotate_em = FALSE;
  i = 0;
  while( (NOT rotate_em) AND (i<9) )
  {
    dx = in_glo_loc[i] - identity_matrix[i];
    dy = (dx < 0.0) ? (-dx) : (dx);
    if(dy >= matrix_tol) rotate_em = TRUE;
    i++;
  }

  if(rotate_em)
  {
    prop_matrix[0][0] =  prop[5];	/* mxx */
    prop_matrix[0][1] = -prop[8];	/* mxy */
    prop_matrix[0][2] = -prop[10];	/* mzx */

    prop_matrix[1][0] = -prop[8];	/* mxy */
    prop_matrix[1][1] =  prop[6];	/* myy */
    prop_matrix[1][2] = -prop[9];	/* myz */

    prop_matrix[2][0] = -prop[10];	/* mzx */
    prop_matrix[2][1] = -prop[9];	/* myz */
    prop_matrix[2][2] =  prop[7];	/* mzz */

    MSmat_transpose(in_glo_loc, temp_orient_matrix);
    MSmat_mult(temp_orient_matrix, prop_matrix, temp_prop_matrix);
    MSmat_mult(temp_prop_matrix, in_glo_loc, prop_matrix);
	
    prop[5]  = prop_matrix[0][0];
    prop[6]  = prop_matrix[1][1];
    prop[7]  = prop_matrix[2][2];
    prop[8]  = -prop_matrix[0][1];
    prop[9]  = -prop_matrix[1][2];
    prop[10] = -prop_matrix[0][2];
  }

/* Translate properties to centroid */

  translate_em = FALSE;
  i = 0;
  while( (NOT translate_em) AND (i<3) )
  {
    dx = prop[2+i] - in_org[i];
    dy = (dx < 0.0) ? (-dx) : (dx);
    if(dy >= length_tol) translate_em = TRUE;
    i++;
  }

  if(translate_em)
  {
    dx = prop[2] - in_org[0];
    dy = prop[3] - in_org[1];
    dz = prop[4] - in_org[2];

    prop[5] -= prop[1] * ( dy * dy + dz * dz );
    prop[6] -= prop[1] * ( dz * dz + dx * dx );
    prop[7] -= prop[1] * ( dx * dx + dy * dy );

    prop[8]  -= prop[1] * ( dx * dy );
    prop[9]  -= prop[1] * ( dy * dz );
    prop[10] -= prop[1] * ( dz * dx );
  }   

/* Translate properties to required reference point */

  translate_em = FALSE;
  i = 0;
  while( (NOT translate_em) AND (i<3) )
  {
    dx = prop[2+i] - dest_org[i];
    dy = (dx < 0.0) ? (-dx) : (dx);
    if(dy >= length_tol) translate_em = TRUE;
    i++;
  }

  if(translate_em)
  {
    dx = prop[2] - dest_org[0];
    dy = prop[3] - dest_org[1];
    dz = prop[4] - dest_org[2];

    prop[5] += prop[1] * ( dy * dy + dz * dz );
    prop[6] += prop[1] * ( dz * dz + dx * dx );
    prop[7] += prop[1] * ( dx * dx + dy * dy );

    prop[8]  += prop[1] * ( dx * dy );
    prop[9]  += prop[1] * ( dy * dz );
    prop[10] += prop[1] * ( dz * dx );
  }   

/* Rotate the properties to the required orientation */

  rotate_em = FALSE;
  i = 0;
  while( (NOT rotate_em) AND (i<9) )
  {
    dx = dest_glo_loc[i] - identity_matrix[i];
    dy = (dx < 0.0) ? (-dx) : (dx);
    if(dy >= matrix_tol) rotate_em = TRUE;
    i++;
  }

  if(rotate_em)
  {
    prop_matrix[0][0] =  prop[5];	/* mxx */
    prop_matrix[0][1] = -prop[8];	/* mxy */
    prop_matrix[0][2] = -prop[10];	/* mzx */

    prop_matrix[1][0] = -prop[8];	/* mxy */
    prop_matrix[1][1] =  prop[6];	/* myy */
    prop_matrix[1][2] = -prop[9];	/* myz */

    prop_matrix[2][0] = -prop[10];	/* mzx */
    prop_matrix[2][1] = -prop[9];	/* myz */
    prop_matrix[2][2] =  prop[7];	/* mzz */

    MSmat_transpose(dest_glo_loc, temp_orient_matrix);
    MSmat_mult(dest_glo_loc, prop_matrix, temp_prop_matrix);
    MSmat_mult(temp_prop_matrix, temp_orient_matrix, prop_matrix);

    prop[5]  = prop_matrix[0][0];
    prop[6]  = prop_matrix[1][1];
    prop[7]  = prop_matrix[2][2];
    prop[8]  = -prop_matrix[0][1];
    prop[9]  = -prop_matrix[1][2];
    prop[10] = -prop_matrix[0][2];
  }

 if (in_prop[19] == 0.01234)
 {
  prop[16] = in_prop[16];
  prop[17] = in_prop[17];
  prop[18] = in_prop[18];
  prop[19] = 0.01234;
 }

 for( i = 0; i < 20; i++ )dest_prop[i] = prop[i];

 return;

}
