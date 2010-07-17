/* $Id: VSjnattrCmdi.I,v 1.1.1.1 2001/01/04 21:10:23 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vscmd/VSjnattrCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnattrCmdi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/01/22  19:17:52  pinnacle
# Replaced: vscmd/VSjnattrCmdi.I for:  by impd for struct
#
# Revision 1.2  1997/12/19  06:09:34  pinnacle
# Replaced: vscmd/VSjnattrCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSjnattrCmd ;

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

short	VSdoesActJnAttrformExist ;
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
void VSfillSelectListAndSetActive( form, gadget, count, list, activeValue )

char	*form ;
long	*list ;
int	gadget,
	count,
	activeValue ; {

	int		i ;
	char		buffer[MS_MAX_MSG_LENGTH] ;

	FIfld_set_list_num_rows( form, gadget, 0, count ) ;

	for( i = 0 ; i < count ; i++ ) {

		ex$message( msgnumb	= list[i],
			    buff	= buffer ) ;

		FIfld_set_list_text( form, gadget, i, 0, (unsigned char *) buffer, FALSE ) ;

		if( i == activeValue ) {
			FIfld_set_text( form, gadget, 0, 0, buffer, TRUE ) ;

			FIfld_set_list_select( form, gadget, i, 0, TRUE ) ;
		}
	}

} /* VSfillSelectListAndSetActive */
/*----------------------------------------------------------------------------*/
long VSfillJointUsrAttrForm( msg, form, jnUA )

long		*msg ;
char		*form ;
struct GRid	*jnUA ; {

	char		**AttrVals	= NULL,
			**AttrNames	= NULL ;
	int		nbAttrs		= 0 ;

	vs$getUsrAttrContent( msg	= msg,
			      UAid	= jnUA,
			      p_size	= &nbAttrs,
			      p_names	= &AttrNames,
			      p_syntaxes= &AttrVals ) ;

	FIfld_set_num_rows( form, VS_K_jn_UsrAttrMcf, nbAttrs ) ;
	VSmcf_set_list_text( form, VS_K_jn_UsrAttrMcf, VS_K_jn_UAmcfNamCol,
				nbAttrs, AttrNames ) ;
	VSmcf_set_list_text( form, VS_K_jn_UsrAttrMcf, VS_K_jn_UAmcfValCol,
				nbAttrs, AttrVals  ) ;
	
	if( nbAttrs ) {
		VSfreeList( nbAttrs, AttrNames ) ;
		VSfreeList( nbAttrs, AttrVals ) ;
	}
	return *msg & 1 ;

} /* VSfillJointUsrAttrForm */
/*----------------------------------------------------------------------------*/
long VSfillJointForm( msg, form, jAttr )

long		*msg ;
char		*form ;
VSjointAttr	*jAttr ; {

	long		sts,
			*list ;
	int		count, cnt1 = 0,cnt2,
			info,
			g,
			s ;
	char		**codeList , **procList;

	codeList = procList = NULL ;
	vs$g_erase_gadgets(	form	= form,
				list	= `VS_K_jn_ArrowSideSym,
					   VS_K_jn_OtherSideSym,
					   VS_K_jn_BothSidesSym` ) ;
/*
	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Allowance,
				value	= jAttr->allowance ) ;
*/
	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Allowance,
				value	= jAttr->size ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_GrooveAngle,
				type	= GRIO_ANGLE,
				value	= jAttr->grooveAngle ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_Pitch,
				value	= jAttr->pitch ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_jn_IncrLength,
				value	= jAttr->incrLength ) ;
	/*
	 * Retrieve list of weld codes from an ASCII file
	 */
