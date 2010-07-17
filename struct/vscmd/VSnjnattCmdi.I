/* $Id: VSnjnattCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSnjnattCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSnjnattCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/15  14:07:06  pinnacle
# New Joints
#
# Revision 1.1  1998/03/13  23:27:44  pinnacle
# New Joints
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/98  ah      TR179800680 Modify New Joint - Creation
 ***************************************************************************/
class implementation VSnjnattCmd ;

#include <stdio.h>
#include <FI.h>
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "VDSsymb_def.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vspart.h"
#include "vs.h"
#include "vsmiscmacros.h"
#include "vswelddef.h"
#include "vsweld.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsformmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsjnformdef.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

extern char	*MS_pocket_menu ;

// short	VSdoesActJnAttrformExist ;
/*
 * already defined in VSjnattrcmdi.I file
 */
extern 	short        	VSdoesActJnAttrformExist ;
struct	VSdpb_form_pos	VS_ActJnAttrForm_pos ;

#include "VDweldsym.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldtxt.I						*/
/* 	Used also in :								*/
/*		vdweld/cmd/VDweldcmd.I & vdweld/cmd/weldform.I			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern struct VDweld_gadget_sym	sym_char[];

extern int	VDread_weld_sym_char();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern int	VS_ActJnAttr_form_notification() ;
extern int	VS_ActJnAttr_UA_form_notification() ;
extern void	VS_ActJnAttr_delete_form __(( char* )) ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VS_ActNewJnAttr_form_notification( form_label, gadget_label, value, form_ptr )

int	form_label,
	gadget_label ;
double	value ;
char	*form_ptr ; {

	long		msg ;
	int		i,
			attr,
			trunc,
			symbol ;
	double		fvalue ;
	char		*type,
			*name,
			usrSym[VS_K_MAXUSRSYMSZ],
			*UAsubForm ;
	struct GRid	UAid ;

#define PUT_RESPONSE( value )\
	{ int resp = (value) ; ex$putque( msg = &msg, response = &resp ) ; }

	switch( gadget_label ) {

		case FI_CVT_TO_PERM_WIN	:
			/*
			 * Terminate command but don't erase form. The form
			 * is now a persistent form without command.
			 *
			 * Note : We put response EX_FORM_FINISHED instead of
			 *	  TERMINATE. In fact TERMINATE is put on the
			 *	  software queue when coming back to previous
			 *	  command ( double tap in the left mouse
			 *	  button ) and we use filter wfi which
			 *	  doesn't understand GR_UNKNOWN_TYPE response.
			 */
			PUT_RESPONSE( EX_FORM_FINISHED ) ;
			break ;

		case VS_K_jn_FloorPos  :
			symbol = VS_K_jn_FloorPos; 
			fvalue	= VS_K_wldFloorPos ; goto UPDATE0 ;
		case VS_K_jn_HorzPos  :
			symbol = VS_K_jn_HorzPos ; 
			fvalue	= VS_K_wdlHorzPos ; goto UPDATE0 ;
		case VS_K_jn_CeilPos  :
			symbol = VS_K_jn_CeilPos ; 
			fvalue	= VS_K_wldCeilPos ; goto UPDATE0 ;
		case VS_K_jn_VertPos  :
			symbol = VS_K_jn_VertPos ;
			fvalue	= VS_K_wldVertPos ;
			 
		UPDATE0	:
			FIg_set_state_on( form_ptr, symbol ) ;
			vs$putDpbCollAttr( 	msg     = &msg,
						name    = VS_K_dpbActJnWeldPos,
						value   = &fvalue ) ;
			break ;


		case VS_K_jn_GrooveAngle:
			name = VS_K_dpbActJnGrvAng ;
			type = GRIO_ANGLE ;
			goto UPDATE1 ;

		case VS_K_jn_Pitch	:
			name = VS_K_dpbActJnPitch ;
			type = GRIO_DISTANCE ;
			goto UPDATE1 ;

		case VS_K_jn_Weld_Size	:
			name = VS_K_dpbActJnWeldSize;
			type = GRIO_DISTANCE ;
			goto UPDATE1 ;

		case VS_K_jn_Shrinkage	:
			name = VS_K_dpbActJnShrkRatio ;
			type = GRIO_DISTANCE ;
			goto UPDATE1 ;

		case VS_K_jn_IncrLength	:
			name = VS_K_dpbActJnIncrLn ;
			type = GRIO_DISTANCE ;
		UPDATE1 :
			vs$getDpbCollAttr(	msg	= &msg,
						name	= name,
						p_value	= &fvalue ) ;

			vs$processUnitField(	msg	= &msg,
						form	= form_ptr,
						field	= gadget_label,
						type	= type,
						oldValue= fvalue,
						newValue= &fvalue ) ;
			
			if( msg & 1 ) {
				vs$putDpbCollAttr(	msg	= &msg,
							name	= name,
							value	= &fvalue ) ;
			}
			break ;

		case VS_K_jn_UsrSymbol	:
			name = VSfld_get_text( form_ptr, gadget_label ) ;
			VSstrncpy( usrSym, name, VS_K_MAXUSRSYMSZ, &trunc ) ;
			_FREE( name ) ;

			vs$putDpbCollAttr(	msg	= &msg,
						name	= VS_K_dpbActJnUsrSym,
						value	= usrSym ) ;
			if( trunc ) {
				FIfld_set_text( form_ptr, gadget_label,
						0, 0, usrSym, FALSE ) ;
			}
			break ;

		case VS_K_jn_Process	:
		case VS_K_jn_Weld_Code	:

			/*
			 * Retrieve selected row : row number corresponds to
			 * value of datum.
			 */
			i = VSgetSelectedRow( form_ptr, gadget_label ) ;

			VSputWeldInfo( gadget_label, i ) ;
			break ;

		case VS_K_jn_ArrowSide	:
			symbol = VS_K_jn_ArrowSideSym ; goto UPDATE2 ;
		case VS_K_jn_OtherSide	:
			symbol = VS_K_jn_OtherSideSym ; goto UPDATE2 ;
		case VS_K_jn_BothSides	:
			symbol = VS_K_jn_BothSidesSym ;
		UPDATE2			:
			vs$g_erase_gadgets(
					form	= form_ptr,
					list	= `VS_K_jn_ArrowSideSym,
					   	   VS_K_jn_OtherSideSym,
					   	   VS_K_jn_BothSidesSym` ) ;
			FIg_display( form_ptr, symbol ) ;
		/* No break intentionally */

		case VS_K_jn_FieldWeld	:
		case VS_K_jn_MeltThru	:
		case VS_K_jn_AllAround	:
		case VS_K_jn_Flush	:
		case VS_K_jn_Concave	:
		case VS_K_jn_Convex	:
			VSputWeldInfo( gadget_label, (int) value ) ;
			break ;

		case VS_K_jn_UsrAttrsBtn:
			FIg_set_state_off( form_ptr, gadget_label ) ;

			FIf_get_user_pointer( form_ptr, &UAsubForm ) ;
			if( !UAsubForm ) break ;

			/*
			 * Retrieve active collection of user-attributes for
			 * joints.
			 */
			vs$getActiveUsrAttr( msg	= &msg,
					     basename	= VS_K_jointUA,
					     p_activeUA	= &UAid ) ;

			if( !IF_NULL_OBJID( UAid.objid ) ) {
				VSfillJointUsrAttrForm( &msg, UAsubForm, &UAid);
			}
			FIf_display( UAsubForm ) ;
			break ;

		case FI_ACCEPT		:
			/*
			 * Delete form.
			 */
			FIg_get_attr( form_ptr,
				      FI_CVT_TO_PERM_WIN,
				      &attr ) ;

			/*
			 * If button 'Convert-form' is OFF that means the
			 * command already exists. So delete command.
			 */
				PUT_RESPONSE( TERMINATE ) ;
			
			break ;

	}

	return FI_SUCCESS ;

} /* VS_ActNewJnAttr_form_notification */
/*----------------------------------------------------------------------------*/
method does_form_exist( int *sts ) {

	*sts = VSdoesActJnAttrformExist ? VS_K_FORM_EXIST : !VS_K_FORM_EXIST ;

	return OM_S_SUCCESS ;

} /* method does_form_exist */
/*----------------------------------------------------------------------------*/
method createForm( int *sts ) {

	int	rc ;

	/*
	 * Create form.
	 */
	rc = FIf_new( 0,
		      VS_K_jn_AttrForm_Name,
		      VS_ActNewJnAttr_form_notification,
		      &me->ActJnAttr_form ) ;

	if( rc == FI_SUCCESS ) {
		char	*usrAttrFm ;
		/*
		 * We build the sub-form to be at hand if needed.
		 */
		rc = FIf_new(	1,
				VS_K_jn_UsrAttrFormName,
				VS_ActJnAttr_UA_form_notification,
				&usrAttrFm ) ;
		if( rc == FI_SUCCESS ) {
			/*
			 * Stick sub-form as user-pointer for easy retrieval.
			 */
			FIf_set_user_pointer( me->ActJnAttr_form, usrAttrFm ) ;
		}
	}
	*sts = ( rc == FI_SUCCESS ) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method createForm */
/*----------------------------------------------------------------------------*/
method initForm( long *msg ) {

	long		sts ;
	VSjointAttr	jAttr ;
	char		*form = me->ActJnAttr_form ;

	/*
	 * Retrieve active joint attributes from DPB.
	 */
	sts = VSgetActNewJnAttr( msg, &jAttr ) ;
	__CheckRC( sts, *msg, "VSgetActJnAttr", wrapup ) ;

	/*
	 * Fill form.
	 */
	sts = VSfillNewJointForm( msg, form, &jAttr ) ;

	wrapup :
		*msg = ( *msg & sts & 1 ) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method initForm */
/*----------------------------------------------------------------------------*/
method displayForm( int *sts ) {

	/*
	 * Set layout of form.
	 */
	if( !( !VS_ActJnAttrForm_pos.x		&&
	       !VS_ActJnAttrForm_pos.y		&&
	       !VS_ActJnAttrForm_pos.width	&&
	       !VS_ActJnAttrForm_pos.height	&&
	       !VS_ActJnAttrForm_pos.screen ) ) {

		char	*UAform = NULL ;

		VSf_set_layout( me->ActJnAttr_form,
				VS_ActJnAttrForm_pos.screen,
				VS_ActJnAttrForm_pos.x,
				VS_ActJnAttrForm_pos.y,
				VS_ActJnAttrForm_pos.width,
				VS_ActJnAttrForm_pos.height ) ;

		/*
		 * Sub-form to follow location of master form.
		 */
		FIf_get_user_pointer( me->ActJnAttr_form, &UAform ) ;
		if( UAform ) {
			FIf_set_screen  ( UAform, VS_ActJnAttrForm_pos.screen );
			FIf_set_location( UAform,
					  VS_ActJnAttrForm_pos.x,
					  VS_ActJnAttrForm_pos.y ) ;
		}
	}

	VSf_display( me->ActJnAttr_form ) ;

	VSdoesActJnAttrformExist = TRUE ;

	return OM_S_SUCCESS ;

} /* method displayForm */
/*----------------------------------------------------------------------------*/
method deleteForm( int *sts ) {

	VS_ActJnAttr_delete_form( me->ActJnAttr_form ) ;

	return OM_S_SUCCESS ;

} /* method deleteForm */
/*----------------------------------------------------------------------------*/
method disable_enable_pkt_menu( int di0_en1 ) {

	if( di0_en1 ) {
		MS_pocket_menu	= me->pkt_menu ;
	} else {
		me->pkt_menu	= MS_pocket_menu ;
		MS_pocket_menu	= NULL ;
	}

	return OM_S_SUCCESS ;

} /* method disable_enable_pkt_menu */
/*----------------------------------------------------------------------------*/

end implementation VSnjnattCmd ;
