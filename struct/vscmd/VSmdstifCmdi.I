/* $Id: VSmdstifCmdi.I,v 1.3 2002/01/29 17:44:23 ylong Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSmdstifCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmdstifCmdi.I,v $
 *      Revision 1.3  2002/01/29 17:44:23  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/17 00:11:55  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/06/20  22:32:34  pinnacle
# Created: struct/vscmd/VSmdstifCmdi.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/12  13:22:56  pinnacle
# ah
#
# Revision 1.2  1998/04/09  21:49:40  pinnacle
# TR179800861
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/98  ah      TR179800861 Changing name should not change directory
 * 04/12/98  ah      Uninitialized ref to sts in recomp_surface
 * 06/20/00  Jayadev TR179901700 change name not required; will be done
 *				 inside the parent VSbeam
 * 01/29/02  ylong   TR3960
 ***************************************************************************/

class implementation VSmdstifCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "COBmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "vsglobalmsg.h"
#include "vsdpbdef.h"
#include "vsdef.h"
#include "vscmddef.h"
#include "vsoptdef.h"
#include "vsicondef.h"
#include "vsbeamdef.h"
#include "vsstfnrdef.h"
#include "vsgddef.h"
#include "vsbmaxisdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmdmacros.h"
#include "vsformmacros.h"
#include "vsdbgmacros.h"
#include "vsslcdef.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsformproto.h"
#include "vsgetaxofstf.h"
#include "vsgetchildrn.h"
#include "vsverifyval.h"

#include "VDobj.h"

#define VS_K_ROT_DEFN_FILE      "VStwsDefn.fm"

#define VS_K_stAngUp	0x0001
#define VS_K_edAngUp	0x0002
#define VS_K_stRefUp	0x0004
#define VS_K_edRefUp	0x0008


extern long	VSgetHeightOfCrossSectionDef() ;
extern void	VSinitStiffenerEditionForm __(( char *form )) ;

extern OMuword	OPP_VSgapDtector_class_id ;
extern OMuword	OPP_VStwsBeam_class_id ;

from GRgraphics import GRchgname;
from ACpretend	import ACfind_parent;

from NDnode	import ASreturn_go,
		       NDchange_connect ,
		       NDget_objects ;
from NDmacro	import ACreturn_foot,
		       ACgive_structure ;
from expression	import NDset_value ;
from ACcpx	import ACfind_temp_obj ;
from VSpart	import VSgetUserEditableAttr ;
from VSfeature	import VSforwardToOriginal ;
from VSstfBeam	import VSgetConstructionType,
		       VSputConstructionType ;
from VSbeamAxis import VSgetConstructionType,
		       VSgeneratePerpSfToParentSf ;

