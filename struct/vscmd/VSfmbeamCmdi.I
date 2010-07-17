/* $Id: VSfmbeamCmdi.I,v 1.2 2001/05/06 15:50:46 jayadev Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:      vscmd/VSfmbeamCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfmbeamCmdi.I,v $
 *      Revision 1.2  2001/05/06 15:50:46  jayadev
 *      changes for CR#5169
 *
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 05/04/01  Jayadev  CR# MP5169  
 *************************************************************************/
/*
	I/STRUCT
*/
class implementation VSfmbeamCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "OMmacros.h"
#include "godef.h"
#include "growner.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "EMSssprops.h"
#include "v_iomacros.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsglobals.h"
#include "vsglobalmsg.h"
#include "vssectiondef.h"
#include "vsbeam.h"
#include "vsoptdef.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vscmddef.h"
#include "vsformmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsmeasmacros.h"
#include "vsgeommacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsformproto.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsstrngproto.h"

#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'
#define FILL_ASCII_FIELD( label, text ) \
	FIfld_set_text(	form, (label), 0, 0, (text), FALSE ) 
#define FILL_VALUE_FIELD( label, val ) \
	FIfld_set_value( form, (label), 0, 0, (double) (val), FALSE ) 
#define FILL_FIELD_ALIST( label, size, list ) \
	VSfld_set_list( form, (label), (size), (list) ) 
#define FILL_ASCII_ROW( label, size, list ) \
	VSfld_set_row_text( form, (label), (size), (list) )
#define FILL_ASCII_MCF( label, column, size, list ) \
	VSmcf_set_list_text( form, (label), (column), (size), (list) )
	

from	GRvg		import	GRgenabsg,
				GRgetrang ;
from    GRcurve         import  GRtotlength;
from    VSbeam          import  VSgetProfileDef,
                                VSgetSectionParameter ;
from	EMSsubbs	import	EMget_props ;
from	GRvg		import	GRputattr ;

/*
 * Default display ratio.
 */
%safe
static double VS_Gd_DisplayRatio = 10. ;
%endsafe