//	sts = vs$getWeldCodeASCII (	msg 	= msg,
//					count 	= &cnt1,
//					list	= &codeList );
//	if( !(sts & 1 & *msg ) ) {

	sts = VDread_weld_sym_char( &cnt1 );	// READ FROM "$VDS/config/weld_symbols"
	
	if( !(sts & 1 && cnt1 ) ) {
		/*
		 * Retrieve list of weld codes which are static 
		 * NOTE `list' not to be freed.
		 */
		sts = vs$getWeldCodes( msg	= msg,
				       count	= &count,
				       list	= &list ) ;
		__CheckRC( sts, *msg, "vs$getWeldCodes", wrapup ) ;

		VSfillSelectListAndSetActive(	form,
						VS_K_jn_Weld_Code,
						count,
						list,
						(int) jAttr->weldAttr.code ) ;
	} else {
		/*
		 * Set the list of weld codes from the ASCII file
		 * in the form
		 */
//////		int	flag = TRUE ;	
		int	i;

		for ( i = 0; i< cnt1 ; i ++ ) {
			FIfld_set_list_text( form, VS_K_jn_Weld_Code, i, 0,
//////					     codeList[i],
					     (unsigned char *) sym_char[i].desc,
					     FALSE);
			if( i == (int) jAttr->weldAttr.code )
			{
			  FIfld_set_text( form, VS_K_jn_Weld_Code, 0, 0, sym_char[i].desc, TRUE ) ;
 
			  FIfld_set_list_select( form, VS_K_jn_Weld_Code, i, 0, TRUE ) ;
			}

//////			flag = FALSE ;
		}
	}
	/*
	 * Retrieve list of weld processes from an ASCII file
	 */
	sts = vs$getWeldProcASCII (	msg 	= msg,
					count 	= &cnt2,
					list	= &procList );
	if( !(sts & *msg & 1 ) ) {
		/*
		 * Retrieve list of weld processes which are statis. 
		 * NOTE `list' not to be freed.
		 */
		sts = vs$getWeldProcesses(	msg	= msg,
						count	= &count,
						list	= &list ) ;
		__CheckRC( sts, *msg, "vs$getWeldProcesses", wrapup ) ;

		VSfillSelectListAndSetActive(	form,
						VS_K_jn_Process,
						count,
						list,
						(int) jAttr->weldAttr.process );
	} else {
		/*
		 * Set the list of weld code from the ASCII file
		 * in the form
		 */
		int	flag = TRUE ;	
		int	i;

		for ( i = 0; i< cnt2 ; i ++ ) {
			FIfld_set_list_text( form, VS_K_jn_Process,
						i, 0, (unsigned char *) procList[i], flag);
			flag = FALSE ;
		}
	}
	info = jAttr->weldAttr.info ;

	if( info & VS_m_wldWeldAllAround ) {
		FIg_set_state_on( form, VS_K_jn_AllAround	) ;
	}

	if( info & VS_m_wldFieldWeld	) {
		FIg_set_state_on( form, VS_K_jn_FieldWeld	) ;
	}

	if( info & VS_m_wldMeltThru	) {
		FIg_set_state_on( form, VS_K_jn_MeltThru	) ;
	}

	       if( info & VS_m_wldFlushContour	) {
		FIg_set_state_on( form, VS_K_jn_Flush	) ;
	} else if( info & VS_m_wldConvexContour	) {
		FIg_set_state_on( form, VS_K_jn_Convex	) ;
	} else if( info & VS_m_wldConcaveContour) {
		FIg_set_state_on( form, VS_K_jn_Concave	) ;
	}

	switch( jAttr->weldAttr.side ) {
		default			: 
		case VS_K_wldArrowSide	:
			g = VS_K_jn_ArrowSide ;
			s = VS_K_jn_ArrowSideSym ; break ;
		case VS_K_wdlOtherSide	:
			g = VS_K_jn_OtherSide ;
			s = VS_K_jn_OtherSideSym ; break ;
		case VS_K_wldBothSides	:
			g = VS_K_jn_BothSides ;
			s = VS_K_jn_BothSidesSym ; break ;
	}
	FIg_set_state_on( form, g ) ;
	FIg_display( form, s ) ;

//	FIfld_set_text( form, VS_K_jn_UsrSymbol, 0, 0, jAttr->usrSymbol, FALSE ) ;

	wrapup :
		VSfreeList( cnt1, codeList);
		VSfreeList( cnt2, procList);
		return sts ;

} /* VSfillJointForm */
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
		      VS_K_jn_Form_Name,
		      VS_ActJnAttr_form_notification,
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
	sts = VSfillJointForm( msg, form, &jAttr ) ;

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

end implementation VSjnattrCmd ;
