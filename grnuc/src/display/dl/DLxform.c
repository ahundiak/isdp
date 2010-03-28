#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIreport_errors;

/*--- DLIxform3D ---------------------------------------------------*/

int DLIxform3D(
   double *bufin,
   double *bufout,
   int numpnts,
   double matrix[16],
   int matmap[4] )

/*
NAME
	DLIxform3D

DESCRIPTION
	This function transforms an array of points using an
	ortho pipe matrix.

SYNOPSIS
	int DLIxform3D(
	   double *bufin,
	   double *bufout,
	   int numpnts,
	   double matrix[16],
	   int matmap[4] )

PARAMETERS
	bufin (IN) - the array of points to transform (xyz, xyz, etc )
	bufout (OUT) - the transformed array of points
	numpnts (IN) - the number of points to transform
	matrix (IN) - the matrix to use for the transformation
	matmap (IN) - results from matrix characterization to optimize
                      the transformation

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/18/92    S.P. Rogers
	   Documented
*/

{
   double x, y, z;

   for ( ; numpnts--; bufin += 3, bufout += 3 )
   {
      x = bufin[0];
      y = bufin[1];
      z = bufin[2];

      switch ( matmap[0] )
      {
         case 1:
            bufout[0] = matrix[12];
            break;
         case 2:
            bufout[0] = z * matrix[8];
            break;
         case 3:
            bufout[0] = z * matrix[8] + matrix[12];
            break;
         case 4:
            bufout[0] = y * matrix[4];
            break;
         case 5:
            bufout[0] = y * matrix[4] + matrix[12];
            break;
         case 6:
            bufout[0] = y * matrix[4] + z * matrix[8];
            break;
         case 7:
            bufout[0] = y * matrix[4] + z * matrix[8] + matrix[12];
            break;
         case 8:
            bufout[0] = x * matrix[0];
            break;
         case 9:
            bufout[0] = x * matrix[0] + matrix[12];
            break;
         case 10:
            bufout[0] = x * matrix[0] + z * matrix[8];
            break;
         case 11:
            bufout[0] = x * matrix[0] + z * matrix[8] + matrix[12];
            break;
         case 12:
            bufout[0] = x * matrix[0] + y * matrix[4];
            break;
         case 13:
            bufout[0] = x * matrix[0] + y * matrix[4] + matrix[12];
            break;
         case 14:
            bufout[0] = x * matrix[0] + y * matrix[4] + z * matrix[8];
            break;
         case 15:
            bufout[0] = x * matrix[0] + y * matrix[4] + z * matrix[8] + matrix[12];
            break;
      }  /* end: switch ( matmap[0] ) */

      switch ( matmap[1] )
      {
         case 1:
            bufout[1] = matrix[13];
            break;
         case 2:
            bufout[1] = z * matrix[9];
            break;
         case 3:
            bufout[1] = z * matrix[9] + matrix[13];
            break;
         case 4:
            bufout[1] = y * matrix[5];
            break;
         case 5:
            bufout[1] = y * matrix[5] + matrix[13];
            break;
         case 6:
            bufout[1] = y * matrix[5] + z * matrix[9];
            break;
         case 7:
            bufout[1] = y * matrix[5] + z * matrix[9] + matrix[13];
            break;
         case 8:
            bufout[1] = x * matrix[1];
            break;
         case 9:
            bufout[1] = x * matrix[1] + matrix[13];
            break;
         case 10:
            bufout[1] = x * matrix[1] + z * matrix[9];
            break;
         case 11:
            bufout[1] = x * matrix[1] + z * matrix[9] + matrix[13];
            break;
         case 12:
            bufout[1] = x * matrix[1] + y * matrix[5];
            break;
         case 13:
            bufout[1] = x * matrix[1] + y * matrix[5] + matrix[13];
            break;
         case 14:
            bufout[1] = x * matrix[1] + y * matrix[5] + z * matrix[9];
            break;
         case 15:
            bufout[1] = x * matrix[1] + y * matrix[5] + z * matrix[9] + matrix[13];
            break;
      }  /* end: switch ( matmap[1] ) */

      switch ( matmap[2] )
      {
         case 1:
            bufout[2] = matrix[14];
            break;
         case 2:
            bufout[2] = z * matrix[10];
            break;
         case 3:
            bufout[2] = z * matrix[10] + matrix[14];
            break;
         case 4:
            bufout[2] = y * matrix[6];
            break;
         case 5:
            bufout[2] = y * matrix[6] + matrix[14];
            break;
         case 6:
            bufout[2] = y * matrix[6] + z * matrix[10];
            break;
         case 7:
            bufout[2] = y * matrix[6] + z * matrix[10] + matrix[14];
            break;
         case 8:
            bufout[2] = x * matrix[2];
            break;
         case 9:
            bufout[2] = x * matrix[2] + matrix[14];
            break;
         case 10:
            bufout[2] = x * matrix[2] + z * matrix[10];
            break;
         case 11:
            bufout[2] = x * matrix[2] + z * matrix[10] + matrix[14];
            break;
         case 12:
            bufout[2] = x * matrix[2] + y * matrix[6];
            break;
         case 13:
            bufout[2] = x * matrix[2] + y * matrix[6] + matrix[14];
            break;
         case 14:
            bufout[2] = x * matrix[2] + y * matrix[6] + z * matrix[10];
            break;
         case 15:
            bufout[2] = x * matrix[2] + y * matrix[6] + z * matrix[10] + matrix[14];
            break;
      }  /* end: switch ( matmap[1] ) */

   }

   return( DL_SUCCESS );

}  /* DLIxform3D */

