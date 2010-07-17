/* $Id: VSfefwd2src.I,v 1.1.1.1 2001/01/04 21:10:36 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsfeature/VSfefwd2src.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfefwd2src.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/01/07  08:35:48  pinnacle
# Replaced: vsfeature/VSfefwd2src.I for:  by svkadamb for struct
#
# Revision 1.1  1998/01/07  08:03:22  pinnacle
# Created: vsfeature/VSfefwd2src.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation . This forward to source will 
					also verify for the correct return code.
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSfwdToSource(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts,		/* OM return code	*/
				notUsed ;

	sts = om$send(	msg 	= message NDmacro.ACbubble_up(
					&notUsed,
					"",
					VS_K_ConsumedIx,
					message VSpart.VSifSourceThenSend(
							VS_K_READ_OMmsg ),
					Message,
					deliver ),
			targetid= my_id ) ;

	*msg = ( sts & *msg & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* method VSfwdToSource */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
