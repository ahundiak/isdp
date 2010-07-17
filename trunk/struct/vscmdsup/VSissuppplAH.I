/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "vscmd.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "LCptlocact.h"
#include "vsacthrproto.h"
#include "vselmsonsupp.h"

extern OMuword	OPP_EMSsubbs_class_id ;
/*----------------------------------------------------------------------------*/
int VSisSupportOfPlate( msg, surface )

long			*msg ;
struct GRobj_env	*surface ; {

	/*
	 *  Checks that a surface does not already carry a plate.
	 */

	int             isSupport ;

	*msg = MSSUCC ; isSupport = FALSE ;

	/*
	 * Reject non-EMSsubbs because fence locate accepts them even if not
	 * requested ...
	 */
	if( vs$is_ancestry_valid(	object	= &surface->_grid,
					classid	= OPP_EMSsubbs_class_id ) ) {
		long		sts ;
		struct  GRid    as_grid ;
		int             count ;
		/*
		 * Get associative header if any.
		 */
		as$make_source(	go_grid		= surface->_grid,
				mod_env		= &surface->mod_env,
				as_os		= surface->_osnum,
				as_grid		= &as_grid ) ;

		if( IF_NULL_OBJID( as_grid.objid ) ) {
			isSupport = FALSE ; *msg = MSSUCC ;
		} else {
			/*
			 * See if there is a plate among children.
			 */
			 /*
			  * To solve TR 179800170  3rd argument ichanged from
			  * VS_m_PLATE VS_m_SRC_PLATE 
			  */
			sts = VSgetElementsOnSupport( msg, &as_grid, VS_m_SRC_PLATE,
							FALSE, &count, NULL ) ;

			isSupport = ( sts & 1 & *msg ) && count ;
			__DBGpr_int(" isSupport   ",isSupport);
			__DBGpr_int("  count  ", count);
			__DBGpr_int(" (sts & 1 *msg) ", (sts & 1 & *msg));
		}
	} else {
		*msg = MSINARG ;
	}

	return isSupport ;

} /* VSisSupportOfPlate */
/*----------------------------------------------------------------------------*/
int VSnotSupportOfPlate_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Remove the surfaces which already bears a plate from the locate
	 * stack.
	 */
	long			sts,	/* OM return code		*/
				msg ;	/* Completion code		*/
	struct GRobj_env	supp ;
	SetProc(VSnotSupportOfPlate_LCAH); Begin
	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		goto wrapup ;
	}

	supp._grid 	= entry->located_obj ;
	supp.mod_env	= entry->module_info ;

	sts = VSisSupportOfPlate( &msg, &supp ) ;
	__DBGpr_int("sts", sts);
	__DBGpr_int("msg", msg);
	/*
	 * If failure say you don't want locate to take this one.
	 */
	if( !( msg & 1 ) ) sts = TRUE ;

	__DBGpr_int("sts", sts);
	__DBGpr_obj("supp._grid",supp._grid);
	 sts = !sts ? LCptlocact( (char *) LCargs->stack, entry, args, action )
 	 		: LC_RELOCATE ;

	wrapup :
		End return sts ;
			
} /* VSnotSupportOfPlate_LCAH */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSnotSupportOfPlate_PFAH( object, args )

struct GRobj_env	*object ;
VSfenceArgs		*args ; {
	
	long			sts,
				msg ;
	SetProc(VSnotSupportOfPlate_PFAH); Begin	
	sts = VSisSupportOfPlate( &msg, object ) ;
	
	if( !( msg & 1 ) ) sts = TRUE ;
	
	sts = !sts ? TRUE : FALSE ;
	
	End return sts ;
	
} /* VSnotSupportOfPlate_PFAH */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
