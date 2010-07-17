/* $Id */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSfmplatCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfmplatCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/19  20:34:26  pinnacle
# tr179900100
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/99  ah      TR179900100 Core dump if plate has lost it's parents
 *                   Added debug statements and header
 ***************************************************************************/

class implementation VSfmplatCmd ;

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <FI.h>
#include "growner.h"
#include "EMSssprops.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
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

#define vdsDEBUGx 1

#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'
#define FILL_ASCII_FIELD( label, text ) \
	FIfld_set_text(	form, (label), 0, 0, (text), FALSE )
#define FILL_VALUE_FIELD( label, val ) \
	FIfld_set_value( form, (label), 0, 0, (double) (val), FALSE )
#define FILL_FIELD_ALIST( label, size, list ) \
	VSfld_set_list( form, (label), (size), (list) ) ;
#define FILL_ASCII_MCF( label, column, size, list ) \
	VSmcf_set_list_text( form, (label), (column), (size), (list) )

extern int COB_FI_form_notification() ;
/*----------------------------------------------------------------------------*/
method initToFailure() { me->flag = VS_K_init_failed ; return OM_S_SUCCESS ; }
/*----------------------------------------------------------------------------*/
method createForm() {

	char	*form ;
	int 	isLoaded ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.createForm\n");
#endif

	/*
	 * Init instance data.
	 */	
	me->source		= NULL ;
	me->notes		= NULL ;
	me->approval_status 	= NULL ;
	me->construction_status = NULL ;
	me->usrNamList		= NULL ;
	me->usrSynList		= NULL ;
	me->usrAttCount		= 0 ;
	me->flag		= 0 ;
	*me->prompt		= '\0' ;

	/*
	 * Init form.
	 */
	me->ret = FIf_new( 1, "VSplModPlat.fm", COB_FI_form_notification, 
			   &me->fm_ptr ) ;
			   
	if( me->ret ) { me->flag |= VS_K_init_failed ; goto wrapup ; }
		 
	FIf_set_cmd_oid_os( me->fm_ptr, my_id, OM_Gw_current_OS ) ;
	
	form = me->fm_ptr ;

	/*
	 * Initialize group of gadgets. The label is 100 + gadget label which
	 * activates the group.  
	 */
	FIg_new( form, FI_GROUP , VS_K_pl_Grp_Definition   ) ;
	FIg_new( form, FI_GROUP , VS_K_pl_Grp_Manipulation ) ;
	FIg_new( form, FI_GROUP , VS_K_pl_Grp_MTO          ) ;
	FIg_new( form, FI_GROUP , VS_K_pl_Grp_UA           ) ;

	/* Initialize group 'Definition' */

	FIgrp_add_to_group( form,
			    VS_K_pl_Grp_Def_Gadget,
			    VS_K_pl_Grp_Definition ) ;
			    
	/* Initialize group 'Manipulation' */
	
	FIgrp_add_to_group( form,
			    VS_K_pl_Grp_Manip_Gadget,
			    VS_K_pl_Grp_Manipulation ) ;
			    	
	/* Initialize group 'MTO' */

	FIgrp_add_to_group( form,
			    VS_K_pl_Grp_MTO_Gadget,
			    VS_K_pl_Grp_MTO ) ;

	/* Initialize group 'User Attributes' */
	
	FIgrp_add_to_group( form,
			    VS_K_pl_Grp_User_Attributes,
			    VS_K_pl_Grp_UA ) ;

	me->ActGrp = VS_K_pl_Grp_Default ;

	/*
	 * See if a plate has already been placed.
	 */
	VSdpb_loaded_with_plate( &isLoaded ) ;

	if( isLoaded ) {
		struct VSdpb_form_pos	P_form ;

		vs$get_act_pm(	msg	= &me->ret,
				param	= VS_e_dpb_P_form,
				p_arg	= &P_form ) ;

		if( me->ret & 1 ) {
			VSf_set_layout( form,
					(int) P_form.screen,
					P_form.x,
					P_form.y,
					P_form.width,
					P_form.height ) ;
		}

	}
	 /*
	  * Else form will be displayed with default location and size.
	  */
		
	om$send(msg	= message VSfmplatCmd.overrideForm(),
		targetid= my_id ) ;

	vs$get_member_classes_from_RDB( msg 	= &me->ret,
					clsList	= me->clsCode,
					keyList = me->clsMsg ) ;
	me->clsIndex = 0 ;

	vs$get_mb_plate_types_from_RDB(  msg		= &me->ret,
					 typeList	= me->typCode,
					 keyList	= me->typMsg ) ;
	me->typIndex = 0 ;

	om$send(msg	= message VSfmplatCmd.load_attributes( &me->ret ),
		targetid= my_id ) ;

	if( me->ret & 1 ) {
		om$send(msg	= message VSfmplatCmd.fill_form( &me->ret ),
			targetid= my_id ) ;

	 	/*
	 	 * Display form.
	 	 */
		VSf_display( form ) ;

		/*
		 * First wake-up after init must enable form.
		 */
	 	me->flag &= ~VS_K_form_active ;
		om$send(msg	= message VSfmplatCmd.enable_form( &me->ret ),
			targetid= my_id ) ;
	 	
	 	me->flag &= ~VS_K_init_failed ;

	} else {
		me->flag |=  VS_K_init_failed ;
	}

	me->flag |= VS_K_no_object_located ;
	
	me->suppressHilite = FALSE ;

	wrapup :

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.createForm\n");
#endif
		return OM_S_SUCCESS ;

} /* method createForm */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	char	*form = me->fm_ptr ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.wakeup\n");
#endif

	if( me->flag & VS_K_init_failed ) {
#if vdsDEBUG
	printf("@1@ VSfmplatCmd.wakeup\n");
#endif
	  return OM_S_SUCCESS ;
	}
	
	me->ret = om$send(	msg	= message VSlocateCmd.wakeup( pos ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	if( !( me->ret & 1 ) ) goto wrapup ;

	if( form ) {
		/*
		 * Show support's normal.
		 */
		om$send(msg	= message VSfmplatCmd.display_support_normal( GRhd ),
			targetid= my_id ) ;

		if( me->ret & 1 ) {
			FILL_ASCII_FIELD( VS_K_pl_Directory,	me->directory	) ;	
			om$send(msg	= message VSfmplatCmd.enable_form( &me->ret ),
				targetid= my_id ) ;
		}
	}

	wrapup :
		if( !( me->ret & 1 ) ) me->flag |= VS_K_cmd_error ;
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.wakeup\n");
#endif
		return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

#if vdsDEBUG
	printf(">>> VSfmplatCmd.sleep\n");
#endif
	if( me->flag & VS_K_init_failed ) {

#if vdsDEBUG
	printf("@1@ VSfmplatCmd.delete\n");
#endif
	  return OM_S_SUCCESS ;
	}
	
	me->flag |= VS_K_command_stacked ;

	me->ret = om$send(	msg	= message VSlocateCmd.sleep( pos ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	if( ( me->ret & 1 ) && me->fm_ptr ) {
		/*
		 * Erase support's highlighted normal.
		 */
		om$send(msg	= message VSfmplatCmd.display_support_normal( GRhe ),
			targetid= my_id ) ;


		if( me->ret & 1 ) {
			om$send(msg	= message VSfmplatCmd.disable_form( &me->ret ),
				targetid= my_id ) ;
		}
	}

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.delete\n");
#endif
	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int notUsed ) {

#if vdsDEBUG
	printf(">>> VSfmplatCmd.delete\n");
#endif

	if( me->flag & VS_K_init_failed ) {
		ex$message( msgnumb       = VS_gE_ErrEncCmdTrm,
			    justification = CENTER_JUS ) ;
		goto wrapup ;
	}

	/*
	 * Store active set-up to DPB.
	 */
	om$send(msg	= message VSfmplatCmd.write_to_DPB( &me->ret ),
		targetid= my_id ) ;

	/*
	 * Store active user attributes if any.
	 */
	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount )  {
		struct GRid	newUA ;
		
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename  = VS_K_ActPlUAttr,
				      nbEntries	= me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &newUA ) ;
	}

	/*
	 * Now free instance data.
	 */
	_FREE( me->source	) ;
	_FREE( me->stock	) ;
	_FREE( me->notes	) ;
	_FREE( me->approval_status  	) ;
	_FREE( me->construction_status  ) ;

	VSfreeList( me->usrAttCount, me->usrNamList) ;
	VSfreeList( me->usrAttCount, me->usrSynList) ;
	
	if( me->fm_ptr ) FIf_delete( me->fm_ptr ) ;

	wrapup :
	me->ret = om$send(	msg	= message VSlocateCmd.delete( notUsed ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.delete\n");
#endif
	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method overrideForm() {

	long		msg ;
	struct VSgadget	*label ;
	char		*form = me->fm_ptr ;	/* Unburdens compiler */

#if vdsDEBUG
	printf(">>> VSfmplatCmd.overrideForm\n");
#endif
	VSg_chg_attr_of_gadgets( form,
				 FI_INITIAL_NOTIFY,
				 FI_NO_COMPLETE_NOTIFY,
				 VS_K_pl_Material_Type,
				 VS_K_pl_Material_Grade,
				 VS_K_pl_Plate_Type,
				 VS_K_pl_Thickness,
				 -1 ) ;

	om$send( msg	= message VSlocateCmd.formOpByPtr( form,
							   VS_FIf_INITNTFY_ON ),
		 targetid = my_id ) ;

	/*
	 * Disable possible forbidden gadgets.
	 */
	om$send(msg	= message VSfmplatCmd.get_modifiable_gadgets(
							&msg, &label ),
		targetid= my_id ) ;

	for( ; label->label != -1 ; label++ ) {
		if( !label->touchable ) {
			FIg_disable( form, label->label ) ;
		}
	}
	
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.overrideForm\n");
#endif
	return OM_S_SUCCESS ;

} /* method overrideForm */
/*----------------------------------------------------------------------------*/
method display_support_normal( enum GRdpmode mode ) {

	struct GRobj_env	support ;	/* First support	*/
	long			sts,		/* OM return code	*/
				msg ;		/* Completion code	*/

#if vdsDEBUG
	printf(">>> VSfmplatCmd.display_support_normal\n");
#endif

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							&msg, 1, &support ),
			targetid= my_id ) ;
	if( sts == OM_I_CHAN_EMPTY ) goto wrapup ;

	/*
	 * Update directory field
	 * MIGHT BE IN A SEPARATE ACTION NOT TO BE CALLED ALL THE TIME !
	 */
	vs$cnstDefaults(	msg	= &msg,
				symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				matchKey= "plate",
				matchId	= &support._grid,
				path	= me->cnstDir,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;

	/*
	 * Do not use PWD any longer.
	 */
	me->directory = me->cnstDir ;

	if( *me->basename ) {
		/*
		 * Display suggested name.
		 */
		GRname name ;

		strcpy( name, me->basename ) ;
		VSbuildName( &msg, me->directory, name, me->basename ) ;
		FIfld_set_text( me->fm_ptr, VS_K_pl_Name, 0, 0, 
				me->basename, FALSE ) ;
	}

	FIfld_set_text( me->fm_ptr, VS_K_pl_Directory, 0, 0, 
					me->directory, FALSE ) ;

	VSdisplaySurfaceNormal(	&msg,
				&support,
				me->orientation == VS_K_USE_REV_NORM,
				&me->ActiveDisplay,
				mode ) ;
	wrapup :
		me->ret = VS_K_ACT_SUCCESS ;
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.display_support_normal\n");
#endif
		return OM_S_SUCCESS ;

} /* method display_support_normal */
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
	double	value ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.fill_form\n");
#endif

	if( me->flag & VS_K_no_attributes ) { *msg = MSSUCC ; goto wrapup ; }

	FILL_FIELD_ALIST( VS_K_pl_Material_Type	, me->matCount, me->matList ) ;
	FILL_FIELD_ALIST( VS_K_pl_Material_Grade, me->grdCount, me->grdList ) ;
	FILL_FIELD_ALIST( VS_K_pl_Plate_Type	, me->famCount, me->famList ) ;	
	FILL_FIELD_ALIST( VS_K_pl_Thickness	, me->prtCount, me->prtList ) ;

	VSfld_set_list_with_msgkeys(	form,
					VS_K_pl_Member_Class,
					VS_rdb_MAXCLASSES,
					me->clsMsg ) ;
	VSfld_set_list_with_msgkeys(	form,
					VS_K_pl_Member_Type,
					VS_rdb_MAXPLTYPES,
					me->typMsg ) ;

	if( me->usrAttCount ) {
		FILL_ASCII_MCF( VS_K_pl_Mcf_User_Attributes,
				0, 
				me->usrAttCount, 
				me->usrNamList 			) ;
		FILL_ASCII_MCF( VS_K_pl_Mcf_User_Attributes,
				1, 
				me->usrAttCount, 
				me->usrSynList 			) ;
	}

	FILL_ASCII_FIELD( VS_K_pl_Material_Type	, me->actMat ) ;
	FILL_ASCII_FIELD( VS_K_pl_Material_Grade, me->actGrd ) ;
	FILL_ASCII_FIELD( VS_K_pl_Plate_Type	, me->actFam ) ;	
	FILL_ASCII_FIELD( VS_K_pl_Thickness	, me->actPrt ) ;

	FILL_ASCII_FIELD( VS_K_pl_Member_Class	, 
			  VSmsgkey2string( me->clsMsg[me->clsIndex] ) ) ;
	FILL_ASCII_FIELD( VS_K_pl_Member_Type	,
			  VSmsgkey2string( me->typMsg[me->typIndex] ) ) ;

	FILL_ASCII_FIELD( VS_K_pl_Stock_Number,	me->stock	        ) ;
	FILL_ASCII_FIELD( VS_K_pl_Source,	me->source	        ) ;
	FILL_ASCII_FIELD( VS_K_pl_Approval_Status, 
						me->approval_status     ) ;
	FILL_ASCII_FIELD( VS_K_pl_Construction_Status, 
						me->construction_status ) ;

	VSfld_set_lines(	form,
				VS_K_pl_Comments,
				me->notes ) ;
	FILL_ASCII_FIELD( VS_K_pl_Name,		me->basename	) ;		
	FILL_ASCII_FIELD( VS_K_pl_Directory,	me->directory	) ;		

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pl_Cut_Off,
				osnum	= me->cstEnv.md_id.osnum,
				value	= me->cut_off ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pl_Cut_Off,
				osnum	= me->cstEnv.md_id.osnum,
				value	= me->cut_off ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pl_Offset,
				osnum	= me->cstEnv.md_id.osnum,
				value	= me->offset ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pl_Fireproofing,
				osnum	= me->cstEnv.md_id.osnum,
				value	= me->fireproofing ) ;

	FILL_VALUE_FIELD( VS_K_pl_Change_Number,   me->change_number	) ;

	value = me->orientation == VS_K_USE_REV_NORM ? 1 : 0 ;
	FIg_set_state(	form,
			VS_K_pl_Orientation,
			(int) value ) ;

	FILL_VALUE_FIELD( VS_K_pl_Number_Of_Plates, me->number_of_plates ) ;

	*msg = MSSUCC ;

	wrapup :
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.fill_form\n");
#endif
		return OM_S_SUCCESS ;
	
} /* method fill_form */
/*----------------------------------------------------------------------------*/
method QueryRDB( long	*msg ; int action, fillForm ) {

	long	sts ;
	int	A ;
	char	errStr[MS_MAX_MSG_LENGTH] ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.QueryRDB\n");
#endif
	sts = om$send(	msg	= message VSqryRdbCmd.loadAny(
						msg, errStr, action, &A ),
			targetid= my_id ) ;

	if( sts & 1 & *msg ) {
	
		if( fillForm ) {

			sts = om$send(
				msg	= message VSfmplatCmd.fillFormWithRdbData(
								msg, A ),
				targetid= my_id ) ;
		}
	} else {
		VSfi_msg( me->fm_ptr, errStr ) ;
		me->flag |= VS_K_message_set ;
		VS_Wait_timer( 60 ) ;
	}

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.QueryRDB\n");
#endif
	return OM_S_SUCCESS ;

} /* method QueryRDB */
/*----------------------------------------------------------------------------*/
method fillFormWithRdbData( long *msg ; int action ) {

	char	*form = me->fm_ptr ;

#define FILL_FLIST( gadget, descr ) \
	{\
	VSfld_set_list( form, VS_K_pl_##gadget, me->descr##Count,\
			me->descr##List ) ;\
	FIfld_set_text( form, VS_K_pl_##gadget, 0, 0,\
			 me->descr##List[me->descr##Index], FALSE ) ;\
	}
#define UPDATE_CUTOFF( v ) \
	om$send( msg	= message VSfmplatCmd.updCutOff( msg , (v) ),\
		 targetid = my_id ) ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.fillFormWithRdbData\n");
#endif

	if( action & VS_m_mat ) { FILL_FLIST( Material_Type	, mat ) ; }
	if( action & VS_m_grd ) { FILL_FLIST( Material_Grade	, grd ) ; }
	if( action & VS_m_fam ) { FILL_FLIST( Plate_Type	, fam ) ; }
	if( action & VS_m_prt ) { FILL_FLIST( Thickness		, prt ) ;
		UPDATE_CUTOFF( me->cut_off ) ;
	}

#undef FILL_FLIST
#undef UPDATE_CUTOFF

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.fillFormWithRdbData\n");
#endif
	return OM_S_SUCCESS ;

} /* method fillFormWithRdbData */
/*----------------------------------------------------------------------------*/
method enable_form( long *msg ) {

	char	*form = me->fm_ptr ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.enable_form\n");
#endif
	
	if( !form ) goto wrapup ;

	if( !( me->flag & VS_K_form_active ) ) {
		struct VSgadget	*label ;

		om$send( msg	= message VSfmplatCmd.get_modifiable_gadgets(
								msg, &label ),
			 targetid= my_id ) ;

		VSf_enable_form( form, label ) ;
		me->flag |= VS_K_form_active ;
	}
	wrapup :
		*msg = MSSUCC ;
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.enable_form\n");
#endif
		return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method disable_form( long *msg ) {

	char	*form = me->fm_ptr ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.disable_form\n");
#endif
	if( !form ) goto wrapup ;

	if( me->flag & VS_K_form_active ) {
		struct VSgadget	*label ;

		om$send(msg	= message VSfmplatCmd.get_modifiable_gadgets(
								msg, &label ),
			targetid= my_id ) ;

		VSf_disable_form( form, label ) ;
		me->flag &= ~VS_K_form_active ;
	}
	wrapup :
		*msg = MSSUCC ;
#if vdsDEBUG
	printf("@@@ VSfmplatCmd.disable_form\n");
#endif
		return OM_S_SUCCESS ;

} /* method disable_form */
/*----------------------------------------------------------------------------*/
/* TR179900100 Plates can lose their parents sometimes, if this happens
 * then of course you cannot get attribute values from them.
 * Really should never get here but sometimes during modify plate you do
 * and the me->data pointers could be null causing crash
 * fix in put_act_pm
 */
method write_to_DPB( long *msg ) {

	struct VSdpb_form_pos	P_form ;
	int			rc,
				screen,
				x,
				y,
				width,
				height ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.write_to_DPB\n");
#endif
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
			P_form.screen 	= screen ;
			P_form.x 	= x ;
			P_form.y 	= y ;
			P_form.width	= width ;
			P_form.height	= height ;

			vs$put_act_pm(	msg	= msg,
					param	= VS_e_dpb_P_form,
					p_arg	= &P_form ) ;
		}
	}

#if vdsDEBUG
        if (me->stock == NULL) {
	  printf("Stock value is null\n");
	  goto wrapup;
	}
	
	printf("    Name   '%s'\n",me->basename);
	printf("    form stored\n");
#endif

	/*
	 * Store active material.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_material,
			p_arg	= me->actMat ) ;

	/*
	 * Store active grade.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_grade,
			p_arg	= me->actGrd ) ;

#if vdsDEBUG
	printf("    mat/grade stored\n");
	printf("    Family  '%s'\n",me->actFam);
	printf("    thkName '%s'\n",me->actPrt);
	printf("    thkVal  '%f'\n",me->actPar);
#endif
	/*
	 * Store active familiy.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_type,
			p_arg	= me->actFam ) ;

	/*
	 * Store active thickness name.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_thkname,
			p_arg	= me->actPrt ) ;

	/*
	 * Store active thickness value.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_thickness,
			p_arg	= &me->actPar ) ;

#if vdsDEBUG
	printf("    family/thickness stored\n");
	printf("    Stock  '%s'\n",me->stock);
	printf("    Source '%s'\n",me->source);
	printf("    Notes  '%s'\n",me->notes);
	printf("    Name   '%s'\n",me->basename);
#endif
	/*
	 * Store active stock, source, notes.
	 */
	
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_stock,
			p_arg	= me->stock ) ;
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_source,
			p_arg	= me->source ) ;
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_notes,
			p_arg	= me->notes ) ;

