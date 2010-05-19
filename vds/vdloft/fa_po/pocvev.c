/*----
%HD%
 
     MODULE NAME POcvev
 
     Abstract:
        This function evaluates the current point from Bezier curve.
	giving the poles;
	poles are store as followed:
	P0(xyzh), P1(xyzh),....., Pn(xyzh) if idim is 4 and rational flag
	is set to TRUE.

-----
%SC%

     POcvev( idim, rational, poles, order, u, sol, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        idim       IGRshort        dimension of the polynomial
        rational   IGRboolean        0 non rational else 1
	*poles     IGRdouble     the array of poles
	order      IGRint	 the order
	u          IGRdouble	 the parameter
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*sol	   IGRdouble	the current point
        *rc        BSrc         completion code message
                                 - always BSSUCC
  
-----
%MD%

     MODULES INVOKED: POlmu
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 12 nov 91 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "v_.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "bsvalues.h"

POcvev ( IGRshort        idim,
         IGRboolean      rational,
         IGRdouble       *poles,
         IGRint          order,
         IGRdouble       u,
         IGRdouble       *sol,
         BSrc            *rc )

{

#define	MAX_OD	3 * MAX_ORDER

IGRint		i, j, j1;
IGRdouble	bern[MAX_OD];


	POlmu(order,u,bern,rc);

	for(i=0;i<idim;i++){
		sol[i] = 0.0;
		j1 = i;
		for(j=0;j<order;j++){
			 sol[i] += poles[j1] * bern[j];
			 j1 += idim;
		}
	}

	if( rational == FALSE ) goto wrapup;
	if( idim == 1 )         goto wrapup;

	j = idim - 1;

	for(i=0;i<j;i++)
	   sol[i] = sol[i] / sol[j];

wrapup:
 	*rc = BSSUCC;
	return;

}
