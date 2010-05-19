/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                          */
/*               load the IGRarc structure                                  */
/*                                                                          */
/* constarc( msg, center, strvec, endvec, radius, arc, arc_len )            */
/*           O  , I     , I     , I     , I     , O  , O	            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#include <stdio.h>
#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"
#include "bsvalues.h"

#include "bsnorvec.h"
#include "bscrossp.h"

POcstarcstr( center, strvec, endvec, radius, arc, arc_len, rc )  

IGRdouble       *center;
IGRdouble	*strvec;
IGRdouble	*endvec;
IGRdouble	radius;
struct IGRarc	*arc;
IGRdouble	*arc_len;
IGRlong		*rc;

{

IGRlong		rcc;
IGRint		i,k;
IGRdouble	VX[3],VY[3],VZ[3];


if ( !center || !strvec || !endvec || !arc || !arc_len ) goto wrapup;



	arc->prim_axis = radius;
	arc->sec_axis  = radius;
	
	for(i=0; i<3; i=i+1){
		VX[i] = strvec[i];
		VY[i] = endvec[i];
	}


	BSnorvec(&rcc,VX);
	BScrossp(&rcc,VX,VY,VZ);
	BSnorvec(&rcc,VZ);

	POangv1v2( VX,VY,VZ, &(arc->sweep_angle),&rcc );
	if( rcc != BSSUCC ) goto wrapup;


	BScrossp(&rcc,VZ,VX,VY);
	BSnorvec(&rcc,VY);		
	
	for(i=0; i<3; i=i+1){
		k = 4*i;
		arc->origin[i] 	      = center[i];
		arc->rot_matrix[k]    = VX[i];
		arc->rot_matrix[k+1]  = VY[i];
		arc->rot_matrix[k+2]  = VZ[i];
		arc->rot_matrix[k+3]  = 0.0;
		arc->rot_matrix[12+i] = 0.0;
   	}
		
	arc->rot_matrix[15] = 1.0;

   	arc->start_angle = 0.0;

	*arc_len = radius * arc->sweep_angle;
	*rc = BSSUCC;
	return;
wrapup:
	*rc = BSFAIL;
	return;
}
