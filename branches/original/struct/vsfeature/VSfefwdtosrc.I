/* $Id: VSfefwdtosrc.I,v 1.1.1.1 2001/01/04 21:10:36 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	source_directory_filename
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfefwdtosrc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/01/06  10:26:22  pinnacle
# Replaced: vsfeature/VSfefwdtosrc.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/06/98	suresh		added header 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSsendToEveryoneUp(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) {

	long			sts,		/* OM return code	*/
				notUsed ;	/* Self-explanatory	*/

	*msg = MSFAIL ;

	sts = om$send( msg = Message, mode = deliver, targetid = my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message VScpx.VSalways_TRUE(),
			targetid= my_id ) ;
	if( sts == OM_I_STOP_SENDING ) {
		/* It is the top of the history:  we are done */
		*msg	= MSSUCC ; sts	= OM_S_SUCCESS ; goto wrapup ;
	}

	/*
	 * Traverse the graph up through all the consumed parts till you
	 * find a source part, sending message to everybody up.
	 */
	sts = om$send(	msg 	= message NDmacro.ACbubble_up(
						&notUsed,
						"",
						VS_K_ConsumedIx,
						message VScpx.VSalways_TRUE(),
						Message,
						deliver ),
			targetid= my_id ) ;
	*msg = MSSUCC ;

	wrapup :
		 return sts ;

} /* method VSsendToEveryoneUp */
/*----------------------------------------------------------------------------*/
method VSforwardToSource(	long			*msg ;
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
	*msg = MSSUCC ;

	return sts ;

} /* method VSforwardToSource */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