/*--- DLIxform4D ------------------------------------------------*/

int DLIxform4D(
   double *bufin,
   double *bufout,
   int numpnts,
   double matrix[16],
   int matmap[4] )

/*
NAME
	DLIxform4D

DESCRIPTION
	This function transforms an array of points using a
	perspective pipe matrix.

SYNOPSIS
	int DLIxform4D(
	   double *bufin,
	   double *bufout,
	   int numpnts,
	   double matrix[16],
	   int matmap[4] )

PARAMETERS
	bufin (IN) - the array of points to transform (xyz, xyz, etc )
	bufout (OUT) - the transformed array of homogeneous points
                       (xyzw, xyzw, xyzw, etc)
	numpnts (IN) - the number of points to transform
	matrix (IN) - the matrix to use for the transformation
	matmap (IN) - results from matrix characterization to optimize
                      the transformation

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/18/92    S.P. Rogers
	   Documented
*/

{
   double x, y, z;

   for ( ; numpnts--; bufin += 3, bufout += 4 )
   {
      x = bufin[0];
      y = bufin[1];
      z = bufin[2];

      switch ( matmap[0] )
      {
         case 1:
            bufout[0] = matrix[12];
            break;
         case 2:
            bufout[0] = z * matrix[8];
            break;
         case 3:
            bufout[0] = z * matrix[8] + matrix[12];
            break;
         case 4:
            bufout[0] = y * matrix[4];
            break;
         case 5:
            bufout[0] = y * matrix[4] + matrix[12];
            break;
         case 6:
            bufout[0] = y * matrix[4] + z * matrix[8];
            break;
         case 7:
            bufout[0] = y * matrix[4] + z * matrix[8] + matrix[12];
            break;
         case 8:
            bufout[0] = x * matrix[0];
            break;
         case 9:
            bufout[0] = x * matrix[0] + matrix[12];
            break;
         case 10:
            bufout[0] = x * matrix[0] + z * matrix[8];
            break;
         case 11:
            bufout[0] = x * matrix[0] + z * matrix[8] + matrix[12];
            break;
         case 12:
            bufout[0] = x * matrix[0] + y * matrix[4];
            break;
         case 13:
            bufout[0] = x * matrix[0] + y * matrix[4] + matrix[12];
            break;
         case 14:
            bufout[0] = x * matrix[0] + y * matrix[4] + z * matrix[8];
            break;
         case 15:
            bufout[0] = x * matrix[0] + y * matrix[4] + z * matrix[8] + matrix[12];
            break;
      }  /* end: switch ( matmap[0] ) */

      switch ( matmap[1] )
      {
         case 1:
            bufout[1] = matrix[13];
            break;
         case 2:
            bufout[1] = z * matrix[9];
            break;
         case 3:
            bufout[1] = z * matrix[9] + matrix[13];
            break;
         case 4:
            bufout[1] = y * matrix[5];
            break;
         case 5:
            bufout[1] = y * matrix[5] + matrix[13];
            break;
         case 6:
            bufout[1] = y * matrix[5] + z * matrix[9];
            break;
         case 7:
            bufout[1] = y * matrix[5] + z * matrix[9] + matrix[13];
            break;
         case 8:
            bufout[1] = x * matrix[1];
            break;
         case 9:
            bufout[1] = x * matrix[1] + matrix[13];
            break;
         case 10:
            bufout[1] = x * matrix[1] + z * matrix[9];
            break;
         case 11:
            bufout[1] = x * matrix[1] + z * matrix[9] + matrix[13];
            break;
         case 12:
            bufout[1] = x * matrix[1] + y * matrix[5];
            break;
         case 13:
            bufout[1] = x * matrix[1] + y * matrix[5] + matrix[13];
            break;
         case 14:
            bufout[1] = x * matrix[1] + y * matrix[5] + z * matrix[9];
            break;
         case 15:
            bufout[1] = x * matrix[1] + y * matrix[5] + z * matrix[9] + matrix[13];
            break;
      }  /* end: switch ( matmap[1] ) */

      switch ( matmap[2] )
      {
         case 1:
            bufout[2] = matrix[14];
            break;
         case 2:
            bufout[2] = z * matrix[10];
            break;
         case 3:
            bufout[2] = z * matrix[10] + matrix[14];
            break;
         case 4:
            bufout[2] = y * matrix[6];
            break;
         case 5:
            bufout[2] = y * matrix[6] + matrix[14];
            break;
         case 6:
            bufout[2] = y * matrix[6] + z * matrix[10];
            break;
         case 7:
            bufout[2] = y * matrix[6] + z * matrix[10] + matrix[14];
            break;
         case 8:
            bufout[2] = x * matrix[2];
            break;
         case 9:
            bufout[2] = x * matrix[2] + matrix[14];
            break;
         case 10:
            bufout[2] = x * matrix[2] + z * matrix[10];
            break;
         case 11:
            bufout[2] = x * matrix[2] + z * matrix[10] +
               matrix[14];
            break;
         case 12:
            bufout[2] = x * matrix[2] + y * matrix[6];
            break;
         case 13:
            bufout[2] = x * matrix[2] + y * matrix[6] + matrix[14];
            break;
         case 14:
            bufout[2] = x * matrix[2] + y * matrix[6] + z * matrix[10];
            break;
         case 15:
            bufout[2] = x * matrix[2] + y * matrix[6] + z * matrix[10] + matrix[14];
            break;
      }  /* end: switch ( matmap[2] ) */

      switch ( matmap[3] )
      {
         case 1:
            bufout[3] = matrix[15];
            break;
         case 2:
            bufout[3] = z * matrix[11];
            break;
         case 3:
            bufout[3] = z * matrix[11] + matrix[15];
            break;
         case 4:
            bufout[3] = y * matrix[7];
            break;
         case 5:
            bufout[3] = y * matrix[7] + matrix[15];
            break;
         case 6:
            bufout[3] = y * matrix[7] + z * matrix[11];
            break;
         case 7:
            bufout[3] = y * matrix[7] + z * matrix[11] + matrix[15];
            break;
         case 8:
            bufout[3] = x * matrix[3];
            break;
         case 9:
            bufout[3] = x * matrix[3] + matrix[15];
            break;
         case 10:
            bufout[3] = x * matrix[3] + z * matrix[11];
            break;
         case 11:
            bufout[3] = x * matrix[3] + z * matrix[11] + matrix[15];
            break;
         case 12:
            bufout[3] = x * matrix[3] + y * matrix[7];
            break;
         case 13:
            bufout[3] = x * matrix[3] + y * matrix[7] + matrix[15];
            break;
         case 14:
            bufout[3] = x * matrix[3] + y * matrix[7] + z * matrix[11];
            break;
         case 15:
            bufout[3] = x * matrix[3] + y * matrix[7] + z * matrix[11] + matrix[15];
            break;

      }  /* end: switch ( matmap[3] ) */

   }

   return( DL_SUCCESS );

}  /* DLIxform4D */