#define DISPLAY_GROUP( grp ) \
	if( VS_K_bm_Grp_##grp != me->ActGrp ) {\
		if( me->ActGrp == VS_K_bm_Grp_Definition ) \
			vs$repaint_gadget( form   = form_ptr,\
					   gadget = VS_K_bm_Area ) ;\
		VSg_replace( form_ptr, me->ActGrp, VS_K_bm_Grp_##grp ) ;\
		me->ActGrp = VS_K_bm_Grp_##grp ;\
	}
/*----------------------------------------------------------------------------*/
method init_cmd ( int *sts ) {

	om$send(msg	= message VSmdbeamCmd.init_cmd( sts ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	FIf_set_collapse_symbol( me->fm_ptr,
				 VS_K_CLP_SYM_FILE,
				 VS_K_CLP_ModStfn ) ;

	me->position	  = VS_K_stNormalToSide ;
	me->CanPlaceAlPl  = FALSE ;
	me->InternalYOff  = 0. ;
	me->flag	  &= ~VS_K_change_cnst_type ;
	me->nameModified  = FALSE;
	me->recompSurf 	  = 0 ;
	me->isTwistedStfnr= FALSE ;

	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {

	long	rc ;
	double	StfnNrmlToSd ;

	switch( me->position ) {
		default 			:
		case VS_K_stNormalToSide	: StfnNrmlToSd = 1 ; break ;
		case VS_K_stUseSurfOfPrj	: StfnNrmlToSd = 0 ; break ;
	}
	vs$putDpbCollAttr(	msg	= &rc,
				name	= VS_K_dpbActStfnNrmlToSd,
				value	= &StfnNrmlToSd ) ;

	om$send(msg	= message VSmdbeamCmd.delete( f_defer_flag ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	if ( me->rotDefForm ) FIf_delete( me->rotDefForm ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmbeam_labels[] = {
	{ VS_K_bm_Dismiss_Execute	, TRUE },
	{ VS_K_bm_Execute		, TRUE },
	{ VS_K_bm_Revert		, TRUE },
	{ VS_K_bm_Dismiss		, TRUE },
	{ VS_K_bm_Roll_Through		, TRUE },
	{ VS_K_bm_Message		, TRUE },
	{ VS_K_bm_Material_Type 	, TRUE },
	{ VS_K_bm_Material_Grade	, TRUE },
	{ VS_K_bm_Shape_Name		, TRUE },
	{ VS_K_bm_Section_Name		, TRUE },
	{ VS_K_bm_Directory		, TRUE },
	{ VS_K_bm_Name			, TRUE },
	{ VS_K_bm_Stock_Number		, TRUE },
	{ VS_K_bm_Source		, TRUE },
	{ VS_K_bm_Fireproofing		, TRUE },
	{ VS_K_bm_Approval_Status	, TRUE },
	{ VS_K_bm_Construction_Status	, TRUE },
	{ VS_K_bm_Member_Class		, TRUE },
	{ VS_K_bm_Member_Type		, TRUE },
	{ VS_K_bm_Change_Number 	, TRUE },
	{ VS_K_bm_Number_Of_Beams	, TRUE },
	{ VS_K_bm_Comments		, TRUE },
	{ VS_K_bm_Display_Ratio 	, TRUE },
	{ VS_K_bm_X_Offset		, TRUE },
	{ VS_K_bm_Y_Offset		, TRUE },
	{ VS_K_tws_Rotation		, TRUE },	
	{ VS_K_sf_Position		, TRUE },
	{ VS_K_xs_Position		, TRUE },
	{ VS_K_bm_Rotation		, TRUE },
	{ VS_K_bm_Section_Length	, TRUE },
	{ VS_K_bm_Section_Area		, TRUE },
	{ VS_K_bm_Top_Left		, TRUE },
	{ VS_K_bm_Center_Left		, TRUE },
	{ VS_K_bm_Bot_Left		, TRUE },
	{ VS_K_bm_Top_Middle		, TRUE },
	{ VS_K_bm_Bot_Mid		, TRUE },
	{ VS_K_bm_Top_Right		, TRUE },
	{ VS_K_bm_Center_Middle 	, TRUE },
	{ VS_K_bm_Center_Right		, TRUE },
	{ VS_K_bm_Bot_Right		, TRUE },
	{ VS_K_bm_No_Sym		, TRUE },
	{ VS_K_bm_X_Sym 		, TRUE },
	{ VS_K_bm_Y_Sym 		, TRUE },
	{ VS_K_bm_XY_Sym		, TRUE },
	{ VS_K_bm_Copy_Params		, TRUE },
	{ VS_K_bm_Parameters		, TRUE },
	{ VS_K_bm_Definition		, TRUE },
	{ VS_K_bm_Section_Manipulation	, TRUE },
	{ VS_K_bm_Material_Take_Off	, TRUE },
	{ VS_K_bm_User_Attributes	, TRUE },
	{ VS_K_bm_Mcf_User_Attributes	, TRUE },
	{ VS_K_bm_AccessToGapDetctGrp	, TRUE },
	{ VS_K_bm_GapDetection_Toggle	, TRUE },
	{ VS_K_bm_GapDetection_ValFld	, TRUE },
	{ VS_K_bm_GapDetection_MaxFld	, TRUE },
	{ -1				, TRUE }	/* End-of-list flag */
} ;
	long				sts ;
	struct GRobj_env		stif ;
	unsigned long			attrMask,
					type ;
	register struct VSgadget	*l ;

#define NO_EDIT( attr ) !( attrMask & VS_m_##attr )
#define SET_NO_EDIT( gadget )\
	VSsetGadgetModifiable(	VS_Ga_fmbeam_labels,\
				VS_K_bm_##gadget,\
				FALSE )

	for( l = VS_Ga_fmbeam_labels ; l->label != -1 ; l++ ) {
		l->touchable = TRUE ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &stif ),
			targetid= my_id ) ;
	if( sts == OM_S_SUCCESS ) {
		sts  = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attrMask ),
				targetid= stif._objid,
				targetos= stif._osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;
		if( !attrMask ) {
			/*
			 * stiffener not editable at all.
			 */
			for( l = VS_Ga_fmbeam_labels ; l->label != -1 ; l++ ) {
				l->touchable = FALSE ;
			}
			om$send(msg	= message VSfmbeamCmd.tellUser(
							VS_gW_PartNtEdit ),
				targetid= my_id ) ;
		} else {
			if( NO_EDIT( MatType		) ) {
				SET_NO_EDIT( Material_Type	) ;
			}
			if( NO_EDIT( MatGrade		) ) {
				SET_NO_EDIT( Material_Grade	) ;
			}
			if( NO_EDIT( Notes		) ) {
				SET_NO_EDIT( Comments		) ;
			}
			if( NO_EDIT( PartFam		) ) {
				SET_NO_EDIT( Shape_Name 	) ;
			}
			if( NO_EDIT( PartNum		) )
				SET_NO_EDIT( Section_Name	) ;

			if( NO_EDIT( Symmetry		) ) {
				SET_NO_EDIT( X_Sym		) ;
				SET_NO_EDIT( Y_Sym		) ;
				SET_NO_EDIT( No_Sym		) ;
				SET_NO_EDIT( XY_Sym		) ;
			}

			if( NO_EDIT( cardPnt		) ) {
				SET_NO_EDIT( Top_Left		) ;
				SET_NO_EDIT( Top_Middle 	) ;
				SET_NO_EDIT( Top_Right		) ;
				SET_NO_EDIT( Center_Left	) ;
				SET_NO_EDIT( Center_Middle	) ;
				SET_NO_EDIT( Center_Right	) ;
				SET_NO_EDIT( Bot_Left		) ;
				SET_NO_EDIT( Bot_Mid		) ;
				SET_NO_EDIT( Bot_Right		) ;
			}

			if( NO_EDIT( xOffset		) )
				SET_NO_EDIT( X_Offset		) ;

			if( NO_EDIT( yOffset		) )
				SET_NO_EDIT( Y_Offset		) ;

			if( NO_EDIT( RotAngle		) )
				SET_NO_EDIT( Rotation		) ;

			if( NO_EDIT( MtoStk		) ) {
				SET_NO_EDIT( Stock_Number	) ;
			}
			if( NO_EDIT( MtoSrc		) )
				SET_NO_EDIT( Source		) ;

			if( NO_EDIT( MbrClass		) )
				SET_NO_EDIT( Member_Class	) ;

			if( NO_EDIT( MbrType		) )
				SET_NO_EDIT( Member_Type	) ;

			if( NO_EDIT( AppStat		) )
				SET_NO_EDIT( Approval_Status	) ;

			if( NO_EDIT( CstStat		) )
				SET_NO_EDIT( Construction_Status) ;

			if( NO_EDIT( FpThck		) )
				SET_NO_EDIT( Fireproofing	) ;

			if( NO_EDIT( ChgNum		) )
				SET_NO_EDIT( Change_Number	) ;

			if( NO_EDIT( UsrAttr		) )
				SET_NO_EDIT( Mcf_User_Attributes) ;

		if( type == VS_m_STF_BEAM ) {
			SET_NO_EDIT( Top_Left		) ;
			SET_NO_EDIT( Center_Left	) ;
			SET_NO_EDIT( Top_Middle 	) ;
			SET_NO_EDIT( Top_Right		) ;
			SET_NO_EDIT( Center_Middle	) ;
			SET_NO_EDIT( Center_Right	) ;
		}

		/*
		 * We do not want the name to be changed from this
		 * form.
		 */
			if( me->number_of_beams != 1 )  {
				SET_NO_EDIT( Name ) ; 
			}
		}

		/*
		 * Set gadget 'Position' not modifiable if stiffener cannot be
		 * placed along plane.
		 */
		if( !me->CanPlaceAlPl ) {
			VSsetGadgetModifiable(	VS_Ga_fmbeam_labels,
						VS_K_sf_Position,
						FALSE ) ;
		}
	}

	*msg = MSSUCC ;
	*list = VS_Ga_fmbeam_labels ;

	wrapup :
		return OM_S_SUCCESS ;

#undef NO_EDIT
#undef SET_NO_EDIT

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method recomp_surface( long *msg ) {
	long 		sts = OM_S_SUCCESS;
	char 		*form_ptr = me->rotDefForm ;
	int		sel_flag,
			r_pos ;
	char		refType[2],
			expVal[80];
	struct GRid	*myParents,
			ACpretend, 
			expObj,
			beamSupp ;
	int		ACcount , 
			i, 
			cn_type, 
			wait_index ,
			nbParents ;
	double 		value[2] ;
			

	struct GRobj_env *stifList ;
			
	/*
         * Get located stiffeners.
         */
        stifList = _MALLOC( me->number_of_beams, struct GRobj_env ) ;
        if( !stifList ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

        sts = om$send( msg      = message VSlocateCmd.getLocObjs(
                                          msg, me->number_of_beams, stifList ),
			targetid = my_id ) ;

	cn_type = ND_COMP ;

	for( i = 0; i< me->number_of_beams ; i++ ) {
		/*
		 * Get root ACpretend #1 of given stiffener.
		 */
		sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
						msg,
						OM_e_wrt_object,
						message NDnode.NDget_objects( 
							ND_ROOT,
							&ACpretend,
							1,
							NULL,
							0,
							0,
							&ACcount )),
				targetid = stifList[i]._objid,
				targetos = stifList[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup );
		__DBGpr_obj(" Pretend Obj", ACpretend );

		/*
		 * Get beam axis from ACpretend #1.
		 */
		sts = om$send( msg	= message ACpretend.ACfind_parent(
							&beamSupp, 
							NULL, 
							NULL ),
			       targetid = ACpretend.objid,
			       targetos = ACpretend.osnum ) ;
		__CheckRC( sts, 1, "ACpretend.ACfind_parent", wrapup ) ;
		__DBGpr_obj("Beam Support Obj", beamSupp);

		sts = om$send(msg	= message NDnode.NDget_objects( 
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&myParents,
						0,
						OM_K_MAXINT,
						&nbParents ),
				targetid = beamSupp.objid,
				targetos = beamSupp.osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;
		__DBGpr_int(" Parent count of BeamSupp", nbParents );

		sts = VStxtExpValue( 	myParents[1].objid, 
				 	myParents[1].osnum,
					&expVal );
		__CheckRC( sts, 1, "VStxtExpValue", wrapup ) ;

		sscanf(expVal, "%c|%lf|%c|%lf", &refType[0], &value[0], 
						&refType[1], &value[1] );
		
		if( me->recompSurf & VS_K_stAngUp ) {
			if( me->rotDefForm )  {
				FIfld_get_value(form_ptr, 
						VS_K_tws_StAngle, 
						0, 
						0,
						&value[0], 
						&sel_flag, &r_pos );
			}
		}
		if( me->recompSurf & VS_K_edAngUp ) {
			if( me->rotDefForm )  {
			  	FIfld_get_value(form_ptr, 
						VS_K_tws_EdAngle, 
						0, 
						0,
						&value[1],
						&sel_flag, &r_pos );
			}
		}
		if( me->recompSurf & VS_K_stRefUp ) {
			if( me->rotDefForm )  {
				int 	actRow ;
				actRow = VSgetRowIndex(	form_ptr, 
							VS_K_tws_StRefType );
				switch( actRow ) {
					case 0 :
						refType[0] = 'N';
						break;
					case 1 :
						refType[0] = 'F';
						break;
					case 2 :
						refType[0] = 'B';
						break;
					case 3 :
						refType[0] = 'W';
						break;

					default : break ;
				}
			}
		}
		if( me->recompSurf & VS_K_edRefUp ) {
			if( me->rotDefForm )  {
				int 	actRow ;
				actRow = VSgetRowIndex(	form_ptr, 
							VS_K_tws_EdRefType );
				switch( actRow ) {
					case 0 :
						refType[1] = 'N';
						break;
					case 1 :
						refType[1] = 'F';
						break;
					case 2 :
						refType[1] = 'B';
						break;
					case 3 :
						refType[1] = 'W';
						break;
					default : break ;
				}
			}
		}

		sprintf( expVal, "%c|%g|%c|%g", 
					refType[0],value[0],
					refType[1],value[1] );

		sts = exp$create(	exp_name  = 0,
					exp_syntax= expVal,
					p_exp_id  = &expObj.objid,
					osnum     = me->cstEnv._MD_OS ,
					p_osnum   = &expObj.osnum,
					type_rq   = EXP_TEXT);
		if(!( sts & 1 ) ) {
			expObj.objid = NULL_OBJID ; 
			return MSFAIL ; 
		}

		if( me->recompSurf ){
			sts = om$send( msg = message NDnode.NDchange_connect(
								1,
								&myParents[1],
								&expObj ),
					targetid = beamSupp.objid,
					targetos = beamSupp.osnum );
			__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup );
		}

		NDis_waiting(	GR_GEOM_POSTED, 0, 
				&beamSupp, &wait_index, NULL, NULL, 1 );

		if( wait_index == -1 )
		{
			/*
			 * I am in not in the batch list 
			 */
			nd$wait_batch(  type           = GR_GEOM_POSTED,
                		       l_object        = &beamSupp,
		                       l_obj_info      = &cn_type,
        		               nb_obj          = 1 ) ;
		}
	}

wrapup :
	return sts ;
	
} /* method recomp_surface */
/*----------------------------------------------------------------------------*/
method sub_form_notification( char *form_ptr ; int gadget_label ) {
	long		sts, msg ;
	int		response ;

	switch (gadget_label ) {

		case VS_K_bm_Dismiss	:
			me->recompSurf = 0 ;
			FIf_erase( me->rotDefForm);
			break ;

		case VS_K_bm_Dismiss_Execute :
			
			FIf_erase( me->rotDefForm);

			if( me->recompSurf ){
				sts = om$send ( msg = message 
						VSmdstifCmd.recomp_surface(
								&msg ),
						targetid = my_id );
				if( !( sts & msg & 1 ) ) {
					response = EX_BACK_UP ;
					ex$putque( msg = &msg, 
						   response = &response ) ;
				}
			}
				break ;

		case VS_K_tws_StRefType :	
				me->flag |= VS_K_modify_form ;
				me->recompSurf |= VS_K_stRefUp ;
				break ;

		case VS_K_tws_EdRefType :			
				me->flag |= VS_K_modify_form ;
				me->recompSurf |= VS_K_edRefUp;
				break ;

		case VS_K_tws_StAngle	:	
				me->flag |= VS_K_modify_form ;
				me->recompSurf |= VS_K_stAngUp;
				break ;
				
		case VS_K_tws_EdAngle:	
				me->flag |= VS_K_modify_form ;
				me->recompSurf |= VS_K_edAngUp ;
				break ;
	}

	return OM_S_SUCCESS ;	

}/* method sub_form_notification */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg ;
	int		response ;

	if( form_label == VS_K_tws_Rotation ) {
		om$send( msg = message VSmdstifCmd.sub_form_notification(
							me->rotDefForm, 
							gadget_label ),
			targetid = my_id );
	} else {

	switch( gadget_label ) {
	  case VS_K_tws_Rotation		: 
	  case VS_K_bm_Dismiss_Execute		:
	  case VS_K_bm_Execute			:
	  case VS_K_sf_Position			:
	  case VS_K_bm_AccessToGapDetctGrp	:
	  case VS_K_bm_GapDetection_Toggle	:
	  case VS_K_bm_GapDetection_MaxFld	: break ;
	  default :
	  om$send( msg	    = message VSmdbeamCmd.form_notification(
		                    form_label, gadget_label, value, form_ptr ),
		   mode	    = OM_e_wrt_message,
		   targetid = my_id ) ;
	}

	switch( gadget_label ) {

	case VS_K_bm_Dismiss_Execute	:
		/*
		 * Modify stiffener(s), then exit command.
		 */
		response = TERMINATE ;
		/*
		 * If we do not set the display mode, CEO will re_highlight the
		 * beam's support upon Dismiss_Execute.
		 */
		goto EXECUTE ;

	case VS_K_bm_Execute		:
		/*
		 * Construct stiffeners, then go to state "start".
		 */
		response = EX_BACK_UP ;
	EXECUTE :
		if( (me->flag & VS_K_modify_form) || me->number_of_beams > 1 ) {
			if( me->recompSurf ) {
			     om$send( msg = message VSmdstifCmd.recomp_surface( 
								&msg ),
					targetid = my_id );
			}
		  om$send( msg      = message VSmdbeamCmd.construct_beam( &msg),
			   targetid = my_id ) ;

		  ex$putque( msg = &msg, response = &response ) ;
		} else {
		  om$send( msg	= message VSplbeamCmd.tellUser(	VS_gI_StNoMod ),
			   targetid = my_id ) ;
		  FIg_set_state_off( form_ptr, gadget_label ) ;
		}
		break ;

	case VS_K_sf_Position		:
		me->flag |= ( VS_K_change_cnst_type | VS_K_modify_form ) ;

		if( 1 == (int) value ) {
		  me->position = VS_K_stUseSurfOfPrj ;
		  FIg_enable( form_ptr, VS_K_bm_AccessToGapDetctGrp ) ;
		} else {
		  me->position = VS_K_stNormalToSide ;
		  FIg_disable( form_ptr, VS_K_bm_AccessToGapDetctGrp ) ;
		}

		om$send( msg	  = message VSmdstifCmd.inter_display( &msg ),
			 targetid = my_id ) ;
		break ;

	case VS_K_bm_AccessToGapDetctGrp:
	         FIg_set_state_off( form_ptr, VS_K_bm_Section_Manipulation ) ;
	         DISPLAY_GROUP( GapDetection ) ;
	         break ;

	case VS_K_bm_GapDetection_Toggle:
	        me->flag |= ( VS_K_modify_form | VS_K_change_gap_dtc ) ;
	        if( 1 == (int) value ) {
		  FIg_enable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
	        } else {
		  FIg_disable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
	        }
	        break ;
	      
	  case VS_K_bm_GapDetection_MaxFld:
	       /*
	        * Maximum gap value must be >= 0.
	        */
		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					verify	= VSisDblPositive,
					oldValue= me->maxAdmGap,
					newValue= &me->maxAdmGap ) ;
		me->flag |= VS_K_modify_form | VS_K_change_gap_dtc ;
		break ;

	case VS_K_bm_Material_Type	:
	case VS_K_bm_Shape_Name 	:
	case VS_K_bm_Section_Name	:
	case VS_K_bm_X_Sym		:
	case VS_K_bm_Y_Sym		:
	case VS_K_bm_XY_Sym		:
	case VS_K_bm_No_Sym		:
		me->modAttr |= VS_m_yOffset ;
		break ;

	case VS_K_bm_Name		: me->nameModified = TRUE ; break;


	case VS_K_tws_Rotation		: 
		if ( me->rotDefForm ) {
			int disp_sts ;
			FIf_is_displayed( me->rotDefForm, &disp_sts ) ;

			if( !(disp_sts ) )
				FIf_display( me->rotDefForm );
		} else {
			om$send( msg = message VSmdstifCmd.load_twist_info(
								&msg),
					targetid = my_id );
			FIf_display( me->rotDefForm );
		}
		break;

	default 			: break ;
	}
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method resetForm( int *sts ) {

	char		*form = me->fm_ptr ;
	long		msg ;

	FIf_reset( form ) ;

	/*
	 * Erase section draw on form.
	 */
	if( me->ActGrp == VS_K_bm_Grp_Definition )
		vs$repaint_gadget( form = form, gadget = VS_K_bm_Area ) ;

	me->ActGrp = VS_K_bm_Grp_Default ;

	FIg_display( form, me->ActGrp ) ;

	om$send(msg	= message VSmdstifCmd.initForm( (int *) &msg ),
		targetid= my_id ) ;

	om$send(msg	= message VSplbeamCmd.set_initial_gadget_attributes( &msg ),
		targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method resetForm */
/*----------------------------------------------------------------------------*/
method initForm( int * sts ) {

	char	*form = me->fm_ptr ;

	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	VSg_replace( form, VS_K_bm_Placement, VS_K_sf_Modification ) ;

	VSinitStiffenerEditionForm( form ) ;

	FIg_set_state( form, VS_K_sf_Position, VS_K_stNormalToSide ) ;

	return OM_S_SUCCESS ;

} /* method initForm */
/*----------------------------------------------------------------------------*/
method load_attributes_from_beam( long *msg ) {

	long		sts = OM_S_SUCCESS ;
	unsigned long	attrMask,
			type ;
	struct GRid	LocatedStif = me->event1.located_object[0].located_obj ;
	char		*form = me->fm_ptr ;
	double		excessGap = 0 ;
	int		gapDetectionON = FALSE ;

	om$send(msg	= message VSmdbeamCmd.load_attributes_from_beam( msg ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	/*
	 * For stiffener, no rotation available.
	 */
	me->rotation = 0. ;

	/*
	 * For stiffener, just reference point bottom middle, bottom left and
	 * bottom right are availables.
	 */
	if( me->reference_point != VS_e_BOT_LEFT &&
	    me->reference_point != VS_e_BOT_MIDD &&
	    me->reference_point != VS_e_BOT_RGHT ) {
		me->reference_point = VS_e_BOT_LEFT ;
		FIg_set_state_on( form, VS_K_bm_Bot_Left ) ;
	}

	/*
	 * Retrieve construction type if located beam is a stiffener and if
	 * active stiffener can be placed along plane.
	 */
	if( me->CanPlaceAlPl ) {
	  sts = om$send( msg	 = message VSpart.VSgetUserEditableAttr(
						    msg, &type, &attrMask ),
		        targetid = LocatedStif.objid,
		        targetos = LocatedStif.osnum ) ;
	  __CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	  if( type == VS_m_STF_BEAM ) {
	    struct GRid	original ;

	    sts = om$send( msg	   = message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message NDmacro.ACreturn_foot(
					     msg, "", &original, NULL, NULL ) ),
			   targetid = LocatedStif.objid,
			   targetos = LocatedStif.osnum ) ;
	    __CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;

	    sts = om$send( msg	   = message VSstfBeam.VSgetConstructionType(
	    					           msg, &me->position ),
	    		   targetid= original.objid,
	    		   targetos= original.osnum ) ;
	    __CheckRC( sts, *msg, "VSstfBeam.VSgetConstructionType", wrapup ) ;

	    FIg_set_state( form, VS_K_sf_Position, me->position ) ;

	    me->flag |= VS_K_change_cnst_type ;

	    if( me->position == VS_K_stUseSurfOfPrj ) {
	      struct GRid gapDetector ;
	      FIg_enable( form, VS_K_bm_AccessToGapDetctGrp ) ;

	      /*
	       * Is there a gap detector on the stiffener ?
	       */
	      sts = VSfindChildByType( &original, OPP_VSgapDtector_class_id,
	    				&gapDetector ) ;
	      if( ( sts & 1 ) && !IF_NULL_OBJID( gapDetector.objid ) ) {
	      	struct ret_struct	value ;
	      	int			rc ;
	      	int			index = -1 ;

		gapDetectionON = TRUE ;

	      	sts = om$send( msg      = message NDmacro.ACgive_structure(
	      	                           &rc, &index, VS_K_gdVirtOutMaxAdmGap,
	      	                           &value, &me->ModuleInfo ),
	      	               targetid = gapDetector.objid,
	      	               targetos = gapDetector.osnum ) ;
	      	me->maxAdmGap = value.var.root_pm_st.value ;
                index = -1 ;
	      	sts = om$send( msg      = message NDmacro.ACgive_structure(
	      	                           &rc, &index, VS_K_gdVirtOutExcessGap,
	      	                           &value, &me->ModuleInfo ),
	      	               targetid = gapDetector.objid,
	      	               targetos = gapDetector.osnum ) ;
	      	excessGap = value.var.root_pm_st.value ;
	      }
	    }
	  }
	}
	FIg_set_state( form, VS_K_bm_GapDetection_Toggle, gapDetectionON  ) ;
	if( gapDetectionON ) {
		FIg_enable( form, VS_K_bm_GapDetection_MaxFld ) ;
	} else {
		FIg_disable( form, VS_K_bm_GapDetection_MaxFld ) ;
	}
	FIfld_set_value( form, VS_K_bm_GapDetection_MaxFld, 0, 0,
	      			 me->maxAdmGap, FALSE ) ;
	FIfld_set_value( form, VS_K_bm_GapDetection_ValFld, 0, 0,
	      			 excessGap, FALSE ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method load_attributes_from_beam */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	int	VS_K_sf_Position_save,
		VS_K_bm_AccessToGapDetctGrp_save,
		VS_K_tws_Rotation_save,
		gadget;

	*msg = MSSUCC ;

	om$send(msg	= message VSmdbeamCmd.load_attributes( msg ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;
	__CheckRC( 1, *msg, "VSmdbeamCmd.load_attributes", wrapup ) ;
	
	/*
	 * For symmetries 'XY' and 'X', substract height of cross section
	 * from Y offset.
	 */
	if( me->symmetry == VS_e_XY_Symm || me->symmetry == VS_e_X_Symm  ) {
	   long		sts ;	
	   struct GRid 	sectDef ;

	   sts = vs$load_part_from_RDB( msg	= msg,
					material= me->actMat,
					family	= me->actFam,
					part	= me->actPrt,
					osnum	= me->cstEnv._MD_OS,
					object	= &sectDef ) ;
	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "vs$load_part_from_RDB", wrapup ) ;

	   /*
	    * Get height of cross section.
	    */
           sts = VSgetHeightOfCrossSectionDef( msg,
					       &sectDef,
					       &me->cstEnv,
					       &me->InternalYOff ) ;
	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;

	} else me->InternalYOff = 0. ;
	
	me->Y_offset -= me->InternalYOff ;

	/*
	 * load construction type of stiffener.
	 */
	if( !(me->flag & VS_K_no_attributes) ) {
		struct GRobj_env	stif ;
		/*
		 * Get active located stiffener.
		 */
		om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &stif ),
			targetid= my_id ) ;
		if( vs$is_ancestry_valid(object	 = &stif._grid ,
					 classid = OPP_VStwsBeam_class_id ) ) {
			me->isTwistedStfnr = TRUE ;
		}

		if( me->isTwistedStfnr ) {
			FIg_copy (	me->fm_ptr, 
					VS_K_sf_Position,
					&VS_K_sf_Position_save, 1);
			FIg_copy (	me->fm_ptr, 
					VS_K_bm_AccessToGapDetctGrp,
					&VS_K_bm_AccessToGapDetctGrp_save, 1);
			vs$g_delete_gadgets( form = me->fm_ptr,
					     list = `VS_K_sf_Position,
					     VS_K_bm_AccessToGapDetctGrp` ) ;
			FIg_add_to_group( me->fm_ptr,
					  VS_K_tws_Rotation,
					  VS_K_bm_Grp_Manipulation );
			gadget = VS_K_sf_Position;
			FIg_copy (	me->fm_ptr, 
					VS_K_sf_Position_save, 
					&gadget, 0);
			gadget = VS_K_bm_AccessToGapDetctGrp;
			FIg_copy (	me->fm_ptr, 
					VS_K_bm_AccessToGapDetctGrp_save,
					&gadget, 0);
			vs$g_delete_gadgets( form = me->fm_ptr,
					     list = `VS_K_sf_Position_save,
					     VS_K_bm_AccessToGapDetctGrp_save`);

			if ( me->rotDefForm)  {
				FIf_delete( me->rotDefForm ) ; 
				me->rotDefForm = NULL ;
			}
			om$send(msg	= message VSmdstifCmd.load_twist_info( 
								msg ),
				targetid= my_id ) ;
		} else {
			FIg_copy (	me->fm_ptr, 
					VS_K_tws_Rotation,
					&VS_K_tws_Rotation_save, 1);
			vs$g_delete_gadgets (	form = me->fm_ptr,
						list = `VS_K_tws_Rotation`);
			FIg_add_to_group (	me->fm_ptr, 
						VS_K_sf_Position, 
						VS_K_bm_Grp_Manipulation ) ;
			FIg_add_to_group (	me->fm_ptr, 
						VS_K_bm_AccessToGapDetctGrp, 
						VS_K_bm_Grp_Manipulation ) ;
			gadget = VS_K_tws_Rotation;
			FIg_copy (	me->fm_ptr, 
					VS_K_tws_Rotation_save,
					&gadget, 0);
			vs$g_delete_gadgets( form = me->fm_ptr,
					     list = `VS_K_tws_Rotation_save`);
			om$send(msg	= message VSmdstifCmd.load_cnst_type( 
								msg ),
				targetid= my_id ) ;
		}
	}

	wrapup :
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method load_cnst_type( long *msg ) {

	long			sts ;
	struct GRobj_env	stif ;
	struct GRid		beamAxis ;
	int			cst_type ;
	char			*form = me->fm_ptr ;
	double			excessGap = 0 ;
	int			gapDetectionON = FALSE ;

	/*
	 * Get active located stiffener.
	 */
	om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &stif ),
		targetid= my_id ) ;

	/*
	 * See if active stiffener can be placed along plane.
	 * Get beam axis.
	 */
	sts = VSgetBeamAxisOfStiffener( msg, &stif._grid, &beamAxis ) ;
	__CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

	sts = om$send(	msg	= message VSbeamAxis.VSgetConstructionType(
							    msg, &cst_type ),
			targetid= beamAxis.objid,
			targetos= beamAxis.osnum ) ;
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetConstructionType", wrapup ) ;

	me->CanPlaceAlPl = cst_type == VS_K_baIntersection ;
	if( me->CanPlaceAlPl ) {
		struct GRid	original ;
		sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
						msg,
						OM_e_wrt_object,
						message NDmacro.ACreturn_foot(
							msg, "", &original, 
								NULL, NULL ) ),
				targetid = stif._objid,
				targetos = stif._osnum ) ;
		__CheckRC(sts, *msg, "VSfeature.VSforwardToOriginal", wrapup);

		if( vs$is_ancestry_valid(object	 = &original ,
					 classid = OPP_VStwsBeam_class_id ) ) {
			me->CanPlaceAlPl = FALSE ;
		}
	}


	/*
	 * Retrieve construction type if stiffener can be placed along plane.
	 */
	if( me->CanPlaceAlPl ) {
	  struct GRid	original ;
	  sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message NDmacro.ACreturn_foot(
					     msg, "", &original, NULL, NULL ) ),
		         targetid = stif._objid,
		         targetos = stif._osnum ) ;
	  __CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup );

	  sts = om$send( msg	   = message VSstfBeam.VSgetConstructionType(
	    					           msg, &me->position ),
	    		 targetid= original.objid,
	    		 targetos= original.osnum ) ;
	  __CheckRC( sts, *msg, "VSstfBeam.VSgetConstructionType", wrapup ) ;

	  FIg_set_state( form, VS_K_sf_Position, me->position ) ;
	  FIg_enable( form, VS_K_sf_Position ) ;

	  if( me->position == VS_K_stUseSurfOfPrj ) {
	    struct GRid gapDetector ;
	    FIg_enable( form, VS_K_bm_AccessToGapDetctGrp ) ;

	    /*
	     * Is there a gap detector on the stiffener ?
	     */
	    sts = VSfindChildByType( &original, OPP_VSgapDtector_class_id,
	    				&gapDetector ) ;
	    if( ( sts & 1 ) && !IF_NULL_OBJID( gapDetector.objid ) ) {
	      struct ret_struct	value ;
	      int			rc ;
	      int			index = -1 ;

	      gapDetectionON = TRUE ;

	      sts = om$send( msg      = message NDmacro.ACgive_structure(
	      	                           &rc, &index, VS_K_gdVirtOutMaxAdmGap,
	      	                           &value, &me->ModuleInfo ),
	      	             targetid = gapDetector.objid,
	      	             targetos = gapDetector.osnum ) ;
	      me->maxAdmGap = value.var.root_pm_st.value ;
              index = -1 ;
	      sts = om$send( msg      = message NDmacro.ACgive_structure(
	      	                           &rc, &index, VS_K_gdVirtOutExcessGap,
	      	                           &value, &me->ModuleInfo ),
	      		     targetid = gapDetector.objid,
	      	             targetos = gapDetector.osnum ) ;
	      excessGap = value.var.root_pm_st.value ;
	    }
	  }
	} else {
	  me->position = VS_K_stNormalToSide ;
	  FIg_set_state( form, VS_K_sf_Position, me->position ) ;
	  FIg_disable( form, VS_K_sf_Position ) ;
	}
	FIg_set_state( form, VS_K_bm_GapDetection_Toggle, gapDetectionON  ) ;
	if( gapDetectionON ) {
		FIg_enable( form, VS_K_bm_GapDetection_MaxFld ) ;
	} else {
		FIg_disable( form, VS_K_bm_GapDetection_MaxFld ) ;
	}
	FIfld_set_value( form, VS_K_bm_GapDetection_MaxFld, 0, 0,
	      			 me->maxAdmGap, FALSE ) ;
	FIfld_set_value( form, VS_K_bm_GapDetection_ValFld, 0, 0,
	      			 excessGap, FALSE ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method load_cnst_type */
/*----------------------------------------------------------------------------*/
int VSgetRow( refType )
char	refType ;
{
  	int row = 0;
  	
	switch( refType ) {
	  	case 'N' :
		case 'n' :	row = 0; break ;
	  	case 'F' :
		case 'f' :	row = 1; break ;
		case 'B' :
		case 'b' :	row = 2; break ;
	  	case 'W' :
		case 'w' :	row = 3; break ; 
		/*
		 * Shouldn't  come here
		 */
		default	 :	break ;
	}
	
	return row ;
}/* VSgetRow */
/*----------------------------------------------------------------------------*/
method load_twist_info( long *msg ) {
	long			sts ;
	struct GRobj_env	stif ;
	struct GRid		beamSupp ;
	int			ACcount , 
				nbParents;
	struct GRid		ACpretend,
				*myParents ;
	char			text[15], 
				refType[2] ;
	int			x_pos, 
				y_pos ;
	double			xsAng[2] ;
	char			expVal[80];
	int			flag , 
				row ,
				num_char = 15 ;

	/*
	 * Get active located stiffener.
	 */
	sts =om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &stif ),
			targetid= my_id ) ;

	sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
						msg,
						OM_e_wrt_object,
						message NDnode.NDget_objects( 
								ND_ROOT,
								&ACpretend,
								1,
								NULL,
								0,
								0,
								&ACcount )),
			targetid = stif._objid,
			targetos = stif._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;
	__DBGpr_obj(" Pretend Obj", ACpretend );

	/*
	 * Get beam axis from ACpretend #1.
	 */
	sts = om$send( msg	= message ACpretend.ACfind_parent(
							&beamSupp, NULL, NULL ),
		       targetid = ACpretend.objid,
		       targetos = ACpretend.osnum ) ;
	__CheckRC( sts, 1, "ACpretend.ACfind_parent", wrapup ) ;
	__DBGpr_obj("Beam Support Obj", beamSupp);

	sts = om$send(msg	= message NDnode.NDget_objects( 
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&myParents,
						0,
						OM_K_MAXINT,
						&nbParents ),
			targetid = beamSupp.objid,
			targetos = beamSupp.osnum ) ;
	__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

	__DBGpr_int(" Parent count of BeamSupp", nbParents );
	
	if ( me->rotDefForm ) FIf_delete( me->rotDefForm ) ;

	VSf_sub_form(	me->fm_ptr,
			VS_K_tws_Rotation,
			VS_K_ROT_DEFN_FILE,
			&me->rotDefForm ) ;

	FIf_get_location( me->fm_ptr, &x_pos, &y_pos ) ;
	FIf_set_location( me->rotDefForm, x_pos+480, y_pos+260 ) ;

	sts = VStxtExpValue( 	myParents[1].objid, 
			 	myParents[1].osnum,
				&expVal );
	__CheckRC( sts, 1, "VStxtExpValue", wrapup ) ;

	sscanf(expVal, "%c|%lf|%c|%lf", &refType[0], &xsAng[0], 
					&refType[1], &xsAng[1] );

	FIfld_set_value(me->rotDefForm, 
			VS_K_tws_StAngle, 
			0, 
			0, 
			xsAng[0], 
			TRUE ) ; 

	FIfld_set_value(me->rotDefForm, 
			VS_K_tws_EdAngle, 
			0, 
			0, 
			xsAng[1], 
			TRUE ) ; 

	row = VSgetRow( refType[0] );
	
	FIfld_get_list_text( 	me->rotDefForm, 
				VS_K_tws_StRefType, row, 0, 
				num_char, (unsigned char *)text, &flag );
	
	FIfld_set_text( me->rotDefForm, VS_K_tws_StRefType, 0, 0, text, TRUE );

	row = VSgetRow( refType[1] );

	FIfld_get_list_text( 	me->rotDefForm, 
				VS_K_tws_EdRefType, row, 0, 
				num_char, (unsigned char *)text, &flag );

	FIfld_set_text( me->rotDefForm, VS_K_tws_EdRefType, 0, 0, text, TRUE );

wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method load_twist_info */
/*----------------------------------------------------------------------------*/
method inter_display( long * msg ) {

	long			sts ;
	struct GRobj_env	stifLocated ;
	struct GRid		sectDef ;
	int			oldPosition = me->position ;

	/*
	 * Change construction type to have good support surface with respect
	 * to position wanted.
	 */
	if( me->CanPlaceAlPl ) {
		/*
		 * Get active stiffener located.
		 */
		om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &stifLocated ),
			targetid= my_id ) ;

		/*
		 * Get construction type of stiffener.
		 */
		sts = om$send( msg	= message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message VSstfBeam.VSgetConstructionType(
								msg,
								&oldPosition )),
			       targetid = stifLocated._objid,
			       targetos = stifLocated._osnum ) ;
		__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup );

		 /*
		  * Change construction type.
		  */
		 if( me->position != oldPosition ) {
			sts = om$send( msg	= message
						  VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message VSstfBeam.VSputConstructionType(
								msg,
								me->position )),
				       targetid = stifLocated._objid,
				       targetos = stifLocated._osnum ) ;
			__CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal",
				   wrapup ) ;
		 }
	}

	/*
	 * For symmetries 'XY' and 'X', set Y offset to height of cross section
	 * to have the stiffener outside of plate.
	 */
	if( me->symmetry == VS_e_XY_Symm || me->symmetry == VS_e_X_Symm  ) {

	   sts = vs$load_part_from_RDB( msg	= msg,
				        material= me->actMat,
					family	= me->actFam,
					part	= me->actPrt,
					osnum	= me->cstEnv._MD_OS,
					object	= &sectDef ) ;

	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "vs$load_part_from_RDB", wrapup ) ;

	   /*
	    * Get height of cross section.
	    */
           sts = VSgetHeightOfCrossSectionDef( msg,
					       &sectDef,
					       &me->cstEnv,
					       &me->InternalYOff ) ;
	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;

	} else me->InternalYOff = 0. ;

	/*
	 * Place cross section.
	 */
	me->Y_offset += me->InternalYOff ;
	
	om$send(msg	= message VSmdbeamCmd.inter_display( msg ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	me->Y_offset -= me->InternalYOff ;

	wrapup :
	  if( me->position != oldPosition ) {
	    om$send( msg      = message VSfeature.VSforwardToOriginal(
				   msg, OM_e_wrt_object,
				   message VSstfBeam.VSputConstructionType(
							   msg, oldPosition ) ),
		     targetid = stifLocated._objid,
		     targetos = stifLocated._osnum ) ;
	  }

	  if( me->position == VS_K_stUseSurfOfPrj )
	    vs$bulk_delete( objenvs = &me->surfaceOfCS ) ;

	return OM_S_SUCCESS ;

} /* method inter_display */
/*----------------------------------------------------------------------------*/
method construct_beam( long *msg ) {

	long			sts = OM_S_SUCCESS ;
	int			i,
				cst_type ;
	struct GRobj_env	*stifList = NULL ;
	struct GRid		beamAxis ;
	int			batchMode ;
	int			batchModeWasModified = TRUE ;

	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	/*
	 * Get located stiffeners.
	 */
	stifList = _MALLOC( me->number_of_beams, struct GRobj_env ) ;
	if( !stifList ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
					  msg, me->number_of_beams, stifList ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup );

	/*
	 * Change Name of Stiffner
 	 * commented the vdobj$ChgName for TR179901700
	 */
	
	if( me->number_of_beams == 1 ) 
	{
                if ( me->nameModified)  
		{
		  // TR179800861
/*
		  sts = vdobj$ChgName(msg = msg, objOE = &stifList[0], name = me->basename, keepDir = 1);
*/
		  /*
		    om$send(msg = message GRgraphics.GRchgname(
		    msg,
		    &stifList[0].mod_env,
		    me->basename),
		    targetid = stifList[0]._objid,
		    targetos = stifList[0]._osnum ) ;
		    */
                }
	}

	/*
	 * Change position of stiffener.
	 */

	if( ( me->flag & VS_K_change_cnst_type ) || me->number_of_beams > 1 ) {

	  /*
	   * For each stiffener, if stiffener can be placed along plane
	   * then put new construction type.
	   */
	  for( i = 0 ;  i < me->number_of_beams ; i++ ) {
	    /*
	     * Retrieve beam axis of stiffener.
	     */
	    sts = VSgetBeamAxisOfStiffener( msg, &stifList[i]._grid, &beamAxis ) ;					
	     __CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

	    sts = om$send( msg	= message VSbeamAxis.VSgetConstructionType(
							    msg, &cst_type ),
		           targetid = beamAxis.objid,
			   targetos = beamAxis.osnum ) ;
	    __CheckRC( sts, *msg, "VSbeamAxis.VSgetConstructionType", wrapup );

	   if( cst_type == VS_K_baIntersection ) {

	     sts = om$send( msg      = message VSfeature.VSforwardToOriginal(
				     msg,
				     OM_e_wrt_object,
				     message VSstfBeam.VSputConstructionType(
							 msg, me->position ) ),
			    targetid = stifList[i]._objid,
			    targetos = stifList[i]._osnum ) ;
	     __CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;
	   }
	  }
	}

	/*
	 * Inhibit the batch is we hade to modify gap detection: gap detectors
	 * are children of stiffeners. We do not want them to recompute twice.
	 * VSmdbeamCmd.construct_beam will start the batch if the batch is not
	 * deferred...
	 */
	if( me->flag & VS_K_change_gap_dtc ) {
		nd$mod_batch(	request 	= ND_GET,
				p_ret_mode	= &batchMode ) ;
		if( batchMode != ND_DEFER ) {
			int mode = ND_DEFER ;
			nd$mod_batch(	request 	= ND_SET,
					req_mode	= &mode ) ;
			batchModeWasModified = TRUE ;
		}
	}

	/*
	 * Construct beam.
	 */
	me->Y_offset += me->InternalYOff ;
	
	om$send( msg	  = message VSmdbeamCmd.construct_beam( msg ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	me->Y_offset -= me->InternalYOff ;

	if( me->flag & VS_K_change_gap_dtc ) {
	  int	 	gapDetectionON ;

	  FIg_get_state( me->fm_ptr, VS_K_bm_GapDetection_Toggle,
	  		 &gapDetectionON ) ;
	  /*
	   * Change setting of gap detection if needed.
	   */
	  for( i = 0 ; i < me->number_of_beams ; i++ ) {
	     struct GRid	gapDetector ;

	    /*
	     * Is there a gap detector on the stiffener ?
	     */
	     sts = VSfindChildByType( &stifList[i]._grid, OPP_VSgapDtector_class_id,
	    			      &gapDetector ) ;
	     if( !( sts & 1 ) ) continue ;
	     if( IF_NULL_OBJID( gapDetector.objid ) ) {
	       if( gapDetectionON ) {
	         struct GRvg_construct cst ;
		 vs$fill_cnst_list(	Env_info	= &me->cstEnv,
					Display 	= &me->ActiveDisplay,
					Level		= me->ActiveLevel,
					Cnst_list	= cst,
					Msg		= msg ) ;

		 *msg = VSplaceGapDetector( &stifList[i]._grid,
		 			    &stifList[i].mod_env,
					    me->maxAdmGap, &cst, &gapDetector );
		 if( *msg ) {
			vs$bulk_display( dpmode = GRbd,
					 grids	= &gapDetector,
				 	 theEnv = &me->cstEnv ) ;
		 }
	       }
	     } else {
	       if( gapDetectionON ) {
	       	 /*
	       	  * See if value of the maximum admissible gap has changed.
	       	  */
	       	 int			index = -1 ;
	       	 int			rc ;
	       	 struct ret_struct	value ;

	       	 sts = om$send( msg      = message NDmacro.ACgive_structure(
	      	                           &rc, &index, VS_K_gdVirtOutMaxAdmGap,
	      	                           &value, &me->ModuleInfo ),
	      	                targetid = gapDetector.objid,
	      	                targetos = gapDetector.osnum ) ;
	      	 
	      	 if( me->maxAdmGap != value.var.root_pm_st.value ) {
	      	   struct GRid exp ;
	      	   sts = om$send( msg	   = message ACcpx.ACfind_temp_obj(
					     &rc, VS_K_gdInputMaxAdmGap, &exp ),
	      	                  targetid = gapDetector.objid,
	      	                  targetos = gapDetector.osnum ) ;
		   if( sts & 1 & rc ) {
		      short RC ;
		      int   type = ND_COMP ;
		      sts = om$send( msg      = message expression.NDset_value( NULL,
			      			me->maxAdmGap, &me->ModuleInfo,
        			                &RC ),
        			     targetid = exp.objid,
	      	                     targetos = exp.osnum ) ;

		      nd$wait_batch(	l_obj_info	= &type,
					type		= GR_GEOM_POSTED,
					l_object	= &exp,
					nb_obj		= 1 ) ;

		   }
	      	 }
	       } else {
	       	 vs$bulk_delete( grids = &gapDetector, theEnv = &me->cstEnv ) ;
	       }
	     }	    
	  }
	}

	wrapup :
		if( batchModeWasModified ) {
			nd$mod_batch(	request 	= ND_SET,
					p_ret_mode	= &batchMode ) ;
			if( batchMode != ND_DEFER ) nd$exec_batch() ;
		}
		_FREE( stifList ) ;

		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
 	return OM_S_SUCCESS ;

} /* method construct_beam */
/*----------------------------------------------------------------------------*/

end implementation VSmdstifCmd ;