#if vdsDEBUG
	printf("    stock/source/notes stored\n");
#endif
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

#if vdsDEBUG
	printf("    fire/cons/app stored\n");
#endif
	/*
	 * Store active base name.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_name_pattern,
			p_arg	= me->basename ) ;

#if vdsDEBUG
	printf("    basename stored\n");
#endif
	/*
	 * Store active plate orientation.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_orientation,
			p_arg	= &me->orientation ) ;

	/*
	 * Store active plate offset.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_offset,
			p_arg	= &me->offset ) ;

	/*
	 * Store active cut-off thickness.
	 */
	vs$put_act_pm(	msg	= msg,
			param	= VS_e_dpb_P_cut_off,
			p_arg	= &me->cut_off ) ;

#if vdsDEBUG
	printf("    orien/offset/cutoff stored\n");
#endif

	wrapup :

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.write_to_DPB\n");
#endif
		return OM_S_SUCCESS ;

} /* method write_to_DPB */
/*----------------------------------------------------------------------------*/
method initial_form_notification( 	int 	form_label,
						gadget_label ;
					double	value ;
					char	*form_ptr ) {

	long	msg ;
	int	action = 0 ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.form_notification, %d\n",gadget_label);
#endif
	me->flag |= VS_K_initial_ntf ;
		
	switch( gadget_label ) {
		case VS_K_pl_Material_Type	: action = VS_m_mat ; break ;
		case VS_K_pl_Material_Grade	: action = VS_m_grd ; break ;
		case VS_K_pl_Plate_Type		: action = VS_m_fam ; break ;
		case VS_K_pl_Thickness		: action = VS_m_prt ; break ;
	}
	if( action ) {
		om$send(msg	= message VSfmplatCmd.QueryRDB(
							&msg, action, TRUE ),
			targetid= my_id ) ;
	}

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.form_notification, %d\n",gadget_label);
#endif
	return OM_S_SUCCESS ;

} /* method initial_form_notification */
/*----------------------------------------------------------------------------*/
method tellUser( long msgnum ) {

	char	buffer[MS_MAX_MSG_LENGTH] ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.tellUser\n");
#endif

	if( msgnum == MS_NO_MSG ) {
		*buffer = '\0' ;
	} else {
		ex$message(	msgnumb	= msgnum,
				buff	= buffer ) ;
		me->flag |= VS_K_message_set ;
	}
	VSfi_msg( me->fm_ptr, buffer ) ;

	if( *buffer && !( msgnum & 1 ) ) VS_Wait_timer( 60 ) ;

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.tellUser\n");
#endif
	return OM_S_SUCCESS ;

} /* method tellUser */
/*----------------------------------------------------------------------------*/
method updCutOff( long *msg ; double value ) {
	
	char		*form = me->fm_ptr ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.updCutOff\n");
#endif

	if( me->flag & VS_K_deflt_cutoff ) {
		me->cut_off = me->actPar ;
	} else {
		if( value >= me->actPar ) {
			me->cut_off = value ;
		} else {
			/* Bad cut-off value */
			om$send( msg	= 
				 message VSfmplatCmd.tellUser( VS_gW_BadCutOff),
				 targetid = my_id ) ;
			if( me->cut_off <= me->actPar ) {
				/* Cut-off value = thickness */
				me->flag |= VS_K_deflt_cutoff ;
				me->cut_off = me->actPar ;
			} /* else Cut-off inchanged */
		}
	}

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pl_Cut_Off,
				osnum	= me->cstEnv.md_id.osnum,
				value	= me->cut_off ) ;

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.updCutOff\n");
#endif
	return OM_S_SUCCESS ;
	
} /* method updCutOff */
/*----------------------------------------------------------------------------*/
method getCnstDefaults() {

	long			sts,
				msg ;
	struct GRobj_env	parent0 ;
	char			*matchKey ;
	struct GRid		*matchId ;
	GRname			name ;

#if vdsDEBUG
	printf(">>> VSfmplatCmd.getCnstDefaults\n");
#endif
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
		FIfld_set_text( me->fm_ptr, VS_K_pl_Name, 0, 0, 
				me->basename, FALSE ) ;
	}
	FIfld_set_text( me->fm_ptr, VS_K_pl_Directory,0, 0, 
					me->directory, FALSE ) ;

#if vdsDEBUG
	printf("@@@ VSfmplatCmd.getCnstDefaults\n");
#endif
	return OM_S_SUCCESS ;

} /* method getCnstDefaults */
/*----------------------------------------------------------------------------*/

end implementation VSfmplatCmd ;

