/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MSreduce(numb_pnts, pnts_in, pnts_out, tol)

Given an array of points, this functions "knocks off" interior points
in a linear section; thus reducing the number of points in the array.


Caution: Works for only 2D points

IGRlong		*numb_pnts;	number of points in the array
				also contains the reduced number of points

IGRdouble	*pnts_in;	array containing the "raw" points
		*pnts_out;	array containing the "reduced" number
				of points.
				pnts_out can be same as pnts_in

		tol;		tolerance
History:
	gk	03/08/88	creation date
*/

# include "igrtypedef.h"

void MSreduce(numb_pnts, pnts_in, pnts_out, tol)

IGRlong		*numb_pnts;
IGRdouble	*pnts_in, *pnts_out, tol;

{
  IGRlong	ind1, ind2, ind4, end_of_array;
  IGRdouble	dist, area, tol_sq, ref[3], test[3];



  ind1 = 0;
  ind2 = 0;

/* First point is unaltered */

  pnts_out[0] = pnts_in[0];
  pnts_out[1] = pnts_in[1];

  tol_sq = tol * tol;
  end_of_array = 2 * (*numb_pnts);

  do
   {
     ind2 += 2;

     ref[0] = pnts_in[ind2]     - pnts_in[0];
     ref[1] = pnts_in[ind2 + 1] - pnts_in[1];

     dist = ref[0]*ref[0] + ref[1]*ref[1];

   }while( (dist < tol_sq) || (ind2 < end_of_array) );

  if(dist < tol_sq)
   {
     *numb_pnts = 1;	/* only one valid point */
     return;
   }

/* We now have non-degenerate vector pnt_in[ind1] to pnt_in[ind2] */

  ind4 = 2;
  end_of_array -= 2;

  for( ; ind2 < end_of_array; ind2 += 2)
   {
     test[0] = pnts_in[ind2 + 2] - pnts_in[ind1];
     test[1] = pnts_in[ind2 + 3] - pnts_in[ind1 + 1];

/*   Establish if vectors test and ref are collinear */

     area = ref[0]*test[1] - ref[1]*test[0];

     dist = (area < 0.0) ? ( - area ) : ( area );

     if(dist >= tol_sq)		/* points are not collinear */
      {
	pnts_out[ind4]     = pnts_in[ind2];
	pnts_out[ind4 + 1] = pnts_in[ind2 + 1];

	ind4 += 2;
	ind1  = ind2;

	ref[0] = pnts_in[ind2 + 2] - pnts_in[ind2];
	ref[1] = pnts_in[ind2 + 3] - pnts_in[ind2 + 1];
      }
   }

  pnts_out[ind4]     = pnts_in[ind2];
  pnts_out[ind4 + 1] = pnts_in[ind2 + 1];

  *numb_pnts = (ind4 + 3)/2;
  return;
}
