#include <stdio.h>
#include <math.h>
#include <values.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"
#include "VDobj.h"
#include "vsdbgmacros.h"
/*
 * Include of prototypes begin
 */
#include "bspl_pl.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bscrossp.h"
/*---------------------------------------------------------------------------*/
long VSgetRelativeAngle( 
	IGRdouble localy[], 		/* local y-axis 	*/
	IGRdouble localz[],		/* local z-axis 	*/
	IGRdouble theta, 		/* input angle in rad 	*/
	char 	  refType,		/* reference type  	*/
	IGRdouble localOrg[], 		/* origin of local CS	*/
	IGRdouble *orgAngle  )		/* output angle	in rad	*/
{

	IGRdouble 	norToRotPl[3],	/* Vector normal to rotated plane */
			dp;		/* value of dot product		  */
	struct IGRplane	rotatedPl, 	/* plane rotated with angle	  */
			localxy;	/* local x-y plane		  */
	IGRdouble 	ptvec[3], 	/* pnt of intersection 		  */
			intersectVec[3],/* intersection vector direction  */ 
			norLocalz[3],	/* normalised local z-direction   */
			norLocaly[3], 	/* normalised local y-direction   */
			cross[3];	/* vector for cross product	  */
	IGRint 		flag;		/* pl_pl intersection result	  */
	BSrc		rc;		/* BS return code		  */
     
	__DBGpr_vec(" Local Y-Dir", localy ) ;
	__DBGpr_vec(" Local Z-Dir", localz ) ;
	
     	switch( refType )  {
		case 'F' :
		case 'f' :
              		norToRotPl[0] =  cos(theta) ;
              		norToRotPl[1] =  0.0 ;
              		norToRotPl[2] =  -sin(theta) ; 
              		break ;

        	case 'B' :
        	case 'b' :
              		norToRotPl[0] =  0.0 ;
              		norToRotPl[1] =  -cos(theta) ;
              		norToRotPl[2] =  -sin(theta) ;
              		break ;
 
        	case 'W' :
        	case 'w' :
              		norToRotPl[0] =  0.0 ;
              		norToRotPl[1] =  -sin(theta) ;
              		norToRotPl[2] =  cos(theta) ;
             	 	break ;

		case 'Y' :
		case 'y' :
              		norToRotPl[0] =  -sin(theta) ;
              		norToRotPl[1] =  0.0 ;
              		norToRotPl[2] =  -cos(theta) ; 
              		break ;

		case 'N' :
		case 'n' :
			*orgAngle = theta ;
			return OM_S_SUCCESS ;
	}

	/* 
	 * define base plane with point at the local origin and normal
	 * in the rotated vector direction
	 */

	rotatedPl.point = localOrg;
	rotatedPl.normal= norToRotPl;

	/* 
	 * define local plane with point at the local origin and normal
	 * pointing in the local z-direction
	 */
	norLocalz[0] = localz[0];
	norLocalz[1] = localz[1];
	norLocalz[2] = localz[2];

	BSnorvec( &rc, norLocalz );
	__DBGpr_vec(" Normalised Local Z", norLocalz ) ;

	localxy.point  = localOrg;
	localxy.normal = norLocalz;

	/* 
	 * Intersect the two planes 
	 */

	BSpl_pl( rotatedPl.point,
		 rotatedPl.normal,
		 localxy.point,
		 localxy.normal,
		 &flag,
		 ptvec,
		 intersectVec,
		 &rc	) ;
	if( BSERROR( rc ) ) { return MSFAIL ; }
	if ( flag == BSCINTERSECTING )

	__DBGpr_vec("Intersect vector", intersectVec);
	__DBGpr_vec("Pnt Of Intersection", ptvec);

        norLocaly[0] = localy[0];
        norLocaly[1] = localy[1];
        norLocaly[2] = localy[2];
        /*
         * Normalise the resultant vectors
         */
        BSnorvec( &rc, intersectVec );
        BSnorvec( &rc, norLocaly );

	__DBGpr_vec("normalised intersect Vector", intersectVec ) ;
	__DBGpr_vec("normalised Local y-dir", norLocaly );

	
	dp =  BSdotp(&rc, norLocaly, intersectVec ); 
	*orgAngle = acos(dp);

	BScrossp( &rc, norLocaly, intersectVec, cross );

	dp =  BSdotp(&rc, cross, localz ); 
	if ( dp < 0.0 ) {
		*orgAngle *= -1.0;
		*orgAngle = *orgAngle + M_PI ; 
	}

	return OM_S_SUCCESS ;
}
/*---------------------------------------------------------------------------*/
