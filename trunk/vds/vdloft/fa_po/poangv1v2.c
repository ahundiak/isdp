/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME POangv1v2
 
     Abstract:
        This function evaluate the angle between 2 vectors with respect
	to the vz vector.
-----
%SC%

     POangv1v2( v1, v2, vz, &angle, &rc )
		I , I , I , O     , O
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *v1    	   IGRdouble     vector[3] first vector 
        *v2        IGRdouble     vector[3] second vector
	*vz	   IGRdouble	 vector[3] direction vector
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*angle	   IGRdouble	angle between v1,v2
        *rc        BSrc         completion code message
                                 -  BSSUCC if ok

  
-----
%MD%

     MODULES INVOKED: BSdotp, BScrossp, BSlenvec, atan2, modulo,
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

#include <math.h>
#include "v_.h"
#include "bsvalues_sn.h"
#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"

#include "bsdotp.h"	/* extern  IGRdouble	BSdotp();   */
#include "bslenvec.h"	/* extern  IGRdouble	BSlenvec(); */
#include "bscrossp.h"	/* extern  IGRboolean	BSlenvec(); */

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

POangv1v2( v1, v2, vz, angle, rc )

IGRdouble	*v1;
IGRdouble	*v2;
IGRdouble	*vz;
IGRdouble	*angle;
BSrc		*rc;



 {

	BSrc		rcc;
	IGRdouble	cosinus, sinus, kz, DEUXPI;
	IGRvector	normal;

	if ( !v1 || !v2  || !vz || !angle ) goto wrapup;

	/* -- compute angle's ( cosinus * length ) -- */

	cosinus = BSdotp ( &rcc, v1, v2 );

	/* -- compute angle's ( sinus * length ) -- */

	BScrossp (&rcc, v1, v2, normal);
	sinus = BSlenvec ( &rcc, normal );

	/* -- compute angle -- */

        if (fabs(cosinus) > 0.0)
	  *angle = atan2(sinus,cosinus);
        else{
	  if( ( fabs( BSdotp(&rcc,v1,v1) ) > 0.0 ) && 
	      ( fabs( BSdotp(&rcc,v2,v2) ) > 0.0 ) ) 	   *angle = 0.5 * M_PI;
	  else 						   *angle = 0;
	}

	/* angle or PI - angle depending upon vz value */

	kz = BSdotp ( &rcc, normal, vz );

	/* -- if kz < 0 => take the complementary angle -- */
	
	DEUXPI = 2.0 * M_PI;

	if ( kz < 0 ) *angle = DEUXPI - *angle;

	modulo( angle, DEUXPI ); 
	
	*rc = BSSUCC;
	return;

wrapup:
	*rc = BSFAIL;
	return;
  }

