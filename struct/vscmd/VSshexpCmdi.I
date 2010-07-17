/*
	I/STRUCT
*/
class implementation VSshexpCmd ;

#include <stdio.h>
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe

/*
 * Form gadgets.
 */
#define VS_K_fm_SHELL		16
#define VS_K_fm_REFERENCE	44
#define VS_K_fm_START		45
#define VS_K_fm_END		46
#define VS_K_fm_REFERENCE_DEF	49
#define VS_K_fm_START_DEF	47
#define VS_K_fm_END_DEF 	48
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	char	*form = me->forms[0].form_ptr ;

	me->suppressHilite = TRUE ;

	FIg_erase(   form, VS_K_fm_REFERENCE_DEF ) ;
	FIg_display( form, VS_K_fm_REFERENCE	 ) ;
	FIg_erase(   form, VS_K_fm_START_DEF	 ) ;
	FIg_display( form, VS_K_fm_START	 ) ;
	FIg_erase(   form, VS_K_fm_END_DEF	 ) ;
	FIg_display( form, VS_K_fm_END		 ) ;

	*sts = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* init_cmd */
/*----------------------------------------------------------------------------*/
method discard_start_plane( int *sts ) {

	om$send( msg	  = message VSshexpCmd.rmLastLocObjs( me->oprtrCount ),
		 targetid = my_id ) ;

	me->oprtrCount-- ;

	*sts = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* discard_start_plane */
/*----------------------------------------------------------------------------*/
method hilite_gadget( int state ) {

	char	*form		= me->forms[0].form_ptr ;
	int	gadget_label	= -1,
		default_label	= -1 ;

	/*
	 * Unhilite all gadgets of form.
	 */
	FIg_unhilite( form, VS_K_fm_SHELL	) ;
	FIg_unhilite( form, VS_K_fm_REFERENCE	) ;
	FIg_unhilite( form, VS_K_fm_START	) ;
	FIg_unhilite( form, VS_K_fm_END 	) ;

	/*
	 * Erase default gadget, display and hilite corresponding gadget
	 * of state we are.
	 */
	switch( state ) {
		case 0 : gadget_label  = VS_K_fm_SHELL ;
			 break ;
		case 1 : gadget_label  = VS_K_fm_REFERENCE ;
			 default_label = VS_K_fm_REFERENCE_DEF ;
			 break ;
		case 2 : gadget_label  = VS_K_fm_START ;
			 default_label = VS_K_fm_START_DEF ;
			 break ;
		case 3 : gadget_label  = VS_K_fm_END ;
			 default_label = VS_K_fm_END_DEF ;
			 break ;
	}

	if( default_label != -1 ) FIg_erase( form, default_label ) ;

	if( gadget_label != -1 ) {
		FIg_display( form, gadget_label ) ;
		FIg_hilite(  form, gadget_label ) ;
	}

	return OM_S_SUCCESS ;

} /* method hilite_gadget */
/*----------------------------------------------------------------------------*/
method display_default_gadget( int state ) {

	char	*form = me->forms[0].form_ptr ;

	/*
	 * Display default gadget(s) with respect to state we are.
	 */
	switch( state ) {
		case 1 : FIg_erase(   form, VS_K_fm_REFERENCE	  ) ;
			 FIg_display( form, VS_K_fm_REFERENCE_DEF ) ;
			 break ;
		case 2 : FIg_erase(   form, VS_K_fm_START	 ) ;
			 FIg_display( form, VS_K_fm_START_DEF	 ) ;
			 FIg_erase(   form, VS_K_fm_END		 ) ;
			 FIg_display( form, VS_K_fm_END_DEF	 ) ;
			 break ;
	}

	return OM_S_SUCCESS ;

} /* method display_default_gadget */
/*----------------------------------------------------------------------------*/
method unhilite_end_gadget( int *sts ) {

	FIg_unhilite( me->forms[0].form_ptr, VS_K_fm_END ) ;

	*sts = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* unhilite_end_gadget */
/*----------------------------------------------------------------------------*/

end implementation VSshexpCmd ;
