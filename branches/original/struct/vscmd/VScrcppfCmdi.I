/*
	I/STRUCT
*/
class implementation VScrcppfCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "OMmacros.h"
#include "COBmacros.h"
#include "acrepdef.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"
#include "vsxsfpmacros.h"
#include "vscppffmdef.h"
#include "vsiomacros.h"
#include "vsformmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"
#include "vsverifyval.h"

extern void	VSdelCmpProfile() ;
extern int	VSallPlatesStick() ;


#define SET_MESSAGE( fm, txt ) VSfi_msg( (fm), (txt) ) ; \
			       me->flag |= VS_K_message_set ;
#define SET_MSGKEY( fm, key ) VSfi_msgkey( (fm), (key) ) ; \
			       me->flag |= VS_K_message_set ;
#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'

/*----------------------------------------------------------------------------*/
method init_cmd( long *msg ) {

	int	i ;
	char	*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_init_cmd ); Begin

	/*
	 * Delete gadgets plate created.
	 */
	if( me->number_of_plates )
		for( i=0; i<me->number_of_plates; i++ ) {
			FIg_delete(   form, VS_K_cp_Dgn_Plate + i ) ;
			FIg_delete(   form, VS_K_cp_Dgn_Text  + i ) ;
			FIgrp_delete( form, VS_K_cp_Dgn_Plate + i ) ;
		}

	me->number_of_plates = 0 ;
	me->active_plate     = 0 ;
	me->profile_type[0]  = '\0' ;
	me->profile.objid    = NULL_OBJID ;

	me->flag &= ~( VS_K_exit_cmd		|
		       VS_K_restart_cmd 	|
		       VS_K_all_plates_stick	|
		       VS_K_offset_draw 	|
		       VS_K_locate_plate	) ;

	End
	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method get_nb_plates( long  *msg ) {

	char	*form = me->fm_ptr,
		buffer[MS_MAX_MSG_LENGTH] ;

	SetProc( VScrcppfCmd_get_nb_plates ); Begin

	/*
	 * Get number of plates.
	 */
	ex$message( msgnumb = VS_gI_BadNbPlates,
		    type    = "%d%d",
		    var     = `VS_K_MIN_XSPLATES,
			       VS_K_MAX_XSPLATES`,
		    buff    = buffer ) ;
	SET_MESSAGE( form, buffer ) ;

	VSfld_restart( form, VS_K_cp_Number_Of_Plates ) ;

	End
	return OM_S_SUCCESS ;

} /* method get_nb_plates */
/*----------------------------------------------------------------------------*/
method disable_form( int *sts ) {

	char	*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_disable_form ); Begin

	if( !form ) goto wrapup ;

	/*
	 * If we ask for accepting or rejecting profile constructed,
	 * just disable buttons 'accept', 'reject' and 'dismiss'.
	 */
	if( me->flag & (VS_K_exit_cmd | VS_K_restart_cmd) &&
	    me->flag & VS_K_command_stacked ) {
		vs$g_disable_gadgets( form = form,
				      list = `VS_K_cp_Accept_Profile,
					      VS_K_cp_Reject_Profile,
					      VS_K_cp_AR_Profile_Type,
					      VS_K_cp_AR_Material_Type,
					      VS_K_cp_AR_Plate_Type,
					      VS_K_cp_Dismiss` );
		goto wrapup ;
	}

	/*
	 * If command was stacked disable all gadgets on the form. Otherwise,
	 * we ask for number of plates, so disable some gadgets.
	 */
	vs$g_disable_gadgets( form = form,
			      list = `VS_K_cp_Dismiss_Execute,
				      VS_K_cp_Execute,
				      VS_K_cp_Revert,
				      VS_K_cp_Material_Type,
				      VS_K_cp_Plate_Type,
				      VS_K_cp_Mcf_Column_L,
				      VS_K_cp_Mcf_Column_R,
				      VS_K_cp_Stick,
				      VS_K_cp_Check,
				      VS_K_cp_Profile_Type` ) ;

	if( me->flag & VS_K_command_stacked ) {
		vs$g_disable_gadgets( form = form,
				      list = `VS_K_cp_Dismiss,
					      VS_K_cp_Message,
					      VS_K_cp_Number_Of_Plates` ) ;
	}

	/*
	 * Warning : if scroll bar isn't displayed when we disable it,
	 * a part of it will be displayed.
	 */
	if( me->number_of_plates > 2 ) FIg_disable( form, VS_K_cp_Scroll_Bar ) ;

	wrapup :
		End
		return OM_S_SUCCESS ;

} /* method disable_form */
/*----------------------------------------------------------------------------*/
method enable_form( int *sts ) {

	char	*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_enable_form ); Begin

	if( !form ) goto wrapup ;

	/*
	 * If we ask for accepting or rejecting profile constructed,
	 * enable 'accept', 'reject' and 'dismiss' buttons.
	 */
	if( me->flag & (VS_K_exit_cmd | VS_K_restart_cmd) &&
	    me->flag & VS_K_command_stacked ) {
		vs$g_enable_gadgets(  form = form,
				      list = `VS_K_cp_Accept_Profile,
					      VS_K_cp_Reject_Profile,
					      VS_K_cp_AR_Profile_Type,
					      VS_K_cp_AR_Material_Type,
					      VS_K_cp_AR_Plate_Type,
					      VS_K_cp_Dismiss` ) ;
		goto wrapup ;
	}

	/*
	 * If we know the number of plates, enable all gadgets on the form
	 * except gadget 'number of plates'. Otherwise enable some gadgets.
	 */
	if( me->number_of_plates ) {
		vs$g_enable_gadgets(  form = form,
				      list = `VS_K_cp_Dismiss_Execute,
					      VS_K_cp_Execute,
					      VS_K_cp_Revert,
					      VS_K_cp_Material_Type,
					      VS_K_cp_Plate_Type,
					      VS_K_cp_Mcf_Column_L,
					      VS_K_cp_Mcf_Column_R,
					      VS_K_cp_Check,
					      VS_K_cp_Profile_Type` ) ;

	}

	if( me->flag & VS_K_command_stacked ) {
		vs$g_enable_gadgets(  form = form,
				      list = `VS_K_cp_Dismiss,
					      VS_K_cp_Message` ) ;
	}

	if( me->flag & VS_K_command_stacked &&
	    !me->number_of_plates )
		FIg_enable( form, VS_K_cp_Number_Of_Plates ) ;

	/*
	 * Warning : if scroll bar isn't displayed when we enable it,
	 * a part of it will be displayed.
	 */
	if( me->number_of_plates > 2 ) FIg_enable( form, VS_K_cp_Scroll_Bar ) ;

	/*
	 * Enable 'stick' button if all plates isn't stick.
	 */
	if( me->number_of_plates > 1	&&
	    !(me->flag & VS_K_all_plates_stick) )
		FIg_enable( form, VS_K_cp_Stick ) ;

	/*
	 * Disable gadget offset if we have one plate. We disable here the
	 * gadget, because the gadget is inside the group VS_K_cp_Mcf_Column_L
	 * which was enabled before.
	 */
	if( me->number_of_plates == 1 ) FIg_disable( form, VS_K_cp_Offset_L ) ;

	wrapup :
		End
		return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method initForm( long *msg ) {

	int	rc,
		color ;
	double	width,
		height ;
	char	*form = me->fm_ptr ;

	extern int VScreatePlates() ;

	SetProc( VScrcppfCmd_initForm ); Begin

	*msg = VS_K_ACT_SUCCESS ;

	/*
	 * Set number of plates to scroll bar.
	 */
	if( me->number_of_plates > 2 ) {
		double	view ;

		FIg_set_high_value( form, VS_K_cp_Scroll_Bar,
				    (double) me->number_of_plates-2 ) ;
		view = 1. - (double) (me->number_of_plates-2) /
		       me->number_of_plates ;
		FIscrl_set_view( form, VS_K_cp_Scroll_Bar, view ) ;
		FIg_activate( form, VS_K_cp_Scroll_Bar ) ;
		FIg_display( form, VS_K_cp_Scroll_Bar ) ;
	}

	/*
	 * Display right column of pseudo multicolumn if we have more
	 * than one plate.
	 */
	if( me->number_of_plates > 1 )
		FIg_display( form, VS_K_cp_Mcf_Column_R ) ;

	/*
	 * Create plates using color of rectangle for erase color.
	 */
	FIg_get_on_color( form, VS_K_cp_Rectangle, &color ) ;

	rc = VScreatePlates( form, VS_K_cp_Dgn_Plate, VS_K_cp_Dgn_Text,
			     me->number_of_plates, color ) ;
	if( rc != FI_SUCCESS ) {
		*msg = VS_K_ABORT_CMD ;
		me->stskey = VS_gE_ErrEncCmdTrm ;
		goto wrapup ;
	}

	/*
	 * Compute scale of design.
	 */
	FIg_get_dsize( form, VS_K_cp_Dgn_Plate, &width, &height ) ;

	if( me->plates[0].Orientation == VS_K_HORIZONTAL )
		me->scale = width  / me->plates[0].whtVal ;
	else	me->scale = height / me->plates[0].whtVal ;

	/*
	 * Draw composite profile.
	 */
	om$send( msg	  = message VScrcppfCmd.draw_plates( msg ),
		 targetid = my_id ) ;

	wrapup :
		End
		return OM_S_SUCCESS ;

} /* method initForm */
/*----------------------------------------------------------------------------*/
method init_plates_definition( long *msg ) {

	int	i ;

	SetProc( VScrcppfCmd_init_plates_definition ); Begin

	/*
	 * Initialize structure for plate definitions.
	 */
	for( i=0; i<me->number_of_plates; i++ ) {
		me->plates[i].Orientation = VS_K_HORIZONTAL ;
		me->plates[i].thkVal	  = me->actPar ;
		me->plates[i].offVal	  = 0. ;
		me->plates[i].whtVal	  = 4 * me->actPar ;
		strcpy( me->plates[i].thkType, me->actPrt     ) ;
		strcpy( me->plates[i].ornType, me->ornList[0] ) ;

		me->connection[i].plate1  = VS_K_MAX_XSPLATES + 1 ;
		me->connection[i].side1   = VS_K_MAX_XSPLATES + 1 ;
		me->connection[i].plate2  = VS_K_MAX_XSPLATES + 1 ;
		me->connection[i].side2   = VS_K_MAX_XSPLATES + 1 ;
		me->connection[i].offset  = 0. ;
	}

	End
	return OM_S_SUCCESS ;

} /* method init_plates_definition */
/*----------------------------------------------------------------------------*/
method initial_form_notification(	int	form_label,
						gadget ;
					double	value ;
					char	*form ) {

	long	msg ;
	int	action = 0,
		active_plate ;

	extern void VSdisplayOffset() ;

	SetProc( VScrcppfCmd_initial_form_notification ); Begin

#define WHICH_PLATE_NUMBER( descr )\
	if( gadget == VS_K_cp_##descr##_L )\
		active_plate = me->active_plate ;\
	else	active_plate = me->active_plate+1 ;\
	__DBGpr_int( "plate number", active_plate ) ;

	switch( gadget ) {

		case VS_K_cp_Material_Type	:
			action = VS_m_mat ; break ;

		case VS_K_cp_Plate_Type 	:
			action = VS_m_fam ; break ;

		case VS_K_cp_Thickness_Type_L	:
			action = VS_m_thk_L ; break ;

		case VS_K_cp_Thickness_Type_R	:
			action = VS_m_thk_R ; break ;

		case VS_K_cp_Offset_L		:
		case VS_K_cp_Offset_R		:
			WHICH_PLATE_NUMBER( Offset ) ;

			/*
			 * Display offset on form if active plate is stick and
			 * have an offset not equal to 0.
			 */
			if( me->connection[active_plate].plate1
				!= (VS_K_MAX_XSPLATES + 1)	&&
			    me->connection[active_plate].plate2
				!= (VS_K_MAX_XSPLATES + 1)	&&
			    me->connection[active_plate].offset != 0. ) {
			       VSdisplayOffset(
					    form,
					    VS_K_cp_Dgn_Plate,
					    me->connection[active_plate].plate1,
					    me->connection[active_plate].side1,
					    me->connection[active_plate].plate2,
					    me->connection[active_plate].side2,
					    VS_K_cp_Rectangle,
					    me->connection[active_plate].offset,
					    VS_K_cp_Dgn_Offset ) ;
			       me->flag |= VS_K_offset_draw ;
			}
			break ;
	}
	if( action ) {
		om$send( msg	  = message VSfmcppfCmd.QueryRDB(
							&msg, action, TRUE ),
			 targetid = my_id ) ;
	}

	End
	return OM_S_SUCCESS ;

} /* method initial_form_notification */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg,
			QYmask ;
	int		i,
			response,
			sel_flag,
			r_pos,
			active_plate,
			DRAW = FALSE ;
	double		value ;
	char		buffer[MS_MAX_MSG_LENGTH],
			*text = NULL,
			*Unit ;


	SetProc( VScrcppfCmd_form_notification ); Begin

#define GET_FIELD_TEXT() VSfld_get_text( form_ptr, gadget_label )

#define FILL_ASCII_FIELD( text ) \
	FIfld_set_text( form_ptr, gadget_label, 0, 0, (text), FALSE )

#define QUERY_RDB( a, f ) \
	om$send( msg	  = message VSfmcppfCmd.QueryRDB( &msg, (a), (f) ), \
		 targetid = my_id )

#define SET_VALUE_UNIT( gadget, val ) {\
	vs$system_to_unit( msg	  = &msg,\
			   value  = (val),\
			   osnum  = me->cstEnv._MD_OS,\
			   p_unit = &Unit ) ;\
	FIfld_set_text( form_ptr, (gadget), 0, 0, Unit, FALSE ) ;\
	}

