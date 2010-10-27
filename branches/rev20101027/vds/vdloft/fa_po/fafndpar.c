/*----
%HD%
 
     MODULE NAME FAfndPar
 
     Abstract:
        This function finds the u,v parameter of a point in the u,v space
	relative to the space of facet defined by P00, P01, P10 and P11.

		^
		|
	      1 |-----------------------
		|                       |
		|   P00		 P01    |
		|   +***********+       |     So us, vs are the parameters
		|    *		*	|     of P(U,V) express in the uv
		|     *		*	|     space of the facet.
	      U |............+	*	|
		|       *    .	*	|
		|	 +***.**+	|
		|     P10    .   P11	|
		|	     .		|
		 -------------------------->
	       0	     V		1
-----
%SC%

     FAfndPar( P00, P01, P10, P11, u, v, us, vs, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *P00      IGRdouble 	 first pole
        *P01      IGRdouble 	 second pole
        *P10	  IGRdouble  	 third pole
        *P11	  IGRdouble 	 forth pole
        u	  IGRdouble  	 u parameter
        v	  IGRdouble  	 v parameter

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*us	   IGRdouble	the u parameter solution
	*vs        IGRdouble	the v parameter solution
        *rc        BSrc         completion code message
                                 - always BSSUCC or BSFAIL
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 9-03-95 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <stdio.h>
#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"

IGRboolean FAfndPar( P00, P01, P10, P11, u, v, us, vs, rc )

IGRdouble	*P00;	/*I first pole 					      */
IGRdouble	*P01;	/*I second pole 				      */
IGRdouble	*P10;   /*I third pole 					      */
IGRdouble	*P11;   /*I forth pole 					      */
IGRdouble	u;	/*I u parameter in the uv space of one surface        */
IGRdouble	v;	/*I v parameter in the uv space of one surface        */
IGRdouble	*us;	/*O u parameter solution in the uv space of the facet */
IGRdouble	*vs;    /*O v parameter solution in the uv space of the facet */
BSrc		*rc;    /*O BSSUCC or BSFAIL                                  */

