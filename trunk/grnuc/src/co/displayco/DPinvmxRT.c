#include "DPinvmxRT.h" /* defining prototype file */


/* calculate the inverse of an 4x4 matrix which is composed of
[Rotation] * [Tranformation]. This routine will be much faster
than the generic MAinvmx() */

DPinvmxRT(mx,invmx)
double *mx;     /* mx = R * T */
double *invmx;  /* output matrix, the inverse of mx */

/*double mx[4][4];      previous declaration of parameters passed */
/*double invmx[4][4];*/
{
   int i,j;
   
  /* Algorithm:
         MX = R * T  (is how to get the RTmx)
         so, INVMX = inv(T) * inv(R)
         notice, R is upper-left corner of MX, and  transpose(R)==inv(R)
         T == inv(R) * MX, so we can also get inv(T)
         also notice:  inv(T) * inv(R) is simply put the last colum of inv(T) to inv(R)
   
     11/10/92 - needed to adjust algorithm to accept either single or multi-
                dimensional arrays due to ansi prototypes. A 4x4 matrix x[4][4] 
		has element x[i][j] accessed with the formula: 
				num_cols * i + j
                this means element x[2][3] is referenced by x[ 4 * 2 + 3] or
		x[11].     bd
  */
  
   for(i=0;i<4;i++) 
   {
      for(j=0;j<4;j++) 
      {
         invmx[4 * i + j] = mx[4 * j + i];
      }
   }
   invmx[3] = -(invmx[0]*mx[3] + invmx[1]*mx[7] + invmx[2]*mx[11]);

   invmx[7] = -(invmx[4]*mx[3] + invmx[5]*mx[7] + invmx[6]*mx[11]);

   invmx[11] = -(invmx[8]*mx[3] + invmx[9]*mx[7] + invmx[10]*mx[11]);
  
   for(i=0;i<3;i++)
   {
	invmx[4 * 3 + i] = 0.0;
   }

   invmx[15] = 1.0;

/* ++++  previous declaration for error checking and debugging ++++
 *
 * for(i=0;i<4;i++) 
 * {
 *    for(j=0;j<4;j++) 
 *    {
 *        invmx[i][j] = mx[j][i];
 *    }
 * }
 *
 * invmx[0][3] = -(invmx[0][0]*mx[0][3]+invmx[0][1]*mx[1][3]+
 *                 invmx[0][2]*mx[2][3]);
 *
 * invmx[1][3] = -(invmx[1][0]*mx[0][3]+invmx[1][1]*mx[1][3]+
 *                 invmx[1][2]*mx[2][3]);
 *
 * invmx[2][3] = -(invmx[2][0]*mx[0][3]+invmx[2][1]*mx[1][3]+
 *                 invmx[2][2]*mx[2][3]);
 *
 * for(i=0;i<3;i++)
 * {
 *    invmx[3][i] = 0.0;
 * }
 * 
 * invmx[3][3] = 1.0;
 */

   return(1);
   
}

