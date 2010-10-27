/*----
%HD%
 
     MODULE NAME POapplaw2val
 
     Abstract:
        This function apply a law to evaluate a intermediate value between
	2 values that define and interval.
-----
%SC%

     POapploi2val( law, strVal, endVal, strInt, endInt, paInt, valSol, &rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        law    	   IGRint	 index between 0 and 5 to select the law
			         law = 0 --> linear (1-u)*strVal + u*endVal
				 law = 1 --> parabolic
				 law = 2 --> other parabolic
				 law = 3 --> cubic
			         law = 4 --> cubic 2
				 law = 5 --> quintinc
				 law = 6 --> order 8
	 
        strVal	   IGRdouble	 starting value that will be interpolated.
	endVal	   IGRdouble	 end value that will be interpolated.
	strInt	   IGRdouble	 start interval.
	endInt	   IGRdouble	 end interval.
	paInt	   IGRdouble	 interpolation parameter that belongs to
				 [strInt,endInt].
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*valSol	   IGRdouble     the value solution.
        *rc        BSrc          completion code message
                                 - BSSUCC or BSFAIL
        result     IGRdouble     dotproduct of two vectors
  
-----
%MD%

     MODULES INVOKED: POcvev
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 2 april 1993, redo it again after 15 years !!!  Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <stdio.h>
#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"

POapplaw2val( law, strVal, endVal, strInt, endInt, paInt, valSol, rc )

IGRint		law;
IGRdouble	strVal;
IGRdouble	endVal;
IGRdouble	strInt;
IGRdouble	endInt;
IGRdouble	paInt;
IGRdouble	*valSol;
IGRlong		*rc;

{

static int    iord[7]  = { 2, 3, 3, 4, 4, 6, 8 };
static double pol[60]  = {
 
	0.0, 0.0, 1.0,  1.0,
	0.0, 0.0, 0.5,  0.0,  1.0, 1.0,
	0.0, 0.0, 0.75, 0.25, 1.0, 1.0,
	0.0, 0.0, 0.5,  0.0, 0.5, 1.0, 1.0, 1.0,
	0.0, 0.0, (1.0/3.0), 0.0, (2.0/3.0), 1.0, 1.0, 1.0,
	0.0, 0.0, 0.2, 0.0, 0.4, 0.0, 0.6, 1.0, 0.8, 1.0, 1.0, 1.0,  
        0.0, 0.0, (1.0/7.0), 0.0, (2.0/7.0), 0.0, (3.0/7.0), 0.0,
	(4.0/7.0), 1.0, (5.0/7.0), 1.0, (6.0/7.0), 1.0, 1.0, 1.0

};


IGRdouble 	u, v;
IGRshort  	dim;
IGRint		npolMdim;
IGRint		i, index;
IGRdouble	poles[16];
IGRdouble	sol[2];


	*rc = BSFAIL;
	if( ( law < 0 ) || ( law > 6 ) ) return;
  
	dim = 2;
	npolMdim = iord[law] * dim;

	u = ( paInt - strInt ) / ( endInt - strInt );
	index = 0;
	for(i=0;i<law;i++) index += 2 * iord[i];

	for(i=0;i<npolMdim;i+=dim){
		 v = pol[index+i];
		 poles[i] = strInt * (1.0 -v) + v * endInt;
	}
	   
	for(i=1;i<npolMdim;i+=dim){
		 v = pol[index + i];
		 poles[i] = strVal * (1.0-v) + v * endVal;
	}
	POcvev( dim, (IGRboolean) FALSE, poles, iord[law], u, sol, rc );
/*
	for(i=0;i<npolMdim;i+=dim)
	printf("poles[%d] = %f, %f\n",(i/dim),poles[i],poles[i+1]);	
	printf("u = %f\n",u );
	printf("sol = %f, %f\n",sol[0], sol[1]);	
*/

	*valSol = sol[1];
	*rc = BSSUCC;
	return;

}
