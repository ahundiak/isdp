/* $Id: VDdataredcv.I,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintersect/VDdataredcv.I
 *
 * Description:
 *		This function can be called everywehere to extablish
 *		data reduction on generated curves.
 *		This function is used to reduice data of the output
 *		of the visualization process.
 *
 * Dependencies:
 *		The file VDSreduidata.I (in same directory) is checking
 *		against the curve order before doing any reduction. This
 *		option is replaced by number of poles.
 *
 * Revision History:
 *	$Log: VDdataredcv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
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
# Revision 1.3  1995/09/28  12:50:58  pinnacle
# Replaced: ./vdintersect/VDdataredcv.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/09/25  13:36:38  pinnacle
# Replaced: vdintersect/VDdataredcv.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/02  15:19:36  pinnacle
# Created: vdintersect/VDdataredcv.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/02/95	adz		creation date.
 *	09/28/95	adz		garentie positive result and
 *					changed the tolerance.
 * -------------------------------------------------------------------*/


class implementation GRvg ;

#include <stdio.h>
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "growner.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototype.
 */
#include "bsdta_rducv.h"
#include "bschangepar.h"
#include "bsxtractpar.h"
#include "bsfreecv.h"

/*----------------------------------------------------------------------------*/
long VD_drwCvApplyDataReduction( msg, redTolerance, elmId, elmEnv )

long			*msg ;		/* O : Return code.		      */
double			*redTolerance ;	/* I : Data Red Tolerance Value       */
struct GRid		*elmId ;	/* I/O : Bspline intesection.         */
struct GRmd_env		*elmEnv ; {	/* I : Object Envireonment.	      */

	long			sts,
				bsRC ;
	struct IGRbsp_curve	*bs_geom = NULL,
				*reduice_geom = NULL ;
	int			tanl,
				tanr ;
	IGRvector		tangentl,
				tangentr ;
	IGRboolean		option ;
	IGRdouble		savTolerance,
				maxerr,
				avgerr,
				par,
				apar ;
	IGRpoint		pt,
				apt ;
	struct GRpost_info	post_info ;
	GRobjid 		newobjid ;

	SetProc( VD_cvApplyDataReduction ); Begin

	if( redTolerance ){
		BSxtractpar( &bsRC, BSTOLCHRDHT, &savTolerance );
		BSchangepar( &bsRC, BSTOLCHRDHT, *redTolerance );
		__DBGpr_dbl(" redTolerance ", *redTolerance );
	}

	/*
	 * See if bspline big enough to reduice.
	 */
	sts = 
	_VD_SEND_OBJN(	*elmId,
			GRvg.GRgenabsg(	msg,
					&elmEnv->md_env.matrix_type,
					elmEnv->md_env.matrix,
					(IGRchar **) &bs_geom ));
	CheckRC( sts, *msg );
	if( !(sts&*msg&1) || ( bs_geom->num_poles < 4 )){
		__DBGpr_com( "\tCurve is smaller or invalid geometry" ) ;
		goto wrapup ;
	}

	/*
	 * Do data reduction.
	 */
	tanl   = 1 ;
	tanr   = 1 ;
	option = TRUE ;

	BSdta_rducv( bs_geom,
		     tanl,
		     tanr,
		     tangentl,
		     tangentr,
		     option,
		     &maxerr,
		     &avgerr,
		     &par,
		     pt,
		     &apar,
		     apt,
		     &reduice_geom,
		     &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR : Cannot reduice using BSdta_rducv" ) ;
		goto wrapup ;
	}

        __DBGpr_dbl( "Average Error ", avgerr );
        __DBGpr_dbl( "Maximum Error ", maxerr );

	post_info.construct_flag = FALSE ;

	__DBGpr_int( "\tOld Number Poles ", bs_geom->num_poles );
	__DBGpr_int( "\tNew Number Poles ", reduice_geom->num_poles );

	/*
	 * Only post when the new result is better. We are checking here 
	 * because the tolerance is put to bastol for precision reasons.
	 */
	if( reduice_geom->num_poles < bs_geom->num_poles ){

		sts =
		_VD_SEND_OBJN(	*elmId,
				GRvg.GRpostabsg(msg,
						elmEnv,
						&post_info,
						(IGRchar *) reduice_geom,
						&newobjid ));
		if( !(sts&*msg&1)){
			/*
			 * We re-address the previous geometry info.
			 */
			__DBGpr_com(" Error in Posting New Geometry ");
			sts =
			_VD_SEND_OBJN(	*elmId,
					GRvg.GRpostabsg(msg,
							elmEnv,
							&post_info,
							(IGRchar *)reduice_geom,
							&newobjid ));
		}
	}


	wrapup :
		if( reduice_geom ) BSfreecv( &bsRC, reduice_geom ) ;

		if( redTolerance ){
			BSchangepar( &bsRC, BSTOLCHRDHT, savTolerance );
		}

		*msg = MSSUCC ;
		End 
		return OM_S_SUCCESS ;

} /* VD_drwCvApplyDataReduction */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