extern int	VSfmbeamCmd_window_event() ;
extern int	COB_FI_form_notification() ;
/*----------------------------------------------------------------------------*/
method initToFailure() { me->flag = VS_K_init_failed ; return OM_S_SUCCESS ; }
/*----------------------------------------------------------------------------*/
method createForm() {

	char	*form ;
	int 	isLoaded ;

	/*
	 * Init instance data.
	 */	
	me->source		= NULL ;
	me->stock		= NULL ;
	me->notes		= NULL ;
	me->approval_status 	= NULL ;
	me->construction_status = NULL ;
	me->usrNamList		= NULL ;
	me->usrSynList		= NULL ;
	me->usrAttCount		= 0 ;

	me->flag = 0 ; 		
	me->display_ratio = VS_Gd_DisplayRatio ;

	/*
	 * Init form.
	 */
	me->ret = FIf_new( 1, "VSplModBeam.fm", COB_FI_form_notification, 
			   &me->fm_ptr ) ;

	if( me->ret ) {
		me->flag |= VS_K_init_failed ; goto wrapup ;
	}
	
	FIf_set_cmd_oid_os( me->fm_ptr, my_id, OM_Gw_current_OS ) ;

	form = me->fm_ptr ;
	
	/*
	 * Initialize group gadget. The label is 100 + label gadget which
	 * activates the group.  
	 */
	FIg_new( form, FI_GROUP , VS_K_bm_Grp_Definition   ) ;
	FIg_new( form, FI_GROUP , VS_K_bm_Grp_Manipulation ) ;
	FIg_new( form, FI_GROUP , VS_K_bm_Grp_MTO          ) ;
	FIg_new( form, FI_GROUP , VS_K_bm_Grp_UA           ) ;
	
	/* Initialize group Definition */

	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_Def_Gadget,
			    VS_K_bm_Grp_Definition ) ;

	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_Comments,
			    VS_K_bm_Grp_Definition ) ;

	/* Initialize group Manipulation */
	
	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_Manip_Gadget,
			    VS_K_bm_Grp_Manipulation ) ;

	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_Sym_Gadget,
			    VS_K_bm_Grp_Manipulation ) ;

	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_Ref_Gadget,
			    VS_K_bm_Grp_Manipulation ) ;

	FIgrp_add_to_group( form,
			    VS_K_xs_Position,
			    VS_K_bm_Grp_Manipulation ) ;


	/* Initialize group MTO */

	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_MTO_Gadget,
			    VS_K_bm_Grp_MTO ) ;

	/* Initialize group User Attributes */
	
	FIgrp_add_to_group( form,
			    VS_K_bm_Grp_User_Attributes,
			    VS_K_bm_Grp_UA ) ;

	me->ActGrp = VS_K_bm_Grp_Default ;

	/*
	 * See if form has already been invoked.
	 */
	VSdpb_loaded_with_beam( &isLoaded ) ;

	if( isLoaded ) {
		struct VSdpb_form_pos	B_form ;

		vs$get_act_pm(	msg	= &me->ret,
				param	= VS_e_dpb_B_form,
				p_arg	= &B_form ) ;

		if( me->ret & 1 ) {
			VSf_set_layout( form,
					(int) B_form.screen,
					B_form.x,
					B_form.y,
					B_form.width,
					B_form.height ) ;
		}
	}
	 /*
	  * Else form will be displayed with default location and size.
	  */

	om$send(msg	= message VSfmbeamCmd.set_initial_gadget_attributes(
								     &me->ret ),
		targetid= my_id  ) ;
    
	om$send(msg	= message VSlocateCmd.formOpByPtr( form,
							   VS_FIf_INITNTFY_ON ),
		targetid= my_id ) ;

	FIf_set_window_event_routine( form, VSfmbeamCmd_window_event ) ;

	vs$get_member_classes_from_RDB( msg 	= &me->ret,
					clsList	= me->clsCode,
					keyList = me->clsMsg ) ;
	me->clsIndex = 0 ;

	vs$get_mb_beam_types_from_RDB(  msg 	 = &me->ret,
					typeList = me->typCode,
					keyList  = me->typMsg ) ;
	me->typIndex = 0 ;

	om$send(msg	= message VSfmbeamCmd.load_attributes( &me->ret ),
		targetid= my_id ) ;
			
	if( me->ret & 1 ) {
		om$send(msg	= message VSfmbeamCmd.fill_form( &me->ret ),
			targetid= my_id ) ;
			 
		/*
		 * Display active group.
		 */
		FIg_display( form, me->ActGrp ) ;

	 	/*
	 	 * Display form.
	 	 */
 	 	VSf_display( form ) ;
 	 	
		/*
		 * First wakeup after init must enable form.
		 */
		me->flag &= ~VS_K_form_active ;
		me->flag |= VS_K_no_object_located ;
		om$send(msg	= message VSfmbeamCmd.enable_form( &me->ret ),
			targetid= my_id ) ;
		
		me->flag &= ~VS_K_init_failed ;

	} else	me->flag |=  VS_K_init_failed ;

	me->flag |= VS_K_first_inter_displ ;

	wrapup :
		me->ret = me->flag & VS_K_init_failed ? MSFAIL : MSSUCC ;
	return OM_S_SUCCESS ;

} /* method createForm */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {
	
	char	*form = me->fm_ptr ;
	
	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	me->suppressHilite = TRUE ;

	me->ret = om$send(	msg	= message VSlocateCmd.wakeup( pos ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	if( ( me->ret & 1 ) && form ) {
		if( !(me->flag & VS_K_no_attributes) ) {
			if( *me->cnstDir )	me->directory = me->cnstDir ;
			else			me->directory = me->Cwd ;
			FILL_ASCII_FIELD( VS_K_bm_Directory, me->directory ) ;	
		}
		om$send(msg	= message VSfmbeamCmd.enable_form( &me->ret ),
			targetid= my_id ) ;
	}

	return me->ret & 1 ? OM_S_SUCCESS : OM_W_ABORT ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	me->flag |= VS_K_command_stacked ;
	
	me->suppressHilite = FALSE ;

	me->ret = om$send(	msg	= message VSlocateCmd.sleep( pos ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	if( me->ret & 1 ) {
		om$send(msg	= message VSfmbeamCmd.disable_form( &me->ret ),
			targetid= my_id ) ;
	}
	
	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int notUsed ) {

	if( me->flag & VS_K_init_failed ) {
		ex$message( msgnumb 	  = VS_gE_ErrEncCmdTrm,
			    justification = CENTER_JUS ) ;
		goto wrapup ;
	}

	/*
	 * Store active set-up to DPB.
	 */
	om$send(msg	= message VSfmbeamCmd.write_to_DPB( &me->ret ),
		targetid= my_id ) ;

	/*
	 * Remember default display ratio.
	 */
	VS_Gd_DisplayRatio = me->display_ratio ;
	
	/*
	 * Store active user attributes if any.
	 */
	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount )  {
		struct GRid	newUA ;
		
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename  = VS_K_ActBmUAttr,
				      nbEntries	= me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &newUA ) ;
	}

	/*
	 * Now free instance data.
	 */
	_FREE( me->source		) ;
	_FREE( me->notes		) ;
	_FREE( me->stock		) ;
	_FREE( me->approval_status  	) ;
	_FREE( me->construction_status  ) ;
	
	VSfreeList( me->usrAttCount, me->usrNamList) ;
	VSfreeList( me->usrAttCount, me->usrSynList) ;

	if( me->fm_ptr ) FIf_delete( me->fm_ptr ) ;

	wrapup :
	me->ret = om$send(	msg	= message VSlocateCmd.delete( notUsed ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method was_init_successful( long *msg ) {

	*msg = me->flag & ( VS_K_init_failed | VS_K_cmd_error )
	                ? MSFAIL 
	                : MSSUCC ;

	return OM_S_SUCCESS ;

} /* method was_init_successful */
/*----------------------------------------------------------------------------*/
method fill_form( long *msg ) {

	char	*form = me->fm_ptr ;
	int	button ;
        int     count = 0, retSts;
        double  beamLength = 0.0;
        char    *unit, buffer[128];

	if( me->flag & VS_K_no_attributes ) { *msg = MSSUCC ; goto wrapup ; }

	FILL_FIELD_ALIST( VS_K_bm_Material_Type	, me->matCount, me->matList ) ;
	FILL_FIELD_ALIST( VS_K_bm_Material_Grade, me->grdCount, me->grdList ) ;
	FILL_FIELD_ALIST( VS_K_bm_Shape_Name	, me->famCount, me->famList ) ;	
	FILL_FIELD_ALIST( VS_K_bm_Section_Name	, me->prtCount, me->prtList ) ;

        /*
         * changes for CR# MP5169
         */
        count = om$dimension_of( varray = me->locObjs ) ;
        if(count > 0)
        {
          retSts = VSgetBeamLength(&me->locObjs[0],&beamLength);

          __DBGpr_obj("Beam ",me->locObjs[0].obj_id);
          __DBGpr_dbl("Beam Length",beamLength);

          if(retSts&1)
          {
	    vd_$get_default_unit(   msg     = msg,
				    type    = GRIO_DISTANCE,
				    osnum   = me->locObjs[0].obj_id.osnum,
				    p_unit  = &unit ) ;
            sprintf(buffer,"%f %s",beamLength,unit);
            FIfld_set_text( form, VS_K_bm_Beam_Length, 0, 0,buffer, FALSE ) ;
          } 
        }
	
	VSfld_set_list_with_msgkeys(	form,
					VS_K_bm_Member_Class,
					VS_rdb_MAXCLASSES,
					me->clsMsg ) ;

	VSfld_set_list_with_msgkeys(	form,
					VS_K_bm_Member_Type,
					VS_rdb_MAXBMTYPES,
					me->typMsg ) ;
	
	FILL_ASCII_ROW( VS_K_bm_Parameters	,me->parCount,
			me->namValList ) ;
	if( me->usrAttCount ) {
		FILL_ASCII_MCF( VS_K_bm_Mcf_User_Attributes,
				0, 
				me->usrAttCount, 
				me->usrNamList 			) ;
		FILL_ASCII_MCF( VS_K_bm_Mcf_User_Attributes,
				1, 
				me->usrAttCount, 
				me->usrSynList 			) ;
	}

	FILL_ASCII_FIELD( VS_K_bm_Material_Type	, me->actMat ) ;
	FILL_ASCII_FIELD( VS_K_bm_Material_Grade, me->actGrd ) ;
	FILL_ASCII_FIELD( VS_K_bm_Shape_Name	, me->actFam ) ;	
	FILL_ASCII_FIELD( VS_K_bm_Section_Name	, me->actPrt ) ;
	FILL_ASCII_FIELD( VS_K_bm_Member_Class	,
			  VSmsgkey2string( me->clsMsg[me->clsIndex] ) ) ;
	FILL_ASCII_FIELD( VS_K_bm_Member_Type	,
			  VSmsgkey2string( me->typMsg[me->typIndex] ) ) ;

	FILL_ASCII_FIELD( VS_K_bm_Stock_Number,	me->stock		) ;
	FILL_ASCII_FIELD( VS_K_bm_Source,	me->source		) ;
	FILL_ASCII_FIELD( VS_K_bm_Approval_Status, 
						me->approval_status     ) ;
	FILL_ASCII_FIELD( VS_K_bm_Construction_Status, 
						me->construction_status ) ;

	VSfld_set_lines(	form,
				VS_K_bm_Comments,
				me->notes ) ;
				
	FILL_ASCII_FIELD( VS_K_bm_Name,		me->basename	) ;		
	FILL_ASCII_FIELD( VS_K_bm_Directory,	me->directory	) ;		

	FILL_VALUE_FIELD( VS_K_bm_Change_Number,   me->change_number	) ;
	FILL_VALUE_FIELD( VS_K_bm_Display_Ratio,   me->display_ratio 	) ;

	if( me->flag & VS_K_no_object_located )
		FILL_VALUE_FIELD( VS_K_bm_Number_Of_Beams, 
			          0 	                ) ;
	else    FILL_VALUE_FIELD( VS_K_bm_Number_Of_Beams, 
			  	  me->number_of_beams 	) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_X_Offset,
				value	= me->X_offset ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_Y_Offset,
				value	= me->Y_offset ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_Rotation,
				value	= me->rotation,
				type 	= GRIO_ANGLE ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_Fireproofing,
				value	= me->fireproofing ) ;

	/*
	 * Turn on reference point button.
	 */
	switch( me->reference_point ) {
		case VS_e_UPP_LEFT : button = VS_K_bm_Top_Left     ; break ;
		case VS_e_LFT_MIDD : button = VS_K_bm_Center_Left  ; break ;
		default		   : /* Should not get here */
		case VS_e_BOT_LEFT : button = VS_K_bm_Bot_Left	   ; break ;
		case VS_e_TOP_MIDD : button = VS_K_bm_Top_Middle   ; break ;
		case VS_e_BOT_MIDD : button = VS_K_bm_Bot_Mid	   ; break ;
		case VS_e_UPP_RGHT : button = VS_K_bm_Top_Right	   ; break ;
		case VS_e_GEO_CENT : button = VS_K_bm_Center_Middle; break ;
		case VS_e_RGH_MIDD : button = VS_K_bm_Center_Right ; break ;
		case VS_e_BOT_RGHT : button = VS_K_bm_Bot_Right	   ; break ;
        }

	FIg_set_state_on( form, button ) ;

	/*
	 *   Turn on symmetry button.
	 */
	switch( me->symmetry ) {
		case VS_e_No_Symm	: button = VS_K_bm_No_Sym ; break ;
		case VS_e_X_Symm	: button = VS_K_bm_X_Sym  ; break ;
		case VS_e_Y_Symm	: button = VS_K_bm_Y_Sym  ; break ;
		case VS_e_XY_Symm	: button = VS_K_bm_XY_Sym ; break ;
	}

	om$send( msg = message VSfmbeamCmd.fill_section_area_and_length_gadgets( msg ),
		 targetid = my_id ) ;

	FIg_set_state_on( form, button ) ;

	*msg = MSSUCC ;

	wrapup :
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
 		return OM_S_SUCCESS ;
	
} /* method fill_form */
/*----------------------------------------------------------------------------*/
method enable_form( long *msg ) {
	
	char	*form = me->fm_ptr ;

	if( !form ) goto wrapup ;

	if( !( me->flag & VS_K_form_active ) ) {
		struct VSgadget	*label ;

		om$send(msg	= message VSfmbeamCmd.get_modifiable_gadgets(
								msg, &label ),
			targetid= my_id ) ;

		VSf_enable_form( form, label ) ;
		me->flag |= VS_K_form_active ;
	}
	wrapup :
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method disable_form( long *msg ) {
	
	char	*form = me->fm_ptr ;

	if( !form ) goto wrapup ;

	if( me->flag & VS_K_form_active ) {
		struct VSgadget	*label ;

		om$send(msg	= message VSfmbeamCmd.get_modifiable_gadgets(
							msg, &label ),
			targetid= my_id ) ;

		VSf_disable_form( form, label ) ;
		me->flag &= ~VS_K_form_active ;
	}

	wrapup :
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;

} /* method disable_form */
/*----------------------------------------------------------------------------*/
method write_to_DPB( long *msg ) {

	struct VSdpb_form_pos	B_form ;
	int			rc,
				screen,
				x,
				y,
				width,
				height ;

	if( me->flag & VS_K_no_attributes ) { goto wrapup ; }

	/*
	 * Store form's location and size.
	 */
	if( me->fm_ptr ) {
		rc = VSf_get_layout( me->fm_ptr, 
			             &screen, 
			             &x, 
			             &y, 
		                     &width, 
		                     &height ) ;
		                     
		if( rc == FI_SUCCESS ) {
			B_form.screen 	= screen ;
			B_form.x 	= x ;
			B_form.y 	= y ;
			B_form.width	= width ;
			B_form.height	= height ;

			vs$put_act_pm(	msg	= msg,
					param	= VS_e_dpb_B_form,
					p_arg	= &B_form ) ;
		}
	}

	/*
	 * Store active material.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_material,
			p_arg	= me->actMat ) ;
	/*
	 * Store active grades.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_grade,
			p_arg	= me->actGrd ) ;

	/*
	 * Store active  shape.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_type,
			p_arg	= me->actFam ) ;

	/*
	 * Store active section.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_shape,
			p_arg	= me->actPrt ) ;

	/*
	 * Store active stock, source, notes.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_stock,
			p_arg	= me->stock ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_source,
			p_arg	= me->source ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_notes,
			p_arg	= me->notes ) ;
			
	/*
	 * Store active fireproofing thickness, construction status,
	 * approval status.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_fireproofing_thk,
			p_arg	= &me->fireproofing ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_const_status,
			p_arg	= me->construction_status ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_apprv_status,
			p_arg	= me->approval_status ) ;

	/*
	 * Store active base name.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_name_pattern,
			p_arg	= me->basename ) ;

	/*
	 * Store x, y, rotation.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_x_offset,
			p_arg	= &me->X_offset ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_y_offset,
			p_arg	= &me->Y_offset ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_rotation,
			p_arg	= &me->rotation ) ;

	/*
	 * Store reference point, symmetry.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_cardinal_point,
			p_arg	= &me->reference_point ) ;

	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_B_symmetry,
			p_arg	= &me->symmetry ) ;
		
	wrapup :
		return OM_S_SUCCESS ;

} /* method write_to_DPB */
/*----------------------------------------------------------------------------*/
method initial_form_notification( 	int 	form_label,
						gadget_label ;
					double	value ;
					char	*form_ptr ) {
	
	long	msg ;
	int 	action = 0 ;

	me->flag |= VS_K_initial_ntf ;

	switch( gadget_label ) {
		case VS_K_bm_Material_Type	: action = VS_m_mat ; break ;
		case VS_K_bm_Material_Grade	: action = VS_m_grd ; break ;
		case VS_K_bm_Shape_Name		: action = VS_m_fam ; break ;
		case VS_K_bm_Section_Name	: action = VS_m_prt ; break ;
	}

	if( action ) {
		om$send(msg	= message VSfmbeamCmd.QueryRDB(
							&msg, action, TRUE ),
			targetid= my_id ) ;
	}
	
	return OM_S_SUCCESS ;

} /* method initial_form_notification */
/*----------------------------------------------------------------------------*/
method tellUser( long msgnum ) {

	char	buffer[MS_MAX_MSG_LENGTH] ;

	if( msgnum == MS_NO_MSG ) {
		*buffer = '\0' ;
	} else {
		ex$message(	msgnumb	= msgnum,
				buff	= buffer ) ;
		me->flag |= VS_K_message_set ;
	}
	VSfi_msg( me->fm_ptr, buffer ) ;

	if( *buffer && !( msgnum & 1 ) ) VS_Wait_timer( 60 ) ;

	return OM_S_SUCCESS ;

} /* method tellUser */
/*----------------------------------------------------------------------------*/
method set_initial_gadget_attributes( long *msg ) {

	VSg_chg_attr_of_gadgets( me->fm_ptr, 
				 FI_INITIAL_NOTIFY, 
				 FI_NO_COMPLETE_NOTIFY,
				 VS_K_bm_Material_Type,
				 VS_K_bm_Material_Grade,
				 VS_K_bm_Shape_Name,
				 VS_K_bm_Section_Name,
				 -1 ) ;

	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* method set_initial_gadget_attributes */
/*----------------------------------------------------------------------------*/
method draw_section_on_form( long *msg ) {
	
	char		*form = me->fm_ptr ;
	struct GRid	sectionDef ;
	
	/*
	 * The section will be drawn on the form if the active group is
	 * `Definition'.
	 */
	
#define weight 1

	if( me->ActGrp != VS_K_bm_Grp_Definition ) goto wrapup ;
	
	ex$message( msgnumb       = VS_gI_Processing,
	            justification = CENTER_JUS ) ;

	/*
	 * Get active representation.
	 */ 
	vs$cnstDefaults(	msg	= msg,
			   	symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;

	/*
	 * Get the section definition.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &sectionDef ) ;
	__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;

	/*
	 * Erase the old section drawn on the form.
	 */
	vs$repaint_gadget( form = form, gadget = VS_K_bm_Area ) ;

	/*
	 * Draw the section on the form.
	 */
	vs$draw_section_on_form( msg 		= msg,
				 form		= form,
				 gadget		= VS_K_bm_Area,
				 representation	= me->ActiveRep.representation,
				 weight 	= weight,
				 mod_env	= &me->cstEnv,
				 sectDef	= &sectionDef ) ;
				 
	/*
	 * Display section on the form.
	 */
	FIg_display( form, VS_K_bm_Area ) ;
			   
	ex$message( field = ERROR_FIELD, in_buff = "" ) ;
			
	wrapup :
		return OM_S_SUCCESS ;

#undef weight
	
} /* method draw_section_on_form */
/*----------------------------------------------------------------------------*/
method QueryRDB(	long	*msg ;
			int	action,
				fillForm ) {

	long	sts ;
	int	A ;
	char	errStr[MS_MAX_MSG_LENGTH] ;

	sts = om$send(	msg	= message VSqryRdbCmd.loadAny(
						msg, errStr, action, &A ),
			targetid= my_id ) ;

	if( sts & 1 & *msg ) {
		if( fillForm ) {

			sts = om$send(
				msg	= message VSfmbeamCmd.fillFormWithRdbData(
								msg, A ),
				targetid= my_id ) ;
		}
	} else {
		VSfi_msg( me->fm_ptr, errStr ) ;
		me->flag |= VS_K_message_set ;
		VS_Wait_timer( 60 ) ;
	}
	return OM_S_SUCCESS ;

} /* method QueryRDB */
/*----------------------------------------------------------------------------*/
method fillFormWithRdbData( long *msg ; int action ) {

#define FILL_FLIST( gadget, descr ) \
	{\
	VSfld_set_list( form, VS_K_bm_##gadget, me->descr##Count,\
			me->descr##List ) ;\
	FIfld_set_text( form, VS_K_bm_##gadget, 0, 0,\
			 me->descr##List[me->descr##Index], FALSE ) ;\
	}

	char	*form = me->fm_ptr ;

	*msg = MSSUCC ;
	if( action & VS_m_mat ) { FILL_FLIST( Material_Type	, mat ) ; }
	if( action & VS_m_grd ) { FILL_FLIST( Material_Grade	, grd ) ; }
	if( action & VS_m_fam ) { FILL_FLIST( Shape_Name	, fam ) ; }
	if( action & VS_m_prt ) { FILL_FLIST( Section_Name	, prt ) ; }
	if( action & VS_m_par ) {
		FILL_ASCII_ROW( VS_K_bm_Parameters,
				me->parCount, me->namValList ) ;
		om$send( msg	= message 
		         VSfmbeamCmd.fill_section_area_and_length_gadgets( msg ),
		         targetid = my_id ) ;
	}

#undef FILL_FLIST

	return OM_S_SUCCESS ;

} /* method fillFormWithRdbData */
/*----------------------------------------------------------------------------*/
method fill_section_area_and_length_gadgets( long *msg ) {
	
	struct	GRobj_env	section ;
	struct  GRid		sectionDef ;
	double			sectionLength,
				sectionArea ;
	char			errStr[MS_MAX_MSG_LENGTH] ;
	char			*form =  me->fm_ptr ;

	ex$message( msgnumb       = VS_gI_Processing,
	            justification = CENTER_JUS ) ;

	/*
	 * Retrieve section definition.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				errStr		= errStr,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &sectionDef ) ;
	if( !( *msg & 1 ) ) {
		ex$message( 	field 		= ERROR_FIELD,
				justification	= CENTER_JUS,
				in_buff		= errStr,
				time		= 2 ) ;
		goto wrapup ;
	}				

	/*
	 * Retrieve the graphic cross-section with 3D representation.
	 */
	vs$get_graphic_section(	msg		= msg,
				sectDef		= &sectionDef,
				representation	= AC_3D_REP,
				section		= &section ) ;
	__CheckRC( 1, *msg, "vs$get_graphic_section", wrapup ) ;

	/*
	 * Get section area and section length.
	 */
	vs$lengthAndAreaOfClPlCv( msg		= msg,
				  curveId	= &section.obj_id,
				  curveEnv	= &section.mod_env,
				  length	= &sectionLength,
				  area		= &sectionArea ) ;
				
	__CheckRC( 1, *msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;
	 
	/*
	 * Fill gadgets.
	 */
	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_Section_Length,
				value	= sectionLength,
				osnum 	= section._osnum ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_bm_Section_Area,
				type 	= GRIO_AREA,
				value	= sectionArea,
				osnum 	= section._osnum ) ;

	wrapup :
		ex$message( field 	= ERROR_FIELD,
			    in_buff	= "" ) ;

		return OM_S_SUCCESS ;

} /* method fill_section_area_and_length_gadgets */
/*----------------------------------------------------------------------------*/
method getCnstDefaults() {

	long			sts,
				msg ;
	struct GRobj_env	parent0 ;
	char			*matchKey ;
	struct GRid		*matchId ;
	GRname			name ;

	sts = om$send(	msg  	= message VSlocateCmd.getLocObjAtIndex( 
							&msg, 0, &parent0 ),
			targetid= my_id ) ;
	if( !( sts & 1 & msg ) ) {
		matchId	= NULL ;
		matchKey= NULL ;
	} else {
		matchId = &parent0._grid ;
		matchKey= me->matchKey ;
	}
	vs$getBmOrPlCstDefaults(msg		= &msg,
			   	symb_id		= me->ModuleInfo.md_id,
			   	memberClass	= me->clsCode[me->clsIndex],
			   	matchKey	= matchKey,
			   	matchId		= matchId,
			   	path		= me->cnstDir,
				symb		= &me->ActiveRep,
				level		= &me->ActiveLevel,
				display		= &me->ActiveDisplay ) ;

	me->directory = me->cnstDir ;

	/*
	 * Display suggested name.
	 */
	if( *me->basename ) {
		strcpy( name, me->basename ) ;
		VSbuildName( &msg, me->directory, name, me->basename ) ;
		FIfld_set_text( me->fm_ptr, VS_K_bm_Name, 0, 0, 
				me->basename, FALSE ) ;
	}
	FIfld_set_text( me->fm_ptr, VS_K_bm_Directory,0, 0, 
					me->directory, FALSE ) ;

	return OM_S_SUCCESS ;

} /* method getCnstDefaults */
/*----------------------------------------------------------------------------*/
/*
 * This function has been added for CR# MP5169 
 */
IGRint VSgetBeamLength(
                       struct GRobj_env *beam,
                       double           *length
                      )
{
  IGRint             retFlag = 0;  
  long		     msg,sts ;
  struct GRobj_env   section ;
  struct GRid	     sectionDef ;
  double	     sectionLength,
		     sectionArea ;
  struct GRid	     cntAxis;
  double	     len1;	

  // arg check
  if(!beam) goto wrapup;

  /*
   * Retrieve profile definition.
   */
  sts = om$send( msg	= message VSbeam.VSgetProfileDef( &msg,
							  &sectionDef ),
		 senderid = NULL_OBJID,
		 targetos = beam->obj_id.osnum,
		 targetid = beam->obj_id.objid ) ;
  __CheckRC( sts, msg, "VSbeam.VSgetProfileDef", wrapup ) ;
  
  /*
   * Retrieve the graphic cross-section with 3D representation.
   */
  vs$get_graphic_section( msg		 = &msg,
			  sectDef 	 = &sectionDef,
			  representation = AC_3D_REP,
			  section 	 = &section ) ;
  __CheckRC( 1, msg, "vs$get_graphic_section", wrapup ) ;
  
  /*
   * Get profile area and length.
   */
  vs$lengthAndAreaOfClPlCv( msg		= &msg,
			    curveId	= &section.obj_id,
			    curveEnv	= &section.mod_env,
			    length	= &sectionLength,
			    area	= &sectionArea ) ;
  
  __CheckRC( 1, msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;
  
  sts = VSgetBeamCentroidalAxis ( &msg,
				  beam->obj_id,
				  &beam->mod_env,
				  &beam->mod_env,
				  &cntAxis );
  __CheckRC(sts,  msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;
  
  sts = om$send( msg = message GRcurve.GRtotlength (
                                       &msg,
                                       &beam->mod_env.md_env.matrix_type,
                                       beam->mod_env.md_env.matrix,
                                       &len1),
		 senderid = NULL_OBJID,
		 targetid = cntAxis.objid,
		 targetos = cntAxis.osnum );
  __CheckRC( sts, msg,"GRcurve.GRtotlength",wrapup ) ;
  
  sts = vs$bulk_delete ( 	grids  = &cntAxis,
				theEnv = &beam->mod_env,
        			count  = 1 );
  *length = len1;

  //Done
  retFlag = 1;
wrapup:
  return retFlag;
}

end implementation VSfmbeamCmd ;

