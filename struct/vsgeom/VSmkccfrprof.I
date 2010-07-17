/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSmkccfrprof.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmkccfrprof.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1995/11/15  05:40:56  pinnacle
# Created: VSmkccfrprof.I by msbraju for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/15/95        Suresh          creation date
 *
 ***************************************************************************/

class implementation GRcompcurve ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "bserr.h"

extern OMuword	OPP_GRcompcurve_class_id ;
/*----------------------------------------------------------------------------*/
long VSmakeCompCurve2( msg, cst, cvList, cvCount, cvEnv, compEnv, compCv )

long		*msg ;
struct GRvg_construct	*cst;
struct GRid	cvList[] ;
int		cvCount ;
struct GRmd_env *cvEnv ;
struct GRmd_env *compEnv ;
struct GRid	*compCv ; {

	/*
	 * This function is interfaced by macro 'vs$makeCompCurve'.
	 */

	long			sts ;
	int			i ;
	struct GRlc_info	*entries = NULL ;

	compCv->osnum = compEnv->_MD_OS ;
	compCv->objid = NULL_OBJID ;


	/*
	 * Create entry for SortAndBuildCrv
	 */
	if( !( entries = _MALLOC( cvCount, struct GRlc_info ) ) ) vs$mem_fail();
	for( i=0; i<cvCount; i++ ) {
		entries[i].located_obj = cvList[i] ;
		entries[i].module_info = *cvEnv ;
	}

	/*
	 * Construct composite curve.
	 */

	/*
	 * GRcompcurve.EMmakecomp fails if two adjacent curves don't
         * have the same end points. Thus, we use the function
         * SortAndBuildCrv() which do the same job but extend the curve
         * if needed.
	 */

	{
        	struct GRobj_env        *Crvs = NULL ;
	        struct GRid             *ConCrvs = NULL ;
        	int                     NumConCrvs ;

	        if( !( Crvs = _MALLOC( cvCount, struct GRobj_env ) ) ) 
			vs$mem_fail() ;

        	for( i=0; i<cvCount; i++ ) {
	                Crvs[i].obj_id  = entries[i].located_obj ;
                	Crvs[i].mod_env = entries[i].module_info ;
        	}

	        SortAndBuildCrv( 	Crvs, 
					cvCount, 
					3, 
					cst, 
					&ConCrvs, 
					&NumConCrvs, 
					msg ) ;
        	_FREE( Crvs ) ;

        	if( *msg == BSFAIL ) {
                	__DBGpr_com( "SortAndBuildCrv FAILED" ) ;
                	vs$error( msgval = EMS_E_BSerror ) ;
        	} else {
                	if( NumConCrvs != 1 ) {
                        	__DBGpr_com( "Too many composite curves !!!" ) ;
 		           	vs$error() ;
                	}
        	}

        	*compCv = ConCrvs[0] ;

        	_FREE( ConCrvs ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) )
			if( !IF_NULL_OBJID( compCv->objid ) )
				vs$bulk_delete( count	= 1,
						grids	= compCv,
						theEnv	= compEnv ) ;

		_FREE( entries ) ;

		return sts ;

} /* VSmakeCompCurve2 */
/*----------------------------------------------------------------------------*/

end implementation GRcompcurve ;
