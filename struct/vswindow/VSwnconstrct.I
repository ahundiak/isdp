/*
	I/STRUCT
*/
class implementation IGEwindow ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"

extern OMuword	OPP_VSsomeObjcVw_class_id ;

from IGEgragad		import	gragad_cons ;
/*----------------------------------------------------------------------------*/
long VScstSomeObjcVw( msg, windowName, someObjcWin, someObjcGad ) 

long		*msg ;
char		*windowName ;
struct GRid	*someObjcWin ;
struct GRid	*someObjcGad ; {

	long		sts ;
	OM_S_OBJID	curModId,
			window,
			gragad ;
	OMuword		curModOs ;
	int		y_ht ;
	double		mv_factor ;
#define MOVE_WIN 55

	someObjcWin->objid	= someObjcGad->objid = gragad = window
				= NULL_OBJID ;

	ex$get_cur_mod( id = &curModId, osnum = &curModOs ) ;

	someObjcWin->osnum = someObjcGad->osnum = curModOs ;

	ige$inq_term_info( y_extent = &y_ht ) ;
        mv_factor = 1.0 * MOVE_WIN / y_ht ;

	*msg = om$construct(	classid	= OPP_VSsomeObjcVw_class_id,
				osnum	= curModOs,
				p_objid	= &gragad ) ;
	if( !(*msg & 1) ) goto wrapup ;

	sts = om$send(	msg	= message IGEgragad.gragad_cons(
						msg, windowName,
						0.0, 0.0, 1.0, 1.0 ),
			senderid= NULL_OBJID,
			targetid= gragad,
			targetos= curModOs ) ;
	if( !( sts & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; } ;

	ige$construct_win(	msg		= msg,
				win_class	= "GRwindow",
				win_objid	= &window,
				mod_id		= curModId,
				mod_osnum	= curModOs,
				name		= NULL,
				win_type	= BORDER,
				screen		= CURRENT_SCREEN,
				min_x		= 0.004222973,
				min_y		= 0.0848416 + mv_factor,
				max_x		= 0.4131,
				max_y		= 0.47512 + mv_factor ) ;
	if( !(*msg & 1) ) goto wrapup ;

	sts = om$send(	msg	= message IGEgadget.add_gadget(	msg,
								&gragad,
								1 ),
			senderid= NULL_OBJID,
			targetid= window,
			targetos= curModOs ) ;
	if( !( sts & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; } ;

	sts = om$send(	msg	= message IGEgadget.activate( msg, 0 ),
			senderid= NULL_OBJID,
			targetid= window,
			targetos= curModOs ) ;
	if( !( sts & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; } ;

	someObjcGad->objid	= gragad ;
	someObjcWin->objid	= window ;
	*msg			= MSSUCC ;
	sts			= OM_S_SUCCESS ;

	wrapup :

		if( !( *msg & 1 ) ) {
			if( !IF_NULL_OBJID( gragad ) ) {
				om$send(msg	= message Root.delete( 0 ),
					senderid= NULL_OBJID,
					targetid= gragad,
					targetos= curModOs ) ;
			}
			if( !IF_NULL_OBJID( window ) ) {
				om$send(msg	= message Root.delete( 0 ),
					senderid= NULL_OBJID,
					targetid= window,
					targetos= curModOs ) ;
			}
		}
		return *msg & 1 ;

} /* VScstSomeObjcVw */
/*----------------------------------------------------------------------------*/
int VSwnMakeName( modId, seed, wname )

struct GRid	*modId ;
char		*seed,
		*wname ; {

	long		msg ;
	int		i,
			total,
			count ;
	GRname		tst ;
	struct GRid	wn ;

	*wname = '\0' ;

	for( i = 0 ; i < 1000 ; i++ ) {

		sprintf( tst, "%s-%d", seed, i ) ;

		dp$get_gragad_id(	msg		= &msg,
					mod_GRid	= modId,
					name		= tst, 
					array_size	= 1,
					total_num	= &total,
					numberofids	= &count, 
					found_GRids	= &wn ) ;
		if( !total ) {
			strcpy( wname, tst ) ;
			break ;
		}
	}

	return *wname !='\0' ;

} /* VSwnMakeName */
/*----------------------------------------------------------------------------*/

end implementation IGEwindow ;

