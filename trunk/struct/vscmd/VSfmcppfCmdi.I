/*
	I/STRUCT
*/
class implementation VSfmcppfCmd ;

#include <stdio.h>
#include <string.h>
#include "FI.h"
#include "OMmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vscppf.h"
#include "vscppffmdef.h"
#include "vsglobalmsg.h"
#include "vsdpb.h"
#include "vspart.h"
#include "vsdpbmacros.h"
#include "vsiomacros.h"
#include "vsRDBdef.h"
#include "vsmiscmacros.h"
#include "vscmdmacros.h"
#include "vscmddef.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

%safe
static int 	x_compProf_pos = 0,
		y_compProf_pos = 0,
		s_compProf_pos = 0 ;
%endsafe

#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'
#define FILL_ASCII_FIELD( label, text ) \
	FIfld_set_text( form, (label), 0, 0, (text), FALSE )
#define SET_LIST_SELECT( label, index )\
	FIfld_set_list_select( form, (label), (index), 0, TRUE )


int VSbutton_intercept(Form form,
                        int xpos, int ypos,
                        int button, int trans, int t_tag)
{
	int gadget, rc,sel;
	long 	msg,sts;

#if defined(ENV5)
	switch ( button ) {

		case	MIDDLE_BUTTON:
   	
	    		FIf_process_point(	form, 
						xpos, 
						ypos, 
						button, 
						trans, 
						t_tag);
			break;
	
		case	LEFT_BUTTON:
	
			break;	

		case	RIGHT_BUTTON:
	
			rc = FIf_find_gadget(	form, 
						FI_FORM_GROUP,
						xpos,
						ypos, 
						&gadget);
			if( rc == FI_SUCCESS )
			{
				if ( gadget == VS_K_cp_Rectangle )
				{ 
					sel = VS_K_FORM_MOVEON; 
					ex$putque ( msg      = &msg,
						    response = &sel );
				}
	  		}
			break;
		
		
		default:
			break;
       };

#elif defined(X11)

	switch ( button ) {   		
		
		case	Button1:
			break;

		case	Button2:

     			FIf_process_point(form,xpos,ypos, button, trans, t_tag);
			break;

		case	Button3:
			
			rc = FIf_find_gadget(	form, 
						FI_FORM_GROUP,
						xpos,
						ypos, 
						&gadget);
			if(rc == FI_SUCCESS)
			{
				if ( gadget == VS_K_cp_Rectangle )
				{ 
					sel = VS_K_FORM_MOVEON;

					ex$putque ( msg      = &msg,
						    response = &sel );
				}
	  		}
			break;

		default:
		break;
       };
#else
#	omerror "Windowing system switches must be set!"
#endif
	return 1;
}