{


extern IGRdouble 	sqrt();
extern IGRdouble	fabs();
extern IGRdouble 	POdistptpts();
extern  void    	FAev();
extern  void    	FAev1();

#define	ZERO    1.0E-30
#define ZEROPAR 1.0E-10



IGRint		i;
IGRdouble	a[2],b[2],c[2],d[2];
IGRdouble	delta0, delta1, delta2;
IGRdouble	dd, s1, s2, vs1, vs2, xx;

/*c evaluate the coefficient of the trinome to simplify the writing a[i] = ai
	
   		(1) a0 + r*b0 + s*c0 + r*s*d0 = e0
		(2) a1 + r*b1 + s*c1 + r*s*d1 = e1

		from equation (1) evaluate s = F(r)
		s = ( e0 - a0 - r*b0 ) / ( c0 + r*d0 ) = N(r)/D(r)

		replace s by F(r) in equation (2)
		
		P(r)*D(r) = a1*D(r) + r*b1*D(r) + c1*N(r) + r*N(r)*d1 = e1*D(r)
		
		P(r)*D(r) - e1*D(r) = a1*( c0 + r*d0 ) + 
			    	      r*b1*( c0 + r*d0 ) +
			              c1*( e0 - a0 - r*b0 ) + 
			              r*( e0 - a0 - r*b0 )*d1 - 
			              e1*( c0 + r*d0 )


		P(r)*D(r) - e1*D(r) = delta0 + r*delta1 + r*r*delta2 = 0

		with:

		delta0 = a1*c0 - a0*c1 + c1*e0 - c0*e1 
	   	delta1 = a1*d0 + b1*c0 - c1*b0 + d1*e0 - d1*a0 - d0*e1
		delta2 = b1*d0 - b0*d1
*/


/*c eval the coefficients of the surface */

for(i=0;i<2;i++){
	a[i] = P00[i];
	b[i] = P01[i] - P00[i];
	c[i] = P10[i] - P00[i];
	d[i] = P00[i] - P01[i] - P10[i] + P11[i];
}

delta2 = d[0]*d[0] + d[1]*d[1];

/*d
printf("dd delta2 = %16.13f\n",delta2 );
d*/
	
if( delta2 > ZERO ){

	delta0 = a[1]*c[0] - a[0]*c[1] + c[1]*u - c[0]*v; 
   	delta1 = a[1]*d[0] + b[1]*c[0] - c[1]*b[0] + d[1]*u - d[1]*a[0] -d[0]*v;
	delta2 = b[1]*d[0] - b[0]*d[1];
	dd = delta1 * delta1 - 4.0 * delta2 * delta0;

	/*d
	printf("delta0 = %17.14f\n",delta0);
	printf("delta1 = %17.14f\n",delta1);
	printf("delta2 = %17.14f\n",delta2);
	printf(" dd = %17.14f\n",dd);
	d*/

	if ( dd < 0.0 ) goto wrapup;
	else if( dd > 0.0 ) {
	   if( fabs(delta2) > ZERO ){
	   	dd = sqrt(dd);
		delta2 *= 2.0; 
	   	s1 = ( -delta1 - dd ) / delta2;
	   	s2 = ( -delta1 + dd ) / delta2;

		/*d
		printf("delta2 = 0\n");
		d*/
	   }
	   else{
		s1 = - delta0 / delta1;
		s2 = -s1;
	   }
	}
	else{

	   /* 
	    *	I decided to solve it as 2 distinct roots.
	    */

	   /*d
	    printf("racine double\n");
	   d*/

	   s1 = ( -delta1 ) / delta2;
	   s2 = 10.0E30;
	}
	

	/* 
	 *	two distinct roots in the non degenerated case
	 */

	a[0] = u - a[0];
	a[1] = v - a[1];

	xx = c[1] + s1 * d[1];
	if( fabs(xx) > ZERO ) vs1 = ( a[1] - s1 * b[1] ) / xx; 
	else vs1 = 10.0E30;
	xx = c[0] + s1 * d[0];
	if( fabs(xx) > ZERO ) vs2 = ( a[0] - s1 * b[0] ) / xx; 
	else vs2 = 10.0E30;
	if( fabs(vs2) < fabs(vs1) ) vs1 = vs2;

	xx = c[1] + s2 * d[1];
	if( fabs(xx) > ZERO ) vs2 = ( a[1] - s2 * b[1] ) / xx; 
	else vs2 = 10.0E30;
	xx = c[0] + s2 * d[0];
	if( fabs(xx) > ZERO ) xx = ( a[0] - s2 * b[0] ) / xx; 
	else xx = 10.0E30;
	if( fabs(xx) < fabs(vs2) ) vs2 = xx;
				

	/*d
	printf("\n\n two distinct roots\n");
	printf("s1=%f,vs1=%lf,s2=%lf,vs2=%lf\n",s1,vs1,s2,vs2);
	d*/

	if ( fabs(vs1) < fabs(vs2) ){
		*us = s1;
		*vs = vs1;
	}
	else if( fabs(vs1) > fabs(vs2) ){
		*us = s2;
		*vs = vs2;
	}
	else{
		/*d
		printf("cas abs(vs1) == abs(vs2)\n");
		d*/

		if( ( s1 < (-ZEROPAR) ) || ( (s1-1.0) > ZEROPAR ) ){
			*us = s2;
			*vs = vs2;
		}
		else if( ( s2 < (-ZEROPAR) ) || ( (s2-1.0) > ZEROPAR )){
			*us = s1;
			*vs = vs1;
		}
			else goto wrapup;
	}

}
else{
	/*
         *	then the equations (1) and (2) become
	 *
	 *   	(1) a0 + r*b0 + s*c0  = e0 
	 *	(2) a1 + r*b1 + s*c1  = e1
	 */

	/*d
	printf("cas degenere\n");	
	d*/

	delta1 = b[0]*c[1] - b[1]*c[0];
		
	if( fabs(delta1) > ZERO ){
	   *us = (a[1]*c[0] - a[0]*c[1] + c[1]*u - c[0]*v) / delta1;
	   *vs = (b[0]*v - b[0]*a[1] + b[1]*a[0] - b[1]*u) / delta1; 
	}
	else goto wrapup;
}


/*d 
printf("us,vs = %20.18f,%20.18f\n",*us,*vs);
d*/

*rc = BSSUCC;
if( ( *us < (-ZEROPAR) ) || ( (*us-1.0) > ZEROPAR ) ) return(FALSE);
if( ( *vs < (-ZEROPAR) ) || ( (*vs-1.0) > ZEROPAR ) ) return(FALSE);
return(TRUE);



wrapup:
	*rc = BSFAIL;
	return(FALSE);

}

