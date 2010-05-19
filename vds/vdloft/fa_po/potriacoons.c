/*----
%HD%
 
     MODULE NAME POtriaCoons()
 
     Abstract:
        This function evaluates the poles of a triparametric Coons
	patch.

	The 3 curves MUST have the same number of poles and ordered.

	   c1	     c2      c3
	.------->.------->.------->.

	The caller should malloc the pPoles array to idim * np * (np+1) / 2. 

	example of what you get in pPoles with 5 poles per curve:


			       10
			       / \
			     11---6
			     / \ / \
			   12---7---3     
			   / \ / \ / \
			 13---8---4---1
			 / \ / \ / \ / \
		       14---9---5---2---0  


-----
%SC%

     result = POtriaCoons( idim, pC1, pC2, pC3, np, pPoles )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        idim	   IGRshort      dimension if 2d 3d ..
        *pC1       IGRdouble     poles of the first contour
        *pC2       IGRdouble     poles of the second
        *pC3       IGRdouble     poles of the third
 
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 2 June 1995 Creation date.. my last production for I/LOFT..
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <stdio.h>
#include "v_.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"

void POtriaCoons( idim, pC1, pC2, pC3, np, pPoles )

IGRshort	idim;
IGRdouble	*pC1;
IGRdouble	*pC2;
IGRdouble	*pC3;
IGRint		np;
IGRdouble	*pPoles;

{

IGRint		npMidim;
IGRint		i, i1, j, j1, k, m, m0, m1, m11, ind, ni1, nj1, ij1, nij1;
IGRdouble	deno, x, y, z, xb, yb, zb, xyb, xzb, yxb, yzb, zxb, zyb;


	for(k=0;k<idim;k++) pPoles[k] = pC1[k];

	ind = idim * ( np * (np+1) / 2 );
	npMidim = idim * np;
	j = npMidim - idim;

	for (i=j; i>=0; i-=idim )
	{
		ind -= idim;
		for( k=0; k<idim; k++ ) pPoles[ind+k] = pC2[i+k];
	}

	m    = npMidim;
	m0   = m - idim;
	ind -= idim;

	
	for( i=idim; i<m0; i+=idim )
	{
		m -= idim;
		j  = ind - m + idim;
		m1 = m - idim;

		for( k=0; k<idim; k++ ){
			pPoles[ind+k] = pC3[i+k];
			pPoles[j+k]   = pC1[m1+k];

		}
		ind -= m;
	}

	m1   = np - 1;
	deno = (IGRdouble) m1;
	m0   = 5;
	ind  = 3;

	for( i=2; i<m1; i++ )
	{
		m  = m0;
		y  = (IGRdouble)(i-1);
		y /= deno;

		for ( j=2; j<=(np-i); j++ )
		{
			x   = (IGRdouble)(j-1);
			x  /= deno;
			xb  = 1.0 - x;
			yb  = 1.0 - y;
			zb  = x + y;
			z   = 1.0 - zb;
			zxb = z / xb;
			yxb = y / xb;
			zyb = z / yb;
			xyb = x / yb;
			xzb = x / zb;
			yzb = y / zb;

			ni1  = idim * ( np - i );
			nj1  = idim * ( np - j );
			ij1  = idim * ( i + j - 2 );
			nij1 = idim * ( np - 1 ) - ij1;
			i1   = idim * ( i - 1 );
			j1   = idim * ( j - 1 );
			m11  = idim * ( m - 1 );

			for( k=0; k<idim; k++ )
			 pPoles[m11+k] = 
			                 ( zxb * pC1[j1+k]   + 
					   yxb * pC2[nj1+k]  +
					   xyb * pC2[i1+k]   +
					   zyb * pC3[ni1+k]  +
					   yzb * pC3[nij1+k] +
					   xzb * pC1[ij1+k]  -
					   x * pC2[k]        -
					   y * pC3[k]        -
					   z * pC1[k]           ) * 0.5;

			m += (i + j - 1);

		}

		ind += 1;
		m0  += ind;

	}

 
}
