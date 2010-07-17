/* $Id: VSsxgetexcv.I,v 1.2 2001/08/17 21:59:09 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSsxgetexcv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsxgetexcv.I,v $
 *      Revision 1.2  2001/08/17 21:59:09  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/01  14:58:34  pinnacle
# TR179701791
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTIO
 * 09/26/97  ah      added header
 * 09/30/97  ah      TR179701791 Don't allocate 0 bytes
 * 03/01/98  ah      TR179701791 Final Checkin
 *
 ***************************************************************************/

class implementation VSshellExp ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"

extern OMuword	OPP_VSexpandedCv_class_id ;



/*----------------------------------------------------------------------------*/
method VSget_expanded_curves( long		*msg ;
			      struct GRmd_env	*myEnv ;
			      int		*count ;
			      struct GRobj_env	*list[] )
{
	long			sts ;		/* OM return code.	      */
	int			i,		/* Loop index.		      */
				nbChild ;	/* Number of childrens.       */
	struct GRid		*children,	/* List of childrens.	      */
				moi ;		/* Myself.		      */

	SetProc( VSshellExp_VSget_expanded_curves ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "VSget_expanded_curves" //, argfmt = "", args = ``
        );

	*count = 0 ;
	if( list ) *list = NULL ;

	nbChild = 0;
	children = NULL ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	/*
	 * Get my childrens.
	 */
	sts = VSgetChildrenGoThruPretends( msg,
					   &moi,
					   &nbChild,
					   &children ) ;

	__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;

	/*
	 * Find the children expanded curves attached to myself.
	 */
	if( list && !( *list = _MALLOC( nbChild + 1, struct GRobj_env ) ) )
		vs$mem_fail() ;

	for( i=0; i<nbChild; i++ ) {
#ifdef vsDEBUG
		printf( "\tChildren #%d", i ) ;
		ShowObj( children +i ) ;
#endif

		if( !vs$is_ancestry_valid( object  = children +i,
					   classid = OPP_VSexpandedCv_class_id))
			continue ;

		__DBGpr_com( "It's an expanded curve" ) ;

		if( list ) {

			sts = VSgetVirtualInfo( msg,
						children +i,
						&(*list)[*count].mod_env,
						&(*list)[*count]._grid ) ;

			__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

			VSmulmx( myEnv->_MATRIX,
				 (*list)[*count]._matrix,
				 (*list)[*count]._matrix,
				 &(*list)[*count]._matrix_type ) ;
		}

		(*count)++ ;
	}

	/*
	 * Resize output list.
	 */
	if( list		&&
	    *count != nbChild	&&
	    !( *list = _REALLOC( *list, *count + 1, struct GRobj_env ) ) )
		vs$mem_fail() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( list ) {
				_FREE( *list ) ;
				*list = NULL ;
			}
			*count = 0 ;
		}

		_FREE( children ) ;

        __exitMethod ( name = "VSget_expanded_curves", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSget_expanded_curves */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;












