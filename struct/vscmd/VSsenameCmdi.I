/*
	I/STRUCT
*/
class implementation VSsenameCmd ;

#include <stdio.h>
#include <FI.h>
#include "COBmacros.h"
#include "msmacros.h"
#include "madef.h"
#include "dp.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vssnformdef.h"
#include "vsformmacros.h"
#include "vscmdmacros.h"
#include "vsdpb.h"
#include "vssectiondef.h"
#include "vsprofmacros.h"
#include "vscmddef.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "EMSifmacros.h"
#include "vsformproto.h"
#include "vsioproto.h"

#define CURRENT_FACE (-1)
#define FORM	      0

static 	int	x_pos,
		y_pos,
		s_pos ;

from GRowner	import	GRget_components ;
from GRgraphics	import	GRdisplay ;
from GRgraphics import	GRgetobjinfo ;
/*----------------------------------------------------------------------------*/
method mouse( long * msg ; char * form ; int x , y ) {

	char 	info[MS_MAX_MSG_LENGTH] ;
	int	row,
		offset ;

	*msg = MSSUCC ;

	FIfld_get_row_offset( form, VS_K_sn_Side_Name, &offset ) ;

	/*
	 * Display the meaning of a field as mouse cursor flies over the form.
	 */
	if( VSf_is_cursor_in_fld_row( form, VS_K_sn_Side_Name, x, y, &row ) ) {
	
	  if( me->lastHilitedRow != row ) {

	    ex$message(	msgnumb	= me->ldescrKeys[me->rowToFcIndex[row]],
	                buff	= info ) ;

	    FIg_erase(    form, VS_K_sn_Dyn_Txt ) ;
	    FIg_set_text( form, VS_K_sn_Dyn_Txt, info ) ;
	    FIg_display(  form, VS_K_sn_Dyn_Txt ) ;

	    if( -1 != me->lastHilitedRow ) {
	      VSfld_flip_row_block(	form,
					VS_K_sn_Side_Name,
					me->lastHilitedRow - offset,
					0, 1 ) ;
	    }

	    VSfld_flip_row_block(	form,
					VS_K_sn_Side_Name,
					row - offset,
					0, 1 ) ;

	    me->lastHilitedRow = row ;
	  }
	} else if( -1 != me->lastHilitedRow ) {

	  VSfld_flip_row_block(	form,
				VS_K_sn_Side_Name,
				me->lastHilitedRow - offset,
				0, 1 ) ;

	  FIg_erase(    form, VS_K_sn_Dyn_Txt ) ;
	  FIg_set_text( form, VS_K_sn_Dyn_Txt, "" ) ;
	  FIg_display(  form, VS_K_sn_Dyn_Txt ) ;

	  me->lastHilitedRow = -1 ;
	}

	return OM_S_SUCCESS ;

} /* method mouse */
/*----------------------------------------------------------------------------*/
method window_notification( int form_label, event ; char *form ) {

	if( FI_REFRESH == event ) {

	  om$send( msg      = message VSsenameCmd.drwPrflOnForm( CURRENT_FACE ),
		   targetid = my_id ) ;
	}
	return OM_S_SUCCESS ;

} /* method window_notification */
/*----------------------------------------------------------------------------*/
method button_notification(	int	form_label,
					xpos,
					ypos,
					button_number,
					transition,
					time_tag ;
				char	*form ;
				int	*rc ) {

	long	msg ;
	int	resp = VS_K_DYN_MOUSE ;

	/*
	 * A button press stops the dynamic mouse notification so restart it.
	 */
	ex$putque( msg = &msg, response = &resp ) ;

	*rc = 0 ;

	return OM_S_SUCCESS;

} /* method button_notification */
/*----------------------------------------------------------------------------*/
method initCmd( int *sts ) {

	me->count		=  0 ;
	me->lastSelectedRow	= -1 ;

	/*
	 * Display form at its last location.
	 */
	if( x_pos != 0 || y_pos != 0 || s_pos != 0 ) {
		FIf_set_location( me->forms[0].form_ptr, x_pos, y_pos ) ;
		FIf_set_screen(   me->forms[0].form_ptr, s_pos ) ;
	}
	return OM_S_SUCCESS ;

} /* method initCmd */
/*----------------------------------------------------------------------------*/
method repaint_form( int * sts ) {

	char 	*form = me->forms[0].form_ptr ;

	/*
	 * Erase the previous profile drawn on the form.
	 */
	vs$repaint_gadget( form = form, gadget = VS_K_sn_Rectangle ) ;

	/*
	 * Empty the message field.
	 */
	FIfld_delete_rows( form, FI_MSG_FIELD, 0, 1 ) ;

	return OM_S_SUCCESS ;

} /* method repaint_form */
/*----------------------------------------------------------------------------*/
method disable_gadgets( int *sts ) {

	char 	*form = me->forms[0].form_ptr ;

	/*
	 * Disable list field and both exit buttons.
	 */
	FIfld_set_mode( form, VS_K_sn_Side_Name, 0, FI_REVIEW ) ;
	vs$g_disable_gadgets( form = form, list	= `FI_ACCEPT, FI_EXECUTE` ) ;
	
	return OM_S_SUCCESS ;

} /* method disable_gadgets */
/*----------------------------------------------------------------------------*/
method resetCmd() {

	long		msg ,
			descrKeys[VS_K_sc_MAXFACES] ;	/* Message Key   */
	char		face_name[MS_MAX_MSG_LENGTH] ;	/* Name selected */
	int		il,				/* Index in list */
			i ;

	me->nbNames		= VS_K_sc_MAXFACES ;
	me->lastSelectedRow	= -1 ;
	me->lastHilitedRow	= -1 ;

	/*
	 * Init the correspondance tables.
	 */
	for( i  = 0 ; i < VS_K_sc_MAXFACES ; i++ ) me->rowToFcIndex[i] = i ;
  
	/*
	 * Get standard names of faces from include file.
	 */
	vs$getComponentDescr(	msg		= &msg,
				descrKeys 	= descrKeys,
				ldescrKeys 	= me->ldescrKeys ) ;
	
	/*
	 * Init all field lists.
	 */
	for( il = 0 ; il < VS_K_sc_MAXFACES ; il++ ) {

		ex$message( msgnumb = descrKeys[il], buff = face_name ) ;

		FIfld_set_text(	me->forms[0].form_ptr, VS_K_sn_Side_Name,
				il, 0, face_name, FALSE ) ;
	}

	return OM_S_SUCCESS ;

} /* method resetCmd */
/*----------------------------------------------------------------------------*/
method unhiliteProfile( int *sts ) {

	struct	GRlc_info	*section = me->event1.located_object ;

	/*
	 * Unhighlight the selected composite curve.
	 */
	vs$bulk_display(	grids	= &section->located_obj,
				theEnv	= &section->module_info,
				dpmode	= GRhe ) ;
	return OM_S_SUCCESS ;

} /* method unhiliteProfile */
/*----------------------------------------------------------------------------*/
method getCtrAndCmpsOfPrfl( int *sts ) {

	char 			*form	= me->forms[0].form_ptr ;
	long			msg ;
	int			rc ;
	struct	GRlc_info	*profile= me->event1.located_object ;
	
	/*
	 * Store composite curve to avoid problem during init.
	 */
	om$send(msg	= message VSlocateCmd.addLocObj(
							&profile->located_obj,
							&profile->module_info,
							0 ),
		targetid= my_id ) ;

	/*
	 * Enable field list.
	 */
	FIfld_set_mode( form, VS_K_sn_Side_Name, 0, FI_SINGLE_SELECT ) ;

	/*
	 * Find the center of the profile.
	 */
	{
	IGRboolean cardOpt = FALSE ;
	VScardpoint_to_vector(	&msg,
				&profile->module_info,
				&profile->located_obj,
				&cardOpt,
				VS_e_GEO_CENT,
				me->center );
	}

	/*
	 * Find the components of the composite and their number.
	 */
	om$send(msg	= message GRowner.GRget_components( 
							&msg,
						      	&me->cstEnv, 
							me->component_grid,
						      	VS_K_sc_MAXFACES + 1, 
							&me->count, 
							0,
							VS_K_sc_MAXFACES + 1 ),
		targetid= profile->located_obj.objid,
		targetos= profile->located_obj.osnum ) ;

	/*
	 * Does the composite have too many components ?
	 */
	if( me->count > VS_K_sc_MAXFACES ) {

		ex$message(	msgnumb		= VS_gW_TooManyFc,
				justification	= CENTER_JUS ) ;

		om$send(msg	= message VSsenameCmd.unhiliteProfile( &rc ),
			targetid= my_id ) ;

		FIfld_set_mode( form, VS_K_sn_Side_Name, 0, FI_REVIEW ) ;

		me->ret = VS_K_RESTART_CMD ;
	} else {
		int		clockwise ;
		IGRvector	positiveZ ;

		/*
		 * Check that curve is oriented clockwise.
		 */
		positiveZ[0] = positiveZ[1] = 0 ; positiveZ[2] = 1 ;

		vs$isPlanarCurveClockwise(
					msg		= &msg,
					cvId		= &profile->located_obj,
					cvEnv		= &profile->module_info,
					refVector	= positiveZ,
					isClockwise	= &clockwise ) ;
		if( ( msg & 1 ) && !clockwise ) {
			ex$message(
				msgnumb		= VS_gW_CvNotClkWise,
				field		= KEYIN_FIELD,
				justification	= CENTER_JUS ) ;

			me->ActiveDisplay.weight = 2 ;
			EFdisplay_curve_normal_or_tangent(	
							profile,
							NULL,
							FALSE,
							FALSE,
							my_id,
							GRhd,
							&me->ModuleInfo,
							&me->ActiveDisplay,
							&msg ) ;
		}
		me->ret = VS_K_ACT_SUCCESS ;
	}

	return OM_S_SUCCESS ;

} /* method getCtrAndCmpsOfPrfl */
/*----------------------------------------------------------------------------*/
method drwPrflOnForm( int faceNo ) {

	struct	GRlc_info	*section	= me->event1.located_object ;
	char 			*form		= me->forms[0].form_ptr,
				info[MS_MAX_MSG_LENGTH] ;
	long			msg ;
	int			rc ;
#define weight 	1
#define bold	3
	struct	GRobj_info	nature ; /* Nature of the component */ 

	/*
	 * Action possible only if a composite is being computed.
	 */
	if( me->count != 0 ) {
		/*
	 	 * If -1 is given as parameter the current face is bolded.
	 	 */

		if( faceNo == CURRENT_FACE ) {
			faceNo = VS_K_sc_MAXFACES - me->nbNames ;
		}
		/*
	 	 * Erase the previous profile drawn on the form.
	 	 */
		vs$repaint_gadget( form	= form, gadget = VS_K_sn_Rectangle ) ;

		/*
	 	 * Unhighlight the previous state.
	 	 */
		om$send(msg	= message VSsenameCmd.unhiliteProfile( &rc ),
			targetid= my_id ) ;

		/*
	 	 * Draw the profile on the form.
	 	 */
		vs$draw_curve_on_form(	msg 	= &msg,
					form	= form,
					gadget	= VS_K_sn_Area,
					weight 	= weight,
					refPoint= me->center,
					curveEnv= &section->module_info ,
					curveId	= &section->located_obj ) ;
	
		/*
	 	 * Draw the component curve of number `faceNo'.
	 	 */
		if( faceNo < me->count ) {
			vs$draw_curve_on_form(
				msg 		= &msg,
				form		= form,
				gadget		= VS_K_sn_Area,
				weight 		= bold,
				refPoint	= me->center,
				curveEnv	= &section->module_info ,
				curveId		= &me->component_grid[faceNo],
				scaleCvId	= &section->located_obj ) ;
			/*
		 	 * Show the nature of the component.
		 	 */
			om$send(msg	= message GRgraphics.GRgetobjinfo(
								&msg, &nature ),
				targetid= me->component_grid[faceNo].objid,
				targetos= me->component_grid[faceNo].osnum ) ;

			ex$message(	field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					in_buff		= nature.type ) ;

			/*
		 	 * Highlight the component of the composite curve.
		 	 */
			vs$bulk_display(
				grids	= me->component_grid + faceNo,
				theEnv	= &section->module_info,
				dpmode	= GRhd ) ;
			/*
	 	 	 * Display the number of the face to be named.
	 	 	 */
			ex$message(	msgnumb	= VS_gI_CmpInfo,
					buff	= info,
					type	= "%d%s",
					var	= `faceNo, nature.type` ) ;

			FIfld_set_text( form, FI_MSG_FIELD, 0, 0, info, FALSE );
		} else 	{
			vs$g_enable_gadgets(	form	= form,
						list	= `FI_ACCEPT,
							   FI_EXECUTE` ) ;

			FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
					VSmsgkey2string( VS_gI_AllNamed ),
					FALSE ) ;

			FIfld_set_mode( form, VS_K_sn_Side_Name, 0, FI_REVIEW );
		}
		/*
	 	 * Display profile on form.
		 */
		FIg_display( form, VS_K_sn_Area ) ;
	}

