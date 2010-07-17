/*
	I/STRUCT
*/
class implementation VSdpb ;

#include <stdio.h>		/* For "NULL"		*/
#include "OMerrordef.h"		/* For OM_S_SUCCESS	*/
#include "msdef.h"		/* For MS...		*/
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

#define VS_K_MAX_DPBSTRBUF_SIZE	81
static char VS_Gs_dpbStrBuf[VS_K_MAX_DPBSTRBUF_SIZE] ;
/*----------------------------------------------------------------------------*/
method	get(	long		*msg ;
		enum VSdpb_parm	type ;
		char		*pm ) {

	union any {
		double			*d ;
		int			*i ;
		char			*s,
					**ps ;
		struct VSdpb_form_pos	*f ;
		VSweldAttr		*w ;
		
	} val ;
	char		*frStr	= NULL ;
	int		frSiz	= 0 ;

#omdef TO_CPY( f )
	frSiz = om$dimension_of( varray = me->f ) ;
	frStr = me->f
#endomdef

	val.s = pm ;
	*msg = MSFAIL ;

	switch( type ) {
/*
 * Beams
 */
	case VS_e_dpb_B_x_offset : *val.d = me->B_x_offset	; break ;
	case VS_e_dpb_B_y_offset : *val.d = me->B_y_offset	; break ;
	case VS_e_dpb_B_rotation : *val.d = me->B_rotation	; break ;
	case VS_e_dpb_B_symmetry : *val.i = me->flags.B_symmetry; break ;
	case VS_e_dpb_B_cardinal_point :
				   *val.i = me->flags.B_cardinal_point ; break ;
	case VS_e_dpb_B_material: TO_CPY( f = B_material)	; break ;
	case VS_e_dpb_B_grade	: TO_CPY( f = B_grade )		; break ;
	case VS_e_dpb_B_type	: TO_CPY( f = B_type )		; break ;
	case VS_e_dpb_B_shape	: TO_CPY( f = B_shape )		; break ;
	case VS_e_dpb_B_stock	: TO_CPY( f = B_stock )		; break ;
	case VS_e_dpb_B_source	: TO_CPY( f = B_source )	; break ;
	case VS_e_dpb_B_notes	: TO_CPY( f = B_notes )		; break ;
	case VS_e_dpb_B_name_pattern :
				  TO_CPY( f = B_name_pattern )	; break ;
	case VS_e_dpb_B_form	: *val.f = me->B_form		; break ;

/*
 * Plates.
 */
	case VS_e_dpb_P_thickness   : *val.d = me->P_thickness	; break ;
	case VS_e_dpb_P_cut_off	    : *val.d = me->P_cut_off	; break ;
	case VS_e_dpb_P_offset	    : *val.d = me->P_offset	; break ;
	case VS_e_dpb_P_orientation : *val.i = me->flags.P_orientation ; break ;
	case VS_e_dpb_P_thkname	    : TO_CPY( f = P_thkname )	; break ;
	case VS_e_dpb_P_material    : TO_CPY( f = P_material)	; break ;
	case VS_e_dpb_P_grade	    : TO_CPY( f = P_grade )	; break ;
	case VS_e_dpb_P_type	    : TO_CPY( f = P_type )	; break ;
	case VS_e_dpb_P_stock	    : TO_CPY( f = P_stock )	; break ;
	case VS_e_dpb_P_source	    : TO_CPY( f = P_source )	; break ;
	case VS_e_dpb_P_notes	    : TO_CPY( f = P_notes )	; break ;
	case VS_e_dpb_P_name_pattern:
				     TO_CPY( f = P_name_pattern ); break ;
	case VS_e_dpb_P_form	: *val.f = me->P_form		; break ;
/*
 * Joints.
 */
	case VS_e_dpb_J_weldAttr  : *val.w = me->J_weldAttr	; break ;
	case VS_e_dpb_J_Allowance : *val.d = me->J_allowance	; break ;
/*
 * Miscellanious.
 */
	case VS_e_dpb_mass_props_toggle	:
			*val.i = me->flags.massp_toggle		; break ;
	case VS_e_dpb_beam_arrow_size	:
			*val.d = me->B_arw_size			; break ;
	case VS_e_dpb_fireproofing_thk	:
			*val.d = me->FireProofingThk		; break ;
	case VS_e_dpb_apprv_status	:
			TO_CPY( f = ApprovalSts )		; break ;
	case VS_e_dpb_const_status	:
			TO_CPY( f = ConstructionSts )		; break ;

	default :
			*msg = MSINARG		;
			return OM_W_ABORT	;
	}

	if( frStr ) {
		if( frStr ) {
			int	trunc ;
			*val.ps = VSstrncpy(	VS_Gs_dpbStrBuf,
						frStr,
						VS_K_MAX_DPBSTRBUF_SIZE,
						&trunc ) ;
		} else {
			VS_Gs_dpbStrBuf[0] = '\0' ;
			*val.ps = VS_Gs_dpbStrBuf ;
		}
	}

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method get */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;

