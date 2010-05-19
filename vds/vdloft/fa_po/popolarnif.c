/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  POpolarnif
 
     Abstract:     This function accepts a knot vector, a span index,
             a curve order and an array containing the polar values
	     that will be used to evaluate the polar Ni functions
	     associated to the polar values.
	    
-----
%SC%

     POpolarnif( order, knots, ikt, par, b, rc  )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     order        IGRint         the order of the curve from which the
                                     current span is taken
     *knots       IGRdouble      an array of knots
     ikt          IGRint         the index of the knot which is the origin
				 interval for a diven span.
				 example:
				  ... t0 t1 t2 t2 t3 t4 t4 ... 
						|
						V
				 ikt will contain the index of this t2 value
			         which is the origin of the interval [t2,t3].
     *par         IGRdouble      the array of parameters for which the 
				 polar base functions are calculated
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *b           IGRdouble      the B-spline polar ni coefficients 
				 associated to the polar values loaded in
				 the par array.
     *rc          BSrc           return code
-----
%MD%

     MODULES INVOKED: fabs ( absolute value function )
                      BSEXTRACTPAR ( extract tolerance )
-----
%NB%

     NOTES:     The calling function should allocate space for the array
           	of polar B-spline values. The array b sould be dimensioned
	   	to order and par to order - 1.
-----
%CH%
     CHANGE HISTORY:
	
	JLL  6/feb/92  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "bs.h"
#include "bsparameters.h"

POpolarnif( order, knots, ikt, par, b, rc)

IGRint 		order;      
IGRdouble 	*knots;
IGRint 		ikt;
IGRdouble 	*par;
IGRdouble 	*b;
BSrc 		*rc;          

{

#define		MAX_OD		3 * MAX_ORDER
 
extern  IGRdouble 	fabs();

  IGRint 	i,r,m,n;         /* loop counters                            */
  IGRdouble 	beta[MAX_OD];    
  IGRdouble 	zero_tol;        /* zero tolerance                           */
  IGRboolean 	status;          /* return status from BSEXTRACTPAR          */
  IGRdouble	pa;	      



  *rc = BSFAIL;    
  status = TRUE;

  b[0] = 1;

  status = BSEXTRACTPAR(rc,BSTOLCLOSETOZERO,zero_tol);
  if( !status )  goto wrapup;

  if( fabs( knots[ikt + 1] - knots[ikt] ) < zero_tol ){
    	*rc = BSINARG;
    	goto wrapup;
  }

  for( i = 1; i < order; ++i ){

    	pa = par[i-1];
    	beta[i] = ( pa - knots[ikt] ) / ( knots[ikt + i] - knots[ikt] );
    	b[i] = beta[i] * b[i - 1];

    	for( r = 1; r < i; ++r ){
      		m = i - r;
      		n = ikt - r;
      		beta[m] = ( pa - knots[n] ) / ( knots[n + i] - knots[n] );
     		b[m] = beta[m] * b[m - 1] + ( 1 - beta[m + 1] ) * b[m];
     	}

    	b[0] = ( 1 - beta[1] ) * b[0];
   }

   *rc = BSSUCC;

  wrapup:
  return;
}
