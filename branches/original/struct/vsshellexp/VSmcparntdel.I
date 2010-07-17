/* $Id: VSmcparntdel.I,v 1.2 2001/08/17 21:58:35 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSmcparntdel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmcparntdel.I,v $
 *      Revision 1.2  2001/08/17 21:58:35  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/07  13:59:10  pinnacle
# EMSmacros.h renamed to emsmacros.h
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      10/07/97        ah              added header
 *      10/07/97        ah              EMSmacros.h renamed to emsmacros.h
 ***************************************************************************/

class implementation VSmergeExpCv ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
#include "EMSmacros.h"
*/
#include "emsmacros.h"

#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

/*----------------------------------------------------------------------------*/
method NDparent_deleted( long			*msg ;
			 int			count_deleted ;
			 struct GRid		list_deleted[] ;
			 struct GRid		*new_obj ;
			 struct GRmd_env	*md_env )
{
	long			sts ;	  /* OM return code.		      */
	int			i,	  /* Loop index.		      */
				count ;   /* Count of my parents.	      */
	struct GRid		mergeSh ; /* My merged shell expansion parent.*/

	SetProc( VSmergeExpCv_NDparent_deleted ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "NDparent_deleted" //, argfmt = "", args = ``
        );

	/*
	 * If my merged shell expansion parent #0 is being deleted then delete
	 * myself, otherwise foward message to my parent class.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&mergeSh,
								1,
								NULL,
								0,
								0,
								&count ),
		       targetid = my_id ) ;

	*msg = sts & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

	__DBGpr_obj( "My merged shell expansion parent", mergeSh ) ;

	for( i=0; i<count_deleted; i++ ) {
		__DBGpr_obj( "Parent deleted", list_deleted[i] ) ;
		if( IF_EQ_GRID( list_deleted[i], mergeSh ) ) break ;
	}

	if( i < count_deleted ) {
		/*
		 * My merged shell expansion is being deleted, so delete
		 * myself.
		 */
		__DBGpr_com( "Delete myself" ) ;

		sts = vs$bulk_display( dpmode = GRbehe,
				       objids = &my_id,
				       theEnv = md_env ) ;

		*msg = sts & 1 ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "vs$bulk_display", wrapup ) ;

		sts = om$send( msg	= message GRgraphics.GRdelete( msg,
								       md_env ),
			       targetid = my_id ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup ) ;

	} else {
		/*
		 * An expanded curve parent is being deleted, so forward message
		 * to my parent class to do a NDmove_to_root.
		 */
		__DBGpr_com( "Do nothing" ) ;

		sts = om$send( msg	= message VSexpandedCv.NDparent_deleted(
								  msg,
								  count_deleted,
								  list_deleted,
								  new_obj,
								  md_env ),
			       mode	= OM_e_wrt_message,
			       targetid = my_id ) ;

		__CheckRC( sts, *msg, "VSexpandedCv.NDparent_deleted", wrapup );
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :

        __exitMethod ( name = "NDparent_deleted", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End
		return sts ;

} /* NDparent_deleted */
/*----------------------------------------------------------------------------*/

end implementation VSmergeExpCv ;