#define UPDATE_WIDTH_HEIGHT {\
	for( i=0; i<me->number_of_plates; i++ )\
		if( me->plates[i].thkVal >= me->plates[i].whtVal ) {\
			me->plates[i].whtVal = me->plates[i].thkVal *4 ;\
			if( i == me->active_plate )\
				SET_VALUE_UNIT( VS_K_cp_Thickness_Value_L,\
						me->plates[i].whtVal ) ;\
			if( i == me->active_plate +1 )\
				SET_VALUE_UNIT( VS_K_cp_Thickness_Value_R,\
						me->plates[i].whtVal ) ;\
		}\
	}

#define SET_PLATES_THK_TYPE {\
	for( i=0; i<me->number_of_plates; i++ ) {\
		STRNCPY( me->plates[i].thkType, me->actPrt ) ;\
		me->plates[i].thkVal = me->actPar ;\
	}\
	UPDATE_WIDTH_HEIGHT ;\
	}

#define WHICH_PLATE_NUMBER( descr )\
	if( gadget_label == VS_K_cp_##descr##_L )\
		active_plate = me->active_plate ;\
	else	active_plate = me->active_plate+1 ;\
	__DBGpr_int( "plate number", active_plate ) ;

#define FILL_THK_VALUE_FIELD( text )\
	if( gadget_label == VS_K_cp_Thickness_Type_L )\
		FIfld_set_text( form_ptr, VS_K_cp_Thickness_Value_L, 0, 0,\
				(text), FALSE ) ;\
	else	FIfld_set_text( form_ptr, VS_K_cp_Thickness_Value_R, 0, 0,\
				(text), FALSE ) ;


	/*
	 * Erase message or prompt field.
	 */
	if( me->flag & VS_K_message_set ) {
		VSfi_msg( form_ptr, "" ) ;
		me->flag &= ~VS_K_message_set ;
	}

	switch( gadget_label ) {

	case VS_K_cp_Dismiss_Execute	:
	case VS_K_cp_Execute		:
		/*
		 * Check construction.
		 */
		om$send( msg   = message VScrcppfCmd.check_construction( &msg ),
			 targetid = my_id ) ;

		if( msg == MSFAIL ) {
			/*
			 * Cannot construct profile.
			 */
			break ;
		}

		/*
		 * Construct profile.
		 */
		om$send( msg	= message VScrcppfCmd.construct_profile( &msg ),
			 targetid = my_id ) ;

		if( me->flag & (VS_K_unknown_shape | VS_K_construction_error) )
			break ;

		/*
		 * Accept profile ?.
		 */
		om$send( msg	  = message VScrcppfCmd.accept_profile( &msg ),
			 targetid = my_id ) ;

		if( gadget_label == VS_K_cp_Dismiss_Execute )
			me->flag |= VS_K_exit_cmd ;
		else	me->flag |= VS_K_restart_cmd ;
		break ;

	case VS_K_cp_Dismiss		:
		response = TERMINATE ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_cp_Revert		:
		/*
		 * Reload form with default values.
		 */
		om$send( msg	  = message VSfmcppfCmd.load_attributes( &msg ),
			 targetid = my_id ) ;

		response = EX_RESTART ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_cp_Number_Of_Plates	:
		/*
		 * number should be >= VS_K_MIN_XSPLATES and
		 * <= VS_K_MAX_XSPLATES ( #defined in vsxsfrpldef.h ).
		 */
		FIfld_get_value( form_ptr, gadget_label, 0, 0,
				 &value, &sel_flag, &r_pos ) ;

		if( value >= VS_K_MIN_XSPLATES &&
		    value <= VS_K_MAX_XSPLATES ) {
			me->number_of_plates = (int) value ;
			FIg_disable( form_ptr, gadget_label ) ;

			response = VS_K_END_STATE ;
			ex$putque( msg = &msg, response = &response ) ;

			/*
			 * For one plate, we have no plates to stick.
			 */
			if( me->number_of_plates == 1 )
				me->flag |= VS_K_all_plates_stick ;

		} else {
			response = VS_K_SAME_STATE ;
			ex$putque( msg = &msg, response = &response ) ;
		}
		break ;

	case VS_K_cp_Material_Type	:
		/*
		 * Load new plate families and thicknesses.
		 */
		text = GET_FIELD_TEXT() ;
		__DBGpr_str( "New material", text ) ;
		if( !strcmp( text, me->actMat ) ) {
			_FREE( text ) ; break ;
		}

		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						text, NULL, NULL, NULL ),
				targetid= my_id ) ;

		if( msg != OM_I_NOMATCH ) {
			/*
			 * Query RDB.
			 */

			if( me->number_of_plates > 1 ) {
				QYmask = VS_m_fam	|
					 VS_m_thk_L	|
					 VS_m_thk_R	|
					 VS_m_force ;
			} else {
				QYmask = VS_m_fam | VS_m_thk_L | VS_m_force ;
			}
			QUERY_RDB( QYmask, TRUE ) ;
			SET_PLATES_THK_TYPE ;
			DRAW = TRUE ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_cp_Plate_Type 	:
		/*
		 * Load new thicknesses.
		 */
		text = GET_FIELD_TEXT() ;
		__DBGpr_str( "New family", text ) ;
		if( !strcmp( text, me->actFam ) ) {
			_FREE( text ) ; break ;
		}
		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						NULL, NULL, text, NULL ),
				targetid= my_id ) ;

		if( msg != OM_I_NOMATCH ) {
			/*
			 * Query RDB.
			 */
			if( me->number_of_plates > 1 ) {
				QYmask = VS_m_thk_L | VS_m_thk_R | VS_m_force ;
			} else {
				QYmask = VS_m_thk_L | VS_m_force ;
			}
			QUERY_RDB( QYmask, TRUE ) ;
			SET_PLATES_THK_TYPE ;
			DRAW = TRUE ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_cp_Thickness_Type_L	:
	case VS_K_cp_Thickness_Type_R	:
		WHICH_PLATE_NUMBER( Thickness_Type ) ;

		text = GET_FIELD_TEXT() ;
		__DBGpr_str( "New thickness", text ) ;

		if( strcmp( text,
			    me->plates[active_plate].thkType ) ) {
  
			msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
							NULL, NULL, NULL, text ),
					targetid= my_id ) ;


			if( msg != OM_I_NOMATCH ) {
				STRNCPY( me->plates[active_plate].thkType,
					 me->actPrt ) ;
				me->plates[active_plate].thkVal = me->actPar ;
				DRAW = TRUE ;
			}
		}

		__DBGpr_dbl( "Thickness value",
				     me->plates[active_plate].thkVal ) ;

		vs$system_to_unit( msg		= &msg,
				   value	= me->actPar,
				   osnum	= me->cstEnv.md_id.osnum,
				   p_unit	= &Unit ) ;

		/*
		 * Update thickness value field.
		 */
		FILL_THK_VALUE_FIELD( Unit ) ;

		/*
		 * Change value of width / height, if thickness is
		 * greater than it.
		 */
		if( me->plates[active_plate].thkVal >=
		    me->plates[active_plate].whtVal ) {

			me->plates[active_plate].whtVal =
			       me->plates[active_plate].thkVal *4 ;

			ex$message( msgnumb = VS_gI_WHChanged,
				    type    = "%d",
				    var     = `active_plate`,
				    buff    = buffer ) ;

			SET_VALUE_UNIT( gadget_label ==
					   VS_K_cp_Thickness_Type_L ?
					   VS_K_cp_Width_Or_Height_L :
					   VS_K_cp_Width_Or_Height_R,
					me->plates[active_plate].whtVal ) ;
		} else {
			sprintf( buffer, "%s : %s", me->actPrt, Unit ) ;
		}

		SET_MESSAGE( form_ptr, buffer ) ;

		_FREE( text ) ;
		break ;

	case VS_K_cp_Orientation_L	:
	case VS_K_cp_Orientation_R	:
		WHICH_PLATE_NUMBER( Orientation ) ;

		text = GET_FIELD_TEXT() ;

		__DBGpr_str( "New orientation", text ) ;
		if( strcmp( text,
			    me->plates[active_plate].ornType ) ) {

			STRNCPY( me->plates[active_plate].ornType,
				 text ) ;
			if( !strcmp( text,
				     VSmsgkey2string( VS_gI_Horizontal )))
				me->plates[active_plate].Orientation =
						       VS_K_HORIZONTAL ;

			if( !strcmp( text,
				     VSmsgkey2string( VS_gI_Vertical )))
				me->plates[active_plate].Orientation =
						       VS_K_VERTICAL ;
				DRAW = TRUE ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_cp_Width_Or_Height_L	:
	case VS_K_cp_Width_Or_Height_R	:
		/*
		 * Read user input, convert it to a numeric value,
		 * re-translate it to units then fill field ( user may
		 * have entered a unit expression ).
		 */
		WHICH_PLATE_NUMBER( Width_Or_Height ) ;

		/*
		 * Value must be greater than thickness.
		 */
		vs$processUnitField(	
				msg	= &msg,
				form	= form_ptr,
				field	= gadget_label,
				osnum	= me->cstEnv._MD_OS,
				verify	= VSisDblGreaterThan,
				args	= &me->plates[active_plate].thkVal,
				oldValue= me->plates[active_plate].whtVal,
				newValue= &value ) ;
		if( !( msg & 1 ) ) {
			SET_MSGKEY( form_ptr, VS_gI_WHGreaterThk ) ;
		} else {
			me->plates[active_plate].whtVal = value ;
			DRAW = TRUE ;
		}

		__DBGpr_dbl( "Width / Height",
			     me->plates[active_plate].whtVal ) ;
		break ;

	case VS_K_cp_Offset_L		:
	case VS_K_cp_Offset_R		:
		WHICH_PLATE_NUMBER( Offset ) ;

		if( me->connection[active_plate].plate2
				== (VS_K_MAX_XSPLATES + 1)	&&
		    me->connection[active_plate].plate2
				== (VS_K_MAX_XSPLATES + 1)	&&
		    me->flag & VS_K_all_plates_stick		) {
		    	/*
		    	 * Offset not used.
		    	 */
			ex$message( msgnumb = VS_gI_OffsetNotUsed,
				    type    = "%d",
				    var     = `active_plate`,
				    buff    = buffer ) ;
			SET_MESSAGE( form_ptr, buffer ) ;
			
			me->plates[active_plate].offVal = 0. ;

			vs$fillUnitField( 
			             msg   = &msg,
				     form  = form_ptr,
				     field = gadget_label,
				     value = me->plates[active_plate].offVal ) ;

		} else {
			/*
			 * Offset used. Read user input, convert it to a  
			 * numeric value, re-translate it to units then fill
			 * field (user may have entered a unit expression).
			 */
			vs$processUnitField(	
				      msg     = &msg,
				      form    = form_ptr,
				      field   = gadget_label,
				      osnum   = me->cstEnv._MD_OS,
				      oldValue= me->plates[active_plate].offVal,
				      newValue= &value ) ;

			if( me->plates[active_plate].offVal != value ) {
				me->plates[active_plate].offVal = value ;
				DRAW = TRUE ;
			}

			__DBGpr_dbl( "Offset",
				     me->plates[active_plate].offVal ) ;
		}
		break ;

	case VS_K_cp_Scroll_Bar 	:
		FIg_get_value( form_ptr, gadget_label, &value ) ;
		active_plate = value ;
		__DBGpr_int( "Plate number in left column", active_plate ) ;

		if( active_plate != me->active_plate ) {
			me->active_plate = active_plate ;
			om$send( msg	  =
					 message VSfmcppfCmd.fill_pseudo_mcf(
									 &msg ),
				 targetid = my_id ) ;
		}
		break ;

	case VS_K_cp_Stick		:
		me->flag |= VS_K_locate_plate ;
		response = VS_K_END_STATE ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_cp_Check		:
		om$send( msg   = message VScrcppfCmd.check_construction( &msg ),
			 targetid = my_id ) ;

		if( msg == MSSUCC ) {
			SET_MSGKEY( form_ptr, VS_gI_NoErrors ) ;
		}
		break ;

	case VS_K_cp_Profile_Type	:
		text = GET_FIELD_TEXT() ;

		VSstripString( text ) ;
		__DBGpr_str( "Profile type", text ) ;

		/*
		 * See if profile type exists.
		 */
		if( vs$doesCmpPrflExist( osnum	  = me->cstEnv._MD_OS,
					 material = me->actMat,
					 family   = me->actFam,
					 partName = text ) ) {
			SET_MSGKEY( form_ptr, VS_gI_PrfTypExist ) ;
			FILL_ASCII_FIELD( "" ) ;
		} else {
			strcpy( me->profile_type, text ) ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_cp_Rectangle		:
		if( me->flag & VS_K_command_stacked ) break ;
		if( !(me->flag & VS_K_locate_plate) ) break ;
		om$send( msg	  = message VSlocateCmd.processLocate(
							 form_ptr,
							 gadget_label ),
			 targetid = my_id ) ;
		break ;

	case VS_K_cp_Accept_Profile	:
		/*
		 * Set window notification off.
		 */
		om$send( msg	  = message VSlocateCmd.formOpByPtr(
							   form_ptr,
							   VS_FIf_WNEVENT_OFF ),
			 targetid = my_id ) ;

		/*
		 * Erase constructed profile draw on form.
		 */
		vs$repaint_gadget( form   = form_ptr,
				   gadget = VS_K_cp_Area ) ;

		/*
		 * Exit or restart command.
		 */
		response = -1 ;
		if( me->flag & VS_K_exit_cmd	)
			response = TERMINATE ;

		if( me->flag & VS_K_restart_cmd ) {
			/*
			 * WARNING : Gadgets text was not redisplayed,
			 * when we reset the form, so redisplay
			 * gadgets text.
			 */
			FIf_reset( form_ptr ) ;
			FIg_display( form_ptr, VS_K_cp_Mcf_Text       );
			FIg_display( form_ptr, VS_K_cp_Definition_Text);
			response = EX_RESTART ;
		}

		if( response != -1 ) {
			me->profile.objid = NULL_OBJID ;
			me->flag &= ~( VS_K_exit_cmd | VS_K_restart_cmd ) ;
			ex$putque( msg = &msg, response = &response ) ;
		}
		break ;

	case VS_K_cp_Reject_Profile	:
		/*
		 * Set window notification off.
		 */
		om$send( msg	  = message VSlocateCmd.formOpByPtr(
						   form_ptr,
						   VS_FIf_WNEVENT_OFF ),
			 targetid = my_id ) ;

		/*
		 * Erase profile draw on form.
		 */
		vs$repaint_gadget( form   = form_ptr,
				   gadget = VS_K_cp_Area ) ;

		/*
		 * Delete profile.
		 */
		VSdelCmpProfile( &me->cstEnv, &me->profile ) ;
		me->profile.objid = NULL_OBJID ;

		/*
		 * Erase 'accept' and 'reject' buttons.
		 */
		FIg_erase( form_ptr, VS_K_cp_Accept_Reject_Profile ) ;
		FIg_set_state_off( form_ptr, VS_K_cp_Reject_Profile ) ;

		/*
		 * Enable some gadgets.
		 */
		vs$g_enable_gadgets( form = form_ptr,
				     list = `VS_K_cp_Dismiss_Execute,
					     VS_K_cp_Execute,
					     VS_K_cp_Revert` ) ;

		/*
		 * Display pseudo multi-columns buttons 'stick' and 'check'.
		 */
		vs$g_display_gadgets( form = form_ptr,
				      list = `VS_K_cp_Mcf_Text,
					      VS_K_cp_Mcf_Column_L,
					      VS_K_cp_Check,
					      VS_K_cp_Stick,
					      VS_K_cp_Definition,
					      VS_K_cp_Definition_Text`);

		if( me->number_of_plates > 1 )
			FIg_display( form_ptr, VS_K_cp_Mcf_Column_R ) ;

		if( me->number_of_plates > 2 )
			FIg_display( form_ptr, VS_K_cp_Scroll_Bar ) ;

		/*
		 * Display plates on form.
		 */
		for( i=0; i<me->number_of_plates; i++ ) {
			FIg_display( form_ptr, VS_K_cp_Dgn_Plate + i ) ;
			FIg_display( form_ptr, VS_K_cp_Dgn_Text  + i ) ;
		}
		me->flag &= ~( VS_K_exit_cmd | VS_K_restart_cmd ) ;
		break ;
	}

	/*
	 * Erase offset display on form.
	 */
	if( me->flag & VS_K_offset_draw ) {

		FIg_erase(    form_ptr, VS_K_cp_Dgn_Offset ) ;
		FIg_delete(   form_ptr, VS_K_cp_Dgn_Offset ) ;
		FIgrp_delete( form_ptr, VS_K_cp_Dgn_Offset ) ;

		/*
		 * Update design.
		 */
		if( !DRAW )
			for( i=0; i<me->number_of_plates; i++ ) {
				FIg_display( form_ptr,
					     VS_K_cp_Dgn_Plate + i ) ;
				FIg_display( form_ptr,
					     VS_K_cp_Dgn_Text  + i ) ;
			}
		me->flag &= ~VS_K_offset_draw ;
	}

	/*
	 * Draw composite profile.
	 */
	if( DRAW )
		om$send( msg	  = message VScrcppfCmd.draw_plates( &msg ),
			 targetid = my_id ) ;


#undef GET_FIELD_TEXT
#undef FILL_ASCII_FIELD
#undef SET_VALUE_UNIT
#undef UPDATE_WIDTH_HEIGHT
#undef SET_PLATES_THK_TYPE
#undef WHICH_PLATE_NUMBER
#undef FILL_THK_VALUE_FIELD

	End
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method find_plate2( long *msg ) {

	int	side,
		plate2_stick ;
	char	buffer[MS_MAX_MSG_LENGTH],
		*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_find_plate2 ); Begin

	*msg = VS_K_ACT_SUCCESS ;

	me->plate2_stick = -1 ;
	me->side2	 = -1 ;

	/*
	 * Find plate side and plate number.
	 */
	VSfindPlate( form,
		     VS_K_cp_Dgn_Plate,
		     me->number_of_plates,
		     me->locatedGadget,
		     &plate2_stick,
		     &side ) ;

	__DBGpr_int( "Plate 2 found", plate2_stick ) ;
	__DBGpr_int( "Side found   ", side	   ) ;

	if( plate2_stick == -1 ||
	    side	 == -1 ) goto wrapup ;

	/*
	 * See if located plate is already stuck to an another plate.
	 */
	if( me->connection[plate2_stick].plate1 != VS_K_MAX_XSPLATES + 1 ) {
		ex$message( msgnumb = VS_gI_NoStuck,
			    type    = "%d%d",
			    var     = `plate2_stick,
				       me->connection[plate2_stick].plate1`,
			    buff    = buffer ) ;
		SET_MESSAGE( form, buffer ) ;
		goto wrapup ;
	}

	/*
	 * Located plate isn't stuck to a plate. So identify second plate.
	 */
	me->plate2_stick = plate2_stick ;
	me->side2	 = side ;

	wrapup :
		*msg = me->plate2_stick == -1 ? VS_K_SAME_STATE :
						VS_K_ACT_SUCCESS ;
	End
	return OM_S_SUCCESS ;

} /* method find_plate2 */
/*----------------------------------------------------------------------------*/
method find_plate1( long *msg ) {

	int	side,
		plate1_stick,
		plateNoStick ;
	char	buffer[MS_MAX_MSG_LENGTH],
		*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_find_plate1 ); Begin

	*msg = VS_K_SAME_STATE ;

	/*
	 * Find plate side and plate number.
	 */
	VSfindPlate( form,
		     VS_K_cp_Dgn_Plate,
		     me->number_of_plates,
		     me->locatedGadget,
		     &plate1_stick,
		     &side ) ;

	__DBGpr_int( "Plate 1 found", plate1_stick ) ;
	__DBGpr_int( "Side found   ", side	   ) ;

	if( plate1_stick == -1 ||
	    side	 == -1 )
		goto wrapup ;

	/*
	 * See if plate 2 ( located first ) is already stick to located plate.
	 */
	if( me->connection[plate1_stick].plate1 == me->plate2_stick ) {
		ex$message( msgnumb = VS_gI_NoStuck,
			    type    = "%d%d",
			    var     = `plate1_stick,
				       me->plate2_stick`,
			    buff    = buffer ) ;
		SET_MESSAGE( form, buffer ) ;
		goto wrapup ;
	}

	/*
	 * Check located plate.
	 */
	if( plate1_stick == me->plate2_stick )
		goto wrapup ;

	/*
	 * Check located side.
	 */
	if( (me->side2 == VS_K_TOP	||
	     me->side2 == VS_K_BOTTOM ) &&
	    ( side == VS_K_LEFT || side == VS_K_RIGHT ) )
		goto wrapup ;

	if( (me->side2 == VS_K_LEFT    ||
	     me->side2 == VS_K_RIGHT ) &&
	    ( side == VS_K_TOP || side == VS_K_BOTTOM ) )
		goto wrapup ;

	me->connection[me->plate2_stick].plate1 = plate1_stick ;
	me->connection[me->plate2_stick].side1	= side ;
	me->connection[me->plate2_stick].plate2 = me->plate2_stick ;
	me->connection[me->plate2_stick].side2	= me->side2 ;

	/*
	 * If all plates are stuck, disable 'stick' button.
	 */
	if( VSallPlatesStick( me->connection, me->number_of_plates,
			      &plateNoStick ) ) {

		FIg_disable( form, VS_K_cp_Stick ) ;
		me->flag |= VS_K_all_plates_stick ;

		SET_MSGKEY( form, VS_gI_AllPlatesStick ) ;
	}

	me->flag &= ~VS_K_locate_plate ;

	*msg = VS_K_ACT_SUCCESS ;

	wrapup :
	End
	return OM_S_SUCCESS ;

} /* method find_plate1 */
/*----------------------------------------------------------------------------*/
method draw_plates( long *msg ) {

	int	i,
		list[VS_K_MAX_XSPLATES] ;
	double	width,
		height ;
	char	*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_draw_plates ); Begin

	/*
	 * Erase all plates on design and set plate size according to plate
	 * definition.
	 */
	for( i=0; i<me->number_of_plates; i++ ) {

		FIg_erase( form, VS_K_cp_Dgn_Plate + i ) ;
		FIg_erase( form, VS_K_cp_Dgn_Text  + i ) ;

		VSsetPlateSize( form,
				VS_K_cp_Dgn_Plate + i,
				me->plates[i].Orientation,
				me->plates[i].thkVal,
				me->plates[i].whtVal,
				me->scale ) ;
	}

	/*
	 * Find list of plates to stick.
	 */
	VSfindListToStick( me->connection, me->number_of_plates, list ) ;

	/*
	 * Stick plates.
	 */
	for( i=0; i<me->number_of_plates; i++ )
		if( me->connection[list[i]].plate1 != (VS_K_MAX_XSPLATES + 1) &&
		    me->connection[list[i]].plate2 != (VS_K_MAX_XSPLATES + 1) ){

			me->connection[list[i]].offset =
				me->plates[list[i]].offVal ;

			VSstickPlate( form,
				      VS_K_cp_Dgn_Plate,
				      me->connection[list[i]].plate1,
				      me->connection[list[i]].side1,
				      me->connection[list[i]].plate2,
				      me->connection[list[i]].side2,
				      me->connection[list[i]].offset,
				      me->scale ) ;
		}

	/*
	 * Fit design.
	 */
	VSfitDrawing( form,
		      VS_K_cp_Dgn_Plate,
		      me->number_of_plates,
		      VS_K_cp_Rectangle ) ;

	/*
	 * Adjust plate number and display plates.
	 */
	for( i=0; i<me->number_of_plates; i++ ) {

		VSadjustPlateNumber( form,
				     VS_K_cp_Dgn_Plate + i,
				     VS_K_cp_Dgn_Text  + i ) ;

		FIg_display( form, VS_K_cp_Dgn_Plate + i ) ;
		FIg_display( form, VS_K_cp_Dgn_Text  + i ) ;
	}

	/*
	 * Compute scale of design.
	 */
	FIg_get_dsize( form, VS_K_cp_Dgn_Plate, &width, &height ) ;

	if( me->plates[0].Orientation == VS_K_HORIZONTAL )
		me->scale = width  / me->plates[0].whtVal ;
	else	me->scale = height / me->plates[0].whtVal ;

	__DBGpr_dbl( "Scale of design", me->scale ) ;

	/*
	 * Update axis of design.
	 */
	VSupdateAxis( form,
		      VS_K_cp_Axis_Unit,
		      VS_K_cp_Axis_X_Middle,
		      VS_K_cp_Axis_X_Max,
		      VS_K_cp_Axis_Y_Middle,
		      VS_K_cp_Axis_Y_Max,
		      VS_K_cp_Rectangle,
		      me->scale ) ;

	End
	return OM_S_SUCCESS ;

} /* method draw_plates */
/*----------------------------------------------------------------------------*/
method check_construction( long *msg ) {

	int	plateNoStick ;
	char	buffer[MS_MAX_MSG_LENGTH] ;

	SetProc( VScrcppfCmd_check_construction ); Begin

	*msg = MSSUCC ;

	/*
	 * See if profile type was given.
	 */
	if( !strlen( me->profile_type ) ) {

		SET_MSGKEY( me->fm_ptr, VS_gI_PrfTypNotGiven )  ;

		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * See if all plates are stuck.
	 */
	if( !(me->flag & VS_K_all_plates_stick ) ) {
			VSallPlatesStick( me->connection, me->number_of_plates,
					  &plateNoStick ) ;

			ex$message( msgnumb = VS_gI_PlMustStick,
				    type    = "%d",
				    var     = `plateNoStick`,
				    buff    = buffer ) ;

			SET_MESSAGE( me->fm_ptr, buffer ) ;

			*msg = MSFAIL ;
	}

	wrapup :
		End
		return OM_S_SUCCESS ;

} /* method check_construction */
/*----------------------------------------------------------------------------*/
method construct_profile( long *msg ) {

	int			i,
				nbCnxs,
				list[VS_K_MAX_XSPLATES],
				transName[VS_K_MAX_XSPLATES] ;
	VSxsPlateDef		plateDef[VS_K_MAX_XSPLATES] ;
	VSxsPlType		plateType ;
	VSxsPlContour		contour ;
	VSxsPlConn		connections[VS_K_MAX_XSPLATES] ;
	VSxsPlShpDesc		shapeDescr ;
	struct GRvg_construct	cst ;
	char			*thicknesses[VS_K_MAX_XSPLATES],
				*form = me->fm_ptr ;

	SetProc( VScrcppfCmd_construct_profile ); Begin

	me->flag &= ~( VS_K_unknown_shape | VS_K_construction_error ) ;

	me->profile.objid = NULL_OBJID ;

	/*
	 * Find list of plates to stick.
	 */
	VSfindListToStick( me->connection, me->number_of_plates, list ) ;

	/*
	 * Compute transformation of name ( number ) to have
	 * transName[old_name] = new_name.
	 */
	for( i=0; i<me->number_of_plates; i++ )
		transName[list[i]] = i ;

	/*
	 * Set struct 'connections' and 'plateDef' to generate closed contour.
	 */
	nbCnxs = 0 ;

	for( i=0; i<me->number_of_plates; i++ ) {
		if( me->connection[i].plate1 != VS_K_MAX_XSPLATES + 1 &&
		    me->connection[i].plate2 != VS_K_MAX_XSPLATES + 1 ) {

			connections[nbCnxs].plate1 =
				transName[me->connection[i].plate1] ;
			connections[nbCnxs].plate2 =
				transName[me->connection[i].plate2] ;

			connections[nbCnxs].side1 = me->connection[i].side1 ;
			connections[nbCnxs].side2 = me->connection[i].side2 ;

			connections[nbCnxs].offset = me->connection[i].offset ;

			nbCnxs++ ;
		}

		plateDef[i].thickness = me->plates[list[i]].thkVal ;
		plateDef[i].length    = me->plates[list[i]].whtVal ;
		plateDef[i].type      = me->plates[list[i]].Orientation ;
	}

#ifdef vsDEBUG
	printf( "~~~~~~~~~	CONNECTIONS FROM COMMAND      ~~~~~~~~~\n\n" ) ;
	printf( "List of plate\n" ) ;
	for( i=0; i<me->number_of_plates; i++ ) {
		printf( "Plate n'%d\n", i ) ;
		printf( "\tthickness : %g\n", plateDef[i].thickness ) ;
		printf( "\tlength    : %g\n", plateDef[i].length    ) ;
		printf( "\ttype      : %d\n", plateDef[i].type	    ) ;
	}

	printf( "List of connection\n" ) ;
	for( i=0; i<nbCnxs; i++ ) {
		printf( "Connection n'%d\n", i ) ;
		printf( "\tplate1 : %d\n", connections[i].plate1 ) ;
		printf( "\tplate2 : %d\n", connections[i].plate2 ) ;
		printf( "\tside1  : %d\n", connections[i].side1  ) ;
		printf( "\tside2  : %d\n", connections[i].side2  ) ;
		printf( "\toffset : %g\n", connections[i].offset ) ;
	}
	printf( "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ) ;
#endif

	/*
	 * Generate contour.
	 */
	vs$getContour( msg		= msg,
		       nbPlates 	= me->number_of_plates,
		       plates		= plateDef,
		       nbCnxs		= nbCnxs,
		       connections	= connections,
		       contour		= &contour,
		       shapeDescr	= &shapeDescr ) ;

	__CheckRC( 1, *msg, "vs$getContour", wrapup ) ;

	if( shapeDescr.shapeType == VS_K_UNKNOWN_SHAPE ) {
		__DBGpr_com( "Unknown shape !!!" ) ;
		me->flag |= VS_K_unknown_shape ;
		goto wrapup ;
	}

	__DBGpr_int( "Shape type", shapeDescr.shapeType ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= &me->cstEnv,
			   Level	= me->ActiveLevel,
			   Display	= &me->ActiveDisplay,
			   Properties	= GRIS_DISPLAYABLE |
					  GRIS_LOCATABLE   |
					  GRNOT_IN_RTREE,
			   Cnst_list	= cst ) ;

	/*
	 * Fill material and family of all plates.
	 */
	__DBGpr_str( "Material of profile", me->actMat	     ) ;
	__DBGpr_str( "Family   of profile", me->actFam	     ) ;
	__DBGpr_str( "Profile type	 ", me->profile_type ) ;

	plateType.material    = me->actMat ;
	plateType.family      = me->actFam ;
	plateType.profileType = me->profile_type ;

	/*
	 * Fill thickness name of each plate.
	 */
	for( i=0; i<me->number_of_plates; i++ ) {
		__DBGpr_int( "Part name of plate n'", i ) ;
		__DBGpr_str( "\t", me->plates[i].thkType ) ;

		thicknesses[i] = me->plates[i].thkType ;
	}

	/*
	 * Construct profile.
	 */
	vs$mkProfileFromPlates( msg		= msg,
				nbPlates	= me->number_of_plates,
				plates		= plateDef,
				nbCnxs		= nbCnxs,
				connections	= connections,
				cst		= &cst,
				plType		= &plateType,
				thicknesses	= thicknesses,
				profile 	= &me->profile ) ;

	__CheckRC( 1, *msg, "vs$mkProfileFromPlates", wrapup ) ;

	__DBGpr_obj( "Profile constructed", me->profile ) ;

	/*
	 * Delete cached ASCII data in transient object space, used by
	 * "Place/Modify Beam/Stiffener, etc." so next time one of these
	 * command is invoked it will regenerate it and the cache will now
	 * also contain the just-created composite profile.
	 */
	VSrdbDelCache() ;

	*msg = MSSUCC ;

	wrapup :
		if( !(*msg & 1) ) {
			 *msg = MSSUCC ;
			 __DBGpr_com( "Construction error" ) ;
			 SET_MSGKEY( form, VS_gI_ConstError ) ;
			 me->flag |= VS_K_construction_error  ;
		}

		if( me->flag & VS_K_unknown_shape ) {
			 SET_MSGKEY( form, VS_gI_UnkShapeType ) ;
		}
	End
	return OM_S_SUCCESS ;

} /* method construct_profile */
/*----------------------------------------------------------------------------*/
method accept_profile( long *msg ) {

	int	i ;
	char	*form = me->fm_ptr ;

#define weight 1

	SetProc( VScrcppfCmd_accept_profile ); Begin

	/*
	 * Set window notification on.
	 */
	om$send( msg	  = message VSlocateCmd.formOpByPtr( form,
							     VS_FIf_WNEVENT_ON),
		 targetid = my_id ) ;

	/*
	 * Erase plates on form.
	 */
	for( i=0; i<me->number_of_plates; i++ ) {
		FIg_erase( form, VS_K_cp_Dgn_Plate + i ) ;
		FIg_erase( form, VS_K_cp_Dgn_Text  + i ) ;
	}

	/*
	 * Erase pseudo multi-column, buttons 'stick', 'check' and profile
	 * definition.
	 */
	vs$g_erase_gadgets( form = form,
			    list = `VS_K_cp_Mcf_Text,
				    VS_K_cp_Mcf_Column_R,
				    VS_K_cp_Mcf_Column_L,
				    VS_K_cp_Scroll_Bar,
				    VS_K_cp_Check,
				    VS_K_cp_Stick,
				    VS_K_cp_Definition,
				    VS_K_cp_Definition_Text` ) ;

	/*
	 * Disable the other gadgets, except button 'Dismiss'.
	 */
	vs$g_disable_gadgets( form = form,
			      list = `VS_K_cp_Dismiss_Execute,
				      VS_K_cp_Execute,
				      VS_K_cp_Revert` ) ;

	/*
	 * Draw the profile on the form in symbolic representation.
	 */
	vs$draw_section_on_form( msg		= msg,
				 form		= form,
				 gadget 	= VS_K_cp_Area,
				 representation = AC_2D_REP,
				 weight 	= weight,
				 mod_env	= &me->cstEnv,
				 sectDef	= &me->profile ) ;

	/*
	 * Fill fields of profile, material, plate type.
	 */
	FIfld_set_text( form, VS_K_cp_AR_Profile_Type, 0, 0,
			me->profile_type, FALSE ) ;

	FIfld_set_text( form, VS_K_cp_AR_Material_Type, 0, 0,
			me->actMat,	  FALSE ) ;

	FIfld_set_text( form, VS_K_cp_AR_Plate_Type, 0, 0,
			me->actFam,	  FALSE ) ;


	/*
	 * Display 'accept / reject' gadgets.
	 */
	FIg_display( form, VS_K_cp_Accept_Reject_Profile ) ;

#undef weight

	End
	return OM_S_SUCCESS ;

} /* method accept_profile */
/*----------------------------------------------------------------------------*/
method window_notification( int form_label, event ; char *form ) {

	long	msg ;

	SetProc( VScrcppfCmd_window_notification ); Begin

#define weight 1

	if( event == FI_REFRESH ) {
		/*
		 * Draw constructed profile on form.
		 */
		vs$draw_section_on_form( msg		= &msg,
					 form		= me->fm_ptr,
					 gadget 	= VS_K_cp_Area,
					 representation = AC_2D_REP,
					 weight 	= weight,
					 mod_env	= &me->cstEnv,
					 sectDef	= &me->profile ) ;
	}

#undef weight

	End
	return OM_S_SUCCESS ;

} /* method window_notification */
/*----------------------------------------------------------------------------*/

end implementation VScrcppfCmd ;
