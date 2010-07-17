/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdio.h>
#include "OMmacros.h"
#include "msmacros.h"
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
#include "vsgrenvproto.h"

extern OMuword	OPP_EMSsubbs_class_id ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSisSupportOfBeam_PFAH( surface, args )

struct GRobj_env	*surface ;
VSfenceArgs		*args ; {

	/*
	 *  Checks that a surface carries one or more beams.
	 */

	int	isSupport ;
			
	/*
	 * Reject non-EMSsubbs because fence locate accepts them even if not
	 * requested ...
	 */
	 
	if( vs$is_ancestry_valid(	object	= &surface->_grid,
					classid	= OPP_EMSsubbs_class_id ) ) {
		
		long		sts,
				msg ;
		struct  GRid    as_grid ;
		int             count ;

		/*
		 * Get associative header if any, otherwise put one.
		 */
		as$make_source(	go_grid		= surface->_grid,
				mod_env		= &surface->mod_env,
				as_os		= surface->_osnum,
				as_grid		= &as_grid ) ;

		/*
		 * See if there is a beam among children.
		 */
		sts = VSgetElementsOnSupport( &msg, &as_grid, VS_m_SRC_BEAM,
						FALSE, &count, NULL ) ;

		isSupport = ( sts & 1 & msg ) && count ;
	} else {
		isSupport = FALSE ;
	}

	return isSupport ;

} /* VSisSupportOfBeam_PFAH */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSisSupportOfStiffener_PFAH( plate, args )

struct GRobj_env	*plate ;
VSfenceArgs		*args ; {

	/*
	 *  Checks that a plate carries one or more stiffeners.
	 */

	long		sts,
			msg ;
	unsigned long	type ;
	int		count,
			isSupport ;
			
	/*
	 * Is it really a plate.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
			senderid= NULL_OBJID,
			targetid= plate->_objid,
			targetos= plate->_osnum ) ;
	if( !( ( sts & 1 & msg ) && ( type & VS_m_PLATE ) ) ) {
		isSupport = FALSE ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetSupportedElements(	
						&msg, FALSE, &count, NULL ),
			senderid= NULL_OBJID,
			targetid= plate->_objid,
			targetos= plate->_osnum ) ;
	if ( (sts & 1 & msg ) && count )
		isSupport = count; 
	else  
		isSupport = FALSE ;

	wrapup :
		return isSupport ;

} /* VSisSupportOfStiffener_PFAH */
/*----------------------------------------------------------------------------*/
int VSisSupportOfBeam_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Remove the object not support of beam from the locate stack.
	 */
	 
	long			sts ;
	struct GRobj_env	support ;
			
	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		return sts ;
	}

	support._grid 	= entry->located_obj ;
	support.mod_env	= entry->module_info ;
	
	sts = VSisSupportOfBeam_PFAH( &support, (VSfenceArgs *) NULL ) ;
	
	if( !sts && LCargs->rejectSts != MS_NO_MSG ) {
		ex$message( msgnumb	  = LCargs->rejectSts,
			    field	  = ERROR_FIELD,
			    justification = CENTER_JUS ) ;
		VS_Wait_timer( 40 ) ;
	}
	sts = sts ? LCptlocact( (char *) LCargs->stack, entry, args, action )
		  : LC_RELOCATE ;

	return sts ;
			
} /* VSisSupportOfBeam_LCAH */
/*----------------------------------------------------------------------------*/
int VSisSupportOfStiffener_LCAH( LCargs, entry, args, action )

VSlocateArgs		*LCargs ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ;
enum GRlocate_action	*action ; {

	/*
	 * Remove the object not support of stiffener from the locate stack.
	 */
	 
	long			sts ;
	struct GRobj_env	support ;
			
	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCargs->stack, entry, args, action );
		return sts ;
	}

	support._grid 	= entry->located_obj ;
	support.mod_env	= entry->module_info ;
	
	sts = VSisSupportOfStiffener_PFAH( &support, (VSfenceArgs *) NULL ) ;
	
	if( !sts && LCargs->rejectSts != MS_NO_MSG ) {
		ex$message( msgnumb	  = LCargs->rejectSts,
			    field	  = ERROR_FIELD,
			    justification = CENTER_JUS ) ;
		VS_Wait_timer( 40 ) ;
	} else {
		IGRchar	mesg[40];
		sprintf (mesg,"%d Stiffeners on plate",sts);
		ex$message( field         = ERROR_FIELD,
                            justification = CENTER_JUS,
			    in_buff	  = mesg );
		VS_Wait_timer( 60 ) ;
	}
	sts = sts ? LCptlocact( (char *) LCargs->stack, entry, args, action )
		  : LC_RELOCATE ;

	return sts ;

} /* VSisSupportOfStiffener_LCAH */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