/*----------------------------------------------------------------------------*/
method createForm() {

	long		msg ;

        int	VSbutton_intercept();

	/*
	 * Init instances data.
	 */
	me->ornCount		= 0 ;
	me->ornList		= NULL ;
	me->flag		= 0 ;
	me->fm_ptr		= NULL ;
	me->number_of_plates	= 0 ;
	me->active_plate	= 0 ;
	me->profile_type[0]	= '\0' ;

	/*
	 * Create form.
	 */
	om$send( msg	  = message VSlocateCmd.formCreationByPtr(
					0, "VScompProf.fm", &me->fm_ptr ),
		 targetid = my_id ) ;

	if( !me->fm_ptr ) { me->flag |= VS_K_init_failed ; goto wrapup ; }

	/*
	 * Set initial notification method to form.
	 */
	om$send(msg	= message VSlocateCmd.formOpByPtr(
					me->fm_ptr, VS_FIf_INITNTFY_ON ),
		targetid= my_id ) ;
		 
	/*
	 * Set location and screen.
	 */
	if( x_compProf_pos || y_compProf_pos || s_compProf_pos ) {
	    	FIf_set_location( me->fm_ptr, x_compProf_pos, y_compProf_pos ) ;
	    	FIf_set_screen( me->fm_ptr, s_compProf_pos ) ;
	} 

	/*
	 * Load attributes.
	 */
	om$send(msg	= message VSfmcppfCmd.load_attributes( &msg ),
		targetid= my_id ) ;

	if( !( msg & 1 ) ) { me->flag |= VS_K_init_failed ; goto wrapup ; }

        FIf_set_button_intercept_routine( me->fm_ptr, VSbutton_intercept );
	/*
	 * Display form.
	 */
	VSf_display( me->fm_ptr ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method createForm */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	if( me->flag & ( VS_K_init_failed | VS_K_cmd_error ) ) goto wrapup ;

	om$send( msg	  = message VSlocateCmd.wakeup( pos ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	if( me->fm_ptr ) {
		/*
		 * Enable form.
		 */
		om$send( msg	  = message VSfmcppfCmd.enable_form( &pos ),
			 targetid = my_id ) ;
	}

	me->flag &= ~VS_K_command_stacked ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	if( me->flag & ( VS_K_init_failed | VS_K_cmd_error ) ) goto wrapup ;

	me->flag |= VS_K_command_stacked ;

	if( me->fm_ptr ) {
		/*
		 * Disable form.
		 */
		om$send( msg	  = message VSfmcppfCmd.disable_form( &pos ),
			 targetid = my_id ) ;
	}

	om$send( msg	  = message VSlocateCmd.sleep( pos ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int notUsed ) {

	if( me->flag & ( VS_K_init_failed | VS_K_cmd_error ) ) goto wrapup ;

	VSfreeList( me->ornCount, me->ornList ) ;

	/*
	 * Delete constructed profile if not accepted.
	 */
	if( !IF_NULL_OBJID( me->profile.objid ) )
		VSdelCmpProfile( &me->cstEnv, &me->profile ) ;

	wrapup :
		if( me->fm_ptr ) {
			FIf_get_location( me->fm_ptr, 
					  &x_compProf_pos, 
					  &y_compProf_pos ) ;
			FIf_get_screen( me->fm_ptr,
					&s_compProf_pos ) ;
			FIf_delete( me->fm_ptr ) ;
		}

		om$send( msg	  = message VSlocateCmd.delete( notUsed ),
			 mode	  = OM_e_wrt_message,
			 targetid = my_id ) ;

		return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method QueryRDB( long	*msg ; int action, fillForm ) {

	long	sts ;
	int	a, A, m ;
	char	errStr[MS_MAX_MSG_LENGTH] ;

	a = action ; m = 0 ;
	if( ( action & VS_m_thk_L ) || ( action & VS_m_thk_R ) ) {
		m = action & ( VS_m_thk_L | VS_m_thk_R ) ;
		action &= ~( VS_m_thk_L | VS_m_thk_R ) ;
		action |= VS_m_prt ;
	}

	sts = om$send(	msg	= message VSqryRdbCmd.loadAny(
						msg, errStr, action, &A ),
			targetid= my_id ) ;

	if( sts & 1 & *msg ) {
		if( fillForm ) {
			if( m && ( A & VS_m_prt ) ) A |= m ;
			sts = om$send(
				msg	= message VSfmcppfCmd.fillFormWithRdbData(
								msg, A ),
				targetid= my_id ) ;
		}
	} else {
		VSfi_msg( me->fm_ptr, errStr ),
		me->flag |= VS_K_message_set ;
		VS_Wait_timer( 60 ) ;
	}

	return OM_S_SUCCESS ;

} /* method QueryRDB */
/*----------------------------------------------------------------------------*/
method fillFormWithRdbData( long *msg ; int action ) {

	char    *form = me->fm_ptr ;

#define FILL_FLIST( gadget, descr ) \
	{\
	VSfld_set_list( form, VS_K_cp_##gadget, me->descr##Count,\
			me->descr##List ) ;\
	FIfld_set_text( form, VS_K_cp_##gadget, 0, 0,\
			 me->descr##List[me->descr##Index], FALSE ) ;\
	SET_LIST_SELECT( VS_K_cp_##gadget, me->descr##Index ) ;\
	}
#define RESTORE_FIELD( gadget, descr ) \
	{\
	FILL_ASCII_FIELD( VS_K_cp_##gadget,\
			  me->descr##List[me->descr##Index] ) ;\
	SET_LIST_SELECT( VS_K_cp_##gadget, me->descr##Index ) ;\
	}

	*msg = MSSUCC ;

	if( action & VS_m_mat ) { FILL_FLIST( Material_Type	, mat ) ; }
	if( action & VS_m_fam ) { FILL_FLIST( Plate_Type	, fam ) ; }
	if( action & VS_m_thk_L ) {
		FILL_FLIST( Thickness_Type_L	, prt ) ;
		vs$fillUnitField(	msg	= msg,
					form	= me->fm_ptr,
					field	= VS_K_cp_Thickness_Value_L,
					value	= me->actPar ) ;
	}
	if( action & VS_m_thk_R ) {
		FILL_FLIST( Thickness_Type_R	, prt ) ;
		vs$fillUnitField(	msg	= msg,
					form	= me->fm_ptr,
					field	= VS_K_cp_Thickness_Value_R,
					value	= me->actPar ) ;
	}

#undef FILL_FLIST
#undef RESTORE_FIELD

	return OM_S_SUCCESS ;

} /* method fillFormWithRdbData */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	int	got_data ;	/* TRUE if DPB loaded with plate data */
	double	thkVal ;
	char	buffer[MS_MAX_MSG_LENGTH] ;

	VSdpb_loaded_with_plate( &got_data ) ;

	/*
	 * Retrieve active RDB attributes form DPB; if DPB not loaded (first
	 * time) then query RDB.
	 */
	if( got_data ) {
		char	*actAttr,
			actMat[VS_K_MAXDBNAME],
			actFam[VS_K_MAXDBNAME],
			actPrt[VS_K_MAXDBNAME] ;

		/*
		 * Materials from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_material,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actMat, actAttr ) ;

		/*
		 * Families from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_type,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actFam, actAttr  ) ;

		/*
		 * Thicknesses from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_thkname,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actPrt, actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_thickness,
				p_arg	= &thkVal ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		me->actPar = thkVal ;

		om$send(msg     = message VSqryRdbCmd.setActiveItems(
					actMat, NULL, actFam, actPrt ),
			targetid= my_id ) ;
	}
	
	om$send(msg     = message VSfmcppfCmd.QueryRDB(	msg,
							VS_m_mat |
							VS_m_fam |
							VS_m_prt |
							VS_m_par |
							VS_m_force,
							FALSE ),
			targetid= my_id ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	/*
	 * Load orientation for plates.
	 */
	if( me->ornCount ) {
		VSfreeList( me->ornCount, me->ornList ) ;
		me->ornList  = NULL ;
		me->ornCount = 0 ;
	}

	me->ornList = _MALLOC( 2, char * ) ;
	if( !me->ornList ) { *msg = MSFAIL ; goto wrapup ; }

	ex$message( msgnumb = VS_gI_Horizontal, buff = buffer ) ;
	me->ornList[0] = VSstrdup( buffer ) ;

	ex$message( msgnumb = VS_gI_Vertical  , buff = buffer ) ;
	me->ornList[1] = VSstrdup( buffer ) ;

	me->ornCount   = 2 ;

	*msg = MSSUCC ;

	wrapup :
		if( !(*msg  & 1) ) me->flag |= VS_K_cmd_error ;
		return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method was_init_successful( long *msg ) {

	*msg = me->flag & ( VS_K_init_failed | VS_K_cmd_error )
			? MSFAIL
			: MSSUCC ;

	if( !( *msg & 1 ) ) me->stskey = VS_gE_ErrEncCmdTrm ;

	return OM_S_SUCCESS ;

} /* method was_init_successful */
/*----------------------------------------------------------------------------*/
method fill_form( long *msg ) {

	char	*form = me->fm_ptr ;

#define FILL_FIELD_ALIST( label, size, list ) \
	VSfld_set_list( form, (label), (size), (list) ) ;

	*msg = MSSUCC ;

	/*
	 * Set list for material type, plate type, thickness and orientation.
	 */
	FILL_FIELD_ALIST( VS_K_cp_Material_Type   , me->matCount, me->matList );
	FILL_FIELD_ALIST( VS_K_cp_Plate_Type	  , me->famCount, me->famList );
	FILL_FIELD_ALIST( VS_K_cp_Thickness_Type_L, me->prtCount, me->prtList );
	FILL_FIELD_ALIST( VS_K_cp_Orientation_L   , me->ornCount, me->ornList );

	if( me->number_of_plates > 1 ) {
		FILL_FIELD_ALIST( VS_K_cp_Thickness_Type_R,
				  me->prtCount,
				  me->prtList ) ;

		FILL_FIELD_ALIST( VS_K_cp_Orientation_R,
				  me->ornCount,
				  me->ornList ) ;
	}

	/*
	 * Set text for material type and plate type.
	 */
	FILL_ASCII_FIELD( VS_K_cp_Material_Type , me->actMat ) ;
	FILL_ASCII_FIELD( VS_K_cp_Plate_Type	, me->actFam ) ;

	SET_LIST_SELECT( VS_K_cp_Material_Type,   me->matIndex ) ;
	SET_LIST_SELECT( VS_K_cp_Plate_Type,	  me->famIndex ) ;

	om$send( msg	  = message VSfmcppfCmd.fill_pseudo_mcf( msg ),
		 targetid = my_id ) ;

#undef FILL_FIELD_ALIST

	return OM_S_SUCCESS ;

} /* method fill_form */
/*----------------------------------------------------------------------------*/
method fill_pseudo_mcf( long *msg ) {

	long			msg ;
	char			*form	= me->fm_ptr ;
	int			index,
				actPl	= me->active_plate ;
	VScompProfPlateDef	*pl	= me->plates ;

#define SET_TEXT( gadget, text, descr )\
	{\
	FILL_ASCII_FIELD( (gadget), (text) ) ;\
	VSfind_string_in_list( (text),\
			     me->descr##List,\
			     me->descr##Count,\
			     &index ) ;\
	SET_LIST_SELECT( (gadget), index ) ;\
	}

#define FILL_VALUE_FIELD( gadget, val ) \
	FIfld_set_value( form, (gadget), 0, 0, (double) (val), FALSE ) ;

	/*
	 * Fill plate number row.
	 */
	FILL_VALUE_FIELD( VS_K_cp_Plate_Number_L, actPl ) ;
	if( me->number_of_plates > 1 )
		FILL_VALUE_FIELD( VS_K_cp_Plate_Number_R, actPl + 1 ) ;

	/*
	 * Fill orientation row.
	 */
	SET_TEXT( VS_K_cp_Orientation_L, pl[actPl].ornType, orn ) ;

	if( me->number_of_plates > 1 )
		SET_TEXT( VS_K_cp_Orientation_R, pl[actPl+1].ornType, orn ) ;

	/*
	 * Fill thickness type row.
	 */
	SET_TEXT( VS_K_cp_Thickness_Type_L, pl[actPl].thkType, prt ) ;

	if( me->number_of_plates > 1 )
		SET_TEXT( VS_K_cp_Thickness_Type_R, pl[actPl+1].thkType, prt ) ;

	/*
	 * Fill thickness value row.
	 */
	vs$fillUnitField(	msg	= &msg,
				form	= form,
				field	= VS_K_cp_Thickness_Value_L,
				value	= pl[actPl].thkVal ) ;

	if( me->number_of_plates > 1 ) {
		vs$fillUnitField(
				msg	= &msg,
				form	= form,
				field	= VS_K_cp_Thickness_Value_R,
				value	= pl[actPl+1].thkVal ) ;
	}

	/*
	 * Fill width row.
	 */
	vs$fillUnitField(	msg	= &msg,
				form	= form,
				field	= VS_K_cp_Width_Or_Height_L,
				value	= pl[actPl].whtVal ) ;

	if( me->number_of_plates > 1 ) {
		vs$fillUnitField(
				msg	= &msg,
				form	= form,
				field	= VS_K_cp_Width_Or_Height_R,
				value	= pl[actPl+1].whtVal ) ;
	}

	/*
	 * Fill offset row.
	 */
	vs$fillUnitField(	msg	= &msg,
				form	= form,
				field	= VS_K_cp_Offset_L,
				value	= pl[actPl].offVal ) ;

	if( me->number_of_plates > 1 ) {
		vs$fillUnitField(
				msg	= &msg,
				form	= form,
				field	= VS_K_cp_Offset_R,
				value	= pl[actPl+1].offVal ) ;
	}

#undef SET_TEXT
#undef FILL_VALUE_FIELD

	return OM_S_SUCCESS ;

} /* fill_pseudo_mcf */
/*----------------------------------------------------------------------------*/

end implementation VSfmcppfCmd ;
