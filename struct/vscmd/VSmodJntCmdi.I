/*
	I/STRUCT
*/
class implementation VSmodJntCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "OMmacros.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsjntmacros.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsuattdef.h"
#include "VSmsg.h"
#include "vsicondef.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsjnformdef.h"
#include "vsmiscmacros.h"
#include "vsformmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsioproto.h"

#define VS_K_JnFmLabel	0
#define VS_K_UAFmLabel	1

from	GRvg	import	GRgetattr,
			GRputattr ;
/*----------------------------------------------------------------------------*/
method fillForm( long *msg ) {

	long			sts ;
	struct GRobj_env	joint ;
	VSpartAttr		pAttr ;
	char			*form	= me->forms[0].form_ptr,
				*subForm= me->forms[1].form_ptr ;

	me->newUAid.objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, 1, &joint ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	pAttr.Iwant	= VS_m_All ;
	pAttr.specific	= (void *) &me->jAttr ;

	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &pAttr),
			targetid= joint._objid,
			targetos= joint._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	VSf_rmSaveRestoreProp( form ) ;
	VSf_rmSaveRestoreProp( subForm ) ;

	FIf_set_user_pointer( form, subForm ) ;

	FIg_set_text( form, VS_K_jn_Title, VSmsgkey2string( VS_M_VSMdJn ) ) ;

	FIf_set_collapse_symbol( form, VS_K_CLP_SYM_FILE, VS_K_CLP_MdJoint ) ;

	sts = VSfillJointForm( msg, form, &me->jAttr ) ;
	if( !IF_NULL_OBJID( pAttr.usrAttr.objid ) ) {
		 VSfillJointUsrAttrForm( msg, subForm, &pAttr.usrAttr ) ;
	}

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method fillForm */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long			sts,
				msg ;
	int			i,
				trc,
				symbol ;
	double			*attr ;
	struct GRobj_env	joint ;
	VSpartAttr		pAttr ;
	char			*type,
				*text ;

	if( form_label == VS_K_JnFmLabel ) {

	switch( gadget_label ) {

	case FI_ACCEPT	:
		sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							&msg, 1, &joint ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "getLocObjs", ERROR ) ;

		pAttr.Iwant	= VS_m_All ;
		if( IF_NULL_OBJID( me->newUAid.objid ) ) {
			pAttr.Iwant &= ~VS_m_UsrAttr ;
		} else {
			pAttr.usrAttr = me->newUAid ;
		}
		pAttr.specific	= (void *) &me->jAttr ;
		sts = om$send(	msg	= message GRvg.GRputattr(
							&msg, (char *) &pAttr ),
				targetid= joint._objid,
				targetos= joint._osnum ) ;
		__CheckRC( sts, msg, "GRvg.GRputattr", ERROR ) ;

	ERROR		:

		FIg_set_state_off( form_ptr, gadget_label ) ;

		i = EX_RESTART ;
		ex$putque( msg = &msg, response = &i ) ;

		break ;

	case VS_K_jn_Allowance	:
		attr = &me->jAttr.allowance ;
		type = GRIO_DISTANCE ;
		goto UNITFIELD ;

	case VS_K_jn_GrooveAngle:
		attr = &me->jAttr.grooveAngle ;
		type = GRIO_ANGLE ;
		goto UNITFIELD ;

	case VS_K_jn_Pitch	:
		attr = &me->jAttr.pitch ;
		type = GRIO_DISTANCE ;
		goto UNITFIELD ;

	case VS_K_jn_IncrLength	:
		attr = &me->jAttr.incrLength ;
		type = GRIO_DISTANCE ;
	UNITFIELD			:
		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					type	= type,
					oldValue= *attr,
					newValue= attr ) ;
			break ;

	case VS_K_jn_Process	:
	case VS_K_jn_Weld_Code	:
		/*
		 * Retrieve selected row : row number corresponds to
		 * value of datum.
		 */
		i = VSgetSelectedRow( form_ptr, gadget_label ) ;

		VSupdWeldInfo( gadget_label, i, &me->jAttr.weldAttr ) ;
		break ;

	case VS_K_jn_UsrSymbol	:
		text = VSfld_get_text( form_ptr, gadget_label ) ;
		VSstrncpy( me->jAttr.usrSymbol, text, VS_K_MAXUSRSYMSZ, &trc ) ;
		if( trc ) {
			FIfld_set_text( form_ptr, gadget_label,
					0, 0, me->jAttr.usrSymbol, FALSE ) ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_jn_ArrowSide	:
		symbol = VS_K_jn_ArrowSideSym ; goto UPDATESYM ;
	case VS_K_jn_OtherSide	:
		symbol = VS_K_jn_OtherSideSym ; goto UPDATESYM ;
	case VS_K_jn_BothSides	:
		symbol = VS_K_jn_BothSidesSym ;
	UPDATESYM		:
		vs$g_erase_gadgets(	form	= form_ptr,
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

		VSupdWeldInfo( gadget_label, (int) value, &me->jAttr.weldAttr ) ;
		break ;

	case VS_K_jn_UsrAttrsBtn:
		FIg_set_state_off( form_ptr, gadget_label ) ;
		om$send(msg	= message CEO.display_form_by_label(
						VS_K_UAFmLabel, &trc ),
			targetid= my_id ) ;
		break ;
		
	}

	} else if( form_label == VS_K_UAFmLabel ) {

		int	rc ;

		switch( gadget_label ) {

		case FI_ACCEPT		:
			VScreateJnUA( &msg, form_ptr, VS_K_TmpUAttr,
					&me->newUAid ) ;
			/* Fall through to next case */
		
		case FI_CANCEL		:

			FIg_set_state_off( form_ptr, gadget_label ) ;
			om$send(msg	= message CEO.erase_form_by_label(
						VS_K_UAFmLabel, FALSE, &rc ),
				targetid= my_id ) ;
			 break ;

		case VS_K_jn_UsrAttrMcf	:
			VSfld_del_empty_rows( form_ptr, gadget_label,
						VS_K_jn_UAmcfNamCol ) ;
			break ;
		}

	}
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VSmodJntCmd ;
