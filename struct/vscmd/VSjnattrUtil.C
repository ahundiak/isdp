/*
	I/STRUCT
*/
#include <stdio.h>
#include <FI.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "vswelddef.h"
#include "vscmd.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vsiomacros.h"
#include "vsformmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsmiscmacros.h"
#include "VDSsymb_def.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
#include "vsjnformdef.h"
/*
 * Includes of function prototypes
 */
#include "VX_FIproto.h"
#include "vsstrngproto.h"
#include "vsioproto.h"
#include "vsformproto.h"

extern short			VSdoesActJnAttrformExist ;
extern struct VSdpb_form_pos	VS_ActJnAttrForm_pos ;
extern void			VS_ActJnAttr_delete_form() ;
/*----------------------------------------------------------------------------*/
int VSgetSelectedRow( form, gadget )

char	*form ;
int	gadget ; {

	int	i,
		num_rows,
		selected,
		found = 0 ;

	FIfld_get_list_num_rows( form, gadget, 0, &num_rows ) ;

	for( i = 0 ; i < num_rows ; i++ ) {
		FIfld_get_list_select( form, gadget, i, 0, &selected ) ;

		if( selected ) { found = i ; break ; }
	}

	return found ;

} /* VSgetSelectedRow */
/*----------------------------------------------------------------------------*/
void VSupdWeldInfo( type, value, wa ) int type, value ; VSweldAttr *wa ; {

	switch( type ) {
		case VS_K_jn_Weld_Code	:
			wa->code	= value ;
			break ;

		case VS_K_jn_Process	:
			wa->process	= value ;
			break ;

		case VS_K_jn_FieldWeld	:
			if( value ) {
				wa->info |=  VS_m_wldFieldWeld ;
			} else {
				wa->info &= ~VS_m_wldFieldWeld ;
			}
			break ;

		case VS_K_jn_MeltThru	:
			if( value ) {
				wa->info |=  VS_m_wldMeltThru ;
			} else {
				wa->info &= ~VS_m_wldMeltThru ;
			}
			break ;

		case VS_K_jn_AllAround	:
			if( value ) {
				wa->info |=  VS_m_wldWeldAllAround ;
			} else {
				wa->info &= ~VS_m_wldWeldAllAround ;
			}
			break ;

		case VS_K_jn_Flush	:
			if( value ) {
				wa->info &= ~(   VS_m_wldConvexContour
					       | VS_m_wldConcaveContour ) ;
				wa->info |=  VS_m_wldFlushContour ;
			} else {
				wa->info &= ~VS_m_wldFlushContour ;
			}
			break ;

		case VS_K_jn_Concave	:
			if( value ) {
				wa->info &= ~(   VS_m_wldConvexContour
					       | VS_m_wldFlushContour ) ;
				wa->info |=  VS_m_wldConcaveContour ;
			} else {
				wa->info &= ~VS_m_wldConcaveContour ;
			}
			break ;

		case VS_K_jn_Convex	:
			if( value ) {
				wa->info &= ~(   VS_m_wldConcaveContour
					       | VS_m_wldFlushContour ) ;
				wa->info |=  VS_m_wldConvexContour ;
			} else {
				wa->info &= ~VS_m_wldConvexContour ;
			}
			break ;

		case VS_K_jn_ArrowSide	:
			wa->side = VS_K_wldArrowSide ; break ;

		case VS_K_jn_OtherSide	:
			wa->side = VS_K_wdlOtherSide ; break ;

		case VS_K_jn_BothSides  :
			wa->side = VS_K_wldBothSides ; break ;
	}
	
} /* VSupdWeldInfo */
/*----------------------------------------------------------------------------*/
void VSputWeldInfo( type, value ) int type, value ; {

	long		msg ;
	VSweldAttr	wa ;

	vs$get_act_pm(	msg   = &msg,
		     	param = VS_e_dpb_J_weldAttr,
			p_arg = &wa ) ;

	VSupdWeldInfo( type, value, &wa ) ;

	vs$put_act_pm(	msg   = &msg,
			param = VS_e_dpb_J_weldAttr,
			p_arg = &wa ) ;

} /* VSputWeldInfo */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VS_ActJnAttr_form_notification( form_label, gadget_label, value, form_ptr )

int	form_label,
	gadget_label ;
