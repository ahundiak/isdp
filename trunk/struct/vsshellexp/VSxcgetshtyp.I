/* $Id: VSxcgetshtyp.I,v 1.2 2001/08/17 21:59:27 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSxcgetshtyp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxcgetshtyp.I,v $
 *      Revision 1.2  2001/08/17 21:59:27  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:01  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/07  13:58:52  pinnacle
# EMSmacros.h renamed to emsmacros.h
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      10/07/97        ah              added header
 *      10/07/97        ah              EMSmacros.h renamed to emsmacros.h
 ***************************************************************************/

class implementation VSexpandedCv ;

#include <stdio.h>
#include "OMmacros.h"
/*
#include "EMSmacros.h"
*/
#include "emsmacros.h"

#include "vsshexpdef.h"
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

extern OMuword	OPP_VSmergeShExp_class_id ;

from VSmergeShExp	import VSget_shell_exp_parents ;

/*----------------------------------------------------------------------------*/
method VSget_shell_expansion_type( long 		*msg ;
				   enum VSshell_type	*type )
{
	long			sts ;		/* OM completion code.	      */
	int			rc,		/* Return code. 	      */
				i,		/* Loop index.		      */
				nbChild ;	/* Number of childrens.       */
	struct GRid		shExp,		/* My shell expansion parent. */
				*childrens ;	/* List of childrens.	      */

	SetProc( VSexpandedCv_VSget_shell_expansion_type ) ; Begin ;

        __enterMethod ( name = "VSget_shell_expansion_type" //, argfmt = "", args = ``
        );

	__DBGpr_me() ;

	*type = VSoriginal ;

	childrens = NULL ;

	/*
	 * Get my shell expansion parent.
	 */
	sts = om$send( msg	= message VSexpandedCv.ACfind_temp_obj(
							  &rc,
							  VS_K_sxShellExpansion,
							  &shExp ),
		       targetid = my_id ) ;

	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "VSexpandedCv.ACfind_temp_obj", wrapup ) ;

	__DBGpr_obj( "Shell expansion parent", shExp ) ;

	/*
	 * Get all childrens of shell expansion and see if there is a merged
	 * shell expansion.
	 */
	sts = VSgetChildrenGoThruPretends( msg,
					   &shExp,
					   &nbChild,
					   &childrens ) ;

	__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;

	__DBGpr_int( "Number of childrens of shell expansion", nbChild ) ;

	for( i=0; i<nbChild; i++ ) {
#ifdef vsDEBUG
		printf( "\tChildren #%d", i ) ;
		ShowObj( childrens + i ) ;
#endif

		if( vs$is_ancestry_valid( object  = childrens +i,
					  classid = OPP_VSmergeShExp_class_id ))
			break ;
	}

	if( i < nbChild ) {
		struct GRobj_env	shParents[2] ;
		struct GRmd_env 	mergedShEnv ;

		__DBGpr_com( "Children is a merged shell expansion" ) ;

		/*
		 * Get parents shell expansion of the merged shell expansion.
		 */
		sts = VSgetVirtualInfo( msg,
					childrens +i,
					&mergedShEnv,
					NULL ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		sts = om$send( msg	=
				   message VSmergeShExp.VSget_shell_exp_parents(
								 msg,
								 &mergedShEnv,
								 shParents,
								 shParents +1 ),
			       targetid = childrens[i].objid,
			       targetos = childrens[i].osnum ) ;

		__CheckRC( sts, *msg, "VSmergeShExp.VSget_shell_exp_parents",
			   wrapup ) ;

		/*
		 * See type of shell expansion.
		 */
		if( IF_EQ_GRID( shExp, shParents[0]._grid ) ) {
			__DBGpr_com( "Shell expansion is a FROM" ) ;
			*type = VSfrom ;
		} else {
			if( IF_EQ_GRID( shExp, shParents[1]._grid ) ) {
				__DBGpr_com( "Shell expansion is a TO" ) ;
				*type = VSto ;
			} else {
				__DBGpr_com( "UNKNOWN shell type" ) ;
				vs$failure() ;
			}
		}
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( childrens ) ;

        __exitMethod ( name = "VSget_shell_expansion_type", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSget_shell_expansion_type */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
