/*----
%HD%
 
     MODULE NAME FAsetRng
 
     Abstract:
        This function evaluate the range of a set of facets.



	^
	|
	|
	|
   vmax + . . . . . . ##########
	|	      #    /\  #
        |             #   /  \ #
	|	      #  /    \#
	|	      # /     /#
	|	      #/     / #
	|	      #\    /  #
        |	      # \  /   #
        |             #	 \/    #
   vmin + . . . . . . ##########
	|	      .	       .
	|	      .	       .
	|	      .	       .
	|	      .	       .
	 -------------+--------+-------------->
		      umin     umax

-----
%SC%

     FAsetRng( idim, pars, uNum, vNum, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	idim	  IGRshort	 the dimension
        *pars     IGRdouble 	 the matrix of poles
        uNum      IGRint 	 the number of poles in u
        vNum      IGRint	 the number of poles in v

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *rc        BSrc         completion code message
                                 - BSSUCC or BSSDGENRAT
        result     IGRboolean   TRUE or FALSE
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 8 march 95 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"

void  FAsetRng( idim, pars, uNum, vNum, rc )

IGRshort	idim;
IGRdouble	*pars;
IGRint          uNum;
IGRint          vNum;
BSrc		*rc;

{



IGRint		i, j, jend, offset, offsetMiIdim, numPars;
IGRint		start,end;
IGRdouble	*uv;
IGRdouble	*P00, *P01, *P10, *P11;
IGRdouble	delta;

  *rc = BSSUCC;
  numPars = idim * uNum * ( vNum - 1 );
  offset  = idim * uNum;
  offsetMiIdim = offset - idim;

  uv = pars + offset * vNum;

  for(i=0;i<numPars;i+=offset){

	jend = i + offsetMiIdim;

	for(j=i;j<jend;j+=idim){

               
                P00 = pars + j;
		P01 = P00  + idim;
		P10 = P00  + offset;
                P11 = P01  + offset;

		/* set uMin */

		(*uv) = P00[0];
		if( P01[0] < (*uv) ) (*uv) = P01[0];
		if( P10[0] < (*uv) ) (*uv) = P10[0];
		if( P11[0] < (*uv) ) (*uv) = P11[0];
 		
		/* set uMax */
		uv++;
		(*uv) = P00[0];
		if( P01[0] > (*uv) ) (*uv) = P01[0];
		if( P10[0] > (*uv) ) (*uv) = P10[0];
		if( P11[0] > (*uv) ) (*uv) = P11[0];


		/* set vMin */
		uv++;
		(*uv) = P00[1];
		if( P01[1] < (*uv) ) (*uv) = P01[1];
		if( P10[1] < (*uv) ) (*uv) = P10[1];
		if( P11[1] < (*uv) ) (*uv) = P11[1];


		/* set vMax */
		uv++;
		(*uv) = P00[1];
		if( P01[1] > (*uv) ) (*uv) = P01[1];
		if( P10[1] > (*uv) ) (*uv) = P10[1];
		if( P11[1] > (*uv) ) (*uv) = P11[1];
		uv++;		
	}
  }

  uv = pars +  offset * vNum + 4*(uNum-1)*(vNum-1);

  memcpy((IGRchar *) uv,(IGRchar *) pars,
         (IGRint) uNum*idim*sizeof(IGRdouble));
  
  P01 = uv + offset;
  P11 = uv + idim*(2*(uNum+vNum)-3) -2*idim;
  start = offset + offsetMiIdim;
  end = idim*(uNum*vNum-1);

  for (j=start;j<=end;j += offset)
  {
    P00 = pars + j;
    P01[0] = P00[0];
    P01[1] = P00[1];
    P01[2] = 0;
    
    P00 = P00 - offsetMiIdim;
    P11[0] = P00[0];
    P11[1] = P00[1];
    P11[2] = 0;
  
    P01 += idim;
    P11 -= idim;
  }

  P10 = uv + (uNum + vNum - 1)*idim;
  start = idim*(uNum*vNum -2 );
  end   = start - (uNum - 3)*idim;
  for (j=start;j>=end; j -= idim)
  {
    P00 = pars + j;
    P10[0] = P00[0];
    P10[1] = P00[1];
    P10[2] = 0;
    P10 += idim;
  }
  j = idim*(2*(uNum+vNum)-3) -idim;
  uv[j] = uv[0];
  uv[j+1] = uv[1];
  uv[j+2] = uv[2];

  j = offset * vNum + 4*(uNum-1)*(vNum-1) + j + idim;
  P00 = pars + j;
  *P00 = 0.0;
  P00++;
  end = 2*(uNum+vNum)-3;
  delta = end - 1;
  for(i=0;i<end;i++) P00[i] = i / delta;
  P00[end] = 1.0; 
  
	

}