double	value ;
char	*form_ptr ; {

	long		msg ;
	int		i,
			attr,
			trunc,
			symbol ;
	double		allowance,
			fvalue ;
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

		case VS_K_jn_Allowance	:
			/*
			 * Put allowance into DPB.
			 */
			vs$get_act_pm(	msg   = &msg,
				     	param = VS_e_dpb_J_Allowance,
					p_arg = &allowance ) ;

			vs$processUnitField(	msg	= &msg,
						form	= form_ptr,
						field	= gadget_label,
						oldValue= allowance,
						newValue= &allowance ) ;


			if( msg & 1 ) {
				vs$put_act_pm(	msg   = &msg,
					     	param = VS_e_dpb_J_Allowance,
						p_arg = &allowance ) ;
			}
			break ;

		case VS_K_jn_GrooveAngle:
			name = VS_K_dpbActJnGrvAng ;
			type = GRIO_ANGLE ;
			goto UPDATE1 ;

		case VS_K_jn_Pitch	:
			name = VS_K_dpbActJnPitch ;
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

} /* VS_ActJnAttr_form_notification */
/*----------------------------------------------------------------------------*/
long VScreateJnUA( msg, UAform, UAbasename, p_UAid )

long		*msg ;
char		*UAform,
		*UAbasename ;
struct GRid	*p_UAid ; {

	/*
	 * Reads MCF for attribute names and values then create an Active
	 * Collection of user-attributes that goes by the name `UAbasename'.
	 */
	char		**attrNames	= NULL,
			**attrVals	= NULL ;
	int		nbAttrs		= 0 ;

	FIfld_get_num_rows(	UAform,
				VS_K_jn_UsrAttrMcf,
				&nbAttrs ) ;
	attrNames = VSmcf_get_list_text(UAform,
					VS_K_jn_UsrAttrMcf,
					VS_K_jn_UAmcfNamCol ) ;
	attrVals  = VSmcf_get_list_text(UAform,
					VS_K_jn_UsrAttrMcf,
					VS_K_jn_UAmcfValCol ) ;
	vs$makeActiveUsrAttr( msg	= msg,
			      basename  = UAbasename,
			      nbEntries	= nbAttrs,
			      names	= attrNames,
			      syntaxes	= attrVals,
			      p_activeUA= p_UAid ) ;
	if( nbAttrs ) {
		VSfreeList( nbAttrs, attrNames ) ;
		VSfreeList( nbAttrs, attrVals  ) ;
	}

	return *msg & 1 ;

} /* VScreateJnUA */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VS_ActJnAttr_UA_form_notification( form_label, gadget_label, value,
					form_ptr )

int	form_label,
	gadget_label ;
double	value ;
char	*form_ptr ; {

	/*
	 * Notification routine of user-attributes sub-form.
	 */
	long		msg ;
	struct GRid	UAid ;

	switch( gadget_label ) {

		case FI_ACCEPT		:
			VScreateJnUA( &msg, form_ptr, VS_K_jointUA, &UAid ) ;

			/* Do not break : fall through next case */

		case FI_CANCEL		: 
			FIf_erase( form_ptr ) ;
			FIf_reset( form_ptr ) ;
			break ;

		case VS_K_jn_UsrAttrMcf	:
			VSfld_del_empty_rows( form_ptr, gadget_label,
						VS_K_jn_UAmcfNamCol ) ;
			break ;
	}

	return FI_SUCCESS ;

} /* VS_ActJnAttr_UA_form_notification */
/*----------------------------------------------------------------------------*/
void VS_ActJnAttr_delete_form( actJnFm ) char	*actJnFm ; {

	char	*usrAttrFm = NULL ;

	/*
	 * Save layout of form.
	 */
	VSget_form_pos( actJnFm, &VS_ActJnAttrForm_pos ) ;

	/*
	 * Delete sub-form.
	 */
	FIf_get_user_pointer( actJnFm, &usrAttrFm ) ;
	if( usrAttrFm ) FIf_delete( usrAttrFm ) ;

	/*
	 * Delete form.
	 */
	FIf_delete( actJnFm ) ;

	VSdoesActJnAttrformExist = FALSE ;

} /* ActJnAttr_delete_form */
/*----------------------------------------------------------------------------*/
