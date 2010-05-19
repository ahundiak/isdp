#include <stdio.h>
#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"
#include "bsvalues.h"
#include "bsdotp.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                          */
/*             are poles aligned		                            *
		16 Feb 94 PW: added test on BSnorvec, if two end poles are
			      at the same point, return BSDGENRAT.	    */
/*                                                                          */
    POarepolaln( bsp, tol, rc )  
/*               I  , I  , O                                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct 	  IGRbsp_curve 		*bsp;
IGRdouble			tol;
IGRlong				*rc;

{

    IGRlong		irc; 
    IGRint		i, j, iD3, num_poles;
    IGRdouble		v1[3], v2[3], w[3];

	if ( !bsp ) goto wrapup;

        if( bsp->num_poles == 2 ) {
		*rc = BSSUCC; 
		return;
	}

	num_poles = 3 * (bsp->num_poles-1);

	BSmkvec( &irc,v1,&(bsp->poles[0]),&(bsp->poles[num_poles]) );
	BSnorvec( &irc,v1); 
	if ( irc == BSDGENRAT ) {
		*rc = irc ;
		return;
	}

	if( !bsp->rational ){

        	for( i=3;i<=num_poles;i+=3 ){

			BSmkvec( &irc,v2,&(bsp->poles[0]),&(bsp->poles[i]) );
			BScrossp( &irc, v1,v2,w);

			if( BSdotp(&irc,w,w) >= tol ) goto wrapup;
		}

	}
	else{

        	for( i=3;i<=num_poles;i+=3 ){

			iD3 = i / 3;

			for(j=0;j<3;j++) 
			v2[j] = bsp->poles[i+j] / bsp->weights[iD3] - 
				bsp->poles[j];

			BScrossp( &irc, v1,v2,w);

			if( BSdotp(&irc,w,w) >= tol ) goto wrapup;
		}



	} /* else rational */


	*rc = BSSUCC;
	return;
wrapup:

	*rc = BSFAIL;		
        return;

}/* end of arepolaln */

