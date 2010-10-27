/*----
%HD%
 
     MODULE NAME POXXXX
 
     Abstract:
        special function for the circular approximation which
	evaluate the positive root of a trinome.
-----
%SC%

     POrac2( a, b, c, flag, &root, &rc )
	     I, I, I, I   , O    , O
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        a	   IGRdouble     coef of x**2 
        b 	   IGRdouble     coef of x
	c          IGRdouble	 constant
	flag	   IGRint	

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	root	   IGRdouble	you know
        *rc        BSrc         completion code BSSUCC or BSFAIL
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : Creation date.
      
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
#include "bstypes.h"

POrac2( a, b, c, flag, root, rc)


IGRdouble		a;
IGRdouble		b;
IGRdouble		c;
IGRint			flag;
IGRdouble		*root;
IGRlong			*rc;



{

extern IGRdouble	sqrt();


	IGRdouble	d	= 0., 
			u1	= 0.,
			u2	= 0.,
			ZERO;


	if ( !root ) goto wrapup;

	 ZERO = 1.0E-16;

	 d = b*b - 4.0*a*c;
	 if ( !(d < ZERO ) )	/*was >=0.0*/
	 {

	   d = sqrt(d); 

	   u1 = (-b-d) / (2*a);
	   u2 = (-b+d) / (2*a);
	   *rc = BSSUCC;

	   /*
	   printf("POrac2 u1 = %f, u2 = %f\n",u1,u2);
  	   */

	   if( flag == 1 )
	   {
	     if( ( u1 > 0.0 ) && ( u1 < 1.0 ) ) *root = u1;
	     if( ( u2 > 0.0 ) && ( u2 < 1.0 ) ) *root = u2;
	   }
	   else
	   {
	     if( u1 > 0.0 ) *root = u1;
	     if( u2 > 0.0 ) *root = u2;
	   }
           if( *root < ZERO ) *rc = BSFAIL;
	 }
	 else *rc = BSFAIL;

	return;
wrapup:
	*rc = BSFAIL;
	return;
} 


