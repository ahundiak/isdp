/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

#include "igrtypedef.h"

void	MSmat_transpose(a, b)

/*  sets b = a transpose for 3x3 matrix a */

IGRdouble	a[3][3], b[3][3];

{
	IGRlong	i, j;
	
	for(i = 0; i < 3; i ++)
	 {
		for(j = 0; j < 3; j ++)
		 {
			b[i][j] = a[j][i];
		 }
	 }
}


void MSmat_mult(a, b, c)

/* sets c = a x b  for 3x3 matrices */

IGRdouble a[3][3], b[3][3], c[3][3];

{
	IGRlong	i, j;
	
	for(i = 0; i < 3; i ++)
	 {
		for(j = 0; j < 3 ; j++)
		 {
			c[i][j] = a[i][0] * b[0][j] +
				  a[i][1] * b[1][j] +
				  a[i][2] * b[2][j];
		 }
	 }
}
