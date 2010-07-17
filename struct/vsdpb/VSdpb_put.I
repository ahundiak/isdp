/* $Id */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsdpb/VSdpb_put.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdpb_put.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/19  20:33:36  pinnacle
# tr179900100
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/99  ah      TR179900100 Core dump if plate has lost it's parents
 *                   Protect against NULL data being passed
 ***************************************************************************/

class implementation VSdpb ;

#include <string.h>
#include "OMerrordef.h"		/* For OM_S_SUCCESS	*/
#include "msdef.h"		/* For MS...		*/
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	put(	long		*msg ;
		enum VSdpb_parm	type ;
		char		*pm ) {

	union any {
		double			*d ;
		int			*i ;
		char			*s ;
		struct VSdpb_form_pos	*f ;
		VSweldAttr		*w ;
	} val ;
	unsigned gotmem = TRUE ;

#omdef	FILL_ARRAY( f )
	( om$vla_set_dimension(	varray	= me->f,
				size	= 1 + strlen( val.s ) ) & 1 ) ?
		(int) strcpy( me->f, val.s )
	:	( gotmem = FALSE )
#endomdef

	/* ------------------------------------------
	 * TR179900100 Should not happen but does
	 */
	if (pm == NULL) {
	    
	  *msg = MSINARG ; 
	  return OM_W_ABORT ;
	}
	
	val.s = pm ;
	*msg = MSSUCC ;

	switch( type ) {
/*
 * Beams
 */
	case VS_e_dpb_B_x_offset	:
			me->B_x_offset			= *val.d ; break ;
	case VS_e_dpb_B_y_offset	:
			me->B_y_offset			= *val.d ; break ;
	case VS_e_dpb_B_rotation	:
			me->B_rotation			= *val.d ; break ;
	case VS_e_dpb_B_symmetry	:
			me->flags.B_symmetry		= *val.i ; break ;
	case VS_e_dpb_B_cardinal_point	:
			me->flags.B_cardinal_point	= *val.i ; break ;
	case VS_e_dpb_B_material: FILL_ARRAY( f = B_material )	; break ;
	case VS_e_dpb_B_grade	: FILL_ARRAY( f = B_grade )	; break ;
	case VS_e_dpb_B_type	: FILL_ARRAY( f = B_type )	; break ;
	case VS_e_dpb_B_shape	: FILL_ARRAY( f = B_shape )	; break ;
	case VS_e_dpb_B_stock	: FILL_ARRAY( f = B_stock )	; break ;
	case VS_e_dpb_B_source	: FILL_ARRAY( f = B_source )	; break ;
	case VS_e_dpb_B_notes	: FILL_ARRAY( f = B_notes )	; break ;
	case VS_e_dpb_B_name_pattern :
				  FILL_ARRAY( f = B_name_pattern ) ;
				  break ;
	case VS_e_dpb_B_form	: me->B_form = *val.f		; break ;

/*
 * Plates.
 */
	case VS_e_dpb_P_thickness	:
			me->P_thickness			= *val.d ; break ;
	case VS_e_dpb_P_cut_off		:
			me->P_cut_off			= *val.d ; break ;
	case VS_e_dpb_P_offset		:
			me->P_offset			= *val.d ; break ;
	case VS_e_dpb_P_orientation	:
			me->flags.P_orientation		= *val.i ; break ;
	case VS_e_dpb_P_thkname	: FILL_ARRAY( f = P_thkname )	; break ;
	case VS_e_dpb_P_material: FILL_ARRAY( f = P_material )	; break ;
	case VS_e_dpb_P_grade	: FILL_ARRAY( f = P_grade )	; break ;
	case VS_e_dpb_P_type	: FILL_ARRAY( f = P_type )	; break ;
	case VS_e_dpb_P_stock	: FILL_ARRAY( f = P_stock )	; break ;
	case VS_e_dpb_P_source	: FILL_ARRAY( f = P_source )	; break ;
	case VS_e_dpb_P_notes	: FILL_ARRAY( f = P_notes )	; break ;
	case VS_e_dpb_P_name_pattern :
				  FILL_ARRAY( f = P_name_pattern ) ;
				  break ;
	case VS_e_dpb_P_form	: me->P_form = *val.f		; break ;
/*
 * Joints.
 */
	case VS_e_dpb_J_weldAttr	:
			me->J_weldAttr			= *val.w ; break ;
	case VS_e_dpb_J_Allowance	:
			me->J_allowance			= *val.d ; break ;
/*
 * Miscellanious.
 */
	case VS_e_dpb_mass_props_toggle	:
			me->flags.massp_toggle	= *val.i	; break ;
	case VS_e_dpb_beam_arrow_size	:
			me->B_arw_size		= *val.d	; break ;
	case VS_e_dpb_fireproofing_thk	:
			me->FireProofingThk	= *val.d	; break ;
	case VS_e_dpb_apprv_status	:
			FILL_ARRAY( f = ApprovalSts )		; break ;
	case VS_e_dpb_const_status	:
			FILL_ARRAY( f = ConstructionSts )	; break ;

	default :
			*msg = MSINARG ; return OM_W_ABORT ;
	}
	if( gotmem ) {
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;
	} else {
		*msg = MSFAIL ;
		return OM_E_NODYNMEM ;
	}

} /* method put */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;






