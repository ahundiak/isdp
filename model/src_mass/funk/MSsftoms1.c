/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MSsftoms(trans_vect, scaling_factor, sf_int, glo_prop);

Given translation vector, scaling factor and surface integrals, 
this function derives mass properties at the centroid of mass.

IGRdouble	trans_vect[3];	The point with respect to which
				the integrals are computed

IGRdouble	scaling_factor;	scaling factor if the data was 'shrunk'

IGRdouble	sf_int[12];	surface integrals evaluated on 'shrunk'
				data at the point trans_vect

IGRdouble	glo_prop[12];	mass properties

History:
	gk	5/10/87		creation date

Note:
	This is connected closely with MSsfint1.c and the implementations
	for various special (EMspsurfint.I EMcysurfint.I).
	MSsfint1.c uses Simpson rule for integrating. Hence the factor
	of division is associated with that.
*/

# include <stdio.h>
# include "igrtypedef.h"
# include "igr.h"
# include "emsmass.h"


void MSsftoms(trans_vector, scaling_factor, sf_int, glo_prop)

IGRdouble	trans_vector[];
IGRdouble	scaling_factor;
IGRdouble	sf_int[];
IGRdouble	glo_prop[];
{
   IGRdouble		scaling_2, scaling_3, scaling_4, scaling_5;
   IGRdouble		x, y, z, x_sq, y_sq, z_sq;	/* all deltas */
  extern    IGRdouble		sqrt();
   IGRlong		i;


  scaling_2 = scaling_factor * scaling_factor;
  scaling_3 = scaling_2 * scaling_factor;
  scaling_4 = scaling_3 * scaling_factor;
  scaling_5 = scaling_4 * scaling_factor;

/* 9/28/87 - Now divide all sf_ints by 9 (2d Simpson integration)
   and constants divider of integrals
   Divide by 4.0 if Gaussian quadrature is used
*/

  for(i = 0; i < 12; i++) sf_int[i] /= INTEGRATION_FACTOR;

  sf_int[0] /= 3.0;
  sf_int[1] /= 3.0;
  sf_int[2] /= 2.0;
  sf_int[3] /= 2.0;
  sf_int[4] /= 2.0;
  sf_int[5] /= 3.0;
  sf_int[6] /= 3.0;
  sf_int[7] /= 3.0;


/* All other integrals have dividing factors of 1.0 */


/*
  Compute centroid and translate sf_int to the centroid
*/
    x = scaling_factor * sf_int[2]/sf_int[1];
    y = scaling_factor * sf_int[3]/sf_int[1];
    z = scaling_factor * sf_int[4]/sf_int[1];

    x_sq = x * x;
    y_sq = y * y;
    z_sq = z * z;

    glo_prop[0] = sf_int[0] * scaling_3;	/* Volume */
    glo_prop[1] = sf_int[1] * scaling_3;	/* Mass */

    glo_prop[2] = x;  /* Xc */
    glo_prop[3] = y;  /* Yc */
    glo_prop[4] = z;  /* Zc */

    glo_prop[5] = (sf_int[6] + sf_int[7]) * scaling_5	/* Mxx */
		     - glo_prop[1] * ( y_sq + z_sq );

    glo_prop[6] = (sf_int[7] + sf_int[5]) * scaling_5	/* Myy */
		     - glo_prop[1] * ( z_sq + x_sq );

    glo_prop[7] = (sf_int[5] + sf_int[6]) * scaling_5	/* Mzz */
		     - glo_prop[1] * ( x_sq + y_sq );

    glo_prop[8] = sf_int[8] * scaling_5			/* Mxy */
		    - glo_prop[1] * ( x * y );

    glo_prop[9] = sf_int[9] * scaling_5			/* Myz */
		    - glo_prop[1] * ( y * z );

    glo_prop[10] = sf_int[10] * scaling_5			/* Mzx */
		    - glo_prop[1] * ( x * z );

    glo_prop[11] = sf_int[11] * scaling_2;	/* Surface area */

    glo_prop[2] += trans_vector[0];	/* True centroid */
    glo_prop[3] += trans_vector[1];	/* True centroid */
    glo_prop[4] += trans_vector[2];	/* True centroid */

 return;

}