#undef weight
#undef bold

	return OM_S_SUCCESS ;

} /* method drwPrflOnForm */
/*----------------------------------------------------------------------------*/
method display_list( int value ) {
	
	char 	*form = me->forms[0].form_ptr ;
	int	i,
		bold_face ;	/* Face that should be displayed in bold */

	/*
	 * Display the bold face if the list is not empty and the naming not
	 * completed yet.
	 */
	me->nbNames-- ;
	bold_face = VS_K_sc_MAXFACES - me->nbNames ;
	
	if( ( me->nbNames < 0 ) || ( bold_face > me->count ) ) {
		FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
				VSmsgkey2string( VS_gI_AllSelected ), FALSE ) ;
	} else {
		me->usrIndex[bold_face - 1] = me->rowToFcIndex[value] ;

		om$send(msg	= message VSsenameCmd.drwPrflOnForm( bold_face),
			targetid= my_id ) ;
	       /*
	 	* Display new list without the selected name.
	 	*/
		for( i = value ; i < me->nbNames ; i++ ) {
			me->rowToFcIndex[i] = me->rowToFcIndex[i+1] ;
		}
	
		FIfld_delete_rows( form, VS_K_sn_Side_Name, value, 1 ) ;
	}

	return OM_S_SUCCESS ;

} /* method display_list */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {
	
	int		msg ;
	long		rc ;
	int		resp ;

	resp = VS_K_DYN_MOUSE ;
	ex$putque( msg = &rc, response = &resp ) ;

	switch( gadget_label ) {

	  case FI_ACCEPT :
		resp = TERMINATE ;
		ex$putque( msg = &rc, response = &resp ) ;

		/*
		 * Save last location of the form.
		 */
		FIf_get_location( form_ptr, &x_pos, &y_pos ) ;
		FIf_get_screen( form_ptr, &s_pos ) ;

		goto EXECUTE ;

	  case FI_EXECUTE :

		resp = EX_BACK_UP ;
		ex$putque( msg = &rc, response = &resp ) ;

		vs$g_disable_gadgets(	form	= form_ptr,
					list	= `FI_ACCEPT,
						   FI_EXECUTE` ) ;

		me->count = 0 ;

	  EXECUTE :
		/*
		 * Transform composite curve into cross-section.
		 */			
		vs$moveAGccToXSection(
			msg	= &rc,
			AGccId	= &me->event1.located_object->located_obj ,
			usrIndex= me->usrIndex ) ;

		om$send(msg	= message VSsenameCmd.unhiliteProfile( &msg ) ,
		 	targetid= my_id ) ;

		om$send(msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

		break ;
		
	  case FI_RESET :
		/*
		 * Redisplay form with default values.
		 */
		om$send(msg	= message VSsenameCmd.resetCmd(),
			targetid= my_id ) ;

		om$send(msg	= message VSsenameCmd.unhiliteProfile( &msg ) ,
			targetid= my_id ) ;

		om$send(msg	= message VSsenameCmd.drwPrflOnForm( 0 ),
			targetid= my_id ) ;

		FIfld_set_mode( form_ptr, VS_K_sn_Side_Name, 0, FI_SINGLE_SELECT ) ;
		vs$g_disable_gadgets(	form	= form_ptr,
					list	= `FI_ACCEPT,
						   FI_EXECUTE` ) ;

		break ;

	  case FI_CANCEL :

		om$send(msg	= message VSsenameCmd.unhiliteProfile( &msg ) ,
			targetid= my_id ) ;

		om$send(msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

		resp = TERMINATE ;
		ex$putque( msg = &rc, response = &resp ) ;

		/*
		 * Save last location of the form.
		 */
		FIf_get_location( form_ptr, &x_pos, &y_pos ) ;
		FIf_get_screen( form_ptr, &s_pos ) ;

		break ;

	  case VS_K_sn_Side_Name :
		/*
		 * A name must be selected twice to be validated.
		 */
		if( -1 == me->lastSelectedRow ) {

		  /* Goto AccRejName state */
		  resp = VS_K_CH_STATE ;
		  ex$putque( msg = &rc, response = &resp ) ;
		  me->lastSelectedRow = (int) value ;

		} else if( me->lastSelectedRow == value ) {

		  om$send( msg	    = message VSsenameCmd.display_list( value ),
			   targetid = my_id ) ;

		  /*
		   * Test if all face are named.
		   */
		  if( ( VS_K_sc_MAXFACES - me->nbNames ) == me->count ) {
		    FIg_erase( form_ptr, VS_K_sn_Dyn_Txt ) ;
		    /* Goto AccRej state */
		    resp = VS_K_CH_STATE ;
		    ex$putque( msg = &rc, response = &resp ) ;
		   } else {
		     /* Goto ModifyForm state */		
		     resp = VS_K_LOAD_ATTR ;
		     ex$putque( msg = &rc, response = &resp ) ;
		   }
		   me->lastSelectedRow = -1 ;
		} else {
		  /* Stay in the same state */
		  me->lastSelectedRow = (int) value ;
		}
		me->lastHilitedRow = -1 ;
		break ;

	  default : break ;
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VSsenameCmd ;
