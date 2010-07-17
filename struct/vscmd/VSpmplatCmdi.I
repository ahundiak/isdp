/*
	I/STRUCT
*/
class implementation VSpmplatCmd ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "COBmacros.h"
#include "growner.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsplate.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vsicondef.h"
#include "vsRDBmacros.h"
#include "vsglobalmsg.h"
#include "vsdbgmacros.h"
#include "vscmdmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsformmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsexpvalue.h"
#include "vsformproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsstrngproto.h"

from GRgraphics	import	GRconstruct ;
from ACdb_info	import	ACset_db_info ;
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {
	
	long 	sts ;
	double	value ;
	
	om$send( msg	= message VSplplatCmd.wakeup( pos ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;
 		 
	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	if( !me->fm_ptr ) goto wrapup ;

	/*
	 * Test if Thickness parameter was modified.
	 */	 
	if( IF_NULL_OBJID( me->expression.objid ) ) goto wrapup ;

	sts = VSexpValue( me->expression.objid, me->expression.osnum, &value ) ;
	__CheckRC( sts, 1, "VSexpValue", wrapup ) ;
	
	if( value != me->expValue ) {
	  om$send( msg	    = message VSfmplatCmd.QueryRDB(
				&sts, VS_m_prt | VS_m_par | VS_m_force, FALSE ),
		   targetid = my_id ) ;

	  om$send( msg	    = message VSpmplatCmd.updCutOff( &sts, me->cut_off),
		   targetid = my_id ) ;
			 
	  om$send( msg	    = message VSpmplatCmd.fillThkCutOffFld( &sts ),
		   targetid = my_id ) ;
	}

	wrapup : 
		return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {
	
	int 	row ;
	long	msg ;
	
	if( me->flag & VS_K_init_failed ) goto wrapup ;

	/*
	 * If no Thickness parameter, reload Thickness and Value List
	 */
	if( IF_NULL_OBJID( me->expression.objid ) ) {
		
		VSfreeList( me->prtCount, me->prtList ) ;
		VScopyList( &msg, me->oldprtList, me->oldprtCount, &me->prtList ) ;
	
		_FREE( me->parVal ) ;
		me->parVal = _MALLOC( me->oldprtCount, double ) ;
		for( row = 0 ; row < me->oldprtCount ; row++ ) {
			me->parVal[row] = me->oldparVal[row] ;
		}
	
		me->prtCount = me->oldprtCount ;
		me->prtIndex = me->oldprtIndex ;
	
		me->actPar = me->parVal[me->prtIndex] ;
		strcpy( me->actPrt, me->prtList[me->prtIndex] ) ;
	}

	VSfreeList( me->oldprtCount, me->oldprtList ) ;
	_FREE( me->oldparVal ) ;

	wrapup :
		om$send( msg	  = message VSfmplatCmd.delete( f_defer_flag ),
			 mode 	  = OM_e_wrt_message,
			 targetid = my_id ) ;
		return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {
	
	om$send( msg	  = message VSplplatCmd.init_cmd( sts ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;
		 
	FIf_set_collapse_symbol( me->fm_ptr, VS_K_CLP_SYM_FILE, VS_K_CLP_PlcPmPl ) ;

	me->expValue = 0. ;
	me->expression.objid = NULL_OBJID ;
	
	return OM_S_SUCCESS ;
 
} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmplat_labels[] = {
	{ VS_K_pl_Dismiss_Execute	, TRUE },
	{ VS_K_pl_Execute		, TRUE },
	{ VS_K_pl_Revert		, TRUE },
	{ VS_K_pl_Dismiss		, TRUE },
	{ VS_K_pl_Message		, TRUE },
	{ VS_K_pl_Material_Type		, TRUE },
	{ VS_K_pl_Material_Grade	, TRUE },
	{ VS_K_pl_Plate_Type		, TRUE },
	{ VS_K_pl_Thickness		, TRUE },
	{ VS_K_pl_Cut_Off		, TRUE },
	{ VS_K_pl_Offset		, TRUE },
	{ VS_K_pl_Directory		, TRUE },
	{ VS_K_pl_Name			, TRUE },
	{ VS_K_pl_Stock_Number		, TRUE },
	{ VS_K_pl_Source		, TRUE },
	{ VS_K_pl_Fireproofing		, TRUE },
	{ VS_K_pl_Approval_Status	, TRUE },
	{ VS_K_pl_Construction_Status	, TRUE },
	{ VS_K_pl_Member_Class		, TRUE },
	{ VS_K_pl_Member_Type		, TRUE },
	{ VS_K_pl_Change_Number		, TRUE },
	{ VS_K_pl_Orientation		, TRUE },
	{ VS_K_pl_Number_Of_Plates	, TRUE },
	{ VS_K_pl_Comments		, TRUE },
	{ VS_K_pl_Copy_Params		, TRUE },
	{ VS_K_pl_Definition		, TRUE },
	{ VS_K_pl_Plate_Manipulation  	, TRUE },
	{ VS_K_pl_Material_Take_Off	, TRUE },
	{ VS_K_pl_User_Attributes	, TRUE },
	{ VS_K_pl_Mcf_User_Attributes	, TRUE },
	{ -1				, TRUE }	/* End-of-list flag */
} ;
	long				sts ;
	unsigned long			attrMask,
					type ;
	register struct VSgadget	*l ;

#define NO_EDIT( attr ) !( attrMask & VS_m_##attr )
#define SET_NO_EDIT( gadget )\
	VSsetGadgetModifiable(	VS_Ga_fmplat_labels,\
				VS_K_pl_##gadget,\
				FALSE )

	for( l = VS_Ga_fmplat_labels ; l->label != -1 ; l++ ) {
		l->touchable = TRUE ;
	}

	/*
	 * Construct fake parametric plate, just to get editable attributes.
	 */
	sts = vs$get_modifiable_attr(	msg		= msg,
					classname	= "VSvarPlate",
					type		= &type,
					attributes	= &attrMask ) ;
	if( sts & 1 & *msg ) {
		if( !attrMask ) {
			/*
			 * Plate not editable at all.
			 */
			for( l = VS_Ga_fmplat_labels ; l->label != -1 ; l++ ) {
				l->touchable = FALSE ;
			}
			om$send(msg	= message VSfmplatCmd.tellUser(
							VS_gW_PartNtEdit ),
				targetid= my_id ) ;
		} else {
			if( NO_EDIT( MatType		) )  
				SET_NO_EDIT( Material_Type	) ; 
			
			if( NO_EDIT( MatGrade		) )  
				SET_NO_EDIT( Material_Grade	) ;
			
			if( NO_EDIT( Notes		) )  
				SET_NO_EDIT( Comments		) ;
			
			if( NO_EDIT( PartFam		) )  
				SET_NO_EDIT( Plate_Type		) ;
			
			if( NO_EDIT( MtoStk		) ) {
				SET_NO_EDIT( Stock_Number	) ;
			}
			if( NO_EDIT( MtoSrc		) ) 
				SET_NO_EDIT( Source		) ;
			
			if( NO_EDIT( CutOff		) ) 
				SET_NO_EDIT( Cut_Off		) ;
			
			if( NO_EDIT( Offset		) ) 
				SET_NO_EDIT( Offset		) ;
			
			if( NO_EDIT( Orientation	) ) 
				SET_NO_EDIT( Orientation	) ;
			
			if( NO_EDIT( PartNum	) ) {
				SET_NO_EDIT( Thickness		) ;
			}
 			if( NO_EDIT( MbrClass		) ) 
				SET_NO_EDIT( Member_Class	) ;
			
 			if( NO_EDIT( MbrType		) ) 
				SET_NO_EDIT( Member_Type	) ;
			
 			if( NO_EDIT( AppStat		) ) 
				SET_NO_EDIT( Approval_Status	) ;
				
 			if( NO_EDIT( CstStat		) ) 
				SET_NO_EDIT( Construction_Status) ;
				
 			if( NO_EDIT( FpThck		) ) 
				SET_NO_EDIT( Fireproofing 	) ; 
			
			if( NO_EDIT( ChgNum		) )
				SET_NO_EDIT( Change_Number	) ; 

			if( NO_EDIT( UsrAttr		) ) 
				SET_NO_EDIT( Mcf_User_Attributes) ; 
			
		}
	}
	*msg = MSSUCC ;
	*list = VS_Ga_fmplat_labels ;

	return OM_S_SUCCESS ;

#undef NO_EDIT
#undef SET_NO_EDIT

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method QueryRDB( long *msg ; int action, fillForm ) {

	long	sts ;

	om$send(msg	= message VSfmplatCmd.QueryRDB( msg, action, fillForm ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;
	if( !( *msg & 1 ) || !( action & VS_m_prt ) ) goto wrapup ;

	/*
	 * Caution: the list of previous part may not have been saved yet.
	 */
	if( me->oldprtList ) {
		strcpy( me->actPrt, me->oldprtList[me->oldprtIndex] ) ;
	}
		 
	if( !IF_NULL_OBJID( me->expression.objid ) ) {
		char	*thkName = NULL ;
		double	value ;

		sts = VSexpValue( me->expression.objid, me->expression.osnum,
				  &value ) ;
		__CheckRC( sts, 1, "VSexpValue", wrapup ) ;
		
		me->expValue = value ;

		vs$find_thickness_in_RDB(	
					msg		= msg,
					material	= me->actMat,
					family		= me->actFam,
					value		= value,
					p_thickness	= &me->actPar,
					p_thkname	= &thkName ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		
		om$send(msg	= message VSqryRdbCmd.setActiveItems(
						NULL, NULL, NULL, thkName ),
			targetid= my_id ) ;
	} else {
		/*
		 * Save Thickness and Value lists. While the thickness
		 * parameter isn't set, this list contains just one item,
		 * 'Unknown' for Thickness list and -1. for Value list.
		 */
		om$send( msg	= message VSpmplatCmd.SaveList( &sts ),
			 targetid = my_id ) ;
			 
		sts = OM_S_SUCCESS ; *msg = MSSUCC ;
	}
	
	wrapup :
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method QueryRDB */
/*----------------------------------------------------------------------------*/
method construct_plate( long *msg ) {

	char			*form = me->fm_ptr ;
	long			sts ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	int			i,
				count ;
	char			name[DI_PATH_MAX] ;
	struct GRobj_env	*supports = NULL,
				parents[2] ;
	struct GRid		plateId ;
	struct ACdb_info	checkin ;
	struct GRid		cachedPart ;

	/*
	 * Get parents.
	 */
	supports = _MALLOC( me->number_of_plates, struct GRobj_env ) ;
	if( !supports ) {
		*msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
					msg, me->number_of_plates, supports ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	VSfixPlateRep(   me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	parents[1]._grid	= me->expression ;
	parents[1].mod_env	= me->cstEnv ;
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= me->ActiveRep.representation ;
	vsargs.feature_att	= (char *) &part ;

	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount ) {
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename  = VS_K_ActPlUAttr,
				      nbEntries	= me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &me->UAid ) ;
		me->flag &= ~VS_K_change_usr_attr ;
	}

	sts = vs$fillPlateAttr(	msg		= msg,
				options		= VS_m_All,
				partFam		= me->actFam,
				matType		= me->actMat,
				matGrade	= me->actGrd,
				partNum		= me->actPrt,
				usrNotes	= me->notes,
				mtoSrc		= me->source,
				mtoStk		= me->stock,
				FireProofing	= me->fireproofing,
				mtoChgNo	= me->change_number,
				apprvStat	= me->approval_status,
				constStat	= me->construction_status,
				mbrClass	= me->clsCode[me->clsIndex],
				mbrType		= me->typCode[me->typIndex],
				orientation	= me->orientation,
				cutOff		= me->cut_off,
				offset		= me->offset,
				thickness	= me->actPar,
				usrAttrId	= &me->UAid,
				partAttr	= &part,
				plateAttr	= &plate ) ;

	strcpy( checkin.catalog	, "vssrcplate" ) ;
	strcpy( checkin.part_num, "vssrcplate" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;
	checkin.quantity = STRUCT_PLATE_OBJ ;

	/*
	 * Load plate from RDB.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &cachedPart ) ;
	__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;

	count = me->number_of_plates ;
	for( i = 0 ; i < count ; i++ ) {

		/*
		 * Must get construction defaults generated by each parent.
		 */
		vs$getBmOrPlCstDefaults(
				msg		= msg,
				symb_id		= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				matchKey	= me->matchKey,
				memberClass	= me->clsCode[me->clsIndex],
				matchId		= &supports[i]._grid,
				path		= me->directory,
				level		= &me->ActiveLevel,
				display		= &me->ActiveDisplay ) ;

		if( *me->basename ) {
			DIstmcpy( name, me->directory, me->basename, NULL ) ;
		} else {
			/*
			 * Plate unnamed.
			 */
			*name = '\0' ;
		}

		parents[0] = supports[i] ;
		cstargs.name = name ;

		/*
		 * Unhighlight parent support.
		 */
		vs$bulk_display( dpmode = GRhe, objenvs = &supports[i] ) ;

		/*
		 * Construct plate, then display it.
		 */
		sts = om$construct(
			classname= me->const_class,
			osnum	 = me->cstEnv._MD_OS,
			p_objid	 = &plateId.objid,
			msg	 = message GRgraphics.GRconstruct( &cstargs ) );

		if( !( sts & 1 & *msg ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;

			ex$message(	msgnumb		= VSgetMsgKey( *msg ),
					field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					time		= 2 ) ;

			me->number_of_plates = 0 ;
			goto wrapup ;
		}
		
		plateId.osnum = me->cstEnv._MD_OS ;
		
		/*
		 * Store PDU check-in information.
		 */
		om$send(msg	= message ACdb_info.ACset_db_info( msg,
								&checkin ),
			targetid= plateId.objid,
			targetos= plateId.osnum ) ;

		/*
		 * Display plate.
		 */
	 	vs$bulk_display( dpmode = GRbd,
	 	                 grids  = &plateId,
	 	                 theEnv	= &me->cstEnv ) ;
		 	                 
		/*
		 * Must find a new base name.
		 */
		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( msg, me->directory, name, me->basename ) ;
		}

		/*
		 * Decrease plate count.
		 */
		me->number_of_plates-- ;
		FIfld_set_value( form, VS_K_pl_Number_Of_Plates,
				 0, 0, (double) me->number_of_plates, FALSE ) ;
	}
	/*
	 * Display new base name.
	 */
	FIfld_set_text( form, VS_K_pl_Name, 0, 0, me->basename, FALSE ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		om$send(msg	= message VSfmplatCmd.display_support_normal(
									 GRhe ),
			targetid= my_id ) ;

		_FREE( supports ) ;
		me->expression.objid = NULL_OBJID ;

		return OM_S_SUCCESS ;

} /* method construct_plate */
/*----------------------------------------------------------------------------*/
method fillThkCutOffFld( long *msg ) {
	
	FIfld_set_text( me->fm_ptr, VS_K_pl_Thickness, 0, 0,
			me->actPrt, FALSE ) ;
			
	om$send( msg	  = message VSfmplatCmd.updCutOff( msg, me->cut_off ),
		 targetid = my_id ) ;

	return OM_S_SUCCESS ;

} /* method fillThkCutOffFld */
/*----------------------------------------------------------------------------*/
method enable_form( long *msg ) {
	
	char	*form = me->fm_ptr ;
	long 	msg ;

	om$send( msg = message VSplplatCmd.enable_form( &msg ),
		 mode	= OM_e_wrt_message,
		 targetid = my_id ) ;
		 
	/*
	 * Set Cut-off Thickness not editable as long as Thickness parameter is
	 * not set.
	 */
	if( IF_NULL_OBJID( me->expression.objid ) ) {
		FIg_disable( form, VS_K_pl_Cut_Off ) ;
		FIg_disable( form, VS_K_pl_Copy_Params ) ;
	} else {
		FIg_enable( form, VS_K_pl_Cut_Off ) ;
		FIg_enable( form, VS_K_pl_Copy_Params ) ;
	}	
	
	return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		sts ;

	sts = om$send(	msg	= message VSplplatCmd.form_notification(
					form_label, gadget_label,
					value, form_ptr ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
			
	switch( gadget_label ) {
		
	case VS_K_pl_Revert		:
		/*
		 * Set Cut-off Thickness not editable as long as Thickness
		 * parameter is not set.
	 	 */
		if( IF_NULL_OBJID( me->expression.objid ) ) {
			vs$g_disable_gadgets( form = form_ptr,
					      list = `VS_K_pl_Cut_Off,
						      VS_K_pl_Thickness,
						      -1` ) ;
			om$send( msg	= message VSpmplatCmd.SaveList( &sts ),
				 targetid = my_id ) ;
		} else
			om$send(msg	= message VSfmplatCmd.QueryRDB(
					    &sts, VS_m_prt | VS_m_par, FALSE ),
				targetid= my_id ) ;
		om$send( msg	  = message VSpmplatCmd.fillThkCutOffFld( &sts),
			 targetid = my_id ) ;
		break ;
		
	default				: 
		break ;
	
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method updCutOff( long *msg ; double value ) {
	
	char		*unit,
			*cutOff,
			unknown[MS_MAX_MSG_LENGTH] ;
	double		actPar ;

	if( me->actPar == -1. ) actPar = me->oldparVal[me->oldprtIndex] ;
	else			actPar = me->actPar ;

	if( me->flag & VS_K_deflt_cutoff ) {
		me->cut_off = actPar ;
	} else {
	  if( value >= actPar ) {
	    me->cut_off = value ;
	  } else {
	    /* Bad cut-off value */
	    if( !IF_NULL_OBJID( me->expression.objid ) )
	      om$send(msg     = message VSfmplatCmd.tellUser( VS_gW_BadCutOff ),
		      targetid= my_id ) ;
	    if( me->cut_off <= actPar ) {
	      me->flag |= VS_K_deflt_cutoff ;
	      me->cut_off = actPar ;
	    }
	  }
	}
	
	if( me->actPar == -1. ) {
		ex$message( msgnumb = VS_gI_Unknown, buff = unknown ) ;
		cutOff = unknown ;
	} else {
		vs$system_to_unit(	msg	= msg,
					value	= me->cut_off,
					osnum	= me->cstEnv.md_id.osnum,
					p_unit	= &unit ) ;
		cutOff = unit ;
	}
	
	FIfld_set_text( me->fm_ptr, VS_K_pl_Cut_Off, 0, 0, cutOff, FALSE ) ;
	
	return OM_S_SUCCESS ;

} /* method updCutOff */
/*----------------------------------------------------------------------------*/
method SaveList( long *msg ) {
	
	int 	row ;
	char	*toCpy[1] ;

	/*
	 * Save Thickness and Value lists. As long as the thickness parameter
	 * isn't set, this lists contain just one item, 'Unknown' for
	 * Thickness list and -1.0 for Value list.
	 */
	VSfreeList( me->oldprtCount, me->oldprtList ) ;
	VScopyList( msg, me->prtList, me->prtCount, &me->oldprtList ) ;
	
	_FREE( me->oldparVal ) ;
	me->oldparVal = _MALLOC( me->prtCount, double ) ;
	for( row = 0 ; row < me->prtCount ; row++ ) {
		me->oldparVal[row] = me->parVal[row] ;
	}
	
	VSfreeList( me->prtCount, me->prtList ) ;
	_FREE( me->parVal ) ;
	
	me->oldprtCount = me->prtCount ;
	me->oldprtIndex = me->prtIndex ;
	
	me->prtCount = 1 ;
	me->prtIndex = 0 ;
	
	me->parVal = _MALLOC( 1, double ) ;
	me->parVal[0] = -1. ;
	
	toCpy[0] = VSmsgkey2string( VS_gI_Unknown ) ;
	VScopyList( msg, toCpy, 1, &me->prtList ) ;

	me->actPar = me->parVal[me->prtIndex] ;
	strcpy( me->actPrt, me->prtList[me->prtIndex] ) ;

	return OM_S_SUCCESS ;

} /* method SaveList */
/*----------------------------------------------------------------------------*/

end implementation VSpmplatCmd ;
