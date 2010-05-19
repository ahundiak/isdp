/* $Id: VDang_v1v2.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl/VDang_v1v2.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDang_v1v2.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/11/03  17:19:24  pinnacle
# Replaced: ./vdcppl/VDang_v1v2.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/10/95	adz		Seperated from ppl files.
 *
 * -------------------------------------------------------------------*/

class implementation Root ;

#include <stdio.h>

%safe
#include <math.h>
%endsafe

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "bsparameters.h"
#include "bsvalues.h"

#include "msdef.h"			/* MSSUCC */
#include "grerr.h"			/* GRILLDEFINITION */
#include "madef.h"			/* MAIDMX */
#include "bserr.h"			/* BSSUCC for next .h */

#include "growner.h"			/* GRobj_env */
#include "AS_status.h"
#include "v_dbgmacros.h"		/* Debug information */

#include "bsdotp.h"
#include "bscrossp.h"
#include "bslenvec.h"

/*=========================================================================*/
/*            compute the angle between two vectors                        */
/*									   */
/* VDppl_ang_v1v2( v1, v2, vz, angle, rc )				   */
/*                 I , I , I , O    , O					   */
/*=========================================================================*/

void VDppl_ang_v1v2( v1, v2, vz, angle, rc)

IGRdouble	*v1;
IGRdouble	*v2;
IGRdouble 	*vz;
IGRdouble 	*angle;
BSrc		*rc;

{
	IGRlong		retmsg;
	IGRdouble	cosinus,sinus,kz;
	IGRdouble	normal[3];

	*rc = BSSUCC ;

	if( !v1 || !v2 || !vz || !angle )	goto wrapup ;

	/* 
	 * compute angle's ( cosinus * length ) 
	 */
	cosinus = BSdotp ( &retmsg, v1, v2 );

	/* 
	 * compute angle's ( sinus * length ) 
	 */
	BScrossp ( &retmsg, v1, v2, normal);

	sinus = BSlenvec ( &retmsg, normal );

	/*
	 * compute angle 
	 */
	if( fabs( cosinus ) > 0.0 ){
		*angle = atan2( sinus, cosinus );
	}
	else{
		if( ( fabs( BSdotp( &retmsg, v1, v1 )) > 0.0 ) &&
		    ( fabs( BSdotp( &retmsg, v2, v2 )) > 0.0 )){

			*angle = M_PI / 2.0 ;
		}
		else{	*angle = 0.0 ; 
			*rc = BSDGENRAT ;
			return ;
		}
	}

	/*
	 * angle or M_PI - angle depending upon vz value
	 */
	kz = BSdotp ( &retmsg, normal, vz );

	/* 
	 * if kz < 0 => take the complementary angle 
	 */
	if (kz < 0) *angle = 2*M_PI - *angle;

	modulo( angle, 2*M_PI ); 
	__DBGpr_dbl(" Angle ", *angle );

	*rc = BSSUCC ;
	return ;

	wrapup:

		*rc = BSFAIL ;
		return ;
}

end implementation Root ;

